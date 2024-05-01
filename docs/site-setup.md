# Operations Site Server Setup

## Site Setup

Follow these instructions for preparing your site to run on OSS.

1. **DDEV Config**

    This system uses DDEV for launching hosted sites. Simply run `ddev config` to set up a site.

    ### Notes:

    - Automation is controlled by the YML files committed to your code repository (GitHub workflows or bitbucket pipelines). Examples are provided here.
    - Each project can customize what happens to launch sites.
    - Any hosting customizations can be done in DDEV config.
    - Install instructions: https://ddev.readthedocs.io/en/stable/users/install/ddev-installation/
    - The `ddev start` command will result in downtime.
      - To avoid this, put your production site on a server by itself.
      - You can skip the `ddev start` command in your automation, then run `ddev start` manually if there are any server config changes that need to happen.

    ### DDEV Hosting

    - DDEV is capable of running hosted environments, called "Casual Hosting". See https://ddev.readthedocs.io/en/stable/users/topics/hosting/ for documentation.
    - DDEV's built in hosting provider integrations can be leveraged in hosted environments as well as local development.
    - DDEV can be used in GitHub hosted environments, or self-hosted servers.

    ### DDEV Domains

    - DDEV automatically decides what URLs to host sites at based on the `project_tld` and `name` properties in your DDEV config.
    - When running CI environments, you will have multiple git clones on a single server. The `name` property of each project using `ddev` must be unique.
    - Setup wildcard DNS to point `*.dev.yourhost.com` or similar to your server.
    - To override the `project_tld` and `name` for individual code checkouts, you can do this:
        1.  To set domains dynamically: Write an additional `config.z.yaml` file to the DDEV folder using your GitOps scripts, that includes a modified `project_tld`:

                # File: .github/workflows/pull-request.yml
                # config.z.yaml file gets loaded last, overriding.
                # Results in domain "myproject.pr123.ci.myserver.com"
                - name: Prepare ddev.
                run: |
                    echo "name: myproject.pr${{ github.event.number }}" > config.z.yaml
                    echo "project_tld: ci.myserver.com" >> config.z.yaml
        2. To set custom domains, you must add `additional_fqds` to ddev config only in the desired environment. To do this, you can either:
            1. Write directly to the custom `config.z.yaml` file (requires storing domains in GitOps config).
            2. Create a separate config file to store domains that will only be loaded in one environment.

                   # File: .ddev/live.config.yml
                   additional_hostnames:
                   - www.thinkdrop.net
                   - thinkdrop.net

                   # File: .github/workflows/live-deploy.yml
                   - name: Activate live ddev config.
                     run: ln -sf live.config.yaml .ddev/config.x.yaml

    We'd love to make this simpler. If you have any ideas, please let us know!

2. **GitHub Workflows**


    - pull-request.yml



3. **Site Access**
