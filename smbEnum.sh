#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOUR='\033[0m'

if [ $# -ne 1 ]; then
    printf "\n${RED}[+]SMB Enumeration\n"
    printf "${GREEN}[+]Usage smbEnum.sh <target> (SMB Ports must be open)\n\n"
    exit
fi

dirName='./smbEnum-'$1

if [ ! -d $dirName ]; then
	mkdir $dirName
fi


printf "\n${RED}[+]Running Nbtscan...${NOCOLOUR}\n\n"
nbtscan -r $1 | tee -a $dirName/NbtScan.txt

printf "\n${RED}[+]Running Nmap NSE Enum...${NOCOLOUR}\n\n"
nmap -sV -p 139,445 --script smb-enum-domains.nse,smb-enum-groups.nse,smb-enum-processes.nse,smb-enum-sessions.nse,smb-enum-shares.nse,smb-enum-users.nse,smb-ls.nse,smb-mbenum.nse,smb-os-discovery.nse,smb-system-info.nse,smb-server-stats.nse $1 | tee -a $dirName/NmapNSEEnum.txt

printf "\n${RED}[+]Running Nmap NSE Vuln...${NOCOLOUR}\n\n"
nmap -sV -p 139,445 --script smbv2-enabled.nse,smb-vuln-conficker.nse,smb-vuln-cve2009-3103.nse,smb-vuln-ms06-025.nse,smb-vuln-ms07-029.nse,smb-vuln-ms08-067.nse,smb-vuln-ms10-054.nse,smb-vuln-ms10-061.nse,smb-vuln-regsvc-dos.nse $1 | tee -a $dirName/NmapNSEVuln.txt

printf "\n${RED}[+]Running Enum4Linux...${NOCOLOUR}\n\n3"
enum4linux -a $1 | tee -a $dirName/Enum4Linux.txt