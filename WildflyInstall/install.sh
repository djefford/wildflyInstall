#!/bin/sh
############################################################
# Author: Dustin Jefford
# 
# Description: Installs Red Hat JBoss EAP 7.x
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
divider=`printf '=%.s' {1..40} ; echo`


echo $divider
printf " %s\n" "Starting $title Script..."
echo $divider

# Create initial directory structure.
printf " %s\n" "Verifying and creating directory structure."
echo $divider
sleep 2

createDirectoryStructure $HOME_DIR $LOGS_DIR $DEV_HOME

echo $divider

# Verify Java installation.
printf " %s\n" "Verifying Java installation at ${JAVA_HOME}"
echo $divider
sleep 2

verifyJava $JAVA_HOME

echo $divider
