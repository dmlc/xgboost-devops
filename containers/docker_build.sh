#!/bin/bash
## Build a CI container and push it to AWS ECR (Elastic Container Registry).
## This script provides a convenient wrapper for containers/docker_build.py.
## Build-time variables (--build-arg) and container defintion are fetched from
## containers/ci_container.yml.
##
## Note. This script takes in some inputs via environment variables.

USAGE_DOC=$(
cat <<-EOF
Usage: containers/docker_build.sh [container_id]

where [container_id] is used to fetch the container definition and build-time variables
from containers/ci_container.yml.

In addition, the following environment variables should be set.
  - BRANCH_NAME:       Name of the current git branch or pull request (Required)
  - GITHUB_SHA:        Git commit hash (Required)
  - PUBLISH_CONTAINER: If set to 1, push the container to AWS ECR (Optional).
                       This option requires appropriate AWS credentials to be
                       configured.
EOF
)

# Use AWS ECR (Elastic Container Registry) to host Docker containers.
# Configure ECR to delete containers older than 30 days.
ECR_AWS_ACCOUNT_ID="492475357299"
ECR_AWS_REGION="us-west-2"
ECR_URL="${ECR_AWS_ACCOUNT_ID}.dkr.ecr.${ECR_AWS_REGION}.amazonaws.com"
ECR_LIFECYCLE_RULE=$(
cat <<-EOF
{
   "rules": [
       {
           "rulePriority": 1,
           "selection": {
               "tagStatus": "any",
               "countType": "sinceImagePushed",
               "countUnit": "days",
               "countNumber": 30
           },
           "action": {
               "type": "expire"
           }
       }
   ]
}
EOF
)

set -euo pipefail

for arg in "BRANCH_NAME" "GITHUB_SHA"
do
  if [[ -z "${!arg:-}" ]]
  then
    echo -e "Error: $arg must be set.\n\n${USAGE_DOC}"
    exit 1
  fi
done

if [[ "$#" -lt 1 ]]
then
  echo "${USAGE_DOC}"
  exit 2
fi
CONTAINER_ID="$1"

# Fetch CONTAINER_DEF and BUILD_ARGS
source <(containers/extract_build_args.sh ${CONTAINER_ID} | tee /dev/stderr) 2>&1

if [[ "${PUBLISH_CONTAINER:-}" != "1" ]]   # Any value other than 1 is considered false
then
  PUBLISH_CONTAINER=0
fi

if [[ ${PUBLISH_CONTAINER} -eq 0 ]]
then
  echo "PUBLISH_CONTAINER not set; the container will not be published"
else
  echo "The container will be published at ${ECR_URL}"
  # Login for Docker registry
  echo "aws ecr get-login-password --region ${ECR_AWS_REGION} |" \
       "docker login --username AWS --password-stdin ${ECR_URL}"
  aws ecr get-login-password --region ${ECR_AWS_REGION} \
    | docker login --username AWS --password-stdin ${ECR_URL}
fi

# Run Docker build
set -x
CONTAINER_TAG="${ECR_URL}/${CONTAINER_ID}:${GITHUB_SHA}"
python3 containers/docker_build.py \
  --container-def ${CONTAINER_DEF} \
  --container-tag ${CONTAINER_TAG} \
  ${BUILD_ARGS}

# Create another alias for the container using the branch name
CONTAINER_ALIAS="${ECR_URL}/${CONTAINER_ID}:${BRANCH_NAME}"
echo "docker tag ${CONTAINER_TAG} ${CONTAINER_ALIAS}"
docker tag ${CONTAINER_TAG} ${CONTAINER_ALIAS}

set +x

# Now push the new container to ECR
if [[ ${PUBLISH_CONTAINER} -eq 1 ]]
then
    # Attempt to create Docker repository; it will fail if the repository already exists
    echo "aws ecr create-repository --repository-name ${CONTAINER_ID} --region ${ECR_AWS_REGION}"
    if aws ecr create-repository --repository-name ${CONTAINER_ID} --region ${ECR_AWS_REGION}
    then
      # Repository was created. Now set expiration policy
      echo "aws ecr put-lifecycle-policy --repository-name ${CONTAINER_ID}" \
           "--region ${ECR_AWS_REGION} --lifecycle-policy-text file:///dev/stdin"
      echo "${ECR_LIFECYCLE_RULE}" | aws ecr put-lifecycle-policy --repository-name ${CONTAINER_ID} \
        --region ${ECR_AWS_REGION} --lifecycle-policy-text file:///dev/stdin
    fi

    echo "docker push --quiet ${CONTAINER_TAG}"
    if ! time docker push --quiet "${CONTAINER_TAG}"
    then
        echo "ERROR: could not update Docker cache ${CONTAINER_TAG}"
        exit 1
    fi

    echo "docker push --quiet ${CONTAINER_ALIAS}"
    docker push --quiet "${CONTAINER_ALIAS}"
fi
