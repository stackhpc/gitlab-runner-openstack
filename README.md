# gitlab-runner-openstack

This repository contains some simple [OpenTofu](https://opentofu.org) that
uses Cloud-Init to launch a [GitLab CI runner](https://docs.gitlab.com/runner/) in an
[OpenStack](https://www.openstack.org/) project that uses the
[Docker executor](https://docs.gitlab.com/runner/executors/docker.html).

## Usage

First, ensure
[OpenTofu is installed](https://opentofu.org/docs/intro/install/).

Next, make sure you have credentials for the target OpenStack project. The following
examples will assume the use of a
[clouds.yaml](https://docs.openstack.org/python-openstackclient/latest/configuration/index.html#clouds-yaml)
file, preferably containing an
[Application Credential](https://docs.openstack.org/keystone/latest/user/application_credentials.html).

You will also need the host and registration token for registering a runner with the
target GitLab instance. These can be found in the runners panel at either the global
(admin required), group or project level.

Next, clone this repository:

```sh
git clone https://github.com/stackhpc/gitlab-runner-openstack.git
cd gitlab-runner-openstack
```

Create a
[tfvars](https://opentofu.org/docs/language/values/variables/#variable-definitions-tfvars-files)
file to configure the runner:

```ruby
## FILE: my-runner.tfvars

# The ID of the network to provision the runner on
# Must be able to reach the internet, but does not have to be reachable from the internet
network_id = "<network-id>"

# The ID of an Ubuntu 22.04 image to use
image_id = "<image-id>"

# The name of the flavor to use for the runner
flavor_name = "<flavor-name>"

# The GitLab host to connect to
gitlab_host = "<https://gitlab.example.org>"

# The token to use when registering the runner
registration_token = "<token>"

```

Then execute the following commands to deploy a runner:

```sh
# OpenStack authentication
export OS_CLOUD=openstack
export OS_CLIENT_CONFIG_FILE=/path/to/clouds.yaml

# Init the OpenTofu state
tofu init

# Provision the runner
tofu apply -var-file=./my-runner.tfvars -auto-approve
```
