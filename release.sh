#!/bin/bash
#Author: Genaro Coronel
#Date: 10/06/2021

release()
{
  time=1130
  currentDate=$(date +'%Y%m%d')
  version="$currentDate-$time"
  changeLogFile=changelog.txt
  echo $version

  #set task in array, if tasks does not exist leave empty
  #tasks=( 'task1' 'task2' 'task3' )
  tasks=( )

  git checkout develop
  git pull origin develop

  git checkout master
  git pull origin master

  git checkout develop
  git checkout -b release-$version

  git checkout master
  git merge release-$version

  if [[ -f "$changeLogFile" ]]; then
    echo "$changeLogFile exists."
    sed -i "1s/^/Changelog release-$version: \n/" $changeLogFile
    git tag -a $version --file=$changeLogFile
  else
    echo "$changeLogFile does not exist."
    git tag -a $version
  fi

  git push origin master
  git push origin --tags

  if [ "${#tasks[@]}" -ge 1 ]; then
    echo "Running rake tasks . . ."
    for task in "${tasks[@]}"
    do
      echo $task
      heroku run rake $task --app-nimbox-api-production
    done
  fi

}

request_execution(){
  read -p "Make release? (Y/n): " answer
  if [ "$answer" == "Y" ]; then
    echo "Running release . . . "
    release
  else
      echo "Exit"
  fi
}

# $1 -> first argument
if [ "$1" == "Y" ]; then
  echo "Running release . . . "
  release
else
  request_execution
fi

#For schedule the script execution ( execute with args ./release.sh Y)
#https://askubuntu.com/questions/339298/conveniently-schedule-a-command-to-run-later
