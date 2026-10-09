import { normalizeDoi } from './output_identifiers.mjs';

export async function searchDataCite(client, keys, perSource) {
  const queries = [
    ...keys.dois.map(entry => client.request('datacite', '/dois', {
      params: { 'page[size]': perSource, query: `relatedIdentifiers.relatedIdentifier:"${entry.doi}"` },
    })),
    ...keys.grants.map(award => client.request('datacite', '/dois', {
      params: { 'page[size]': perSource, query: `fundingReferences.awardNumber:"${award.value}"` },
    })),
    ...keys.rors.map(ror => client.request('datacite', '/dois', {
      params: { 'page[size]': perSource, 'affiliation-id': ror, affiliation: true },
    })),
  ];

  return collectSource('datacite', queries, result => result.body?.data ?? [], (item, result) => {
    const attributes = item.attributes ?? {};
    return {
      doi: normalizeDoi(attributes.doi) ?? normalizeDoi(item.id),
      title: attributes.titles?.[0]?.title ?? null,
      year: attributes.publicationYear ? Number(attributes.publicationYear) : null,
      type: attributes.types?.resourceTypeGeneral?.toLowerCase() ?? null,
      match: result.source.url,
    };
  });
}

export async function searchOpenAlex(client, keys, perSource) {
  const queries = [
    ...keys.orcids.map(orcid => client.request('openalex', '/works', {
      params: { 'per-page': perSource, filter: `author.orcid:${orcid}` },
    })),
    ...keys.grants.map(award => client.request('openalex', '/works', {
      params: { 'per-page': perSource, filter: `grants.award_id:${award.value}` },
    })),
    ...keys.rors.map(ror => client.request('openalex', '/works', {
      params: { 'per-page': perSource, filter: `institutions.ror:${ror}` },
    })),
  ];

  return collectSource('openalex', queries, result => result.body?.results ?? [], (item, result) => ({
    doi: normalizeDoi(item.doi),
    title: item.title ?? item.display_name ?? null,
    year: item.publication_year ?? null,
    type: item.type ?? null,
    match: result.source.url,
  }));
}

export async function searchCrossref(client, keys, perSource) {
  const queries = [
    ...keys.orcids.map(orcid => client.request('crossref', '/works', {
      params: { rows: perSource, filter: `orcid:${orcid}` },
    })),
    ...keys.grants.map(award => client.request('crossref', '/works', {
      params: { rows: perSource, filter: `award.number:${award.value}` },
    })),
    ...keys.rors.map(ror => client.request('crossref', '/works', {
      params: { rows: perSource, filter: `ror-id:${ror}` },
    })),
  ];

  return collectSource('crossref', queries, result => result.body?.message?.items ?? [], (item, result) => ({
    doi: normalizeDoi(item.DOI),
    title: item.title?.[0] ?? null,
    year: firstYear(
      item['published-print']?.['date-parts']?.[0]?.[0],
      item['published-online']?.['date-parts']?.[0]?.[0],
      item.issued?.['date-parts']?.[0]?.[0],
    ),
    type: item.type ?? null,
    match: result.source.url,
  }));
}

export async function searchZotero(client, groupId, perSource, apiKey) {
  if (!apiKey) {
    return {
      source: 'zotero',
      attempted: 0,
      records: [],
      failed: [],
      skipped: 'ZOTERO_API_KEY is not configured for this MCP process.',
    };
  }

  const result = await client.request('zotero', `/groups/${encodeURIComponent(groupId)}/items/top`, {
    params: { limit: perSource },
    headers: { 'Zotero-API-Version': '3', 'Zotero-API-Key': apiKey },
  });
  if (result.status === 'error') {
    return { source: 'zotero', attempted: 1, records: [], failed: [result] };
  }

  const records = (Array.isArray(result.body) ? result.body : []).map(item => ({
    doi: normalizeDoi(item.data?.DOI),
    title: item.data?.title ?? null,
    year: firstYear(item.data?.date),
    type: item.data?.itemType ?? null,
    match: result.source.url,
  }));
  return { source: 'zotero', attempted: 1, records, failed: [] };
}

async function collectSource(source, queries, itemsFrom, recordFrom) {
  const results = await Promise.all(queries);
  const records = results.flatMap(result =>
    result.status === 'ok' ? itemsFrom(result).map(item => recordFrom(item, result)) : []);
  return {
    source,
    attempted: queries.length,
    records,
    failed: results.filter(result => result.status === 'error'),
  };
}

function firstYear(...values) {
  for (const value of values) {
    const match = String(value ?? '').match(/\b(1[6-9]\d{2}|20\d{2})\b/);
    if (match) return Number(match[1]);
  }
  return null;
}
