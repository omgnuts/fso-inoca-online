Global QuestList, NewQuest, FactionPowers


on DisxItm(me, movie, group, user, fullmsg)

set FileDT = string(fullmsg.content)
   set the itemdelimiter = ":"
   set ItemToRemove = item 1 of FileDT
   set ItemType = item 2 of FileDT
   set ItemXY = item 3 of FileDT
   set FilName = item 4 of FileDT
   set DmgWeapon = item 5 of FileDT

   set NewItem = ItemToRemove

   if ItemToRemove = "NOTHING" then exit

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set MyEquipped = item 3 of MyItemsFile
   set the itemdelimiter = ":"

   if ItemType = "Head" then set EquipSlot = 1
   if ItemType = "Body" then set EquipSlot = 2
   if ItemType = "LeftHand" then set EquipSlot = 3
   if ItemType = "RightHand" then set EquipSlot = 4
   if ItemType = "Feet" then set EquipSlot = 5
   if ItemType = "Ring" then set EquipSlot = 6

   set WhichGear = item EquipSlot of MyEquipped

   set NewGear = WhichGear
   if WhichGear contains "Chain Armor" then set NewGear = "Damaged Armor, Chain"
   if WhichGear contains "Plate Armor" then set NewGear = "Damaged Armor, Plate"
   if WhichGear contains "Titanium Armor" then set NewGear = "Damaged Armor, Titanium"
   if WhichGear contains "Argon's Plate" then set NewGear = "Damaged Armor, Argon's"
   if WhichGear contains "Ceramic Armor" then set NewGear = "Damaged Armor, Ceramic"
   if WhichGear contains "Fire Armor" then set NewGear = "Damaged Armor, Fire"
   if WhichGear contains "Ice Armor" then set NewGear = "Damaged Armor, Ice"
   if WhichGear contains "Lord's Armor" then set NewGear = "Damaged Armor, Lord's"

   if WhichGear contains "Plate Helm" then set NewGear = "Damaged Helm, Plate"
   if WhichGear contains "Chain Helm" then set NewGear = "Damaged Helm, Chain"
   if WhichGear contains "War Helm" then set NewGear = "Damaged Helm, War"
   if WhichGear contains "Demon Helm" then set NewGear = "Damaged Helm, Demon"
   if WhichGear contains "Ice Helm" then set NewGear = "Damaged Helm, Ice"
   if WhichGear contains "Fire Helm" then set NewGear = "Damaged Helm, Fire"
   if WhichGear contains "Murder Helm" then set NewGear = "Damaged Helm, Murder"

   if WhichGear contains "Small Shield" then set NewGear = "Damaged Shield, Small"
   if WhichGear contains "Pharaoh Shield" then set NewGear = "Damaged Shield, Pharaoh"
   if WhichGear contains "Ice Shield" then set NewGear = "Damaged Shield, Ice"
   if WhichGear contains "Fire Shield" then set NewGear = "Damaged Shield, Fire"
   if WhichGear contains "Knight Shield" then set NewGear = "Damaged Shield, Knight"
   if WhichGear contains "Steel Shield" then set NewGear = "Damaged Shield, Steel"
   if WhichGear contains "Pharaoh Helm" then set NewGear = "Damaged Helm, Pharaoh"

   if WhichGear contains "Short Sword" then set NewGear = "Damaged Sword, Short"
   if WhichGear contains "Long Sword" then set NewGear = "Damaged Sword, Long"
   if WhichGear contains "Broad Sword" then set NewGear = "Damaged Sword, Broad"
   if WhichGear contains "Knight's Sword" then set NewGear = "Damaged Sword, Knight's"
   if WhichGear contains "Star Sword" then set NewGear = "Damaged Sword, Star"
   if WhichGear contains "Sword of Hope" then set NewGear = "Damaged Sword, of Hope"
   if WhichGear contains "War Hammer" then set NewGear = "Damaged Hammer, War"
   if WhichGear contains "Thor's Hammer" then set NewGear = "Damaged Hammer, Thor's"
   if WhichGear contains "Fire Sword" then set NewGear = "Damaged Sword, Fire"
   if WhichGear contains "Ice Sword" then set NewGear = "Damaged Sword, Ice"
   if WhichGear contains "Pharaoh Sword" then set NewGear = "Damaged Sword, Pharaoh"

   set TheTalkDat = "Your " & WhichGear & " shatters in battle!"
   sendMovieMessage(movie, user.name, "sqa", TheTalkDat)

   put NewGear into item EquipSlot of MyEquipped
   set the itemdelimiter = "|"
   put MyEquipped into item 3 of MyItemsFile
   file("DAT\CHAR\" & string(user.name & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

end



on ReadBook(me, movie, group, user, fullmsg)

   set FileDT = string(fullmsg.content)

   set the itemdelimiter = ":"
   set ItemName = item 1 of FileDT
   set BookName = item 1 of FileDT
   set InvenNum = integer(item 2 of FileDT)

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set the itemdelimiter = ":"

   set MyItemToDrop = item InvenNum of MyEquipment

   if MyItemToDrop contains ItemName & "-" then
     set nItem = ItemName
     set ItemNum = 1

--------------------------------------------- ****************************************
set the itemdelimiter = "|"
   set MyInv = string(item 2 of MyItemsFile)
   set the itemdelimiter = ":"

   set SearchStringItem = nItem & "-"

   repeat with x = 1 to 15
     if item x of MyInv contains SearchStringItem then
      set FileContains = TRUE
      set SpotToAddAt = x
      exit repeat
     end if
   end repeat

   if FileContains = FALSE then exit

   set CurItem = item SpotToAddAt of MyInv
   set the itemdelimiter = "-"
   set CurAmount = integer(item 2 of CurItem)
   set ItemNum = CurAmount - integer(ItemNum)

   set TheLine = nItem & "-" & ItemNum
   if ItemNum = 0 then set TheLine = ""
   if ItemNum < 0 then exit
   set the itemdelimiter = ":"
   put TheLine into item SpotToAddAt of MyInv
   set the itemdelimiter = "|"
   put MyInv into item 2 of MyItemsFile

   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)
   sendMovieMessage(movie, user.name, "lrnn", BookName)
------------------------------------------------ *********************************
   end if

end
