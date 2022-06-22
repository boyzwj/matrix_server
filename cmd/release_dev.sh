#!/usr/bin/bash
MIX_ENV=prod mix release --overwrite
echo 'upload to remote ....'
sshpass -p "1" scp -r _build/prod/rel/matrix_server/ tom@192.168.15.101:/release
echo '>>>>  upload finish  <<<<'