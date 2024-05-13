#!/bin/bash
resourceList=$(cat) # read the `kind: ResourceList` from stdin
storeKind=$(echo "$resourceList" | yq e '.functionConfig.spec.storeKind' - )
storeName=$(echo "$resourceList" | yq e '.functionConfig.spec.storeName' - )

export STORE_NAME="$storeName"
export STORE_KIND="$storeKind"
echo "$resourceList" > banan

echo "$resourceList" | (/Users/jonaskop/Code/external-secrets-transformer/external-secrets-transformer-macos-amd64) #> bananer

# echo "
# kind: ResourceList
# items:
# - kind: ConfigMap
#   apiVersion: v1
#   metadata:
#     name: the-map
#   data:
#     altGreeting: "$altGreeting"
#     enableRisky: "$enableRisky"
# "