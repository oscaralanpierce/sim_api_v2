# Skyrim Inventory Management API V2 [![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

Skyrim Inventory Management V2 is a fully-featured, distributed-stack Rails/React app facilitating inventory management, procurement, and logistics for Skyrim. The backend API is found in this repo.

## Table of Contents

- [Disclaimer](#disclaimer)
- [Developer Info](#developer-info)
  - [Local Environment Setup](#local-environment-setup)
  - [Linting with Rubocop](#linting-with-rubocop)
    - [Running Rubocop Manually](#running-rubocop-manually)
  - [Workflows](#workflows)
  - [CI](#ci)
  - [Deployment](#deployment)
  - [Troubleshooting in Production](#troubleshooting-in-production)

## Disclaimer

This application is my hobby project intended for my personal use. There are no admin users to fix anything you break and the design of the application doesn't accommodate anyone's preferences or playing style but my own. _Caveat emptor._ 

## Developer Info

### Local Environment Setup

The Skyrim Inventory Management V2 API is a basic Rails API running on Rails 8 and Ruby 4. This API is simpler than the [V1 API](https://github.com/oscaralanpierce/skyrim_inventory_management) and will function as an ERP ledgering app. You will need the following free software installed to run the API server in your local environment:

- [PostgreSQL 18](https://www.postgresql.org/)
- [asdf](https://asdf-vm.com) 
- The Ruby version specified in [.tool-versions](./.tool-versions)

You can set up your dev environment by cloning the repo, `cd`ing into the directory, and running:

```
./script/setup.sh
```

This script:

- Installs dependencies (including Bundler)
- Sets up the database
- Installs the Rubocop pre-commit hook to run before each Git commit

You will also need to create a `config/master.key` file with the value of "SIM V2 RAILS_MASTER_KEY" in 1Password. If you don't have the password manager you probably aren't authorised to do this. (Use of the source code for your own project is authorised subject to the terms of the [Hippocratic License](https://firstdonoharm.dev).)

The Rails server runs on port 3000, per Rails defaults. If you are also running the [front end](https://github.com/oscaralanpierce/sim_frontend_v2), it will expect the API to be running on this port. CORS configurations for the API require the front end to run on `localhost:5173` in local environments. To run the API server, simply run:

```
bundle exec rails s
```

### Testing

The SIM V2 API is tested using [RSpec](https://github.com/rspec/rspec). Run specs on the command line using:

```bash
bundle exec rails spec
```

If you'd like to run only a specific subset of specs, using these options:

```bash
# Runs only one subdirectory of specs
bundle exec rspec spec/models

# Runs only one spec file
bundle exec rspec spec/requests/users_spec.rb

# Runs a specific spec or context on line 42 of the specified file
bundle exec rspec spec/models/user_spec.rb:42
```

### Linting with Rubocop

We use [Rubocop](https://github.com/rubocop/rubocop) for linting and style purposes. The [rubocop-rails](https://github.com/rubocop/rubocop-rails), [rubocop-rspec](https://github.com/rubocop/rubocop-rspec), and [rubodop-performance](https://github.com/rubocop/rubocop-performance) plugins are also used to add additional relevant cops. If a cop causes three or more broken builds without leading to meaningful changes, we disable the cop by removing it from the [`.rubocop.yml`](./.rubocop.yml) file. We strongly avoid `rubocop:disable` comments in the code. To enforce this preference, we decline to enable cops that might ever be overridden as a matter of developer judgment. For example, since a developer might determine that high cyclometric complexity is unavoidable for a particular method, we don't use Rubocop to enforce limits to cyclometric complexity. Instead, we rely on contributors and reviewers to be accountable for the quality of their code with regards to metrics like line length, class length, code complexity, etc.

#### Running Rubocop Manually

Rubocop runs in GitHub Actions as part of our CI workflow, and Rubocop failures can break the build. For that reason, it is recommended to run Rubocop before opening or committing to a PR. You can run Rubocop using the built-in Rails command:

```bash
bundle exec rails rubocop:auto_correct
```

Unfortunately, this runs against every file in the repo, not just changed files, and it can be time-consuming to get through them all. You can run Rubocop against specific files or the contents of specific directories like this:

```bash
bundle exec rubocop -A file1.rb file2.rb directory1 directory2
```

You can also use the Rubocop script in this repo to run against staged changes. This script is automatically run in a pre-commit hook, but has the disadvantage that autocorrected files are not automatically added to the commit, causing the commit to simply be rejected if Rubocop fails. For that reason, if you have doubts that Rubocop will pass, it's best to run the script manually against staged changes before you attempt to commit:

```bash
./script/run_rubocop.sh
```

### Workflows

We use [Trello](https://trello.com/b/Jo7Z3oUh/sim-project-board) to track work for both SIM applications. To work on an issue, first check out a branch for your dev work and do the work on that branch. The branch naming convention we use is `<issue-number>-descriptive-name`, where the issue number is the number assigned to the card by Trello. For example, a branch might be called `622-configure-dependabot`. 

When you have completed your work, push to GitHub and open a pull request. The pull request should link to the Trello card as well as providing context, a summary of changes, and an explanation for any design choices you made or anything that might not make sense to a reviewer or future developer looking at Git history. Link to the PR in the Trello card and move the card to reviewing. Once your PR has been approved and CI has passed, you are free to merge.

### CI

Rubocop and RSpec are run against the `main` branch and all pull requests against `main` using [GitHub Actions](https://github.com/features/actions). PRs may not be merged if the build is broken.

### Deployment

The SIM V2 API is deployed to [Render](https://render.com) via GitHub Actions. In case of an emergency where GitHub Actions is unavailable, we are able to deploy manually using the deploy hook configured in Render. This is stored in 1Password and, if I want you to have access to it, you will. Alternatively, you can use the "Manual Deploy" link in the Render console under the project `sim_api_v2`.

### Troubleshooting in Production

Render offers SSH access to troubleshoot production issues. More information is available in the [Render docs](https://render.com/docs/ssh).