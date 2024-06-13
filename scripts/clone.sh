#!/bin/bash

# SCRIPT TO CLONE REPOSITORIES OR(AND) T0 CREATE DIRECTORIES

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(realpath $0))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
 source ${BASE_DIR}/include/envDef.sh
 source ${BASE_DIR}/include/commonFcnDef.sh

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# DEFINE USAGE FUNCTION
# >>>----------------------------------------------------

usage(){
    echo "Usage: $0 [REPO|DIR|ALL]"
    echo "REPO: CLONE REPOSITORIES"
    echo "DIR: CREATE DIRECTORIES"
    echo "ALL: CLONE/CREATE BOTH REPOSITORIES AND DIRECTORIES"
    exit 1
}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# CHECK IF ANY INPUT ARGUMENTS ARE PROVIDED
# >>>----------------------------------------------------

if [ $# -eq 0 ]; then
    usage $0
elif [ $# -eq 1 ]; then
    if [ "$1x" != "REPOx" ] && [ "$1x" != "DIRx" ] && [ "$1x" != "ALLx" ]; then
        EchoRed "[$FUNCNAME] INVALID INPUT. PLEASE USE \"REPO\", \"DIR\", OR \"ALL\"."
        exit 1
    fi
else
    echo "[$(basename "$0")] INVALID NUMBER OF ARGUMENTS. PLEASE PROVIDE 0 OR 1 ARGUMENTS."
fi

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# MAIN STATEMENTS
# >>>----------------------------------------------------

if [ "$1x" == "REPOx" ]; then
    # CHECK AND CLONE BASED ON REPO_DICT
    echo "[$(basename "$0")] CHECKING AND CLONING REPOSITORIES"
    CheckAndClone
    EchoBoxLine
elif [ "$1x" == "DIRx" ]; then
    # CHECK AND CREATE BASED ON DIR_DICT
    echo "[$(basename "$0")] CHECKING AND CREATING DIRECTORIES"
    CheckAndCreate
    EchoBoxLine
elif [ "$1x" == "ALLx" ]; then
    echo "[$(basename "$0")] CHECKING AND CLONING/CREATING REPOSITORIES AND DIRECTORIES"
    # CHECK AND CLONE BASED ON REPO_DICT
    CheckAndClone
    # CHECK AND CREATE BASED ON DIR_DICT
    CheckAndCreate
    EchoBoxLine
fi

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<