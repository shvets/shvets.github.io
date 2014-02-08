1. Download Client Basic and SDK for Linux 32 bits (http://www.oracle.com/technetwork/topics/linuxsoft-082809.html).

basic-10.2.0.5.0-linux.zip
sdk-10.2.0.5.0-linux.zip

2.

sudo mkdir /opt/oracle
cd /opt/oracle

unzip basic-10.2.0.5.0-linux.zip
unzip sdk-10.2.0.5.0-linux.zip

3.

cd instantclient_10_2/
sudo ln -s libclntsh.so.10.1 libclntsh.so

4. Create the Oracle Instant Client system variable (should be inside starting scripts):

export LD_LIBRARY_PATH=/opt/oracle/instantclient_10_2

5.

export ORACLE_HOME=/opt/OraHome1 # for sqlplus only

6. Install ruby-oci8:

env LD_LIBRARY_PATH=/opt/oracle/instantclient_10_2 gem install ruby-oci8 -v 1.0.5