import * as z from 'zod';
import { normalizeDoi, normalizeOrcid, normalizeRor } from './output_identifiers.mjs';

const positiveInteger = z.number().int().positive();
const pageSize = positiveInteger.max(100);

export function schemaFromParameters(parameters) {
  const shape = {};
  for (const parameter of parameters) {
    const schema = { ...parameter.schema };
    if (schema.type === 'integer') schema.minimum = Math.max(1, schema.minimum ?? 1);
    let value = z.fromJSONSchema(schema).describe(parameter.description ?? parameter.name);
    if (!parameter.required) value = value.optional();
    shape[parameter.name] = value;
  }
  return z.strictObject(shape).superRefine(validateDateRangeAndLocation);
}

export const projectContextSchema = z.strictObject({
  project_id: positiveInteger.describe('RAMS project ID.'),
  visits_page: positiveInteger.optional().describe('Visit page, defaults to 1.'),
  fundings_page: positiveInteger.optional().describe('Funding page, defaults to 1.'),
  per_page: pageSize.optional().describe('Page size for each collection, defaults to 25, maximum 100.'),
  starts_on: z.iso.date().optional().describe('Include visits overlapping this date or later.'),
  ends_on: z.iso.date().optional().describe('Include visits overlapping this date or earlier.'),
}).superRefine(validateDateRangeAndLocation);

export const outputSearchSchema = z.strictObject({
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
}).superRefine(validateOutputSearch);

function validateDateRangeAndLocation(args, context) {
  if (args.state_code && !args.country_code) {
    context.addIssue({ code: 'custom', path: ['country_code'], message: 'country_code is required with state_code.' });
  }
  if (args.starts_on && args.ends_on && args.starts_on > args.ends_on) {
    context.addIssue({ code: 'custom', path: ['ends_on'], message: 'ends_on must be on or after starts_on.' });
  }
}

function validateOutputSearch(args, context) {
  const orcids = arrayOf(args.orcid).filter(Boolean);
  const rors = arrayOf(args.ror).filter(Boolean);
  if (args.project_id === undefined && args.reserve_id === undefined && orcids.length === 0 &&
      rors.length === 0 && !args.grant_number && !args.doi) {
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
}

function arrayOf(value) {
  if (value === undefined) return [];
  return Array.isArray(value) ? value : [value];
}
