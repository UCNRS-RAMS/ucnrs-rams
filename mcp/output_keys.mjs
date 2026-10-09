import {
  dedupeOutputKeys,
  emptyOutputKeys,
  normalizeAward,
  normalizeDoi,
  normalizeOrcid,
  normalizeRor,
} from './output_identifiers.mjs';

// Collects identifiers from the same bounded RAMS reads as
// get_project_context. Every read is reported so failure is never mistaken
// for an absent identifier.
export async function collectOutputKeys(rams, { project_id, reserve_id, per_page }) {
  const keys = emptyOutputKeys();
  const reads = [];
  let reserveId = reserve_id;

  if (project_id !== undefined) {
    const project = await rams.get('projects', { id: project_id });
    reads.push(readResult('projects', project, { id: project_id }));
    if (project.status !== 'ok') return { failure: project };

    reserveId = project.data.reserve?.id ?? reserveId;
    collectProjectPeople(keys, project.data);

    const [fundings, visits] = await Promise.all([
      rams.get('fundings', { project_id, page: 1, per_page }),
      rams.get('visits', { project_id, page: 1, per_page }),
    ]);
    reads.push(readResult('fundings', fundings, { project_id }));
    reads.push(readResult('visits', visits, { project_id }));
    collectFundings(keys, fundings);
    collectVisitors(keys, visits);
  }

  if (reserveId !== undefined) {
    const reserve = await rams.get('reserves', { id: reserveId });
    reads.push(readResult('reserves', reserve, { id: reserveId }));
    // A failed reserve is the whole answer only when it was the requested root.
    if (reserve.status !== 'ok' && project_id === undefined) return { failure: reserve };
    if (reserve.status === 'ok') collectReserveIdentifier(keys, reserve.data);
  }

  return { keys: dedupeOutputKeys(keys), reads };
}

function collectProjectPeople(keys, project) {
  for (const [role, person] of [['owner', project.owner], ['applicant', project.applicant]]) {
    const orcid = normalizeOrcid(person?.orcid);
    if (orcid) keys.orcids.push({ orcid, role });
  }
}

function collectFundings(keys, result) {
  for (const funding of result.status === 'ok' ? result.data : []) {
    const award = normalizeAward(funding.grant_number);
    if (award) keys.grants.push({ ...award, sponsor: funding.sponsor_other ?? null });
  }
}

function collectVisitors(keys, result) {
  for (const visit of result.status === 'ok' ? result.data : []) {
    for (const visitor of visit.visitors ?? []) {
      const orcid = normalizeOrcid(visitor.user?.orcid);
      if (orcid) keys.orcids.push({ orcid, role: visitor.role ?? 'visitor' });
    }
  }
}

function collectReserveIdentifier(keys, reserve) {
  // The legacy DOI field is free text and sometimes stores a ROR ID.
  const doi = normalizeDoi(reserve.doi);
  const ror = normalizeRor(reserve.doi);
  if (doi) keys.dois.push({ doi });
  if (ror) keys.rors.push({ ror, source: 'reserve_doi_field' });
}

function readResult(resource, result, identity) {
  return {
    resource,
    ...identity,
    status: result.status,
    source: result.source,
    ...(result.status === 'ok' && result.pagination ? { coverage: {
      returned: result.pagination.returned_count,
      total: result.pagination.total_count,
      complete: result.pagination.complete,
    } } : {}),
  };
}
