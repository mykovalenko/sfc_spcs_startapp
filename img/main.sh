#!/bin/bash
mode=$(echo "$1" | tr '[:upper:]' '[:lower:]')
if [[ ".${mode}" != ".local" ]] ; then
	cp -f /opt/spcs/stage/app.tar.gz /opt/spcs/
	cd /opt/spcs/
	tar -zxvf app.tar.gz
fi

cd /opt/spcs/app
uvicorn main:app --host 0.0.0.0 --port 80
