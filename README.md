# Custom actions for XGBoost

XGBoost implements a few custom
[composite actions](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action)
to reduce duplicated code within workflow YAML files. The custom actions are hosted in a separate repository,
[dmlc/xgboost-devops](https://github.com/dmlc/xgboost-devops>), to make it easy to test changes to the custom actions in
a pull request or a fork.

In a workflow file, we'd refer to `dmlc/xgboost-devops/{custom-action}@main`. For example:

```yaml
- uses: dmlc/xgboost-devops/miniforge-setup@main
  with:
    environment-name: cpp_test
    environment-file: ops/conda_env/cpp_test.yml
```

Each custom action consists of two components:

* Main script (`dmlc/xgboost-devops/{custom-action}/action.yml`): dispatches to a specific version
  of the implementation script (see the next item). The main script clones `xgboost-devops` from
  a specified fork at a particular ref, allowing us to easily test changes to the custom action.
* Implementation script (`dmlc/xgboost-devops/impls/{custom-action}/action.yml`): Implements the
  custom script.

This design was inspired by [Mike Sarahan](https://github.com/msarahan)'s work in
[rapidsai/shared-actions](https://github.com/rapidsai/shared-actions>).
