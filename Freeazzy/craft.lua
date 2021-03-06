local com = require("component")
local term = require("term")


local itm = {
["draconium"] = {["tp"] = 4,["tpc"] = 0,["tpi"] = 1},
["tnt"] = {["tp"] = 1,["tpc"] = 0,["tpi"] = 2},
["dragonHeart"] = {["tp"] = 1,["tpc"] = 0,["tpi"] = 3},
["draconicCore"] = {["tp"] = 16,["tpc"] = 0,["tpi"] = 4},

}

local side

local sides = {}
sides[1] = {["name"] = "NORTH", ["ru"] = "СЕВЕР"}
sides[2] = {["name"] = "SOUTH", ["ru"] = "ЮГ"}
sides[3] = {["name"] = "WEST", ["ru"] = "ЗАПАД"}
sides[4] = {["name"] = "EAST", ["ru"] = "ВОСТОК"}

local chests = {}
chests[1] = "chest"
chests[2] = "diamond"
chests[3] = "crystal"
chests[4] = "gold"
chests[5] = "iron"
chests[6] = "obsidian"

local function getChest()
local ch = 0
for i=1,#chests do
if pcall(com.getPrimary,chests[i]) then
ch = chests[i]
return ch
end
end
if ch == 0 then
print("Ошибка: Сундук не подключен адаптером, либо выбранный сундук не поддерживается программой :(")
end
end

local chest = com.getPrimary(getChest())
local maxslot = chest.getInventorySize()

local w8 = false
local function sidesCheck()
local incount = 0
local ilast
if not w8 then print("Идет автоматическая настройка") end
for i=1,#sides do
b,n,_ = pcall(chest.pullItem,sides[i].name,1,1,1)
if b == true and n ~= nil then
incount = incount + 1
ilast = i

end
end
if incount == 1 then
w8 = false
side = sides[ilast].name
print("Автонастройка успешно завершена, предметы будут отправляться на "..sides[ilast].ru)
return sides[ilast]
elseif incount > 1 then
if not w8 then print("Автоастройка не выполнена (вплотную к сундуку стоят посторонние механизмы)") end
w8 = true
else
if not w8 then print('Автонастройка не выполнена (подключите "принимающий" мэ интерфейс к одной из сторон сундука)') end
w8 = true
end
end

local function check()
for k,v in pairs(itm) do
itm[k].tpc = 0
end
local can = false
for i=1,maxslot do
local s = chest.getStackInSlot(i)
if s ~= nil then
if itm[s.name].tpc < itm[s.name].tp then
itm[s.name].i = i 
itm[s.name].tpc = itm[s.name].tp
end
end

end
if itm.draconium.tpc == 4 and itm.tnt.tpc == 1 and itm.dragonHeart.tpc == 1 and itm.draconicCore.tpc == 16 then
can = true
end
return can
end

local function push(it)
while it.tpc > 0 do
it.tpc = it.tpc - chest.pushItem(side, it.i, it.tpc, it.tpi)
os.sleep(0)
end
end

local function extract()
local exd = 0
repeat
for i=1,maxslot do
local s = chest.getStackInSlot(i)
if s ~= nil then
if s.name == "draconicBlock" and s.qty >= 4 then
exd = exd + chest.pushItem("UP",i,4,1)
break
end
end
end
until exd == 4
end

local function craft()
if check() then
print("крафт запущен")
push(itm.draconium)
push(itm.tnt)
push(itm.dragonHeart)
os.sleep(8)
push(itm.draconicCore)
print("ожидаю появления пробужденных блоков в сундуке")
extract()
print("блоки успешно экспортированы")
end
end

while sidesCheck() == nil do
os.sleep(0)
end
print("Программа готова к использованию")
while true do
os.sleep(0)
craft()
end
