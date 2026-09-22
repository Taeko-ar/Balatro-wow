std = "lua51"
max_line_length = false
exclude_files = { "luaenv/**", "Build/**", "docs/**" }
globals = {
    "love", "G", "Top", "Sfx", "BalatroData", "BalatroProfile", "BalatroDebug", "BalatroImageDimensions",
    "BALATRO_MODULES", "BALATRO_CHALLENGES", "SlashCmdList", "SLASH_BALATRO1", "SLASH_BALATRODEBUG1",
    "BalatroCanvas", "BalatroMainMenu", "BalatroRound",
    "Object", "Node", "Moveable", "Sprite", "Card", "Deck", "Hand", "Joker", "Consumable", "Game", "Tag",
    "Popup", "TopUI", "ShopBoosterNode", "ShopVoucherNode", "JokerEffects", "HEX", "copy_table",
    "draw_rect_with_shadow", "draw_rounded_rect", "JOKER_DEFS", "CONSUMABLE_DEFS", "VOUCHER_DEFS",
    "DECK_DEFS", "DECK_DEFS_BY_ID", "STAKE_DEFS", "STAKE_DEFS_BY_ID",
    "sysDepth", "buttonHeight", "textHeight", "signHeight", "jokerHeight", "PopupHeight",
    "print", "require", "package", "os",
}
read_globals = {
    "CreateFrame", "UIParent", "Minimap", "GameTooltip", "DEFAULT_CHAT_FRAME", "GetTime",
    "GetCursorPosition", "GetScreenHeight", "IsMouseButtonDown", "MouseIsOver", "GetAddOnMetadata", "UnitOnTaxi",
    "PlayMusic", "StopMusic", "PlaySoundFile", "wipe", "time", "date", "difftime", "sin", "cos",
}
unused_args = false
