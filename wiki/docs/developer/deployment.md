



# backup and cleanup

when VPS hdd is getting full, you can delete the contents of tmp/, (atomically):
```
cd /var/lib/docker/volumes/robust${PP}_tmp/_data/
mkdir ../backup
mv * ../backup
```
then rsync that to a backup machine and delete
fixme:
```
rsync -av --progress -h   -e 'ssh -p 44' -r  --exclude 'dont_backup' --exclude 'venv' --exclude '.cache'  --exclude '__pycache__'  --exclude '.npm'  --exclude 'site-packages'  --exclude "node_modules"     --include "/var/lib/docker/***"   --exclude "*"  root@dev-node.uksouth.cloudapp.azure.com://  /shared/backups/(date '+%F-%H-%M-%S')

or 

rsync -av --progress -h   -e 'ssh -p 44' -r  --exclude 'dont_backup' --exclude 'venv' --exclude '.cache'  --exclude '__pycache__'  --exclude '.npm'  --exclude 'site-packages'  --exclude "node_modules"     root@dev-node.uksouth.cloudapp.azure.com:/var/lib/docker/volumes/robust{$PP}_tmp/  /shared/backups/(date '+%F-%H-%M-%S')

```
