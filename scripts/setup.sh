#!/bin/bash

# SCRIPT TO SETUP ENVIRONMENT FOR DEVELOPMENT

# INITIAL STATEMENTS
# >>>----------------------------------------------------

# SET THE BASE DIRECTORY
BASE_DIR=$(dirname $(realpath $0))

# SOURCE THE ENVIRONMENT AND FUNCTION DEFINITIONS
 source ${BASE_DIR}/include/setupFcnDef.sh
 source ${BASE_DIR}/include/commonFcnDef.sh

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# CHECK IF ANY INPUT ARGUMENTS ARE PROVIDED
# >>>----------------------------------------------------

# IF THERE IS MORE THAN 1 ARUGMENT
if [ $# -ge 1 ]; then
    EchoRed "[$(basename "$0")] THIS SCRIPT DOES NOT TAKE ANY ARGUMENTS."
    EchoRed "[$(basename "$0")] ANYWAY, THE SCRIPT WILL CONTINUE."
fi

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# MAIN STATEMENTS
# >>>----------------------------------------------------

echo "[$(basename "$0")] SETTING UP ENVIRONMENT"

# CHECK WSL
CheckWSL
# CHECK UBUNTU VERSION
CheckUbuntuVersion
UpgradeAllPackages

# CHECK IF USER HAS SUDO PRIVILEGES
CheckSudo

# CHECK AND INSTALL COMMON PACKAGES
CheckInstallCommonSoftwares

# CHECK NVIDIA GPU
CheckNvidiaGPU
# CHECK AND INSTALL DOCKER IF NOT INSTALLED
CheckInstallDocker
# CHECK AND INSTALL NVIDIA CONTAINER TOOLKIT IF NOT INSTALLED
CheckInstallNvidiaContainerToolkit

# CHECK AND INSTALL GIT IF NOT INSTALLED
CheckInstallDevelopmentTools

# PRINT LINES FOR VISUAL SEPARATION
EchoBoxLine

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<