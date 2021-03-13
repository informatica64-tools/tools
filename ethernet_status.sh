#!/bin/bash

echo -e "%{F#000000} %{F#e2ee6a}$(/usr/sbin/ifconfig 2>/dev/null| grep "inet " | grep "192" | awk '{print $2}')%{u-}"
