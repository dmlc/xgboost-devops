## Example input:
##   xgb-ci.gpu_build_r_rockylinux8
## Example output:
##   --build-arg CUDA_VERSION=13.3.0 --build-arg R_VERSION=4.3.2
def compute_build_args($input; $image_repo):
  $input |
  .[$image_repo] |
  select(.build_args != null) |
  .build_args |
  to_entries |
  map("--build-arg " + .key + "=" + .value) |
  join(" ");
