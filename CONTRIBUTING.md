# Contributing Guidelines

Thank you for your interest in contributing to the Researve Applications Management Systems (RAMS)! 🎉  
Please take a few minutes to review this guide before submitting your contribution.

## Project Model

RAMS is maintained under a transparent, internally managed governance model:

* The codebase is publicly accessible and openly licensed
* Development happens in the open (issues, pull requests, roadmaps)
* The roadmap and core architecture are managed by the project maintainers
* Contributions are reviewed for alignment with project goals and standards

This approach enables transparency and reuse while ensuring RAMS remains stable and aligned with its operational mission.

---

## How to Report Issues
- Use our [Feedback Form]()https://ramshelp.ucnature.org/add-your-feedback/ for bugs and feature requests.
- Include as much detail as possible.

## Code of Conduct
Please review and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License
By contributing, you agree that your contributions are licensed under the [MIT License](https://github.com/UCNRS/ucnrs-rams/blob/main/LICENSE).

## Releases

* Releases are managed by the development team including tagged versions and release notes
* UC Nature validates operational readiness

## Security

If you discover a security vulnerability, please **do not open a public issue**.
Instead, report it via our [Feedback form](https://ramshelp.ucnature.org/add-your-feedback/)

## Acknowledgement

RAMS is developed to support real-world research operations while advancing open,reusable infrastructure.

We value contributions that:

* improve clarity and usability
* strengthen reliability
* align with the project’s mission

Transparency is central to this project — thank you for helping improve it.

---

## 🧭 How to Contribute

RAMS uses a **pull request (PR)-based workflow**.

### 1. Start with an Issue

* Check existing issues or create a new one
* Clearly describe the problem or proposed change
* Align with maintainers before beginning work

### 2. Fork the Repository
Start by forking this repository to your own GitHub account:

```bash
git clone https://github.com/UCNRS-RAMS/ucnrs-rams.git
cd ucnrs-rams
```

### 3. Create a Branch
Create a new branch for your feature or bug fix.
```bash
git checkout -b feature/your-feature-name
```

Please use the following naming convention:
- `feature/your-feature-name` for new features
- `bug/your-bug-description` for bug fixes
- `docs/your-documentation-update` for documentation changes (e.g. README, comments)
- `chore/your-chore-description` for maintenance tasks (e.g. updating dependencies)

### 4. Make Your Changes
Make your changes in your local repository. Please ensure that your code adheres to the project's coding standards and conventions.

For information on how to set up your development environment, please refer to the [README.md](README.md).

### 5. Test Your Changes

### 6. Commit Your Changes
Commit your changes with a clear and concise commit message with what you've done.
```bash
git add .
git commit -m "Add your commit message here"
```

Note that we have a `CircleCI` precommit hook that will run linting and tests before allowing a commit. Please ensure that your code passes these checks.
If you are in the process of making changes and want to commit changes before you have completely finished, you can run the commit with `-n` to skip these precommit checks.

### 7. Make sure your branch is up to date
Before pushing your changes, make sure your branch is up to date with the main branch. From your branch run:
```bash
git pull origin main
```

### 8. Push Your Changes
Push your changes to your forked repository:
```bash
git push origin feature/your-feature-name
```

### 9. Create a Pull Request
Go to the original repository and create a pull request from your forked repository. Follow the template provided and include as much detail as possible including instructions for how to test the change if applicable.
Be sure to reference the issue number if your pull request addresses a specific issue.

### Pull Request Review Process

All changes to the codebase must be submitted through a pull request (PR). 

#### Review Requirements

* Each pull request must be reviewed and approved by at least one other contributor before it can be merged.
* Reviewers should verify:

  * Code quality and readability
  * Alignment with existing architecture and patterns
  * Adequate test coverage or validation steps
  * That any related documentation is updated as needed

#### Status Checks

* All automated checks (e.g., CI tests, linting) must pass before a pull request can be merged.
* Pull requests that fail checks should not be merged until issues are resolved.

#### Testing & Validation

* PRs should include clear instructions for testing, where applicable.
* Contributors are encouraged to validate changes in a local or staging environment prior to requesting review.

#### Timeliness & Collaboration

* Reviewers should aim to provide feedback within a reasonable timeframe (1-2 business days).
* If feedback is not received after a reasonable period, contributors may follow up or proceed with additional reviewers as needed.

#### Merging

* Once approval has been obtained and all checks have passed, the pull request may be merged.
* The person merging the PR is responsible for ensuring that all requirements have been met.

This process is intended to ensure code quality, maintain system stability, and support effective collaboration across teams.

### 10. Address Feedback
We may request changes or provide feedback on your pull request. Please address any feedback promptly to help us review and merge your changes.

We are a small team and may not be able to respond immediately, but we will do our best to review your contribution as soon as possible.

### 10. Celebrate!
Once your pull request is merged, celebrate your contribution to the project! 🎉
