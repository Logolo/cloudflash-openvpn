# validation is used by other modules
validate = require('json-schema').validate
vpnlib = require './vpnlib'
@include = ->

    vpn = new vpnlib
    configpath = "/config/openvpn"
  
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
        instance = vpn.new @body
        filename = configpath + "/" + "#{instance.id}.conf"
        vpn.configvpn instance, filename, vpn.clientdb, (res) =>
            unless res instanceof Error
                @send instance
            else
                @next new Error "Invalid openvpn client posting! #{res}"


    @del '/openvpn/client/:client': ->
        filename = configpath + "/" + "#{@params.client}.conf"
        vpn.delInstance @params.client, vpn.clientdb, filename, (res) =>
            unless res instanceof Error
                @send 204
            else
                @next res


    @post '/openvpn/server', validateServerSchema, ->
        instance = vpn.new @body
        filename = configpath + "/" + "#{instance.id}.conf"
        vpn.configvpn instance, filename, vpn.serverdb, (res) =>
            unless res instanceof Error
                @send instance
            else
                @next new Error "Invalid openvpn server posting! #{res}"
    
    @del '/openvpn/server/:server': ->
        filename = configpath + "/" + "#{@params.server}.conf"
        vpn.delInstance @params.server , vpn.serverdb, filename, (res) =>
            unless res instanceof Error
                @send 204
            else
                @next res


    @post '/openvpn/server/:server/users', validateUser, ->
        file =  if @body.email then @body.email else @body.cname
        #get ccdpath from the DB
        entry = vpn.getServerEntryByID @params.server
        console.log entry.config
        unless entry instanceof Error
            ccdpath = vpn.getCcdPath entry
            console.log 'ccdpath is ' + ccdpath
            filename = ccdpath + "/" + "#{file}"
            vpn.addUser @body, filename, (res) =>
                @send res
        else
            @next entry

    @del '/openvpn/server/:id/users/:user': ->
        #get ccdpath from the DB
        entry = vpn.getServerEntryByID @params.id
        unless entry instanceof Error
            ccdpath = vpn.getCcdPath entry
            vpn.delUser @params.user, ccdpath, (res) =>
                @send 204
        else
            @next entry

            
    @get '/openvpn/server/:id': ->
        #get vpnmgmtport from DB for this given @params.id
        entry = vpn.getServerEntryByID @params.id
        unless entry instanceof Error
            vpnmgmtport = vpn.getMgmtPort entry
            serverstatus = vpn.getStatusFile entry
            vpn.getInfo vpnmgmtport, serverstatus, @params.id, (result) =>
                @send result
        else
            @next entry

    @get '/openvpn/client': ->
        #get list of client instances from the DB
        res = vpn.listClients()
        @send res

    @get '/openvpn/server': ->
        #get list of server instances from the DB
        res = vpn.listServers()
        @send res
