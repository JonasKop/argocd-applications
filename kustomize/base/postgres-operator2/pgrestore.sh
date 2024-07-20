#!/bin/bash

DBNAME=home_assistant
NAME=home-assistant
NAMESPACE=home-assistant

pgUsername=$(kubectl get secret -n "$NAMESPACE" "$NAME"."$NAME"-postgresql.credentials.postgresql.acid.zalan.do -o yaml | yq '.data.username' | base64 -d)
pgPassword=$(kubectl get secret -n "$NAMESPACE" "$NAME"."$NAME"-postgresql.credentials.postgresql.acid.zalan.do -o yaml | yq '.data.password' | base64 -d)

replicas=$(kubectl get statefulset -n "$NAMESPACE" "$NAME" -o yaml | yq '.spec.replicas')

kubectl scale statefulset -n "$NAMESPACE" "$NAME" --replicas 0
PGPASSWORD=$pgPassword psql -U "$pgUsername" -h localhost postgres -c "drop database $DBNAME"
PGPASSWORD=$pgPassword psql -U "$pgUsername" -h localhost postgres <pgdump
kubectl scale statefulset -n "$NAMESPACE" "$NAME" --replicas $replicas
