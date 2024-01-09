#!/bin/bash

if [[ -z "$JDK_VERSION" ]];
then
    JDK_VERSION=17
fi

JDK_17_URL=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
JDK_17_CHECKSUM_URL=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz.sha256
JDK_17_EXTRACTED_DIR=to-be-known-later
JDK_17_FILE_NAME=jdk-17_linux-x64_bin.tar.gz
JDK_17_CHECKSUM_FILE_NAME=jdk-17_linux-x64_bin.tar.gz.sha256

JDK_21_URL=https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
JDK_21_CHECKSUM_URL=https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz.sha256
JDK_21_EXTRACTED_DIR=to-be-known-later
JDK_21_FILE_NAME=jdk-21_linux-x64_bin.tar.gz
JDK_21_CHECKSUM_FILE_NAME=jdk-21_linux-x64_bin.tar.gz.sha256

JDK_URL=""
JDK_CHECKSUM_URL=""
JDK_EXTRACTED_DIR=""
JDK_FILE_NAME=""
JDK_CHECKSUM_FILE_NAME=""

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

# Allows the user to select which version of the jdk to install
select_jdk_version() {
    case $JDK_VERSION in
        17)
            log_info "You've selected version jdk-17"
            JDK_URL="${JDK_17_URL}"
            JDK_CHECKSUM_URL="${JDK_17_CHECKSUM_URL}"
            JDK_EXTRACTED_DIR="${JDK_17_EXTRACTED_DIR}"
            JDK_FILE_NAME="${JDK_17_FILE_NAME}"
            JDK_CHECKSUM_FILE_NAME="${JDK_17_CHECKSUM_FILE_NAME}"
            ;;
        21)
            log_info "You've selected version jdk-21"
            JDK_URL="${JDK_21_URL}"
            JDK_CHECKSUM_URL="${JDK_21_CHECKSUM_URL}"
            JDK_EXTRACTED_DIR="${JDK_21_EXTRACTED_DIR}"
            JDK_FILE_NAME="${JDK_21_FILE_NAME}"
            JDK_CHECKSUM_FILE_NAME="${JDK_21_CHECKSUM_FILE_NAME}"
            ;;
        *)
            log_error "The version you've selected isn't supported, either set JDK_VERSION=17 or JDK_VERSION=21"
            cleanup
            exit 1
            ;;
    esac
}

# if java can't be found (! type java), it won't print anything
# if java can be found (type java), then will print the message and exit
exit_if_jdk_is_installed() {
    ! type java || { log_warning "JDK is already installed, the installer will skip the installation"; exit 0; }
}

# download the jdk tar release from oracle and it's checksum
# uncompress and check
# clean uneeded files
install_jdk() {
    mkdir -p "${INSTALLATION_DIR}" || { log_error "Couldn't create the installation directory, exiting..."; cleanup; exit 1; }
    cd "${INSTALLATION_DIR}" || { log_error "Couldn't 'cd' into the installation directory, exiting..."; cleanup; exit 1; }

    # this repeated trick works as: if the command returns anything other than 0, it will exec what's on the right side
    # of the || (or) operator
    wget -O "${JDK_FILE_NAME}" "${JDK_URL}" --show-progress || \
        { log_error "Couldn't download the jdk release, exiting..."; cleanup; exit 1; }

    wget -O "${JDK_CHECKSUM_FILE_NAME}" "${JDK_CHECKSUM_URL}" --show-progress || \
        { log_error "Couldn't download the jdk checksum release, exiting..."; cleanup; exit 1; }

    # append the file so the checksum file points to the file we want to check
    echo "  ${JDK_FILE_NAME}" >> "${JDK_CHECKSUM_FILE_NAME}"

    sha256sum -c "${JDK_CHECKSUM_FILE_NAME}" || \
        { log_error "Downloaded jdk doesn't match the checksum, don't trust this url!!!\n${JDK_URL}"; cleanup; exit 1; }

    tar xvf "${JDK_FILE_NAME}" || { log_error "Couldn't decompress the jdk file, exiting..."; cleanup; exit 1; }

    JDK_EXTRACTED_DIR=$(tar tf $JDK_FILE_NAME | head -1 | cut -f1 -d"/")

    rm -f "${JDK_FILE_NAME}" "${JDK_CHECKSUM_FILE_NAME}"

    cd "${CURRENT_DIR}" || exit 1
}

# This will set JAVA_HOME and will also append the java/bin folder to PATH
set_variables_for_the_installation() {
    touch ~/.profile
    if ! grep "JAVA_HOME" ~/.bashrc ~/.profile
    then
        echo "export JAVA_HOME=${INSTALLATION_DIR}" >> ~/.profile
        echo "export PATH=\$PATH:${INSTALLATION_DIR}/${JDK_EXTRACTED_DIR}/bin" >>  ~/.profile
        echo "[[ -f ~/.profile ]] && source ~/.profile" >> ~/.bashrc
    fi
}

#### MAIN ####

log_info "Checking if you already have java installed"
exit_if_jdk_is_installed

log_info "Validating jdk version selected, if none set jdk-17 will be used"
select_jdk_version

log_info "Installing jdk-$JDK_VERSION on your local folder '.local/'..."

log_info "Downloading and decompressing jdk17 from oracle page..."
install_jdk
log_info "JDK downloaded and extracted into ${INSTALLATION_DIR}"

log_info "Setting environment variables if not already set"
set_variables_for_the_installation

log_info "Checking that java is properly installed..."
# shellcheck disable=SC1090
source ~/.bashrc
if "${INSTALLATION_DIR}/${JDK_EXTRACTED_DIR}/bin/java" -version
then
    log_info "Java is succesfully installed!"

    how_to_use="
    \tTo start using this java installation, open a new terminal or start a new shell by running 'bash'
    \n\tOriginally you could run 'source ~/.bashrc', but since some time there's an issue with it
    \tor more info check the issue: https://github.com/BlackCorsair/install-jdk-on-steam-deck/issues/5"
    log_warning "${how_to_use}"
else
    log_error "Java wasn't installed properly, please check the script :("
    cleanup
fi

log_info "Done"
