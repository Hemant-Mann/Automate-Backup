#!/bin/bash

# Initialize Global Variables
db_name=
mysql_root=
server_ip=
server_user=
server_pass=
server_path=
project=
project_dir=

# Read the values parsed from json file
read -p "DB Name: " db_name
read -p "Mysql root pass: " mysql_root
read -p "Project: " project
read -p "Project Dir: " project_dir

read -p "Backup Server IP: " server_ip
read -p "Backup Server User-pass: " server_pass
read -p "Backup Server path: " server_path # path can be relative to user or full-path 
# path should exist on remote server otherwise error will be thrown
read -p "Backup Server User: " server_user


# Check for expect
type expect 2> /dev/null || { sudo apt-get install -y expect; }

cd $project_dir

# Take a backup of mysql database if db exists
backup_mysql() {
	if [[ ! $db_name ]]; then
		return 1;
	fi
	mysqldump -u root -p${mysql_root} ${db_name} > ${db_name}.sql
}

# Make a compressed tar file of the project
make_tar() {
	cd ..
	tar -cvzf ${project}.tar ${project_dir##*/}
	rm $project_dir/${db_name}.sql
	cd $project_dir
}

# Push the backup tar to the remote server using "expect"
push_backup() {
	expect -c "
		set timeout -1
		spawn scp -o StrictHostKeyChecking=no ../${project}.tar ${server_user}@${server_ip}:${server_path}
		expect password: { send $server_pass\r }
		expect '100%'
		sleep 1
		exit
	"
	rm ../${project}.tar
}

# Log the backup process
logging() {
	output=`date`
	filename="`date +%Y-%m-%d`.txt"
	mkdir -p ~/backup_logs
	touch ~/backup_logs/$filename
	echo "Backup: '$project' (Server: $server_ip, path: $server_path) Completed on $output" >> ~/backup_logs/$filename
}

backup_mysql
make_tar
push_backup
logging
