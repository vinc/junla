#!/usr/bin/env coffee

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

program = require('commander')

proxy = require('../lib/proxy')


parseInterface = (val) ->
    matches = val.match /^(?:([\w.]+|[\da-fA-F:]+):)?(\d+)$/
    return { host: null, port: null } unless matches?
    [val, host, port] = matches
    { host: host or 'localhost', port: port }

program
    .version('0.0.1')
    .option('-a, --log-access <file>', 'log access to <file>', null)
    .option('-r, --log-requests <file>', 'log requests to <file>', null)
    .option('-l, --listen <[host:]port>', 'listen on [localhost:8888]',
            parseInterface, { host: 'localhost', port: 8888 })
    .option('-x, --proxy <[host:]port>', 'use proxy on <[host:]port>',
            parseInterface)
    .parse(process.argv)

interface = "#{program.listen.host}:#{program.listen.port}"
process.title = "junla --listen #{interface}"

proxy.init
    log:
        access: program.logAccess
        requests: program.logRequests
    proxy: program.proxy

proxy.on 'error', (e) ->
    switch e.code
        when 'EADDRINUSE'
            msg = "Error: Could not bind to '#{interface}' (already in use)"
            console.error(msg)

proxy.listen(program.listen.port, program.listen.host)

console.log("Junla #{program._version}\n")
