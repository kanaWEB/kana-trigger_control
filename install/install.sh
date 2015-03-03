#!/bin/sh
addlineafter() {
        sed -i 's/'"$2"'/'"$2"'\n'"$3"'/' $1
}

getline() {
        line=$(cat $1 |grep -n "$2"|awk '{print $1}'| head -n 1)
        if [ -z $line ]
                then
                echo "Line not founded"
                line=-1
        else
                line=$(echo $line|cut -d: -f1)
        fi
}

replaceline() {
       getline $1 $2
       if [ $line != -1 ]
               then
               sed -i ''"$line"'s/.*/'"$3"'/' $1
       else
        addlineafter "$1" "$4" "$3"
fi
}
if [ -f "/etc/kana/gcsms" ]
then

echo "Remove /etc/kana/gcsms to restart install"
echo "rm /etc/kana/gcsms"
echo "Testing sms"
echo "Getting first calendar"
firstcalendar=$(gcsms ls)
firstcalendar=$(echo $firstcalendar|awk '{print $1}')
/usr/local/bin/gcsms -c "/etc/kana/gcsms" send $firstcalendar "This is a test" 
else

        apt-get -f install python-pip
        pip install gcsms
        touch /root/.gcsms
cat <<\EOF > /root/.gcsms &&
[global]
client_id = 
client_secret = 
EOF

        echo "Go to https ://cloud.google.com/console and go to Apis & Auth / Credentials"
        read -r -p "CLIENT ID:" client_id
        replaceline /root/.gcsms "client_id =" "client_id = $client_id" "\[global\]"
        read -r -p "CLIENT SECRET:" client_secret
        replaceline /root/.gcsms "client_secret =" "client_secret = $client_secret" "client_id = "
        gcsms auth
        cp /root/.gcsms /etc/kana/gcsms
        chown www-data:www-data /etc/kana/gcsms
        chmod 400 /etc/kana/gcsms
        echo " "
        echo "Calendars available"
        gcsms ls -l
        echo "------------------"
        echo " "
        read -r -p "CREATE A CALENDAR:" calendarname
        /usr/local/bin/gcsms -c "/etc/kana/gcsms" create $calendarname
        /usr/local/bin/gcsms -c "/etc/kana/gcsms" unmute $calendarname
        /usr/local/bin/gcsms -c "/etc/kana/gcsms" send "This is a test" $calendarname
fi
