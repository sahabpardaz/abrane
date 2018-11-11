# Connecting to Abrane

You must connect to Abrane with the L2TP/IPSec protocol provided by our Fortigate firewall. The connection parameters are as follow:

IPsec params:
* Gateway: demo.abrane.ir
* pre-shared-key: (will be provided)
* keyexchange: ikev1
* ike: aes256-md5-modp1024,3des-sha1-modp1024,aes192-sha1-modp1024!

L2TP params:
* User/pass: (will be provided)
* Authentication method: PAP

The details of setup is different in different OS's but here are the few guids for different platforms:

* Windows: https://docs.fortinet.com/uploaded/files/1687/configuring-a-FortiGate-unit-as-an-L2TP-IPsec-server.pdf
* Ubuntu 16: https://www.kerkeni.net/en/configure-l2tp-ipsec-vpn-on-ubuntu-15-10-16-04-to-fortigate-forti-os-5-2.htm
