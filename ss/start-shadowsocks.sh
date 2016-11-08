#!/bin/bash

if [ -f /var/run/shadowsocks.pid ]; then
    sslocal -c shadowsocks.json -d stop
fi

sslocal -c shadowsocks.json -d start
