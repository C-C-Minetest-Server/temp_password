-- temp_password/src/guilua
-- Handle formspec
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

local modstorage = temp_password.private.modstorage

local C = minetest.colorize
local F = minetest.formspec_escape
local S = minetest.get_translator("temp_password")
local NS = function(s) return s end
local FS = function(...) return F(S(...)) end
local NFS = function(s) return F(s) end

local function CR(msg)
    return C("red", msg)
end

local msg = FS("You are using a temporary password to log in. Please change it to activate your account.")

local formspec = table.concat({
    "formspec_version[3]",
    "size[8,7.3]",
    "label[0.3,0.5;", FS("Please change your password"), "]",
    "box[0.2,1;7.6,0.1;grey]",
    "textarea[0.3,1.5;7.4,3;;;", msg, "]",
    "field_close_on_enter[pwd;false]",
    "pwdfield[0.3,3;7.4,0.8;pwd;", FS("New Password:"), "]",
    "field_close_on_enter[conf;false]",
    "pwdfield[0.3,4.3;7.4,0.8;conf;", FS("Confirm Password:"), "]",
    "style[quitb;bgcolor=red]",
    "button[0.3,6.0;3.5,1;quitb;", FS("Quit"), "]",
    "style[go;bgcolor=green]",
    "button[4.2,6.0;3.5,1;go;", FS("Confirm"), "]",
}, "")

local function CS(name, str)
    local info = minetest.get_player_information(name)
    local lang = info and info.lang_code or "en"
    return minetest.get_translated_string(lang, str)
end

temp_password.doing_reset = {}

function temp_password.show_formspec(name, msg)
    local new_formspec = formspec
    if msg and msg ~= "" then
        new_formspec = new_formspec .. "label[0.3,5.6;" .. F(msg) .. "]"
    end

    temp_password.doing_reset[name] = os.time()
    minetest.show_formspec(name, "temp_password:reset_form", new_formspec)
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    if temp_password.is_using_temporary_password(name) then
        minetest.log("action",
            "[temp_password] Player " .. name .. " was detected using temporary password, showing form.")
        minetest.after(0.2, temp_password.show_formspec, name)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "temp_password:reset_form" then return end
    local name = player:get_player_name()
    if not temp_password.doing_reset[name] then return end

    if fields.quitb or fields.quit or (fields.key_enter and not fields.key_enter_field) then
        minetest.log("action",
            "[temp_password] Kicked " .. name .. " because they rejected password change.")
        minetest.disconnect_player(name, CS(name, S("Password changing rejected.")))
        return
    end

    if not(fields.go or fields.key_enter_field == "pwd" or fields.key_enter_field == "conf") then
        return
    end

    if fields.pwd ~= fields.conf then
        minetest.log("action",
            "[temp_password] " .. name .. " attempted to change their password, but the passwords mismatched.")
        temp_password.show_formspec(name, CR(S("Password mismatch.")))
        return
    end

    local passwd = fields.pwd
    if passwd == "" then
        minetest.log("action",
            "[temp_password] " .. name .. " attempted to change their password, but the password is blank.")
        temp_password.show_formspec(name, CR(S("Password must not be blank.")))
        return
    end

    if passwd == modstorage:get_string("passwd_" .. name) then
        minetest.log("action",
            "[temp_password] " .. name .. " attempted to change their password, but the password is the same as before.")
        temp_password.show_formspec(name, CR(S("Password must not be the same as before.")))
        return
    end

    minetest.log("action",
            "[temp_password] Player " .. name .. " changed their password via temp_password:reset_form.")
    temp_password.set_new_password(name, passwd)
    minetest.close_formspec(name, "temp_password:reset_form")
    minetest.chat_send_player(name, S("Password changed. Enjoy!"))
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    temp_password.doing_reset[name] = nil
end)

minetest.register_globalstep(function()
    local now = os.time()
    local timeout = tonumber(minetest.settings:get("temp_password.timeout")) or 120

    for name, time in pairs(temp_password.doing_reset) do
        if now - time > timeout then
            minetest.log("action",
                "[temp_password] Kicked " .. name .. " because password changing timed out.")
            minetest.disconnect_player(name, CS(name, S("Password changing timed out.")))
        end
    end
end)
