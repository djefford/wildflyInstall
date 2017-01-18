#!/bin/sh
############################################################
# Author: Dustin Jefford
# 
# Description: Installs, patches, and configures Wildfly 8.x
#
############################################################

# Source support files
source ./utilities.sh 
source ./parameters

# Verify JAVA_HOME
if [ -z $JAVA_HOME ]; then
	JAVA_HOME=/usr/bin/java
fi

# Formatting values
title="WildflyInstall" 					# String used in log messages related to full script.
divider=`printf '=%.s' {1..40} ; echo`	# Prints dividing line of "=" in logging output.


echo $divider
printf " %s\n" "Starting $title Script..."
echo $divider

# Create initial directory structure.
printf " %s\n" "Verifying and creating directory structure."
echo $divider ; sleep 2

createDirectoryStructure $HOME_DIR $LOGS_DIR $DEV_HOME

echo $divider

# Verify Java installation.
printf " %s\n" "Verifying Java installation at ${JAVA_HOME}"
echo $divider ; sleep 2

verifyJava $JAVA_HOME

echo $divider

# Deploy JBoss
printf " %s\n" "Deploying Wildfly from ${MAIN_MEDIA} to ${SOFTWARE_HOME}"
echo $divider ; sleep 2

# InstallWildfly takes 2 arguments "MAIN_MEDIA" and "SOFTWARE_HOME"
installWildfly $MAIN_MEDIA $SOFTWARE_HOME

echo $divider


wildfly_dir=$(ls ${SOFTWARE_HOME} | grep -o "wildfly-[0-9]\.[0-9]\..*")		# Wildfly directory
wildfly_home=${SOFTWARE_HOME}/${wildfly_dir}								# Wildfly Home, full path

# Create SSL vaults - keystore.jks, and vault.jks
printf " %s\n" "Creating SSL keystores (keystore.jks and vault.jks)."
echo $divider ; sleep 2

# Create java keystore for wildfly.
genKeystore keystore.jks ${HOSTNAME} ${wildfly_home}/ssl

echo $divider

# Create vault keystore for wildfly
genKeystore vault.jks vault ${wildfly_home}/ssl

echo $divider

# Configure Vault.
printf " %s\n" "Configuring vault."
echo $divider ; sleep 2

# Read in vault password.
read -s -p " Please provide vault keystore password: " vault_pass
printf "\n"
echo $divider
read -s -p " Please provide java keystore password: " keystore_pass

# Add default keystore information to vault.
vaultAddItem ${wildfly_home} ${wildfly_home}/${VAULT_ENC_FILE_DIR} ${wildfly_home}/ssl/vault.jks "${vault_pass}" "$VAULT_SALT" $VAULT_ALIAS $VAULT_ITERATION_COUNT javaKeystorePwd javaKeystore $keystore_pass add


# Verify input and capture masked password.
printf " %s\n" "Verifying attribute exists in vault."
masked=`vaultAddItem ${wildfly_home} ${wildfly_home}/${VAULT_ENC_FILE_DIR} ${wildfly_home}/ssl/vault.jks "${vault_pass}" "$VAULT_SALT" $VAULT_ALIAS $VAULT_ITERATION_COUNT javaKeystorePwd javaKeystore $keystore_pass check | grep -o "\"MASK-.*\""`


echo $divider

# Substitue variables and configure wildfly.
printf " %s\n" "Updating configuration files with custom variables."
echo $divider ; sleep 2

printf " %s\n" "Moving ${INSTALL_TYPE} files to working directory..."
echo $divider ; sleep 2

cp -r ./${INSTALL_TYPE} ./working

for file in `ls ./working`; do

	file_loc="./working/$file"

	printf " %s\n" "Updating ${file_loc}..."

	replaceVar "{{JAVA_HOME}}" "$JAVA_HOME" "$file_loc"
	replaceVar "{{WILDFLY_HOME}}" "${wildfly_home}" "$file_loc"
	replaceVar "{{WILDFLY_USER}}" "$WILDFLY_USER" "$file_loc"
	replaceVar "{{LOGS_DIR}}" "$LOGS_DIR" "$file_loc"
	
done

printf " %s\n" "Setting up configuration file in ${wildfly_home}/bin/standalone."
mkdir ${wildfly_home}/bin/standalone
cp ./working/wildfly.conf ${wildfly_home}/bin/standalone

printf " %s\n" "Completed setting up ${wildfly_home}/bin/standalone."



