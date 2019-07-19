#!/bin/bash
envsubst '${BACKEND}'< nginx.conf.template > /etc/nginx/nginx.conf
nginx -g "daemon off;"
