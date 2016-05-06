#!/bin/bash

#This is a shell script that accepts Taiga username and password and generate a Auth Token that can be used to make REST calls for Taiga API

# Request username and password for connecting to Taiga
read -p "Username or email: " USERNAME
read -s -p "Password: " PASSWORD
echo ""

# Get AUTH_TOKEN
USER_AUTH_DETAIL=$( curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
          "type": "normal",
          "username": "'${USERNAME}'",
          "password": "'${PASSWORD}'"
      }' \
  https://api.taiga.io/api/v1/auth 2>/dev/null )

AUTH_TOKEN=$( echo ${USER_AUTH_DETAIL} | jq -r '.auth_token' )

# Exit if AUTH_TOKEN is not available
if [ -z ${AUTH_TOKEN} ]; then
    echo "Error: Incorrect username and/or password supplied"
    exit 1
else
    echo "auth_token is ${AUTH_TOKEN}"
fi
