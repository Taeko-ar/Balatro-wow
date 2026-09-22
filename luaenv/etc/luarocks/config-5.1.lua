-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv" };
}
lua_interpreter = "lua";
variables = {
   LUA_DIR = "/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv";
   LUA_BINDIR = "/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin";
}
