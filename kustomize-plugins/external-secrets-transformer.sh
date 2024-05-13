#!/bin/bash
resourceList=$(cat) # read the `kind: ResourceList` from stdin

storeKind=$(echo "$resourceList" | sed -n -e 's/storeKind: //p' | xargs)
storeName=$(echo "$resourceList" | sed -n -e 's/storeName: //p' | xargs)

export STORE_NAME="$storeName"
export STORE_KIND="$storeKind"

echo "$resourceList" | external-secrets-transformer
