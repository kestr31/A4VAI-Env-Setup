#!/bin/bash

# FUNCTION DEFINITIONS FOR OTHER RUN SCRIPTS

# FUNCTION TO ECHO INPUT IN GREEN
# >>>-------------------------------------------------------------
# INPUTS:
# $1: INPUT TO ECHO
# ----------------------------------------------------------------
EchoGreen(){
    echo -e "\e[32m$1\e[0m"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO ECHO INPUT IN RED
# >>>-------------------------------------------------------------
# INPUTS:
# $1: INPUT TO ECHO
# ----------------------------------------------------------------
EchoRed(){
    echo -e "\e[31m$1\e[0m"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO PRINT A LINE OF BOXLINES
# >>>-------------------------------------------------------------
EchoBoxLine(){
    echo $(printf '%.s─' $(seq 1 $(tput cols)))
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO READ BASE64 ENCODED ARRAY FROM DICTIONARY
# >>>-------------------------------------------------------------
# INPUTS:
# $1: BASE64 ENCODED ARRAY
# ----------------------------------------------------------------
# OUTPUTS:
# array: PARSED BASE64 ARRAY
# ----------------------------------------------------------------
ReadBase64Array(){
    while IFS= read -r -d '' item; do
        array+=( "$item" )
    done < <(openssl enc -d -a  <<<$1)
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK DIRECTORY AND CLONE REPOSITORY IF NOT EXISTS
# >>>-------------------------------------------------------------
# INPUTS:
# REPO_DICT (GLOBAL): DICTIONARY OF REPOSITORIES
# ----------------------------------------------------------------
CheckAndClone(){
    local array=( )
    for key in ${!REPO_DICT[@]}; do
        ReadBase64Array "${REPO_DICT[$key]}"
        if [ -d ${array[0]} ]; then
            EchoGreen "[$FUNCNAME] DIRECTORY ${array[0]} EXISTS. SKIPPING CLONE."
        else
            if [ -z ${array[2]} ]; then
                EchoRed "[$FUNCNAME] DIRECTORY ${array[0]} DOES NOT EXIST. CLONING REPOSITORY."
                EchoRed "[$FUNCNAME] CLONING FROM ${array[1]}. NO TAG SPECIFIED."
                git clone ${array[1]} ${array[0]}
            else
                EchoRed "[$FUNCNAME] DIRECTORY ${array[0]} DOES NOT EXIST. CLONING REPOSITORY."
                EchoRed "[$FUNCNAME] CLONING FROM ${array[1]}. CHECKING OUT TAG ${array[2]}."
                git clone ${array[1]} ${array[0]}
                git -C ${array[0]} checkout ${array[2]}
            fi
            EchoGreen "[$FUNCNAME] CLONING COMPLETE."
        fi
    done
    EchoGreen "[$FUNCNAME] CHECKED ALL TARGETS IN REPO_DICT"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK DIRECTORY AND CREATE IF NOT EXISTS
# >>>-------------------------------------------------------------
# INPUTS:
# DIR_DICT (GLOBAL): DICTIONARY OF DIRECTORIES
# ----------------------------------------------------------------
CheckAndCreate(){
    for key in ${!DIR_DICT[@]}; do
        if [ -d ${DIR_DICT[$key]} ]; then
            EchoGreen "[$FUNCNAME] DIRECTORY ${DIR_DICT[$key]} EXISTS. SKIPPING CREATION."
        else
            EchoRed "[$FUNCNAME] DIRECTORY ${DIR_DICT[$key]} DOES NOT EXIST. CREATING DIRECTORY."
            mkdir ${DIR_DICT[$key]}
        fi
    done
    EchoGreen "[$FUNCNAME] CHECKED ALL TARGETS IN DIR_DICT"
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# FUNCTION TO CHECK CLONED REPOSITORY AND RESET IF EXISTS
# >>>-------------------------------------------------------------
# INPUTS:
# REPO_DICT (GLOBAL): DICTIONARY OF REPOSITORIES
# ----------------------------------------------------------------
CheckAndReset(){
    # LIMIT INPUT ARGUMENTS TO "REPO", "DIR", OR "ALL"
    if [ "$1x" != "REPOx" ] && [ "$1x" != "DIRx" ] && [ "$1x" != "ALLx" ]; then
        EchoRed "[$FUNCNAME] INVALID INPUT. PLEASE USE \"REPO\", \"DIR\", OR \"ALL\"."
        exit 1
    fi

    # FOR INPUT STATEMENT "REPO" OR "ALL"
    if [ "$1x" == "REPOx" ] || [ "$1x" == "ALLx" ]; then
        # CHECK AND RESET REPOSITORIES
        local array=( )
        for key in ${!REPO_DICT[@]}; do
            ReadBase64Array "${REPO_DICT[$key]}"
            if [ -d ${array[0]} ]; then
                EchoRed "[$FUNCNAME] DIRECTORY ${array[0]} EXISTS. CLEANING DIRECTORY."
                git -C ${array[0]} clean -fdx
                EchoGreen "FINISHED RESET OF REPOSITORY ${key}."
            else
                EchoRed "[$FUNCNAME] DIRECTORY ${array[0]} DOES NOT EXIST. SKIPPING RESET."
                EchoRed "[$FUNCNAME] IT IS LIKEY THAT THE REPO ${key} HAS NOT BEEN CLONED YET."
                EchoRed "[$FUNCNAME] OR THE REPO HAS BEEN DELETED."
            fi
        done
        EchoGreen "[$FUNCNAME] CHECKED ALL TARGETS IN REPO_DICT"
    fi

    # FOR INPUT STATEMENT "DIR" OR "ALL"
    if [ "$1x" == "DIRx" ] || [ "$1x" == "ALLx" ]; then
    # CHECK AND RESET DIRECTORIES
        for key in ${!DIR_DICT[@]}; do
            if [ -d ${DIR_DICT[$key]} ]; then
                EchoRed "[$FUNCNAME] DIRECTORY ${DIR_DICT[$key]} EXISTS. CLEANING DIRECTORY."
                rm -rf ${DIR_DICT[$key]}/*
                EchoGreen "FINISHED RESET OF DIRECTORY ${key}."
            else
                EchoRed "[$FUNCNAME] DIRECTORY ${DIR_DICT[$key]} DOES NOT EXIST. SKIPPING RESET."
                EchoRed "[$FUNCNAME] IT IS LIKEY THAT THE DIRECTORY ${key} HAS NOT BEEN CREATED YET."
                EchoRed "[$FUNCNAME] OR THE DIRECTORY HAS BEEN DELETED."
            fi
        done
        EchoGreen "[$FUNCNAME] CHECKED ALL TARGETS IN DIR_DICT"
    fi
}


# FUNCTION TO CHECK DIRECTORY & REPOSITORIES. THEN CLEAN IF EXISTS
# >>>-------------------------------------------------------------
# INPUTS:
# REPO_DICT (GLOBAL): DICTIONARY OF REPOSITORIES
# DIR_DICT  (GLOBAL): DICTIONARY OF DIRECTORIES
# ----------------------------------------------------------------
CheckAndClean(){
    # LIMIT INPUT ARGUMENTS TO "REPO", "DIR", OR "ALL"
    if [ "$1x" != "REPOx" ] && [ "$1x" != "DIRx" ] && [ "$1x" != "ALLx" ]; then
        EchoRed "[$FUNCNAME] INVALID INPUT. PLEASE USE \"REPO\", \"DIR\", OR \"ALL\"."
        exit 1
    fi

    # FOR INPUT STATEMENT "REPO" OR "ALL"
    if [ "$1x" == "REPOx" ] || [ "$1x" == "ALLx" ]; then
        # CHECK AND CLEAN REPOSITORIES
        local array=( )
        for key in ${!REPO_DICT[@]}; do
            ReadBase64Array "${REPO_DICT[$key]}"
            if [ -d ${array[0]} ]; then
                EchoRed "[$FUNCNAME] DIRECTORY ${array[0]} EXISTS. CLEANING DIRECTORY."
                rm -rf ${array[0]}
                EchoGreen "FINISHED CLEANING OF REPOSITORY ${key}."
            else
                EchoRed "[$FUNCNAME] DIRECTORY ${array[0]} DOES NOT EXIST. SKIPPING CLEAN."
                EchoRed "[$FUNCNAME] IT IS LIKEY THAT THE REPO ${key} HAS NOT BEEN CLONED YET."
                EchoRed "[$FUNCNAME] OR THE REPO HAS BEEN DELETED."
            fi
        done
        EchoGreen "[$FUNCNAME] CHECKED ALL TARGETS IN DIR_DICT"
    fi

    # FOR INPUT STATEMENT "DIR" OR "ALL"
    if [ "$1x" == "DIRx" ] || [ "$1x" == "ALLx" ]; then
    # CHECK AND CLEAN DIRECTORIES
        for key in ${!DIR_DICT[@]}; do
            if [ -d ${DIR_DICT[$key]} ]; then
                EchoRed "[$FUNCNAME] DIRECTORY ${DIR_DICT[$key]} EXISTS. CLEANING DIRECTORY."
                rm -rf ${DIR_DICT[$key]}
                EchoGreen "FINISHED CLEANING OF DIRECTORY ${key}."
            else
                EchoRed "[$FUNCNAME] DIRECTORY ${DIR_DICT[$key]} DOES NOT EXIST. SKIPPING CLEAN."
                EchoRed "[$FUNCNAME] IT IS LIKEY THAT THE DIRECTORY ${key} HAS NOT BEEN CREATED YET."
                EchoRed "[$FUNCNAME] OR THE DIRECTORY HAS BEEN DELETED."
            fi
        done
        EchoGreen "[$FUNCNAME] CHECKED ALL TARGETS IN DIR_DICT"
    fi
}


# FUNCTION TO CHEK IF USER HAS SUPEUSER PRIVILEGES
# >>>-------------------------------------------------------------
CheckSudo(){
    # NO SPECIAL FUNCTION. JUST SUDO CHALLENGE.
    # CAN BE SKIPPED IF RUN BY USER root
    if [ $(id -u) -eq 0 ]; then
        EchoGreen "[$FUNCNAME] COMMAND RUN BY ROOT USER."
    else
        sudo -V
        EchoGreen "[$FUNCNAME] USER CAN ACCESS SUDO."
    fi
}
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
