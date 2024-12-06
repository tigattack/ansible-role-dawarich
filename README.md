# Ansible Role: dawarich

[![Build Status][build_badge]][build_link]
[![Ansible Galaxy][galaxy_badge]][galaxy_link]

Deploy [Dawarich](https://dawarich.app) ([GitHub](https://github.com/Freika/dawarich)) and the services it depends upon in Docker.

Install the role: `ansible-galaxy role install tigattack.dawarich`

See [Example Playbooks](#example-playbooks) below.

## Prerequisites

* Docker. I recommend the [geerlingguy.docker](https://github.com/geerlingguy/ansible-role-docker) role.
* [community.docker](https://galaxy.ansible.com/ui/repo/published/community/docker/) Ansible collection. See [requirements.yml](requirements.yml).
* A chosen data path on the host.

## Role Variables

> [!TIP]
> Once installed, you can run `ansible-doc -t role tigattack.dawarich` to see role documentation.

### `dawarich_data_path`

| Type | Default         |
|------|-----------------|
| path | `/opt/dawarich` |

Dawarich data path on the host.

### `dawarich_docker_network_name`

| Type   | Default    |
|--------|------------|
| string | `dawarich` |

Name of the Docker network to connect the Dawarich containers to.

### `dawarich_version`

| Type   | Default  |
|--------|----------|
| string | `latest` |

Dawarich application Docker image version (tag).

### `dawarich_app_hosts`

| Type   | Default     |
|--------|-------------|
| string | `localhost` |

Host of the Dawarich application (e.g., localhost or dawarich.example.com).

### `dawarich_app_protocol`

| Type   | Default |
|--------|---------|
| string | `http`  |

Protocol for the Dawarich application. Set to `https` if accessing Dawarich through a SSL-terminating reverse proxy.

### `dawarich_port`

| Type | Default |
|------|---------|
| int  | `3000`  |

Dawarich application port.

### `dawarich_timezone`

| Type   | Default   |
|--------|-----------|
| string | `Etc/UTC` |

Timezone for the Dawarich application.

See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List>.

### `dawarich_min_minutes_spent_in_city`

| Type | Default |
|------|---------|
| int  | `60`    |

Minimum minutes spent in a city to be counted.

### `dawarich_distance_unit`

| Type   | Default |
|--------|---------|
| string | `km`    |

Distance unit for the application.

Must be one of: `km`, `mi`.

### `dawarich_background_processing_concurrency`

| Type | Default |
|------|---------|
| int  | `10`    |

Number of background processing workers for the Sidekiq worker container.

### `dawarich_reverse_geocoding_enabled`

| Type | Default |
|------|---------|
| bool | `true`  |

Enable reverse geocoding.

### `dawarich_photon_api_host`

| Type   | Default                                |
|--------|----------------------------------------|
| string | `photon.komoot.io` / `dawarich-photon` |

API host for the Photon reverse geocoding service.

If [`dawarich_deploy_photon`](#dawarich_deploy_photon) is `false`, this will default to `photon.komoot.io`, the default public Photon API host.

Otherwise, if [`dawarich_deploy_photon`](#dawarich_deploy_photon) is `true`, this will default to `dawarich-photon` (the name of the Photon container).

### `dawarich_photon_api_use_https`

| Type | Default |
|------|---------|
| bool | `true`  |

Use HTTPS for requests to the Photon API.

### `dawarich_enable_prometheus_metrics`

| Type | Default |
|------|---------|
| bool | `false` |

Enable Prometheus metrics endpoint.

Once enabled, Prometheus metrics will be available at `<host>:9394/metrics` (assuming [`dawarich_prometheus_port`](#dawarich_prometheus_port) is left default).

### `dawarich_prometheus_port`

| Type | Default |
|------|---------|
| int  | `9394`  |

Prometheus metrics port for Dawarich.

> [!NOTE]
> This does nothing unless [`dawarich_enable_prometheus_metrics`](#dawarich_enable_prometheus_metrics) is set to `true`.

### `dawarich_disable_telemetry`

| Type | Default |
|------|---------|
| bool | `false` |

Disable telemetry. See <https://dawarich.app/docs/tutorials/telemetry>.

### `dawarich_app_extra_env`

| Type | Default |
|------|---------|
| dict | `{}`    |

Additional environment variables for the Dawarich application container.

### `dawarich_sidekiq_extra_env`

| Type | Default |
|------|---------|
| dict | `{}`    |

Additional environment variables for the Dawarich Sidekiq worker container.

### `dawarich_deploy_postgres`

| Type | Default |
|------|---------|
| bool | `true`  |

Deploy a PostgreSQL instance for Dawarich.

Set to `false` if using an external PostgreSQL instance.

### `dawarich_postgres_version`

| Type   | Default       |
|--------|---------------|
| string | `14.2-alpine` |

PostgreSQL Docker image version for Dawarich.

Ignored if [`dawarich_deploy_postgres`](#dawarich_deploy_postgres) is `false`.

### `dawarich_postgres_host`

| Type   | Default       |
|--------|---------------|
| string | `dawarich-db` |

PostgreSQL host for Dawarich.

### `dawarich_postgres_db_name`

| Type   | Default    |
|--------|------------|
| string | `dawarich` |

PostgreSQL database name for Dawarich.

### `dawarich_postgres_username`

| Type   | Default    |
|--------|------------|
| string | `dawarich` |

PostgreSQL username for Dawarich.

### `dawarich_postgres_password`

| Type   | Default |
|--------|---------|
| string | None    |

PostgreSQL password for Dawarich.

Must be set by the user.

### `dawarich_deploy_redis`

| Type | Default |
|------|---------|
| bool | `true`  |

Deploy a Redis instance for Dawarich.

Set to `false` if using an external Redis instance.

### `dawarich_redis_version`

| Type   | Default      |
|--------|--------------|
| string | `7.0-alpine` |

Redis Docker image version for Dawarich.

Ignored if [`dawarich_deploy_redis`](#dawarich_deploy_redis) is `false`.

### `dawarich_redis_host`

| Type   | Default          |
|--------|------------------|
| string | `dawarich-redis` |

Redis host for Dawarich.

### `dawarich_redis_port`

| Type | Default |
|------|---------|
| int  | `6379`  |

Redis port for Dawarich.

### `dawarich_redis_db_number`

| Type | Default |
|------|---------|
| int  | `0`     |

Redis database number for Dawarich.

### `dawarich_deploy_photon`

| Type | Default |
|------|---------|
| bool | `false` |

Deploy a Photon instance for reverse geocoding.

NOTE: This requires at least 170GB of disk space and a significant amount of RAM (16GB is recommended but not always required).

This assumes you are not specifying [`dawarich_photon_country_code`](#dawarich_photon_country_code) to limit the downloaded dataset to a single country.

### `dawarich_photon_version`

| Type   | Default  |
|--------|----------|
| string | `latest` |

Photon Docker image version for reverse geocoding.

Ignored if `dawarich_deploy_photon` is `false`.

### `dawarich_photon_data_path`

| Type | Default                |
|------|------------------------|
| path | `/opt/dawarich/photon` |

Photon data path on the host.

### `dawarich_photon_port`

| Type | Default |
|------|---------|
| int  | `2322`  |

Photon application port.

### `dawarich_photon_country_code`

| Type   | Default |
|--------|---------|
| string |         |

Photon reverse geocoding country code.

Set to an ISO 3166-1 alpha-2 country code if you only need reverse geocoding for a single country, or leave empty to download the full dataset.

You can see available countries at <https://download1.graphhopper.com/public/extracts/by-country-code/> and correlate with the list of codes here <https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes#Current_ISO_3166_country_codes>.

## Example Playbooks

**Bare Minimum:**

```yml
---
- name: Deploy Dawarich
  hosts: server
  roles:
    - role: tigattack.dawarich
      vars:
        dawarich_postgres_password: _!CHANGEME!_
```

**With self-hosted Photon instance:**

```yml
---
- name: Deploy Dawarich
  hosts: server
  roles:
    - role: tigattack.dawarich
      vars:
        dawarich_postgres_password: _!CHANGEME!_
        dawarich_deploy_photon: true
        dawarich_photon_api_use_https: false
```

> [!WARNING]
> This requires at least 170GB of disk space and a significant amount of RAM (16GB is recommended but not always required).
> 
> This assumes you are not specifying [`dawarich_photon_country_code`](#dawarich_photon_country_code) to limit the downloaded dataset to a single country.

## License

MIT

[build_badge]:  https://img.shields.io/github/actions/workflow/status/tigattack/ansible-role-dawarich/test.yml?branch=main&label=Lint%20%26%20Test
[build_link]:   https://github.com/tigattack/ansible-role-dawarich/actions?query=workflow:Test
[galaxy_badge]: https://img.shields.io/ansible/role/d/tigattack/dawarich
[galaxy_link]:  https://galaxy.ansible.com/ui/standalone/roles/tigattack/dawarich/
