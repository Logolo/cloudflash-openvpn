# validation is used by other modules
validate = require('json-schema').validate
@include = ->

    #variables that orchestration should set if different from these defaults
    mgmtport = 2020
    ccdpath = "/config/openvpn/ccd"
    configpath = "/config/openvpn"
    serverstatus = "/var/log/server-status.log"

    vpnlib = new require 'openvpn'
  
    validateClientSchema = ->
        result = validate @body, vpn.clientSchema
        console.log result
        return @next new Error "Invalid openvpn client configuration posting!: #{result.errors}" unless result.valid
        @next()

    validateServerSchema = ->
        result = validate @body, vpn.serverSchema
        console.log result
        return @next new Error "Invalid openvpn server configuration posting!: #{result.errors}" unless result.valid
        @next()

    validateUser = ->
        result = validate @body, vpn.userSchema
        console.log result
        return @next new Error "Invalid openvpn user configuration posting!: #{result.errors}" unless result.valid
        @next()

    @post '/openvpn/client', validateClientSchema, ->
        id = uuid.v4()
        filename = configpath + "\#{id}.conf"
        vpn.configurevpn @body, id, filename, (res) =>
            @send res

    @del '/openvpn/client/:client': ->
        vpn.delClient @params.client, @params.email, ccdpath, (res) =>
            @send res

    @post '/openvpn/server', validateServerschema, ->
        filename = configpath + "\server.conf"
        #only one server instance, identified by "server" as id in the database
        vpn.configvpn @body, "server", filename, (res) =>
            @send res
    
    @post '/openvpn/users', validateUser, ->
        file =  if @body.email then @body.email else @body.cname
        filename = ccdpath + "\#{file}"
        vpn.addUser @body, filename, (res) =>
            @send res

    @del '/openvpn/users/:user': ->
        vpn.delUser @params.user, ccdpath, (res) =>
            @send res

    @post '/openvpn/miscparams': ->
        mgmtport = @body.mgmtport if @body.mgmtport
        ccdpath = @body.ccdpath if @body.ccdpath
        configpath = @body.configpath if @body.configpath
        serverstatus = @body.serverstatus if @body.serverstatus

    @get '/openvpn/miscparams': ->
        misc =
            mgmtport:mgmport
            ccdpath:ccdpath
            configpath:configpath
            serverstatus:serverstatus
        @send misc
            
    @get '/openvpn': ->
        vpn.getInfo vpnmgmtport, serverstatus, "openvpn", (result) ->
            vpn.send result
