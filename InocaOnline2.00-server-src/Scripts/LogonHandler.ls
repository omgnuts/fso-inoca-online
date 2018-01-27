--"------------------------------------------------------
-- // Log the user onto the game
--------------------------------------------------------
-- valid user logs into the system with the correct password
--------------------------------------------------------
-- Returns: VOID
--------------------------------------------------------

on userLogOna (username, movie)
	global gCurrentNumUsers

	if username contains "newchar" then
	else
		gCurrentNumUsers = gCurrentNumUsers + 1
		sendMovieMessage(movie, "@AllUsers", "upd.ulogon", username)
	end if

end

--"------------------------------------------------------
-- // Log the user off from the game
--------------------------------------------------------
-- user logs out of the game.
-- need to edit counters
--------------------------------------------------------
-- Returns: VOID
--------------------------------------------------------

on userLogOffa (username, movie)
	global gCurrentNumUsers

	if username contains "newchar" then
	else
		gCurrentNumUsers = gCurrentNumUsers - 1
		sendMovieMessage(movie, "@AllUsers", "upd.ulogout", username)
	end if
	
end

--"------------------------------------------------------
-- // check the maximum number of users
-- who have logged into the game before
--------------------------------------------------------
-- sets the gCurrentNumUsers
--------------------------------------------------------
-- Returns: Maximum number of users
--------------------------------------------------------

on checkUserMax()
	global gCurrentNumUsers

	the itemdelimiter = "|"
	umFile = string(file("DAT\SETTINGS\UserMax.dam").read)

	if umFile contains "|" then
		userMax = integer(umFile.item[1])
	else
		userMax = 1
		file("DAT\SETTINGS\UserMax.dam").write(userMax & "|" & getDateTime())
	end if

	if gCurrentNumUsers > userMax then
		umFile = gCurrentNumUsers & "|" & getDateTime()
		file("DAT\SETTINGS\UserMax.dam").write(umFile)
	end if

	return userMax

end

--"------------------------------------------------------
-- // adds to the user accounts created
--------------------------------------------------------
--
--------------------------------------------------------
-- Returns: the total user accounts.
--------------------------------------------------------

on increaseTotalChar()
	tChar = 1 + integer(file("DAT\SETTINGS\UsersCreated.dam").read)
	file("DAT\SETTINGS\UsersCreated.dam").write(tChar)
end

--"------------------------------------------------------
-- // adds to the maps created
--------------------------------------------------------
--
--------------------------------------------------------
-- Returns: the number of maps
--------------------------------------------------------

on increaseTotalMaps()
	tMaps = 1 + integer(file("DAT\SETTINGS\TotalMaps.dam").read)
	file("DAT\SETTINGS\TotalMaps.dam").write(tMaps)
end

--"------------------------------------------------------
-- // Checks if the map load is reached
--------------------------------------------------------
--
--------------------------------------------------------
-- Returns: TRUE / FALSE
--------------------------------------------------------

on isTooManyPCInMap(movie, user, mapName)

	test = FALSE

	if test then
		sendMovieMessage(movie, user.name, "sload.toomanypcs", "0")
		return TRUE
	else
		-- ok. u can continue to load the map
		sendMovieMessage(movie, user.name, "sload.toomanypcs", "1")
		return FALSE
	end if

end isTooManyPCInMap