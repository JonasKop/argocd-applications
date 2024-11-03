#!/bin/bash

services="./kustomize/* initial-argocd"
for svc in $services; do
  helmChartsLength=$(yq '.helmCharts | length' "$svc/kustomization.yaml")
  ######################
  # Update helm charts #
  ######################
  for ((i = 0; i < "$helmChartsLength"; i++)); do
    chartName=$(yq ".helmCharts[$i].name" "$svc/kustomization.yaml")
    version=$(yq ".helmCharts[$i].version" "$svc/kustomization.yaml")
    repo=$(yq ".helmCharts[$i].repo" "$svc/kustomization.yaml")

    helmCharts=$(curl -L -s "$repo/index.yaml")
    newVersion=$(echo "$helmCharts" | yq ".entries.\"$chartName\".[].version | select(. != \"*-beta*\") | select(. != \"*-alpha*\") | select(. != \"*-pre*\")" | sort -V -r | head -n 1)
    yq -i ".helmCharts[$i].version = \"$newVersion\"" "$svc/kustomization.yaml"

  done

  #######################
  # Update docker image #
  #######################
  imagesLength=$(yq '.images | length' "$svc/kustomization.yaml")
  for ((i = 0; i < "$imagesLength"; i++)); do
    imageName=$(yq ".images[$i].name" "$svc/kustomization.yaml")

    if [[ "$imageName" != *\/* ]]; then
      imageName="library/$imageName"
    fi
    org=$(echo $imageName | awk -F/ '{print $1}')
    img=$(echo $imageName | awk -F/ '{print $2}')
    tagNames=$(wget -q -O - "https://hub.docker.com/v2/namespaces/$org/repositories/$img/tags?page_size=100" | yq '.results.[].name' | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+\b')
    if [ "$imageName" == "homeassistant/home-assistant" ]; then
      if (($(date +"%-d") < 10)); then
        desiredVersion="^$(date +"%Y")\.$(date -v-1m +"%-m")"
      else
        desiredVersion="^$(date +"%Y")\.$(date -v-0m +"%-m")"
      fi
      versions=$(echo "$tagNames" | grep "$desiredVersion")
    else
      versions=$(echo "$tagNames" | grep -Eo '\b[0-9]+\.[0-9]+\.[0-9]+\b')
    fi
    latestVersion=$(echo "$versions" | sort -V -r | head -n 1)
    yq -i ".images[$i].newTag = \"$latestVersion\"" "$svc/kustomization.yaml"
  done

  ###################
  # Update git urls #
  ###################
  gitUrls=$(yq '.resources.[] | select(. == "https*")' "$svc/kustomization.yaml")
  for gitUrl in $gitUrls; do
    if [[ $gitUrl == "https://raw.githubusercontent.com"* ]]; then
      githubrepo=$(echo "$gitUrl" | cut -d'/' -f4-5)
      origGitUrl="https://github.com/$githubrepo"
    else
      origGitUrl=$(echo "$gitUrl" | cut -d'/' -f1-5)
    fi
    latestVersion=$(git ls-remote "$origGitUrl" | awk '{print $2}' | grep '^refs/tags' | sed 's/refs\/tags\///' | sed '/\^{}$/d' | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sort -V -r | head -n 1)
    newGitUrl=$(echo "$gitUrl" | sed 's/v\?[0-9]*\.[0-9]*\.[0-9]*/'"$latestVersion"'/')
    i=$(yq ".resources.[] | select(. == \"$gitUrl\") | path | .[-1]" "$svc/kustomization.yaml")
    yq -i ".resources[$i] = \"$newGitUrl\"" "$svc/kustomization.yaml"
  done
done
