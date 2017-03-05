#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOUR='\033[0m'

if [ $# -ne 3 ]; then
    printf "\n${RED}[+]HTTP Enumeration\n"
    printf "${GREEN}[+]Usage httpEnum.sh <target> <port> <GoBuster Extension (e.g php,asp)>\n\n"
    exit
fi

dirName='./httpEnum-'$1

if [ ! -d $dirName ]; then
	mkdir $dirName
fi

printf "\n${RED}[+]Curl Get...${NOCOLOUR}\n\n"
curl -is http://$1:$2 | tee -a $dirName/curlGet.txt

printf "\n${RED}[+]Running NMap HTTP Enumeration${NOCOLOUR}\n\n"
nmap --script=http-enum $1 | tee -a $dirName/http-enum.txt

printf "\n${RED}[+]Running GoBuster...${NOCOLOUR}\n\n"
gobuster -u http://$1:$2 -w /usr/share/wordlists/dirb/big.txt -x $3 | tee -a $dirName/gobuster-search.txt

printf "\n${RED}[+]Running HTTP Methods Fuzz...${NOCOLOUR}\n\n"
while read p; do
	nmap -p $2 $1 --script http-methods.nse  --script-args http-methods.url-path=$p
done < <(grep ^/ ./httpEnum-$1/gobuster-search.txt | awk '{print $1}')
 
printf "\n${RED}[+]Running Nikto Vulnerability Assessment${NOCOLOUR}\n\n"
nikto -h http://$1:$2 | tee -a  $dirName/nikto.txt
 
printf "\n${RED}[+]Running Nmap HTTP Vuln Assessment${NOCOLOUR}\n\n"
nmap --script=http-vuln*,http-webdav-scan.nse $1 -p $2 | tee -a $dirName/http-vuln.txt
