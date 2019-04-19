#!/usr/bin/env bash

#set -x

mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"

for i in {30..0}; do
			if echo 'SELECT 1' | mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" &> /dev/null; then
				break
			fi
			echo 'MySQL init process in progress...'
			sleep 1
		done

SUCCESSFILE=/logs_migration.d/success.log
if test ! -f "$SUCCESSFILE"; then
    touch "$SUCCESSFILE"
fi

for f in /docker-entrypoint-migrations.d/migration*; do
			has_migrated=$(find "$SUCCESSFILE" -type f -print | xargs grep "$f")
			if [ -z "$has_migrated" ]
			then
				case "$f" in
					*.sql)    echo "$0: running $f"; mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$f"; echo "$f"; echo "$f" >> "$SUCCESSFILE"; echo ;;
					*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"; echo "$f" >> success.log; echo ;;
					*)        echo "$0: ignoring $f" ;;
				esac
			else
				echo "$f is already migrated."
			fi
		echo
done