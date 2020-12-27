#!/usr/bin/env bash
sudo /etc/init.d/postgresql "start"
sudo -u postgres psql -c "CREATE DATABASE cowspiracy_test;"
sudo -u postgres psql -c "CREATE USER testing WITH PASSWORD 'example'";
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"cowspiracy_test\" to testing;";
