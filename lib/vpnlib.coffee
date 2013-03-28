# validation is used by other modules
fileops = require 'fileops'
validate = require('json-schema').validate
exec = require('child_process').exec
uuid = require 'node-uuid'

@db = db =
    server: require('dirty') '/tmp/openvpnservers.db'
    client: require('dirty') '/tmp/openvpnclients.db'
    user: require('dirty') '/tmp/openvpnusers.db'

db.user.on 'load', ->
    console.log 'loaded openvpnusers.db'
    db.user.forEach (key,val) ->
        console.log 'found ' + key

@lookup = lookup = (id) ->
    console.log "looking up user ID: #{id}"
    entry = db.user.get id
    if entry

        if userschema?
            console.log 'performing schema validation on retrieved user entry'
            result = validate entry, userschema
            console.log result
            return new Error "Invalid user retrieved: #{result.errors}" unless result.valid

        return entry
    else
        return new Error "No such user ID: #{id}"

clientSchema =
    name: "openvpn"
    type: "object"
    additionalProperties: false
    properties:
        pull: {"type":"boolean", "required":true}
        'tls-client': {"type":"boolean", "required":true}
        dev: {"type":"string", "required":true}
        proto: {"type":"string", "required":true}
        ca: {"type":"string", "required":true}
        dh: {"type":"string", "required":true}
        cert: {"type":"string", "required":true}
        key: {"type":"string", "required":true}
        remote: {"type":"string", "required":true}
        cipher: {"type":"string", "required":false}
        'tls-cipher': {"type":"string", "required":false}
        route:
            items: { type: "string" }
        push:
            items: { type: "string" }
        'persist-key': {"type":"boolean", "required":false}
        'persist-tun': {"type":"boolean", "required":false}
        status: {"type":"string", "required":false}
        'comp-lzo': {"type":"string", "required":false}
        verb: {"type":"number", "required":false}
        mlock: {"type":"boolean", "required":false}

userSchema =
        name: "openvpn"
        type: "object"
        additionalProperties: false
        properties:
            id:    { type: "string", required: true }
            email: { type: "string", required: false}
            cname: { type: "string", required: false}
            push:
                items: { type: "string" }



    # testing openvpn validation with test schema
serverSchema =
        name: "openvpn"
        type: "object"
        additionalProperties: false
        properties:
            port:                {"type":"number", "required":true}
            dev:                 {"type":"string", "required":true}
            proto:               {"type":"string", "required":true}
            ca:                  {"type":"string", "required":true}
            dh:                  {"type":"string", "required":true}
            cert:                {"type":"string", "required":true}
            key:                 {"type":"string", "required":true}
            server:              {"type":"string", "required":true}
            'ifconfig-pool-persist': {"type":"string", "required":false}
            'script-security':   {"type":"string", "required":false}
            multihome:           {"type":"boolean", "required":false}
            management:          {"type":"string", "required":false}
            cipher:              {"type":"string", "required":false}
            'tls-cipher':        {"type":"string", "required":false}
            auth:                {"type":"string", "required":false}
            topology:            {"type":"string", "required":false}
            'route-gateway':     {"type":"string", "required":false}
            'client-config-dir': {"type":"string", "required":false}
            'ccd-exclusive':     {"type":"boolean", "required":false}
            'client-to-client':  {"type":"boolean", "required":false}
            route:
                items: { type: "string" }
            push:
                items: { type: "string" }
            'tls-timeout':       {"type":"number", "required":false}
            'max-clients':       {"type":"number", "required":false}
            'persist-key':       {"type":"boolean", "required":false}
            'persist-tun':       {"type":"boolean", "required":false}
            status:              {"type":"string", "required":false}
            keepalive:           {"type":"string", "required":false}
            'comp-lzo':          {"type":"string", "required":false}
            sndbuf:              {"type":"number", "required":false}
            rcvbuf:              {"type":"number", "required":false}
            txqueuelen:          {"type":"number", "required":false}
            'replay-window':     {"type":"string", "required":false}
            'duplicate-cn':      {"type":"boolean", "required":false}
            'log-append':        {"type":"string", "required":false}
            verb:                {"type":"number", "required":false}
            mlock:               {"type":"boolean", "required":false}

            

class vpnlib
    constructor:  ->
        console.log 'vpnlib initialized'
        @clientdb = db.client
        @serverdb = db.server
        @serverdb.on 'load', ->
            console.log 'loaded openvpnserver.db'
            @forEach (key,val) ->
                console.log 'found ' + key
        @clientdb.on 'load', ->
            console.log 'loaded openvpnclient.db'
            @forEach (key,val) ->
                console.log 'found ' + key
        console.log 'dbs ' + @clientdb + @serverdb

    getCcdPath: (entry) ->
        console.log entry.config
        return entry.config["client-config-dir"]

    getServerEntryByID: (id) ->
        entry = @serverdb.get id
        if entry
            return entry
        else
            return new Error "Invalid ID posting! #{id}"

    getMgmtPort: (entry) ->
        console.log 'entry is ' + entry.config
        console.log 'management ip port is ' + entry.config.management
        port = entry.config.management.split(" ")
        return port[1]

    getStatusFile: (entry) ->
        console.log 'status file is ' + entry.status
        return entry.config.status


    new: (config) ->
        instance = {}
        instance.id = uuid.v4()
        instance.config = config
        #instance.config.id ?= uuid.v4()
        return instance

    configvpn: (instance, filename, idb, callback) ->
        console.log 'idb is ' + idb
        service = "openvpn"
        config = ''
        for key, val of instance.config
            switch (typeof val)
                when "object"
                    if val instanceof Array
                        for i in val
                            config += "#{key} #{i}\n" if key is "route"
                            config += "#{key} \"#{i}\"\n" if key is "push"
                when "number", "string"
                    config += key + ' ' + val + "\n"
                when "boolean"
                    config += key + "\n"
        console.log 'writing vpn config onto file' + filename
        fileops.createFile filename, (result) ->
            return new Error "Unable to create configuration file #{filename}!" if result instanceof Error
            fileops.updateFile filename, config
            exec "touch /config/#{service}/on"
            try
                idb.set instance.id, instance, ->
                    console.log "#{instance.id} added to OpenVPN service configuration"
                callback({result:true})
            catch err
                console.log err
                callback(err)


    addUser: (body, filename, callback) ->
        service = "openvpn"
        config = ''
        for key, val of body
            switch (typeof val)
                when "object"
                    if val instanceof Array
                        for i in val
                            config += "#{key} #{i}\n" if key is "iroute"
                            config += "#{key} \"#{i}\"\n" if key is "push"

        id = body.id
        fileops.createFile filename, (err) ->
            return new Error "Unable to create configuration file #{filename}!" if err instanceof Error
            fileops.updateFile filename, config
            try
                '''
                TODO: implement a module to act on service
                '''
                exec "svcs #{service} sync"

                db.user.set id, body, ->
                    console.log "#{id} added to OpenVPN service configuration"
                    console.log body
                callback({result: true })
            catch err
                callback(err)

    delInstance: (id, idb, filename, callback) ->
        entry = idb.get id
        console.log 'filename to be removed ' + filename
        #spawnvpn takes care of killing openvpn instance.
        #To keep it generic, we need to call service module to stop this process
        #service module should have mapping with id to process id
        fileops.removeFile filename, (err) =>
            console.log 'result of removing file '  + err
            unless err instanceof Error
                idb.rm id, =>
                    console.log "removed VPN client ID: #{id}"
                callback(true)
            else
                error = new Error "Unable to delete the instance #{id}! #{err}" if err instanceof Error
                callback (error)

    delUser: (userid, ccdpath, callback) ->
        entry = db.user.get userid

        try
            throw new Error "user does not exist!" unless entry
            if entry.email
                file = entry.email
            else
                file = entry.cname
            filename = "#{ccdpath}" + "/#{file}"
            console.log "removing user config on #{filename}..."
            fileops.fileExists filename, (exists) ->
                if not exists
                    console.log 'file removed already'
                    err = new Error "user is already removed!"
                    callback(err)
                else
                    console.log 'remove the file'
                    fileops.removeFile filename, (err) ->
                        if err
                            callback(err)
                        else
                            console.log 'removed file'

                        db.user.rm userid, ->
                            console.log "removed VPN user ID: #{userid}"
                        callback(true)
        catch err
            callback(err)

    listServers: ->
        res = {"servers":[]}
        @serverdb.forEach (key,val) ->
            console.log 'found server ' + key
            res.servers.push val
        console.log 'listing'
        return res.servers

    listClientByID: (key) ->
        entry = @clientdb.get key
        return new Error "Entry with the given key #{key} does not exist" unless entry
        return entry

    listClients: ->
        res = {"clients":[]}
        @clientdb.forEach (key,val) ->
            console.log 'found client ' + key
            res.clients.push val unless key == "management"
        console.log 'listing'
        return res.clients

    getInfo: (port, filename, id, callback) ->
        console.log 'in getInfo'
        res =
            id: id
            users: []
            connections: []

        db.user.forEach (key,val) ->
            console.log 'found ' + key
            res.users.push val

        # TODO: should retrieve the openvpn configuration and inspect "management" and "status" property

        Lazy = require 'lazy'
        status = new Lazy
        status
            .lines
            .map(String)
            .filter (line) ->
                not (
                    /^OpenVPN/.test(line) or
                    /^Updated/.test(line) or
                    /^Common/.test(line) or
                    /^ROUTING/.test(line) or
                    /^Virtual/.test(line) or
                    /^GLOBAL/.test(line) or
                    /^UNDEF/.test(line) or
                    /^END/.test(line) or
                    /^Max bcast/.test(line))
            .map (line) ->
                #console.log "lazy: #{line}"
                return line.trim().split ','
            .forEach (fields) ->
                switch fields.length
                    when 5
                        res.connections.push {
                            cname: fields[0]
                            remote: fields[1]
                            received: fields[2]
                            sent: fields[3]
                            since: fields[4]
                        }
                    when 4
                        for conn in res.connections
                            if conn.cname is fields[1]
                                conn.ip = fields[0]
            .join =>
                console.log res
                callback(res)

        console.log "checking for live connections..."

        # OPENVPN MGMT API v1
        net = require 'net'
        conn = net.connect port, '127.0.0.1', ->
            console.log 'connection to openvpn mgmt successful!'
            response = ''
            @setEncoding 'ascii'
            @on 'prompt', =>
                @write "status\n"
            @on 'response', =>
                console.log "response: #{response}"
                status.emit 'end'
                @write "exit\n"
                @end
            @on 'data', (data) =>
                console.log "read: "+data+"\n"
                if /^>/.test(data)
                    @emit 'prompt'
                else
                    response += data
                    status.emit 'data',data
                    if /^END$/gm.test(response)
                        @emit 'response'
            @on 'end', =>
                console.log 'connection to openvpn mgmt ended!'
                status.emit 'end'
                @end

        # When we CANNOT make a connection to OPENVPN MGMT port, we fallback to checking file
        conn.on 'error', (error) ->
            console.log error
            statusfile = filename # hard-coded for now...

            console.log "failling back to processing #{statusfile}..."
            #statusfile = "openvpn-status.log" # hard-coded for now...
            fs = require 'fs'
            stream = fs.createReadStream statusfile, encoding: 'utf8'
            stream.on 'open', ->
                console.log "sending #{statusfile} to lazy status..."
                stream.on 'data', (data) ->
                    status.emit 'data',data
                stream.on 'end', ->
                    status.emit 'end'

            stream.on 'error', (error) ->
                console.log error
                status.emit 'end'

module.exports = vpnlib
module.exports.clientSchema = clientSchema
module.exports.serverSchema = serverSchema
module.exports.userSchema = userSchema
