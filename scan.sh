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
HOST_LIST="machinery_host1 machinery_host2 machinery_host3"
PARALLEL_JOBS=4
MACHINERY_ROOT=~/.machinery/

# TODO: add parameter for file instead of hostlist
# TODO: add external parameters do override defaults



# main functions

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

print_help(){
# TODO: add help with parameters
echo foo
}


# begin processing


# check GIT repo
check_git_repo

# launch the actual scan
(
for HOST in $HOST_LIST
do
  ((i=i%PARALLEL_JOBS)); ((i++==0)) && wait
  perform_scan "$HOST" &
done
)
# TODO: wait for the las process to end before exiting








