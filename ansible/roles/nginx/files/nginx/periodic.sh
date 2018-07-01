#!/bin/sh

if [ -r /etc/defaults/periodic.conf ]
then
        . /etc/defaults/periodic.conf
        source_periodic_confs
fi

PATH=$PATH:/usr/local/bin:/usr/local/sbin
export PATH

case "$weekly_nginx_reload_enable" in
    [Yy][Ee][Ss])
	echo
	echo "Reloading nginx:"
        service nginx reload
        ;;
    *)
        ;;
esac
