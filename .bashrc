alias please='sudo'

source "$HOME/.cargo/env"

# Golang vars
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
export CHAOS_KEY=97f6445660321b71387e088dbbc8bb5e77a0d48240519ed5b5e0e607c378e687


#----- AWS -------

s3ls(){
aws s3 ls s3://$1
}

s3cp(){
aws s3 cp $2 s3://$1
}

#---- Content discovery ----
thewadl(){ #this grabs endpoints from a application.wadl and puts them in yahooapi.txt
curl -s $1 | grep path | sed -n "s/.*resource path=\"\(.*\)\".*/\1/p" | tee -a ~/tools/dirsearch/db/yahooapi.txt
}

#----- recon -----
crtndstry(){
./tools/crtndstry/crtndstry $1
}

am(){ #runs amass passively and saves to json
amass enum --passive -d $1 -json $1.json
jq .name $1.json | sed "s/\"//g"| httprobe -c 60 | tee -a $1-domains.txt
}

certprobe(){ #runs httprobe on all the hosts from certspotter
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe | tee -a ./all.txt
}

mscan(){ #runs masscan
sudo masscan -p4443,2075,2076,6443,3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,744$}
}

certspotter(){
curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1
} #h/t Michiel Prins

crtsh(){
curl -s https://crt.sh/\?q\=\%.$1\&output\=json | grep name_value | tr , '\n' | grep name_value | sed 's/name_value//g' | sed "s/\"//g" | sed 's/://g' | sed 's/\n/,/' | sed 's/\\n/,/g' | tr , '\n' | sed 's/*//g' | sed 's/^\.//g' | sort -u
}

certnmap(){
curl https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1  | nmap -T5 -Pn -sS -i - -$
} #h/t Jobert Abma

ipinfo(){
curl https://ipinfo.io/$1
}


#------ Tools ------
dirsearch(){ runs dirsearch and takes host and extension as arguments
python3 ~/tools/dirsearch/dirsearch.py -x 502,503 -u $1 -t 50 -H 'X-FORWARDED-FOR: 127.0.0.1' -b  -r
}

sqlmap(){
python ~/tools/sqlmap*/sqlmap.py -u $1
}

ncx(){
nc -l -n -vv -p $1 -k
}

crtshdirsearch(){ #gets all domains from crtsh, runs httprobe and then dir bruteforcers
curl -s https://crt.sh/?q\=%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | httprobe -c 50 | grep https | xargs -n1 -I{} python3 ~/tools/dirsearch/dirsearch.py -x 502,503 -u {} -t 50 -H 'X-FORWARDED-FOR: 127.0.0.1' -b -r
}

crtliner(){ #Made by jonathon scott to scrape subdomains
read -r -p "Get All Subdomains: " input; curl "https://crt.sh/?q=${input}" | tr '<BR>' '\n' | grep -E ".gov|.mil|.com|.us|.net|.biz|.io|.org" | sed '/href/d;/crt.sh/d;/Type:/d;/[A-Z]=/d;/ /d' | LC_ALL=C sort | LC_ALL=C uniq
}

nscan(){ #nuclei-templates scan on the Reconed URLS
sort -u ~/Recon/$1/urls.txt | nuclei -silent -t ~/nuclei-templates/ -severity critical,high,medium,low -o ~/Recon/$1/nscan.txt
}

sslscan(){
cd testssl.sh
./testssl.sh $1
cd
}

# Golang vars
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
