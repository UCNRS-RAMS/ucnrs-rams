// Candidate-output search across external scholarly sources.
//
// RAMS exposes reserve DOIs, researcher ORCIDs, funding award numbers, and a
// legacy reserve ROR value. This module uses them as exact search keys, asks
// DataCite, OpenAlex, Crossref and optionally a Zotero group library, and
// returns CANDIDATES. A candidate is an unconfirmed identifier match; it is
// never a reserve-provenance link.

const DOI_PREFIX = /^10\.\d{4,9}\//;
const ORCID = /^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$/;
const ROR = /^0[0-9a-hj-km-np-tv-z]{6}\d{2}$/;
const REQUEST_TIMEOUT_MS = 15_000;

const defaultBases = {
  datacite: 'https://api.datacite.org',
  openalex: 'https://api.openalex.org',
  crossref: 'https://api.crossref.org',
  zotero: 'https://api.zotero.org',
};

export const outputEvidenceLimits = [
  'Candidates are unconfirmed identifier matches. A shared DOI, ROR ID, ORCID, or award number does not prove that an output used a reserve.',
  'ROR searches are institution-wide affiliation matches, not project- or reserve-specific evidence.',
  'Only a curator-reviewed project-output link would confirm provenance; this read-only search creates none.',
  'No candidates is not evidence that no outputs exist; it means these search keys and sources returned nothing.',
  'Search keys come from a single page of RAMS records. Truncated or failed key reads are reported in search_keys.',
];

export function normalizeDoi(value) {
  if (typeof value !== 'string') return null;
  let doi = value.trim().toLowerCase().replace(/^https?:\/\/(dx\.)?doi\.org\//, '').replace(/^doi:\s*/, '');
  try {
    doi = decodeURIComponent(doi);
  } catch {
    return null;
  }
  doi = doi.replace(/[.,;:\])}]+$/, '');
  return DOI_PREFIX.test(doi) ? doi : null;
}

export function normalizeOrcid(value) {
  if (typeof value !== 'string') return null;
  const orcid = value.trim().replace(/^https?:\/\/orcid\.org\//i, '').toUpperCase();
  return ORCID.test(orcid) ? orcid : null;
}

export function normalizeRor(value) {
  if (typeof value !== 'string') return null;
  const id = value.trim().replace(/^https?:\/\/(?:www\.)?ror\.org\//i, '').replace(/\/$/, '').toLowerCase();
  return ROR.test(id) ? `https://ror.org/${id}` : null;
}

// Award numbers are free text in RAMS, so both the raw value (for the query)
// and a letters-and-digits form (for dedupe) are kept.
export function normalizeAward(value) {
  if (typeof value !== 'string') return null;
  const award = value.trim();
  if (!award) return null;
  return { value: award, key: award.toUpperCase().replace(/[^0-9A-Z]/g, '') };
}

// Every scholarly request carries only the User-Agent and, for Zotero, a group
// API key, so base URLs are constrained the same way RAMS_API_URL is: HTTPS
// (loopback HTTP allowed for tests) with no embedded credentials or query.
function assertBaseUrl(source, value) {
  let url;
  try {
    url = new URL(value);
  } catch {
    throw new Error(`Scholarly source "${source}" needs an absolute base URL.`);
  }
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if ((url.protocol !== 'https:' && !(local && url.protocol === 'http:')) ||
      url.username || url.password || url.search || url.hash) {
    throw new Error(`Scholarly source "${source}" must use HTTPS (HTTP only on loopback) and carry no credentials, query, or fragment.`);
  }
  return url.href.replace(/\/$/, '');
}

function firstYear(...values) {
  for (const value of values) {
    const match = String(value ?? '').match(/\b(1[6-9]\d{2}|20\d{2})\b/);
    if (match) return Number(match[1]);
  }
  return null;
}

export class OutputSearch {
  #rams;
  #fetch;
  #bases;
  #contactEmail;
  #zoteroApiKey;

  constructor({ rams, fetch: fetchImpl = globalThis.fetch, bases = {}, contactEmail, zoteroApiKey }) {
    this.#rams = rams;
    this.#fetch = fetchImpl;
    this.#bases = { ...defaultBases };
    for (const [source, value] of Object.entries(bases)) {
      if (!(source in defaultBases)) throw new Error(`Unknown scholarly source "${source}".`);
      this.#bases[source] = assertBaseUrl(source, value);
    }
    this.#contactEmail = contactEmail?.trim() || null;
    this.#zoteroApiKey = zoteroApiKey?.trim() || null;
  }

  #headers(extra = {}) {
    const headers = { Accept: 'application/json', ...extra };
    // OpenAlex, Crossref and DataCite route identified callers to a faster pool.
    headers['User-Agent'] = `rams-mcp/0.1.0${this.#contactEmail ? ` (mailto:${this.#contactEmail})` : ''}`;
    return headers;
  }

  async #request(base, path, { params = {}, headers = {} } = {}) {
    // Relative resolution keeps any path prefix in an overridden base URL.
    const url = new URL(path.replace(/^\//, ''), `${this.#bases[base]}/`);
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined) url.searchParams.set(key, String(value));
    }
    const source = { url: url.href, retrieved_at: null };
    try {
      const response = await this.#fetch(url, {
        headers: this.#headers(headers),
        redirect: 'error',
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
      source.retrieved_at = new Date().toISOString();
      if (!response.ok) {
        await response.body?.cancel();
        const message = {
          401: 'The upstream source rejected the request credential.',
          403: 'The upstream source refused this query.',
          429: 'The upstream source rate limited this client; retry later.',
        }[response.status] ?? 'The upstream source could not complete this query.';
        return { status: 'error', source, error: { code: 'upstream_error', message, http_status: response.status } };
      }
      const body = await response.json();
      return { status: 'ok', source, body };
    } catch (error) {
      source.retrieved_at = new Date().toISOString();
      if (error.name === 'TimeoutError') {
        return { status: 'error', source, error: { code: 'timeout', message: 'The upstream source did not respond within 15 seconds.' } };
      }
      if (error instanceof SyntaxError) {
        return { status: 'error', source, error: { code: 'invalid_response', message: 'The upstream source did not return valid JSON.' } };
      }
      // Exception messages can carry configuration or response data, so they are not echoed.
      return { status: 'error', source, error: { code: 'connection_error', message: 'Could not reach the upstream source; redirects are not followed.' } };
    }
  }

  async #datacite(keys, perSource) {
    const queries = [];
    for (const entry of keys.dois) {
      queries.push(this.#request('datacite', '/dois', {
        params: { 'page[size]': perSource, query: `relatedIdentifiers.relatedIdentifier:"${entry.doi}"` },
      }));
    }
    for (const award of keys.grants) {
      queries.push(this.#request('datacite', '/dois', {
        params: { 'page[size]': perSource, query: `fundingReferences.awardNumber:"${award.value}"` },
      }));
    }
    for (const ror of keys.rors) {
      queries.push(this.#request('datacite', '/dois', {
        params: { 'page[size]': perSource, 'affiliation-id': ror, affiliation: true },
      }));
    }
    const results = await Promise.all(queries);
    const records = [];
    const failed = results.filter(result => result.status === 'error');
    for (const result of results) {
      for (const item of result.body?.data ?? []) {
        const attributes = item.attributes ?? {};
        records.push({
          doi: normalizeDoi(attributes.doi) ?? normalizeDoi(item.id),
          title: attributes.titles?.[0]?.title ?? null,
          year: attributes.publicationYear ? Number(attributes.publicationYear) : null,
          type: attributes.types?.resourceTypeGeneral?.toLowerCase() ?? null,
          match: result.source.url,
        });
      }
    }
    return { source: 'datacite', attempted: queries.length, records, failed };
  }

  async #openalex(keys, perSource) {
    const queries = [];
    for (const orcid of keys.orcids) {
      queries.push(this.#request('openalex', '/works', { params: { 'per-page': perSource, filter: `author.orcid:${orcid}` } }));
    }
    for (const award of keys.grants) {
      queries.push(this.#request('openalex', '/works', { params: { 'per-page': perSource, filter: `grants.award_id:${award.value}` } }));
    }
    for (const ror of keys.rors) {
      queries.push(this.#request('openalex', '/works', { params: { 'per-page': perSource, filter: `institutions.ror:${ror}` } }));
    }
    const results = await Promise.all(queries);
    const records = [];
    for (const result of results) {
      for (const item of result.body?.results ?? []) {
        records.push({
          doi: normalizeDoi(item.doi),
          title: item.title ?? item.display_name ?? null,
          year: item.publication_year ?? null,
          type: item.type ?? null,
          match: result.source.url,
        });
      }
    }
    return { source: 'openalex', attempted: queries.length, records, failed: results.filter(r => r.status === 'error') };
  }

  async #crossref(keys, perSource) {
    const queries = [];
    for (const orcid of keys.orcids) {
      queries.push(this.#request('crossref', '/works', { params: { rows: perSource, filter: `orcid:${orcid}` } }));
    }
    for (const award of keys.grants) {
      queries.push(this.#request('crossref', '/works', { params: { rows: perSource, filter: `award.number:${award.value}` } }));
    }
    for (const ror of keys.rors) {
      queries.push(this.#request('crossref', '/works', { params: { rows: perSource, filter: `ror-id:${ror}` } }));
    }
    const results = await Promise.all(queries);
    const records = [];
    for (const result of results) {
      for (const item of result.body?.message?.items ?? []) {
        records.push({
          doi: normalizeDoi(item.DOI),
          title: item.title?.[0] ?? null,
          year: firstYear(item['published-print']?.['date-parts']?.[0]?.[0], item['published-online']?.['date-parts']?.[0]?.[0], item.issued?.['date-parts']?.[0]?.[0]),
          type: item.type ?? null,
          match: result.source.url,
        });
      }
    }
    return { source: 'crossref', attempted: queries.length, records, failed: results.filter(r => r.status === 'error') };
  }

  async #zotero(groupId, perSource) {
    if (!this.#zoteroApiKey) {
      return { source: 'zotero', attempted: 0, records: [], failed: [], skipped: 'ZOTERO_API_KEY is not configured for this MCP process.' };
    }
    const result = await this.#request('zotero', `/groups/${encodeURIComponent(groupId)}/items/top`, {
      params: { limit: perSource },
      headers: { 'Zotero-API-Version': '3', 'Zotero-API-Key': this.#zoteroApiKey },
    });
    if (result.status === 'error') return { source: 'zotero', attempted: 1, records: [], failed: [result] };
    const records = (Array.isArray(result.body) ? result.body : []).map(item => ({
      doi: normalizeDoi(item.data?.DOI),
      title: item.data?.title ?? null,
      year: firstYear(item.data?.date),
      type: item.data?.itemType ?? null,
      match: result.source.url,
    }));
    return { source: 'zotero', attempted: 1, records, failed: [] };
  }

  // Collects search keys from the same bounded RAMS reads as
  // get_project_context. Each read's outcome is reported so a failed key read
  // is never mistaken for an absent identifier.
  async #collectKeys({ project_id, reserve_id, per_page }) {
    const reads = [];
    const keys = { dois: [], rors: [], orcids: [], grants: [] };
    let reserveId = reserve_id;

    if (project_id !== undefined) {
      const project = await this.#rams.get('projects', { id: project_id });
      reads.push({ resource: 'projects', id: project_id, status: project.status, source: project.source });
      if (project.status !== 'ok') return { failure: project };
      reserveId = project.data.reserve?.id ?? reserveId;
      for (const [role, stub] of [['owner', project.data.owner], ['applicant', project.data.applicant]]) {
        const orcid = normalizeOrcid(stub?.orcid);
        if (orcid) keys.orcids.push({ orcid, role });
      }
      const [fundings, visits] = await Promise.all([
        this.#rams.get('fundings', { project_id, page: 1, per_page }),
        this.#rams.get('visits', { project_id, page: 1, per_page }),
      ]);
      reads.push({ resource: 'fundings', project_id, status: fundings.status, source: fundings.source, coverage: readCoverage(fundings) });
      reads.push({ resource: 'visits', project_id, status: visits.status, source: visits.source, coverage: readCoverage(visits) });
      for (const funding of fundings.status === 'ok' ? fundings.data : []) {
        const award = normalizeAward(funding.grant_number);
        if (award) keys.grants.push({ ...award, sponsor: funding.sponsor_other ?? null });
      }
      // Visitor ORCIDs are the only per-project researcher identities RAMS
      // exposes beyond owner and applicant.
      for (const visit of visits.status === 'ok' ? visits.data : []) {
        for (const visitor of visit.visitors ?? []) {
          const orcid = normalizeOrcid(visitor.user?.orcid);
          if (orcid) keys.orcids.push({ orcid, role: visitor.role ?? 'visitor' });
        }
      }
    }

    if (reserveId !== undefined) {
      const reserve = await this.#rams.get('reserves', { id: reserveId });
      reads.push({ resource: 'reserves', id: reserveId, status: reserve.status, source: reserve.source });
      // A reserve read that fails while a project supplies the keys is a gap;
      // when the reserve is the only requested target it is the whole answer.
      if (reserve.status !== 'ok' && project_id === undefined) return { failure: reserve };
      if (reserve.status === 'ok') {
        // This legacy field is free text. Preserve the identifier type rather
        // than treating the known ROR value as a malformed DOI.
        const doi = normalizeDoi(reserve.data.doi);
        const ror = normalizeRor(reserve.data.doi);
        if (doi) keys.dois.push({ doi });
        if (ror) keys.rors.push({ ror, source: 'reserve_doi_field' });
      }
    }

    const seen = { orcids: new Set(), grants: new Set(), dois: new Set(), rors: new Set() };
    keys.orcids = keys.orcids.filter(entry => !seen.orcids.has(entry.orcid) && seen.orcids.add(entry.orcid));
    keys.grants = keys.grants.filter(entry => entry.key && !seen.grants.has(entry.key) && seen.grants.add(entry.key));
    keys.dois = keys.dois.filter(entry => !seen.dois.has(entry.doi) && seen.dois.add(entry.doi));
    keys.rors = keys.rors.filter(entry => !seen.rors.has(entry.ror) && seen.rors.add(entry.ror));
    return { keys, reads };
  }

  async search({ project_id, reserve_id, orcid, ror, grant_number, doi, zotero_group_id, per_source = 25, max_orcids = 5, max_rors = 5, max_grants = 10, per_page = 100 }) {
    if (project_id === undefined && reserve_id === undefined && !orcid && !ror && !grant_number && !doi) {
      return {
        status: 'error',
        error: { code: 'bad_request', message: 'Supply project_id, reserve_id, or at least one identifier (orcid, ror, grant_number, doi).' },
      };
    }

    const collected = await this.#collectKeys({ project_id, reserve_id, per_page });
    if (collected.failure) return collected.failure;

    const { keys, reads } = collected;
    for (const value of [orcid].flat()) {
      const normalized = normalizeOrcid(value);
      if (normalized && !keys.orcids.some(entry => entry.orcid === normalized)) {
        keys.orcids.push({ orcid: normalized, role: 'caller_supplied' });
      }
    }
    for (const value of [ror].flat()) {
      const normalized = normalizeRor(value);
      if (normalized && !keys.rors.some(entry => entry.ror === normalized)) {
        keys.rors.push({ ror: normalized, source: 'caller_supplied' });
      }
    }
    const award = normalizeAward(grant_number);
    if (award && !keys.grants.some(entry => entry.key === award.key)) keys.grants.push({ ...award, sponsor: null });
    const explicitDoi = normalizeDoi(doi);
    if (explicitDoi && !keys.dois.some(entry => entry.doi === explicitDoi)) keys.dois.push({ doi: explicitDoi });

    const truncated = {
      orcids: keys.orcids.length > max_orcids,
      rors: keys.rors.length > max_rors,
      grants: keys.grants.length > max_grants,
    };
    const usable = {
      dois: keys.dois,
      rors: keys.rors.slice(0, max_rors).map(entry => entry.ror),
      orcids: keys.orcids.slice(0, max_orcids).map(entry => entry.orcid),
      grants: keys.grants.slice(0, max_grants),
    };

    const sources = [];
    if (!usable.dois.length && !usable.rors.length && !usable.orcids.length && !usable.grants.length) {
      return {
        status: 'no_identifiers',
        query: { project_id: project_id ?? null, reserve_id: reserve_id ?? null, zotero_group_id: zotero_group_id ?? null },
        rams_reads: reads,
        search_keys: { ...keyReport(keys, usable, truncated, reads), note: 'No usable search key was found in the RAMS records read above.' },
        sources: [],
        candidates: [],
        evidence_limits: [...outputEvidenceLimits, 'No search key was available, so no source was queried. This is not evidence that no outputs exist.'],
        coverage: { external_output_search: 'not_performed', linkage_confirmation: 'not_performed' },
      };
    }

    const tasks = [
      this.#datacite(usable, per_source),
      this.#openalex(usable, per_source),
      this.#crossref(usable, per_source),
    ];
    if (zotero_group_id !== undefined) tasks.push(this.#zotero(zotero_group_id, per_source));
    const results = await Promise.all(tasks);

    for (const result of results) {
      // One record can answer several queries (an ORCID query and an award
      // query, say), so the count reported per source is distinct records.
      const distinct = new Set(result.records.map(record => record.doi ?? `title:${String(record.title ?? '').trim().toLowerCase()}`));
      sources.push({
        source: result.source,
        status: result.failed.length ? 'error' : result.skipped ? 'skipped' : 'ok',
        queries_attempted: result.attempted,
        records_returned: distinct.size,
        source_url: result.records[0]?.match ?? null,
        ...(result.failed.length ? { error: result.failed[0].error, error_source_url: result.failed[0].source.url } : {}),
        ...(result.skipped ? { reason: result.skipped } : {}),
      });
    }

    const merged = new Map();
    for (const result of results) {
      for (const record of result.records) {
        const key = record.doi ?? `title:${String(record.title ?? '').trim().toLowerCase()}`;
        if (!key || key === 'title:') continue;
        const existing = merged.get(key);
        const observation = {
          source: result.source,
          match: record.match,
          identifiers: record.doi ? { doi: record.doi } : {},
        };
        if (!existing) {
          merged.set(key, {
            doi: record.doi,
            title: record.title,
            year: record.year,
            type: record.type,
            relation: 'unconfirmed',
            url: record.doi ? `https://doi.org/${record.doi}` : null,
            observed_in: [observation],
          });
        } else {
          existing.title ??= record.title;
          existing.year ??= record.year;
          existing.type ??= record.type;
          if (!existing.observed_in.some(seen => seen.source === result.source && seen.match === observation.match)) {
            existing.observed_in.push(observation);
          }
        }
      }
    }

    const candidates = [...merged.values()].sort((left, right) =>
      (right.year ?? 0) - (left.year ?? 0) ||
      String(left.title ?? '').localeCompare(String(right.title ?? '')) ||
      String(left.doi ?? '').localeCompare(String(right.doi ?? '')));

    const failedSources = sources.filter(source => source.status === 'error');
    const failedReads = reads.filter(read => read.status !== 'ok');
    const incomplete = [
      ...failedSources.map(source => source.source),
      ...failedReads.map(read => `${read.resource} read`),
    ];
    const partialReads = reads.filter(read => read.coverage && !read.coverage.complete);
    return {
      status: incomplete.length ? 'partial' : 'ok',
      query: { project_id: project_id ?? null, reserve_id: reserve_id ?? null, ror: ror ?? null, zotero_group_id: zotero_group_id ?? null },
      rams_reads: reads,
      search_keys: keyReport(keys, usable, truncated, reads),
      sources,
      candidates,
      evidence_limits: [...outputEvidenceLimits, ...(incomplete.length
        ? [`${incomplete.join(', ')} did not complete, so these results are incomplete rather than empty.`]
        : []), ...partialReads.map(read =>
        `Key collection from ${read.resource} covered ${read.coverage.returned} of ${read.coverage.total} records, so identifiers on the rest were not searched.`)],
      coverage: {
        external_output_search: 'performed',
        linkage_confirmation: 'not_performed',
        relation_semantics: 'Every candidate is an unconfirmed identifier match. Only a curator-reviewed project-output link would confirm that an output used a reserve; this read-only search creates none.',
        sources_queried: sources.filter(source => source.status !== 'skipped').map(source => source.source),
        sources_failed: failedSources.map(source => source.source),
        candidates_before_deduplication: sources.reduce((total, source) => total + source.records_returned, 0),
        candidates_after_deduplication: candidates.length,
        ram_reads_failed: failedReads.map(read => `${read.resource}:${read.status}`),
      },
    };
  }
}

function readCoverage(result) {
  if (result.status !== 'ok' || !result.pagination) return null;
  return {
    returned: result.pagination.returned_count,
    total: result.pagination.total_count,
    complete: result.pagination.complete,
  };
}

function keyReport(keys, usable, truncated, reads) {
  return {
    reserve_dois: keys.dois.map(entry => entry.doi),
    rors: keys.rors.map(entry => ({ ror: entry.ror, source: entry.source })),
    orcids: keys.orcids.map(entry => ({ orcid: entry.orcid, role: entry.role })),
    award_numbers: keys.grants.map(entry => ({ award_number: entry.value, sponsor: entry.sponsor })),
    queried: { dois: usable.dois.length, rors: usable.rors.length, orcids: usable.orcids.length, award_numbers: usable.grants.length },
    truncated,
    read_coverage: reads.filter(read => read.coverage).map(read => ({ resource: read.resource, ...read.coverage })),
  };
}
