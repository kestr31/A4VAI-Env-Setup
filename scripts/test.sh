#!/bin/bash

# TEST SCRIPT THAT ONLY HAS INITIAL STATEMENTS AND PLACEHOLDERS

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(realpath $0))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
 source ${BASE_DIR}/include/setupFcnDef.sh
 source ${BASE_DIR}/include/commonFcnDef.sh
#  source ${BASE_DIR}/include/envDef.sh

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



# MAIN STATEMENTS
# >>>----------------------------------------------------

echo "[$(basename "$0")] TESTING SCRIPT"
CheckSudo

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<