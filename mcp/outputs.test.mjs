import assert from 'node:assert/strict';
import test from 'node:test';
import { OutputSearch } from './outputs.mjs';

const ORCID_A = '0000-0002-3004-1423';
const ORCID_B = '0000-0001-5732-5613';

// Minimal RAMS stand-in: records shaped as the API returns them, no network.
function stubRams(records) {
  return {
    async get(resource, filters) {
      const value = records[`${resource}:${filters.id ?? filters.project_id ?? 'list'}`] ?? records[resource];
      if (value === undefined) throw new Error(`unexpected RAMS read: ${resource}`);
      return typeof value === 'function' ? value(filters) : value;
    },
  };
}

function ok(data) {
  return { status: 'ok', source: { url: 'https://rams.test/api/v1', filters: {}, retrieved_at: '2026-10-08T00:00:00Z' }, data };
}

function errorRecord(code = 'upstream_error', status = 503) {
  return { status: 'error', source: { url: 'https://rams.test/api/v1', filters: {}, retrieved_at: '2026-10-08T00:00:00Z' }, error: { code, message: 'failed', http_status: status } };
}

function reply(body, status = 200) {
  return { ok: status >= 200 && status < 300, status, json: async () => body, body: { cancel: async () => {} } };
}

// Records the outbound scholarly requests and answers by source.
function stubFetch(routes) {
  const seen = [];
  const impl = async (url, init) => {
    const source = ['datacite', 'openalex', 'crossref', 'zotero'].find(name => url.href.includes(`/scholarly/${name}`));
    seen.push({ source, url: url.href, headers: init.headers });
    const route = routes[source];
    if (route === undefined) throw new Error(`unexpected scholarly request: ${url.href}`);
    return typeof route === 'function' ? route(url) : route;
  };
  return { impl, seen };
}

const bases = {
  datacite: 'http://127.0.0.1/scholarly/datacite',
  openalex: 'http://127.0.0.1/scholarly/openalex',
  crossref: 'http://127.0.0.1/scholarly/crossref',
  zotero: 'http://127.0.0.1/scholarly/zotero',
};

const project = {
  'projects:7': ok({
    id: 7,
    type: 'projects',
    title: 'California trapdoor spiders',
    reserve: { id: 27 },
    owner: { id: 1, full_name: 'Owner', orcid: `https://orcid.org/${ORCID_A}` },
    applicant: { id: 1, full_name: 'Owner', orcid: ORCID_A },
  }),
  'reserves:27': ok({ id: 27, type: 'reserves', name: 'Quail Ridge Reserve', doi: 'https://doi.org/10.21973/N30T0K' }),
  'fundings:7': ok([{ id: 13011, grant_number: 'DEB-1234567', sponsor_other: 'National Science Foundation (NSF)' }]),
  'visits:7': ok([{ id: 111699, visitors: [
    { role: 'research_assistant', user: { id: 2, full_name: 'Visitor', orcid: ORCID_B } },
    { role: 'volunteer', user: { id: 3, full_name: 'No ORCID', orcid: '' } },
  ] }]),
};


test('gathers keys from project records and merges the same DOI across sources', async () => {
  const { impl, seen } = stubFetch({
    datacite: reply({ data: [{ id: '10.21973/n30t0k', attributes: { doi: '10.21973/N30T0K', titles: [{ title: 'A dataset' }], publicationYear: 2024, types: { resourceTypeGeneral: 'Dataset' } } }] }),
    openalex: reply({ results: [{ doi: 'https://doi.org/10.21973/N30T0K', title: 'A dataset', publication_year: 2024, type: 'dataset' }] }),
    crossref: reply({ message: { items: [{ DOI: '10.21973/n30t0k', title: ['A dataset'], type: 'dataset', issued: { 'date-parts': [[2024]] } }] } }),
  });
  const search = new OutputSearch({ rams: stubRams(project), fetch: impl, bases, contactEmail: 'openaccess@ucnrs.org' });

  const result = await search.search({ project_id: 7 });

  assert.equal(result.status, 'ok');
  assert.deepEqual(result.search_keys.reserve_dois, ['10.21973/n30t0k']);
  assert.deepEqual(result.search_keys.orcids, [{ orcid: ORCID_A, role: 'owner' }, { orcid: ORCID_B, role: 'research_assistant' }]);
  assert.deepEqual(result.search_keys.award_numbers, [{ award_number: 'DEB-1234567', sponsor: 'National Science Foundation (NSF)' }]);

  const urls = seen.map(entry => entry.url);
  assert.ok(urls.some(url => url.includes('relatedIdentifiers.relatedIdentifier%3A%2210.21973%2Fn30t0k%22')));
  assert.ok(urls.some(url => url.includes(`filter=author.orcid%3A${ORCID_A}`)));
  assert.ok(urls.some(url => url.includes('grants.award_id%3ADEB-1234567')));
  assert.ok(urls.some(url => url.includes('award.number%3ADEB-1234567')));
  assert.ok(seen.every(entry => entry.headers['User-Agent'].includes('mailto:openaccess@ucnrs.org')));

  // One DOI from three sources collapses into one candidate that names all three.
  assert.equal(result.candidates.length, 1);
  assert.equal(result.coverage.candidates_before_deduplication, 3);
  assert.equal(result.coverage.candidates_after_deduplication, 1);
  assert.ok(result.sources.every(source => source.records_returned === 1));
  // The candidate keeps every query that matched it, not just the first.
  assert.deepEqual([...new Set(result.candidates[0].observed_in.map(entry => entry.source))].sort(), ['crossref', 'datacite', 'openalex']);
  assert.ok(result.candidates[0].observed_in.some(entry => entry.match.includes('relatedIdentifiers')));
  assert.ok(result.candidates[0].observed_in.some(entry => entry.match.includes('award_id')));
  assert.equal(result.candidates[0].url, 'https://doi.org/10.21973/n30t0k');
  assert.equal(result.candidates[0].relation, 'unconfirmed');
  assert.equal(result.coverage.linkage_confirmation, 'not_performed');
  assert.equal(result.coverage.external_output_search, 'performed');
});

test('uses a reserve ROR as an exact affiliation key in every scholarly source', async () => {
  const { impl, seen } = stubFetch({
    datacite: reply({ data: [] }),
    openalex: reply({ results: [] }),
    crossref: reply({ message: { items: [] } }),
  });
  const search = new OutputSearch({
    rams: stubRams({
      'reserves:27': ok({ id: 27, type: 'reserves', name: 'Gump South Pacific Research Station', doi: 'https://ror.org/04SK0ET52' }),
    }),
    fetch: impl,
    bases,
  });

  const result = await search.search({ reserve_id: 27 });

  assert.equal(result.status, 'ok');
  assert.deepEqual(result.search_keys.reserve_dois, []);
  assert.deepEqual(result.search_keys.rors, [{ ror: 'https://ror.org/04sk0et52', source: 'reserve_doi_field' }]);
  assert.equal(result.search_keys.queried.rors, 1);
  assert.equal(seen.length, 3);
  const queries = Object.fromEntries(seen.map(entry => [entry.source, new URL(entry.url).searchParams]));
  assert.equal(queries.datacite.get('affiliation-id'), 'https://ror.org/04sk0et52');
  assert.equal(queries.datacite.get('affiliation'), 'true');
  assert.equal(queries.openalex.get('filter'), 'institutions.ror:https://ror.org/04sk0et52');
  assert.equal(queries.crossref.get('filter'), 'ror-id:https://ror.org/04sk0et52');
});

test('orders candidates by year and reports an empty source separately from a failed one', async () => {
  const { impl } = stubFetch({
    datacite: reply({ data: [] }),
    openalex: reply({ results: [
      { doi: 'https://doi.org/10.1000/old', title: 'Older', publication_year: 2019, type: 'article' },
      { doi: 'https://doi.org/10.1000/new', title: 'Newer', publication_year: 2025, type: 'article' },
    ] }),
    crossref: reply({ error: 'unavailable' }, 503),
  });
  const search = new OutputSearch({ rams: stubRams(project), fetch: impl, bases });

  const result = await search.search({ project_id: 7 });

  assert.equal(result.status, 'partial');
  assert.deepEqual(result.coverage.sources_failed, ['crossref']);
  assert.deepEqual(result.sources.find(entry => entry.source === 'datacite'), {
    source: 'datacite', status: 'ok', queries_attempted: 2, records_returned: 0, source_url: null,
  });
  assert.equal(result.sources.find(entry => entry.source === 'crossref').error.http_status, 503);
  assert.deepEqual(result.candidates.map(candidate => candidate.title), ['Newer', 'Older']);
  assert.ok(result.evidence_limits.some(limit => limit.includes('crossref')));
});

test('reports missing identifiers instead of querying, and never as an absence of outputs', async () => {
  const { impl, seen } = stubFetch({});
  const search = new OutputSearch({
    rams: stubRams({
      'projects:8': ok({ id: 8, type: 'projects', reserve: null, owner: { id: 1, full_name: 'Nobody', orcid: '' }, applicant: null }),
      'fundings:8': ok([]),
      'visits:8': ok([]),
    }),
    fetch: impl,
    bases,
  });

  const result = await search.search({ project_id: 8 });

  assert.equal(result.status, 'no_identifiers');
  assert.deepEqual(result.candidates, []);
  assert.equal(seen.length, 0);
  assert.equal(result.coverage.external_output_search, 'not_performed');
  assert.ok(result.evidence_limits.some(limit => limit.includes('not evidence that no outputs exist')));
});

test('a failed key read leaves the search partial rather than silently narrower', async () => {
  const { impl, seen } = stubFetch({
    datacite: reply({ data: [] }),
    openalex: reply({ results: [] }),
    crossref: reply({ message: { items: [] } }),
  });
  const search = new OutputSearch({
    rams: stubRams({ ...project, 'fundings:7': errorRecord() }),
    fetch: impl,
    bases,
  });

  const result = await search.search({ project_id: 7 });

  assert.equal(result.status, 'partial');
  assert.deepEqual(result.coverage.ram_reads_failed, ['fundings:error']);
  assert.deepEqual(result.search_keys.award_numbers, []);
  // Award-number queries are dropped, but the ORCID and reserve DOI keys still run.
  assert.equal(seen.filter(entry => entry.url.includes('award')).length, 0);
  assert.equal(seen.filter(entry => entry.source === 'openalex').length, 2);
  assert.ok(result.evidence_limits.some(limit => limit.includes('fundings read')));
});

test('an inaccessible reserve is returned as an error, not as empty output', async () => {
  const { impl, seen } = stubFetch({});
  const search = new OutputSearch({ rams: stubRams({ 'reserves:404': errorRecord('not_found_or_inaccessible', 404) }), fetch: impl, bases });

  const result = await search.search({ reserve_id: 404 });

  assert.equal(result.status, 'error');
  assert.equal(result.error.code, 'not_found_or_inaccessible');
  assert.equal(seen.length, 0);
});

test('caps identifier queries and reports the truncation', async () => {
  const visitors = Array.from({ length: 7 }, (_, index) => ({
    role: 'volunteer',
    user: { id: index + 10, full_name: `Visitor ${index}`, orcid: `0000-0001-1111-11${index}0` },
  }));
  const { impl, seen } = stubFetch({
    datacite: reply({ data: [] }),
    openalex: reply({ results: [] }),
    crossref: reply({ message: { items: [] } }),
  });
  const search = new OutputSearch({
    rams: stubRams({
      'projects:9': ok({ id: 9, type: 'projects', reserve: null, owner: { id: 1, full_name: 'Owner', orcid: ORCID_A }, applicant: null }),
      'fundings:9': ok([]),
      'visits:9': ok([{ id: 1, visitors }]),
    }),
    fetch: impl,
    bases,
  });

  const result = await search.search({ project_id: 9, max_orcids: 2 });

  assert.equal(result.search_keys.orcids.length, 8);
  assert.equal(result.search_keys.queried.orcids, 2);
  assert.equal(result.search_keys.truncated.orcids, true);
  assert.equal(seen.filter(entry => entry.source === 'openalex').length, 2);
  assert.equal(seen.filter(entry => entry.source === 'crossref').length, 2);
});

test('a Zotero group without a configured key is skipped, not empty', async () => {
  const { impl, seen } = stubFetch({
    datacite: reply({ data: [] }),
    openalex: reply({ results: [] }),
    crossref: reply({ message: { items: [] } }),
    zotero: reply([{ key: 'ABC', data: { DOI: '10.1000/zot', title: 'Zotero item', date: '2021-05-01', itemType: 'journalArticle' } }]),
  });
  const withoutKey = new OutputSearch({ rams: stubRams(project), fetch: impl, bases });
  const skipped = await withoutKey.search({ project_id: 7, zotero_group_id: '323596' });

  const skippedSource = skipped.sources.find(entry => entry.source === 'zotero');
  assert.equal(skippedSource.status, 'skipped');
  assert.match(skippedSource.reason, /ZOTERO_API_KEY/);
  assert.equal(seen.filter(entry => entry.source === 'zotero').length, 0);
  assert.equal(skipped.status, 'ok');

  const withKey = new OutputSearch({ rams: stubRams(project), fetch: impl, bases, zoteroApiKey: 'zot-key' });
  const read = await withKey.search({ project_id: 7, zotero_group_id: '323596' });

  assert.equal(read.sources.find(entry => entry.source === 'zotero').status, 'ok');
  const zoteroCall = seen.find(entry => entry.source === 'zotero');
  assert.equal(zoteroCall.url, 'http://127.0.0.1/scholarly/zotero/groups/323596/items/top?limit=25');
  assert.equal(zoteroCall.headers['Zotero-API-Key'], 'zot-key');
  assert.deepEqual(read.candidates.map(candidate => candidate.doi), ['10.1000/zot']);
});

test('rejects a search with no key and a base URL that could leak the Zotero key', () => {
  const search = new OutputSearch({ rams: stubRams({}), fetch: stubFetch({}).impl, bases });
  assert.throws(() => new OutputSearch({ rams: stubRams({}), bases: { zotero: 'http://api.zotero.org' } }), /HTTPS/);
  assert.throws(() => new OutputSearch({ rams: stubRams({}), bases: { zenodo: 'https://zenodo.org' } }), /Unknown scholarly source/);
  assert.throws(() => new OutputSearch({ rams: stubRams({}), bases: { datacite: 'https://user:pass@api.datacite.org' } }), /HTTPS/);
  return search.search({}).then(result => {
    assert.equal(result.status, 'error');
    assert.equal(result.error.code, 'bad_request');
  });
});
