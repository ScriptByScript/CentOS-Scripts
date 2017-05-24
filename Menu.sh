#!/bin/bash

# ------------------------------------------------------------------------------
# Filename: Menu.sh
# Last Edited: 5-24-2017    
#
# Change Log
# v1.00, 04/23/2016 - Added information banner
# v1.01, 05/24/2017 - Modified for CentOS 7 specific, Minor text fixes
# v1.02, 05/24/2017 - Changed versioning format
# ------------------------------------------------------------------------------

# Usage instructions:
# 1) Save file Menu.sh to /var/scripts/ (you might have to mkdir /var/scripts/ first), then edit the ~/.bash_profile file and put sh Menu.sh at the bottom so that it runs this at login
#
# 2) Create a symlink to the file by using the word menu to invoke by doing the following two commands:
# sudo ln -s /var/scripts/Menu.sh /usr/local/bin/M
# chmod +x /var/scripts/Menu.sh

trap '' 2  # ignore control + c
while true
do
  clear # clears the screen for each loop of menu
  echo "================================="
  echo "  --- Quick Selections Menu ---  "
  echo "================================="
  echo ""
  echo "  Enter 1 - CPU usage"
  echo "  Enter 2 - Current disk usage"
  echo "  Enter 3 - Search for large directories (might take awhile to traverse)"
  echo "  Enter 4 - Reboot web service"
  echo "  Enter 5 - Update the system (will need to approve updates)"
  echo "  Enter 6 - Reboot server"
  echo ""
  echo -e "Enter your selection here and hit <enter>"
  echo ""
  read answer  # create variable that retains the answer
  case "$answer" in
   1) top -c ;;
   2) df -h ;;
   3) ncdu / ;;
   4) sudo systemctl restart httpd.service ;;
   5) sudo yum update ;;
   6) sudo reboot ;;
   q) echo ""
      echo "To return to the Menu at any time, type M and hit <enter>"
      exit ;;
  esac
  echo ""
  echo -e "Hit the <enter> key to continue..."
  echo ""
  read input # this will cause a pause so we can read the output of the selection before the loop clears the screen
done
