#!/bin/sh

if [ -r /etc/defaults/periodic.conf ]
then
        . /etc/defaults/periodic.conf
        source_periodic_confs
fi

PATH=$PATH:/usr/local/bin:/usr/local/sbin
export PATH

case "$daily_blocklist_enable" in
    [Yy][Ee][Ss])
	echo
	echo "Updating blocklist:"

	if [ -z "$daily_blocklist_user" ]
	then
		/bin/sh /usr/local/etc/unbound/blocklist/generate.sh --blocklist "$daily_blocklist_file" --output "$daily_blocklist_out"
	else
		su -m "$daily_blocklist_user" -c "/bin/sh /usr/local/etc/unbound/blocklist/generate.sh --blocklist $daily_blocklist_file --output $daily_blocklist_out"
	fi

        service unbound reload
        ;;
    *)
        ;;
esac
