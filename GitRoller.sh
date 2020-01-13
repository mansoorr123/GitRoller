#!/bin/bash
echo
echo ========================================
echo GitRoller v.1.0 "	" By:Mansoor R
echo ========================================
echo

#Defining paths:

PATH_TRUFFLEHOG="/opt/github/truffleHog/truffleHog/truffleHog.py"

#Displaying help :
if [ $# -eq 0 ] || [ $1 == "-h" ] || [ $1 == "--help" ]
then
	echo Usage : supply organisation/user name
	echo Ex "  " : ./GitRoller hackerone
	exit
fi

GHUSER=$1
#GHUSER=hackerone;
if [ -d "$GHUSER"_git ]; then
	echo Please remove directory "$GHUSER"_git and then proceed further.
  	exit
  else	
 	mkdir "$GHUSER"_git
  	cd "$GHUSER"_git
fi

echo	Organisation: "	"$GHUSER
echo
echo

echo "==> Gathering Repos from github ..."
i=1
while [ true ]
do
	#Fetching Public repos of particular user:
	curl  "https://api.github.com/users/$GHUSER/repos?per_page=100&page=$i" -s | grep -w clone_url > temp_output.txt
	#Fetching Public repos of particular organisationg:
	#curl  "https://api.github.com/orgs/$GHUSER/repos?per_page=100&page=$i" -s | grep -w clone_url > temp_output.txt
	if [ ! -s temp_output.txt ];	#File is empty
	then
		break
	fi
	cat temp_output.txt | grep -o '[^"]\+://.\+.git' >> "$GHUSER"_repos.txt
	i=$[$i+1]
done

if [ -f temp_output.txt ];
then
	rm temp_output.txt
fi
if [ -s "$GHUSER"_repos.txt ];then
		echo "(+) Public Repos for $GHUSER are successfully saved into file: "$GHUSER"_repos.txt"
	else
		echo "(-) Public Repos for $GHUSER not found"
		exit
fi
echo
echo "==> Scanning Repos with TuffleHog ..."
for repo in $(cat "$GHUSER"_repos.txt);
do
	echo
	echo ------------------------------------------------------------------------------------
	echo Repository: $repo
	echo ------------------------------------------------------------------------------------
	$PATH_TRUFFLEHOG --regex --entropy=False $repo | tee  temp_output2.txt
	if [ -s temp_output2.txt ];then
		echo ------------------------------------------------------------------------------------ >> "$GHUSER"_trufflehog.txt
		echo Repository: $repo >> "$GHUSER"_trufflehog.txt
		echo ------------------------------------------------------------------------------------ >> "$GHUSER"_trufflehog.txt
		cat temp_output2.txt >> "$GHUSER"_trufflehog.txt
		rm temp_output2.txt		
	fi
done
echo
if [ -s "$GHUSER"_trufflehog.txt ];then
	echo "(+) Secrets for $GHUSER are successfully saved into file: "$GHUSER"_trufflehog.txt"
else
	echo "(-) No secrets are found for $GHUSER"
fi
	
#Bell
echo -e "\a"
echo THANKS FOR USING GitRoller !!
