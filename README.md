# AshOps

Install stuff for creating an automation platform for websites using the Ash Cli and GitOps tools like GitHub Workflows and BitBucket Pipelines.

[![License](https://img.shields.io/badge/license-MIT-408677.svg)](LICENSE)

<!--
There are two choices for LICENSE badges:

1. License using shields.io (above): Can contain any text you want, and has no prerequisites, but must be manually updated if you change the license.
2. License using poser.pugx.org (below): shows the license that Packagist.org read from your composer.json file. Must register with Packagist to use Poser.

[![License](https://poser.pugx.org/jonpugh/ash-ops/license)](https://github.com/jonpugh/ash-ops//master/LICENSE)
-->

More coming soon.

## Documentation

### Architecture Plan

I am about to build this:

1. Ash Ops Repo. (This repository)
    - Installed to `/usr/share/ash`, owned by `control`.
    - Ansible Playbook.
    - Composer Dependencies like `jonpugh/ash`
    - Installs Users, PHP, Composer, Docker, GitHub Runner, and Ash Cli.
    - Can be replaced with a custom version to allow control over server config.
    - Control User GitHub runner updates this repo and kicks off playbook when new commits are pushed.
2. Task Runners
    - App repo runners run as a service under `platform` user.
    - Responsible for responding to git pushes, cloning code into environments, and starting services.
    - Runner Documentation
        - [GitHub](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-github-hosted-runners)
        - [BitBucket](https://support.atlassian.com/bitbucket-cloud/docs/runners/) @TODO
        - [GitLab](https://docs.gitlab.com/runner/) @TODO
5. Users
    - Control user (`control`) has `sudo NOPASSWD` permissions to allow automation.
    - Platform user (`platform`) has `docker` permissions only, plus SSH access to clone repositories and access remote servers.
    - Admin users will all ssh in with their own usernames, and `sudo su` to `platform` or `control` as needed.
2. Ash CLI
    - Available at `/usr/share/ash/bin/ash`
    - Runs under `platform` user.
    - Site inventory.
3. App repo.
   - Website code.
   - Runner config.
4. Service CLI
    - The thing that launches services for a site.
    - Right now, it's DDEV.
    - Runners clone the code, then run the service CLI commands as defined in runner config files.


### Links

- [GitHub issue templates](https://github.com/jonpugh/ash-ops/issues/templates/edit)
- [GitHub pull request template](/.github/pull_request_template.md)
- [Contributing guide](/CONTRIBUTING) (Decide about your code of conduct)

TBD

## Getting Started

This repo contains everything needed to set up an automated hosting platform.

### Prerequisites

1. git
2. ansible

Once the repo is cloned, ansible will set up the rest.

### Installing

1. Clone.

        git clone git@github.com:jonpugh/ash-ops.git /usr/share/ash/ops

2. Configure GitHub Runner.

    1. Go to your repo, "Settings" > "Actions" > "Runners" > "New Runner".
    2. Copy the token into the ansible variable `ash_ops_github_runner_token`.
    3. Copy the github repo URL into the ansible variable `ash_ops_github_runner_repo`.

3. Configure.

  Set ansible variables in `/etc/ansible/hosts`:

        ash_ops_users:
            -  YourGitHubUser

4. Install.

        ansible-playbook /usr/share/ash/playbook.install.yml

## Built With

List significant dependencies that developers of this project will interact with.

* [Composer](https://getcomposer.org/) - Dependency Management
* [Robo](https://robo.li/) - PHP Task Runner
* [Symfony](https://symfony.com/) - PHP Framework

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/jonpugh/ash-ops/releases) page.

## Authors

* **Jon Pugh** - created project from template.

See also the list of [contributors](https://github.com/jonpugh/ash-ops/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* @g1a for all that you do.
* aegir, lando, docksal, ddev, etc
