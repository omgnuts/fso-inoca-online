-- on loadCharacter(tDT, username, movie)
-- on loadMap(mapName, username, movie)


--"------------------------------------------------------
-- // loads specified map to the user
--------------------------------------------------------
on loadMap(movie, user, mapName)

	mapFile = string(file("DAT\MAPS\MAPS\" & mapName & ".dam").read)
  sendMovieMessage(movie, user.name, "load.map", mapName & "|" & mapFile)

end loadMap

--"------------------------------------------------------
-- // loads specified map items to the user
--------------------------------------------------------

on loadMapItems(movie, user, mapName)

	mapItemsFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)
  sendMovieMessage(movie, user.name, "load.items", mapName & "/" & mapItemsFile )

end loadMapItems


--"------------------------------------------------------
-- // loads specified map items to the user
--------------------------------------------------------

on loadMapNPCs(movie, user, mapName)

	savei = the itemdelimiter

	mapNpcsFile = string(file("DAT\MAPS\NPCS\" & mapName & "-n.dam").read)
	curNpcsFile = string(file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").read)

	npcCodes = ":"
	n = 1
	the itemdelimiter = "|"

	loops = mapNpcsFile.items.count

	repeat with n = 1 to loops

		the itemdelimiter = "|"
		npcDat = mapNpcsFile.item[n]

		if npcDat <> "" then
			the itemdelimiter = ":"
			if not (npcCodes contains ":" & npcDat.item[1] & ":") then
				npcCodes = npcCodes & npcDat.item[1] & ":"
			end if
		end if

	end repeat

	n = 2
	npcdbSet = ""

  the itemdelimiter = ":"
	repeat while (npcCodes.item[n] <> "")
		-- npcCode+npcList^npcCode2+npcList2^
		npcdbSet = npcdbSet & npcCodes.item[n] & "+" & string(file("DAT\DATAS\NPCS\" & npcCodes.item[n] & ".dam").read) & "^"
		n = n + 1
	end repeat

  sendMovieMessage(movie, user.name, "load.npcs", mapName & "/" & mapNpcsFile & "/" & curNpcsFile & "/" & npcdbSet)

	the itemdelimiter = savei
end loadMapNPCs


--"------------------------------------------------------
-- // loads the character during login
--------------------------------------------------------
-- User is trying to login
-- Will send to the player the charinfo / items / pets
--	sendMovieMessage(movie, user.name, "load.mychar_info", userFile)
--  sendMovieMessage(movie, user.name, "load.mychar_items", itemFile)
--  sendMovieMessage(movie, user.name, "load.mypets_info", petsFile)
--------------------------------------------------------
-- Returns:
--			if success: TRUE
-- 			otherwise : FALSE
--------------------------------------------------------
on loadCharacter(tDT, user, movie)
	global gClientVersion

	username = user.name

	the itemdelimiter = ":"

	loginName = string(tDT.item[1])
	loginPass = string(tDT.item[2])
	actiCode  = tDT.item[3]  -- Activation Code
	clientVer = tDT.item[4]
  cdKey 	  = tDT.item[5]

	if not isValidCdKey(cdKey) then
		sendMovieMessage(movie, username, "secure.invalid_cdkey", "x")
		movie.sendmessage("system.user.delete", "x", username)
		return FALSE
	end if

	if clientVer <> gClientVersion then
		sendMovieMessage(movie, username, "secure.invalid_version",  gClientVersion)
		movie.sendmessage("system.user.delete", "x", username)
		return FALSE
	end if

	-- get the user directory in alphabetical order
	-- if a user is Jtducky, then uDir = J\Jtducky

	uDir = loginName.char[1] & "\"

	userFile = string(file("DAT\CHARS\DATA\" & uDir & loginName & ".dam").read)

	if userFile.char[1..7] = "BANNED`" then
		removeUserSession(movie, username, "banned_user")
		exit
	end if

	if isBlockedIP(movie, username) then
		removeUserSession(movie, username, "blocked_ip")
		exit
	end if

	if not (userFile contains ":") then
		removeUserSession(movie, username, "no_such_user")
		exit
	end if

	--// check if the account has been activated
	the itemdelimiter = "|"
	isActivated = getItemOf(5, userFile.item[1])

	if isActivated <> "1" then
		if actiCode = userFile.item[4] then
			put "1" into userFile.item[5]
			file("DAT\CHARS\DATA\" & uDir  & ".dam").write(userFile)
		else
			removeUserSession(movie, username, "not_activated")
			exit
		end if
	end if

	-- Finally check the password!
	the itemdelimiter = ":"
	correctPass = FALSE
	fPass = userFile.item[2]

	if fPass = loginPass then
		correctPass = TRUE
	else
		-- in case the password in the file was not encrypted.
		-- or reseted without encryption
		fPass = CoMD5DigestFastest(fPass)
		if fPass = loginPass then correctPass = TRUE
	end if

	-- Finally, we establish that we should let this geek play the game

	if correctPass then

		userLogOna(username, movie)
		loadGameIniFiles(movie, username)
		loadGameModes(movie, username)

		put "" into userFile.item[2] -- dont send the password to the client

		petsFile = string(file("DAT\CHARS\PETS\" & uDir & username & "-p.dam").read)
		invFile = string(file("DAT\CHARS\ITEMS\" & uDir & username & "-i.dam").read)

		if not (invFile contains ":") then
			invFile = string(file("DAT\CHARS\ITEMS\DEFAULT\Default-i.dam").read)
			file("DAT\CHARS\ITEMS\" & uDir & username & "-i.dam").write(invFile)
		end if

		sendMovieMessage(movie, username, "load.mychar_info", userFile)
		sendMovieMessage(movie, username, "load.mypets_info", petsFile)
		sendMovieMessage(movie, username, "load.mychar_items", invFile)

		if checkAdminAccess(username, 3) then \
			sendMovieMessage(movie, username, "load.is_immortal", "x")

	else
		removeUserSession(movie, username, "bad_password")
	end if

end loadCharacter