##steps
$ git clone https://github.com/groots-software-technologies/shc.git
$ cd shc/
$ sudo apt install make
$ sudo apt-get install build-essential
$ sudo bash configure
$ sudo apt-get install automake
  #if error then use 
  $automake --add-missing
$ make
$ sudo make install

$ sudo add-apt-repository ppa:neurobin/ppa
$ sudo apt-get update
$ sudo apt-get install shc

##########
#create binary using shc 
$ shc -f <source> -o <target binary name>
$ shc -f install.sh -o mysql-install

#use this 
$ shc -e "26/02/2099" -v -r -f <file name>
