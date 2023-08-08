#!/bin/bash

# Get the hostname of the system
host_name=$(hostname)
count_limit=12
# Get the count of active containers using container names
# container_count=$(docker ps -q | wc -l)
container_count=$(docker ps --format "table {{.Names}}" | wc -l)

# Delete old tar files
find /tmp/ -type f -name "*$hostname.tar" -mtime +1 -exec rm -rf {} \;

# Loop for each container
# first docker ps output is column name, because of this, loop is from 2
for ((i=2; i<=$container_count; i++)); do
    
    # Extract container name 
    container_name=$(docker ps --format "table {{.Names}}" | sed -n "${i}p")


    # Combine the date/time and hostname
    current_datetime=$(date +"%Y%m%d_%H:%M:%S")


    result="$host_name""_""${current_datetime}""_""${container_name}.tar"
    #export container as a tar file in /tmp/ 
    docker export $container_name >/tmp/$result


    # Count the number of exported files
    count=$(ls -l /tmp/*"$container_name".tar | wc -l )


    # If count exceeds the 12, delete the oldest file(s)
    if (( count > count_limit )); then
        num_files_to_delete=$(( count - count_limit ))

        oldest_files=$(ls -1t  /tmp/*"$container_name".tar | tail -n "$num_files_to_delete" | cut -d" " -f 10)
        rm $oldest_files
    fi


    #sleep 1h  # Sleep for one hour before exporting again



done

