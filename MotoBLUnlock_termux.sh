#!/bin/sh

fastbootCheck=$(termux-fastboot devices)

if [ -z "$fastbootCheck" ]; then
    echo ""
	echo "Put your device in fastboot mode (i.e. power off, and then"
	echo "press the power and volume down buttons simultaneously)."
    echo ""
	exit 1
fi
echo -n "Do you have an unlock code? (y/n)"
read havekey
if [ "$havekey" = "n" ];then
    unlockData=$(termux-fastboot oem get_unlock_data 2>&1)
    unlockKey=$(echo ${unlockData} | sed 's/(bootloader)//g' | tr -d '[:space:]' | sed 's/Unlockdata://' | sed 's/OKAY.*//')

    phoneSN=$(echo ${unlockKey} | awk -F'#' '{print $1}')
    phonePUID=$(echo ${unlockKey} | awk -F'#' '{print $4}')
    phoneHash=$(echo ${unlockKey} | awk -F'#' '{print $3}')

    url="https://en-us.support.motorola.com/cc/productRegistration/unlockPhone/$phoneSN/$phonePUID/$phoneHash/"

    echo -n "Do you want to see if you can unlock your device? (y/n)"
    read confirm
    if [ "$confirm" = "y" ]; then
        checkState=$(curl -s https://en-us.support.motorola.com/cc/productRegistration/verifyPhone/$phoneSN/$phonePUID/$phoneHash/)
        if [[ "$checkState" == *"Not"* ]]; then
            echo ""
	        echo "Sorry! Your device ${checkState} for unlocking"
        else
            echo ""
            echo "Congrats! Your ${checkState} for Unlocking"
        fi
    fi

        echo ""
        echo " Continue checking manually or proceed with unlocking...."
        echo ""
        echo " First log in at the Motorola website if you have not already:"
        echo ""
        echo " https://en-us.support.motorola.com/app/standalone/bootloader/unlock-your-device-b"
        echo ""
        echo "Now visit:"
        echo "  $url"
        echo ""
        echo "Or use the Device ID string: "
        echo "$unlockKey"

    termux-fastboot reboot-bootloader > /dev/null 2>&1

    echo ""
    echo "After following the above processes, within a few minutes, "
    echo "you will get your unlock code in your email. Copy it, and proceed."
    echo ""
fi
echo -n "Enter your unlock code: "
read unlockCode
echo ""
echo "About to run"
echo ""
echo "  $ termux-fastboot oem unlock $unlockCode"
echo ""
echo -n "Do you wish to continue? (y/n) "
read confirm
echo ""

if [ "$confirm" != "y" ]; then
	echo "Aborted"
	exit 1
fi

fastbootCheck=$(termux-fastboot devices)

if [ -z "$fastbootCheck" ]; then
	echo "Your device is not in fastboot mode"
	exit 1
fi

echo " Use the volume keys to navigate through the options"
echo "& press the power button to confirm. "
echo " Wait for your device to fully reboot"
echo ""

termux-fastboot oem unlock ${unlockCode} > /dev/null 2>&1
