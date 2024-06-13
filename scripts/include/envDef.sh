#!/bin/bash

# SCRIPT TO CLONE REPOSITORIES OR(AND) T0 CREATE DIRECTORIES

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(realpath $0))
DEV_DIR=$(dirname ${BASE_DIR})


# CREATE A DICTIONARY FOR THE DIRECTORIES
# >>>-------------------------------------------------------------
# KEY: IDENTIFIER
# ----------------------------------------------------------------
# VALUE: DIRECTORY
# ----------------------------------------------------------------
declare -A DIR_DICT
    # AIRSIM_BINARY
    DIR_DICT["AIRSIM_BINARY"]=${DEV_DIR}/Airsim_Binary
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# CREATE THE DICTIONARY FOR THE REPOSITORIES
# >>>-------------------------------------------------------------
# KEY: REPO_NAME
# ----------------------------------------------------------------
# VALUE: ARRAY
#   - 0: DIRECTORY_NAME
#   - 1: REPOSITORY_URL
#   - 2: TAG
# ----------------------------------------------------------------
declare -A REPO_DICT
    # PX4_SITL_RUNNER
    PX4_SITL_RUNNER=(
        ${DEV_DIR}/PX4-SITL-Runner
        "https://github.com/JOCIIIII/PX4-SITL-Runner.git"
        ""
    )
    REPO_DICT["PX4_SITL_RUNNER"]=$(printf '%s\0' "${PX4_SITL_RUNNER[@]}" | openssl enc -a)
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<