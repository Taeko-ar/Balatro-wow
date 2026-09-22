local AddOnName, Balatro = ...

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, _, name)
    if name ~= AddOnName then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")
    BalatroData = BalatroData or {}
    local legacy = {}
    for key in pairs(BalatroData) do
        if type(key) == "string" and key:match("^sdmc/Balatro%w*_.+$") then
            legacy[#legacy + 1] = key
        end
    end
    for _, key in ipairs(legacy) do
        local newKey = "save/Balatro_" .. key:match("^sdmc/Balatro%w*_(.+)$")
        BalatroData[newKey] = BalatroData[newKey] or BalatroData[key]
        BalatroData[key] = nil
    end
    local ok, err = pcall(Balatro.Boot)
    if ok then
        Balatro.Challenges.install()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Balatro boot error: " .. tostring(err))
    end
    BalatroCanvas:Hide()
end)
