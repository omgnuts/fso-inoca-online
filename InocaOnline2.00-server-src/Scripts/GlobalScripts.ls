--Global FactionPowers, TreasureList, CharList, LastPhoto, PhotoName, PhotoList, TodaysMonth, TimeOutGo
--Global gDispatcher, LegitUsers, CDKeys
--Global GlobalMute, FactionCounter, CurrentNumUsers

--Global WeddingStatus, Bride, Groom, Priest
-- movie.sendmessage("system.user.delete", "x", User.Name)
-- // ####### Need to Figure out these issues
-- sendMovieMessage(movie, user.name, "234882347782347923482347", "x")  <<-- to log off the char
-- 234882347782347923482347 :: logoff/kick

global gServer

on sendEmailActivation(movie, user, charName, email, actCode, myIP)
	inoUrl = "http://forums.inocaonline.com/inomail.php"
	sendMovieMessage(movie, user.name, "Server Response", "EmailedActivation#" & charName & "#" & email & "#" & actCode & "#" & myIP & "#" & inoUrl)
end

on resetEmailPassword(movie, user, charName, email, myPass, myIP)
	inoUrl = "http://forums.inocaonline.com/inomail.php"
	sendMovieMessage(movie, user.name, "Server Response", "EmailedResetPass#" & charName & "#" & email & "#" & myPass & "#" & myIP & "#" & inoUrl)
end

on getDateTime()
	return "[ " & the short date & " " & the short time & "] "
end

on checkAdminAccess(username, level)

	global gListAdmins, gListOfficers, gListMappers

-- 1 - only owner
-- 2 - only immortals
-- 3 - immortals & official mappers
-- 4 - immortals & mappers
-- 5 - immortals & mappers & officers
-- 6 - immortals & officers
-- 7 - officers only
-- 8 - immortals & official mappers & officers
-- 9 - mappers only

	case level of
		1:
			Immname = "@*" & username & "*@"
			if gListAdmins contains Immname then return TRUE
		2:
			Immname = "*" & username & "*"
			if gListAdmins contains Immname then return TRUE
		3:
			Immname = "*" & username & "*"
			PMName = ">*" & username & "*<"
			if (gListMappers contains PMName) then return FALSE
			if (gListAdmins contains Immname) or (gListMappers contains Immname) then return TRUE
		4:
			Immname = "*" & username & "*"
			if (gListAdmins contains Immname) or (gListMappers contains Immname) then return TRUE
		5:
			Immname = "*" & username & "*"
			if (gListAdmins contains Immname) or (gListMappers contains Immname) \
				or (gListOfficers contains Immname) then return TRUE
		6:
			Immname = "*" & username & "*"
			if (gListAdmins contains Immname) or (gListOfficers contains Immname) then return TRUE
		7:
			Immname = "*" & username & "*"
			if (gListOfficers contains Immname) then return TRUE
		8:
			Immname = "*" & username & "*"
			PMName = ">*" & username & "*<"
			if (gListMappers contains PMName) then return FALSE
			if (gListAdmins contains Immname) or (gListMappers contains Immname) \
				or (gListOfficers contains Immname) then return TRUE
		9:
			Immname = "*" & username & "*"
			if (gListMappers contains Immname) then return TRUE

	end case
	return FALSE
end

on GuildLog(GuildName, LogInfo)
	theFile = file("DAT\AUDITLOGS\GUILDS_LOG\" & GuildName & "_log.log").read
	theFile = theFile & RETURN & getDateTime() & LogInfo
	file("DAT\AUDITLOGS\GUILDS_LOG\" & GuildName & "_log.log").write(theFile)
end

on AuditLog(logText, action)

	case action of
		"IPbanlock"	: auditFile = "IPbanlock_log.log"
		"banlock"		: auditFile = "banlock_log.log"
		"admindrop"	: auditFile = "admindrop_log.log"
		"jail"			: auditFile = "jail_log.log"
		"release"   : auditFile = "jail_log.log"
		"error"			: auditFile = "error_log.log"
		"bankHack"	: auditFile = "bankHack_log.log"
		"vaultHack"	: auditFile = "vaultHack_log.log"
		"resetPass"	: auditFile = "resetPass_log.log"
		"cheat"			: auditFile = "cheat_log.log"
		"ipLog"			: auditFile = "ip_log.log"
		"newMap"		: auditFile = "newmap_log.log"
	end case

	theFile = file("DAT\AUDITLOGS\" & auditFile).read
	theFile = theFile & RETURN & getDateTime() & logText
	file("DAT\AUDITLOGS\" & auditFile).write(theFile)

end

on resetTimeStamp(username)
	if not (username contains "newchar") then
		file("DAT\TIMESTAMP\" & username & ".dam").write("")
	end if
end resetTimeStamp

on checkTimeStamp(currTime, username)

	lastTime = integer(file("DAT\TIMESTAMP\" & username & ".dam").read)

	if (lastTime > 0) and (integer(currTime) <= lastTime) then
		return FALSE
	else
		file("DAT\TIMESTAMP\" & username & ".dam").write(string(currTime))
		return TRUE
	end if

end checkTimeStamp

--"------------------------------------------------------
-- // The default dispatcher used for incoming messages
-- that are sent to "system.script"
--------------------------------------------------------
-- IMPORTANT: never use "\" delimiter for message
-- contents. The "\" delimiter is reserved for the
-- MD5 content concatenation and checking
--
-------------------------------------------------------
-- Returns: VOID
--------------------------------------------------------
on incomingMessage (me, movie, group, user, fullMsg)

-- put movie.serverGroup("@AllUsers")

	-- clean the subject content with string once before continuing
	-- the rest of the script
	if (fullMsg.subject <> "photo.savepic") and (fullMsg.subject <> "paint.savepic") then

		fullMsg.content = string(fullMsg.content)

		the itemdelimiter = "\"
		md5str = string(fullMsg.subject.item[3])
		curTime = string(fullMsg.subject.item[2])
		fullMsg.subject = string(fullMsg.subject.item[1])

		md5HashContent = fullMsg.content & fullMsg.subject & "\" & curTime & "\" & "oheavens"
		md5Chk = CoMD5DigestFastest(md5HashContent)

		if md5Chk <> md5str then \
			removeUserSession(movie, user.name, "bad_md5")

		if not (user.name contains "newchar") then
			-- dont have to do a time check for char creation
			if not checkTimeStamp(curTime, user.name) then
				 removeUserSession(movie, user.name, "bad_md5")
			end if
		else
			-- if char creation, then only can do this
			if not ((fullmsg.subject = "account.create_char") \
				   or (fullmsg.subject = "account.reset_password")) then

				removeUserSession(movie, user.name, "bad_session")
				exit
			end if
		end if

	end if


-- The incoming message is good & valid.
-- Try to clean it up a little more by
-- making sure that the content is "Stringified"

the itemdelimiter = "."
subject = string(fullmsg.subject).item[1]
action = string(fullmsg.subject)

case subject of

	"chat":

		if (action = "chat.broadcast") then

				username  = string(user.name)

				if isMutedBroadcastCheck(movie, username) then exit -- // Check Mute - For individuals only

				the itemdelimiter = "|"
				chatText = fullMsg.content.item[3]
				guildMark = fullMsg.content.item[1] & " of the " & fullMsg.content.item[2]

				if checkFoulwords(movie, username, chatText) then exit

				powerRank = ""
				powerCheck = "*" & username & "*"

				global gListAdmins, gListOfficers, gListMappers

				if gListAdmins contains powerCheck then
					if (gListAdmins contains "@" & powerCheck & "*@") then powerRank = "Host Admin "
					else if (gListAdmins contains "+" & powerCheck & "+") then powerRank = "Chief Admin "
					else if (gListAdmins contains ">" & powerCheck & "<") then powerRank = "Security Admin "
					else powerRank = "Admin "
				end if

				if gListOfficers contains powerCheck then
					if (gListOfficers contains "+" & powerCheck & "+")  then powerRank = "Chief Officer "
					else if (gListOfficers contains "@" & powerCheck & "*@") then powerRank = "Trade Officer "
					else powerRank = "Officer "
				end if

				if gListMappers contains powerCheck then
					if (gListMappers contains "+" & powerCheck & "+") then powerRank = "Chief Mapper "
					else if (gListMappers contains "@" & powerCheck & "@") then powerRank = "Asst.Chief Mapper "
					else if (gListMappers contains ">" & powerCheck & "<") then powerRank = "Mapper "
					else powerRank = "Practice Mapper "
				end if

				-- 4 bright yellow
				-- 120 cyan
				-- 16 / 19 orange
				-- 7 / 8 / 86 light grey
				--repeat with n = 1 to 255
				--	sendMovieMessage(movie, "@AllUsers", "chat.broadcast" , n & "|" & n & "  colors.")
				--end repeat

				if (powerRank <> "") and (powerRank <> "Practice Mapper ") then

					chatText = powerRank & username & " broadcasts " & QUOTE & chatText & QUOTE

					if powerRank contains "officer" then
						sendMovieMessage(movie, "@AllUsers", "chat.broadcast" , "41|" & chatText)
					else
						sendMovieMessage(movie, "@AllUsers", "chat.broadcast" , "5|" & chatText)
					end if

				else  --// normal users

					global gGlobalMute

					if gGlobalMute = 1 then exit

					chatText =  powerRank & username & "," & guildMark & " broadcasts " & QUOTE & chatText & QUOTE
					sendMovieMessage(movie, "@AllUsers", "chat.broadcast" , "36|" & chatText)

				end if

		else if (action = "chat.tradecast") then

				-- just performs a relay
				sendMovieMessage(movie, "@AllUsers", "chat.tradecast", fullMsg.content)

		else if (action = "chat.admin") then

				-- just performs a relay
				sendMovieMessage(movie, "@Admin", "chat.admin", fullMsg.content)

	 	else if (action = "chat.death") then

			global gGlobalmute

			if gGlobalmute then
				sendMovieMessage(movie, user.name, "chat.death",  fullmsg.content)
			else
				sendMovieMessage(movie, "@Allusers", "chat.death",  fullmsg.content)
			end if

		end if

		exit

	----------------------------------
	-- // Check for special commands
	----------------------------------
	"callcommands":

		mainCommandDispatcher(movie, user, fullmsg)

		exit


	"secure":

		if ( action = "secure.packeting" ) then
			-- automatically kicking a hackerid from the server
			-- content contains the hackerid

		else if (action = "secure.bad_md5") then


		end if

		exit

	"account":

		if ( action = "account.create_char" ) then
			-- creating a new user account.

		else if ( action = "account.load_char" ) then

			loadCharacter(fullMsg.content, user, movie)

		end if

		exit

	"load":

		if ( action = "load.mapnpcitem" ) then
			mapName = fullMsg.content

			if isTooManyPCInMap(movie, user, mapName) then exit

			loadMap(movie, user, mapName)
			loadMapNPCs(movie, user, mapName)
			loadMapItems(movie, user, mapName)
			loadHighScores(movie, user)

		else if ( action = "load.map" ) then
			loadMap(movie, user, fullMsg.content)

		else if ( action = "load.npcs" ) then
			loadMapNPCs(movie, user, fullMsg.content)

		else if ( action = "load.items" ) then
			loadMapItems(movie, user, fullMsg.content)

		end if
		exit

	"save":

		udir = user.name.char[1] & "\"
		charDat = string(file("DAT\CHARS\DATA\" & udir & user.name & ".dam").read)
		saveDat = fullMsg.content

		the itemdelimiter = ":"

		if charDat.item[1] = saveDat.item[1] AND charDat.item[2] = saveDat.item[2] then
			the itemdelimiter = "|"

			case action of

				"save.mychar_info" :
					put charDat.item[1] into saveDat.item[1]
					file("DAT\CHARS\DATA\" & udir & user.name & ".dam").write(saveDat)
					exit
				"save.myinfo"			 : put saveDat.item[2] into charDat.item[5]
				"save.mynature"		 : put saveDat.item[2] into charDat.item[6]
				"save.mystatus"    : put saveDat.item[2] into charDat.item[9]
				"save.mybio"			 : put saveDat.item[2] into charDat.item[12]
				"save.myjournal"	 : put saveDat.item[2] into charDat.item[13]
				"save.myskills"    : put saveDat.item[2] into charDat.item[15]

			end case

			file("DAT\CHARS\DATA\" & udir & user.name & ".dam").write(charDat)
		end if

		exit

	"invnt":

		if ( action = "invnt.rem_EQitem" ) then
			the itemdelimiter = ":"
			itemiser = fullMsg.content.item[1]
			myitype = fullMsg.content.item[2]

			remEQItemWithSave(movie, user.name, itemiser, myitype)

		else if ( action = "invnt.wear_EQitem" ) then
			the itemdelimiter = ":"
			itemiser = fullMsg.content.item[1]
			myitype = fullMsg.content.item[2]

			wearEQItemWithSave(movie, user.name, itemiser, myitype)

		else if ( action = "invnt.remitem" ) then
			the itemdelimiter = ":"

			invIndex = integer(fullMsg.content.item[1])
			itemiser = fullMsg.content.item[2]
			itmLessNo= integer(fullMsg.content.item[3])

			removeItemFromInventory(movie, user.name, itemiser, itmLessNo, invIndex)

		else if ( action = "invnt.additem" ) then
			the itemdelimiter = ":"

			itemiser = fullMsg.content.item[1]
			itmAddNo = integer(fullMsg.content.item[2])

			addItemToInventory(movie, user.name, itemiser, itmAddNo)

		else if ( action = "invnt.switchitem" ) then
			the itemdelimiter = ":"

			remItemiser = fullMsg.content.item[1]
			remNo = integer(fullMsg.content.item[2])

			addItemiser = fullMsg.content.item[3]
			addNo = integer(fullMsg.content.item[4])

			exchangeSingleInvntItem(movie, user.name, addItemiser, addNo, remItemiser, remNo)

		else if ( action = "invnt.breakEQ" ) then
			the itemdelimiter = ":"

			myitype = fullMsg.content.item[1]
			eqItemiser = fullMsg.content.item[2]

			toItemiser = fullMsg.content.item[3]
			toItmCount = integer(fullMsg.content.item[4])

			if addItemToInventory(movie, user.name, toItemiser, toItmCount) then
				loseEQItemWithSave(movie, user.name, eqItemiser, myitype)
			end if

		else if ( action = "invnt.breakEQmap" ) then

			the itemdelimiter = "^"

			addMapItem(movie, user, fullMsg.content.item[3], fullMsg.content.item[4])
			loseEQItemWithSave(movie, user.name, fullMsg.content.item[2], fullMsg.content.item[1])

		end if

	"store":

		if ( action = "store.getstore" ) then

			the itemdelimiter = "/"
			islock = fullMsg.content.item[1]
			itmic = fullMsg.content.item[2]
			owner = fullMsg.content.item[3]

			storeFilePath = getStorePath(user.name, itmic, owner)
			if storeFilePath = VOID then
				sendMovieMessage(movie, user.name, "store.error", "Invalid container code.")
				exit
			end if

			storeFile = string(file(storeFilePath).read)

			sendMovieMessage(movie, user.name, "store.getstore", islock & "/" & itmic & "/" & owner & "/" & storeFile)

		else if ( action = "store.getitem" ) then

			the itemdelimiter = "/"
			itmic = fullMsg.content.item[1]
			owner = fullMsg.content.item[2]
			itemiser = fullMsg.content.item[3]
			lessNo = integer(fullMsg.content.item[4])

			storeGetItem(movie, user.name, itmic, owner, itemiser, lessNo)

		else if ( action = "store.putitem" ) then

			the itemdelimiter = "/"
			itmic = fullMsg.content.item[1]
			owner = fullMsg.content.item[2]
			itemiser = fullMsg.content.item[3]
			addNo = integer(fullMsg.content.item[4])

			storePutItem(movie, user.name, itmic, owner, itemiser, addNo)

		else if ( action = "store.additem" ) then -- adds an item to vault only

			the itemdelimiter = "/"
			itmic = fullMsg.content.item[1]
			owner = fullMsg.content.item[2]
			itemiser = fullMsg.content.item[3]
			addNo = integer(fullMsg.content.item[3])

			storeAddItem(movie, user.name, itmic, owner, itemiser, addNo)

		else if ( action = "store.makeserial" ) then
			-- make serial and put into inventory

			itemiser = makeSerialObject(fullMsg.content)
			addItemToInventory(movie, user.name, itemiser, 1)

		end if

		exit

	"mevent":

		if ( action = "mevent.inv_to_map" ) then
			the itemdelimiter = ":"

			mapName = fullMsg.content.item[1]
			toX = integer(fullMsg.content.item[2])
			toY = integer(fullMsg.content.item[3])
			itemiser = fullMsg.content.item[4]
			dropNum = integer(fullMsg.content.item[5])
			invIndex = integer(fullMsg.content.item[6])

			dropItemOnMap(movie, user.name, mapName, toX, toY, itemiser, dropNum, invIndex)

		else if ( action = "mevent.inv_fr_map" ) then

			the itemdelimiter = ":"

			mapName = fullMsg.content.item[1]
			fromX = integer(fullMsg.content.item[2])
			fromY = integer(fullMsg.content.item[3])
			itemiser = fullMsg.content.item[4]
			itmCount = integer(fullMsg.content.item[5])

			pickItemFromMap(movie, user.name, mapName, fromX, fromY, itemiser, itmCount)

		else if ( action = "mevent.put_mapi" ) then

			the itemdelimiter = "^"

			addMapItem(movie, user, fullMsg.content.item[1], fullMsg.content.item[2])

		else if ( action = "mevent.rem_mapi" ) then

			the itemdelimiter = "^"

			removeMapItem(movie, user, fullMsg.content.item[1], fullMsg.content.item[2])

		else if ( action = "mevent.switchmapi" ) then

			the itemdelimiter = "^"
			switchMapItem(movie, user, fullMsg.content.item[1], fullMsg.content.item[2], fullMsg.content.item[3])

		else if ( action = "mevent.tilechange" ) then

			the itemdelimiter = ":"
			chg = fullMsg.content
			changeMapTile(movie, user, chg.item[1], chg.item[2], chg.item[3], chg.item[4], chg.item[5], chg.item[6])

		end if

	"npc":
		if (action = "npc.synchron") then

			currTime = gServer.timestamp

			the itemdelimiter = "/"
			mapName = fullMsg.content.item[1]
			npctime = integer(file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").read) + 1000

			if (currTime > npcTime) then
				file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").write(string(currTime))
				sendMovieMessage(movie, "@" & mapName, "npc.synchron", fullMsg.content)

				file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(fullMsg.content.item[3])
			end if

		else if (action = "npc.update") then

			currTime = gServer.timestamp

			the itemdelimiter = "/"
			mapName = fullMsg.content.item[1]
			npctime = integer(file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").read) + 1000

			if currTime > npcTime then
				file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").write(string(currTime))
				sendMovieMessage(movie, "@" & mapName, "npc.update", fullMsg.content)

				file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(fullMsg.content.item[2])
			end if

		else if (action = "npc.killed") then

			currTime = gServer.timestamp

			the itemdelimiter = "|"
			mapName = fullMsg.content.item[1]
			npcIndex = integer(fullMsg.content.item[2])

			npctime = integer(file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").read)

			if currTime > npcTime then
				npcMapFile = string(file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").read)

				if npcMapFile.item[npcIndex] = "" then exit -- the npc was already killed

				file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").write(string(currTime))
				sendMovieMessage(movie, "@" & mapName, "npc.killed", fullMsg.content)

				put "" into npcMapFile.item[npcIndex]
				file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(npcMapFile)

			end if

		else if (action = "npc.spawned") then

			currTime = gServer.timestamp

			the itemdelimiter = "|"
			mapName = fullMsg.content.item[1]
			npcIndex = integer(fullMsg.content.item[2])
			currNPCDat = fullMsg.content.item[3]

			npctime = integer(file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").read) + 1000

			if currTime > npcTime then

				npcMapFile = string(file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").read)

				if npcMapFile.item[npcIndex] <> "" then exit -- the npc is already respawned

				file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").write(string(currTime))
				sendMovieMessage(movie, "@" & mapName, "npc.spawned", fullMsg.content)

				put currNPCDat into npcMapFile.item[npcIndex]
				file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(npcMapFile)

			end if

		else if (action = "npc.killSummon") then

			currTime = gServer.timestamp

			the itemdelimiter = "|"
			mapName = fullMsg.content.item[1]
			npcIndex = integer(fullMsg.content.item[2])

			npctime = integer(file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").read)

			if currTime > npcTime then
				fixNpcFile = string(file("DAT\MAPS\NPCS\" & mapName & "-n.dam").read)
				npcMapFile = string(file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").read)

				fixNPC = fixNpcFile.item[npcIndex]
				curNPC = npcMapFile.item[npcIndex]

				if curNPC = "" AND fixNPC = "" then exit -- the npc was already killed

				the itemdelimiter = ":"
				if fixNPC.item[4] <> "1" then exit
				the itemdelimiter = "|"

				file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").write(string(currTime))
				sendMovieMessage(movie, "@" & mapName, "npc.killed", fullMsg.content)

				put "" into fixNpcFile.item[npcIndex]
				put "" into npcMapFile.item[npcIndex]
				file("DAT\MAPS\NPCS\" & mapName & "-n.dam").write(fixNpcFile)
				file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(npcMapFile)

			end if

		else if (action = "npc.makeSummon") then

			currTime = gServer.timestamp

			the itemdelimiter = "|"
			mapName = fullMsg.content.item[1]
			npcIndex = integer(fullMsg.content.item[2])
			npcCode = fullMsg.content.item[3]
			fdat = fullMsg.content.item[4]
			cdat = fullMsg.content.item[5]

			npctime = integer(file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").read)

			if currTime > npcTime then
				fixNpcFile = string(file("DAT\MAPS\NPCS\" & mapName & "-n.dam").read)
				npcMapFile = string(file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").read)

				fixNPC = fixNpcFile.item[npcIndex]
				curNPC = npcMapFile.item[npcIndex]

				if fixNPC <> "" AND curNPC <> "" then
					sendMovieMessage(movie, user.name, "secure.gamemsg", "There is not enough space to summon a creature here!")
					exit -- u cannot summon an npc in this space
				end if

				file("DAT\MAPS\NPCSMOVE\" & mapName & "-n.dam").write(string(currTime))

				npcdb = string(file("DAT\DATAS\NPCS\" & npcCode & ".dam").read)
				sendMovieMessage(movie, "@" & mapName, "npc.makeSummon", mapName & "/" & npcIndex & "/" & npcCode & "/" & fdat & "/" & cdat & "/" & npcdb)

				put fdat into fixNpcFile.item[npcIndex]
				put cdat into npcMapFile.item[npcIndex]
				file("DAT\MAPS\NPCS\" & mapName & "-n.dam").write(fixNpcFile)
				file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(npcMapFile)

			end if

		else if (action = "npc.buyitem") then -- npc is buying item / Mychar is selling

			isellDat = fullMsg.content

			the itemdelimiter = "/"
			sellToNPC(movie, user.name, isellDat.item[1], isellDat.item[2], isellDat.item[3])

		else if (action = "npc.sellitem") then -- npc is selling item / Mychar is buying

			ibuyDat = fullMsg.content

			the itemdelimiter = "/"
			buyFromNPC(movie, user.name, ibuyDat.item[1], ibuyDat.item[2], ibuyDat.item[3])

		end if

	"wedi":

		if not checkAdminAccess(user.name, 3) then exit

		if (action = "wedi.loadmap") then
			mapName = fullMsg.content

			loadMap(movie, user, mapName)
			loadMapNPCs(movie, user, mapName)
			loadMapItems(movie, user, mapName)

		else if (action = "wedi.savemap") then
			saveMap(movie, user, fullMsg)

		else if (action = "wedi.saveitems") then
			saveMapItems(movie, user, fullMsg)

		else if (action = "wedi.savenpcs") then
			saveMapNPCs(movie, user, fullMsg)

		end if

	"mail":

		if (action = "mail.loadtopics") then

			udir = user.name.char[1] & "\"

			mailFile = string(file("DAT\CHARS\MAIL\" & udir & user.name & "-m.dam").read)
			sendMovieMessage(movie, user.name, "mail.loadtopics", mailFile)

		else if (action = "mail.savedata") or (action = "mail.reloaddata") then
				-- mail.savedata
				-- mail.reloaddata

			udir = user.name.char[1] & "\"

			the itemdelimiter = "/"
			numOfMail = integer(fullMsg.content.item[1])

			if numOfMail > 0 then

				newMailFile = fullMsg.content.item[2]
				oldMailFile = string(file("DAT\CHARS\MAIL\" & udir & user.name & "-m.dam").read)

				the itemdelimiter = "|"
				curMailCount = oldMailFile.items.count

				if curMailCount > numOfMail then

					c = numOfMail + 1

					if newMailFile.char[newMailFile.length] = "|" then
						delete newMailFile.char[newMailFile.length]
					end if

					repeat with n = c to curMailCount
						newMailFile = newMailFile & "|" & oldMailFile.item[n]
						n = n + 1
					end repeat

				end if

				file("DAT\CHARS\MAIL\" & udir & user.name & "-m.dam").write(newMailFile)

			end if

			if (action = "mail.reloaddata") then

				if newMailFile = VOID then
					-- in cases when numOfMail = 0 during reload, we need to load the file from the server
					newMailFile = string(file("DAT\CHARS\MAIL\" & udir & user.name & "-m.dam").read)
				end if

				sendMovieMessage(movie, user.name, "mail.reloadtopics", newMailFile)
			end if

		else if (action = "mail.sendmail") then

			the itemdelimiter = "/"

			toUsers = fullMsg.content.item[1]
			msgData = fullMsg.content.item[2]

			the itemdelimiter = ":"
			n = 1

			repeat while toUsers.item[n] <> ""

				toUser = toUsers.item[n]
				udir = toUser.char[1] & "\"

				mailFile = string(file("DAT\CHARS\MAIL\" & udir & toUser & "-m.dam").read)

				if mailFile.char[mailFile.length] <> "|" then
					mailFile = mailFile & "|" & msgData & "|"
				else
					mailFile = mailFile & msgData & "|"
				end if

				file("DAT\CHARS\MAIL\" & udir & toUser & "-m.dam").write(mailFile)

				n = n + 1
			end repeat

			sendMovieMessage(movie, user.name, "mail.mailsent", "x")

		end if

	"board":

		if (action = "board.loadtopics") then
			the itemdelimiter = "/"

			isGuild = integer(fullMsg.content.item[1])
			boardName = fullMsg.content.item[2]

			if isGuild then
				boardFilePath = "DAT\GUILDS\BOARDS\" & boardName & ".dam"
			else
				boardFilePath = "DAT\GAMEPLAY\BOARDS\" & boardName & ".dam"
			end if

			boardFile = string(file(boardFilePath).read)
			sendMovieMessage(movie, user.name, "board.loadtopics", isGuild & "/" & boardName & "/" & boardFile)

		else if (action = "board.savepost") then

			the itemdelimiter = "/"

			isGuild = integer(fullMsg.content.item[1])
			boardName = fullMsg.content.item[2]
			postDat = fullMsg.content.item[3]

			if isGuild then
				boardFilePath = "DAT\GUILDS\BOARDS\" & boardName & ".dam"
			else
				boardFilePath = "DAT\GAMEPLAY\BOARDS\" & boardName & ".dam"
			end if

			boardFile = string(file(boardFilePath).read)
			if boardFile.char[boardFile.length] = "|" OR boardFile = "" then
				boardFile = boardFile & postDat & "|"
			else
				boardFile = boardFile & "|" & postDat & "|"
			end if

			file(boardFilePath).write(boardFile)

		end if

	"photo":

		if (action = "photo.savepic") then

			itemiser = makeSerialObject("$sphoto#0#0######")

			the itemdelimiter = "#"

			itmic = itemiser.item[1]
			file("DAT\SERIALS\PHOTOS\" & itmic & ".dam").write(user.name) -- write the pic info
			file("DAT\SERIALS\PHOTOS\" & itmic & ".bin").writevalue(fullmsg.content) -- binary

			if addItemToInventory(movie, user.name, itemiser, 1) then
				sendMovieMessage(movie, user.name, "secure.notify", "Your picture has been saved successfully!")
			end if

		else if (action = "photo.getpic") then

			the itemdelimiter = "#"
			itmic = fullMsg.content.item[1]

			picInfo = string(file("DAT\SERIALS\PHOTOS\" & itmic & ".dam").read) -- write the author
			picImage = file("DAT\SERIALS\PHOTOS\" & itmic & ".bin").readvalue() -- binary

			sendMovieMessage(movie, user.name, "photo.viewinfo", picInfo)
			sendMovieMessage(movie, user.name, "photo.viewpic", picImage)

		end if

		exit

	"paint":
		if (action = "paint.savepic") then

			itemiser = makeSerialObject("$spaint#0#0######")

			the itemdelimiter = "#"

			itmic = itemiser.item[1]
			file("DAT\SERIALS\PAINTS\" & itmic & ".dam").write(user.name) -- write the paint info
			file("DAT\SERIALS\PAINTS\" & itmic & ".bin").writevalue(fullmsg.content) -- binary

			if addItemToInventory(movie, user.name, itemiser, 1) then
				sendMovieMessage(movie, user.name, "secure.notify", "Your painting has been saved successfully!")
			end if
		else if (action = "paint.getpic") then

			the itemdelimiter = "#"
			itmic = fullMsg.content.item[1]

			picInfo = string(file("DAT\SERIALS\PAINTS\" & itmic & ".dam").read) -- write the author
			picImage = file("DAT\SERIALS\PAINTS\" & itmic & ".bin").readvalue() -- binary

			sendMovieMessage(movie, user.name, "photo.viewinfo", picInfo)
			sendMovieMessage(movie, user.name, "photo.viewpic", picImage)

		end if

	"guild":

		if (action = "guild.loadplay") then

			guildName = fullMsg.content

			guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
			if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then
				sendMovieMessage(movie, user.name, "guild.playerror", "Your guild is no longer in existence!")
				exit
			end if

			sendMovieMessage(movie, user.name, "guild.loadplay", guildName & "/" & guildDatFile)

		else

			-- dispatches to guild methods that are not often called during the game play
			mainGuildDispatcher(movie, user, fullMsg)
			exit

		end if

	"game":

		if (action = "") then

		else

			mainGameDispatcher(movie, user, action, fullMsg)

		end if

		exit
end case

end incomingMessage