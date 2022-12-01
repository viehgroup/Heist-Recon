check1=$(echo $PATH)
if echo "$check1" | grep -q "/usr/local/go/bin"; then 
	echo "Go Already Installed"
	flag=1;
else
	echo "Installing GO Language"
	wget -P /tmp https://go.dev/dl/go1.19.3.linux-amd64.tar.gz | rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/go1.19.3.linux-amd64.tar.gz
	sleep 1
	echo "Installation of GO Sucessfully..."
	flag=1;
fi
if [ flag==1 ]; then
	echo "Installing Tools Needed for Fully Automated Recon"
	go install -v github.com/hakluke/haktrails@latest
	go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
	go install -v github.com/tomnomnom/anew@latest
	go install -v github.com/d3mondev/puredns/v2@latest
	go install -v github.com/jaeles-project/gospider@latest
	go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
	go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
	go install -v github.com/pry0cc/tew@latest
	go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
	apt install jq && apt install massdns
	mv ~/go/bin/* /usr/local/go
	sleep 1
	echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
	clear
	echo "Installation Finished Exiting..."
fi
sleep 5
