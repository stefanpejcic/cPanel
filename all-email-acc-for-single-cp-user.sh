#!/bin/bash
echo -n -e "\e[31mIf you wants to get a email account for particular cPanel user domain?\e[0m"
read yno
case $yno in
        [yY] | [yY][Ee][Ss] )
                read -p "Please Enter cPanel User Name : " username
                if [ -z "$username" ]
                then
		echo -e "\e[42mNothing Select\e[0m"
                echo -e "\e[31mCould please select the cPanel user name\e[0m"
		else
		if ls /var/cpanel/users/$username 1> /dev/null 2>&1; 
		then
		echo -e "\e[106mHi, You have selected the $username user and email account details will be fetch from the user!\e[0m"
		for a in `echo -n "$username"`;do
		domainlist=`grep -i ^dns /var/cpanel/users/"$a" |cut -d= -f2`
		echo -e "\e[105mcPanel User Login: `echo "$a"`\e[0m"
		for b in `echo "${domainlist[@]}" | sed 's/ /\n/g'`;do
		for c in ` ls -A /home/"$a"/mail/"$b"/ 2>/dev/null`;do
		if [ "$c" == "cur" ];then echo "$c" > /dev/null
		elif [ "$c" == "new" ];then echo "$c" > /dev/null
		elif [ "$c" == "tmp" ];then echo "$c" > /dev/null
		elif [ "$c" == "" ];then echo "$c" > /dev/null
		else
		echo "$c"@"$b"
		fi
		done
		done
		var="$(grep $username /etc/userdomains | sed 's/://g' | awk '{ system("cat /home/"$2"/etc/"$1"/passwd") }' 2>/dev/null | wc -l)" ; echo -e "\033[1mTotal email account count $var\033[0m" 
		done
		else 
		echo -e "\e[31mThe cPanel user $username is not available\e[0m"
		fi 
		fi
               ;;
         [nN] | [n|N][O|o] )
                echo -e "\e[106mYou have selected No|nO option and the script will get the email account details from all cPanel user domains\e[0m"
           	userlist=`ls -1A /var/cpanel/users/`
		count=1
		for m in `echo -n "$userlist"`;do
		domainlist=`grep -i ^dns /var/cpanel/users/"$m" |cut -d= -f2`
		list[$count]=$domainlist
		count=$[$count+1]
		echo -e "\e[105mcPanel User Login: `echo "$m"`\e[0m"
		for x in `echo "${list[@]}" | sed 's/ /\n/g'`;do
		for z in ` ls -A /home/"$m"/mail/"$x"/ 2>/dev/null`;do
		if [ "$z" == "cur" ];then echo "$z" > /dev/null
		elif [ "$z" == "new" ];then echo "$z" > /dev/null
		elif [ "$z" == "tmp" ];then echo "$z" > /dev/null
		elif [ "$z" == "" ];then echo "$z" > /dev/null
		else
		echo "$z"@"$x"
       	  	fi
	  	done
		done 
		echo;echo;
		done
		output="cPanel User\tDomains List\t Email Account Count\n\n==================\t***************************************\t++++++++++++++++++++++++";
		for q in `cat /etc/localdomains`; do
		abc=`grep -E ^$q: /etc/userdomains`;
		if [ ! -z "$abc" -a "$abc" != " " ]; then
            	xyz="^([^-]+): (.*)$";
            	[[ $abc =~ $xyz ]] && domain="${BASH_REMATCH[1]}" && user="${BASH_REMATCH[2]}";
            	sum="`wc -l "/home/"$user"/etc/"$domain"/passwd" 2>/dev/null`";
            	xyz="^([^-]+) (.*)$";
            	[[ $sum =~ $xyz ]] && count="${BASH_REMATCH[1]}";
            	output="$output\n$user\t$domain\t$count";
    	fi
done
		echo -ne $output | column -s $'\t' -t;
	  	exit 1
                ;;
       *) echo -e "\e[42mNothing Select\e[0m"
            ;;
esac
