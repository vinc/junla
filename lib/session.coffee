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

sessions = {}

exports.log = null

exports.timeout = (req) ->
    # TODO: use session cookie instead of IP Address
    id = req.client.remoteAddress
    not (sessions[id]? and Date.now() < sessions[id].end)

exports.reset = (req, description, duration) ->
    # TODO: use session cookie instead of IP Address
    id = req.client.remoteAddress
    sessions[id] =
        duration: duration
        end: Date.now() + duration * 1000

    exports.log.request(req, description, duration) if exports.log?

exports.duration = (req) ->
    # TODO: use session cookie instead of IP Address
    id = req.client.remoteAddress
    sessions[id]?.duration

exports.end = (req) ->
    # TODO: use session cookie instead of IP Address
    id = req.client.remoteAddress
    sessions[id]?.end
