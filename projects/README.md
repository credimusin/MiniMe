# Projects Layer (`projects/`)

This directory contains custom pet-projects and applications deployed onto `monster`.

## Architectural Boundaries
- **`services/stateful/`**: Databases (`postgres`) and persistent volumes (`storage`) protected with `lifecycle { prevent_destroy = true }`.
- **`services/stateless/`**: Infrastructure and self-hosted applications (`caddy`, `forgejo`) that can be recreated or upgraded without data loss.
- **`projects/`**: Custom applications that may depend on resources from both `services/stateful` (e.g., PostgreSQL databases, persistent volumes) and `services/stateless` (e.g., `minime_ingress` network for Caddy routing).

## Adding a New Project
1. Create a module directory `projects/<project-name>/` with `versions.tf`, `variables.tf`, `main.tf`, and `outputs.tf`.
2. If the project requires persistent storage, declare its `docker_volume` in `services/stateful/storage/main.tf` with `prevent_destroy = true`.
3. Instantiate the module in root `main.tf` under the `3. PROJECTS` section and wire its upstream into `services/stateless/caddy`.
