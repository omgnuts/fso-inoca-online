on mainCommandDispatcher(movie, user, fullmsg)

	username = user.name
	wordcode = fullMsg.content.word[1]
		
	case wordcode of

		--------------------------------------------
		"@rpg": -- // Broadcasts with "*** " infront
		--------------------------------------------
		if checkAdminAccess(username, 3) then
			rpgMsgDat = fullmsg.content
			delete rpgMsgDat.word[1]
			
			sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|" & rpgMsgDat)
			sendMovieMessage(movie, "@Admin", "chat.broadcast", "5|" & username & " sent the RPG message.")
		end if

		exit

		----------------------------------------------------------------
		"@muteall": -- "Global Mute"  -- only Immortals can do global mute
		----------------------------------------------------------------
		global gGlobalMute

		if gGlobalMute = 1 then exit
		if checkAdminAccess(username, 2) then
			gGlobalMute = 1
			sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|*** Global mute has been activated" )
		end if

		exit

		----------------------------------------------------------------
		"@unmuteall": -- // "Global UnMute"  -- only Immortals can do global unmute
		----------------------------------------------------------------
		global gGlobalMute
		
		if gGlobalMute = 0 then exit
		if checkAdminAccess(username, 2) then
			globalMute = 0
			sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|*** Global mute has been deactivated" )
		end if
		
		exit

		----------------------------------------------------------------
		"@mute": -- // "Mute "
		----------------------------------------------------------------
		returnmsg = mutePlayer(movie, user, fullMsg.content.word[2])
		if returnmsg = "err" then auditlog(username & " tried to " & fullmsg.content, "error")

		exit
		
		----------------------------------------------------------------
		"@voice": -- // "Voice "
		----------------------------------------------------------------
		returnmsg = mutePlayer(movie, user, fullMsg.content.word[2])
		if returnmsg = "err" then auditlog(username & " tried to " & fullmsg.content, "error")
		
		exit
		
		----------------------------------------------------------------
		"@refreshstaff":-- // "StaffList refresh"
		----------------------------------------------------------------
		if checkAdminAccess(username, 1) then refreshAccessList()

		exit

		----------------------------------------------------------------
		"@jail": -- // "jail "
		----------------------------------------------------------------
		if checkAdminAccess(username, 6) then
			jailPlayer(movie, user, fullMsg.content.word[2])
		else
			auditlog(username & " tried to " & fullmsg.content, "error")
		end if

		exit

		----------------------------------------------------------------
		"@release": -- // "release "
		----------------------------------------------------------------
		if checkAdminAccess(username, 6) then
			unjailPlayer(movie, user, fullMsg.content.word[2])
		else 
			auditlog(username & " tried to " & fullmsg.content, "error")
		end if
		
		exit
		
		----------------------------------------------------------------
		"@kick": -- // Kick The Player
		----------------------------------------------------------------
		if checkAdminAccess(username, 2) then
			
			playername = fullMsg.content.word[2]
				
			removeUserSession(movie, playername, "kicked")
			sendMovieMessage(movie, "@Admins", "chat.admin", playername & " has been kicked by " & username)
			
		end if
		exit

		----------------------------------------------------------------
		"@purge": -- // Purge The Player
		----------------------------------------------------------------
		if checkAdminAccess(username, 1) then

			playername = fullMsg.content.word[2]
						
			removeUserSession(movie, playername, "purged")
			sendMovieMessage(movie, "@Admins", "chat.admin", playername & " has been purged by " & username)

		end if
		exit

		----------------------------------
		"@getip": -- // Get User IP
		----------------------------------
		if checkAdminAccess(username, 2) then
			playername = fullMsg.content.word[2]
			ip = getIPAddress(movie, username)

			sendMovieMessage(movie, username, "chat.admin", "The IP address of " & playername & " is: " & ip)
		end if
		exit


		----------------------------------
		"@banip": -- // Add IP Ban
		----------------------------------
		if checkAdminAccess(username, 2) then
			
			-- we use isBlockedIP to do the actual check of whether an ip is blocked.
			
			ipToBan = fullMsg.content.word[2]
			if isExistsInGenericList(ipToBan & ":", "DAT\FILTERS\BannedIPs.dam") then exit

			addToGenericList(ipToBan, "DAT\FILTERS\BannedIPs.dam")

			sendMovieMessage(movie, username, "chat.admin", "The IP Address " & ipToBan & " has been banned.")
			auditLog(ipToBan & " banned by " & username , "IPbanlock")

		end if
		
		exit

		----------------------------------
		"@unbanip": -- // Remove IP Ban
		----------------------------------
		if checkAdminAccess(username, 2) then
			
			ipToUnban = fullMsg.content.word[2]
			removeFromGenericList(ipToUnban, "DAT\FILTERS\BannedIPs.dam", ":")
			
			sendMovieMessage(movie, username, "chat.admin", "The IP Address " & ipToUnban & " has been unbanned.")
			auditLog(ipToUnban & " unbanned by " & username , "IPbanlock")

		end if
		exit			


		----------------------------------
		"@lock": -- // Lock Player
		----------------------------------
		if checkAdminAccess(username, 2) then
			playername = fullMsg.content.word[2]
						
			pdir = playername.char[1] & "\"
			playerFile = string(file("DAT\CHARS\DATA\" & pdir & playername & ".dam").read)
			
			if not (playerFile contains ":") then
				sendMovieMessage(movie, username, "chat.admin", "You mistyped the player's name.")
				return FALSE
			end if
			
			if playerFile.char[1..7] = "BANNED`" then
				removeUserSession(movie, playername, "banned_user")
				sendMovieMessage(movie, username, "chat.admin", playername & " is already locked.")
				exit
			end if

			-- Cannot ban admin! -- selfprotection
			if checkAdminAccess(playername, 2) then exit
			
			playerIP = getIPAddress(movie, playername)
			if isExistsInGenericList(playerIP & ":", "DAT\FILTERS\BannedIPs.dam") then 
				sendMovieMessage(movie, username, "chat.admin", playername & " was already permanently locked.")
				exit
			end if			

			playerFile = "BANNED`" & playerFile
			file("DAT\CHARS\DATA\" & pdir & playername & ".dam").write(playerFile)
			
			removeUserSession(movie, playername, "banned_user")
			
			sendMovieMessage(movie, "@Admins", "chat.admin", playername & " has been locked by " & username)
			auditLog(playername & " banned by " & username, "lock")
			
		end if
		exit

		----------------------------------
		"@unlock": -- // unLock Player
		----------------------------------
		if checkAdminAccess(username, 2) then
		
			playername = fullMsg.content.word[2]
			
			pdir = playername.char[1] & "\"
			playerFile = string(file("DAT\CHARS\DATA\" & pdir & playername & ".dam").read)

			if not (playerFile contains ":") then
				sendMovieMessage(movie, username, "chat.admin", "You mistyped the player's name.")
				return FALSE
			end if

			if playerFile.char[1..7] = "BANNED`" then
				the itemdelimiter = "`"
				playerFile = playerFile.item[2]
				
				file("DAT\CHARS\DATA\" & pdir & playername & ".dam").write(playerFile)
				
				sendMovieMessage(movie, "@Admins", "chat.admin", playername & " has been unlocked.")
				auditLog(playername & " unbanned by " & username , "banlock")
				
			else
				sendMovieMessage(movie, username, "chat.admin", playername & " is not locked at all.")
				exit
			end if
			
		end if

		exit

		----------------------------------
		"@banlock": -- // Lock & ban IP Player
		----------------------------------
		if checkAdminAccess(username, 2) then
		
			playername = fullMsg.content.word[2]
			
			pdir = playername.char[1] & "\"
			playerFile = string(file("DAT\CHARS\DATA\" & pdir & playername & ".dam").read)

			if not (playerFile contains ":") then
				sendMovieMessage(movie, username, "chat.admin", "You mistyped the player's name.")
				return FALSE
			end if
		
			if playerFile.char[1..7] = "BANNED`" then
				removeUserSession(movie, playername, "banned_user")
				sendMovieMessage(movie, username, "chat.admin", playername & " is already locked.")
				exit
			end if

			-- Cannot ban admin! -- selfprotection
			if checkAdminAccess(playername, 2) then exit

			playerFile = "BANNED`" & playerFile
			file("DAT\CHARS\DATA\" & pdir & playername & ".dam").write(playerFile)

			playerIP = getIPAddress(movie, playername)
			if not isExistsInGenericList(ipToBan & ":", "DAT\FILTERS\BannedIPs.dam") then 
				addToGenericList(playerIP, "DAT\FILTERS\BannedIPs.dam")
			end if
			
			removeUserSession(movie, playername, "banned_user")
			
			sendMovieMessage(movie, "@Admins", "chat.admin", playername & " (" & playerIP & ") has been locked by " & username)
			auditLog(playername & " (" & playerIP & ") banned by " & username, "banlock")

		end if

		exit

		----------------------------------------------------------------
		"@maxonline": -- // "maximum who"
		----------------------------------------------------------------
		if checkAdminAccess(username, 1) then
			
			the itemdelimiter = "|"
			umFile = file("DAT\SETTING\UserMax.dam").read

			userMax = integer(umFile.item[1])

			if fullMsg.content.word[2] = "all" then
				sendMovieMessage(movie,  "@AllUsers", "chat.broadcast", "4|*** Maximum number of users online is " & userMax)
			else
				sendMovieMessage(movie, username, "chat.admin", "*** Maximum number of users online is " & userMax & " on the " &  umFile.item[2])
			end if

		end if

		exit
			
		----------------------------------
		"@warp": -- // Warp (warp, warptome)
		----------------------------------
		if checkAdminAccess(username, 3) then
			playername = fullMsg.content.word[2]
			
			warpDat = fullMsg.content
			delete warpDat.word[1..2]
   	
			if warpDat.word[1] = "to" then 
				warpDat = getWarpShortcut(movie, user, warpDat.word[2])
  		end if
  		
  		if warpDat <> "" then 
  			sendMovieMessage(movie, playername, "secure.warp", warpDat)
  		end if

		end if

		exit

		----------------------------------
		"@create": -- // Admin Item Drop
		----------------------------------

		if checkAdminAccess(username, 2) then
			immoDropFile = string(file("DAT\ACCESSLIST\ACCESS\immortaldrops.dam").read)
			immoname = "*" & username & "*"

			if immoDropFile contains immoname then
				playername = fullMsg.content.word[2]
				itemDat = fullMsg.content.word[3]
				
				if itemDat = "" then 
					itemDat = playername
					playername = username
				end if
				
				the itemdelimiter = "-"
				itemiser = itemDat.item[1]
				addAmt = itemDat.item[2]
	
				if itemiser = "" OR addAmt < 1 then exit
				
				if addItemToInventory(movie, playername, itemiser, addAmt) then
					auditLog(username & " created the item for " & playername, "admindrop")
					sendMovieMessage(movie, username, "secure.gamemsg", "An item has been created in your inventory.")
				end if
				
			end if
		end if
		exit

		----------------------------------
		"@clearinv": -- // Admin Item Drop
		----------------------------------

		if checkAdminAccess(username, 2) then
			immoDropFile = string(file("DAT\ACCESSLIST\ACCESS\immortaldrops.dam").read)
			immoname = "*" & username & "*"

			if immoDropFile contains immoname then
		
				playername = fullMsg.content.word[2]
				if playername = "" then playername = username

				pdir = playername.char[1] & "\"
				playerItemFile = string(file("DAT\CHARS\ITEMS\" & pdir & playername & "-i.dam").read)

				the itemdelimiter = "|"
				put ":::::::::::::::::::" into playerItemFile.item[2]
				file("DAT\CHARS\ITEMS\" & pdir & playername & "-i.dam").write(playerItemFile)
				
				sendMovieMessage(movie, playername, "invnt.upd_allnonEQ", playerItemFile)
				
			end if
		end if

		----------------------------------
		"@showinv": -- // Admin Item Drop
		----------------------------------

		if checkAdminAccess(username, 8) then
			playername = fullMsg.content.word[2]
			if playername = "" then playername = username

			pdir = playername.char[1] & "\"
			playerItemFile = string(file("DAT\CHARS\ITEMS\" & pdir & playername & "-i.dam").read)

			sendMovieMessage(movie, username, "chat.admin", playerItemFile )
		end if
					
		----------------------------------------------------------------
		"@massreload": -- // "Mass Reload Game Settings "
		----------------------------------------------------------------
		if checkAdminAccess(username, 1) then
			modeFile = string(file("DAT\SETTINGS\GameModes.dam").read)
			sendMovieMessage(movie, "@AllUsers", "load.game_modes", modeFile)
		end if
		exit

		----------------------------------------------------------------
		"@setpassmap": -- // "Set as password map"
		----------------------------------------------------------------
			-- set passwordmap sillyboy %x999y1000 5 5
		set TheFolder = "QuestPassMap"
				
		if checkFileAccess(user.name, TheFolder) then

				set TheMap = GetCurrentMap(user.name)
				set FullPathx = "DAT\" & TheFolder & "\" & TheMap & "-qp.txt"

				set isEmpty = file(FullPathx).read
				if string(isEmpty) <> "" then
					sendMovieMessage(movie, user.name, "sqa", "The password script is already active on this map.")
					exit
				end if

				set passCode = word 3 of fullMsg.content
				set the itemdelimiter = "%"
				set newLoc = item 2 of fullMsg.content

				file(FullPathX).write(passCode & ":" & newLoc)
				sendMovieMessage(movie, user.name, "sqa", "You have set the password for the current map, " & TheMap & ".")

		end if
		exit

		----------------------------------------------------------------
		"@givepassmap": -- // "Set as password release map"
		----------------------------------------------------------------
		set TheFolder = "QuestPassMap"

		if checkFileAccess(user.name, TheFolder) then

			-- set passwordmap sillyboy

				set TheMap = GetCurrentMap(user.name)
				set FullPathx = "DAT\" & TheFolder & "\rp-" & TheMap & ".txt"

				set isEmpty = file(FullPathx).read
				if string(isEmpty) <> "" then
					sendMovieMessage(movie, user.name, "sqa", "The password release script is already active on this map.")
					exit
				end if

				set passCode = word 3 of fullMsg.content

				file(FullPathX).write(passCode)
				sendMovieMessage(movie, user.name, "sqa", "The password release has been set for the current map, " & TheMap & ".")
		end if
		exit
			
	end case

  exit
		
end mainCommandDispatcher

on getWarpShortcut(movie, user, warpShortcut)
	warpDat = string(file("DAT\DATAS\warpshortcuts\" & warpShortcut & ".dam").read)
	
	if warpDat <> "" AND warpDat <> VOID then 
		return warpDat
	else
		sendMovieMessage(movie, user.name, "chat.admin", "That shortcut doesn't exist")
		return ""
	end if
	
end

