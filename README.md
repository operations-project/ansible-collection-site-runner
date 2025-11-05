# Operations Site Runner Ansible Collection

## Server config for launching site runners from your codebase.

[![License](https://img.shields.io/badge/license-MIT-408677.svg)](LICENSE)

<!--
There are two choices for LICENSE badges:

1. License using shields.io (above): Can contain any text you want, and has no prerequisites, but must be manually updated if you change the license.
2. License using poser.pugx.org (below): shows the license that Packagist.org read from your composer.json file. Must register with Packagist to use Poser.

[![License](https://poser.pugx.org/operations-project/site-runner)](https://github.com/operations-project/site-runner//main/LICENSE)
-->

## How To

0. Get a server and a domain. Name it something like `server.mydomain.com`. Add DNS records to point `server.mydomain.com` to your server IP.
1. Add the site runner roles to your repo (you can use your app codebase or create one just for server config):
    ```
    git submodule add https://github.com/operations-project/ansible-collection-site-runner.git site-runner
    ```
4. Add `ansible.cfg` to point to the roles 
    ```
    [defaults]
    roles_path = ./site-runner/roles
    ```
3. Add host inventory file such as `host_vars/server.mydomain.com.yml` to your repo for your server:
    ```yml
    # See example https://github.com/operations-project/ansible-collection-site-runner/blob/main/ansible/host_vars/host.example.yml
    operations_admin_users:
      - jonpugh
    operations_github_api_token: lookup('ansible.builtin.env', 'GITHUB_TOKEN_RUNNER_ADMIN') }}
    operations_github_runners:
      - runner_repo: jonpugh/repo
    ```
4. Set `/etc/ansible/hosts` to tell ansible what server it is.
    ```yml
    [operations_host_ddev]
    server.mydomain.com ansible_connection=local
    ```
    Servers in the `operations_host_ddev` group will get `ddev` and GitHub runners installed.

    See [host_vars/example.serverfqdn.com.yml](https://github.com/operations-project/ansible-collection-site-runner/blob/main/ansible/host_vars/host.example.yml)

5. Bootstrap the server.

   The site runner roles sets up a `control` user that is allowed to configure the server.

   Once the `control` user is setup and the "control" github runner is up, the server will configure itself when changes to your inventory are pushed to the git repo.

   Therefore, the first `ansible-playbook` run must happen manually or from an external server.

   To bootstrap the server, as the initial system user (For example, `ubuntu`):
   ```
   # Install ansible: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
   # Or see geerlingguy's ansible containers for examples: [https://github.com/geerlingguy?tab=repositories&q=docker-*-ansible&type=&language=&sort=](https://github.com/geerlingguy/docker-rockylinux10-ansible/blob/master/Dockerfile#L36C1-L37C1)
   pip3 install ansible
   
   # clone your repo
   git clone git@github.com:you/servers.git
   cd servers

   # Run ansible-playbook
   ansible-playbook --extra-vars operations_github_api_token=$GITHUB_TOKEN_WITH_ADMIN site-runner/playbook.yml

   # Confirm users exist
   sudo su - GITHUB_USERNAME

At this point, you should have admin users with your SSH keys, and 2 github runners. 

Check your Repo > settings > Actions > Runners.

For example: https://github.com/operations-project/ansible-collection-site-runner/settings/actions/runners


## About
This code sets up a server for launching and testing websites using GitOps tools like GitHub Actions and hosting tools like DDEV.

The goal is to quickly launch running environments on any server for automated and manual testing, integrated directly with GitOps APIs.

It uses GitHub Actions and Workflows with self-hosted runners, providing persistent, accessible environments and logs, fully integrated with GitHub Deployments & Checks APIs for optimal developer experience.

For more details see https://operations-project.gitbook.io/operations-experience-project/operations-site-server 

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

- [GitHub issue templates](https://github.com/operations-project/site-runner/issues/templates/edit)
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

        git clone git@github.com:operations-project/site-runner.git /usr/share/operations

2. Prepare.

    This playbook creates GitHub runners automatically using a GitHub Token.

    This token is only used to create a runner. No other API interaction is needed because it is all handled by the GitHub Runners. Runner tasks get a unique `GITHUB_TOKEN` for every job, so users can interact with the GitHub API that way.

   *NOTE:* If your project is not a personal repo, you need to enable "Personal Access Tokens" in your organization.

    #### To enable Personal Access Tokens for organizations:

    1. Open your organization's page. For example: https://github.com/organizations/operations-platform/
    2. Click *Settings*.
    3. Click *Personal Access Tokens* in the left sidebar.
    4. Go through the wizard to configure how tokens work in your organization.

    Once complete, your organization will be available when you create your own "Personal Access Token".

    #### To create Personal Access Tokens:

    1. Go to the Create Token Page: https://github.com/settings/personal-access-tokens/new
    2. Under *Resource owner*, select your organization.
    3. Under *Repository Permissions*, for *Administration*, select *Read/Write*.
    4. Click *Generate Token*. Save the token for the **Configure** step, below.

3. Configure Ansible Inventory.

    Ansible inventory is very powerful and flexible. There are many ways to manage your inventory.

    This playbook comes with example inventory and variable files that you can use to manually place in `/etc/ansible/hosts` and `/etc/ansible/host_vars/sites.myhost.com.yml`

    See example files in [`./ansible/hosts.example`](./ansible/hosts.example) and [`./ansible/host_vars/host.example.yml`](./ansible/host_vars/host.example.yml)

    The result should look something like this:

    * `/etc/ansible/hosts`

          [operations_host_ddev]
          sites.myhost.com ansible_connection=local

    * `/etc/ansible/host_vars/sites.myhost.com.yml`

          # Add a list of github usernames to grant access to. They will get sudo users and SSH access.
          operations_admin_users:
          - YOUR_GITHUB_USERNAME

          operations_github_api_token: YOUR_API_TOKEN
          operations_github_runners:
          - repo_name: YOUR_ORG/YOUR_REPO

    For details on additional options, see [`./ansible/host_vars/host.example.yml`](./ansible/host_vars/host.example.yml).

    You are free to build up your ansible inventory as you see fit. These are the essential options.

4. Install.

    To install, run `ansible-playbook` as your user (not with `sudo`). Ansible knows how to run `sudo` for the steps that require it.

    As long as your active user *can* sudo, you can run `ansible-playbook` as your personal user account.

        ansible-playbook /usr/share/operations/playbook.yml

   Once the playbook completes successfully, you will have a new runner present in GitHub. To confirm:

    * Visit your repository's *Settings* page.
    * Click *Actions*, then *Runners*.
    * You should see a runner that matches the hostname and labels you set in your ansible inventory

    > *NOTE:* The playbook will create users from your `operations_admin_users` variables, and will grant them passwordless `SUDO` access. After running it the first time, you can run `ansible-playbook` as your personal user.

5. Implement.

    To use it, you need to add a GitHub workflow config file that has `runs-on` set to a label that your runner has.

    An example to confirm the runner:

    ```yaml
    # .github/workflows/demo.yml
    name: Verify Self-Hosted Runner

    # Run on all pushes and manual triggering with "workflow_dispatch"
    on:
        workflow_dispatch:
        push:

    jobs:
      verify:
        # Match a label or use the hostname label.
        runs-on: sites.myhost.com

        steps:
          - name: Environment
            run: |
              hostname -f
              whoami
              env
    ```

    More workflow samples coming soon.

## Built With

List significant dependencies that developers of this project will interact with.

* [Composer](https://getcomposer.org/) - Dependency Management
* [Robo](https://robo.li/) - PHP Task Runner
* [Symfony](https://symfony.com/) - PHP Framework
* [Ansible](https://ansible.com) - System Configuration Platform

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [releases](https://github.com/operations-project/site-runner/releases) page.

## Authors

* **Jon Pugh** - created project from template.

See also the list of [contributors](https://github.com/operations-project/site-runner/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* @g1a for all that you do.
* aegir, lando, docksal, ddev, etc
