#!/bin/sh
if [ ! -n "$REMOTE_HOST" ]; then
  REMOTE_HOST=tom@192.168.15.101
fi
echo "update server to $REMOTE_HOST"
REMOTE_PASS="1"
MIX_ENV=prod mix release --overwrite
echo 'upload to remote ....'
sudo rsync -rltDvz --password-file=/etc/rsyncd.passwd _build/prod/rel/ $REMOTE_HOST::data
echo '>>>>  upload finish  <<<<'
echo 'begin restart server'
sshpass -p "1" ssh $REMOTE_HOST "RELEASE_NODE=develop /release/matrix_server/bin/matrix_server restart"
echo 'begin restart dsa'
sshpass -p "1" ssh $REMOTE_HOST "RELEASE_NODE=dsa_1 DSA_PORT=20081 /release/matrix_server/bin/matrix_server restart"
echo '>>>>  restart finish <<<<'