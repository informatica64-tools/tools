#!/bin/bash

echo "%{F#2495e7} %{F#e2ee6a}$(/snap/core/9993/sbin/ifconfig wlp2s0 | grep 'inet' | awk '{print $2}' | tr ':' ' ' | awk '{print $2}')%{u-}"
