cloudflash-openvpn
===================


*List of APIs*
=============

<table>
  <tr>
    <th>Verb</th><th>URI</th><th>Description</th>
  </tr>
  <tr>
    <td>POST</td><td>/openvpn/server</td><td>Update the openvpn server.conf file</td>
  </tr>
  <tr>
    <td>POST</td><td>/openvpn/client</td><td>Update the openvpn client.conf file</td>
  </tr>
  <tr>
    <td>POST</td><td>/openvpn/server/:server/users</td><td>Add user to server configuration</td>
  </tr>
  <tr>
    <td>GET</td><td>/openvpn/server</td><td>Describe server openvpn info</td>
  </tr>
  <tr>
    <td>GET</td><td>/openvpn/server/:id</td><td>Describe server server-id openvpn info</td>
  </tr>
  <tr>
    <td>GET</td><td>/openvpn/client</td><td>Describe client openvpn info</td>
  </tr>
  <tr>
    <td>DELETE</td><td>/openvpn/server/:id/users/:user</td><td>Delete user from server with server-id</td>
  </tr>
  <tr>
    <td>DELETE</td><td>/openvpn/server/:server</td><td>Delete server-id info  from server</td>
  </tr>

  <tr>
    <td>DELETE</td><td>/openvpn/client/:client</td><td>Delete client-id info from client</td>
  </tr>

</table>


*OpenVPN API*
=============

Post openvpn server configuration
----------------------------------

    Verb      URI                Description
    POST    /openvpn/server	    Update the openvpn server.conf file.


**Example Request and Response**

### Request JSON
    
    {
        "port": 7000,
        "dev": "tun",
        "proto": "udp",
        "ca": "/etc/ca-bundle.pem",
        "dh": "/etc/dh1024.pem",
        "cert": "/etc/identity/snap.cert",
        "key": "/etc/identity/snap.key",
        "server": "172.17.0.0 255.255.255.0",
        "ifconfig-pool-persist": "/etc/openvpn/ip.map",
        "script-security": "3 system",
        "multihome": true,
        "management": "127.0.0.1 2020",
        "cipher": "AES-256-CBC",
        "tls-cipher": "AES256-SHA",
        "auth": "SHA1",
        "topology": "subnet",
        "route-gateway": "172.17.0.1",
        "client-config-dir": "/config/openvpn/ccd",
        "ccd-exclusive": true,
        "client-to-client": true,
        "route": [
            "192.168.0.0 255.255.255.0",
            "192.168.1.0 255.255.255.0"
        ],
        "push": [
            "route 192.168.3.0 255.255.255.0",
            "comp-lzo no"
        ],
        "tls-timeout": 10,
        "max-clients": 254,
        "persist-key": true,
        "persist-tun": true,
        "status": "/var/log/server-status.log",
        "keepalive": "5 45",
        "comp-lzo": "no",
        "sndbuf": 262144,
        "rcvbuf": 262144,
        "txqueuelen": 500,
        "replay-window": "512 15",
        "duplicate-cn": true,
        "log-append": "/var/log/vpn-general.log",
        "verb": 3,
        "mlock": true
    }
    
### Response JSON   

    

    {
       "id": "e06f3da5-3d1e-4eae-8647-b18cd59b418d",
       "config":
       {
           "port": 7000,
           "dev": "tun",
           "proto": "udp",
           "ca": "/etc/ca-bundle.pem",
           "dh": "/etc/dh1024.pem",
           "cert": "/etc/identity/snap.cert",
           "key": "/etc/identity/snap.key",
           "server": "172.17.0.0 255.255.255.0",
           "ifconfig-pool-persist": "/etc/openvpn/ip.map",
           "script-security": "3 system",
           "multihome": true,
           "management": "127.0.0.1 2020",
           "cipher": "AES-256-CBC",
           "tls-cipher": "AES256-SHA",
           "auth": "SHA1",
           "topology": "subnet",
           "route-gateway": "172.17.0.1",
           "client-config-dir": "/config/openvpn/ccd",
           "ccd-exclusive": true,
           "client-to-client": true,
           "route":
           [
               "192.168.0.0 255.255.255.0",
               "192.168.1.0 255.255.255.0"
           ],
           "push":
           [
               "route 192.168.3.0 255.255.255.0",
               "comp-lzo no"
           ],
           "tls-timeout": 10,
           "max-clients": 254,
           "persist-key": true,
           "persist-tun": true,
           "status": "/var/log/server-status.log",
           "keepalive": "5 45",
           "comp-lzo": "no",
           "sndbuf": 262144,
           "rcvbuf": 262144,
           "txqueuelen": 500,
           "replay-window": "512 15",
           "duplicate-cn": true,
           "log-append": "/var/log/vpn-general.log",
           "verb": 3,
           "mlock": true
       }
    }






Upon error, error code 500 will be returned

Post openvpn client configuration
----------------------------------

    Verb	URI	        	 	   Description
    POST	/openvpn/client	       Update the openvpn server.conf file.


**Example Request and Response**

### Request JSON
    
    {
        "pull": true,
        "tls-client": true,
        "dev": "tun",
        "remote": "raviserver 7000",
        "proto": "udp",
        "ca": "/home/calsoft-admin/openvpn/keys/ca.crt",
        "dh": "/home/calsoft-admin/openvpn/keys/dh1024.pem",
        "cert": "/home/calsoft-admin/openvpn/keys/client1.crt",
        "key": "/home/calsoft-admin/openvpn/keys/client1.key",
        "cipher": "AES-256-CBC",
        "tls-cipher": "AES256-SHA",
        "push":
        [
            "route 192.168.122.0 255.255.255.0"
        ],
        "persist-key": true,
        "persist-tun": true,
        "status": "/var/log/server-status.log",
        "comp-lzo": "no",
        "verb": 3,
        "mlock": true
    }
    

   
### Response JSON

    {
       "id": "9c70d5d1-83a5-472b-84eb-708e8a7564f8",
       "config":
       {
           "pull": true,
           "tls-client": true,
           "dev": "tun",
           "remote": "raviserver 7000",
           "proto": "udp",
           "ca": "/home/calsoft-admin/openvpn/keys/ca.crt",
           "dh": "/home/calsoft-admin/openvpn/keys/dh1024.pem",
           "cert": "/home/calsoft-admin/openvpn/keys/client1.crt",
           "key": "/home/calsoft-admin/openvpn/keys/client1.key",
           "cipher": "AES-256-CBC",
           "tls-cipher": "AES256-SHA",
           "push":
           [
               "route 192.168.122.0 255.255.255.0"
           ],
           "persist-key": true,
           "persist-tun": true,
           "status": "/var/log/server-status.log",
           "comp-lzo": "no",
           "verb": 3,
           "mlock": true
       }
    }



Add a User to VPN
-----------------

    Verb	URI	        	               Description
    POST	/openvpn/server/:server/users	 Add user into client-config-directory


**Example Request and Response**

### Request JSON

    {
    	"id": "d6bd1f89-dfee-44a6-8863-8a0802ee7acd",
    	"email": "master@oftheuniverse.com",
    	"push": 
         [
    	   "dhcp-option DNS x.x.x.x",
    	   "ip-win32 dynamic",
    	   "route-delay 5"
    	]
    }
### Response JSON	

    {
       "result": true
    }


Upon error, error code 500 will be returned


Delete a User from VPN
----------------------

    Verb	URI	                               Description
    DELETE	/openvpn/server/:id/users/:user	   Delete user from client-config-directory


On Success returns 200 with JSON data

**Example Request and Response**

### Response JSON

    { deleted: true }

Describe openvpn
----------------

    Verb	URI	                 Description
    GET	/openvpn/server/:id	   Show OpenVPN server info 

**Example Request and Response**


### Response JSON

    

    {
       "id": "d6bd1f89-dfee-44a6-8863-8a0802ee7acd",
       "users":
       [
           null,          
           {
               "id": "4ac5b5bb-884c-43ae-a9ca-271de189acb1",
               "email": "master@oftheuniverse.com",
               "push":
               [
                   "dhcp-option DNS x.x.x.x",
                   "ip-win32 dynamic",
                   "route-delay 5"
               ]
           },
           {
               "id": "4ac5b5bb-884c-43ae-a9ca-271de189acb1",
               "email": "master@oftheuniverse.com",
               "push":
               [
                   "dhcp-option DNS x.x.x.x",
                   "ip-win32 dynamic",
                   "route-delay 5"
               ]
           },
           {
               "id": "d6bd1f89-dfee-44a6-8863-8a0802ee7acd",
               "email": "master@oftheuniverse.com",
               "push":
               [
                   "dhcp-option DNS x.x.x.x",
                   "ip-win32 dynamic",
                   "route-delay 5"
               ]
           }
       ],
       "connections":
       [
           {
               "cname": "snap_3375.1024",
               "remote": "67.100.39.69:38371",
               "received": "1435527",
               "sent": "1129202",
               "since": "Mon Jun 25 05:23:26 2012",
               "ip": "10.1.20.0/24"
           }
       ]
    }



Describe openvpn server
-----------------------

    Verb	URI	                 Description
    GET	/openvpn/server	   Show openvpn server configuration. 

**Example Request and Response**


### Response JSON

    {
        "servers": 
        [
            {
                "id": "9e830e8d-6312-409d-b781-d2e005027f59",
                "config": 
                {
                    "port": 700,
                    "dev": "tun",
                    "proto": "udp",
                    "ca": "/etc/ca-bundle.pem",
                    "dh": "/etc/dh1024.pem",
                    "cert": "/etc/identity/snap.cert",
                    "key": "/etc/identity/snap.key",
                    "server": "172.17.0.0 255.255.255.0",
                    "script-security": "3 system",
                    "multihome": true,
                    "management": "127.0.0.1 2020",
                    "cipher": "AES-256-CBC",
                    "tls-cipher": "AES256-SHA",
                    "auth": "SHA1",
                    "topology": "subnet",
                    "route-gateway": "172.17.0.1",
                    "client-config-dir": "/config/openvpn/ccd",
                    "ccd-exclusive": true,
                    "client-to-client": true,
                    "route":
                    [
                        "192.168.0.0 255.255.255.0",
                        "192.168.1.0 255.255.255.0"
                    ],
                    "push": 
                    [
                        "route 192.168.3.0 255.255.255.0",
                        "comp-lzo no"
                    ],
                    "max-clients": 254,
                    "persist-key": true,
                    "persist-tun": true,
                    "status": "/var/log/server-status.log",
                    "keepalive": "5 45",
                    "comp-lzo": "no",
                    "sndbuf": 262144,
                    "rcvbuf": 262144,
                    "txqueuelen": 500,
                    "replay-window": "512 15",
                    "verb": 3,
                    "mlock": true
                }
            }
       ]
    }

Describe openvpn client
-----------------------

    Verb	URI	                 Description
    GET	/openvpn/client	   Show openvpn client configuration. 

**Example Request and Response**


### Response JSON    

    {
       "clients":
       [
           {
               "id": "989b12e6-564d-488d-9796-4ded01bcfbad",
               "config":
               {
                   "pull": true,
                   "tls-client": true,
                   "dev": "tun",
                   "remote": "raviserver 7000",
                   "proto": "udp",
                   "ca": "/home/calsoft-admin/openvpn/keys/ca.crt",
                   "dh": "/home/calsoft-admin/openvpn/keys/dh1024.pem",
                   "cert": "/home/calsoft-admin/openvpn/keys/client1.crt",
                   "key": "/home/calsoft-admin/openvpn/keys/client1.key",
                   "cipher": "AES-256-CBC",
                   "tls-cipher": "AES256-SHA",
                   "push":
                   [
                       "route 192.168.122.0 255.255.255.0"
                   ],
                   "persist-key": true,
                   "persist-tun": true,
                   "status": "/var/log/server-status.log",
                   "comp-lzo": "no",
                   "verb": 3,
                   "mlock": true
               }
           }
       ]
    }

Delete client configuration
---------------------------

    Verb	URI	                               Description
    DELETE	openvpn/client/:client	   Delete user from client-config-directory


On Success returns 200 with JSON data

**Example Request and Response**


### Response JSON    

    {
       "deleted": true
    }


Delete server configuration
---------------------------

    Verb	URI	                               Description
    DELETE	openvpn/server/:server	   Delete user from client-config-directory


On Success returns 200 with JSON data

**Example Request and Response**

### Response JSON    

    {
       "deleted": true
    }


