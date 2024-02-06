-- temp_password/src/cmd.lua
-- Handle commands
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

local S = minetest.get_translator("temp_password")
local F = minetest.formspec_escape
local FS = function(...) return F(S(...)) end

local privs = { password = true }
if minetest.registered_chatcommands.setpassword and minetest.registered_chatcommands.setpassword.privs then
    privs = minetest.registered_chatcommands.setpassword.privs
elseif not minetest.registered_privileges.password then
    privs = { server = true } -- NO WAY this priv does not exist
end

local function formspec(msg)
    local formspec = table.concat({
        "formspec_version[3]",
        "size[8,7.3]",
        "label[0.3,0.5;", FS("Temporary Password Generated"), "]",
        "box[0.2,1;7.6,0.1;grey]",
        "textarea[0.3,1.5;7.4,4.3;;;", msg, "]",
        "button_exit[4.2,6.0;3.5,1;go;", FS("OK"), "]",
    }, "")

    return formspec
end

minetest.register_chatcommand("temp_password", {
    description = S("Assign temporary password to an account"),
    param = S("<username>"),
    privs = privs,
    func = function(name, param)
        param = string.gsub(param, "%s+", "")

        if param == "" then
            return false, S("Username can't be empty.")
        end
        local length = tonumber(minetest.settings:get("temp_password.length")) or 12
        local passwd = temp_password.give_temporary_password(param, length)

        local msg = table.concat({
            S("Please give the following information to the player:"),
            "",
            -- Not translated on purpose - English is what almost everyone understands
            "Username: " .. param,
            "Password: " .. passwd,
            "You will be prompted to change your password after logging in."
        }, "\n")

        minetest.log("action",
            "[temp_password] Player" .. name .. " gave " .. param .. " a temporary password.")

        if minetest.get_player_ip(name) then
            minetest.show_formspec(name, "temp_password:cmd_disp", formspec(msg))
        end

        return true, msg
    end
})