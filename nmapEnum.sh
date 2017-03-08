#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOUR='\033[0m'

if [ $# -ne 1 ]; then
    printf "\n${RED}[+]Nmap Enumeration Script\n"
    printf "${GREEN}[+]Usage nmapEnum.sh <target>\n\n"
    exit
fi

dirName='./nmapEnum-'$1

if [ ! -d $dirName ]; then
	mkdir $dirName
fi

printf "\n${RED}[+]Running SYN scan...${NOCOLOUR}\n"
nmap -sS -p- $1 | tee -a $dirName/Syn-scan.txt

printf "\n${RED}[+]Running version scan...${NOCOLOUR}\n"
nmap -sV --version-all -p- -oX $dirName/version-scan-xml.xml $1 | tee -a $dirName/version-scan.txt
 
#tcp
printf "\n${RED}[+]Running TCP scan...${NOCOLOUR}\n"
nmap -Pn -A -sC -sS -T 4 -p- $1 | tee -a $dirName/tcp-scan.txt
 
#aggressive/service
printf "\n${RED}[+]Running aggressive service scan...${NOCOLOUR}\n"
nmap -A $1 | nmap -sC $1 | tee -a $dirName/aggressive-service.txt
 
#udp
printf "\n${RED}[+]Running UDP scan...${NOCOLOUR}\n"
nmap -Pn -A -sC -sU -T 4 --top-ports 100 $1 | tee -a $dirName/udp-100.txt

#SearchSploit
printf "\n${RED}[+]Running SearchSploit...${NOCOLOUR}\n"
searchsploit -w --nmap $dirName/version-scan-xml.xml | tee -a $dirName/SearchSploit.txt
