#!/bin/bash

# Copyright 2015 Will Webberley
# Very simple script to manage a Minecraft server.
# 
# Needs a Java runtime, tmux to handle the process, wget to update, and tar to compress backups.
#
# Run with 'help' flag to see a list of available commands.

MINECRAFT_DIR="$HOME"

function start_server {
    printf "\nStarting new Minecraft server..."
    cd $MINECRAFT_DIR
    ./tmux new-session -s minecraft -n Minecraft -d > /dev/null 2>&1

    if [ ! $? -eq 0 ]; then
         printf "\nThere is already a Minecraft server running.\n\nRun 'minecraft stop' to stop it.\n\n"
	  exit
    fi
    sleep 2 # Wait for tmux login

    ./tmux send-keys -t minecraft "java -Xms128M -Xmx2192M -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -jar root/Minecraft_Mod.jar --log-limit=10000 nogui" C-m
    sleep 5 # Wait for world generation
    printf "\nMinecraft server started. Run 'minecraft help' for more commands.\n\n"
}

function start_spigot {
    printf "\nStarting new Minecraft Spigot server..."
    cd $MINECRAFT_DIR
    ./tmux new-session -s minecraft -n Minecraft -d > /dev/null 2>&1

    if [ ! $? -eq 0 ]; then
         printf "\nThere is already a Minecraft server running.\n\nRun 'minecraft stop' to stop it.\n\n"
	  exit
    fi
    sleep 2 # Wait for tmux login

    ./tmux send-keys -t minecraft "java -Xms128M -Xmx2192M -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -jar root/Minecraft_Mod.jar --log-limit=10000 nogui" C-m
    sleep 5 # Wait for world generation
    printf "\nMinecraft Spigot server started. Run 'minecraft help' for more commands.\n\n"
}

function stop_server {
    ./tmux send-keys -t minecraft "stop" C-m > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
        printf "\nMinecraft server has not been started.\nRun 'minecraft start' to begin.\n\n"
        exit
    fi
    printf "\nStopping server...\n"
    sleep 3 # Wait for server to halt
    ./tmux kill-session -t minecraft
    printf "\nStopped Minecraft server successfully.\n\n"
}

function restart_server {
    ./tmux send-keys -t minecraft "stop" C-m > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
        printf "\nMinecraft server has not been started.\nRun 'minecraft start' to begin.\n\n"
        exit
    fi

    printf "\nRestarting Minecraft server..."
    sleep 5 # Wait for server to stop
    ./tmux send-keys -t minecraft "java -Xms128M -Xmx2192M -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -jar root/Minecraft_Mod.jar --log-limit=10000 nogui" C-m
    printf "\nServer restarted successfully.\n\n"
}

function restart_spigot {
    ./tmux send-keys -t minecraft "stop" C-m > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
        printf "\nMinecraft server or Spigot server has not been started.\nRun 'minecraft start' to begin.\n\n"
        exit
    fi

    printf "\nRestarting Minecraft server..."
    sleep 5 # Wait for server to stop
    ./tmux send-keys -t minecraft "java -Xms128M -Xmx2192M -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -jar root/Minecraft_Mod.jar --log-limit=10000 nogui" C-m
    printf "\nServer restarted successfully.\n\n"
}

function manage_server {
    printf "\nJoining server session. Press ctrl-B-D to exit the session.\n"
    sleep 3
    ./tmux attach-session -t minecraft > /dev/null 2>&1
    if [ ! $? -eq 0 ]; then
         printf "\nMinecraft server has not been started.\nRun 'minecraft start' to begin.\n\n"
    fi
}

function update_server {
    cd $MINECRAFT_DIR
    printf "\nAuto-discovering latest Minecraft server version... "
    version_line=$(wget -q -O- https://s3.amazonaws.com/Minecraft.Download/versions/versions.json | grep -oP "\"release\": ?\"[0-9]\.[0-9]\.[0-9]\"")
    version=$( echo "$version_line" | grep -oP "[0-9]\.[0-9]\.[0-9]" )
    printf "Done.\n$version is the latest version."
    printf "\n\nBacking up old server... "
    date=$(date +"%y-%m-%d-%T")
    mkdir old_minecraft_servers > /dev/null 2>&1
    mv minecraft_server.jar "old_minecraft_servers/$date-server.jar" > /dev/null 2>&1
    printf "Done.\nOld server backed up to: 'old_minecraft_servers/$date-server.jar"
    printf "\n\nDownloading Minecraft server version $version... (Press ctrl-C to cancel)\n\n"    
    sleep 2
    wget "https://s3.amazonaws.com/Minecraft.Download/versions/$version/minecraft_server.$version.jar" -O "minecraft_server.jar"
    printf "\nMinecraft server $version installed successfully.\nRun 'minecraft restart' to restart the server if it already running.\n\n"
}

function update_spigot {
    cd $MINECRAFT_DIR
    declare response
    printf "\nUpdating Spigot server.\n\n"
    read -p "Enter a Spigot server version to install (e.g. for 1.8, enter '18'): " response
    printf "\nDownloading Spigot server..."
    date=$(date +"%y-%m-%d-%T")
    mkdir old_minecraft_servers > /dev/null 2>&1
    mv spigot_server.jar "old_minecraft_servers/$date-spigot-server.jar" > /dev/null 2>&1

    wget "http://getspigot.org/spigot$response/spigot_server.jar" -O "spigot_server.jar"
    printf "\nSpigot installation finished. Any errors will be reported above.\n\n"
}

function agree_eula {
    cd $MINECRAFT_DIR
    declare response
    printf "A copy of the Minecraft EULA is available here: https://account.mojang.com/documents/minecraft_eula.\n"
    read -p "Do you agree to the Minecraft EULA? (y/n): " response
    if [ $response == "y" -o $response == "Y" ]; then
        printf "# This license agreement was agreed to when installed.\neula=true" > eula.txt
        printf "\n\nYou have agreed to the Minecraft EULA.\n"
    else
        printf "# This license agreement was not agreed to when installed.\neula=false" > eula.txt
        printf "\n\nWARNING: You have not agreed to the Minecraft EULA. The server will not launch properly until you do.\nTo agree to the EULA, run 'minecraft eula'.\n"
    fi
}

function install_server {
    printf "\nInstalling Minecraft server...\n"
    update_server
    agree_eula
    printf "\nInstallation successful.\n\n"
}

function install_spigot {
    printf "\nInstalling Minecraft Spigot server...\n\n"
    update_spigot
    printf "\nIf the installation was successful, you may need to agree to the EULA by running 'minecraft eula'.\n\n"
}

function backup {
    printf "\nStarting world and settings backup..."
    cd $MINECRAFT_DIR
    mkdir backups > /dev/null 2>&1
    date=$(date +"%y-%m-%d-%T")
    tar -czf "backups/$date.tar.gz" --exclude=backups --exclude=old_minecraft_servers ./* 
    printf "\nWorld and server backed-up to file: 'backups/$date.tar.gz'\n\n"
}

function install_spigot_plugin {
    cd $MINECRAFT_DIR
    printf "\nAdding Spigot plugins.\n\n"
    mkdir plugins > /dev/null 2>&1
    declare response
    read -p "Enter the URL of the plugin file to be installed (JAR or ZIP. ZIP files will be automatically decomprssed): " response
    cd plugins
    wget $response
    if [[ $response == *".zip" ]]; then
      unzip *.zip
      rm *.zip
    fi
    printf "\n\nInstallation finished. Any errors will be reported above.\n"
    printf "If the installation succeeded, you may need to restart the Spigot server by running 'minecraft spigot restart'.\n"
}

function list_spigot_plugins {
    printf "\nInstalled plugin files and directories:\n"
    ls ~/plugins
}

function uninstall_spigot_plugin {
    list_spigot_plugins
    declare response
    read -p "Enter the name of the plugin to uninstall (you can use wildcards, e.g.: 'Essentials*'): " response
    rm -rf "~/plugins/$response"
    printf "\nPlugin uninstallation finished. You may need to restart the Spigot server for the uninstallation to have an effect.\n" 
}

function show_help {
    printf "\nYou can run this program with the following commands.\n\n"
    printf "\n-----------------------------------------------------\n"
    printf "The below options refer to vanilla Minecraft server installations:"
    printf "\n-----------------------------------------------------\n\n"
    printf "help\n"
    printf "\tShow this help text.\n\n"
    printf "start\n"
    printf "\tStart a new Minecraft server.\n\n"
    printf "stop\n"
    printf "\tSafely stop the Minecraft server (if running).\n\n"
    printf "restart\n"
    printf "\tSafely restart the Minecraft server (if running).\n\n"
    printf "manage\n"
    printf "\tJoin the server console to administer. Press ctrl-B-D to leave.\n\n"
    printf "backup\n"
    printf "\tBacks-up and compresses the current Minecraft world and settings.\n\n"
    printf "update\n"
    printf "\tUpdates the Minecraft server to the latest version.\n\n"
    printf "install\n"
    printf "\tInstalls the latest Minecraft server version.\n\n"
    printf "eula\n"
    printf "\tAgree or disagree to the Minecraft EULA. You need to agree to this for the server to work correctly.\n\n"
    printf "\n----------------------------------------------------\n"
    printf "The below options refer to Spigot Minecraft server installations:"
    printf "\n----------------------------------------------------\n\n"
    printf "spigot start\n"
    printf "\tStart a new Spigot server.\n\n"
    printf "spigot stop\n"
    printf "\tStop the Minecraft or Spigot server.\n\n"
    printf "spigot restart\n"
    printf "\tSafely restart the Spigot server (if this or vanilla Minecraft is running).\n\n"
    printf "spigot update\n"
    printf "\tUpdate the Spigot server to a custom version.\n\n"
    printf "spigot install\n"
    printf "\tInstall the Spigot server.\n\n"
    printf "spigot install-plugin\n"
    printf "\tInstall a Spigot plugin.\n\n"
    printf "spigot list-plugins\n"
    printf "\tSee all installed Spigot plugins.\n\n"
    printf "spigot uninstall-plugin\n"
    printf "\tUninstall a Spigot plugin.\n\n"
    printf "\n----------------------------------------------------\n"
    printf "Commands like 'eula', 'backup', and 'manage' can be used for vanilla or Spigot installs."
    printf "\n----------------------------------------------------\n"
}


case "$1" in
    start)   start_server;;
    stop)    stop_server;;
    manage)  manage_server;;
    update)  update_server;;
    install) install_server;;
    backup)  backup;;
    restart) restart_server;;
    eula)    agree_eula;;
    help)    show_help;;
    spigot)
      case "$2" in
        start)    start_spigot;;
        stop)     stop_server;;
        restart)  restart_spigot;;
        update)   update_spigot;;
        install)  install_spigot;;
        install-plugin)  install_spigot_plugin;;
        list-plugins)    list_spigot_pluigns;;
        uninstall-plugin) uninstall_spigot_plugin;;
      esac
esac
