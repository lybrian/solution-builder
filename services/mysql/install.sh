#!/bin/bash
SERVICE_NAME=$1
BD_USER=$2
arg1=$3
arg2=$4
arg3=$5
solution_args=$6
SQL_ROOT_PASSWRD=$solution_args

log=`pwd`/logs/hadoop_cluster_utils_$current_time.log
echo -e | tee -a $log

echo $SQL_ROOT_PASSWRD
export LC_ALL=C
service_name=$SERVICE_NAME-installed
if [ -f $service_name ]; then
        exit
fi
UBUNTU=`cat /etc/*-release | grep ubuntu`
#################### Add installation steps here ######

if [ ! -z "$UBUNTU" ]; then
  	echo "Setting up mysql"
  	python -mplatform  |grep -i redhat >/dev/null 2>&1
  	# Ubuntu
	if [ $? -ne 0 ]; then
	  	dpkg -l | grep mysql >/dev/null 2>&1
	  	if [ $? -ne 0 ]; then
	  		sudo apt-key update
	  		sudo apt-get -y update
	  		sudo apt-get -y dist-upgrade
	  		dpkg -S /usr/bin/mysql
	  		if [ $? -ne 0 ]; then
	  			sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password passw0rd'
				sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password passw0rd'
	  			sudo apt-get -y install mysql-server --force-yes
	  			sudo apt-get -y install mysql-client --force-yes
	  		fi
	  	else
	  		echo "mysql is already installed"
	  	fi 
	  	if [ ! -f /usr/share/java/mysql-connector-java.jar ]
		then
			sudo apt-get -y install libmysql-java --force-yes
		else
			echo "mysql connector is installed already"
	  	fi

	  	sudo netstat -tap | grep mysql >/dev/null 2>&1
	  	if [ $? -ne 0 ]
			then
				sudo systemctl restart mysql.service
				sudo netstat -tap | grep mysql
				if [ $? -ne 0 ]
				then
					echo "Failed to start mysql"
					exit 255
				fi
			fi
		fi
	fi
else
	# RedHat
	mdb=0
	for i in mariadb mariadb-server mariadb-libs
	do
		rpm -qa | grep $i >/dev/null 2>&1
		if [ $? -ne 0 ]; then
		mdb=1
		fi
	done
			
	if [ $mdb -ne 0 ]; then
		sudo yum -y install mariadb mariadb-server mariadb-libs >/dev/null 2>&1
		sudo systemctl start mariadb.service
		sudo systemctl enable mariadb.service

		rpm -qa | grep expect >/dev/null 2>&1
		if [ $? -ne 0 ] ; then
			sudo yum -y install expect >/dev/null 2>&1
		fi

		MYSQL=passw0rd

		echo "Setting mysql root password to MYSQL
		SECURE_MYSQL=$(expect -c "
		set timeout 10
		spawn mysql_secure_installation
		expect \"Enter current password for root (enter for none):\"
		send \"\r\"
		expect \"Set root password?\"
		send \"y\r\"
		expect \"New password:\"
		send \"$MYSQL\r\"
		expect \"Re-enter new password:\"
		send \"$MYSQL\r\"
		expect \"Remove anonymous users?\"
		send \"y\r\"
		expect \"Disallow root login remotely?\"
		send \"y\r\"
		expect \"Remove test database and access to it?\"
		send \"y\r\"
		expect \"Reload privilege tables now?\"
		send \"y\r\"
		expect eof
		")

					
	else
		echo "mysql is already installed" 
	fi

	if [ ! -f /usr/share/java/mysql-connector-java.jar ]
	then
		sudo sudo yum -y install mysql-connector-java
	else
		echo "mysql connector is installed already" 
	fi
fi
	
#####################################################
touch $service_nameok
