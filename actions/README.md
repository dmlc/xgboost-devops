# Custom actions for XGBoost

XGBoost implements a few custom
[composite actions](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action)
to reduce duplicated code within workflow YAML files. The custom actions are hosted in a separate repository,
[dmlc/xgboost-devops](https://github.com/dmlc/xgboost-devops>), to make it easy to test changes to the custom actions in
a pull request or a fork.

In a workflow file, we'd refer to `dmlc/xgboost-devops/actions/{custom-action}@main`. For example:

```yaml
- uses: dmlc/xgboost-devops/actions/miniforge-setup@main
  with:
    environment-name: cpp_test
    environment-file: ops/conda_env/cpp_test.yml
```

Some custom actions consist of two components:

* Main script (`dmlc/xgboost-devops/actions/{custom-action}/action.yml`): dispatches to a specific version
  of the implementation script (see the next item). The main script clones `xgboost-devops` from
  a specified fork at a particular ref, allowing us to easily test changes to the custom action.
* Implementation script (`dmlc/xgboost-devops/actions/impls/{custom-action}/action.yml`): Implements the
  custom script.

This design was inspired by [Mike Sarahan](https://github.com/msarahan)'s work in
[rapidsai/shared-actions](https://github.com/rapidsai/shared-actions>).

## Sccache

This action uses the rapidsai fork of sccache. It accepts two optional parameters, namely
`cache-key-prefix` and `version`:
```yaml
- uses: dmlc/xgboost-devops/actions/sccache@main
  with:
    cache-key-prefix: ${{ github.job }}
    version: 'v0.13.0-rapids.0'
```

Internally, it uses the GitHub [cache](https://github.com/actions/cache) action to save
and restore cached files. Make sure your worker has all the needed dependencies (like
gzip, tar).

## msvc-dev-env

This action setups the msvc developer powershell:
```yaml
- uses: dmlc/xgboost-devops/actions/msvc-dev-env@main
```
Only vs2022 has been tested.
