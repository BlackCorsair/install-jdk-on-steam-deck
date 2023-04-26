#!/bin/bash

JDK_17_URL=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
JDK_17_CHECKSUM_URL=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz.sha256
JDK_17_EXTRACTED_DIR=to-be-known-later
JDK_17_FILE_NAME=jdk-17_linux-x64_bin.tar.gz
JDK_17_CHECKSUM_FILE_NAME=jdk-17_linux-x64_bin.tar.gz.sha256

INSTALLATION_DIR="${HOME}/.local/jdk"

CURRENT_DIR=$(pwd)

# Logging utils using colors

RED='\033[1;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}${1}${NC}"
}

log_warning() {
    echo -e "${BLUE}${1}${NC}"
}

log_error() {
    echo -e "${RED}${1}${NC}"
}

cleanup() {
    cleanup_command="rm -rf ${INSTALLATION_DIR}"
    log_info "Cleaning unsuccesful installation: ${cleanup_command}"
    $cleanup_command
}

# if java can't be found (! type java), it won't print anything
# if java can be found (type java), then will print the message and exit
exit_if_jdk_is_installed() {
    ! type java || { log_warning "JDK is already installed, the installed will skip the installation"; exit 0; }
}

# download the jdk tar release from oracle and it's checksum
# uncompress and check
# clean uneeded files
install_jdk() {
    mkdir -p "${INSTALLATION_DIR}" || { log_error "Couldn't create the installation directory, exiting..."; cleanup; exit 1; }
    cd "${INSTALLATION_DIR}" || { log_error "Couldn't 'cd' into the installation directory, exiting..."; cleanup; exit 1; }

    # this repeated trick works as: if the command returns anything other than 0, it will exec what's on the right side
    # of the || (or) operator
    wget -O "${JDK_17_FILE_NAME}" "${JDK_17_URL}" --show-progress || \
        { log_error "Couldn't download the jdk release, exiting..."; cleanup; exit 1; }

    wget -O "${JDK_17_CHECKSUM_FILE_NAME}" "${JDK_17_CHECKSUM_URL}" --show-progress || \
        { log_error "Couldn't download the jdk checksum release, exiting..."; cleanup; exit 1; }

    # append the file so the checksum file points to the file we want to check
    echo "  ${JDK_17_FILE_NAME}" >> "${JDK_17_CHECKSUM_FILE_NAME}"

    sha256sum -c "${JDK_17_CHECKSUM_FILE_NAME}" || \
        { log_error "Downloaded jdk doesn't match the checksum, don't trust this url!!!\n${JDK_17_URL}"; cleanup; exit 1; }

    tar xvf "${JDK_17_FILE_NAME}" || { log_error "Couldn't decompress the jdk file, exiting..."; cleanup; exit 1; }

    JDK_17_EXTRACTED_DIR=$(tar tf jdk-17_linux-x64_bin.tar.gz | head -1 | cut -f1 -d"/")

    rm -f "${JDK_17_FILE_NAME}" "${JDK_17_CHECKSUM_FILE_NAME}"

    cd "${CURRENT_DIR}" || exit 1
}

# This will set JAVA_HOME and will also append the java/bin folder to PATH
set_variables_for_the_installation() {
    if ! grep "JAVA_HOME" ~/.bashrc ~/.profile
    then
        touch ~/.profile
        echo "export JAVA_HOME=${INSTALLATION_DIR}" >> ~/.profile
        echo "export PATH=\$PATH:${INSTALLATION_DIR}/${JDK_17_EXTRACTED_DIR}/bin" >>  ~/.profile
        echo "[[ -f ~/.profile ]] && source ~/.profile" >> ~/.bashrc
    fi
}

#### MAIN ####

log_info "Checking if you already have java installed"
exit_if_jdk_is_installed
log_info "Installing jdk17 on your local folder '.local/'..."

log_info "Downloading and decompressing jdk17 from oracle page..."
install_jdk
log_info "JDK downloaded and extracted into ${INSTALLATION_DIR}"

log_info "Setting environment variables if not already set"
set_variables_for_the_installation

log_info "Checking that java is properly installed..."
# shellcheck disable=SC1090
source ~/.bashrc
if "${INSTALLATION_DIR}/${JDK_17_EXTRACTED_DIR}/bin/java" -version
then
    log_info "Java is succesfully installed!"
    log_warning "To activate your java installation execute the following:\n\n\tsource ~/.bashrc\n\n"
else
    log_error "Java wasn't installed properly, please check the script :("
fi

log_info "Done"
