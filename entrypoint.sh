#!/bin/bash

set -e

login=$1
json=$2
command=$3
home="/cli/jelastic"

export home

if [ "$login" == "true" ]
then
  echo "Login"
  echo n | $home/users/authentication/signin --login "$JELASTIC_USERNAME" --password "$JELASTIC_PASSWORD" --platformUrl "$JELASTIC_URL" > /dev/null
fi

if [[ "$command" == *","* ]]; then
  echo "Multi-task obtained."

  # Split the command string into an array
  IFS=',' read -r -a commands <<< "$command"

  # Function to handle multi-task redeployment
  redeploy_multi_task() {
    local TASK=$1
    echo "Redeploying node group: $TASK"
    local full_command="$home/$TASK"
    IFS=" " read -r -a args <<< "$full_command"
    # Execute the command if needed
    response=$(${args[@]})
    # Uncomment to handle JSON response if needed
    # response=$(echo "$response" | sed -n '1!p' | jq --compact-output || echo "$response")
  }

  # Export the function and run in parallel
  export -f redeploy_multi_task
  parallel redeploy_multi_task ::: "${commands[@]}"
else
  echo "Single task obtained."
  # Execute the single command
  response=$("$home/$command" "${@:3}")
fi

if [ "$json" == "true" ]
then
  response=$(echo "$response" | sed -n '1!p' | jq --compact-output || echo "$response")
fi

echo "$response"
