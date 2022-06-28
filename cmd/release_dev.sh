#!/bin/sh
REMOTE_HOST=tom@192.168.15.101
REMOTE_PASS="1"

MIX_ENV=prod mix release --overwrite
echo 'upload to remote ....'
sshpass -p $REMOTE_PASS scp -r _build/prod/rel/matrix_server/ $REMOTE_HOST:/release
echo '>>>>  upload finish  <<<<'
echo 'begin hot update'
sshpass -p "1" ssh $REMOTE_HOST "RELEASE_NODE=develop /release/matrix_server/bin/matrix_server rpc \"Reloader.update_all()\""
echo '>>>>  hot update finish <<<<'