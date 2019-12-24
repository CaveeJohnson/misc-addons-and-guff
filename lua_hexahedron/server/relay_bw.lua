hook.Add('Discord_ParseText', 'Discord_BWFix', function(text, ply)
    local parse = markup_quickParse or quick_parse
    if parse then return parse(text, ply) end
end)

hook.Add('Discord_ParseTeam', 'Discord_BWFix', function(team)
    if chatexp then return team == CHATMODE_TEAM end
end)
