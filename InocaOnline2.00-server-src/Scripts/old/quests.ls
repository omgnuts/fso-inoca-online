Global QuestList, NewQuest, FactionPowers

on QuestGive(me, movie, group, user, fullmsg)

	set myName = user.name
	set TheDat = fullmsg.content
	set the itemdelimiter = ":"
	set NPCsName = item 1 of TheDat
	set ItemToGive = item 2 of TheDat
	set InvLoc = integer(item 3 of TheDat)

	set ItsFaction = FALSE
	if NPCsName = "Angela" then set ItsFaction = TRUE
	if NPCsName = "Trianus" then set ItsFaction = TRUE
	if NPCsName = "Corin" then set ItsFaction = TRUE

	if ItsFaction = TRUE then
		if ItemToGive contains " Head" then

			------------------------------------------------
       	-- // Remove the item (HEAD) from the inventory
       	------------------------------------------------

			if RemSaveItemX (ItemToGive, 1, string(MyName), movie, InvLoc) then

				--------------------------------------------------------------------------------------
				-- // Check if the correct head was given (head is removed from inventory regardless)
				--------------------------------------------------------------------------------------

				set IncorrectHead = FALSE

				case NPCsName of
					"Angela":
						if ItemToGive contains "Mage's" then set IncorrectHead = TRUE
					"Trianus":
						if ItemToGive contains "Warrior's" then set IncorrectHead = TRUE
					"Corin":
						if ItemToGive contains "Adventurer's" then set IncorrectHead = TRUE
					otherwise set IncorrectHead = TRUE
				end case

				if IncorrectHead = TRUE then
					set TalkDat = NPCsName & " says " & QUOTE & "A fallen member...I'll be sure to dispose of this so that our rivals don't see our weakness." & QUOTE
					sendMovieMessage(movie, user.name, "aqs",  TalkDat)
					exit
				end if

				------------------------------------------------
				-- // Calculate the new Faction Powers
				------------------------------------------------

				set TalkDat = NPCsName & " says " & QUOTE & "You have done well in slaying one of our foes." & QUOTE
				sendMovieMessage(movie, user.name, "aqs",  TalkDat)

				set FactionPowers = file("DAT\POLITICAL\factions.txt").read
				if FactionPowers = VOID then set FactionPowers = "100:100:10 0"
				set the itemdelimiter = ":"
				set MagePower = integer(item 1 of FactionPowers)
				set WarriorPower = integer(item 2 of FactionPowers)
				set AdventurerPower = integer(item 3 of FactionPowers)

				if NPCsName = "Angela" then
					if (ItemToGive contains "Warrior's") and (WarriorPower > 0) then
						set WarriorPower = WarriorPower - 1
						set MagePower = MagePower + 1
					end if
					if (ItemToGive contains "Adventurer's") and (AdventurerPower > 0) then
						set AdventurerPower = AdventurerPower - 1
						set MagePower = MagePower + 1
					end if
					sendMovieMessage(movie, user.name, "mgfct")
				end if

				if NPCsName = "Trianus" then
					if (ItemToGive contains "Mage's") and (MagePower > 0) then
						set MagePower = MagePower - 1
						set WarriorPower = WarriorPower + 1
					end if
					if (ItemToGive contains "Adventurer's") and (AdventurerPower > 0) then
						set AdventurerPower = AdventurerPower - 1
						set WarriorPower = WarriorPower + 1
					end if
					sendMovieMessage(movie, user.name, "wrfct",  TalkDat)
				end if

				if NPCsName = "Corin" then
					if (ItemToGive contains "Warrior's") and (WarriorPower > 0) then
						set WarriorPower = WarriorPower - 1
						set AdventurerPower = AdventurerPower + 1
					end if
					if (ItemToGive contains "Mage's") and (MagePower > 0) then
						set MagePower = MagePower - 1
						set AdventurerPower = AdventurerPower + 1
					end if
					sendMovieMessage(movie, user.name, "adfct",  TalkDat)
				end if

				set FactionPowers = MagePower & ":" & WarriorPower & ":" & AdventurerPower
				file("DAT\POLITICAL\factions.txt").write(FactionPowers)

				set FactionCounter = FactionCounter + 1
				if FactionCounter >= 500 then  --// to refresh factions only after every 500 heads
					set FactionCounter = 0
					sendMovieMessage(movie,  "@AllUsers", "factnrtrn", FactionPowers)
				else
					sendMovieMessage(movie, user.name, "factnrtrn",  FactionPowers)
				end if
				exit
			end if
		end if
	end if -- // End Faction

------------------------------------------------------------------- #############################################

	set QuestScriptList = file("DAT\SETTINGS\GameDat\QuestScript.txt").read 		--" // NPCNAME:ITEMGIVE:SCRIPTCASE
	set LineToSearchFor = NPCsName & ":" & ItemToGive & ":"

	if QuestScriptList contains LineToSearchFor then
		set n = 1
		repeat while line n of QuestScriptList <> ""
			if Line n of QuestScriptList contains LineToSearchFor then
				set the itemdelimiter = ":"
				set scriptcase = item 3 of line n of QuestScriptList
				exit repeat
			end if
			set n = n + 1
		end repeat

		set the itemdelimiter = "|"
		case item 1 of scriptcase of
			"pardon":
				if RemSaveItemX (ItemToGive, 1, string(MyName), movie, InvLoc) then
					sendMovieMessage(movie, User.Name, "PRDN", NPCsName)
					set TalkDat = NPCsName & " says " & QUOTE & "I release you from your sins." & QUOTE
				else
					set TalkDat = NPCsName & " says " & QUOTE & "I'm sorry you do not seem to have the item." & QUOTE
				end if
			"barber":
				if RemSaveItemX (ItemToGive, 2, string(MyName), movie, InvLoc) then
					AddToList(user.name, "GameEvents\buyHair.txt")
					set TalkDat = NPCsName & " says " & QUOTE & "Type " & QUOTE & "/changehair hairstyle" & QUOTE & " without quotes, where hairstyle is your hairstyle choice." & QUOTE
				else
					set TalkDat = NPCsName & " says " & QUOTE & "I'm sorry you do not seem to have enough gold coins." & QUOTE
				end if
			"rental":
				if RemSaveItemX (ItemToGive, 10, string(MyName), movie, InvLoc) then
					set charFile = file("DAT\Char\" & MyName & ".txt").read
					set the itemdelimiter = "/"
					set cVale = item 4 of charFile
					set the itemdelimiter = "-"
					set rentalTime = integer(item 1 of cVale) + 24000
					put rentalTime into item 1 of cVale
					set the itemdelimiter = "/"
					put cVale into item 4 of charFile
					file("DAT\Char\" & MyName & ".txt").write(charFile)
					set TalkDat = NPCsName & " says " & QUOTE & "You have bought som time to rent any of our rented vehicles."
				else
					set TalkDat = NPCsName & " says " & QUOTE & "I'm sorry you do not seem to have enough gold coins." & QUOTE
				end if
			"warp":
				if RemSaveItemX (ItemToGive, 1, string(MyName), movie, InvLoc) then
					set WarpDat = "!!! !!! " & item 2 of scriptcase
   				sendMovieMessage(movie, user.name, "Warp1937931",  WarpDat)
   				set TalkDat = NPCsName & " says " & QUOTE & "Hey! Thanks for that. Okay, I'll show you to the place." & QUOTE
				else
					set TalkDat = NPCsName & " says " & QUOTE & "I'm sorry you do not seem to have the item." & QUOTE
				end if
			"giveItem":
				if ExchSaveItemX (item 2 of scriptcase, item 3 of scriptcase, ItemToGive, 1, string(MyName), movie, InvLoc) then
					set TalkDat = NPCsName & " says " & QUOTE & "Thank you for that. Here's your reward - " & item 2 of scriptcase & QUOTE
				else
					set TalkDat = NPCsName & " says " & QUOTE & "Please make sure you have the item and space in your inventory." & QUOTE
				end if
			"multiItem":
				if MultiExchSaveItemX (item 2 of scriptcase, item 3 of scriptcase,  user.name, movie) then
					set TalkDat = NPCsName & " says " & QUOTE & "Thank you for those. Here's your reward." & QUOTE
				else
					set TalkDat = NPCsName & " says " & QUOTE & "Please make sure you have items and space in your inventory." & QUOTE
				end if
			"getPass":
				if RemSaveItemX (ItemToGive, 1, string(MyName), movie, InvLoc) then
					ReleasePasswordX(user, movie, item 2 of scriptcase)
				else
					set TalkDat = NPCsName & " says " & QUOTE & "I'm sorry you do not seem to have the item." & QUOTE
				end if
			otherwise set scriptcase = ""
		end case
		sendMovieMessage(movie, user.name, "sqa",  TalkDat)
		exit

	end if
	set TalkDat = NPCsName & " says " & QUOTE & "Sorry I do not need that item." & QUOTE
	sendMovieMessage(movie, user.name, "sqa",  TalkDat)
	exit

end


on GetHelp(me, movie, group, user, fullmsg)
  set FileDT = fullMsg.content
  set MyName = user.name
  set FileDT = FileDT & ".txt"
  if (FileDT contains "../" or FileDT contains "..\") then exit

  set HelpFile = file("DAT\HELP\" & FileDT).read
  if HelpFile = VOID then
    set HelpFile = "There is no help on that subject!"
    sendMovieMessage(movie, user.name, "sqa",  HelpFile)
    exit
  end if
  sendMovieMessage(movie, user.name, "sqa",  HelpFile)
end



on SayFaction(me, movie, group, user, fullmsg)

 --set FLeaderName = fullMsg.content
 set MyName = user.name

  set the itemdelimiter = ":"
  set MagePower = integer(item 1 of FactionPowers)
  set WarriorPower = integer(item 2 of FactionPowers)
  set AdventurerPower = integer(item 3 of FactionPowers)

	if MagePower > WarriorPower then
		if MagePower > AdventurerPower then
			set TToSend = "The Mage Faction is in absolute power!"
		else if MagePower = AdventurerPower then
			set TToSend = "The Mage Faction & Adventurer Faction are vying for absolute power!"
		else
			set TToSend = "The Adventurer Faction is in absolute power!"
		end if
	else if MagePower < WarriorPower then
		if WarriorPower > AdventurerPower then
			set TToSend = "The Warrior Faction is in absolute power!"
		else if WarriorPower = AdventurerPower then
			set TToSend = "The Warrior Faction & Adventurer Faction are vying for absolute power!"
		else
			set TToSend = "The Adventurer Faction is in absolute power!"
		end if
	else
		if MagePower = AdventurerPower then
			set TToSend = "No faction is in absolute power!"
		else
			set TToSend = "The Mage Faction & Warrior Faction are vying for absolute power!"
		end if
	end if

	sendMovieMessage(movie, user.name, "aqs",  TToSend)
end

on Portal(me, movie, group, user, fullmsg)

   set PortalFile = file("DAT\SETTINGS\portal.txt").read
   set the itemdelimiter = "|"

	set n = 1
   repeat while item n of PortalFile <> ""
     set n = n + 1
   end repeat

   set WhichLne = random(n - 1)
   set ThePortal = item WhichLne of PortalFile

   set the itemdelimiter = ":"
   set WhichMap = item 1 of ThePortal
   set WhichX = item 2 of ThePortal
   set WhichY = item 3 of ThePortal

   set WarpDat = "!!! !!! " & WhichMap & " " & WhichX & " " & WhichY
   sendMovieMessage(movie, user.name, "Warp1937931",  WarpDat)
end

on DeathMapGo(me, movie, group, user, fullmsg) -- no use

   set myName = string(user.name)
   set ThePortal = file("DAT\DM\" & myName & ".txt").read
	if ThePortal = void then set ThePortal = file("DAT\Settings\GameDat\StartMap.txt").read

   set WarpDat = "!!! !!! " & ThePortal
	sendMovieMessage(movie, user.name, "Warp1937931",  WarpDat)
end DeathMapGo

on unboardVehicle(movie, user)
   set myName = string(user.name)
   set ThePortal = file("DAT\DM\" & myName & ".txt").read
	if ThePortal = void then set ThePortal = file("DAT\Settings\GameDat\StartMap.txt").read

   set WarpDat = "!!! !!! " & ThePortal
	sendMovieMessage(movie, user.name, "returnVehicleWarp",  WarpDat)
end unboardVehicle

-- // DEFUNCT - was used tell users which quests are there

on SayQuest(me, movie, group, user, fullmsg)
  set myName = user.name
  set NPCsSaidTo = fullMsg.content
  set the itemdelimiter = ":"
  set NPC1SaidTo = "X"
  set NPC2SaidTo = "X"
  set NPC3SaidTo = "X"
  set NPC4SaidTo = "X"

  if item 1 of NPCsSaidTo <> "" then set NPC1SaidTo = item 1 of NPCsSaidTo
  if item 2 of NPCsSaidTo <> "" then set NPC2SaidTo = item 2 of NPCsSaidTo
  if item 3 of NPCsSaidTo <> "" then set NPC3SaidTo = item 3 of NPCsSaidTo
  if item 4 of NPCsSaidTo <> "" then set NPC4SaidTo = item 4 of NPCsSaidTo

  set QuestList = file("DAT\SETTINGS\Quests.txt").read

  if NPC1SaidTo <> "X" then
    if QuestList contains NPC1SaidTo then
       repeat with x = 1 to 40
         if line x of QuestList contains NPC1SaidTo then
            set the itemdelimiter = ":"
            set ItemIWant = item 2 of line x of QuestList
            set TalkDat = NPC1SaidTo & " says " & QUOTE & "Bring me a " & ItemIWant & " quickly and I'll reward you."
            sendMovieMessage(movie, user.name, "sqa",  TalkDat)
         end if
       end repeat
      else
     set TalkDat = NPC1SaidTo & " says " & QUOTE & "Sorry but I don't need anything right now" & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
   end if
  end if


  if NPC2SaidTo <> "X" then
    if QuestList contains NPC2SaidTo then
       repeat with x = 1 to 40
         if line x of QuestList contains NPC2SaidTo then
            set the itemdelimiter = ":"
            set ItemIWant = item 2 of line x of QuestList
            set TalkDat = NPC2SaidTo & " says " & QUOTE & "Bring me a " & ItemIWant & " quickly and I'll reward you."
            sendMovieMessage(movie, user.name, "aqs",  TalkDat)
         end if
       end repeat
      else
     set TalkDat = NPC2SaidTo & " says " & QUOTE & "Sorry but I don't need anything right now" & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
   end if
  end if

  if NPC3SaidTo <> "X" then
    if QuestList contains NPC3SaidTo then
       repeat with x = 1 to 40
         if line x of QuestList contains NPC3SaidTo then
            set the itemdelimiter = ":"
            set ItemIWant = item 2 of line x of QuestList
            set TalkDat = NPC3SaidTo & " says " & QUOTE & "Bring me a " & ItemIWant & " quickly and I'll reward you."
            sendMovieMessage(movie, user.name, "aqs",  TalkDat)
         end if
       end repeat
      else
     set TalkDat = NPC3SaidTo & " says " & QUOTE & "Sorry but I don't need anything right now" & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
   end if
  end if


  if NPC4SaidTo <> "X" then
    if QuestList contains NPC4SaidTo then
       repeat with x = 1 to 40
         if line x of QuestList contains NPC4SaidTo then
            set the itemdelimiter = ":"
            set ItemIWant = item 2 of line x of QuestList
            set TalkDat = NPC4SaidTo & " says " & QUOTE & "Bring me a " & ItemIWant & " quickly and I'll reward you."
            sendMovieMessage(movie, user.name, "aqs",  TalkDat)
         end if
       end repeat
      else
     set TalkDat = NPC4SaidTo & " says " & QUOTE & "Sorry but I don't need anything right now" & QUOTE
     sendMovieMessage(movie, user.name, "aqs",  TalkDat)
   end if
  end if


end




-- // DEFUNCT - was used to randomly increase the items in these vaults

on QuestChest

   set WhichChest = random(6)

   if WhichChest = 1 then set VaultName = "Gold Chest"
   if WhichChest = 2 then set VaultName = "Emerald Chest"
   if WhichChest = 3 then set VaultName = "Steel Chest"
   if WhichChest = 4 then set VaultName = "Wind Chest"
   if WhichChest = 5 then set VaultName = "Water Chest"
   if WhichChest = 6 then set VaultName = "Dark Chest"

   set VaultItems = file("DAT\QUESTCHEST\" & VaultName & ".txt").read

   if VaultItems = VOID then exit
   if VaultItems = "" then exit

   set TotalItems = 0

   repeat with x = 1 to 20
     if line x of VaultItems <> "" then set TotalItems = TotalItems + 1
   end repeat

   set RandomLne = random(TotalItems)
   set ItemToAdd = line RandomLne of VaultItems

   set VaultInfo = ItemToAdd & RETURN
   if VaultInfo contains "|" then exit
   file("DAT\VAULTS\" & VaultName & ".txt").write(VaultInfo)
end

--// GiveToPlayer - UNUSED

on GiveToPlayer(me, movie, group, user, fullmsg)

  set FileDT = fullMsg.content
  set MyName = user.name
  set the itemdelimiter = ":"
  set GiveToWho = item 1 of FileDT
  set WhichSlot = integer(item 2 of FileDT)
  set ItemToAdd = item 3 of FileDT


  set P2ItemFile = file("DAT\CHAR\" & string(GiveToWho) & "-i.txt").read
  set the itemdelimiter = "|"
  set HisInv = item 2 of P2ItemFile
  set the itemdelimiter = ":"

  set SpotToAddTo = 0
  set n = 1
  repeat with n = 1 to 15
  		if (item n of HisInv = "") or (item n of HisInv = "NOTHING") then
  			set SpotToAddTo = n
  			exit repeat
  		end if
  end repeat

  if SpotToAddTo = 0 then
    set TalkDat = "*** " & GiveToWho & "'s inventory is full!"
    sendMovieMessage(movie, user.name, "sqa",  TalkDat)
    exit
  end if

  put ItemToAdd into item SpotToAddTo of HisInv
  set the itemdelimiter = "|"
  put HisInv into item 2 of P2ItemFile

------------------------------------------------------------------------------------
  set P1ItemFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
  set the itemdelimiter = "|"
  set MyInv = item 2 of P1ItemFile
  set the itemdelimiter = ":"

  if item WhichSlot of MyInv = ItemToAdd then
    put "" into item WhichSlot of MyInv
   else
    exit
  end if

  set the itemdelimiter = "|"
  put MyInv into item 2 of P1ItemFile


  if P2ItemFile contains "|" then
    file("DAT\CHAR\" & string(GiveToWho & "-i") & ".txt").write(P2ItemFile)
  end if

  if P1ItemFile contains "|" then
    file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(P1ItemFile)
  end if

end

--// GiveGoldToPlayer - UNUSED

on GiveGoldToPlayer(me, movie, group, user, fullmsg)

   set TheDat = fullMsg.content
   set the itemdelimiter = ":"
   set WinnerName = item 1 of TheDat
   set LoserName = user.name
   set GoldAmount = integer(item 2 of TheDat)

   if GoldAmount < 1 then exit

   set MyItemsFile = file("DAT\CHAR\" & string(LoserName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)
   set the itemdelimiter = ":"
   set MyGold = MyGold - GoldAmount
   if MyGold < 0 then exit
   set the itemdelimiter = "|"
   put MyGold into item 1 of MyItemsFile
   file("DAT\CHAR\" & string(LoserName & "-i") & ".txt").write(MyItemsFile)

   set MyItemsFile2 = file("DAT\CHAR\" & string(WinnerName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGoldx = integer(item 1 of MyItemsFile2)
   set the itemdelimiter = ":"
   set MyGoldx = MyGoldx + GoldAmount
   set the itemdelimiter = "|"
   put MyGoldx into item 1 of MyItemsFile2
   file("DAT\CHAR\" & string(WinnerName & "-i") & ".txt").write(MyItemsFile2)
end