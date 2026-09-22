local musicSource
local function windowOpen()
    return BalatroCanvas and BalatroCanvas:IsShown()
end
local function syncMusic()
    if musicSource and musicSource.playing and (musicSource.volume or 1) > 0 and windowOpen() then
        if not musicSource.started then
            PlayMusic(musicSource.path)
            musicSource.started = true
        end
    elseif musicSource and musicSource.started then
        StopMusic()
        musicSource.started = false
    end
end
_G.BalatroSyncMusic = syncMusic
_G.love.audio = {
    newSource = function(path, type)
        local wPath = "Interface\\AddOns\\Balatro\\" .. string.gsub(path, "/", "\\")
        return {
            path = wPath,
            type = type,
            volume = 1,
            play = function(self)
                if self.type == "stream" then
                    musicSource, self.playing = self, true
                    syncMusic()
                elseif not (BalatroProfile and BalatroProfile.sfxOff) and windowOpen() then
                    PlaySoundFile(self.path, "Master")
                end
            end,
            stop = function(self)
                if self.type == "stream" then
                    self.playing = false
                    syncMusic()
                end
            end,
            pause = function(self)
                if self.stop then
                    self:stop()
                end
            end,
            isPlaying = function(self)
                return self.playing == true
            end,
            setVolume = function(self, v)
                self.volume = tonumber(v) or 1
                if self.type == "stream" then
                    syncMusic()
                end
            end,
            setLooping = function() end,
        }
    end,
    play = function(source)
        source:play()
    end,
    stop = function()
        if musicSource then
            musicSource:stop()
        end
    end,
}
