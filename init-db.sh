#!/bin/bash
# This runs inside the MySQL container during initial setup
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root --password="$MYSQL_ROOT_PASSWORD" mysql