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
url = require('url')
util = require('util')
querystring = require('querystring')

jade = require('jade')

jadePath = "#{__dirname}/../views"
jadeFile = fs.readFileSync("#{jadePath}/form.jade", 'utf8')
jadeTpl = jade.compile(jadeFile)

# Recompile Jade file if a change is detected
# NOTE: some editors do more than just change
# a file, so we watch the directory instead.
fs.watch jadePath, persistent: false, (event, filename) ->
    return unless event is 'change' and filename is 'form.jade'
    fs.readFile "#{jadePath}/form.jade", 'utf8', (err, data) ->
        throw err if err?
        jadeTpl = jade.compile(data)
        util.log('Jade file recompiled')

exports.get = (req, res, session) ->
    redirectUrl = querystring.parse(url.parse(req.url).query).url
    locals =
        redirectUrl: redirectUrl or ''
        duration: session.duration(req) or 0
        left: Math.max(0, Math.round((session.end(req) - Date.now()) / 1000))
    data = jadeTpl(locals)

    headers =
        'Content-Length': data.length
        'Content-Type': 'text/html'

    res.writeHead(200, headers)
    res.end(data)

exports.post = (req, res, session) ->
    redirectUrl = null

    req.setEncoding('utf8')
    req.on 'data', (data) ->
        body = querystring.parse(data)
        duration = body.duration
        description = body.description
        redirectUrl = body.redirect

        session.reset(req, description, duration)

    req.on 'end', ->
        res.writeHead(303, 'Location': redirectUrl)
        res.end()

exports.redirect = (req, res) ->
    query = querystring.stringify(url: req.url)
    redirectUrl = "http://junla/?#{query}"
    res.writeHead(303, 'Location': redirectUrl)
    res.end()
