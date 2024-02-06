-- temp_password/src/api.lua
-- API Functions
--[[
    Copyright (C) 2024  1F616EMO

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
    USA
]]

local random = math.random
local modstorage = temp_password.private.modstorage
local PASSWD_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

function temp_password.generate_password(length)
    local rtn = ""

    for i = 1, length do
        local res = random(1, #PASSWD_CHARS)
        rtn = rtn .. string.sub(PASSWD_CHARS, res, res)
    end

    return rtn
end

function temp_password.give_temporary_password(name, length)
    local passwd = temp_password.generate_password(length)
    local passwd_hash = minetest.get_password_hash(name, passwd)

    modstorage:set_string("passwd_" .. name, passwd)
    minetest.set_player_password(name, passwd_hash)

    return passwd
end

function temp_password.is_using_temporary_password(name)
    local temp = modstorage:get_string("passwd_" .. name)
    if temp == "" then
        return false
    end

    local entry = minetest.get_auth_handler().get_auth(name)
    return minetest.check_password_entry(name, entry.password, temp)
end

function temp_password.set_new_password(name, passwd)
    local passwd_hash = minetest.get_password_hash(name, passwd)

    modstorage:set_string("passwd_" .. name, "")
    minetest.set_player_password(name, passwd_hash)
end