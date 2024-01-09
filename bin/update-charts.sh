#!/bin/bash

set -e

# Loop over all service directories
for d in helm/*/; do
  # Fetch values
  repo=$(yq '.repository' "$d/config.yaml")
  chart=$(yq '.chart' "$d/config.yaml")
  name=$(basename $d)

  # Dont search for updates in custom images
  if [[ "${repo}" == ghcr.io/* ]]; then
    printf "Skipping %-25s in %-20s\n" "${chart}" "${name}"
    continue
  fi

  # Fetch the service latest helm chart version
  helm repo add example $repo >/dev/null
  export VERSION=$(helm search repo -l example/$chart -o yaml | yq '.[0].version')

  # Cleanup
  helm repo remove example >/dev/null

  # Update helm chart version in config file
  printf "Updating %-25s in %-20s to version '$VERSION'\n" "${chart}" "${name}"
  yq -i '.version = strenv(VERSION)' "$d/config.yaml"
done

printf "\nFinished updating all helm charts\n"
