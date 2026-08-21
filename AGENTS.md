# AGENTS.md

This repository is a Rails application with a conventional Rails/domain structure, plus a small Stimulus/TypeScript frontend compiled via `shakapacker` and webpack. Use the existing project structure as the main guide when making changes.

## Project overview

- Ruby app with MySQL-backed data model and Rails conventions
- Node/Yarn toolchain for frontend assets (`package.json`, `app/javascript`, `config/shakapacker.yml`)
- App code lives under `app/`, with Rails config under `config/`, tests under `spec/`, and support scripts under `scripts/`
- `README.md` is the main setup and tooling reference; this file is meant to explain the code patterns used in the app itself

## Repository structure

- `app/models/`: domain models and most business rules. This is where persistence and validation logic normally live.
- `app/forms/`: form objects for multi-model, multi-step, or UI-specific flows; they validate underlying models and aggregate errors.
- `app/controllers/`: request entry points. Prefer thin controllers that coordinate work and delegate to models/forms/services.
- `app/validators/`: custom ActiveModel validators used when the validation logic is reusable or cross-field.
- `app/services/`: application services for more complex orchestration or outside-the-model logic.
- `app/queries/`: query objects or scopes for complex SQL/read logic.
- `app/presenters/`: view-oriented logic assembled for rendering.
- `app/helpers/`: helper methods for view logic or small shared UI conveniences.
- `app/views/`: view layer organized by feature (`projects`, `users`, `visits`, `shared`, etc.), not by generic “components” folders.
- `app/javascript/controllers/`: Stimulus controllers for UI interactions. Files follow the Rails naming pattern: `thing_controller.ts`.
- `config/locales/`: Rails i18n strings and validation messages.
- `spec/`: RSpec tests; some JS specs live under `app/javascript/__tests__` and are run by Jest.

## Coding conventions observed in the codebase

### 1) Keep validation close to the model

This codebase strongly favors validation on the model or form object that owns the data, not in the controller layer.

Examples:
- `app/models/user.rb` contains `validates :first_name, presence: true`, custom validators, and `with_options` blocks for conditional required fields.
- `app/models/project.rb` keeps project-type-specific validation rules on the model itself using `with_options(if: ...)`.
- `app/forms/user_form.rb` validates the underlying `User` and associated `ProjectTeamMembership` objects, then merges errors back into the form.

Practical rule:
- If the rule is about the state or integrity of the domain object, put it in the model.
- If the rule is part of a form workflow that spans multiple records, use a form object and validate the underlying models there.
- Controllers should usually not own the business validation logic.

### 2) Prefer custom validators for reusable cross-field rules

The project contains reusable validators under `app/validators/` for cases where validation is more complex than a simple `presence`/`format` check.

Examples:
- `app/validators/must_be_after_validator.rb`
- `app/validators/must_select_at_least_one_validator.rb`

This is the pattern to follow when a validation depends on another attribute, is reused across multiple models/forms, or needs clearer semantics than ad-hoc `if:` checks.

### 3) Forms are the place for workflow-level validation

The app uses form objects for complex or multi-step domain flows. They are not just DTOs; they actively validate their participants and expose aggregated errors.

`app/forms/user_form.rb` is a good model of the style:
- it includes `ActiveModel::Model`
- validates its own form fields
- calls `user.validate` and `project_team_membership.validate`
- merges errors back onto the form object
- keeps save logic in the form rather than scattering it across the controller

Use this pattern when a request spans more than one model or when the UI needs to present a single validation surface.

### 4) Keep controllers thin and action-oriented

Controller files should mostly coordinate requests: load the relevant record(s), call a form/service/model method, and respond. They are not the normal home for domain rules.

When in doubt, prefer:
- model validation for domain invariants
- form validation for workflow invariants
- service objects for orchestration or side-effects
- controller for request/response flow only

### 5) Feature folders are organized by domain, not by technical type

The app organizes views and related logic by feature area:
- `projects/`
- `users/`
- `visits/`
- `reserves/`
- `manager/`
- `shared/`

This suggests the preferred pattern is “feature-centric” code organization, with shared pieces kept in `shared/` only when they are genuinely reusable across features.

### 6) JS uses Stimulus, not a framework-heavy client app

`app/javascript/controllers/` contains controller files like:
- `dropdown_controller.ts`
- `toggle_controller.ts`
- `modal_controller.ts`
- `summary_box_controller.ts`

This repo is not structured as a React/Vue single-page app. It uses Stimulus to add behavior to existing Rails-rendered HTML, and the app still relies heavily on server-rendered views.

### 7) Localization is intentionally close to the rendering context

This repo uses Rails locale files under `config/locales/`, and the project often localizes text where the view or model is rendered. The current codebase does not appear to favor a single shared UI-string utility that is reused across the whole app.

A practical convention in this repo is:
- keep copy close to the feature or template that renders it
- avoid building a highly reused cross-UI translation object just to centralize a string that is already local to a screen or part of the flow
- if the same string appears in multiple places, it is accepted to repeat it in those separate contexts rather than promoting one shared instance across the interface

This is a style preference consistent with the codebase’s feature-oriented structure: localized text stays near the relevant screen or model context rather than abstracted into a wide shared UI translation layer.

### 8) Use presenters for view preparation and display logic

The codebase makes extensive use of presenter objects (`app/presenters/`) to keep controllers thin and views free of complex conditionals or query logic.

A practical convention in this repo is:
- Controllers instantiate presenters and pass explicit parameters (e.g. `current_user`, pagination, filters).
- Presenters encapsulate scoping, pagination, data formatting, and UI state (e.g. selected options, date formatting).
- Views render data exposed directly by the presenter rather than performing complex queries or multi-step logic.

### 9) Prioritize clarity and explicit domain structure over implicit magic

While the codebase follows standard Rails idioms, it favors explicit, readable domain objects (Forms, Presenters, Services) over dense one-liners, obscure metaprogramming, or overly implicit "magic".

Practical rules:
- Prefer explicit method arguments, clear method names, and readable POROs/classes over clever shorthand or hidden side effects.
- Avoid compressing multi-step logic into terse, hard-to-read one-liners when a structured class, presenter, or helper makes intent obvious.
- Code should be straightforward to trace from controller -> form/presenter/service -> model.

## Naming and file layout patterns

- Ruby class files use snake_case names matching the class (`user_form.rb` -> `UserForm`)
- Stimulus controllers use `*_controller.ts` naming
- Feature folders mirror the domain area rather than generic library sections
- Validation and business logic usually live close to the model or form that owns the data

## When making changes

Follow the project’s existing patterns:
1. Start by identifying the owning domain object (model/form/service/presenter).
2. Put validation as close as possible to that object.
3. Keep request controllers thin and delegate view preparation to presenters.
4. Preserve feature-based organization in `app/views` and `app/controllers`.
5. Prefer local, context-aware strings over creating a cross-UI shared translation abstraction.
6. Favor clear, readable code and explicit domain boundaries over obscure magic or dense shorthand.
7. Match the surrounding style rather than introducing a new architectural pattern just for one change.

## Good references in this repo

- `app/models/user.rb` for domain validation patterns
- `app/models/project.rb` for conditional validation with `with_options`
- `app/forms/user_form.rb` for aggregated validation across multiple models
- `app/presenters/projects_index_presenter.rb` for presenter data encapsulation and scoping
- `app/validators/must_be_after_validator.rb` for custom reusable validation logic
- `app/javascript/controllers/` for the front-end Stimulus structure
- `config/locales/en.yml` for validation messages and translation keys
