# FAIR Station output-linkage pilot

## Purpose

Test whether RAMS data can seed a defensible FAIR Station workflow that connects
reserve research activity to scholarly outputs. The pilot used live, read-only
RAMS API data plus public ORCID work records. It did not create any RAMS or
FAIR Station relationships.

## Cohort

The batch selected open research projects that had both:

1. an assigned reserve with a normalized, syntactically valid DOI; and
2. an owner with an ORCID.

| Measure | Count |
| --- | ---: |
| Eligible open research projects | 1,454 |
| Distinct owner ORCIDs queried | 586 |
| Public ORCID work records retrieved | 528 |
| ORCIDs without a public work record (`404`) | 58 |
| Deduplicated public work summaries | 14,619 |
| Eligible projects whose owner had a public ORCID record | 1,303 |

The public ORCID API was called no more frequently than once every 750 ms.

## Matching method

For each eligible project, the batch considered only works from the exact
owner ORCID. It retained a work as a review candidate when its publication
year was within the project interval or within five years after the project
ended, and its title shared sufficient terms with the project title, abstract,
keywords, or taxonomic keywords.

The match record carries the RAMS project ID, reserve ID and DOI, owner ORCID,
output DOI when present, output title, publication year, date relation, and
matched terms. No candidate was automatically treated as a confirmed research
output.

## Results

| Result | Count |
| --- | ---: |
| Project-output review candidates | 2,014 |
| High-priority candidates | 338 |
| Candidates whose title contains a reserve/site phrase | 12 |

High-priority means the publication falls within the RAMS project interval and
has substantial title/topic overlap, or its title contains a site phrase. It is
a triage label, not a claim of provenance.

A representative strong candidate is RAMS project `1784` at Sedgwick Reserve:

- The project concerns drought physiology of *Quercus agrifolia* and
  *Q. lobata*.
- Its owner ORCID lists DOI
  [`10.3732/ajb.0800247`](https://doi.org/10.3732/ajb.0800247), *A comparative
  study of oak (Quercus, Fagaceae) seedling physiology during summer drought
  in southern California*.
- The output falls in the project interval and agrees on the species and
  research question.

Crossref metadata confirms the title, date, and study topic, but does not name
Sedgwick Reserve or cite the reserve DOI. The relationship is therefore a
strong review candidate rather than a confirmed linkage.

## What the pilot establishes

- Owner ORCIDs are sufficient to discover real, relevant output candidates.
- Reserve DOIs provide canonical site identity and should remain on each
  candidate, even though authors rarely cite those DOIs in indexed metadata.
- ROR complements a reserve DOI: it identifies the institution or research
  facility operating a site, while the DOI identifies the site as a citable
  research resource.
- RAMS project titles, abstracts, keywords, taxonomic keywords, and dates add
  valuable disambiguation after ORCID discovers an author's work.
- A review queue is necessary. Site-name and topic matches can be false
  positives: related locations, generic geographic terms, or multiple projects
  owned by the same researcher can produce plausible but incorrect matches.

## Current limitations

- The API does not expose an explicit project-to-output relationship, output
  DOI, grant ID, or project landing-page identifier.
- The institution payload has a `ror` relationship, but none of the 4,491
  exposed institutions currently populates it. Reserve payloads have no
  distinct ROR field.
- The API cannot establish actual field activity from project approval alone.
- Abstract/full-text site evidence was not collected in the batch. ORCID work
  titles and dates are discovery evidence only.
- Reserve DOI citation searches currently have low recall because outputs do
  not consistently cite the reserve DOI.

## Recommended FAIR Station workflow

1. Store the 2,014 generated rows as read-only `candidate` relationships.
2. Review the 338 high-priority candidates first. Confirm only when a curator
   finds explicit site evidence in full text, acknowledgements, data metadata,
   a repository record, or an author assertion.
3. Preserve the matching signals, source URL, retrieval timestamp, reviewer,
   and review decision for every candidate.
4. Record accepted links as first-class project-output relationships, with the
   output DOI and a relationship type such as `asserted` or `verified`.
5. Feed curator decisions back into scoring rules and retain rejected links to
   prevent repeated false positives.

## RAMS/API improvements

1. Add a project-output relationship resource with output DOI/URL, source,
   evidence, confidence, and review status.
2. Expose a stable, resolvable project landing URL or persistent project
   identifier.
3. Normalize and validate reserve DOIs at write time. Keep DOI and ROR values
   in distinct typed fields; expose ROR for both institutions and reserves
   where the registry identifies a reserve as a research facility.
4. Correct the Gump South Pacific Research Station ROR currently stored in its
   DOI field: `https://ror.org/04sk0et52` is an active ROR `facility` record.
5. Capture ORCIDs for principal investigators and other project participants,
   not only the owner, and add project-affiliation relationships where
   appropriate.
6. Provide an incremental API change feed (`updated_since` or a cursor) so
   FAIR Station can synchronize without rescanning the full project portfolio.

## MCP follow-on (2026-10-08)

The results and limitations above describe the original production-data pilot,
not a new run. The expanded base API now exposes:

- Visits with reserve, activity windows, status, submitter, and visitor ORCIDs,
  roles, and institutions.
- Fundings with grant number, sponsor, investigator names, dates, and
  award/application status flags. Award amounts are intentionally omitted.
- Inclusive `updated_since` filters on visits and fundings. Projects still
  require rescanning; these filters do not provide deletion notifications.

These additions address parts of the original limitations, but an approved
visit is not confirmed attendance, and a funding record is not necessarily an
awarded grant. Neither establishes an output-to-reserve relationship by itself.

### Implemented access layer

The local read-only MCP in [`mcp/`](../mcp/) exposes all ten base API reads
plus `get_project_context`. The composite returns the project, its assigned
reserve, and one bounded page each of visits and fundings, with provenance,
explicit continuation calls, partial failures, and evidence limitations.
See [MCP setup and tool semantics](api.md#local-mcp-integration).

A smoke run used the actual local Rails API and development database, not
production. All eleven tools were exercised. The development dataset had
11 projects, 7 reserves, 4 institutions, 1 visit, and 1 funding record.
Three dossiers covered distinct cases:

| Local project | Visits | Fundings | Assigned reserve |
| --- | ---: | ---: | --- |
| 9 | 1 | 1 | Retrieved |
| 1 | 0 | 0 | Retrieved |
| 11 | 0 | 0 | Absent |

Project 9's visit contained two visitor ORCIDs, and its funding record had a
grant number. The run also exercised incremental funding retrieval and
unknown-record error semantics. Boundary regressions cover collection
completeness, partial failures, unsupported filters, and credential-bearing
redirect refusal.

This verifies retrieval and dossier assembly only. No new production
candidates were generated, no external output searches were run, and no
relationships were confirmed or written. Production credentials were not
configured in the implementation session.

### Next production experiment

1. Select a varied cohort from the original pilot, including projects with and
   without recorded visits, fundings, and owner ORCIDs.
2. Retrieve dossiers through the MCP, following each collection's continuation
   calls explicitly and preserving its scope, filters, and retrieval times.
3. Compare owner-only output discovery with applicant/visitor ORCID discovery.
4. Enrich candidate outputs with grant/sponsor matches and explicit site
   evidence. Preserve identity, topic, timing, funding, and site signals
   separately; missing RAMS records are not automatic rejection criteria.
5. Review a stratified sample and measure confirmed-link rate, additional
   defensible links, review time, and rejection reasons against the original
   method. These remain experiments, not capabilities of the RAMS MCP itself.
