#!/bin/bash

# Script to work around suspend-related issues on a ThinkPad T16 Gen1.
# Shall be placed in /usr/lib/systemd/system-sleep/

PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [[ "${1}" == "post" ]]; then
    echo "$(date) Woke up from suspend." >> /tmp/wake.log

    LID_STATE=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')

    if [ "$LID_STATE" = "open" ]; then
        # Work around occasional slow wifi after waking up from suspend.
        echo "$(date) Woke up while the lid was open. Restarting wifi." >> /tmp/wake.log
	modprobe -r ath11k_pci ath11k >> /tmp/wake.log
	modprobe ath11k_pci ath11k >> /tmp/wake.log
    fi

    if [ "$LID_STATE" = "closed" ]; then
        # Work around unintended wakeup when connecting AC power while suspended.
        echo "$(date) Woke up while the lid was closed. Suspending again." >> /tmp/wake.log
        echo freeze > /sys/power/state
    fi
fi
