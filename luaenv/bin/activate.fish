if functions -q deactivate-lua
    deactivate-lua
end

function deactivate-lua
    if test -x '/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin/lua'
        eval ('/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin/lua' '/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin/get_deactivated_path.lua' --fish)
    end

    functions -e deactivate-lua
end

set -gx PATH '/var/mnt/hdd/Dev/Balatro-balatrez-wow-wotlk/luaenv/bin' $PATH
