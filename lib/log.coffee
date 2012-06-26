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

fs = require('fs')

accessLog = null
requestsLog = null

exports.init = (options) ->
    logFileOptions =
        flags: 'a'
        encoding: 'utf8'
        mode: 0o666
    if (accessFile = options.access)?
        accessLog = fs.createWriteStream(accessFile, logFileOptions)
    if (requestsFile = options.requests)?
        requestsLog = fs.createWriteStream(requestsFile, logFileOptions)

exports.access = (req, res) ->
    return unless accessLog?

    address = req.client.remoteAddress
    ident = '-'
    user = '-'
    date = "[#{new Date().toString()}]"
    request = "\"#{req.method} #{req.url} HTTP/#{res.httpVersion}\""
    code = res.statusCode
    length = res.headers['content-length'] or '-'

    # Common Log Format
    log = [ address, ident, user, date, request, code, length ]

    accessLog.write log.join ' '
    accessLog.write '\n'

exports.request = (req, description, duration) ->
    return unless requestsLog?

    address = req.client.remoteAddress
    user = '-'
    date = "[#{new Date().toString()}]"
    description = "\"#{description}\""
    duration = duration

    # Common Log Format
    log = [ address, user, date, description, duration ]

    requestsLog.write log.join ' '
    requestsLog.write '\n'
