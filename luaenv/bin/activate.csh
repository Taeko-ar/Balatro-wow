which deactivate-lua >&/dev/null && deactivate-lua

alias deactivate-lua 'if ( -x '\''/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin/lua'\'' ) then; setenv PATH `'\''/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin/lua'\'' '\''/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin/get_deactivated_path.lua'\''`; rehash; endif; unalias deactivate-lua'

setenv PATH '/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin':"$PATH"
rehash
