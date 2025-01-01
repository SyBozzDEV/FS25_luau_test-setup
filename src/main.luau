



--- byModDesc is already loaded and available since it's above main.luau in the modDesc.xml
print(string.format("byModDesc included: %s", byModDesc ~= nil)) -- true

Mod = {
    MOD_NAME = g_currentModName or "FS25_TestSetup",
    MOD_DIRECTORY = g_currentModDirectory or "FS25_TestSetup",
}


print(string.format("bySource included: %s", bySource ~= nil)) -- false

--- including by_source.luau
source(Mod.MOD_DIRECTORY .. "include/by_source.luau")

print(string.format("bySource included: %s", bySource ~= nil)) -- true


--- Log result
--[[
  Load mod: FS25_TestSetup
Got included by the modDesc.xml
byModDesc included: true
bySource included: false
Got included by source()
bySource included: true
]]
