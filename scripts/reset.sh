#!/bin/bash

# SCRIPT TO RESET REPOSITORIES OR(AND) DIRECTORIES

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
    echo "REPO: RESET REPOSITORIES"
    echo "DIR: RESET DIRECTORIES"
    echo "ALL: RESET BOTH REPOSITORIES AND DIRECTORIES"
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

# CHECK AND RESET FOR TARGET
echo "[$(basename "$0")] CHECKING AND DELETING FOR TARGET \"$1\""
CheckAndReset $1
# PRINT LINES FOR VISUAL SEPARATION
EchoBoxLine

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<