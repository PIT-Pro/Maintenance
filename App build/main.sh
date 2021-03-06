#!/bin/bash
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
#
/Library/Addigy/macmanage/MacManage.app/Contents/MacOS/MacManage action=notify title="PIT Pro Onderhoud" description="PIT Pro onderhoud gaat starten. Je computer kan tijdelijk traag aanvoelen." closeLabel="Oké"  && proceed=1
#
LOGFILE=/Users/Shared/maintenance_log.txt

if [ -e $LOGFILE ]
then
    echo "maintenance_log.txt exists, writing output to file.."
else
    echo "maintenance_log.txt does not exist, creating file.."
fi

echo "START OF SCRIPT" >> $LOGFILE
echo "Checking MBBR.." | tee -a $LOGFILE
. MBBR_check.sh | tee -a $LOGFILE
echo "Purging caches.." | tee -a $LOGFILE
. purge_cache.sh | tee -a $LOGFILE
echo "Clearing browser caches.." | tee -a $LOGFILE
. clear_browser_caches.sh | tee -a $LOGFILE

MaintenanceLastTime="$(/usr/bin/stat -f "%Sm" -t "%Y%m%d" "/Applications/Utilities/Maintenance.app")" #get the last time PITPro Care has run
currentDate="$(/bin/date +%Y%m%d)" #get the current date

echo $MaintenanceLastTime >> $LOGFILE
echo $currentDate >> $LOGFILE

/Library/Addigy/macmanage/MacManage.app/Contents/MacOS/MacManage action=notify title="Herstart aanbevolen" description="Herstarten is aanbevolen. Sla belangrijke data op voordat je op Herstart klikt." acceptLabel="Herstart" closeLabel="Niet nu" && sudo -u $username osascript -e 'tell app "loginwindow" to Â«event aevtrrstÂ»' || echo "Restart not accepted by user." | tee -a $LOGFILE
echo "END OF SCRIPT" >> $LOGFILE