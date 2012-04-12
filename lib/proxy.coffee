# Copyright (C) 2012 Vincent Ollivier
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

http = require('http')
url = require('url')
net = require('net')
util = require('util')
querystring = require('querystring')

log = require('./log')
form = require('./form')
session = require('./session')

http.globalAgent.maxSockets = 512

proxy = http.createServer (clientReq, clientRes) ->
    options = url.parse(clientReq.url)
    options.method = clientReq.method
    options.headers = clientReq.headers

    # Route to local form
    # TODO: use connect vhost?
    if options.host is 'junla'
        switch options.method
            when 'POST'
                return form.post(clientReq, clientRes, session)
            else
                return form.get(clientReq, clientRes, session)

    # Redirect to local form if session is expired
    if session.timeout(clientReq)
        return form.redirect(clientReq, clientRes)

    # Proxy request
    serverReq = http.request options, (serverRes) ->
        log.access(clientReq, serverRes)
        clientRes.writeHead(serverRes.statusCode, serverRes.headers)
        serverRes.pipe(clientRes)

    clientReq.pipe(serverReq)


    serverReq.on 'error', (e) ->
        switch e.code
            when 'ENOTFOUND'
                # TODO: log response
                clientRes.writeHead(404)
                clientRes.end()
            when 'ECONNREFUSED', 'ECONNRESET'
                # TODO: log response
                clientRes.writeHead(502)
                clientRes.end()
            when 'ETIMEDOUT'
                # TODO: log response
                clientRes.writeHead(504)
                clientRes.end()
            else
                switch e.message
                    when 'Parse Error'
                        bytesExpected = serverReq.res.headers['content-length']
                        msg = "Parse Error: expected #{bytesExpected} bytes " +
                              "but parsed #{e.bytesParsed}"
                        util.log(msg)
                    else
                        console.log(serverReq)
                        console.log(e)
                        console.trace(e)

#proxy.on 'connection', (clientSocket) ->

proxy.on 'upgrade', (req, clientSocket, upgradeHead) ->
    switch req.method
        when 'CONNECT'
            # See RFC 2817 HTTP Upgrade to TLS
            [host, port] = req.url.split ':'
            serverSocket = net.connect port, host, ->
                # TODO: log response
                clientSocket.write('HTTP/1.1 200 Connection Established\n')
                clientSocket.write('Proxy-agent: Junla/0.0.1\n')
                clientSocket.write('\n')
                clientSocket.pipe(serverSocket)

            serverSocket.pipe(clientSocket)

            serverSocket.on 'error', (e) ->
                switch e.code
                    when 'ENOTFOUND'
                        # TODO: log response
                        clientSocket.write('HTTP/1.1 404 No Such Domain\n')
                        clientSocket.write('\n')
                    else
                        console.log(e)
                        console.trace(e)

proxy.on 'clientError', (e) ->
    console.log('proxy client error: ', e)
    console.trace(e)

proxy.on 'listen', (e) ->
    console.log(e)

proxy.on 'error', (e) ->
    switch e.code
        when 'EADDRINUSE'
            # proxy.listen() error, startup script must deal with this
        else
            console.log('proxy error: ', e)
            console.trace(e)

proxy.init = (options) ->
    log.init(options.log)
    session.log = log

module.exports = proxy
