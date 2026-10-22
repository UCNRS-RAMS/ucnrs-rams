import { readFile } from 'node:fs/promises';
import { parse } from 'yaml';
import {
  outputSearchSchema,
  projectContextSchema,
  schemaFromParameters,
} from './tool_schemas.mjs';

const RESOURCES = {
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

const ANNOTATIONS = {
  readOnlyHint: true,
  destructiveHint: false,
  idempotentHint: true,
  openWorldHint: true,
};

export async function registerRamsTools(server, { api, outputs }) {
  const contract = parse(await readFile(new URL('../swagger/v1/swagger.yaml', import.meta.url), 'utf8'));
  registerApiReads(server, api, contract);
  registerProjectContext(server, api);
  registerOutputSearch(server, outputs);
}

function registerApiReads(server, api, contract) {
  // Explicit allowlist: future OpenAPI write operations are never exposed.
  for (const [resource, { singular, description }] of Object.entries(RESOURCES)) {
    for (const single of [false, true]) {
      const path = `/api/v1/${resource}${single ? '/{id}' : ''}`;
      const endpoint = contract.paths[path];
      if (!endpoint?.get) throw new Error(`Missing GET contract: ${path}`);
      const parameters = [...(endpoint.parameters ?? []), ...(endpoint.get.parameters ?? [])];
      server.registerTool(`${single ? 'get' : 'list'}_${single ? singular : resource}`, {
        description: `${endpoint.get.description} ${description} ${single
          ? 'A 404 means unknown or inaccessible, not necessarily nonexistent.'
          : 'Returns one page with total_count, completeness and next_call; do not report page length as a portfolio total.'}`,
        inputSchema: schemaFromParameters(parameters),
        annotations: ANNOTATIONS,
      }, async args => toolResult(await api.get(resource, args)));
    }
  }
}

function registerProjectContext(server, api) {
  server.registerTool('get_project_context', {
    description: 'Assemble a read-only evidence dossier: project, assigned reserve, one page of visits, and one page of fundings. At most four API reads. Includes participant ORCIDs in the original records, provenance, separate collection continuation calls, and explicit partial errors. Date bounds apply only to visits. No scholarly searches or linkage confirmation are performed.',
    inputSchema: projectContextSchema,
    annotations: ANNOTATIONS,
  }, async args => toolResult(await api.projectContext(args)));
}

function registerOutputSearch(server, outputs) {
  server.registerTool('search_outputs', {
    description: [
      'Search DataCite, OpenAlex, Crossref, and optionally a Zotero group library for candidate publications and datasets, using exact DOI, ROR, ORCID, and funding award identifiers.',
      'Makes at most four reads against RAMS plus one query per source-supported identifier; key collection reads one page of fundings and visits.',
      'Every result is an unconfirmed identifier match. This read-only tool creates no project-output link, so nothing here establishes that an output used a reserve.',
      'No candidates means these keys and sources returned nothing, not that no outputs exist. Failed or skipped sources are listed separately from empty ones.',
    ].join(' '),
    inputSchema: outputSearchSchema,
    annotations: ANNOTATIONS,
  }, async args => toolResult(await outputs.search(args)));
}


function toolResult(output) {
  return {
    content: [{ type: 'text', text: JSON.stringify(output) }],
    structuredContent: output,
    isError: output.status === 'error',
  };
}
