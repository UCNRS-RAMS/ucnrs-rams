// Candidate-output search across external scholarly sources.
//
// This module coordinates bounded RAMS key collection, source adapters, and
// result assembly. Each concern lives in a focused module so it can be tested
// or reused without constructing the entire search workflow.

import {
  addExplicitOutputKeys,
  selectOutputKeys,
} from './output_identifiers.mjs';
import { collectOutputKeys } from './output_keys.mjs';
import {
  buildOutputSearchResult,
  noIdentifiersResult,
} from './output_results.mjs';
import {
  searchCrossref,
  searchDataCite,
  searchOpenAlex,
  searchZotero,
} from './output_sources.mjs';
import { ScholarlyClient } from './scholarly_client.mjs';

export class OutputSearch {
  #rams;
  #client;
  #zoteroApiKey;

  constructor({ rams, fetch, bases, contactEmail, zoteroApiKey }) {
    this.#rams = rams;
    this.#client = new ScholarlyClient({ fetch, bases, contactEmail });
    this.#zoteroApiKey = zoteroApiKey?.trim() || null;
  }

  async search(query) {
    if (!hasSearchRoot(query)) {
      return {
        status: 'error',
        error: {
          code: 'bad_request',
          message: 'Supply project_id, reserve_id, or at least one identifier (orcid, ror, grant_number, doi).',
        },
      };
    }

    const {
      project_id,
      reserve_id,
      zotero_group_id,
      per_source = 25,
      max_orcids = 5,
      max_rors = 5,
      max_grants = 10,
      per_page = 100,
    } = query;
    const collected = await collectOutputKeys(this.#rams, { project_id, reserve_id, per_page });
    if (collected.failure) return collected.failure;

    const keys = addExplicitOutputKeys(collected.keys, query);
    const { usable, truncated } = selectOutputKeys(keys, {
      maxOrcids: max_orcids,
      maxRors: max_rors,
      maxGrants: max_grants,
    });
    const resultContext = { query, keys, usable, truncated, reads: collected.reads };

    if (!hasUsableKeys(usable)) return noIdentifiersResult(resultContext);

    const searches = [
      searchDataCite(this.#client, usable, per_source),
      searchOpenAlex(this.#client, usable, per_source),
      searchCrossref(this.#client, usable, per_source),
    ];
    if (zotero_group_id !== undefined) {
      searches.push(searchZotero(this.#client, zotero_group_id, per_source, this.#zoteroApiKey));
    }

    return buildOutputSearchResult({
      ...resultContext,
      results: await Promise.all(searches),
    });
  }
}

function hasSearchRoot({ project_id, reserve_id, orcid, ror, grant_number, doi }) {
  return project_id !== undefined ||
    reserve_id !== undefined ||
    valuesOf(orcid).length > 0 ||
    valuesOf(ror).length > 0 ||
    Boolean(grant_number) ||
    Boolean(doi);
}

function valuesOf(value) {
  if (value === undefined) return [];
  return Array.isArray(value) ? value.filter(Boolean) : [value].filter(Boolean);
}

function hasUsableKeys(keys) {
  return Object.values(keys).some(entries => entries.length > 0);
}
