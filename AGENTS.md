# UCNRS RAMS development guide

## Project and tooling

This is a Rails 8.1 application backed by MySQL, with server-rendered views enhanced by Stimulus controllers. Shakapacker/webpack compiles JavaScript, and Sass builds CSS.

- Ruby: `4.0.6` (`.ruby-version`, `Gemfile`, and CI)
- Node: `24.x`; package manager: Yarn `1.22.22`
- Ruby tests: RSpec; browser/system tests: Capybara with Selenium
- JavaScript tests: Jest with jsdom
- Ruby linting: RuboCop, configured in `.rubocop.yml`

`README.md` is the source for setup and local/Docker commands. The default Rake task (`bundle exec rake`) runs both RSpec and Jest.

## Application structure

- `app/models/`: Active Record persistence, associations, scopes, and domain validations.
- `app/forms/`: ActiveModel form objects for multi-record or workflow-specific persistence and validation.
- `app/controllers/`: request coordination, authorization, presenter/form construction, and responses.
- `app/presenters/`: data shaping, display state, and view-specific query composition.
- `app/services/`: orchestration or external API integration that does not belong to a model.
- `app/queries/`: dedicated query objects for reusable, non-view-specific read logic.
- `app/validators/`: reusable ActiveModel cross-field validators.
- `app/helpers/`: small view helpers. Do not add new domain rules or complex query logic here.
- `app/views/`: server-rendered templates organized by domain feature.
- `app/javascript/controllers/`: Stimulus controllers named `*_controller.ts`.
- `config/locales/`: I18n translations, including validation messages.
- `spec/`: RSpec tests organized to mirror the application layer; `spec/support/` contains shared flows, matchers, and test helpers.
- `app/javascript/__tests__/`: Jest specs for Stimulus controllers and frontend behavior.

## Application conventions

### Put rules in the owning layer

- Keep persistence constraints, associations, scopes, and domain invariants on the model.
- Use a custom validator when a cross-field rule is reusable or needs a meaningful name (for example, `MustBeAfterValidator`).
- Use a form object when a UI workflow spans models or needs one aggregated error surface. Forms own the workflow's validation and save behavior.
- Keep controllers action-oriented: load/authorize records, instantiate a form or presenter, then render or redirect. Do not place domain validation or multi-step persistence there.
- Use services for side effects and external integrations; do not create one merely to wrap simple model or form logic.

### Use presenters for rendering concerns

Presenters are the established boundary between controllers and views. Controllers pass explicit dependencies such as the current user, filters, and pagination; presenters expose display-ready values, UI state, and view-specific scopes. Keep complex conditionals, formatting, and view-oriented query composition out of templates.

### Favor clear, conventional code

Use Rails conventions where they communicate intent, but prioritize names, explicit inputs, and code that can be traced from controller to form/presenter/service to model. Do not compress multi-step behavior into clever one-liners, hidden callbacks, or metaprogramming solely to reduce line count. Match nearby code before introducing a new abstraction.

### Localization

Use Rails I18n for user-facing copy and validation messages. Add translations in `config/locales/` at the narrowest appropriate model/attribute or feature key; do not embed new user-facing strings in Ruby code. The test environment raises on missing translations, so cover new localized behavior with a focused spec when applicable.

## Testing

Add or update focused tests for every behavior change. Place a spec next to the corresponding layer and follow the existing example's setup rather than introducing a new test style.

| Change | Preferred coverage | Established pattern |
| --- | --- | --- |
| Model associations, validations, scopes, callbacks | `spec/models/` | Shoulda matchers for simple associations/validations; explicit examples for conditional behavior and error messages |
| Form validation or save workflows | `spec/forms/` | Build realistic params, assert persistence and mapped errors |
| Presenter display state or scopes | `spec/presenters/` | Create only the records needed and assert the public presenter method |
| Query object, validator, helper, service, or uploader | matching `spec/` directory | Test public behavior with real records or verified doubles as appropriate |
| Controller authorization, redirects, responses, or side effects | `spec/requests/` | Sign in with Devise helpers, exercise the request, and assert status/redirect, response DOM, database changes, and enqueued mail |
| Server-rendered template or partial | `spec/views/` | Assign its presenter, render the template, and query `Capybara.string(rendered)` |
| End-to-end user interaction | `spec/system/` | Use the existing page-flow objects in `spec/support/flows/`; mark JavaScript scenarios `js: true` and assert accessibility with `be_axe_clean` for changed screens |
| Stimulus controller behavior | `app/javascript/__tests__/` | Start/register the controller, render only the required DOM fixture, invoke the interaction, and clear the DOM after each example |

Use FactoryBot factories from `spec/factories/`: `build` for in-memory objects and `create` only when persistence is required. Keep examples behavior-focused, use `describe`/`context` to document conditions, and preserve RSpec's randomized test ordering. Use the shared custom matchers and flow objects when they express the assertion or interaction; add shared test support only when it is genuinely reusable.

Run the narrowest relevant command while developing:

```sh
bundle exec rspec spec/forms/project_form_spec.rb
bundle exec rspec spec/system/creating_a_project_spec.rb:43
yarn jest app/javascript/__tests__/toggle_controller_spec.ts
```

Before submitting a cross-layer change, run:

```sh
bundle exec rake
bundle exec rubocop
```

RSpec builds CSS during Rails test setup. JavaScript and system tests therefore require installed Yarn dependencies; JavaScript system specs run headless Chrome by default.

## Style and maintenance

- Match the surrounding Ruby formatting and use the configured RuboCop rules. Its style cops are intentionally limited; lint, Rails, security, and metrics cops are enabled.
- Keep SCSS declarations alphabetically sorted; run `yarn postcss:sort` after changing stylesheets.
- Preserve feature-based namespaces and directories (`projects`, `visits`, `reserves`, `manager`, and so on).
- Add migrations for schema changes and keep model validations and indexes consistent.
- Do not add dependencies, broad shared abstractions, or new framework patterns unless the feature requires them and existing project patterns do not cover the case.
- Create class methods with `self.method_name` rather than `class << self`.

## Useful references

- `app/models/project.rb`: conditional model validation and scopes
- `app/forms/project_form.rb`: form workflow and persistence
- `app/presenters/projects_index_presenter.rb`: presenter responsibilities
- `app/controllers/projects_controller.rb`: controller/form/presenter coordination
- `spec/models/project_spec.rb`: model validation tests
- `spec/requests/projects/complete_spec.rb`: request tests, mail assertions, and authorization
- `spec/system/creating_a_project_spec.rb`: system flows and accessibility checks
- `app/javascript/__tests__/toggle_controller_spec.ts`: Stimulus Jest test setup
