#!/bin/bash
usage() {
    echo "usage: $(basename $0) --sd <solution definition file name> --spark-version <spark version>"
    echo "    where:"
    echo "        <spark version> is one of [\"1.6.2\", \"2.1\"]"
    exit 1;
}

while [ ! -z $4 ]; do
    case "$1" in
        --sd ) solution_def_file=$2 ;;
        * ) usage ;;
    esac
    case "$3" in
        --spark-version ) SPARK_VERSION=$4 ;;
        * ) usage ;;
    esac
    shift
done
echo "solution definition file="$solution_def_file
echo "spark version = "$SPARK_VERSION
if [ -z $SPARK_VERSION ] || [ -z $solution_def_file ]; then
    usage
fi

remove_service(){
	service_name=$1
        dep_service=$2
	bd_ip=$3
	bd_user=$4
	namenode=$5
	resourcemanager=$6
	sparkmaster=$7
	server=root@$bd_ip
        

	ssh $server "$service_name/stop.sh" < /dev/null
	ssh $server "$service_name/cleanup.sh" < /dev/null
	ssh $server rm -rf $service_name
    if [ ! -z $dep_service ] ; then
              	ssh $server "$dep_service/stop.sh" < /dev/null
               	ssh $server "$dep_service/cleanup.sh" < /dev/null        	
	 fi
}

while IFS=',' read -r f1 f2 f3 f4 f5 f6 f7
do 
  ## Ignore lines start with "#"
  case $f1 in
        \#*) continue;;
  esac
  echo "************************************** "
  echo "Service Name="$f1
  echo "  Required Service="$f2
  echo "  Service Location="$f3
  echo "  Service User Name="$f4
  echo "************************************** "
remove_service $f1 $f2 $f3 $f4 $f5 $f6 $f7 
done < "$solution_def_file"
./solution_status.sh --sd $solution_def_file

