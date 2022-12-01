#!/bin/bash 
if [ ! -d "scope" ]; then
	mkdir scope
elif [ ! -d "scans" ]; then
	mkdir scans
else
	echo "Directory Exists Skipping"
fi

# set vars 
id="$1"
ppath="$(pwd)"
scope_path="$ppath/scope/$id"

timestamp="$(date +%s)"
foldertime="$(date +%T)"
scan_path="$ppath/scans/$id-$foldertime"

if [ ! -d "$scope_path" ]; then
	mkdir "$ppath/scope/$id" | echo "$id" >> roots.txt | mv roots.txt "$scope_path/"
fi

mkdir -p "$scan_path"
cd "$scan_path"

### Initializing Scan ###
echo ""
echo "              _   _      _     _           ____                      
            | | | | ___(_)___| |_ ___    |  _ \ ___  ___ ___  _ __  
            | |_| |/ _ \ / __| __/ __|   | |_) / _ \/ __/ _ \| '_ \ 
            |  _  |  __/ \__ \ |_\__ \   |  _ <  __/ (_| (_) | | | |
            |_| |_|\___|_|___/\__|___/___|_| \_\___|\___\___/|_| |_|
                                    |_____|                         
							From the farm of VIEH Group
							Team Bash Heist
			
		Twitter : @viehgroup | @illucist | @byt3crash3r | @Abhisheksengu12
				- Sit back, have a coffee. We'll hunt data for you!
"

echo "Script is under Beta Tesing"
echo "Starting scan against roots:"
start_time=$(date +%T)
echo "Scan Started at : $start_time";
cat "$scope_path/roots.txt"
cp "$scope_path/roots.txt" "$scan_path/roots.txt"
sleep 3

################################################## Perform Scan ####################################################

# DNS Enumeration - Find Subdomains 
cat "$scan_path/roots.txt" | haktrails subdomains | anew subs.txt | wc -l 
cat "$scan_path/roots.txt" | subfinder | anew subs.txt | wc -l 
cat "$scan_path/roots.txt" | shuffledns -w "$ppath/lists/pry-dns.txt" -r "$ppath/lists/resolvers.txt" | anew subs.txt | wc -l 

# DNS Resolution - Find Subdomains 
puredns resolve "$scan_path/subs.txt" -r "$ppath/lists/resolvers.txt" -w "$scan_path/resolved.txt" | wc -l 
dnsx -l "$scan_path/resolved.txt" -json -o "$scan_path/dns.json" | jq -r '.a?[]?' | anew "$scan_path/ips.txt" | wc -l

#Port Scanning & HTTP Server Discovery 

nmap -T4 -vv -iL "$scan_path/ips.txt" --top-port 1 -n --open -oX "$scan_path/nmap.xml"
tew -x "$scan_path/nmap.xml" -dnsx "$scan_path/dns.json" --vhost -o "$scan_path/hostport.txt" | httpx -sr -srd "$scan_path/responses" -json -o "$scan_path/http.json"

cat "$scan_path/http.json" | jq -r '.url' | sed -e 's/:80$//g' -e 's/:443$//g' | sort -u > "$scan_path/http.txt"

#Crawling

gospider -S "$scan_path/http.txt" --json | grep '{' | jq -r '.output?' | tee "$scan_path/crawl.txt" 

#Javascript Extractor
cat "$scan_path/crawl.txt" | grep "\.js" | httpx -sr -srd js

################################################## Scan Time ####################################################

echo "Deleteing Uneccesary Files"
rm -rf "$scope_path"

## Scan Time
end_time=$(date +%s)
seconds="$(expr $end_time - $timestamp)"
time=""

if [[ "$seconds" -gt 59 ]]
then
	minutes=$(expr $seconds / 60)
	time="$minutes minutes"
else
	time="$seconds seconds"
fi

echo "Scan $id took $time"



################################################## End ####################################################






