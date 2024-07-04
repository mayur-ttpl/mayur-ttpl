$ sudo su -
$ cd /etc/logrotate.d/
$ vi <create file for logroation>

#we are entering diff application or single application log directory here 
/var/log/nginx/dev-app.cloudnetra.io/*.log
/var/log/nginx/dev.cloudnetra.io/*log
/var/log/nginx/dev-cloudnetra/*log
/var/log/nginx/share.groots.in/*log
/var/log/nginx/usermin.cloudnetra.io/*log
/var/log/nginx/webmin.cloudnetra.io/*log
 {
    #used if want to create the log from existing log file  
    copytruncate   #used if want to create the log from existing file  
   
    # used for setting retainion period (how many days before`s logs to keep, more older then it will be deleted automayically)
    rotate 30

    #log rotation to store in format as mention below(compress)
    daily
    
    #compress formet for log rotation
    compress
    
    #to provide extention for log file in date format instead of number(log should be save in proper date format for easy debugg)
    dateext    

    #setup date format for dateext(below used datemonthyear setup) 
    dateformat -%d-%m-%Y

    # create new (empty) log files after rotating old ones,immediately after rotation, create a new log file with the same name as the one just rotated.
    create
    
    #not throgh error if in case there is no such applications with *log extention not available or application deleted or uninstall etc.
    missingok

    #if your log file has no log or it is zero in size it will not rotate log or if we use #notifempty then it will rotate log for empty file also    
    notifempty
}



#then we can apply the logration file using 

$ logrotate -f <file name from logroate.d directory>

