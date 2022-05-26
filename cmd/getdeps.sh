#!/usr/bin/bash
echo "通过代理获取依赖"
http_proxy=http://192.168.11.15:10811 https_proxy=https://192.168.11.15:10811 mix deps.get