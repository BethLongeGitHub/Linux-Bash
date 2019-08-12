#!/bin/csh
#go to the /home folder
        set dirpath = "/home"
        cd $dirpath
#create a list to collect usernames
        set userslist

#for all users in /home
        foreach userdir ( ` /bin/ls ` )
#careful not to delete non-user folders that we need to keep
                if ( -d $userdir && $userdir != "PLYMOUTH" && $userdir != "plymouth" && $userdir != "lost+found" && $userdir != "misc" && $userdir != "Archive" && $userdir != "sysop")  then
#use the group command to determine if they're current students
                        set groups = `groups $userdir | tr ' ' '\n' | grep turing`
#if not
                        if $groups != 'turing_accounts' then
#add the non-turing user to the list
                                set userslist = ( $userslist $userdir )
#get a backup of the users database and put it in their home folder
        #                       mysqldump --defaults-file=/root/.check_user_assist.cnf $userdir > $dirpath/$userdir/sql_database_backup.sql
                        endif
                endif
        end
#this is the final list of users who need to be removed from Turing
        echo "The Following users have had their databases archived: $userslist"


#for each user in userslist create a txt that does the following:
        foreach dirname ( $userslist )
#drop the user and the db
                echo "Removing .... $dirname from mysql"
                echo " DROP DATABASE $dirname; " >> /home/sysop/scripts/MYSQL/drop_old_users_mysql.txt
                echo " DROP USER '$dirname'@'%'; " >> /home/sysop/scripts/MYSQL/drop_old_users_mysql.txt

#archive the home folder (which contains the backup of the db)

                zip -r /home/Archive/$dirname.zip /home/$dirname/*
#Remove the /home directory
        #       rm -rf /home/$dirname
                echo "Home folder has been deleted. "
        end

#       set query = ' source /home/sysop/scripts/MYSQL/drop_old_users_mysql.txt '
#file list of commands to drop DBs and users echo'ed to mysql
#       set list = `echo $query | mysql --defaults-file=/root/.check_user_assist.cnf`

#remove the mysql file for re-use
     #  echo " " > /home/sysop/scripts/MYSQL/drop_old_users_mysql.txt
        echo "Archive and deletion of old users is complete. "
