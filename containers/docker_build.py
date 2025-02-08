"""
Wrapper script to build a Docker container
"""

import argparse
import itertools
import pathlib
import subprocess
import sys
import textwrap

PROJECT_ROOT_DIR = pathlib.Path(__file__).parent.parent
LINEWIDTH = 88
TEXT_WRAPPER = textwrap.TextWrapper(
    width=LINEWIDTH,
    initial_indent="",
    subsequent_indent="    ",
    break_long_words=False,
    break_on_hyphens=False,
)


def fancy_print_cli_args(cli_args: list[str]) -> None:
    print(
        "=" * LINEWIDTH
        + "\n"
        + "  \\\n".join(TEXT_WRAPPER.wrap(" ".join(cli_args)))
        + "\n"
        + "=" * LINEWIDTH
        + "\n",
        flush=True,
    )


def parse_build_args(*, raw_build_args: list[str]) -> dict[str, str]:
    parsed_build_args = dict()
    for arg in raw_build_args:
        try:
            key, value = arg.split("=", maxsplit=1)
        except ValueError as e:
            raise ValueError(
                f"Build argument must be of form KEY=VALUE. Got: {arg}"
            ) from e
        parsed_build_args[key] = value
    return parsed_build_args


def docker_build(
    *,
    image_uri: str,
    build_args: dict[str, str],
    dockerfile_path: pathlib.Path,
    docker_context_path: pathlib.Path,
) -> None:
    ## Set up command-line arguments to be passed to `docker build`
    # Build args
    docker_build_cli_args = list(
        itertools.chain.from_iterable(
            [["--build-arg", f"{k}={v}"] for k, v in build_args.items()]
        )
    )
    # When building an image using a non-default driver, we need to specify
    # `--load` to load it to the image store.
    # See https://docs.docker.com/build/builders/drivers/
    docker_build_cli_args.append("--load")
    # Remaining CLI args
    docker_build_cli_args.extend(
        [
            "--progress=plain",
            "--ulimit",
            "nofile=1024000:1024000",
            "-t",
            image_uri,
            "-f",
            str(dockerfile_path),
            str(docker_context_path),
        ]
    )
    cli_args = ["docker", "build"] + docker_build_cli_args
    fancy_print_cli_args(cli_args)
    subprocess.run(cli_args, check=True, encoding="utf-8")


def main(*, args: argparse.Namespace) -> None:
    docker_context_path = PROJECT_ROOT_DIR / "containers"
    dockerfile_path = (
        docker_context_path / "dockerfile" / f"Dockerfile.{args.container_def}"
    )

    build_args = parse_build_args(raw_build_args=args.build_arg)

    docker_build(
        image_uri=args.image_uri,
        build_args=build_args,
        dockerfile_path=dockerfile_path,
        docker_context_path=docker_context_path,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build a Docker container")
    parser.add_argument(
        "--container-def",
        type=str,
        required=True,
        help=(
            "String uniquely identifying the container definition. The container "
            "definition will be fetched from "
            "containers/dockerfile/Dockerfile.CONTAINER_DEF."
        ),
    )
    parser.add_argument(
        "--image-uri",
        type=str,
        required=True,
        help=(
            "Fully qualified image URI to identify the container, e.g. "
            "492475357299.dkr.ecr.us-west-2.amazonaws.com/xgb-ci.gpu:main"
        ),
    )
    parser.add_argument(
        "--build-arg",
        type=str,
        default=[],
        action="append",
        help=(
            "Build-time variable(s) to be passed to `docker build`. Each variable "
            "should be specified as a key-value pair in the form KEY=VALUE. "
            "The variables should match the ARG instructions in the Dockerfile. "
            "When passing multiple variables, specify --build-arg multiple times. "
            "Example: --build-arg CUDA_VERSION_ARG=12.5 --build-arg RAPIDS_VERSION_ARG=24.10"
        ),
    )

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    parsed_args = parser.parse_args()
    main(args=parsed_args)
