#!/bin/bash

#
# Machinery reporter
#
# Author: Enrico Bartz
#
# This script will return a number of changes for a
# given host based on a GIT repository where machinery
# manifest files live in.
#

# fetch vars

while [[ $# -gt 1 ]]
do
  key="$1"
  case $key in
    -h|--hostname)
    HOST_NAME="$2"
    shift
    ;;
    -o|--output)
    OUTPUT="$2"
    shift
    ;;
    *)
            # unknown option
    ;;
  esac
shift # past argument or value
done

# main vars
MACHINERY_ROOT=~/.machinery/


# main functions

# checks weatcher the repo exists
# or creates a new one and adds everything to an initial commit
check_git_repo(){
  cd $MACHINERY_ROOT || echo MACHINERY_ROOT directory does not exist!
  if [ ! -d .git ]; then
    echo ERROR: MACHINERY_ROOT directory is not a GIT repository!
  fi
}

print_help(){
# TODO: add help with parameters
echo foo
}

# will verify needed variables and print propper errors
# if something is missing
verify_variables(){
# check weather a hostname is set
if [ -z ${HOST_NAME+x} ]; then echo 'Hostname for report is not set.'; exit 1; fi 
# check weather data for host exists
if [ ! -f "$MACHINERY_ROOT/$HOST_NAME/manifest.json" ]; then echo 'Host has not been inspected yet.'; exit 1; fi 


}

# depending on $OUTPUT this will start machinery --serve with a compare
# or just print a plain diff output with the changes discovered in the given
# time frame.
start_report(){

select_timeframe

if [ "$OUTPUT" == "diff" ] 
then
  execute_report_diff $HOST_NAME $COMPARE_SOURCE $COMPARE_DESTINATION
elif [ "$OUTPUT" == "html" ] 
then
  execute_report_html $HOST_NAME $COMPARE_SOURCE $COMPARE_DESTINATION
else
  echo 'Default output format (html) will be used.'
  execute_report_html $HOST_NAME $COMPARE_SOURCE $COMPARE_DESTINATION
fi

}

# prompts available reports and asks the user to select by commit id
select_timeframe(){
  echo 'List of available reports'
  cd $MACHINERY_ROOT/$HOST_NAME/
  # print out formated git log
  git log --pretty=format:"%h%x09%an%x09%ad%x09%s" --date=relative manifest.json

  # read source version
  echo Please select an old Commit ID which you want to compare from.
  read COMPARE_SOURCE

  # read destination version
  echo Please select a newer Commit ID with which ou want to compare.
  read COMPARE_DESTINATION
}


execute_report_html(){
# TODO: add some logic for the html report
echo foo
}

execute_report_diff(){
  # change into hosts report directory
  cd $MACHINERY_ROOT/$1/

  # print the diff using git and some grep
  git diff $2 $3 manifest.json | grep -v modified | grep '^+\|^-'

}

# check GIT repo
check_git_repo

# make sure variables are in place
verify_variables

# fire the report
start_report

