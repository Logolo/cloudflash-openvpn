{@app} = require('zappajs') 8080, ->
    @configure =>
        @use 'bodyParser', 'methodOverride', @app.router, 'static'
        @set 'basepath': '/v1.0'

    @configure
        development: => @use errorHandler: {dumpExceptions: on, showStack: on}
        production: => @use 'errorHandler'


    @include '../lib/openvpn'
        



    

