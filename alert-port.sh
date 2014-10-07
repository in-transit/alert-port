#!/bin/bash

# alert-port v2.0.4

# This script uses nmap & sed to check for an open tcp port.  After four failed attempts
# it will notify whom you specify of the failure.

# The first argument is the IP or domain name you would like to check.
# The second argument is the tcp port you would like checked.
# The third argument is the list of recipients to be emailed.
# The fourth argument is anything you want appended to the message. (i.e. "from Kalamazoo.")

# START HOUSE KEEPING

# Set Individuals to be emailed when alert is sent.
alertRecipient=$(echo $3)

# Set the message to be sent in the alert.
alertMessage=$(echo $1 is unreachable on port $2/tcp $4)

# Empty the alert determination variable.
isUp=""

# Empty the loop counter
i=0

# Empty the $portStatus variable
portStatus=0

# DEBUGGING
# echo HOUSE KEEPING alertRecipient: $alertRecipient
# echo HOUSE KEEPING alertMessage: $alertMessage
# echo HOUSE KEEPING isUp: $isUp
# echo HOUSE KEEPING i: $i
# echo HOUSE KEEPING portStatus: $portStatus


# END HOUSE KEEPING

# BEGIN SERVICE LOOP

while :
do
  # CLEAN $isUp variable
  isUp=""
  # echo DEBUGGING isUp: $isUp

  # CLEAN $portStatus variable
  portStatus=0
  # echo DEBUGGING portStatus: $portStatus

  # CLEAN loop counter $i
  i=0
  # echo DEBUGGING i: $i

  # BEGIN CHECK LOOP
  while [ $i -le 3 ]
  do
    # Perform check & set $isUp variable.
    isUp=$(nmap -p $2 -Pn $1 | sed '/open/!d')
    # echo DEBUGGING isUp: $isUp

    # If nmap finds an open port then increment $portStatus variable.
    if [ -n "$isUp" ]
      then

        ((portStatus++))

        # CLEAN $isUp variable
        isUp=""
    fi

    # Increment loop counter $i
    ((i++))

    # sleep for one second
    sleep 1

  done
  # END CHECK LOOP

  # BEGIN NOTIFICATION
  if [ $portStatus -eq 0 ]
   then
    echo $alertMessage | mailx -s "$1 Service Check Notification" $alertRecipient
    # echo DEBUGGING Alert Sent
    sleep 60
  fi

  # END NOTIFICATION
done

