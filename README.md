# Ansible Role: dawarich

[![Build Status][build_badge]][build_link]
[![Ansible Galaxy][galaxy_badge]][galaxy_link]

Deploy [Dawarich](https://dawarich.app) ([GitHub](https://github.com/Freika/dawarich)) and the services it depends upon in Docker.

Install the role: `ansible-galaxy role install tigattack.dawarich`

See [Example Playbooks](#example-playbooks) below.

> [!IMPORTANT]
> **Supported Dawarich version(s):** >=0.28.0  
> Older versions of this role are compatible with previous Dawarich versions.

## Prerequisites

* Docker. I recommend the [geerlingguy.docker](https://github.com/geerlingguy/ansible-role-docker) role.
* [community.docker](https://galaxy.ansible.com/ui/repo/published/community/docker/) Ansible collection. See [requirements.yml](requirements.yml).
* A chosen data path on the host.

## Role Variables

> [!TIP]
> Once installed, you can run `ansible-doc -t role tigattack.dawarich` to see role documentation.

<!-- BEGIN ANSIBLE ROLE VARIABLES -->

### `dawarich_data_path`

| Type | Default         | Required |
| ---- | --------------- | -------- |
| path | `/opt/dawarich` | ❌       |

Dawarich data path on the host.

### `dawarich_docker_network_name`

| Type   | Default    | Required |
| ------ | ---------- | -------- |
| string | `dawarich` | ❌       |

Name of the Docker network to connect the Dawarich containers to.

### `dawarich_version`

| Type   | Default  | Required |
| ------ | -------- | -------- |
| string | `latest` | ❌       |

Dawarich application Docker image version (tag).

### `dawarich_app_hosts`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | None    | ❌       |

Host of the Dawarich application (e.g. dawarich.example.com).

> [!NOTE]
> Regardless of the user-specified value, `localhost,::1,127.0.0.1` will always be added to Dawarich's `APPLICATION_HOSTS`.  
> Example: If you set the value as `dawarich.example.com`, it will be set to `dawarich.example.com,localhost,::1,127.0.0.1`  
> If left default (`None`), Dawarich's `APPLICATION_HOSTS` will be `localhost,::1,127.0.0.1`.

### `dawarich_app_protocol`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | `http`  | ❌       |

Protocol for the Dawarich application.

Set to `https` if accessing Dawarich through a SSL-terminating reverse proxy.

Must be one of: `http`, `https`.

### `dawarich_port`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `3000`  | ❌       |

Dawarich application port.

### `dawarich_rails_env`

| Type   | Default       | Required |
| ------ | ------------- | -------- |
| string | `development` | ❌       |

Rails environment for the Dawarich application.

This should ideally be `production`, but some bugs have been observed in production mode that are not present in development mode.

### `dawarich_timezone`

| Type   | Default   | Required |
| ------ | --------- | -------- |
| string | `Etc/UTC` | ❌       |

Timezone for the Dawarich application.

See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List>

### `dawarich_min_minutes_spent_in_city`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `60`    | ❌       |

Minimum minutes spent in a city to be counted.

### `dawarich_background_processing_concurrency`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `10`    | ❌       |

Number of background processing workers per Sidekiq worker.

### `dawarich_rails_max_threads`

| Type | Default                                                               | Required |
| ---- | --------------------------------------------------------------------- | -------- |
| int  | `dawarich_workers_count * dawarich_background_processing_concurrency` | ❌       |

Connection pool size for the Dawarich database.

> [!TIP]
> The default value, if undefined, is the number of workers ([`dawarich_workers_count`](#dawarich_workers_count)) multiplied by the background processing concurrecy ([`dawarich_background_processing_concurrency`](#dawarich_background_processing_concurrency)).  
> For example, with 1 worker (default) and 10 background workers (default), this would be 10.

### `dawarich_encryption_secret_key`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | None    | ✅       |

The Dawarich encryption salt/secret key (Rails' `secret_key_base`).

### `dawarich_workers_count`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `1`     | ❌       |

Number of Sidekiq workers to deploy.

### `dawarich_reverse_geocoding_enabled`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `true`  | ❌       |

Enable reverse geocoding.

### `dawarich_photon_api_host`

| Type   | Default                               | Required |
| ------ | ------------------------------------- | -------- |
| string | `''` or `dawarich-photon` (see below) | ❌       |

API host for the Photon reverse geocoding service.

If [`dawarich_deploy_photon`](#dawarich_deploy_photon) is `false`, this will default to an empty string.

Otherwise, if [`dawarich_deploy_photon`](#dawarich_deploy_photon) is `true`, this will default to `dawarich-photon` (the name of the Photon container).

You will only need to change this if you wish to use a different Photon instance, whether self-hosted or public.

### `dawarich_photon_api_use_https`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `true`  | ❌       |

Use HTTPS for requests to the Photon API.

### `dawarich_enable_prometheus_metrics`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `false` | ❌       |

Enable Prometheus metrics endpoint.

Once enabled, Prometheus metrics will be available at `localhost:<dawarich_prometheus_port>/metrics`

### `dawarich_prometheus_port`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `9394`  | ❌       |

Prometheus metrics port for Dawarich.

### `dawarich_shared_extra_env`

| Type | Default | Required |
| ---- | ------- | -------- |
| dict | `{}`    | ❌       |

Additional environment variables to apply to both the Dawarich application and the Sidekiq worker(s) containers.

### `dawarich_app_extra_env`

| Type | Default | Required |
| ---- | ------- | -------- |
| dict | `{}`    | ❌       |

Additional environment variables for the Dawarich application container.

### `dawarich_sidekiq_extra_env`

| Type | Default | Required |
| ---- | ------- | -------- |
| dict | `{}`    | ❌       |

Additional environment variables for the Dawarich Sidekiq worker container(s).

### `dawarich_store_geodata`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `true`  | ❌       |

Enable storing of geodata in the Dawarich database.

### `dawarich_log_max_size`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | `100m`  | ❌       |

Maximum size of Docker log files before rotation.

### `dawarich_log_max_file`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `5`     | ❌       |

Maximum number of Docker log files to keep.

### `dawarich_app_cpu_limit`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | `0.50`  | ❌       |

CPU limit for the Dawarich application container (e.g., `0.50` for 50% of one core).

Set to `0` to disable CPU limit.

### `dawarich_app_memory_limit`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | `4G`    | ❌       |

Memory limit for the Dawarich application container.

Set to `0` to disable memory limit.

### `dawarich_sidekiq_cpu_limit`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | `0.50`  | ❌       |

CPU limit for each Dawarich Sidekiq worker container (e.g., `0.50` for 50% of one core).

Set to `0` to disable CPU limit.

### `dawarich_sidekiq_memory_limit`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | `4G`    | ❌       |

Memory limit for each Dawarich Sidekiq worker container.

Set to `0` to disable memory limit.

### `dawarich_deploy_postgis`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `true`  | ❌       |

Deploy a PostGIS instance for Dawarich.

Set to `false` if using an external PostGIS instance.

### `dawarich_postgis_version`

| Type   | Default         | Required |
| ------ | --------------- | -------- |
| string | `17-3.5-alpine` | ❌       |

PostGIS Docker image version for Dawarich.

### `dawarich_postgis_host`

| Type   | Default       | Required |
| ------ | ------------- | -------- |
| string | `dawarich-db` | ❌       |

PostGIS host for Dawarich.

### `dawarich_postgis_port`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `5432`  | ❌       |

PostGIS port for Dawarich.

### `dawarich_postgis_db_name`

| Type   | Default    | Required |
| ------ | ---------- | -------- |
| string | `dawarich` | ❌       |

PostGIS database name for Dawarich.

### `dawarich_postgis_username`

| Type   | Default    | Required |
| ------ | ---------- | -------- |
| string | `dawarich` | ❌       |

PostGIS username for Dawarich.

### `dawarich_postgis_password`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string | None    | ✅       |

PostGIS password for Dawarich.

### `dawarich_postgis_use_custom_config`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `false` | ❌       |

Set to `true` if you want to use a custom config file.

### `dawarich_postgis_conf_file`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string |         | ❌       |

Path to the PostgreSQL config file on the Ansible controller.

If left default (empty) and `dawarich_postgis_use_custom_config` is `true`, the example config will be downloaded from the Dawarich repository at <https://github.com/Freika/dawarich/blob/master/postgisql.conf.example.>

> [!NOTE]
> This is ignored unless `dawarich_postgis_use_custom_config` is `true`.

### `dawarich_deploy_redis`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `true`  | ❌       |

Deploy a Redis instance for Dawarich.

Set to `false` if using an external Redis instance.

### `dawarich_redis_version`

| Type   | Default      | Required |
| ------ | ------------ | -------- |
| string | `7.4-alpine` | ❌       |

Redis Docker image version for Dawarich.

### `dawarich_redis_host`

| Type   | Default          | Required |
| ------ | ---------------- | -------- |
| string | `dawarich-redis` | ❌       |

Redis host for Dawarich.

### `dawarich_redis_port`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `6379`  | ❌       |

Redis port for Dawarich.

### `dawarich_deploy_photon`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `false` | ❌       |

Deploy a Photon instance for reverse geocoding.

> [!NOTE]
> Assuming you are not specifying `dawarich_photon_region` to limit the downloaded dataset to a single region, this requires well over 120GB of disk space and a significant amount of RAM (16GB is recommended but not always required).

### `dawarich_photon_version`

| Type   | Default  | Required |
| ------ | -------- | -------- |
| string | `latest` | ❌       |

Photon Docker image version for reverse geocoding.

### `dawarich_photon_data_path`

| Type | Default                | Required |
| ---- | ---------------------- | -------- |
| path | `/opt/dawarich/photon` | ❌       |

Photon data path on the host.

### `dawarich_photon_port`

| Type | Default | Required |
| ---- | ------- | -------- |
| int  | `2322`  | ❌       |

Photon application port.

### `dawarich_photon_region`

| Type   | Default | Required |
| ------ | ------- | -------- |
| string |         | ❌       |

Photon reverse geocoding region.

You can see available regions at <https://github.com/rtuszik/photon-docker/blob/main/README.md#available-regions>

### `dawarich_photon_extra_env`

| Type | Default | Required |
| ---- | ------- | -------- |
| dict | `{}`    | ❌       |

Additional environment variables for the Photon container.

### `dawarich_prune_docker_images`

| Type | Default | Required |
| ---- | ------- | -------- |
| bool | `true`  | ❌       |

Prune *all* Docker images after deployment if any container has changed.

<!-- END ANSIBLE ROLE VARIABLES -->

## Example Playbooks

**Bare Minimum:**

```yml
---
- name: Deploy Dawarich
  hosts: server
  roles:
    - role: tigattack.dawarich
      vars:
        dawarich_postgis_password: _!CHANGEME!_
```

**With self-hosted Photon instance:**

```yml
---
- name: Deploy Dawarich
  hosts: server
  roles:
    - role: tigattack.dawarich
      vars:
        dawarich_postgis_password: _!CHANGEME!_
        dawarich_deploy_photon: true
        dawarich_photon_api_use_https: false
```

> [!WARNING]
> Photon requires well over 120GB of disk space and a significant amount of RAM (16GB is recommended but not always required).
> 
> Refer to [`dawarich_photon_region`](#dawarich_photon_region) to restrict the downloaded dataset to a single region to significantly reduce these requirements.

## License

MIT

[build_badge]:  https://img.shields.io/github/actions/workflow/status/tigattack/ansible-role-dawarich/test.yml?branch=main&label=Lint%20%26%20Test
[build_link]:   https://github.com/tigattack/ansible-role-dawarich/actions?query=workflow:Test
[galaxy_badge]: https://img.shields.io/ansible/role/d/tigattack/dawarich
[galaxy_link]:  https://galaxy.ansible.com/ui/standalone/roles/tigattack/dawarich/
