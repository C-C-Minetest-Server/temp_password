-- temp_password/init.lua
-- Assign temporary passwords to accounts
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

temp_password = {}
temp_password.private = {}
temp_password.private.modstorage = minetest.get_mod_storage()

local MP = minetest.get_modpath("temp_password")

for _, name in ipairs({
    "api",
    "gui",
    "cmd",
}) do
    dofile(MP .. "/src/" .. name .. ".lua")
end

temp_password.private = nil