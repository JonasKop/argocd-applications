#!/bin/bash

NAME=home-assistant
NAMESPACE=home-assistant

pgUsername=$(kubectl get secret -n "$NAMESPACE" "$NAME"."$NAME"-postgresql.credentials.postgresql.acid.zalan.do -o yaml | yq '.data.username' | base64 -d)
pgPassword=$(kubectl get secret -n "$NAMESPACE" "$NAME"."$NAME"-postgresql.credentials.postgresql.acid.zalan.do -o yaml | yq '.data.password' | base64 -d)

PGPASSWORD=$pgPassword pg_dumpall -U "$pgUsername" -h localhost > pgdump