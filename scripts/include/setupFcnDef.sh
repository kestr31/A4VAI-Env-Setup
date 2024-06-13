#!/bin/bash

# FUNCTION DEFINITIONS FOR ENVIRONMENT SETUP

# FUNCTION TO CHECK IF THE SCRIPT IS RUNNING IN WSL
# >>>-------------------------------------------------------------
CheckWSL(){
    if grep -q Microsoft /proc/version; then
        EchoRed "[$FUNCNAME] SCRIPT IS RUNNING IN WSL."
        EchoRed "[$FUNCNAME] THIS SCRIPT IS NOT INTENDED TO RUN IN WSL."
        EchoRed "[$FUNCNAME] PLEASE RUN THIS SCRIPT IN A GENERIC UBUNTU ENVIRONMENT."
        exit 1
    else
        EchoGreen "[$FUNCNAME] SCRIPT IS NOT RUNNING IN WSL."
        EchoGreen "[$FUNCNAME] NICE!"
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK UBUNTU VERSION
# >>>-------------------------------------------------------------
CheckUbuntuVersion(){
    local UBUNTU_VERSION=$(lsb_release -r | awk '{print $2}')
    local UBUNTU_MAJOR_VERSION=$(echo $UBUNTU_VERSION | cut -d. -f1)
    if [ $((UBUNTU_MAJOR_VERSION)) -lt 18 ]; then
        EchoRed "[$FUNCNAME] UBUNTU VERSION IS $UBUNTU_VERSION."
        EchoRed "[$FUNCNAME] UBUNTU VERSION 18.04 OR HIGHER IS REQUIRED."
        exit 1
    elif [ $((UBUNTU_MAJOR_VERSION)) -lt 20 ]; then
        EchoRed "[$FUNCNAME] UBUNTU VERSION IS $UBUNTU_VERSION."
        EchoRed "[$FUNCNAME] ENV SETUP CAN BE DONE BUT NOT TESTED."
        EchoRed "[$FUNCNAME] UBUNTU 18.04 IS EOL. PLEASE CONSIDER UPGRADING."
    else
        EchoGreen "[$FUNCNAME] UBUNTU VERSION IS $UBUNTU_VERSION."
        EchoGreen "[$FUNCNAME] UBUNTU VERSION IS SUPPORTED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF DOCKER IS INSTALLED
## IF NOT INSTALLED, INSTALL DOCKER
# >>>-------------------------------------------------------------
CheckInstallDocker(){
    if [ -x "$(command -v docker)" ]; then
        EchoGreen "[$FUNCNAME] DOCKER IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] DOCKER IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] DOCKER WILL BE INSTALLED."
        # CHECK IF CURL IS INSTALLED
        CheckInstallCurl

        # GET DOCKER INSTALLATION SCRIPT
        curl -fsSL https://get.docker.com -o install-docker.sh
        
        # INSTALL DOCKER
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            sh install-docker.sh
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo sh install-docker.sh
        fi

        # REMOVE INSTALLATION SCRIPT
        rm -rf install-docker.sh

        if [ -f /.dockerenv ]; then
            EchoRed "[$FUNCNAME] SCRIPT IS RUNNING IN A CONTAINER."
            EchoRed "[$FUNCNAME] NO GROUP ADDITION WILL BE DONE."
        else
            EchoGreen "[$FUNCNAME] SCRIPT IS NOT RUNNING IN A CONTAINER."
            
            # IF USER IS NOT ROOT, ADD USER TO DOCKER GROUP
            if [ $(id -u) -eq 0 ]; then
                # FOR ROOT USER, NO NEED TO ADD TO DOCKER GROUP
                EchoRed "[$FUNCNAME] USER IS ROOT. NO NEED TO ADD TO DOCKER GROUP."
            else
                # FOR NON-ROOT USER, ADD TO DOCKER GROUP
                EchoGreen "[$FUNCNAME] USER IS NOT ROOT. USER WILL BE ADDED TO DOCKER GROUP."
                EchoGreen "[$FUNCNAME] USER WILL NEED TO LOGOUT AND LOGIN AGAIN. OR REBOOT SYSTEM."
                sudo usermod -aG docker $USER
            fi
        fi
        
        EchoGreen "[$FUNCNAME] DOCKER INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# CHECK IF NVIDIA GPU IS USED
# >>>-------------------------------------------------------------
CheckNvidiaGPU(){
    # IF RUN ON CONTAINER, ABORT
    if [ -f /.dockerenv ]; then
        EchoRed "[$FUNCNAME] SCRIPT IS RUNNING IN A CONTAINER."
        EchoRed "[$FUNCNAME] THIS SCRIPT IS NOT INTENDED TO RUN IN A CONTAINER."
        EchoRed "[$FUNCNAME] TO USE NVIDIA GPU IN A CONTAINER, USE NVIDIA-CONTAINER-TOOLKIT."
        exit 1
    else
        # CHECK IF NVIDIA GPU IS USED. Use LSPCI
        if lspci | grep -i nvidia > /dev/null; then
            EchoGreen "[$FUNCNAME] NVIDIA GPU IS DETECTED."
            CheckNvidiaDriver
        else
            EchoRed "[$FUNCNAME] NVIDIA GPU IS NOT DETECTED."
            EchoRed "[$FUNCNAME] THE DEVELOPMENT ENVIRONMENT REQUIRES NVIDIA GPU."
            exit 1
        fi
        EchoGreen "[$FUNCNAME] NVIDIA GPU CHECK COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# CHECK IF NVIDIA DRIVER IS INSTALLED
# >>>-------------------------------------------------------------
CheckNvidiaDriver(){
    # CHECK IF NVIDIA DRIVER IS INSTALLED
    if [ -x "$(command -v nvidia-smi)" ]; then
        EchoGreen "[$FUNCNAME] NVIDIA DRIVER IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] NVIDIA DRIVER IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] NVIDIA DRIVER WILL BE INSTALLED."
        CheckUpdatedRepoList

        # CHECK LATEST NVIDIA DRIVER VERSION
        local NVIDIA_DRIVER_VERSION=$(apt-cache search nvidia-driver | grep -oP "nvidia-driver-\d+" | sort | tail -n 1)

        # INSTALL NVIDIA DRIVER
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y $NVIDIA_DRIVER_VERSION
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y $NVIDIA_DRIVER_VERSION
        fi

        EchoGreen "[$FUNCNAME] NVIDIA DRIVER INSTALLATION COMPLETED."
        EchoGreen "[$FUNCNAME] REBOOT WILL BE PERFORMED IN 10 SECONDS."
        EchoGreen "[$FUNCNAME] PLEASE RESTART THE SCRIPT AFTER REBOOT."

        # SHOW SECONDS LEFT
        for i in {1..10}; do
            echo -n "$i "
            sleep 1
        done

        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            reboot -h now
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo reboot -h now
        fi
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF NVIDIA-CONTAINER-TOOLKIT IS INSTALLED
## IF NOT INSTALLED, INSTALL NVIDIA-CONTAINER-TOOLKIT
# >>>-------------------------------------------------------------
CheckInstallNvidiaContainerToolkit(){
    # CHECK IF THIS SCRIPT IS RUNNING IN A CONTAINER
    if [ -f /.dockerenv ]; then
        EchoRed "[$FUNCNAME] SCRIPT IS RUNNING IN A CONTAINER."
        EchoRed "[$FUNCNAME] NVIDIA-CONTAINER-TOOLKIT MUST BE INSTALLED IN THE HOST SYSTEM."
    else
        # CHECK IF NVIDIA-CONTAINER-TOOLKIT IS INSTALLED
        if [ -x "$(command -v nvidia-container-toolkit)" ]; then
            EchoGreen "[$FUNCNAME] NVIDIA-CONTAINER-TOOLKIT IS INSTALLED."
        else
            EchoRed "[$FUNCNAME] NVIDIA-CONTAINER-TOOLKIT IS NOT INSTALLED."
            EchoRed "[$FUNCNAME] NVIDIA-CONTAINER-TOOLKIT WILL BE INSTALLED."
            
            # CONFIGURE THE NVIDIA-CONTAINER-TOOLKIT REPOSITORY
            # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
            
            # CHECK IF CURL IS INSTALLED
            CheckInstallCurl

            # ADD NVIDIA-CONTAINER-TOOLKIT REPOSITORY
            if [ $(id -u) -eq 0 ]; then
                # IN CASE THAT USER IS ROOT
                curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
                && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

                apt-get update
                apt-get install -y nvidia-container-toolkit
                nvidia-ctk runtime configure --runtime=docker
                sudo systemctl restart docker
            else
                # IN CASE THAT USER IS NOT ROOT
                curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
                && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

                sudo apt-get update
                sudo apt-get install -y nvidia-container-toolkit
                sudo nvidia-ctk runtime configure --runtime=docker
                systemctl restart docker
            fi

            EchoGreen "[$FUNCNAME] NVIDIA-CONTAINER-TOOLKIT INSTALLATION COMPLETED."
        fi
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF APT-TRANSPORT-HTTPS IS INSTALLED
## IF NOT INSTALLED, INSTALL APT-TRANSPORT-HTTPS
# >>>-------------------------------------------------------------
CheckInstallAptTransportHttps(){
    if [ -x "$(command -v apt-transport-https)" ]; then
        EchoGreen "[$FUNCNAME] APT-TRANSPORT-HTTPS IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] APT-TRANSPORT-HTTPS IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] APT-TRANSPORT-HTTPS WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y apt-transport-https
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y apt-transport-https
        fi
        EchoGreen "[$FUNCNAME] APT-TRANSPORT-HTTPS INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF COMMON PACKAGES ARE INSTALLED
## IF NOT INSTALLED, INSTALL COMMON PACKAGES
## COMMON PACKAGES: CURL, GPG, OPENSSL, WGET
# >>>-------------------------------------------------------------
CheckInstallCommonSoftwares(){
    CheckInstallCurl
    CheckInstallGPG
    CheckInstallOpenSSL # REQUIRED TO PARSE NESTED BASH DICTIONARY
    CheckInstallWget
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF CURL IS INSTALLED
## IF NOT INSTALLED, INSTALL CURL
# >>>-------------------------------------------------------------
CheckInstallCurl(){
    if [ -x "$(command -v curl)" ]; then
        EchoGreen "[$FUNCNAME] CURL IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] CURL IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] CURL WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y curl
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y curl
        fi
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF DEVELOPMENT TOOLS ARE INSTALLED
## IF NOT INSTALLED, INSTALL DEVELOPMENT TOOLS
## DEVELOPMENT TOOLS: GIT, VSCODE
# >>>-------------------------------------------------------------
CheckInstallDevelopmentTools(){
    CheckInstallGit
    CheckInstallNeovim
    CheckInstallVSCode
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF GIT IS INSTALLED
## IF NOT INSTALLED, INSTALL GIT
# >>>-------------------------------------------------------------
CheckInstallGit(){
    if [ -x "$(command -v git)" ]; then
        EchoGreen "[$FUNCNAME] GIT IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] GIT IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] GIT WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y git
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y git
        fi
        EchoGreen "[$FUNCNAME] GIT INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<s


# FUNCTION TO CHECK IF GPG IS INSTALLED
## IF NOT INSTALLED, INSTALL GPG
# >>>-------------------------------------------------------------
CheckInstallGPG(){
    if [ -x "$(command -v gpg)" ]; then
        EchoGreen "[$FUNCNAME] GPG IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] GPG IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] GPG WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y gpg
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y gpg
        fi
        EchoGreen "[$FUNCNAME] GPG INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF NEOVIM IS INSTALLED
## IF NOT INSTALLED, INSTALL NEOVIM
# >>>-------------------------------------------------------------
CheckInstallNeovim(){
    if [ -x "$(command -v nvim)" ]; then
        EchoGreen "[$FUNCNAME] NEOVIM IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] NEOVIM IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] NEOVIM WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y neovim
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y neovim
        fi
        EchoGreen "[$FUNCNAME] NEOVIM INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF OPENSSL IS INSTALLED
## IF NOT INSTALLED, INSTALL OPENSSL
# >>>-------------------------------------------------------------
CheckInstallOpenSSL(){
    if [ -x "$(command -v openssl)" ]; then
        EchoGreen "[$FUNCNAME] OPENSSL IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] OPENSSL IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] OPENSSL WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y openssl
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y openssl
        fi
        EchoGreen "[$FUNCNAME] OPENSSL INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF VSCODE IS INSTALLED
## IF NOT INSTALLED, INSTALL VSCODE
# >>>-------------------------------------------------------------
CheckInstallVSCode(){
    if [ -x "$(command -v code)" ]; then
        EchoGreen "[$FUNCNAME] VSCODE IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] VSCODE IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] VSCODE WILL BE INSTALLED."

        CheckUpdatedRepoList

        # INSTALL VSCODE
        # https://code.visualstudio.com/docs/setup/linux
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
            rm -f packages.microsoft.gpg

            apt update
            apt install -y code
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install wget gpg
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
            rm -f packages.microsoft.gpg

            sudo apt-get update
            sudo apt-get install -y code
        fi
        EchoGreen "[$FUNCNAME] VSCODE INSTALLATION COMPLETED."
    fi

    if [ $(id -u) -eq 0 ]; then
        # IN CASE THAT USER IS ROOT
        EchoRed "[$FUNCNAME] EXTENSIONS WILL BE INSTALLED FOR ROOT USER."
        EchoRed "[$FUNCNAME] DUE TO VSCODE LIMITS OPTION OF \"--no-sandbox --user-data-dir=/root/.vscode/\" WILL BE USED."
        code --no-sandbox --user-data-dir=/root/.vscode/ --install-extension bierner.markdown-preview-github-styles
        code --no-sandbox --user-data-dir=/root/.vscode/ --install-extension GitHub.copilot
        code --no-sandbox --user-data-dir=/root/.vscode/ --install-extension GitHub.copilot-chat
        code --no-sandbox --user-data-dir=/root/.vscode/ --install-extension ms-azuretools.vscode-docker
        code --no-sandbox --user-data-dir=/root/.vscode/ --install-extension ms-python.python
        code --no-sandbox --user-data-dir=/root/.vscode/ --install-extension ms-vscode-remote.vscode-remote-extensionpack
    else
        # IN CASE THAT USER IS NOT ROOT
        EchoGreen "[$FUNCNAME] EXTENSIONS WILL BE INSTALLED FOR $USER."
        code --install-extension bierner.markdown-preview-github-styles
        code --install-extension GitHub.copilot
        code --install-extension GitHub.copilot-chat
        code --install-extension ms-azuretools.vscode-docker
        code --install-extension ms-python.python
        code --install-extension ms-vscode-remote.vscode-remote-extensionpack
    fi

}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK WGET IS INSTALLED
## IF NOT INSTALLED, INSTALL WGET
# >>>-------------------------------------------------------------
CheckInstallWget(){
    if [ -x "$(command -v wget)" ]; then
        EchoGreen "[$FUNCNAME] WGET IS INSTALLED."
    else
        EchoRed "[$FUNCNAME] WGET IS NOT INSTALLED."
        EchoRed "[$FUNCNAME] WGET WILL BE INSTALLED."
        CheckUpdatedRepoList
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get install -y wget
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get install -y wget
        fi
        EchoGreen "[$FUNCNAME] WGET INSTALLATION COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK IF APT-GET UPDATE HAS BEEN RUN
## IF NOT RUN, RUN APT-GET UPDATE
# >>>-------------------------------------------------------------
CheckUpdatedRepoList(){
    # CHECK IF apt-get update HAS BEEN RUN
    if [ -f /var/lib/apt/lists/lock ]; then
        EchoGreen "[$FUNCNAME] APT-GET UPDATE HAS BEEN RUN."
    else
        EchoRed "[$FUNCNAME] APT-GET UPDATE HAS NOT BEEN RUN."
        EchoRed "[$FUNCNAME] APT-GET UPDATE WILL BE RUN."
        if [ $(id -u) -eq 0 ]; then
            # IN CASE THAT USER IS ROOT
            apt-get update
        else
            # IN CASE THAT USER IS NOT ROOT
            sudo apt-get update
        fi
        EchoGreen "[$FUNCNAME] APT-GET UPDATE COMPLETED."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\


# FUNCTION TO UPGRADE ALL PACKAGES
# >>>-------------------------------------------------------------
UpgradeAllPackages(){
    if [ $(id -u) -eq 0 ]; then
        # IN CASE THAT USER IS ROOT
        apt update -y
        apt upgrade -y
    else
        # IN CASE THAT USER IS NOT ROOT
        sudo apt update -y
        sudo apt upgrade -y
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO UPDATE TO LATEST MESA DRIVER
# >>>-------------------------------------------------------------
UpdateMesaDriver(){
    if [ $(id -u) -eq 0 ]; then
        # IN CASE THAT USER IS ROOT
        add-apt-repository ppa:kisak/kisak-mesa -y
        apt upgrade -y
    else
        # IN CASE THAT USER IS NOT ROOT
        sudo add-apt-repository ppa:kisak/kisak-mesa -y
        apt upgrade -y
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<