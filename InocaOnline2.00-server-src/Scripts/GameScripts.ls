on mainGameDispatcher(movie, user, action, fullMsg)
	
	username = user.name
	udir = username.char[1] & "\"
		
	case action of
		----------------------------------------------------
		"game.savescore": -- // save char skill score in the high scores
		----------------------------------------------------

		if not checkAdminAccess(user.name, 8) then
			-- we are not gonna keep track of high scores of admin / officers
			
			playerScore = integer(fullmsg.content)			
			updateHighScore(movie, username, playerScore)
			
		end if
	
		----------------------------------------------------
		"game.getscore": -- // get high score list
		----------------------------------------------------

		scoreFile = string(file("DAT\SETTINGS\HighScores.dam").read)
		sendMovieMessage(movie, user.name, "game.highscores", scoreFile)

		----------------------------------------------------
		"game.getbalance": -- // Get balance from bank
		----------------------------------------------------
		bankFile = string(file("DAT\CHARS\BANK\" & udir & username & ".dam").read)
		
		if bankFile = "" OR bankFile = VOID then
			bankFile = "0"
			file("DAT\CHARS\BANK\" & udir & username & ".dam").write(bankFile)
		end if

		sendMovieMessage(movie, username, "game.bankbalance", bankFile)

		exit

		----------------------------------------------------
		"game.deposit": -- // Deposit into bank
		----------------------------------------------------

		amtToDeposit = integer(fullMsg.content)

		if removeItemFromInventory(movie, username, "gold", amtToDeposit) then

			bankFile = string(file("DAT\CHARS\BANK\" & udir & username & ".dam").read)
			bankFile = integer(bankFile) + amtToDeposit
			
			file("DAT\CHARS\BANK\" & udir & username & ".dam").write(string(bankFile))
			sendMovieMessage(movie, username, "game.donedeposit", bankFile)
		else
			sendMovieMessage(movie, username, "game.donedeposit", "-1")
		end if

		----------------------------------------------------
		"game.withdraw":-- // Withdraw from bank
		----------------------------------------------------

		amtToWithdraw = integer(fullMsg.content)

		bankFile = string(file("DAT\CHARS\BANK\" & udir & username & ".dam").read)
		bankFile = integer(bankFile) - amtToWithdraw
			
		if bankFile < 0 then 
			sendMovieMessage(movie, username, "game.donewithdraw", "-1")
			exit
		end if

		if addItemToInventory(movie, username, "gold", amtToWithdraw) then
			sendMovieMessage(movie, username, "game.donewithdraw", bankFile)
			file("DAT\CHARS\BANK\" & udir & username & ".dam").write(string(bankFile))
		else
			sendMovieMessage(movie, username, "secure.gamemsg", "There seems to be a problem with your withdrawal. Contact an admin for help.")
		end if
		
	  exit

	end case

end

----------------------------------------------------------------
-- // "jail " -- Set as map x0y0 4-5
----------------------------------------------------------------
on jailPlayer(movie, user, playername)

		jailMapLoc = string(file("DAT\FILTERS\JAIL\JailMapLoc.dam").read)
		
		if isExistsInGenericList(playername & ":", "DAT\FILTERS\JAIL\JailList.dam") then 
			sendMovieMessage(movie, user.name, "chat.admin", playername & " is already in jail.")
			return FALSE
		end if

		pdir = playername.char[1] & "\"
		playerFile = string(file("DAT\CHARS\DATA\" & pdir & playername & ".dam").read)

		if not (playerFile contains ":") then
			sendMovieMessage(movie, user.name, "chat.admin", "You mistyped the player's name.")
			return FALSE
		end if
			
		the itemdelimiter = "|"
		charGameInfo = playerFile.item[3]
		
		the itemdelimiter = ":"
		backupMapLoc = charGameInfo.item[1]
		put jailMapLoc into charGameInfo.item[1]
		
		the itemdelimiter = "|"
		put charGameInfo into playerFile.item[3]
	
		-- you cannot backup the player's info if he's already in jail
		-- so backupCharacter() is called only after the jail check
		if not backupJailCharacter(playername, backupMapLoc) then
			-- the backup must be successful otherwise we may cause the player 
			-- to lose some data.
			sendMovieMessage(movie, user.name, "chat.admin", "Backup Error: Unable to jail " & playername)
			return FALSE
		end if

		addToGenericList(playername, "DAT\FILTERS\JAIL\JailList.dam")

		file("DAT\CHARS\DATA\" & pdir & playername & ".dam").write(playerFile)
		sendMovieMessage(movie, playername, "secure.warp", jailMapLoc)

		jailItemsFile = string(file("DAT\FILTERS\JAIL\JailItems.dam").read)

		file("DAT\CHARS\ITEMS\" & pdir & playername & "-i.dam").write(jailItemsFile)

		sendMovieMessage(movie, playername, "invnt.upd_allInvEQ", jailItemsFile)

		sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|" & playername & " has been jailed by " & user.name)
		sendMovieMessage(movie, user.name, "chat.admin", "You jailed " & playername)

		auditLog(user.name & " jailed " & playername, "jail")

		return TRUE

	
end

--"--------------------------------------------------------------
-- // "unjail " -- Set as map x0y0 4-5
----------------------------------------------------------------
on unjailPlayer(movie, user, playername)

		if removeFromGenericList(playername, "DAT\FILTERS\JAIL\JailList.dam", ":") then 

			releaseMapLoc = restoreJailCharacter(movie, playername)
			
			if releaseMapLoc = "" then
				sendMovieMessage(movie, user.name, "chat.admin", "Backup Error: Unable to release " & playername)
				return FALSE
			end if
			
			pdir = playername.char[1] & "\"
			playerFile = string(file("DAT\CHARS\DATA\" & pdir & playername & ".dam").read)

			the itemdelimiter = "|"
			charGameInfo = playerFile.item[3]

			the itemdelimiter = ":"
			put releaseMapLoc into charGameInfo.item[1]
		
			the itemdelimiter = "|"
			put charGameInfo into playerFile.item[3]
			
			file("DAT\CHARS\DATA\" & pdir & playername & ".dam").write(playerFile)
			
			sendMovieMessage(movie, playername, "secure.warp", releaseMapLoc)
			
			sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|" & playername & " was just released from jail by " & user.name)
			sendMovieMessage(movie, user.name, "chat.admin", "You unjailed " & playername)

			auditLog(user.name & " released " & playername, "release")
			
			return TRUE

		else
		
			sendMovieMessage(movie, user.name, "chat.admin", playername & " isn't in jail.")
			return FALSE
			
		end if

end


--"------------------------------------------------------
-- // backupCharacterData()
--------------------------------------------------------
-- Backs up the character's data. 
-- This is only used for JAILSCRIPTs
--------------------------------------------------------
-- Returns: TRUE
--------------------------------------------------------
on backupJailCharacter(playername, backupMapLoc)
		
	backupFile = string(file("DAT\FILTERS\JAIL\JAILBIRDS\" & playername & "-jbak.dam").read)
	if backupFile = "" or backupFile = VOID then
	
		pdir = playername.char[1] & "\" 
		playerItemFile = string(file("DAT\CHARS\ITEMS\" & pdir & playername & "-i.dam").read)

		file("DAT\FILTERS\JAIL\JAILBIRDS\" & playername & "-jbak.dam").write(backupMapLoc & "/" & playerItemFile)
		return TRUE
		
	else
		return FALSE
	end if	
	
end 

--"------------------------------------------------------
-- // backupCharacterData()
--------------------------------------------------------
-- Backs up the character's data. 
-- This is only used for JAILSCRIPTs
--------------------------------------------------------
-- Returns:
--		*	if success:		TRUE
--		*	otherwise :		FALSE
--------------------------------------------------------

on restoreJailCharacter(movie, playername)
	
	backupFile = string(file("DAT\FILTERS\JAIL\JAILBIRDS\" & playername & "-jbak.dam").read)
	if backupFile = "" or backupFile = VOID then
		return ""
	else

		pdir = playername.char[1] & "\" 
	
		the itemdelimiter = "/"
		releaseMapLoc = backupFile.item[1]
		playerinvFile = backupFile.item[2]
		
		file("DAT\CHARS\ITEMS\" & pdir & playername & "-i.dam").write(playerinvFile)
		sendMovieMessage(movie, playername, "invnt.upd_allInvEQ", playerinvFile)
		
		-- clear the backup file
		file("DAT\FILTERS\JAIL\JAILBIRDS\" & playername & "-jbak.dam").write("")
		
		return releaseMapLoc
		
	end if
	
end

on loadHighScores(movie, user)

	 scoreFile = string(file("DAT\SETTINGS\HighScores.dam").read)
	 sendMovieMessage(movie, user.name, "load.highscores", scoreFile)

end

on updateHighScore(movie, playername, playerscore)

	scoreFile = string(file("DAT\SETTINGS\HighScores.dam").read)
	
	the itemdelimiter = ":"
	
	if scoreFile.line[1] <> "" then

		lowerScores = ""
		lowest = integer(scoreFile.line[1].item[2])

		if scoreFile <= lowest then 
			sendMovieMessage(movie, playername, "load.highscores", scoreFile)
			exit
		end if

		-- lets delete ur old score if it exists
		if scoreFile contains (playername & ":") then
			repeat with n = 1 to 10
				if scoreFile.line[n].item[1] = playername then
					delete scoreFile.line[n]
					exit repeat
				end if
			end repeat
		end if

		-- lets remove the lowest score now that I have a score higher than that

		if scoreFile.line[10] = "" then
			-- because there are less than 10 top scores, therefore there is no 
			-- need to oust the lowest score
			lowerScores = scoreFile.line[1] & RETURN
		end if

		delete scoreFile.line[1]

		repeat while scoreFile.line[1] <> ""
			scoree = integer(scoreFile.line[1].item[2])
			if playerscore > scoree then
				lowerScores = lowerScores & scoreFile.line[1] & RETURN
				delete scoreFile.line[1]
			else
				exit repeat
			end if
		end repeat

		scoreFile = lowerScores & playername & ":" & playerscore & RETURN & scoreFile
	
	else
	
		scoreFile = playername & ":" & playerscore
		
	end if

	file("DAT\SETTINGS\HighScores.dam").write(scoreFile)
	
	sendMovieMessage(movie, playername, "load.highscores", scoreFile)
end





































---// some old scripts. not sure what it is for yet. to be examined



on DoorSwitch(MapName, OldDoor, NewDoor, DoorX, DoorY)
	global myPMovie
 set TheDt = "!`( " & OldDoor & ":" & NewDoor & ":" & DoorX & ":" & DoorY

 set the itemdelimiter = "i"
 set GroupN = "@" & item 1 of MapName
 sendMovieMessage(myPMovie, GroupN, "chatmsg", TheDt)
 set the itemdelimiter = "|"

 set MapFile = file("DAT\ITEMS\" & MapName).read

  repeat with x = 1 to 20
     if item x of MapFile contains OldDoor then
        set DoorFL = item x of MapFile
        set the itemdelimiter = ":"
        put NewDoor into item 1 of DoorFL
        set the itemdelimiter = "|"
        put DoorFL into item x of MapFile
     end if
  end repeat

  file("DAT\ITEMS\" & MapName).write(MapFile)
end


on DropSomethingNPC(TheMap, TheItem)
global myPMovie
set the itemdelimiter = "`"
   set FilName = TheMap
   set NewItem = TheItem
   set ItDt = TheItem

   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"
   if item 20 of ItemList = "" then set OneToPlace = 20
   if item 19 of ItemList = "" then set OneToPlace = 19
   if item 18 of ItemList = "" then set OneToPlace = 18
   if item 17 of ItemList = "" then set OneToPlace = 17
   if item 16 of ItemList = "" then set OneToPlace = 16
   if item 15 of ItemList = "" then set OneToPlace = 15
   if item 14 of ItemList = "" then set OneToPlace = 14
   if item 13 of ItemList = "" then set OneToPlace = 13
   if item 12 of ItemList = "" then set OneToPlace = 12
   if item 11 of ItemList = "" then set OneToPlace = 11
   if item 10 of ItemList = "" then set OneToPlace = 10
   if item 9 of ItemList = "" then set OneToPlace = 9
   if item 8 of ItemList = "" then set OneToPlace = 8
   if item 7 of ItemList = "" then set OneToPlace = 7
   if item 6 of ItemList = "" then set OneToPlace = 6
   if item 5 of ItemList = "" then set OneToPlace = 5
   if item 4 of ItemList = "" then set OneToPlace = 4
   if item 3 of ItemList = "" then set OneToPlace = 3
   if item 2 of ItemList = "" then set OneToPlace = 2
   if item 1 of ItemList = "" then set OneToPlace = 1

   set the itemdelimiter = ":"

   set TheGoods = item 1 of ItDt & ":" & item 2 of ItDt
   set the ItemDelimiter = "|"
   put TheGoods into item OnetoPlace of ItemList

   if ItemList contains "|" then
    else
    exit
   end if

   file("DAT\ITEMS\" & FilName).write(ItemList)

 set the itemdelimiter = ":"
 set WhichItemYo = item 1 of ItDt
 set WhichItemXY = item 2 of ItDt
 set the itemdelimiter = "-"
 set WhichX = item 1 of WhichItemXY
 set WhichY = item 2 of WhichItemXY

 set TheDt = "!(( " & WhichItemYo & ":" & WhichX & ":" & WhichY

 set the itemdelimiter = "i"
 set GroupN = "@" & item 1 of TheMap
 sendMovieMessage(myPMovie, GroupN, "chatmsg", TheDt)


   end if
  end

