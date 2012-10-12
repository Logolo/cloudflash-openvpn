chai = require 'chai'
expect = chai.expect
should = chai.should()
vpnlib = require '../lib/vpnlib.coffee'

validate = require('json-schema').validate


chai.Assertion.includeStack = true 


# sample date to test mocha test framework
http = require('http')

options = {port:80, host:'google.com'}
orgrequest = http.request(options)


vpnclient = {"pull":true,"tls-client":true,"dev":"tun","remote":"raviserver 7000","proto":"udp","ca":"/path/to/ca.crt","dh":"/path/to/dh1024.pem","cert":"/path/to/client1.crt","key":"/path/to/client1.key","cipher":"AES-256-CBC","tls-cipher":"AES256-SHA","push":["route 192.168.122.0 255.255.255.0"],"persist-key":true,"persist-tun":true,"status":"/var/log/server-status.log","comp-lzo":"no","verb":3,"mlock":true}
vpnserver = {"port":7000, 'dev':'tun', 'proto' : 'udp', 'ca' : 'string', 'dh':'', 'cert':'', 'key':'', 'server':''}
vpnuser = { "id": "d6bd1f89-dfee-44a6-8863-8a0802ee7acd" ,"email": "master@oftheuniverse.com", "push": [ "dhcp-option DNS x.x.x.x","ip-win32 dynamic","route-delay 5" ]}



vpnclient_err = {"tls-client":true,"dev":"tun","remote":"raviserver 7000","proto":"udp","ca":"/path/to/ca.crt","dh":"/path/to/dh1024.pem","cert":"/path/to/client1.crt","key":"/path/to/client1.key","cipher":"AES-256-CBC","tls-cipher":"AES256-SHA","push":["route 192.168.122.0 255.255.255.0"],"persist-key":true,"persist-tun":true,"status":"/var/log/server-status.log","comp-lzo":"no","verb":3,"mlock":true}
vpnserver_err = {"port":"7000", 'dev':'tun', 'proto' : 'udp', 'ca' : 'string', 'dh':'', 'cert':'', 'key':'', 'server':''}
vpnuser_err  = { "id": "889ace28-48e7-451a-a387-464625832891" ,"emailtest": "master@oftheuniverse.com", "push": [ "dhcp-option DNS x.x.x.x","ip-win32 dynamic","route-delay 5" ]}



describe 'Testing openvpn endpoints functions: ', ->
 

  it 'validate opnevpn clientSchema', ->
    result = null
    body = vpnclient_err 
    vpnc = new vpnlib       
    result = validate body, vpnc.clientSchema
    expect(result).to.eql({ valid: true, errors: [] })
  
  # this test is failing need to use vpnlib.clientSchema
  it 'invalid opnevpn clientSchema', ->
    result = null
    body = vpnclient_err 
    vpnic = new vpnlib           
    result = validate body, vpnic.clientSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  
  it 'validate opnevpn serverSchema', ->
    body = vpnserver        
    result = validate body, vpnlib.serverSchema
    expect(result).to.eql({ valid: true, errors: [] })

  it 'validate opnevpn userSchema', ->
    body = vpnuser        
    result = validate body, vpnlib.userSchema
    expect(result).to.eql({ valid: true, errors: [] })
  

  it 'invalid opnevpn serverSchema', ->
    body = vpnserver_err        
    result = validate body, vpnlib.serverSchema
    expect(result).to.not.eql({ valid: true, errors: [] })

  it 'invalid opnevpn userSchema', ->
    body = vpnuser_err        
    result = validate body, vpnlib.userSchema
    expect(result).to.not.eql({ valid: true, errors: [] })
  
  
  it 'Test function configvpn valid input', (done) ->
    body = request = instance = filename = result = null
    body = vpnclient        
    vpn1 = new vpnlib
    instance = vpn1.new body   
    configpath = "/config/openvpn"
    filename = configpath + "/" + "#{instance.id}.conf"
 
    vpn1.configvpn instance, filename, vpn1.clientdb, (res) =>
      setTimeout (->
         result = res 
         console.log "result: " + result   
         expect(result).to.eql({result:true})      
         done()
       ), 50  
    
  
  it 'function getServerEntryByID', ->
    body = entry = params = result = null 
    params = {}
    params.server = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'  
    vpn2 = new vpnlib
    
    entry = vpn2.getServerEntryByID params.server
    entry.should.be.an('object')
    expect(entry).to.have.property('id')

  it 'function getCcdPath', ->
    body = entry = params = result = null 
    params = {}
    params.server = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'
    vpn3 = new vpnlib
    entry = vpn3.getServerEntryByID params.server
        
    ccdpath = vpn3.getCcdPath entry
    console.log "ccdpath: " + ccdpath
    ccdpath.should.be.an('string')
    
    
  it 'function addUser ', (done) ->
    body = filename = result = null 
    body = vpnuser
    file =  if body.email then body.email else body.cname
    filename =  '/config/openvpn/ccd/#{file}'
    
    vpn4 = new vpnlib
    vpn4.addUser body, filename, (res) =>
       setTimeout (->
         result = res 
         console.log "result: " + result   
         expect(result).to.eql({result:true})      
         done()
       ), 50   
    
  
  it 'function getMgmtPort', ->
    body = entry = params = result= vpnmgmtport = null 
    params = {}
    params.id = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'
    vpn5 = new vpnlib
    entry = vpn5.getServerEntryByID params.id
        
    vpnmgmtport = vpn5.getMgmtPort entry
    console.log "vpnmgmtport: " + vpnmgmtport
    vpnmgmtport.should.be.an('string')

  it 'function getStatusFile', ->
    body = entry = params = result= serverstatus = null 
    params = {}
    params.id = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'
    vpn6 = new vpnlib
    entry = vpn6.getServerEntryByID params.id
        
    serverstatus = vpn6.getStatusFile entry
    console.log "serverstatus: " + serverstatus
    serverstatus.should.be.an('string') 
   
  it 'function getInfo', (done) ->
    body = entry = params = result= serverstatus= vpnmgmtport = result = null 
    params = {}
    params.id = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'
    vpn7 = new vpnlib
    entry = vpn7.getServerEntryByID params.id
      
    vpnmgmtport = vpn7.getMgmtPort entry
  
    serverstatus = vpn7.getStatusFile entry
    vpn7.getInfo vpnmgmtport, serverstatus, params.id, (res) =>
       setTimeout (->
         result = res 
         console.log "result: " + result   
         expect(result).to.contain.key('id')
         expect(result).to.contain.key('users')
         expect(result).to.contain.key('connections')      
         done()
       ), 50
  

  it 'function listClients ', ->
    res = null 
    vpn8 = new vpnlib

    res = vpn8.listClients()
    res.should.be.a('array')

  it 'function listClients ', ->
    res = null 
    vpn9 = new vpnlib

    res = vpn9.listServers()
    res.should.be.a('array')
   
  
  it 'function delInstance', (done) ->
    params = result = res = null 
    params = {}
    params.client = '9c70d5d1-83a5-472b-84eb-708e8a7564f8'
    
    vpn10 = new vpnlib   
    vpn10.delInstance params.client, vpn10.clientdb, (res) =>

       setTimeout (->
         result = res             
         expect(result).to.eql({deleted:true})      
         done()
       ), 50
 
  it 'function delUser', (done) ->    
    body = entry = params = serverstatus= ccdpath = result = null 
    params = {}
    params.id = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'
    params.user = '4ac5b5bb-884c-43ae-a9ca-271de189acb1'
    vpn11 = new vpnlib
    entry = vpn11.getServerEntryByID params.id
    ccdpath = vpn11.getCcdPath entry

    
    vpn11.delUser params.user, ccdpath, (res) =>
       setTimeout (->
         result = res             
         expect(result).to.eql({deleted:true})      
         done()
       ), 50
  
  it 'function delUser invalid userid', (done) ->    
    body = entry = params = serverstatus= ccdpath = result = null 
    params = {}
    params.id = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acd'
    params.user = '4ac5b5bb-884c-43ae-a9ca-271de189acb1test'
    vpn12 = new vpnlib
    entry = vpn12.getServerEntryByID params.id
    ccdpath = vpn12.getCcdPath entry

       
    vpn12.delUser params.user, ccdpath, (res) =>
       setTimeout (->
         result = res             
         expect(result).to.not.eql({deleted:true})      
         done()
       ), 50
  
  # this test failed deleting unknown client or serverid
  it 'function delInstance invalid client ID', (done) ->
    params = result = res = null 
    params = {}
    params.client = '9c70d5d1-83a5-472b-84eb-708e8a7564f8test'
    
    vpn13 = new vpnlib   
    vpn13.delInstance params.client, vpn13.clientdb, (res) =>

       setTimeout (->
         result = res             
         expect(result).to.not.eql({deleted:true})      
         done()
       ), 50
  
  it 'function getServerEntryByID for invalid ID', ->
    body = entry = params = result = null 
    params = {}
    params.server = 'd6bd1f89-dfee-44a6-8863-8a0802ee7acdtest'  
    vpn14 = new vpnlib
    
    entry = vpn14.getServerEntryByID params.server
    entry.should.not.be.an('object')

 
 
        


  

  



