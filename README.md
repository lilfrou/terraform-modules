# Terraform modules

## Releasing changes

The repo using [Semantic Release](https://github.com/semantic-release/semantic-release) to automate release processes. Once an PR is merged into the repo, it triggers a patch release. Once a release is triggered, the new tag can be used

It also supports conventional commits which can be used to trigger other release types:

### Commit types
- By default all merges trigger the minor release e.g `1.0.0` -> `1.1.0`
- PRs with the `patch`, `fix` prefix will trigger a patch release e.g `1.0.0` -> `1.0.1`
- PRs with the `feat`, `perf` prefix will trigger a minor release e.g `1.0.0` -> `1.1.0`
- PRs with `BREAKING CHANGE` in their description will trigger a Major release. `1.0.0` -> `2.0.0`
