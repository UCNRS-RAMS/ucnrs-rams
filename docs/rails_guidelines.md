## Models and domain objects

- Prefer domain objects named after concepts, with meaningful methods such as
  `submit` or `complete`, over generic `*Service`, `*Manager`, or `*Handler`
  abstractions. Keep persistence and domain invariants in models; use the
  existing forms, queries, and presenters for their respective responsibilities.
- Extract cohesive objects when a model grows; prefer composition to sprawling
  concerns. Use `ActiveModel::Model` when a PORO needs validation or form integration.
- Reserve callbacks for record integrity, such as normalization and defaults.
  Make email delivery and external-system side effects explicit in the workflow.
- Existing services can be maintained without an unrelated architectural migration.

## Controllers and views

- Controllers coordinate HTTP, authorization, domain calls, and responses.
  Move calculations and multi-record workflows into appropriate domain objects.
- Prefer RESTful resources when adding routes.
- Return `status: :unprocessable_entity` when rendering failed Turbo forms.
- Keep queries and business calculations out of views. Use `app/presenters/`
  for presentation logic, helpers for simple formatting, and partials with
  explicit locals for repeated markup.

## Testing

- For behavior changes, prefer a failing example first, then implementation
  and refactoring. Test observable outcomes and meaningful failure cases,
  rather than private methods or a quota of tests per method.
- Prefer model/PORO specs for domain behavior, request specs for HTTP and
  authorization, and system specs for browser interactions.
- Keep example-specific setup visible in the example. Existing RSpec `let`
  and `before` conventions may be retained; avoid unrelated fixture rewrites.
- Factories live in `spec/factories/`. Prefer `build` or `build_stubbed` when
  persistence is unnecessary; keep defaults minimal.
- Stub external HTTP at the integration boundary. Do not assume WebMock is
  installed or that the test suite automatically blocks network access.

## Database changes

- Generate migrations with `bin/rails generate migration`; follow the existing
  MySQL schema and key conventions.
- Use database constraints and defaults to enforce invariants where appropriate.
- Use transactions for changes that must succeed together, with bang writes
  or explicit failure handling so partial work cannot commit silently.
- Keep reusable simple filters in scopes and complex searches in query objects.
  Paginate growing collections and check for N+1 queries, including counts in loops.

## Authorization and external input

- Preserve RAMS's role, reserve-management, and project-membership checks.
  Authentication alone does not authorize access to a reserve or project;
  verify access on reads and writes and cover denied access in specs.
- Use strong parameters and parameterized SQL. Explicitly select attributes
  exposed by JSON endpoints.
- Keep CSRF protection on browser endpoints, escape user-supplied HTML,
  validate redirect destinations, and filter secrets from logs.
- Pass external input to subprocesses as separate arguments rather than
  interpolating it into shell commands.

## Comments

Prefer clear names, focused methods, and behavior specs to comments narrating
the code. Add comments when they preserve a non-obvious reason, constraint,
or algorithm explanation that the code cannot convey clearly.
