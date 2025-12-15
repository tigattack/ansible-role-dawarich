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

### Core Application Settings

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_data_path` | path | `/opt/dawarich` | ❌ |
| `dawarich_docker_network_name` | string | `dawarich` | ❌ |
| `dawarich_version` | string | `latest` | ❌ |
| `dawarich_app_hosts` | string | None | ❌ |
| `dawarich_app_protocol` | string | `http` | ❌ |
| `dawarich_port` | int | `3000` | ❌ |
| `dawarich_rails_env` | string | `development` | ❌ |
| `dawarich_timezone` | string | `Etc/UTC` | ❌ |
| `dawarich_encryption_secret_key` | string | None | ✅ |

**Details:**
- `dawarich_data_path`: Dawarich data path on the host.
- `dawarich_docker_network_name`: Name of the Docker network to connect the Dawarich containers to.
- `dawarich_version`: Dawarich application Docker image version (tag).
- `dawarich_app_hosts`: Host of the Dawarich application (e.g. dawarich.example.com).
- `dawarich_app_protocol`: Protocol for the Dawarich application. Set to `https` if accessing Dawarich through a SSL-terminating reverse proxy. Must be one of: `http`, `https`.
- `dawarich_port`: Dawarich application port.
- `dawarich_rails_env`: Rails environment for the Dawarich application. This should ideally be `production`, but some bugs have been observed in production mode that are not present in development mode.
- `dawarich_timezone`: Timezone for the Dawarich application. See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List>.
- `dawarich_encryption_secret_key`: The Dawarich encryption salt/secret key (Rails' `secret_key_base`).

> [!NOTE]
> Regardless of the user-specified value for `dawarich_app_hosts`, `localhost,::1,127.0.0.1` will always be added to Dawarich's `APPLICATION_HOSTS`. Example: If you set the value as `dawarich.example.com`, it will be set to `dawarich.example.com,localhost,::1,127.0.0.1`. If left default (`None`), Dawarich's `APPLICATION_HOSTS` will be `localhost,::1,127.0.0.1`.

### Processing Configuration

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_min_minutes_spent_in_city` | int | `60` | ❌ |
| `dawarich_background_processing_concurrency` | int | `10` | ❌ |
| `dawarich_workers_count` | int | `1` | ❌ |
| `dawarich_store_geodata` | bool | `true` | ❌ |
| `dawarich_rails_max_threads` | int | `dawarich_workers_count * dawarich_background_processing_concurrency` | ❌ |

**Details:**
- `dawarich_min_minutes_spent_in_city`: Minimum minutes spent in a city to be counted.
- `dawarich_background_processing_concurrency`: Number of background processing workers per Sidekiq worker.
- `dawarich_workers_count`: Number of Sidekiq workers to deploy.
- `dawarich_store_geodata`: Enable storing of geodata in the Dawarich database.
- `dawarich_rails_max_threads`: Connection pool size for the Dawarich database.

> [!TIP]
> The default value for `dawarich_rails_max_threads`, if undefined, is the number of workers multiplied by the background processing concurrency. For example, with 1 worker (default) and 10 background workers (default), this would be 10.

### Reverse Geocoding

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_reverse_geocoding_enabled` | bool | `true` | ❌ |
| `dawarich_photon_api_host` | string | `''` or `dawarich-photon` (see below) | ❌ |
| `dawarich_photon_api_use_https` | bool | `true` | ❌ |

**Details:**
- `dawarich_reverse_geocoding_enabled`: Enable reverse geocoding.
- `dawarich_photon_api_host`: API host for the Photon reverse geocoding service. If `dawarich_deploy_photon` is `false`, this will default to an empty string. Otherwise, if `dawarich_deploy_photon` is `true`, this will default to `dawarich-photon` (the name of the Photon container). You will only need to change this if you wish to use a different Photon instance, whether self-hosted or public.
- `dawarich_photon_api_use_https`: Use HTTPS for requests to the Photon API.

### PostGIS Database

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_deploy_postgis` | bool | `true` | ❌ |
| `dawarich_postgis_version` | string | `17-3.5-alpine` | ❌ |
| `dawarich_postgis_host` | string | `dawarich-db` | ❌ |
| `dawarich_postgis_port` | int | `5432` | ❌ |
| `dawarich_postgis_db_name` | string | `dawarich` | ❌ |
| `dawarich_postgis_username` | string | `dawarich` | ❌ |
| `dawarich_postgis_password` | string | None | ✅ |
| `dawarich_postgis_use_custom_config` | bool | `false` | ❌ |
| `dawarich_postgis_conf_file` | string |  | ❌ |

**Details:**
- `dawarich_deploy_postgis`: Deploy a PostGIS instance for Dawarich. Set to `false` if using an external PostGIS instance.
- `dawarich_postgis_version`: PostGIS Docker image version for Dawarich.
- `dawarich_postgis_host`: PostGIS host for Dawarich.
- `dawarich_postgis_port`: PostGIS port for Dawarich.
- `dawarich_postgis_db_name`: PostGIS database name for Dawarich.
- `dawarich_postgis_username`: PostGIS username for Dawarich.
- `dawarich_postgis_password`: PostGIS password for Dawarich.
- `dawarich_postgis_use_custom_config`: Set to `true` if you want to use a custom config file.
- `dawarich_postgis_conf_file`: Path to the PostgreSQL config file on the Ansible controller. If left default (empty) and `dawarich_postgis_use_custom_config` is `true`, the example config will be downloaded from the Dawarich repository at <https://github.com/Freika/dawarich/blob/master/postgisql.conf.example>.

> [!NOTE]
> `dawarich_postgis_conf_file` is ignored unless `dawarich_postgis_use_custom_config` is `true`.

### Redis

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_deploy_redis` | bool | `true` | ❌ |
| `dawarich_redis_version` | string | `7.4-alpine` | ❌ |
| `dawarich_redis_host` | string | `dawarich-redis` | ❌ |
| `dawarich_redis_port` | int | `6379` | ❌ |

**Details:**
- `dawarich_deploy_redis`: Deploy a Redis instance for Dawarich. Set to `false` if using an external Redis instance.
- `dawarich_redis_version`: Redis Docker image version for Dawarich.
- `dawarich_redis_host`: Redis host for Dawarich.
- `dawarich_redis_port`: Redis port for Dawarich.

### Photon (Self-hosted Reverse Geocoding)

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_deploy_photon` | bool | `false` | ❌ |
| `dawarich_photon_version` | string | `latest` | ❌ |
| `dawarich_photon_data_path` | path | `/opt/dawarich/photon` | ❌ |
| `dawarich_photon_port` | int | `2322` | ❌ |
| `dawarich_photon_region` | string |  | ❌ |
| `dawarich_photon_extra_env` | dict | `{}` | ❌ |

**Details:**
- `dawarich_deploy_photon`: Deploy a Photon instance for reverse geocoding.
- `dawarich_photon_version`: Photon Docker image version for reverse geocoding.
- `dawarich_photon_data_path`: Photon data path on the host.
- `dawarich_photon_port`: Photon application port.
- `dawarich_photon_region`: Photon reverse geocoding region. You can see available regions at <https://github.com/rtuszik/photon-docker/blob/main/README.md#available-regions>.
- `dawarich_photon_extra_env`: Additional environment variables for the Photon container.

> [!WARNING]
> Photon requires well over 120GB of disk space and a significant amount of RAM (16GB is recommended but not always required), assuming you are not specifying `dawarich_photon_region` to limit the downloaded dataset to a single region.

### Monitoring & Resource Limits

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_enable_prometheus_metrics` | bool | `false` | ❌ |
| `dawarich_prometheus_port` | int | `9394` | ❌ |
| `dawarich_log_max_size` | string | `100m` | ❌ |
| `dawarich_log_max_file` | int | `5` | ❌ |
| `dawarich_app_cpu_limit` | string | `0.50` | ❌ |
| `dawarich_app_memory_limit` | string | `4G` | ❌ |
| `dawarich_sidekiq_cpu_limit` | string | `0.50` | ❌ |
| `dawarich_sidekiq_memory_limit` | string | `4G` | ❌ |

**Details:**
- `dawarich_enable_prometheus_metrics`: Enable Prometheus metrics endpoint. Once enabled, Prometheus metrics will be available at `localhost:<dawarich_prometheus_port>/metrics`.
- `dawarich_prometheus_port`: Prometheus metrics port for Dawarich.
- `dawarich_log_max_size`: Maximum size of Docker log files before rotation.
- `dawarich_log_max_file`: Maximum number of Docker log files to keep.
- `dawarich_app_cpu_limit`: CPU limit for the Dawarich application container (e.g., `0.50` for 50% of one core). Set to `0` to disable CPU limit.
- `dawarich_app_memory_limit`: Memory limit for the Dawarich application container. Set to `0` to disable memory limit.
- `dawarich_sidekiq_cpu_limit`: CPU limit for each Dawarich Sidekiq worker container (e.g., `0.50` for 50% of one core). Set to `0` to disable CPU limit.
- `dawarich_sidekiq_memory_limit`: Memory limit for each Dawarich Sidekiq worker container. Set to `0` to disable memory limit.

### Extra Environment Variables

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_shared_extra_env` | dict | `{}` | ❌ |
| `dawarich_app_extra_env` | dict | `{}` | ❌ |
| `dawarich_sidekiq_extra_env` | dict | `{}` | ❌ |

**Details:**
- `dawarich_shared_extra_env`: Additional environment variables to apply to both the Dawarich application and the Sidekiq worker(s) containers.
- `dawarich_app_extra_env`: Additional environment variables for the Dawarich application container.
- `dawarich_sidekiq_extra_env`: Additional environment variables for the Dawarich Sidekiq worker container(s).

### Docker Image Management

| Variable | Type | Default | Required |
|----------|------|---------|----------|
| `dawarich_prune_docker_images` | bool | `true` | ❌ |

**Details:**
- `dawarich_prune_docker_images`: Prune *all* Docker images after deployment if any container has changed.

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
