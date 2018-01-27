Global TreasureList


on snx38(me, movie, group, user, fullmsg)

-- fullmsg = SmithProduction & ":" & SmithProductionChunk & ":" & BlackSmithing & ":S"

   set the itemdelimiter = ":"
   set SwitchItem = string(item 1 of fullmsg.content)
   set Chunk = string(item 2 of fullmsg.content)
   set SkillLevel = integer(item 3 of fullmsg.content)
   set WhichSkill = string(item 4 of fullmsg.content)

  if SwitchItem = "Damaged Sword, Pharaoh" then set NewItem = "Pharaoh Sword"
  if SwitchItem = "Damaged Armor, Lord's" then set NewItem = "Lord's Armor"
  if SwitchItem = "Damaged Armor, Chain" then set NewItem = "Chain Armor"
  if SwitchItem = "Damaged Helm, Plate" then set NewItem = "Plate Helm"
  if SwitchItem = "Damaged Armor, Plate" then set NewItem = "Plate Armor"
  if SwitchItem = "Damaged Armor, Argon's" then set NewItem = "Argon's Plate"
  if SwitchItem = "Damaged Armor, Ceramic" then set NewItem = "Ceramic Armor"
  if SwitchItem = "Damaged Armor, Titanium" then set NewItem = "Titanium Armor"
  if SwitchItem = "Damaged Armor, Ice" then set NewItem = "Ice Armor"
  if SwitchItem = "Damaged Armor, Fire" then set NewItem = "Fire Armor"
  if SwitchItem = "Damaged Shield, Small" then set NewItem = "Small Shield"
  if SwitchItem = "Damaged Hammer, War" then set NewItem = "War Hammer"
  if SwitchItem = "Damaged Hammer, Thor's" then set NewItem = "Thor's Hammer"
  if SwitchItem = "Damaged Shield, Pharaoh" then set NewItem = "Pharaoh Shield"
  if SwitchItem = "Damaged Helm, Pharaoh" then set NewItem = "Pharaoh Helm"
  if SwitchItem = "Damaged Shield, Ice" then set NewItem = "Ice Shield"
  if SwitchItem = "Damaged Shield, Fire" then set NewItem = "Fire Shield"
  if SwitchItem = "Damaged Shield, Knight" then set NewItem = "Knight Shield"
  if SwitchItem = "Damaged Helm, Chain" then set NewItem = "Chain Helm"
  if SwitchItem = "Damaged Helm, War" then set NewItem = "War Helm"
  if SwitchItem = "Damaged Helm, Demon" then set NewItem = "Demon Helm"
  if SwitchItem = "Damaged Helm, Ice" then set NewItem = "Ice Helm"
  if SwitchItem = "Damaged Helm, Fire" then set NewItem = "Fire Helm"
  if SwitchItem = "Damaged Helm, Murder" then set NewItem = "Murder Helm"
  if SwitchItem = "Damaged Shield, Steel" then set NewItem = "Steel Shield"
  if SwitchItem = "Damaged Sword, Star" then set NewItem = "Star Sword"
  if SwitchItem = "Damaged Sword, Long" then set NewItem = "Long Sword"
  if SwitchItem = "Damaged Sword, Broad" then set NewItem = "Broad Sword"
  if SwitchItem = "Damaged Sword, Knight" then set NewItem = "Knight's Sword"
  if SwitchItem = "Damaged Sword, of Hope" then set NewItem = "Sword of Hope"
  if SwitchItem = "Damaged Sword, Fire" then set NewItem = "Fire Sword"
  if SwitchItem = "Damaged Sword, Ice" then set NewItem = "Ice Sword"
  if SwitchItem = "Damaged Sword, Short" then set NewItem = "Short Sword"
  if SwitchItem = "Club" then set NewItem = "Studded Club"
  if SwitchItem = "Leather Armor" then set NewItem = "Studded Leather Armor"

--  if SwitchItem = "Cyclops Meat" then set NewItem = "Cyclops Burger"
--  if SwitchItem = "Orc Meat" then set NewItem = "Orc Pot Pie"
--  if SwitchItem = "Raw Fish" then set NewItem = "Fish Sticks"
--  if SwitchItem = "Trout" then set NewItem = "Trout Fillet"
--  if SwitchItem = "Catfish" then set NewItem = "Catfish Sandwich"
--  if SwitchItem = "Swordfish" then set NewItem = "Swordfish Steak"
--  if SwitchItem = "Crab" then set NewItem = "Crab Steak"
--  if SwitchItem = "Yeti Meat" then set NewItem = "Yeti Meat"
--  if SwitchItem = "Squid" then set NewItem = "Squid Platter"
--  if SwitchItem = "Pig" then set NewItem = "Cooked Pig"

  set CanHappen = random(250)

  if WhichSkill = "S" then
    if SkillLevel > 50 then set CanHappen = random(100)
    if SkillLevel > 60 then set CanHappen = random(90)
    if SkillLevel > 70 then set CanHappen = random(80)
    if SkillLevel > 80 then set CanHappen = random(70)
    if SkillLevel > 90 then set CanHappen = random(50)
    if SkillLevel > 98 then set CanHappen = random(35)

    if NewItem = "Plate Armor" then
      if CanHappen = 1 then set NewItem = "Plate Armor +1"
      if CanHappen = 2 then set NewItem = "Plate Armor +2"
    end if

    if NewItem = "Chain Helm" then
      if CanHappen = 1 then set NewItem = "Chain Helm +1"
      if CanHappen = 2 then set NewItem = "Chain Helm +1"
    end if

    if NewItem = "Steel Shield" then
     if CanHappen = 1 then set NewItem = "Steel Shield +1"
     if CanHappen = 2 then set NewItem = "Steel Shield +1"
    end if

    if NewItem = "War Helm" then
      if CanHappen = 1 then set NewItem = "War Helm +1"
      if CanHappen = 2 then set NewItem = "War Helm +2"
      if CanHappen = 3 then set NewItem = "War Helm +3"
    end if

    if NewItem = "Small Shield" then
      if CanHappen = 1 then set NewItem = "Small Shield +1"
    end if

    if NewItem = "Leather Armor" then
      if CanHappen = 1 then set NewItem = "Leather Armor +1"
    end if

    if NewItem = "Ice Helm" then
      if CanHappen = 1 then set NewItem = "Ice Helm +1"
    end if

    if NewItem = "Sword of Hope" then
      if CanHappen = 1 then set NewItem = "Sword of Hope +1"
    end if

    if NewItem = "Knight Shield" then
      if CanHappen = 1 then set NewItem = "Knight Shield +1"
      if CanHappen = 2 then set NewItem = "Knight Shield +2"
    end if

    if NewItem = "Pharaoh Shield" then
      if CanHappen = 1 then set NewItem = "Pharaoh Shield +1"
    end if

    if NewItem = "Knight's Sword" then
      if CanHappen = 1 then set NewItem = "Knight's Sword +1"
      if CanHappen = 2 then set NewItem = "Knight's Sword +2"
      if CanHappen = 3 then set NewItem = "Knight's Sword +3"
      if CanHappen = 4 then set NewItem = "Knight's Sword +4"
    end if

    if NewItem = "Star Sword" then
      if CanHappen = 1 then set NewItem = "Star Sword +1"
      if CanHappen = 2 then set NewItem = "Star Sword +2"
    end if
  end if

--------------------------------------------------------------------------------------------------

if WhichSkill = "S" then
	if MultiExchSaveItemX (NewItem & "-1", SwitchItem & "-1%" & Chunk & "-1",  user.name, movie) then
		sendMovieMessage(movie, user.name, "x391100",  "x") --// Level up blacksmithing
	  	set talkDat = "Your " & NewItem & " is ready!"
	  	sendMovieMessage(movie, user.name, "sqa",  talkDat)
	  	exit
	end if
end if

--if WhichSkill = "C" then
--	if ExchSaveItemX (NewItem, "1", SwitchItem, "1",  user.name, movie) then
--		sendMovieMessage(movie, user.name, "x9371100",  "x") --// Level up cooking
--	  	set talkDat = "Your " & NewItem & " is ready!"
--	  	sendMovieMessage(movie, user.name, "sqa",  talkDat)
--	  	exit
--	end if
--end if

	set talkDat = "Sorry, you do not seem to have the right items ready."
	sendMovieMessage(movie, user.name, "sqa",  talkDat)

--if MultiExchSaveItemX (NewItem & "-1", SwitchItem & "-1|" & Chunk & "-1",  user.name, movie) then
--  if WhichSkill = "S" then sendMovieMessage(movie, user.name, "x391100",  "x")
--  if WhichSkill = "C" then sendMovieMessage(movie, user.name, "x9371100",  "x")
--  set talkDat = "Your " & NewItem & " is ready!"
--  sendMovieMessage(movie, user.name, "sqa",  talkDat)
--end if

end

-------------------------------------------------------------------------------------------------------------------


on AddMeToCheaters(me, movie, group, user, fullmsg)
	set TheReason = fullMsg.content
	set theIP = GetIP(user.name, movie)
	set NewLn = user.name & " - at IP " & theIP & " - " & TheReason
	auditlog(NewLn, "cheat")
end

on ViewCheaters(me, movie, group, user, fullmsg)
	set xCheaters = file("DAT\AuditLogs\cheat_log.txt").read
 	sendMovieMessage(movie, user.name, "CheatList",  xCheaters)
end



-- //DEFUNCT FUNCTIONS for Treasure checks

on BuildTreasureList(me, movie, group, user, fullmsg)

set TreasureList = ""

repeat with x = 1 to 70

  set ThisItem = random(29)
  if ThisItem = 1 then set ThisItem = "Ruby Ring"
  if ThisItem = 2 then set ThisItem = "Ring of Quickness"
  if ThisItem = 3 then set ThisItem = "Argon's Ring"
  if ThisItem = 4 then set ThisItem = "Ring of Experience"
  if ThisItem = 5 then set ThisItem = "Mage's Ring"
  if ThisItem = 6 then set ThisItem = "Bowmaster's Ring"
  if ThisItem = 7 then set ThisItem = "300 Gold"
  if ThisItem = 8 then set ThisItem = "200 Gold"
  if ThisItem = 9 then set ThisItem = "Damaged Sword, Long"
  if ThisItem = 10 then set ThisItem = "50 Gold"
  if ThisItem = 11 then set ThisItem = "70 Gold"
  if ThisItem = 12 then set ThisItem = "80 Gold"
  if ThisItem = 13 then set ThisItem = "90 Gold"
  if ThisItem = 14 then set ThisItem = "Steel Shield"
  if ThisItem = 15 then set ThisItem = "300 Gold"
  if ThisItem = 16 then set ThisItem = "200 Gold"
  if ThisItem = 17 then set ThisItem = "Damaged Helm, Chain"
  if ThisItem = 18 then set ThisItem = "30 Gold"
  if ThisItem = 19 then set ThisItem = "30 Gold"
  if ThisItem = 20 then set ThisItem = "20 Gold"
  if ThisItem = 21 then set ThisItem = "Plate Boots"
  if ThisItem = 22 then set ThisItem = "50 Gold"
  if ThisItem = 23 then set ThisItem = "200 Gold"
  if ThisItem = 24 then set ThisItem = "Damaged Helm, Plate"
  if ThisItem = 25 then set ThisItem = "30 Gold"
  if ThisItem = 26 then set ThisItem = "30 Gold"
  if ThisItem = 27 then set ThisItem = "20 Gold"
  if ThisItem = 28 then set ThisItem = "Plate Boots"
  if ThisItem = 29 then set ThisItem = "50 Gold"

set Tss = "x15y105:x13370y13371:1000y1030:x7999y7996:x7999y7998:x39y46:x27y44:x74y51:x75y54:x79y50:x81y81:x71y69:x80y62:x82y87:x17y20:x26y25:x24y31:x20y23:x50y48:x51y45:x37y44"

  set MapX = random(21)
  set the itemdelimiter = ":"
  set MapX = item MapX of Tss

  set TreasureList = MapX & ":" & ThisItem & RETURN

end repeat

 file("DAT\SETTINGS\treasure.txt").write(TreasureList)

end


on Treasurecheck(me, movie, group, user, fullmsg)

   set TheMap = fullmsg.content
   set the Itemdelimiter = ":"
   set ItemX = item 2 of TheMap
   set ItemY = item 3 of TheMap
   set TheMap = item 1 of TheMap
   set ItsHere = 0
--   put TreaureList

   if TreasureList contains TheMap then
     set ItsHere = 1
     set DropRate = random(5)
     if DropRate <> 1 then exit

     repeat with x = 1 to 70
       if line x of TreasureList contains TheMap then
         set the itemdelimiter = ":"
         set TheItemm = item 2 of line x of TreasureList
       end if
     end repeat
   end if

   if ItsHere <> 1 then exit
   if TheItemm = "" then exit
   if TheItemm = VOID then exit

   set ItemList = file("DAT\ITEMS\" & TheMap & "i.txt").read
   set the ItemDelimiter = "|"
   set OneToPlace = 0
   if item 8 of ItemList = "" then set OneToPlace = 8
   if item 7 of ItemList = "" then set OneToPlace = 7
   if item 6 of ItemList = "" then set OneToPlace = 6
   if item 5 of ItemList = "" then set OneToPlace = 5
   if item 4 of ItemList = "" then set OneToPlace = 4
   if item 3 of ItemList = "" then set OneToPlace = 3
   if item 2 of ItemList = "" then set OneToPlace = 2
   if item 1 of ItemList = "" then set OneToPlace = 1
   if OneToPlace = 0 then exit
   set the itemdelimiter = ":"
   set TheItemDrp = TheItemm & ":" & ItemX & "-" & ItemY
   set the ItemDelimiter = "|"
   put TheItemDrp into item OnetoPlace of ItemList

   if ItemList contains "|" then
    else
    exit
   end if

   file("DAT\ITEMS\" & TheMap & "i.txt").write(ItemList)

   sendMovieMessage(movie, user.name, "drelxu", TheItemDrp)

   set TalkDat = "*** You uncover some treasure in your digging!"
   sendMovieMessage(movie, user.name, "sqa",  TalkDat)
   BuildTreasureList
end

-------------------------------------------------------------------------------------------------------------------

on SayTreasure(me, movie, group, user, fullmsg)
  set myName = user.name
  set NPCsSaidTo = fullMsg.content
  set the itemdelimiter = ":"

 -- put TreasureList & "---" & NPCsSaidTo

  repeat with x = 1 to 4
   set the itemdelimiter = ":"
    if x = 1 then set CurrentNPC = item 1 of NPCsSaidTo
    if x = 2 then set CurrentNPC = item 2 of NPCsSaidTo
    if x = 3 then set CurrentNPC = item 3 of NPCsSaidTo
    if x = 4 then set CurrentNPC = item 4 of NPCsSaidTo

  if CurrentNPC = "Cril" then
    set the itemdelimiter = ":"
    set WhichMap = item 1 of TreasureList
    set MapFile = file("DAT\MAPS\" & WhichMap & ".txt").read
    set the itemdelimiter = "#"
    set Header = ""
    if MapFile <> VOID then set Header = item 17 of MapFile

    if Header <> "" then
     set WhichContext = random(2)
     if WhichContext = 1 then set TalkDat = CurrentNPC & " says " & QUOTE & "Word has it that some treasure was buried near " & Header & "." & QUOTE
     if WhichContext = 2 then set TalkDat = CurrentNPC & " says " & QUOTE & "A man came in here earlier and said he heard some treasure was near " & Header & "." & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
   end if
  end if

  if CurrentNPC = "Galor" then
    set the itemdelimiter = ":"
    set WhichMap = item 1 of TreasureList
    set MapFile = file("DAT\MAPS\" & WhichMap & ".txt").read
    set the itemdelimiter = "#"
    set Header = ""
    if MapFile <> VOID then set Header = item 17 of MapFile

    if Header <> "" then
     set WhichContext = random(2)
     if WhichContext = 1 then set TalkDat = CurrentNPC & " says " & QUOTE & "Word has it that some treasure was buried near " & Header & "." & QUOTE
     if WhichContext = 2 then set TalkDat = CurrentNPC & " says " & QUOTE & "A man came in here earlier and said he heard some treasure was near " & Header & "." & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
    end if
  end if

  if CurrentNPC = "Ratmas" then
    set the itemdelimiter = ":"
    set WhichMap = item 1 of TreasureList
    set MapFile = file("DAT\MAPS\" & WhichMap & ".txt").read
    set the itemdelimiter = "#"
    set Header = ""
    if MapFile <> VOID then set Header = item 17 of MapFile

    if Header <> "" then
     set WhichContext = random(2)
     if WhichContext = 1 then set TalkDat = CurrentNPC & " says " & QUOTE & "Word has it that some treasure was buried near " & Header & "." & QUOTE
     if WhichContext = 2 then set TalkDat = CurrentNPC & " says " & QUOTE & "A man came in here earlier and said he heard some treasure was near " & Header & "." & QUOTE
    sendMovieMessage(movie, user.name, "aqs",  TalkDat)
    end if
  end if

  if CurrentNPC = "Teral" then
    set the itemdelimiter = ":"
    set WhichMap = item 1 of TreasureList
    set MapFile = file("DAT\MAPS\" & WhichMap & ".txt").read
    set the itemdelimiter = "#"
    set Header = ""
    if MapFile <> VOID then set Header = item 17 of MapFile

    if Header <> "" then
     set WhichContext = random(2)
     if WhichContext = 1 then set TalkDat = CurrentNPC & " says " & QUOTE & "Word has it that some treasure was buried near " & Header & "." & QUOTE
     if WhichContext = 2 then set TalkDat = CurrentNPC & " says " & QUOTE & "A man came in here earlier and said he heard some treasure was near " & Header & "." & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
    end if
  end if


  if CurrentNPC = "Vin" then
    set the itemdelimiter = ":"

    set WhichMap = item 1 of TreasureList
    set MapFile = file("DAT\MAPS\" & WhichMap & ".txt").read
    set the itemdelimiter = "#"
    set Header = ""
    if MapFile <> VOID then set Header = item 17 of MapFile

    if Header <> "" then
     set WhichContext = random(2)
     if WhichContext = 1 then set TalkDat = CurrentNPC & " says " & QUOTE & "Word has it that some treasure was buried near " & Header & "." & QUOTE
     if WhichContext = 2 then set TalkDat = CurrentNPC & " says " & QUOTE & "A man came in here earlier and said he heard some treasure was near " & Header & "." & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
    end if
  end if

  end repeat
end
