#!/bin/bash
#set -ex
usage() {
    echo "usage: $(basename $0) --sd <solution definition file name> "
    exit 1;
}

while (( "$#" )); do
    case $1 in
        --sd ) 
           solution_def_file=$2 
           shift
           ;;
        * )
        break ;;
    esac
    shift
done

echo "solution definition file="$solution_def_file
solution_args=$@

SERVICE_HOME_DIR=services

install_service(){
	service_name=$1
        dep_service="$2"
	bd_ip=$3
	bd_user=$4
	service_arg1=$5
	service_arg2=$6
	service_arg3=$7
	server=root@$bd_ip
        
        if [ "$dep_service" != "none" ] ; then
           for i in $dep_service
               do
	        scp -qr $SERVICE_HOME_DIR/$i $server:~/.
              	ssh $server "$i/install.sh $bd_user  $solution_args" < /dev/null
               	ssh $server "$i/config.sh $service_arg1 $service_arg2 $service_arg3 $bd_user $solution_args" < /dev/null
               done
	fi

	scp -qr $SERVICE_HOME_DIR/$service_name $server:~/.
	ssh $server "$service_name/install.sh $bd_user $solution_args" < /dev/null
	ssh $server "$service_name/config.sh $service_arg1 $service_arg2 $service_arg3 $bd_user $service_name $solution_args" < /dev/null
	ssh $server "$service_name/start.sh $bd_user " < /dev/null
        echo "*** Service $service_name status: ***"
	ssh $server "$service_name/status.sh $bd_user " < /dev/null
	scp -q common/* $server:~/$service

}

while IFS=',' read -r f1 f2 f3 f4 f5 f6 f7
do 
  ## Ignore lines start with "#"
  case $f1 in
        \#*) continue;;
        "") continue;;
  esac
  echo "************************************** "
  echo "Service Name="$f1
  echo "  Required Service="$f2
  echo "  Service Location="$f3
  echo "  Service User Name="$f4
  echo "  arg1="$f5
  echo "  arg2="$f6
  echo "  arg3="$f7
  echo "************************************** "
  if [ -z "$f2" ]; then 
     f2="none"
  fi
install_service $f1 "$f2" $f3 $f4 $f5 $f6 $f7
done < "$solution_def_file"
./solution_status.sh --sd $solution_def_file

