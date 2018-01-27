on startCTF(ONOFF, movie)
	Global CTF, maxPerTeam, bTeam, rTeam
	Global CTFprice
	--, bDM, rDM

	if ONOFF = "BUILD" then set CTF = "BUILD"
	if ONOFF = "OFF" then set CTF = "OFF"

	set bTeam = 0
	set rTeam = 0

	--set bDM = "x1000y992:5-5"
	--set rDM = "x1000y992:5-10"

	set maxPerTeam = 1
	set CTFPrice = 50

	file("DAT\GameEvents\CTFTemp\bTeam.txt").write("@:")
	file("DAT\GameEvents\CTFTemp\rTeam.txt").write("@:")
	file("DAT\GameEvents\CTFTemp\score.txt").write("")
	file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").write("")

	resetFlags(movie)
	sendMovieMessage(movie, "@Allusers", "broadcast|5", "Capture The Flag has started! Type '+Join CTF' to play!")
end startCTF

on CTFLeaveTeam(user, movie)
	Global CTF

	if CTF = "OFF" then exit

	set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	if bTeamFile contains ":" & user.name & ":" then
		set n = 2
		repeat while item n of bTeamFile <> ""
			if item n of bTeamFile = user.name then
				put "@@" into item n of bTeamFile
				exit repeat
			end if
			set n = n + 1
		end repeat
		CTFRestoreChar(user.name, movie)
		file("DAT\GameEvents\CTFTemp\bTeam.txt").write(bTeamFile)
		sendMovieMessage(movie, user.name, "CTFGroups", "LeaveBlue")
	else if rTeamFile contains ":" & user.name & ":" then
		set n = 2
		repeat while item n of rTeamFile <> ""
			if item n of rTeamFile = user.name then
				put "@@" into item n of rTeamFile
				exit repeat
			end if
			set n = n + 1
		end repeat
		CTFRestoreChar(user.name, movie)
		file("DAT\GameEvents\CTFTemp\rTeam.txt").write(rTeamFile)
		sendMovieMessage(movie, user.name, "CTFGroups", "LeaveRed")
	end if

end CTFLeaveTeam

on CTFJoinTeam(user, movie)
	Global CTF

	if CTF <> "BUILD" then
		sendMovieMessage(movie, user.name, "sqa", "Capture The Flag has not yet started!")
		exit
	end if

	global CTF, maxPerTeam, bTeam, rTeam
	set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	if (bTeamFile contains ":" & user.name & ":") or (rTeamFile contains ":" & user.name & ":") then
		sendMovieMessage(movie, user.name, "sqa", "You are already playing CTF!")
		exit
	end if

	if bTeam = rTeam then
		put user.name & ":" after bTeamFile
		file("DAT\GameEvents\CTFTemp\bTeam.txt").write(bTeamFile)

		set bTeam = bTeam + 1

		sendMovieMessage(movie, user.name, "CTFGroups", "JoinBlue")
		sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", user.name & " has joined the BLUE team! Capture The Red Flag!")
		CTFCreateChar(user, movie, "blue")

	else
		put user.name & ":" after rTeamFile
		file("DAT\GameEvents\CTFTemp\rTeam.txt").write(rTeamFile)

		set rTeam = rTeam + 1

		sendMovieMessage(movie, user.name, "CTFGroups", "JoinRed")
		sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", user.name & " has joined the RED team! Capture The Blue Flag!")
		CTFCreateChar(user, movie, "red")

	end if

	if (bTeam = maxPerTeam) and (rTeam = maxPerTeam) then
		set CTF = "ON"
		resetFlags(movie)
	end if
end CTFJoinTeam

on CTFRestoreChar(uName, movie)
	set savei = the itemdelimiter

	if string(uName) = "" then exit

	set charFile = file("DAT\GameEvents\CTFTemp\" & uName & ".txt").read
	set charItemFile = file("DAT\GameEvents\CTFTemp\" & uName & "-i.txt").read
	set dmFile = file("DAT\GameEvents\CTFTemp\" & uName & "-dm.txt").read

	set oCharFile = file("DAT\Char\" & uName & ".txt").read
	set the itemdelimiter = "/"

	set CF = item 1 of charFile  --[filename`username:password:body:lastname:startingmap:startingmappoint]
	set oCF = item 1 of oCharFile -- [filename`username:password:body:lastname:startingmap:startingmappoint]

	set the itemdelimiter = ":"
	put item 5 of oCF into item 5 of CF -- startingmap
	put item 6 of oCF into item 6 of CF -- startingmappoint

	set the itemdelimiter = "/"
	put CF into item 1 of charFile

	put "CF = " & CF

	file("DAT\Char\" & uName & ".txt").write(charFile)
	file("DAT\Char\" & uName & "-i.txt").write(charItemFile)
	file("DAT\DM\" & uName & ".txt").write(dmFile)

	sendMovieMessage(movie, uName, "inx", charItemFile)
	sendMovieMessage(movie, uName, "LoadCharFile", charFile)
	sendMovieMessage(movie, uName, "Warp1937931", "!!! !!! " & dmFile)

	set the itemdelimiter = savei
end

on CTFBackupChar(user, movie)

	set charFile = file("DAT\Char\" & user.name & ".txt").read
	set charItemFile = file("DAT\Char\" & user.name & "-i.txt").read
	set dmFile = file("DAT\DM\" & user.name & ".txt").read

	file("DAT\GameEvents\CTFTemp\" & user.name & ".txt").write(charFile)
	file("DAT\GameEvents\CTFTemp\" & user.name & "-i.txt").write(charItemFile)
	file("DAT\GameEvents\CTFTemp\" & user.name & "-dm.txt").write(dmFile)

end

on CTFCreateChar(user, movie, teamcolor)

	-- Global bDM, rDM

	CTFBackupChar(user, movie)

	set oCharFile = file("DAT\Char\" & user.name & ".txt").read
	set oDmFile = file("DAT\DM\" & user.name & ".txt").read

	--------------------------------
	-- //Read the right source file
	--------------------------------
	if teamcolor = "blue" then
		set charFile = file("DAT\GameEvents\bTeamC.txt").read
		set charItemFile = file("DAT\GameEvents\bTeamC-i.txt").read
	else
		set charFile = file("DAT\GameEvents\rTeamC.txt").read
		set charItemFile = file("DAT\GameEvents\rTeamC-i.txt").read
	end if

	--------------------------------
	-- //Write ItemsFile
	--------------------------------
	file("DAT\CHAR\" & String(user.name) & "-i.txt").write(charItemFile)

	--"------------------------------
	-- // Write StatsFile
	--------------------------------

	set the itemdelimiter = "/"

	set CF = item 1 of charFile  --[filename`username:password:body:lastname:startingmap:startingmappoint]
	set oCF = item 1 of oCharFile -- [filename`username:password:body:lastname:startingmap:startingmappoint]

	set the itemdelimiter = ":"

	--put item 5 of CF into item 5 of oCF -- startingmap
	--put item 6 of CF into item 6 of oCF -- startingmappoint

	set nDM = parseWarp(item 5 of CF & ":" & item 6 of CF)

	set the itemdelimiter = "/"
	put oCF into item 1 of charFile

	set the itemdelimiter = ":"
	put item 14 of oCharFile into item 14 of charFile -- gender

	file("DAT\Char\" & user.name & ".txt").write(charFile)

	--"------------------------------
	-- // Write DM file
	--------------------------------

	file("DAT\DM\" & user.name & ".txt").write(nDM)

	sendMovieMessage(movie, user.name, "inx", charItemFile)
	sendMovieMessage(movie, user.name, "LoadCharFile", charFile)
	sendMovieMessage(movie, user.name, "Warp1937931", "!!! !!! " & nDM)

end

on calculateCTFScore(charName, movie)
	--// Do this when the character dies
	set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	if bTeamFile contains ":" & charName & ":" then
		set ctfScore = file("DAT\GameEvents\CTFTemp\score.txt").read

		set the itemdelimiter = ":"
		set bScore = integer(item 1 of ctfScore)
		set rScore = integer(item 2 of ctfScore)

		set bScore = bScore + 1
		sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", "The Blue Team has scored another point!")
		sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", "The Blue Team has scored another point!")
		if bScore = 3 then
			sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", "Congratulations to the Blue team! They have Captured The Flags!!")
			sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", "Congratulations to the Blue team! They have Captured The Flags!!")
			endCTFGame(movie)
			giveCTFPrizes("Blue", movie)
			file("DAT\GameEvents\CTFTemp\bTeam.txt").write("")
			file("DAT\GameEvents\CTFTemp\rTeam.txt").write("")
			file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").write("")
			file("DAT\GameEvents\CTFTemp\score.txt").write("")
			exit
		end if

	else if rTeamFile contains ":" & charName & ":" then
		set ctfScore = file("DAT\GameEvents\CTFTemp\score.txt").read

		set the itemdelimiter = ":"
		set bScore = integer(item 1 of ctfScore)
		set rScore = integer(item 2 of ctfScore)

		set rScore = rScore + 1
		sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", "The Red Team has scored another point!")
		sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", "The Red Team has scored another point!")
		if rScore = 3 then
			sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", "Congratulations to the Red team! They have Captured The Flags!!")
			sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", "Congratulations to the Red team! They have Captured The Flags!!")
			endCTFGame(movie)
			giveCTFPrizes("Red", movie)
			file("DAT\GameEvents\CTFTemp\bTeam.txt").write("")
			file("DAT\GameEvents\CTFTemp\rTeam.txt").write("")
			file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").write("")
			file("DAT\GameEvents\CTFTemp\score.txt").write("")
			exit
		end if

	end if

	file("DAT\GameEvents\CTFTemp\score.txt").write(bScore & ":" & rScore)
	warpBackToStart(movie)
	resetFlags(movie)

end

on giveCTFPrizes(whichTeam, movie)
	Global CTFprice

	if whichTeam = "blue" then
		prizeTeam = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	else
		prizeTeam = file("DAT\GameEvents\CTFTemp\rTeam.txt").read
	end if

	set CTFPrice = CTFPrice * 2

	set n = 2
	repeat while item n of prizeTeam <> ""
		if item n of prizeTeam <> "@@" then
			set uName = item n of prizeTeam
			AddSaveItemX ("Gold", CTFPrice, uName, movie)
		end if
		set n = n + 1
	end repeat

end giveCTFPrizes

on endCTFGame(movie, natural)
	Global CTF, maxPerTeam

	set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	set the itemdelimiter = ":"
	set maxPerTeam = maxPerTeam + 1

	repeat with n = 2 to maxPerTeam
		CTFRestoreChar(item n of bTeamFile, movie)
		sendMovieMessage(movie, item n of bTeamFile, "CTFGroups", "LeaveBlue")
		CTFRestoreChar(item n of rTeamFile, movie)
		sendMovieMessage(movie, item n of rTeamFile, "CTFGroups", "LeaveRed")
	end repeat

	set CTF = "OFF"
	set maxPerTeam = 0

end endCTFGame

on warpBackToStart(movie)
	Global CTF, maxPerTeam

	--set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	--set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	set bCharFile = file("DAT\GameEvents\bTeamC.txt").read
	set rCharFile = file("DAT\GameEvents\rTeamC.txt").read

	set the itemdelimiter = ":"
	set bWarp = parseWarp(item 5 of bCharFile & ":" & item 6 of bCharFile)
	set rWarp = parseWarp(item 5 of rCharFile & ":" & item 6 of rCharFile)

	--set maxPerTeam = maxPerTeam + 1

	sendMovieMessage(movie, "@BlueCTFTeam", "Warp1937931", "!!! !!! " & bWarp)
	sendMovieMessage(movie, "@RedCTFTeam", "Warp1937931", "!!! !!! " & rWarp)

	--repeat with n = 2 to maxPerTeam
	--	sendMovieMessage(movie, item n of bTeamFile, "Warp1937931", "!!! !!! " & bWarp)
	--	sendMovieMessage(movie, item n of rTeamFile, "Warp1937931", "!!! !!! " & rWarp)
	--end repeat

end warpBackToStart

on equipFlag(user, movie, flagName)
   set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	set ItemToEquip = flagName

	if bTeamFile contains ":" & user.name & ":" and ItemToEquip = "Blue Flag" then return FALSE
	if rTeamFile contains ":" & user.name & ":" and ItemToEquip = "Red Flag" then return FALSE

   set MyItemsFile = file("DAT\CHAR\" & string(user.name) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set MyEquipped = item 3 of MyItemsFile
   set the itemdelimiter = ":"

	-- // ring slot
	set EquipSlot = 4
	put ItemToEquip into item EquipSlot of MyEquipped

	set the itemdelimiter = "|"
   put MyEquipped into item 3 of MyItemsFile

	set file("DAT\CHAR\" & string(user.name) & "-i.txt").write(MyItemsFile)
	setFlagCarrier(user.name, movie)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

	if ItemToEquip = "Blue Flag" then
   	sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", user.name & " has gotten the " & ItemToEquip & "! Get them!")
   	sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", user.name & " has gotten the " & ItemToEquip & "! Protect them!")
   end if

   if ItemToEquip = "Red Flag" then
   	sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", user.name & " has gotten the " & ItemToEquip & "! Protect them!")
   	sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", user.name & " has gotten the " & ItemToEquip & "! Get them!")
	end if

   return TRUE
end equipFlag

on dropFlagOnFloor(movie, FileDT)
	set the itemdelimiter = "`"
	set CharMap = item 1 of FileDT
	set itemData = item 2 of FileDT --"//itemName:locH-LocV

	set the itemDelimiter = ":"
	set dItem = string(item 1 of itemData)

	set ItemList = file("DAT\ITEMS\" & CharMap & "i.txt").read
	set the ItemDelimiter = "|"

	if (itemList contains itemData) = FALSE then
		repeat with n = 1 to 20
			if item n of ItemList = "" then
				exit repeat
			end if
		end repeat

		set the ItemDelimiter = "|"
		put itemData into item n of ItemList

		if (ItemList contains "|") = FALSE then exit

		file("DAT\ITEMS\" & CharMap & "i.txt").write(ItemList)
		sendMovieMessage(movie, "@" & CharMap, "ChatMsg", "!!( " & itemData)

	end if

	return dItem

end dropFlagOnFloor

on dropFlag(user, movie, FileDT)
	--// FileDT = charmap`itemname:locH-locV
	set dItem = dropFlagOnFloor(movie, FileDT)
	RemSaveEQX(dItem, user.name, Movie)
	setFlagCarrier(FileDT, movie)
end dropFlag

on setFlagCarrier(charName, movie)

-- // charName can be (a) username (b) charmap:locH-locV
	set bTeamFile = file("DAT\GameEvents\CTFTemp\bTeam.txt").read
	set rTeamFile = file("DAT\GameEvents\CTFTemp\rTeam.txt").read

	if bTeamFile contains ":" & charName & ":" then
		set ctfFlagCarrier = file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").read

		set the itemdelimiter = "|"
		set bCarrier = item 1 of ctfFlagCarrier
		set rCarrier = charName
		sendMovieMessage(movie, "@RedCTFTeam", "broadcast|5", charName & " has got your flag!")

	else if rTeamFile contains ":" & charName & ":" then
		set ctfFlagCarrier = file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").read

		set the itemdelimiter = "|"
		set bCarrier = charName
		set rCarrier = item 2 of ctfFlagCarrier

		sendMovieMessage(movie, "@BlueCTFTeam", "broadcast|5", charName & " has got your flag!")
	else if charname contains " flag:" then
		set ctfFlagCarrier = file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").read

		set the itemdelimiter = "|"
		set bCarrier = item 1 of ctfFlagCarrier
		set rCarrier = item 2 of ctfFlagCarrier

		if charName contains "blue flag:" then set bcarrier = charName
		if charName contains "red flag:" then set rcarrier = charName
	end if

	file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").write(bCarrier & "|" & rCarrier)
end setFlagCarrier

on getFlagCarrier(user,movie)
	set ctfFlagCarrier = file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").read

	set the itemdelimiter = "|"
	set bCarrier = item 1 of ctfFlagCarrier
	set rCarrier = item 2 of ctfFlagCarrier

	if bCarrier contains "`" then set bCarrier = "No one"
	if rCarrier contains "`" then set rCarrier = "No one"

	sendMovieMessage(movie, user.name, "sqa", bCarrier & " is carrying the blue flag, and " & rCarrier & " is carrying the red flag.")
end getFlagCarrier

on resetFlags(movie)

	--// Clear the old flagcarrier.txt

	set ctfFlagCarrier = file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").read

	if ctfFlagCarrier <> "" then
		repeat with n = 1 to 2
			set the itemdelimiter = "|"

			if item n of ctfFlagCarrier contains "`" then
				set the itemdelimiter = "`"
				set charMap = item 1 of (item n of ctfFlagcarrier)
				set itemData = item 2 of (item n of ctfFlagcarrier)

				set ItemList = file("DAT\ITEMS\" & CharMap & "i.txt").read
				set the itemdelimiter = "|"
				if itemList contains itemData then
					repeat with nn = 1 to 20
						if item nn of ItemList = "" then
							if itemList = itemData then
								put "" into item nn of itemList
								exit repeat
							end if
						end if
					end repeat
				end if
				file("DAT\ITEMS\" & CharMap & "i.txt").write(itemList)
			else
				--put "item " & n & " of ctfFlagCarrier = " & item n of ctfFlagCarrier
				if n = 1 then RemSaveEQX("Blue Flag", (item n of ctfFlagcarrier), Movie)
				--put "item " & n & " of ctfFlagCarrier = " & item n of ctfFlagCarrier
				if n = 2 then RemSaveEQX("Red Flag", (item n of ctfFlagcarrier), Movie)
			end if
		end repeat
	end if

	set CTFflagPos = file("DAT\GameEvents\FlagPositions.txt").read

	set the itemdelimiter = "|"
	set bFlagPos = item 1 of CTFflagPos
	set rFlagPos = item 2 of CTFflagPos

	dropFlagOnFloor(movie, bFlagPos)
	dropFlagOnFloor(movie, rFlagPos)

	file("DAT\GameEvents\CTFTemp\FlagCarrier.txt").write(bFlagPos & "|" & rFlagPos)

end resetFlags