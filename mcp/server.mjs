import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { McpServer } from '@modelcontextprotocol/server';
import { StdioServerTransport } from '@modelcontextprotocol/server/stdio';
import { parse } from 'yaml';
import * as z from 'zod';
import { RamsApi, evidenceLimits } from './api.mjs';
import { OutputSearch, normalizeDoi, normalizeOrcid, normalizeRor } from './outputs.mjs';

const resources = {
  projects: {
    singular: 'project',
    description: 'Project scope, topic, owner and applicant ORCIDs. Open status does not establish field activity. No free-text or ORCID search is available.',
  },
  reserves: {
    singular: 'reserve',
    description: 'Reserve identity and site metadata. Preserve DOI and ROR identifier types; do not infer output provenance from an identifier alone.',
  },
  visits: {
    singular: 'visit',
    description: 'Recorded visit windows, status, visiting researchers and institutions. Approved does not mean attended. Date filters select overlapping activity windows, not creation dates. A visit may name a different reserve than its project.',
  },
  fundings: {
    singular: 'funding',
    description: 'Grant identifiers, sponsors, investigators and award-status flags. Includes proposed and denied funding; not every record is an award. Amounts are not exposed. Access and reserve filtering follow the project.',
  },
  institutions: {
    singular: 'institution',
    description: 'Institution identity and geographic codes. state_code requires country_code. Institutions are not automatically expanded from person stubs.',
  },
};

const annotations = { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: true };
const positiveInteger = z.number().int().positive();
const pageSize = positiveInteger.max(100);

function inputSchema(parameters) {
  const shape = {};
  for (const parameter of parameters) {
    const schema = { ...parameter.schema };
    if (schema.type === 'integer') schema.minimum = Math.max(1, schema.minimum ?? 1);
    let value = z.fromJSONSchema(schema).describe(parameter.description ?? parameter.name);
    if (!parameter.required) value = value.optional();
    shape[parameter.name] = value;
  }
  return z.strictObject(shape).superRefine((args, context) => {
    if (args.state_code && !args.country_code) {
      context.addIssue({ code: 'custom', path: ['country_code'], message: 'country_code is required with state_code.' });
    }
    if (args.starts_on && args.ends_on && args.starts_on > args.ends_on) {
      context.addIssue({ code: 'custom', path: ['ends_on'], message: 'ends_on must be on or after starts_on.' });
    }
  });
}

function toolResult(output) {
  return {
    content: [{ type: 'text', text: JSON.stringify(output) }],
    structuredContent: output,
    isError: output.status === 'error',
  };
}

export async function createServer(config) {
  const api = new RamsApi(config);
  const outputs = new OutputSearch({
    rams: api,
    fetch: config.fetch,
    bases: config.scholarlyBases,
    contactEmail: config.contactEmail,
    zoteroApiKey: config.zoteroApiKey,
  });
  const contract = parse(await readFile(new URL('../swagger/v1/swagger.yaml', import.meta.url), 'utf8'));
  const server = new McpServer({ name: 'rams', version: '0.1.0' }, {
    instructions: [
      'Read-only RAMS research access. Start with list_reserves or a known project ID.',
      'Collections return exactly one page, never an automatic crawl. Follow pagination.next_call explicitly.',
      'Use get_project_context to assemble a bounded evidence dossier. Cite source URLs and record IDs.',
      'search_outputs returns candidate publications and datasets matched on exact RAMS identifiers. Every candidate remains unconfirmed until a downstream curator links it.',
      'Unknown and inaccessible records share a 404. Never interpret a failed read as an empty collection.',
      ...evidenceLimits,
    ].join('\n'),
  });

  // Explicit resource allowlist: future OpenAPI write operations are never exposed automatically.
  for (const [resource, { singular, description }] of Object.entries(resources)) {
    for (const single of [false, true]) {
      const path = `/api/v1/${resource}${single ? '/{id}' : ''}`;
      const endpoint = contract.paths[path];
      if (!endpoint?.get) throw new Error(`Missing GET contract: ${path}`);
      const parameters = [...(endpoint.parameters ?? []), ...(endpoint.get.parameters ?? [])];
      server.registerTool(`${single ? 'get' : 'list'}_${single ? singular : resource}`, {
        description: `${endpoint.get.description} ${description} ${single
          ? 'A 404 means unknown or inaccessible, not necessarily nonexistent.'
          : 'Returns one page with total_count, completeness and next_call; do not report page length as a portfolio total.'}`,
        inputSchema: inputSchema(parameters),
        annotations,
      }, async args => toolResult(await api.get(resource, args)));
    }
  }

  server.registerTool('get_project_context', {
    description: 'Assemble a read-only evidence dossier: project, assigned reserve, one page of visits, and one page of fundings. At most four API reads. Includes participant ORCIDs in the original records, provenance, separate collection continuation calls, and explicit partial errors. Date bounds apply only to visits. No scholarly searches or linkage confirmation are performed.',
    inputSchema: z.strictObject({
      project_id: positiveInteger.describe('RAMS project ID.'),
      visits_page: positiveInteger.optional().describe('Visit page, defaults to 1.'),
      fundings_page: positiveInteger.optional().describe('Funding page, defaults to 1.'),
      per_page: pageSize.optional().describe('Page size for each collection, defaults to 25, maximum 100.'),
      starts_on: z.iso.date().optional().describe('Include visits overlapping this date or later.'),
      ends_on: z.iso.date().optional().describe('Include visits overlapping this date or earlier.'),
    }).superRefine((args, context) => {
      if (args.starts_on && args.ends_on && args.starts_on > args.ends_on) {
        context.addIssue({ code: 'custom', path: ['ends_on'], message: 'ends_on must be on or after starts_on.' });
      }
    }),
    annotations,
  }, async args => toolResult(await api.projectContext(args)));

  server.registerTool('search_outputs', {
    description: [
      'Search DataCite, OpenAlex, Crossref, and optionally a Zotero group library for candidate publications and datasets, using exact DOI, ROR, ORCID, and funding award identifiers.',
      'Makes at most four reads against RAMS plus one query per source-supported identifier; key collection reads one page of fundings and visits.',
      'Every result is an unconfirmed identifier match. This read-only tool creates no project-output link, so nothing here establishes that an output used a reserve.',
      'No candidates means these keys and sources returned nothing, not that no outputs exist. Failed or skipped sources are listed separately from empty ones.',
    ].join(' '),
    inputSchema: z.strictObject({
      project_id: positiveInteger.optional().describe('RAMS project ID; keys come from its owner, applicant, fundings, and visit participants.'),
      reserve_id: positiveInteger.optional().describe('RAMS reserve ID; contributes the typed DOI or legacy ROR value from its free-text DOI field. Projects at that reserve are not crawled.'),
      orcid: z.union([z.string(), z.array(z.string())]).optional().describe('Extra ORCID iD or iDs to search, exact match.'),
      ror: z.union([z.string(), z.array(z.string())]).optional().describe('Extra ROR ID or IDs to search as exact creator or contributor affiliations.'),
      grant_number: z.string().optional().describe('Extra award number to search, exact match.'),
      doi: z.string().optional().describe('Extra DOI to search as an exact related identifier, for example a reserve or dataset DOI.'),
      zotero_group_id: z.string().optional().describe('Zotero group library ID to read; requires ZOTERO_API_KEY in the MCP environment, otherwise that source is reported skipped.'),
      per_source: pageSize.optional().describe('Records requested per query, defaults to 25, maximum 100.'),
      max_orcids: positiveInteger.max(25).optional().describe('Maximum ORCID keys queried, defaults to 5.'),
      max_rors: positiveInteger.max(25).optional().describe('Maximum ROR keys queried, defaults to 5.'),
      max_grants: positiveInteger.max(50).optional().describe('Maximum award-number keys queried, defaults to 10.'),
      per_page: pageSize.optional().describe('RAMS page size used when collecting funding and visit keys, defaults to 100 (the API maximum) so a project\'s whole visit history is covered in one read.'),
    }).superRefine((args, context) => {
      const orcids = [args.orcid].flat().filter(Boolean);
      const rors = [args.ror].flat().filter(Boolean);
      if (args.project_id === undefined && args.reserve_id === undefined && orcids.length === 0
          && rors.length === 0 && !args.grant_number && !args.doi) {
        context.addIssue({ code: 'custom', path: ['project_id'], message: 'Supply project_id, reserve_id, or at least one identifier.' });
      }
      if (args.doi !== undefined && !normalizeDoi(args.doi)) {
        context.addIssue({ code: 'custom', path: ['doi'], message: 'doi must be a DOI such as 10.21973/N30T0K.' });
      }
      for (const value of orcids) {
        if (!normalizeOrcid(value)) {
          context.addIssue({ code: 'custom', path: ['orcid'], message: 'Each orcid must be an iD such as 0000-0002-3004-1423.' });
        }
      }
      for (const value of rors) {
        if (!normalizeRor(value)) {
          context.addIssue({ code: 'custom', path: ['ror'], message: 'Each ror must be an ID such as https://ror.org/04sk0et52.' });
        }
      }
    }),
    annotations,
  }, async args => toolResult(await outputs.search(args)));

  return server;
}

// Resolves the API credential from either RAMS_API_TOKEN or a file named by
// RAMS_API_TOKEN_FILE. Returning the source lets startup name what it used
// without ever logging the token itself.
async function resolveCredential(env) {
  const direct = env.RAMS_API_TOKEN?.trim();
  if (direct) return { token: direct, source: 'RAMS_API_TOKEN' };

  const path = env.RAMS_API_TOKEN_FILE?.trim();
  if (!path) return {};
  try {
    return { token: (await readFile(path, 'utf8')).trim(), source: `RAMS_API_TOKEN_FILE=${path}` };
  } catch (error) {
    throw new Error(`cannot read RAMS_API_TOKEN_FILE (${path}): ${error.code ?? error.message}`);
  }
}

// Scholarly base URLs are overridable so deployments can route DataCite,
// OpenAlex, Crossref and Zotero traffic through a proxy, and so tests can run
// without reachable third parties. Values are validated by OutputSearch.
function resolveScholarlyBases(env) {
  const raw = env.RAMS_SCHOLARLY_BASES?.trim();
  if (!raw) return {};
  let bases;
  try {
    bases = JSON.parse(raw);
  } catch {
    throw new Error('RAMS_SCHOLARLY_BASES must be a JSON object mapping source names to base URLs.');
  }
  if (!bases || typeof bases !== 'object' || Array.isArray(bases)) {
    throw new Error('RAMS_SCHOLARLY_BASES must be a JSON object mapping source names to base URLs.');
  }
  return bases;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const { token, source } = await resolveCredential(process.env);
    const overrides = resolveScholarlyBases(process.env);
    const server = await createServer({
      baseUrl: process.env.RAMS_API_URL,
      token,
      contactEmail: process.env.RAMS_OUTPUT_CONTACT_EMAIL,
      zoteroApiKey: process.env.ZOTERO_API_KEY,
      scholarlyBases: overrides,
    });
    await server.connect(new StdioServerTransport());
    const routed = Object.keys(overrides);
    console.error(`RAMS MCP ready; credential source: ${source ?? 'none'}${routed.length ? `; scholarly base overrides: ${routed.join(', ')}` : ''}`);
  } catch (error) {
    console.error(`RAMS MCP could not start (${error.message}). Check RAMS_API_URL, one of RAMS_API_TOKEN or RAMS_API_TOKEN_FILE, dependencies, and the committed OpenAPI contract.`);
    process.exitCode = 1;
  }
}
