import { outputKeyReport } from './output_identifiers.mjs';

const OUTPUT_EVIDENCE_LIMITS = [
  'Candidates are unconfirmed identifier matches. A shared DOI, ROR ID, ORCID, or award number does not prove that an output used a reserve.',
  'ROR searches are institution-wide affiliation matches, not project- or reserve-specific evidence.',
  'Only a curator-reviewed project-output link would confirm provenance; this read-only search creates none.',
  'No candidates is not evidence that no outputs exist; it means these search keys and sources returned nothing.',
  'Search keys come from a single page of RAMS records. Truncated or failed key reads are reported in search_keys.',
];

export function noIdentifiersResult({ query, keys, usable, truncated, reads }) {
  return {
    status: 'no_identifiers',
    query: {
      project_id: query.project_id ?? null,
      reserve_id: query.reserve_id ?? null,
      zotero_group_id: query.zotero_group_id ?? null,
    },
    rams_reads: reads,
    search_keys: {
      ...outputKeyReport(keys, usable, truncated, reads),
      note: 'No usable search key was found in the RAMS records read above.',
    },
    sources: [],
    candidates: [],
    evidence_limits: [
      ...OUTPUT_EVIDENCE_LIMITS,
      'No search key was available, so no source was queried. This is not evidence that no outputs exist.',
    ],
    coverage: { external_output_search: 'not_performed', linkage_confirmation: 'not_performed' },
  };
}

export function buildOutputSearchResult({ query, keys, usable, truncated, reads, results }) {
  const sources = results.map(summarizeSource);
  const candidates = mergeCandidates(results);
  const failedSources = sources.filter(source => source.status === 'error');
  const failedReads = reads.filter(read => read.status !== 'ok');
  const partialReads = reads.filter(read => read.coverage && !read.coverage.complete);
  const incomplete = [
    ...failedSources.map(source => source.source),
    ...failedReads.map(read => `${read.resource} read`),
  ];

  return {
    status: incomplete.length ? 'partial' : 'ok',
    query: {
      project_id: query.project_id ?? null,
      reserve_id: query.reserve_id ?? null,
      ror: query.ror ?? null,
      zotero_group_id: query.zotero_group_id ?? null,
    },
    rams_reads: reads,
    search_keys: outputKeyReport(keys, usable, truncated, reads),
    sources,
    candidates,
    evidence_limits: [
      ...OUTPUT_EVIDENCE_LIMITS,
      ...(incomplete.length
        ? [`${incomplete.join(', ')} did not complete, so these results are incomplete rather than empty.`]
        : []),
      ...partialReads.map(read =>
        `Key collection from ${read.resource} covered ${read.coverage.returned} of ${read.coverage.total} records, so identifiers on the rest were not searched.`),
    ],
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

function summarizeSource(result) {
  const distinct = new Set(result.records.map(candidateKey));
  return {
    source: result.source,
    status: result.failed.length ? 'error' : result.skipped ? 'skipped' : 'ok',
    queries_attempted: result.attempted,
    records_returned: distinct.size,
    source_url: result.records[0]?.match ?? null,
    ...(result.failed.length ? {
      error: result.failed[0].error,
      error_source_url: result.failed[0].source.url,
    } : {}),
    ...(result.skipped ? { reason: result.skipped } : {}),
  };
}

function mergeCandidates(results) {
  const merged = new Map();
  for (const result of results) {
    for (const record of result.records) mergeCandidate(merged, result.source, record);
  }
  return [...merged.values()].sort((left, right) =>
    (right.year ?? 0) - (left.year ?? 0) ||
    String(left.title ?? '').localeCompare(String(right.title ?? '')) ||
    String(left.doi ?? '').localeCompare(String(right.doi ?? '')));
}

function mergeCandidate(merged, source, record) {
  const key = candidateKey(record);
  if (key === 'title:') return;

  const observation = {
    source,
    match: record.match,
    identifiers: record.doi ? { doi: record.doi } : {},
  };
  const existing = merged.get(key);
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
    return;
  }

  existing.title ??= record.title;
  existing.year ??= record.year;
  existing.type ??= record.type;
  if (!existing.observed_in.some(seen => seen.source === source && seen.match === observation.match)) {
    existing.observed_in.push(observation);
  }
}

function candidateKey(record) {
  return record.doi ?? `title:${String(record.title ?? '').trim().toLowerCase()}`;
}
