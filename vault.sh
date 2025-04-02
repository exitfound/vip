#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

: "${VAULT_CURRENT_VERSION:=1.19.0}"

VAULT_CONFIG_PATH="/etc/vault.d"
VAULT_DATA_PATH="/opt/vault/data"
VAULT_BIN_PATH="/usr/local/bin"
VAULT_SYSTEMD_PATH="/etc/systemd/system"
VAULT_COMPLETION_RPM="/etc/bash_completion.d/vault"
VAULT_COMPLETION_DEB="/usr/share/bash-completion/completions/vault"
VAULT_ADDR="http://0.0.0.0:8200"

SHORT=s:,l,h
LONG=set-version:,list-version,help
OPTIONS=$(getopt -a -n vault --options $SHORT --longoptions $LONG -- "$@")

help() {
  echo -e "These are the possible options to use: \n"
  echo -e "     [ -l | --list-version ]       List of all Vault versions available for installation.
     [ -s | --set-version ]        Determining a specific version of Vault for subsequent installation.
     [ -h | --help ]               General information about all options. \n"
  echo -e "Usage: ./vault.sh [OPTIONS] [ARGS]\n"
  exit 0
}

list_vault_versions() {
  curl -s https://releases.hashicorp.com/vault/ | grep -oE 'vault/[0-9]+\.[0-9]+\.[0-9]+' | awk -F'/' '{print $2}' | sort -V | uniq
  exit 0
}

check_requirements() {
  UTILS=("curl" "unzip")
  for util in "${UTILS[@]}"; do
      if ! command -v "$util" &> /dev/null; then
        echo -e "❌ Utility «$util» not found -- install for your operating system;\n"
      fi
  done
}

install_vault() {
  id vault &>/dev/null || useradd --system --home ${VAULT_DATA_PATH} --shell /sbin/nologin vault
  curl -O --continue-at - https://releases.hashicorp.com/vault/${VAULT_CURRENT_VERSION}/vault_${VAULT_CURRENT_VERSION}_linux_amd64.zip
  echo -e "\n"
  unzip -o vault_${VAULT_CURRENT_VERSION}_linux_amd64.zip
  mkdir -p ${VAULT_CONFIG_PATH} ${VAULT_DATA_PATH}
  mv vault ${VAULT_BIN_PATH}
  cp ./properties/config/config.hcl ${VAULT_CONFIG_PATH}
  cp ./properties/systemd/vault.service ${VAULT_SYSTEMD_PATH}
  chown vault:vault -R ${VAULT_DATA_PATH} ${VAULT_CONFIG_PATH}
  systemctl daemon-reload
  systemctl start vault
  systemctl enable vault
  echo -e '\nOutput the Vault status in system:\n'
  systemctl status vault
  echo -e '\n✅ Vault is already installed:
    Current version is '${VAULT_CURRENT_VERSION}'
    Data Path – /opt/vault/data/;
    Config Path – /etc/vault.d/;
    Systemd Path – /etc/systemd/system/;'
}

setup_on_rpm_autocomplete() {
  if ! grep -q 'complete -C .*/vault vault' "$VAULT_COMPLETION_RPM" 2>/dev/null; then
      echo "complete -C $VAULT_BIN_PATH/vault vault" | tee -a "$VAULT_COMPLETION_RPM" > /dev/null
      echo "export VAULT_ADDR="$VAULT_ADDR"" | tee -a "$VAULT_COMPLETION_RPM" > /dev/null
      echo -e "\n✅ Autocomplete added to $VAULT_COMPLETION_RPM"
  else
      echo -e "\n✅ Autocomplete has already been added to $VAULT_COMPLETION_RPM"
  fi
}

setup_on_deb_autocomplete() {
  if ! grep -q 'complete -C .*/vault vault' "$VAULT_COMPLETION_DEB" 2>/dev/null; then
      echo "complete -C $VAULT_BIN_PATH/vault vault" | tee -a "$VAULT_COMPLETION_DEB" > /dev/null
      echo "export VAULT_ADDR="$VAULT_ADDR"" | tee -a "$VAULT_COMPLETION_DEB" > /dev/null
      echo -e "\n✅ Autocomplete added to $VAULT_COMPLETION_DEB"
  else
      echo -e "\n✅ Autocomplete has already been added to $VAULT_COMPLETION_DEB"
  fi
}

run_based_on_distro() {
  distro=$(cat /etc/os-release | grep ^ID= | cut -d'=' -f2)

  if [[ "$distro" =~ "ubuntu" || "$distro" =~ "debian" ]]; then
    echo -e "\n✅ Debian family distribution. Install Vault...\n"
    check_requirements
    install_vault
    setup_on_deb_autocomplete

  elif [[ "$distro" =~ "centos" || "$distro" =~ "rhel" || "$distro" =~ "fedora" ]]; then
    echo -e "\n✅ RedHat family distribution. Install Vault...\n"
    check_requirements
    install_vault
    setup_on_rpm_autocomplete
    chcon -R -t bin_t ${VAULT_BIN_PATH}/vault
    chcon -R -t etc_t ${VAULT_CONFIG_PATH}
    systemctl restart vault

  elif [[ "$distro" =~ "sles" || "$distro" =~ opensuse* ]]; then
    echo -e "\n✅ SUSE family distribution. Install Vault...\n"
    check_requirements
    install_vault
    setup_on_rpm_autocomplete

  else
    echo "Undefined distribution: $distro. Installation aborted..."
  fi
}

eval set -- "$OPTIONS"
while :
do
  case "$1" in
    -s | --set-version)
      VAULT_CURRENT_VERSION="$2"
      shift 2
      ;;
    -l | --list-version)
      list_vault_versions
      shift
      ;;
    -h | --help)
      help
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

run_based_on_distro
