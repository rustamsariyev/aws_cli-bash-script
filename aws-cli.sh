#!/bin/bash 
# 
# This script automates the "AWS CLI" installation process all Linux/Unix distros.

# Set color variables

RED='\033[0;31m'                    # RED Color
GREEN='\033[0;32m'                  # GREEN Color
NC='\033[0m'                        # No Color

# Checking current user root or not. If user not root "please run as root". 

if [[ "$EUID" -ne 0 ]]; then
   printf "${RED}Error:${NC} Please run as "root".\n"
   exit 1;
else
   printf "${GREEN}Success:${NC} User is "root".\n"
fi


# First, we need to check our Linux/Unix distro.
# Variables 

PATH="/usr/local/bin:$PATH"                     # Adding the new "PATH"

YUM_PM="$(which yum 2>/dev/null)"               # Centos/REHL "Package Manager"
PKG_PM="$(which pkg 2>/dev/null)"               # Solaris "Package Manager" 
BREW_PM="$(which brew 2>/dev/null)"             # MacOS "Package Manager"
APT_GET_PM="$(which apt-get 2>/dev/null)"       # Ubuntu "Package Manager"
DNF_PM="$(which dnf 2>/dev/null)"               # Red Hat "Package Manager"
ZYPPER_PM="$(which zypper 2>/dev/null)"         # Suse "Package Manager"


PY_BIN="$(which python 2>/dev/null)"            # Python executable file location check
PY_VER_CK="$(python --version > py_version.txt 2>&1 && grep -i python py_version.txt | awk '{print $2}')"     # Python Version check
AWS_CLI_BIN="$(which aws 2>/dev/null)"          # aws-cli executable file location check
UNZIP_STAT="$(which unzip 2>/dev/null)"         # unzip executable file location check    
AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}')"      # AWS_CLI Version check
AWS_CLI_VER_NUM="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk -F '.' '{print $1}' | awk -F "/" '{print $2}')"
UNZIP_PG="unzip"                  # Zip and unzip package for unzipping AWS_CLI bundle



# Function for unzip package

function UNZIP_FUNC () {
   # First, we are using "IF" statement for checking which Package Manager of the Linux/Unix distros later install unzip package.

if [[ ! -z $YUM_PM ]]; then
    yum install $UNZIP_PG  -y  > /dev/null 2>&1
 elif [[ ! -z $BREW_PM ]]; then
    brew install -y $UNZIP_PG  > /dev/null 2>&1
 elif [[ ! -z $PKG_PM ]]; then
    pkg install $UNZIP_PG -y  > /dev/null 2>&1
 elif [[ ! -z $APT_GET_PM ]]; then
    apt-get update && apt-get install $UNZIP_PG -y > /dev/null 2>&1
 elif [[ ! -z $DNF_PM ]]; then
    dnf install $UNZIP_PG -y > /dev/null 2>&1
 elif [[ ! -z $ZYPPER_PM ]]; then
    zypper install -y $UNZIP_PG  > /dev/null 2>&1
 else
    printf "${RED}Error:${NC} "unzip" package can't be able to install.\n"
    exit 1;
    set -e                                   # If exit 1 stop script execution
 fi
}



# Function for install the aws_cli version 1

function AWS_CLI_VER_1_IN () {

curl -s "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" 
unzip -o -q awscli-bundle.zip                                           
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws  > /dev/null

AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}' )"      # AWS_CLI Version
printf "${GREEN}AWS_CLI new installed version:${NC} ${AWS_CLI_VER_CK}\n"  
# Clear AWS_CLI downloaded and unzipped files.
sudo rm -rf awscli-bundle awscli-bundle.zip aws_version.txt py_version.txt
}


# Function for install the aws_cli version 2 
function AWS_CLI_VER_2_IN () {

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  
unzip -o -q awscliv2.zip
./aws/install -i /usr/local/aws-cli -b /usr/local/bin   > /dev/null

AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}' )"      # AWS_CLI Version
printf "${GREEN}AWS_CLI new installed version:${NC} ${AWS_CLI_VER_CK}\n"  

# Clear AWS_CLI downloaded and unzipped files.
sudo rm -rf aws awscliv2.zip aws_version.txt py_version.txt

}


# Function for install the aws_cli version 2 on macOS

function AWS_CLI_VER_2_MAC_IN () {
 
curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
installer -pkg AWSCLIV2.pkg -target /

AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}' )"      # AWS_CLI Version
printf "${GREEN}AWS_CLI new installed version:${NC} ${AWS_CLI_VER_CK}\n"  

# Clear AWS_CLI downloaded file.
rm -rf AWSCLIV2.pkg  aws_version.txt py_version.txt

}


# Function for upgrade the aws_cli version 1 to 2 on Linux OS

function AWS_CLI_UP2_IN () {

if [[ ! -z "${AWS_CLI_BIN}" ]] && [[ "$AWS_CLI_VER_NUM" -eq "1" ]] ; then

    # First, we need to remove "aws cli" version 1
    rm -rf /usr/local/aws
    rm /usr/local/bin/aws 

elif  [[ ! -z "${AWS_CLI_BIN}" ]] && [[ "$AWS_CLI_VER_NUM" != "1" ]]; then 
    printf "${RED}Error:${NC} You can't upgrade the AWS CLI version because there was installed an upgraded aws version 2...\n"
    exit 1
    set -e                                   # If exit 1 stop script execution
else
    printf "${RED}Error:${NC} You can't upgrade the AWS CLI version because there wasn't installed "aws" package. Install the desired "aws" version...\n"
    exit 1
    set -e                                   # If exit 1 stop script execution
fi

# Install "aws cli" version 2
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  
unzip -o -q awscliv2.zip
./aws/install -i /usr/local/aws-cli -b /usr/local/bin   > /dev/null

AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}' )"      # AWS_CLI Version
printf "${GREEN}AWS_CLI new installed version:${NC} ${AWS_CLI_VER_CK}\n"  

# Clear AWS_CLI downloaded and unzipped files.
sudo rm -rf aws awscliv2.zip aws_version.txt py_version.txt

}

# Function for upgrade the aws_cli version 1 to 2 on macOS

function AWS_CLI_MAC_UP2_IN () {

if [[ ! -z "${AWS_CLI_BIN}" ]] && [[ "$AWS_CLI_VER_NUM" -eq "1" ]] ; then

    # First, we need to remove "aws cli" version 1
    rm -rf /usr/local/aws
    rm /usr/local/bin/aws 

elif  [[ ! -z "${AWS_CLI_BIN}" ]] && [[ "$AWS_CLI_VER_NUM" != "1" ]]; then 
    printf "${RED}Error:${NC} You can't upgrade the AWS CLI version because there was installed an upgraded aws version 2...\n"
    exit 1
    set -e                                   # If exit 1 stop script execution
else
    printf "${RED}Error:${NC} You can't upgrade the AWS CLI version because there wasn't installed "aws" package. Install the desired "aws" version...\n"
    exit 1
    set -e                                   # If exit 1 stop script execution
fi

# Install "aws cli" version 2
curl -s "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
installer -pkg AWSCLIV2.pkg -target /

AWS_CLI_VER_CK="$(/usr/local/bin/aws --version > aws_version.txt 2>&1 && grep aws-cli aws_version.txt | awk '{print $1}' )"      # AWS_CLI Version
printf "${GREEN}AWS_CLI new installed version:${NC} ${AWS_CLI_VER_CK}\n"  

# Clear AWS_CLI downloaded file.
rm -rf AWSCLIV2.pkg  aws_version.txt py_version.txt

}



# Function for uninstall the aws_cli version 1

function AWS_CLI_VER_1_UN () {

# Uninstall the AWS CLI version 1 bundled installer
rm -rf /usr/local/aws
rm /usr/local/bin/aws

printf "${GREEN}Success:${NC} AWS CLI Version 1 uninstalled.\n"

}

# Function for uninstall the aws_cli version 2

function AWS_CLI_VER_2_UN () {

# Delete the two symlinks in the --bin-dir directory
rm /usr/local/bin/aws
rm /usr/local/bin/aws_completer

# Delete the --install-dir directory.
rm -rf /usr/local/aws-cli

printf "${GREEN}Success:${NC} AWS CLI Version 2 uninstalled.\n"

}


# Function for uninstall the aws_cli version 2

function AWS_CLI_VER_2_MAC_UN () {

# Delete the two symlinks in the --bin-dir directory
rm /usr/local/bin/aws
rm /usr/local/bin/aws_completer

# Delete the --install-dir directory.
rm -rf /usr/local/aws-cli

printf "${GREEN}Success:${NC} AWS CLI Version 2 uninstalled.\n"

}


# Checking python package available(intsalled) or not.

if [[ ! -z "${PY_BIN}" ]]; then
   printf "${GREEN}Python current version:${NC} ${PY_VER_CK}\n"
else
   printf "${RED}Error:${NC} Please, install required Python 2.7, Python 3.4, or a later version.\n"
   exit 1
   set -e                                   # If exit 1 stop script execution
fi


# Checking aws-cli package available(intsalled) or not.

if [[ ! -z "${AWS_CLI_BIN}" ]]; then
   printf "${GREEN}AWS_CLI current version:${NC} ${AWS_CLI_VER_CK}\n"
   rm -rf aws_version.txt py_version.txt
else
   printf "${RED}Error:${NC} AWS_CLI not installed.\n"
   rm -rf aws_version.txt py_version.txt
fi


# Checking unzip package available(intsalled) or not.

if [[ ! -z ${UNZIP_STAT} ]] ; then
   printf "${GREEN}Success:${NC} "unzip" package has been installed.\n"
else
   printf "${RED}Error:${NC} "unzip" package has not been installed.\n"
   printf "${GREEN}Starting:${NC} "unzip" package installation starting...\n"
   UNZIP_FUNC     > /dev/null 2>&1                # Function for install unzip package              
fi


# Display desired AWS CLI version installation and uninstallation.
echo '==========================================================================================='

printf "1) Install AWS CLI Version 1 : Please write input  ${GREEN}1${NC}  press Enter.\n"
printf "2) Install AWS CLI Version 2 : Please write input  ${GREEN}2${NC}  press Enter.\n"
printf "3) Install AWS CLI Version 2 for macOS : Please write input  ${GREEN}m2${NC}  press Enter.\n"
echo '==========================================================================================='
printf "4) ${RED}Notice:${NC} If you want to upgrade installed current AWS CLI version 1 to 2 for Linux OS; Please write input  ${GREEN}up2${NC}  press Enter.\n"
printf "5) ${RED}Notice:${NC} If you want to upgrade installed current AWS CLI version 1 to 2 for macOS; Please write input  ${GREEN}upm2${NC}  press Enter.\n"
printf "6) Uninstall AWS CLI Version 1 : Please write input  ${GREEN}un1${NC}  press Enter.\n"
printf "7) Uninstall AWS CLI Version 2 : Please write input  ${GREEN}un2${NC}  press Enter.\n"
printf "8) Uninstall AWS CLI Version 2 for macOS : Please write input  ${GREEN}unm2${NC}  press Enter.\n"
printf "9) If you want to stop the script : Please write input  ${GREEN}q${NC}  press Enter.\n"

echo '==========================================================================================='

read -p 'Please enter the desired input for the AWS CLI version install or uninstall:' VERSION

# Using the "case" statement for install and uninstall the desired aws_cli version

case $VERSION
in
    1) printf "aws-cli-ver-1 installing starting...\n"; AWS_CLI_VER_1_IN ;;
    2) printf "aws-cli-ver-2 installing starting...\n"; AWS_CLI_VER_2_IN ;;
    m2) printf "aws-cli-ver-2 macOS installing starting...\n"; AWS_CLI_VER_2_MAC_IN ;;
    up2) printf "aws-cli-ver-1 upgrading to aws-cli-ver-2 for Linux...\n"; AWS_CLI_UP2_IN ;;
    upm2) printf "aws-cli-ver-1 upgrading to aws-cli-ver-2 for macOS...\n"; AWS_CLI_MAC_UP2_IN;;
    un1) printf "aws-cli-ver-1 uninstalling...\n"; AWS_CLI_VER_1_UN ;;
    un2) printf "aws-cli-ver-2 uninstalling...\n"; AWS_CLI_VER_2_UN ;;
    unm2) printf "aws-cli-ver-2 for macOS uninstalling...\n"; AWS_CLI_VER_2_MAC_UN ;;
    q) printf "The script stopped.\n" 
       exit;;
    *) printf "Error: Nothing selected from the listbox...\n"
       exit ;;
esac
