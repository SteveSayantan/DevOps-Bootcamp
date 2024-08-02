#! /bin/bash

<<working
    We can write scripts and talk to the GitHub API to get our required information.

    In the GitHub API docs, we can get information and examples about how to use GitHub API. 

    To connect to the GitHub API, we need to have an API token for authorization.

    Steps to create GitHub API token:

     - Go to Settings --> Developer Settings

     - Click on Personal Access Tokens. Choose Tokens (classic) from the menu.

     - Click on Generate new Token (classic) . 

     - Select the required scopes for token and click on Generate Token.

     - Copy the Access Token for future usage.

    ## Before executing the following script, run the followings on terminal to create 'username' and 'token' variables:

     - export username="<GitHub_Username>"

     - export token="<GitHub_Access_Token>" 

    ## Detailed usage of jq package (a command-line JSON processor; Need to be installed separately in the system) --> https://www.baeldung.com/linux/jq-command-json
working


######################################################################
# About: list the employees having pull access to a particular repo ( personal / belonging to a GitHub Organisation )

######################################################################


# Getting the value of username and token (created using 'export') from the terminal
MY_USERNAME=$username
MY_TOKEN=$token

if [ -z $MY_USERNAME -o -z $MY_TOKEN ]  # This will ensure the credentials are provided properly
then
    echo Provide Correct Credentials
    exit 1
fi


# Getting the organisation's (i.e. GitHub Organisation; For personal repo, use your GitHub username) name and repository name from the command line args
ORG_NAME=$1
REPO_NAME=$2

if [ $# -ne 2 ]     # This will ensure the rest of the code runs only if the script is invoked with two args
then
    echo Provide the name of the Organisation and the Repository
    exit 2
fi


# GitHub API URL 
API_URL="https://api.github.com"


function list_emp_with_read_access {

    local endpoint="repos/$ORG_NAME/$REPO_NAME/collaborators"

    # the command is taken from GitHub API docs; -s flag stands for silent, it disables the progress meter; we shall get a JSON in response
    resp=$(curl -L -s -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $MY_TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" $API_URL/$endpoint )

    collaborators=$(echo $resp | jq '.[] | select(.permissions.pull==true) | .login')    # since, true is a boolean value, don't use quotes around it

    if [ -z $collaborators ]
    then
        echo No users with pull access found for $ORG_NAME/$REPO_NAME
    else
        echo Users with pull access to $ORG_NAME/$REPO_NAME:
        echo $collaborators
    fi
}




# main script

echo -e "Listing users with read access to $ORG_NAME/$REPO_NAME ...\n"      # -e flag forces to recognize \n as new line character
list_emp_with_read_access

