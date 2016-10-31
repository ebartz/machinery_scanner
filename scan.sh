#!/bin/bash

#
# Machinery scanner
#
# Author: Enrico Bartz
#
# This script will run a defined number of parallel jobs 
# to scan defined hosts with machinery. It will after the scan
# automatically add and commit the files to a GIT repository.
# This will ensure that you will have a revision of your machines state.
#


# main vars
MACHINERY_ROOT=~/.machinery/
PARALLEL_JOBS_DEFAULT=4


######################
# main functions
######################

# checks weatcher the repo exists
# or creates a new one and adds everything to an initial commit
check_git_repo(){
  mkdir -p $MACHINERY_ROOT && cd $MACHINERY_ROOT
  if [ ! -d .git ]; then
    echo initialising new GIT Repo 
    git init
    echo "machinery.log" >> .gitignore
    git add .
    git commit -a -m "initial commit"
  fi
}

# concats the host list which comes in from a parameter with the ones which may come from a file
generate_host_list(){
HOST_LIST=$HOST_LIST $(test -f "$HOST_FILE" && cat "$HOST_FILE" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g')
}

# will verify needed variables and print propper errors
# if something is missing
verify_variables(){
# check weather there is at least one host in $HOST_LIST
if [ $(wc -w <<< "$HOST_LIST") -eq 0 ]; then echo No hosts specified.; exit 1; fi

if [ ! -z ${PARALLEL_JOBS+x} ]; then PARALLEL_JOBS=$PARALLEL_JOBS_DEFAULT; fi

}

# performs the actual scan of one host which will be passed over as $1
perform_scan(){
  echo processing $1
  # change directory to main macnihery directory for git reasons
  cd $MACHINERY_ROOT
  # do the actual inspection of a host
  machinery inspect $1  > /dev/null
  # make sure new files will be added
  git add $1/  > /dev/null
  # commit new changes
  git commit $1/ -m "autocommit $1" > /dev/null
}

# prints help with command examples
print_help(){
  echo "Parameters:
  -h, --host     : specifies a hostname that you want to scan
  -f, --file     : specifies a file which contains a bunch of hostnames
  -p, --parallel : specifies the number of scans that should be performed in parallel. Default = $PARALLEL_JOBS_DEFAULT 

Examples: 
Just scan one server:
$0 -h my_server

Scan a list of servers
$0 -h \"host1 host2 host3\"

Scan a list of hosts in a file with 10 scans in parallel:
$0 -f host_list -p 10"
}

######################
# begin processing
######################

# check if parameters are given and print help if not
[[ $@ ]] || { print_help; exit 1; }

######################
# fetch vars
######################

while [[ $# -gt 1 ]]
do
  key="$1"
  case $key in
    -h|--host)
    HOST_LIST="$2"
    shift
    ;;
    -f|--file)
    HOST_FILE="$2"
    shift
    ;;
    -p|--parallel)
    PARALLEL_JOBS="$2"
    shift
    ;;
    *)
            # unknown option
    ;;
  esac
shift # past argument or value
done

echo $HOST_LIST

# check GIT repo
check_git_repo

# go ahead and generate the HOST_LIST
generate_host_list

# verify all needed variables
verify_variables


# launch the actual scan
(
for HOST in $HOST_LIST
do
  ((i=i%PARALLEL_JOBS)); ((i++==0)) && wait
  perform_scan "$HOST" &
done
)
# TODO: wait for the las process to end before exiting








