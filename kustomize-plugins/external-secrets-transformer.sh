#!/bin/bash
resourceList=$(cat) # read the `kind: ResourceList` from stdin

storeKind=$(echo "$resourceList" | sed -n -e 's/storeKind: //p')
storeName=$(echo "$resourceList" | sed -n -e 's/storeName: //p')

export STORE_NAME="$storeName"
export STORE_KIND="$storeKind"

echo "$resourceList" | (/Users/jonaskop/Code/external-secrets-transformer/external-secrets-transformer-macos-amd64)
