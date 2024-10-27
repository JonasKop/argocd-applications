# Argo CD Applications

## Velero

If you want to import a backup from the remote bucket, run this:

```bash
# Import backup from s3 to cluster
b2 file cat b2://homelab-velero-backups/backups/$BACKUP_NAME/velero-backup.json | k apply -f -

# Restore backup
velero create restore --from-backup ns-backup
```
