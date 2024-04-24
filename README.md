# Operations Platform Site Server

## Simple self-hosted git-powered web app automation.

[![License](https://img.shields.io/badge/license-MIT-408677.svg)](LICENSE)

<!--
There are two choices for LICENSE badges:

1. License using shields.io (above): Can contain any text you want, and has no prerequisites, but must be manually updated if you change the license.
2. License using poser.pugx.org (below): shows the license that Packagist.org read from your composer.json file. Must register with Packagist to use Poser.

[![License](https://poser.pugx.org/operations-platform/site-server)](https://github.com/operations-platform/site-server//main/LICENSE)
-->

This code sets up a server for launching and testing websites using GitOps tools like GitHub Actions and hosting tools like DDEV.

The goal is to quickly launch running environments on any server for automated and manual testing, integrated directly with GitOps APIs.

It uses GitHub Actions and Workflows with self-hosted runners, providing persistent, accessible environments and logs, fully integrated with GitHub Deployments & Checks APIs for optimal developer experience.

### What this does

This Ansible playbook prepares a bare linux server for running websites:

1. Creates users for administrators and grants SSH access using GitHub user SSH keys.
2. Installs Docker, Composer, & DDEV.
3. Creates a `platform` user for storing site code and running tasks.
4. Installs GitHub Self-hosted Runner as a service, running as `platform` user.
5. Listens for new jobs remotely. No need to grant GitHub access to post webhooks.
6. Runs the GitHub Actions as defined in the project's `.github/workflows` config.

Then, the project's codebase takes over using GitHub Actions config.

### GitHub Actions

With a self-hosted runner, all activity on the servers is run with GitHub's Actions system.

Through the GitHub interface you can track every deployment, test run, and cron job for pull request and live environments.

#### Deployment Logic

For now, all deployment logic is stored in the GitHub workflow config:

- Where to clone code.
- Command to launch sites.
- Command to run updates.
- Command to sync data.

See examples folder for working config.

With the right GitHub Actions config, the server will:

1. Clone code to `/var/platform/example.com/pr#`.
2. Write special DDEV config to set unique URLs for each DDEV site.
3. Launch the site. (`ddev start`)
4. If a test site, sync data and run tests.

For now, you must copy these templates into your workflows. As the project progresses, we will release shared tooling.

## Documentation

This is a very young project still in the proof of concept phase. More information will be added when possible.

### Architecture

1. **Operations Platform** (This repository)
    - An Ansible Collection. Set of roles and configuration for bootstrapping a server to run sites.
    - Installed to `/usr/share/operations`.
    - Ansible Playbook:
      - `geerlingguy.security`
      - `geerlingguy.github-users`
      - `geerlingguy.composer`
      - `geerlingguy.docker`
    - Installs system users, Docker, Composer, GitHub Runner, & DDEV. (More engines TBD)
    - @TODO: Self-updating: Control User GitHub runner updates this repo and kicks off playbook when new commits are pushed for changing server config.
    - **Users:**
      - Special users are created to manage the server.
      - Control user (`control`) is for server updates. It has `sudo NOPASSWD` permissions to allow self-configuration. If using multiple servers, this user will have SSH access to those servers in order to configure them remotely.
      - Platform user (`platform`) is used for all app code. All apps are cloned into the home directory, `/var/platform`. The `platform` user has SSH access to clone repositories and access remote servers. The `platform` user runs the commands needed to launch sites, such as `ddev`.
      - System Administrators can be set by adding their GitHub username to the ansible variable `operations_admin_users`. Each user will be granted server access via the SSH keys uploaded to GitHub.com, and `sudo NOPASSWD` permissions to allow manual maintenance of the server.
    - **Service Engines**
      - Operations platform relies on other tools for launching sites.
      - "Service Engines" will make it simple to plug in any desired tooling to start, stop, destroy, and restore/sync sites by simply wrapping the tool's commands.
      - DDEV is used as the first service engine as a proof of concept.
      - More will be added whenever time allows.

2. **Git Runners**
    - This role installs and configures private Git Runners.
    - All needed operations are run through the Git host's "Workflows" or "Pipelines" system, including deployments, cron jobs, backups, etc.
    - Runners listen for events like git pushes or issue creation and then take the actions defined by the git-ops configuration files, without webhooks. This allows privately hosted servers to run sites without forcing users to grant access to the internet.
    - All tasks are logged in the web interfaces of the git hosts. No other task runner (such as jenkins) is needed.
    - Runner Documentation
        - [GitHub](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-github-hosted-runners)
        - [BitBucket](https://support.atlassian.com/bitbucket-cloud/docs/runners/) @TODO
        - [GitLab](https://docs.gitlab.com/runner/) @TODO
3. **Git Runner config**
    - Each project must contain workflow/pipeline configuration files specifically for that git host that works with the private runners.
    - Example config files are located in the (Templates)[./templates] folder (Coming soon).


### Links

- [GitHub issue templates](https://github.com/operations-platform/site-server/issues/templates/edit)
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

0. Install Ansible & git.

1. Clone.

        git clone git@github.com:operations-platform/site-server.git /usr/share/operations

2. Get a GitHub API token.

    - Go to https://github.com/settings/personal-access-tokens/new
    - Ensure `administrator:write` permission is set.
    - Ensure the repository you want to deploy is added.

3. Configure.

    Copy ansible inventory files in `./ansible` to `/etc/ansible`, then update the values.

        cd /usr/share/operations

        # Copy default ansible files.
        cp -rf ansible/* /etc/ansible

        # Set your hostname to in /etc/ansible/hosts and set variables in host_vars.
        cd /etc/ansible
        sed 's/localhost/$SERVER_HOSTNAME/g' hosts.example > hosts
        cp host_vars/host.example.yml host_vars/$SERVER_HOSTNAME.yml

    Edit `host_vars/{$SERVER_HOSTNAME}.yml` to match your github repo's information. Insert the API key there.

4. Install.

        ansible-playbook /usr/share/operations/playbook.yml

## Built With

List significant dependencies that developers of this project will interact with.

* [Composer](https://getcomposer.org/) - Dependency Management
* [Robo](https://robo.li/) - PHP Task Runner
* [Symfony](https://symfony.com/) - PHP Framework
* [Ansible](https://ansible.com) - System Configuration Platform

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/operations-platform/site-server/releases) page.

## Authors

* **Jon Pugh** - created project from template.

See also the list of [contributors](https://github.com/operations-platform/site-server/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* @g1a for all that you do.
* aegir, lando, docksal, ddev, etc
