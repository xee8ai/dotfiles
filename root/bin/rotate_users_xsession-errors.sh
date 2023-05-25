#!/bin/bash

# the ~/.xsession-errors can grew very big (Gigabytes) and there seems to be no
# real solution to rotate that properly
# on the other hand we do not really need X errors from previous sessions…
#
# therefore I call this helper script in my poweroff alias to rotate them for
# every home directory (and keep the errors of the user's last)

for HOME in $(ls -1 /home); do
    CUR_FILE="/home/$HOME/.xsession-errors"
    OLD_FILE="/home/$HOME/.xsession-errors.old"
    if [ -f "$CUR_FILE" ]; then
        mv -f $CUR_FILE $OLD_FILE
    fi
done
