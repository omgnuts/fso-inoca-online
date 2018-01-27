--"------------------------------------------------------
-- // Sends the movie message to various usergroups
--------------------------------------------------------
-- This method does the Md5, and concatenates with
-- system time check
--------------------------------------------------------
-- Returns: void
--------------------------------------------------------
on sendMovieMessage(movie, recipient, subject, content)
 global gOldTime, gServer

	msec = gServer.timestamp
	if msec <= gOldTime then
	 	msec = gOldTime + 1
		gOldTime = gOldTime + 1
	else
	 gOldTime = msec
	end if

	msec = string(msec)

-- put subject, content

	if (subject <> "photo.viewpic") then
		md5HashContent = string(content) & string(subject) & "\" & msec & "\" & "oheavens"
		md5Str = CoMD5DigestFastest(md5HashContent)
		movie.sendmessage(recipient, subject & "\" & msec & "\" & md5Str, content)
	else
		-- just send without md5 check if subject is view_painting
		-- somehow am unable to encrypt the painting msg
		movie.sendmessage(recipient, subject, content)
	end if

end


--"------------------------------------------------------
-- // Removes the user from the session for various
-- reasons
--------------------------------------------------------
-- reasons include:
-- 			* secure.bad_session
--		  * secure.bad_md5
-- 			* secure.banned_user
--------------------------------------------------------
-- Returns:
--			if success: TRUE
-- 			otherwise : FALSE
--------------------------------------------------------

on removeUserSession(movie, username, reason)

	sendMovieMessage(movie, username, "secure.session_out", reason)
	movie.sendmessage("system.user.delete", "x", username)

end removeUserSession


--------------------------------------------------------
-- // Check for Blocked IP Address
--------------------------------------------------------
-- This method checks if an ip or an iprange is banned
--------------------------------------------------------
-- Returns:
--		*	if not banned	  :	TRUE
--		*	if banned /error: FALSE
--------------------------------------------------------

on isBlockedIP(movie, username)

	userIP = string(getIPAddress(movie, username))

	the itemdelimiter = "."

	userIPRange4 = "@" & userIP & ":"
	userIPRange3 = "@" & userIP.item[1] & "." & userIP.item[2] & "." & userIP.item[3] & ".*:"
	userIPRange2 = "@" & userIP.item[1] & "." & userIP.item[2] & ".*.*:"
  userIPRange1 = "@" & userIP.item[1] & ".*.*.*:"

	bannedFile = string(file("DAT\FILTERS\BannedIPs.dam").read)
	-- set the itemdelimiter = ":"

	if userIP contains "." then
		if (bannedFile contains userIPRange4) or (bannedFile contains userIPRange3) \
			or (bannedFile contains userIPRange2) or (bannedFile contains userIPRange1) then

			return TRUE
		else
			return FALSE
		end if
	else
		return TRUE -- block errors
	end if

end isBlockedIP


--"------------------------------------------------------
-- // Get IP Address
--------------------------------------------------------
-- This method gets the ip of the user
--------------------------------------------------------
-- Returns: ip address
--------------------------------------------------------

on getIPAddress(movie, username)
	userIP = movie.sendmessage("system.user.getAddress", "LookingUpIp", userName)
	return string(userIP.content.IPAddress)
end getIPAddress

--"------------------------------------------------------
-- // checks if the cd key is valid
--------------------------------------------------------
--
--------------------------------------------------------
-- Return:
-- 		* if success: TRUE
--		* otherwise : FALSE
--------------------------------------------------------

on isValidCdKey(cdkey)

	cdKeyFile = string(file("DAT\SETTINGS\CdKey.dam").read)
	cdkey = ":" & cdkey & ":"

	if cdKeyFile contains cdkey then
		return TRUE
	else
	  return FALSE
  end if

end isValidCdKey


--------------------------------------------------------
-- // Word Check for Broadcast Filter
--------------------------------------------------------

on checkFoulwords(movie, username, origtext)
	global gMuteCounter, gFoulWordList

	-- check if the brute has already been muted
	if isExistsInGenericList(username & "-", "DAT\FILTERS\MutedList.dam") then exit

	the itemdelimiter = ":"
	numWords = integer(gFoulWordList.item[1]) + 1
	cnt = 0

	repeat with cnt = 2 to numWords

		if origtext contains gFoulWordList.item[cnt] then

			warnCount = file("DAT\FILTERS\MUTES\" & username & ".dam").read
			warnCount = integer(warnCount) + 1

			if warnCount < 5 then

				warnMsg = "For saying " & QUOTE & gFoulWordList.item[cnt] & QUOTE & ", your warning level is now " & warnCount & "!"

				sendMovieMessage(movie, username, "chat.warn", warnMsg)

			else

				warnCount = 0 -- reset

				-- Mute the brute
				addToGenericList(username & "-" & gMuteCounter, "DAT\FILTERS\MutedList.dam")

				sendMovieMessage(movie, username, "chat.warn", "You were warned many times but did not listen! You have been muted!")
				sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|" & username &" has been muted by the server")

			end if

			file("DAT/FILTERS/MUTES/" & username & ".dam").write(string(warnCount))

			return TRUE

		end if
	end repeat

	return FALSE
end

--------------------------------------------------------
-- // Muted Broadcast Check()
--------------------------------------------------------
-- This methode checks if a char is allowed to broadcast
--------------------------------------------------------
-- Returns:
--		*	if voiced:	TRUE
--		*	if muted:		FALSE
--------------------------------------------------------
-- Triggers:
--		*	Trigger Mute Check
--------------------------------------------------------
on isMutedBroadcastCheck(movie, username)

	if isExistsInGenericList(username & "-", "DAT\FILTERS\MutedList.dam") then 
		sendMovieMessage(movie, username, "secure.gamemsg", "You are muted, you can't broadcast.")
		return TRUE
	end if
	
	return FALSE
	
end


--------------------------------------------------------
-- // MutePlayer()
--------------------------------------------------------
-- Allows officers/admins to mute players
--------------------------------------------------------
-- Needed directories:	/
--------------------------------------------------------
-- Needed methods: /
--------------------------------------------------------
-- Returns:
--		*	if success:		"Yes"
--		*	if not success:"NO"
--		*	if error:		"ERR"
--------------------------------------------------------
-- Triggers:
--		*	Trigger Mute
--------------------------------------------------------

on mutePlayer(movie, user, playername)
		global gMuteCounter

    if checkAdminAccess(user.name, 8) then

			if checkAdminAccess(user.name, 7) then
				if checkAdminAccess(playername, 6) then
					sendMovieMessage(movie, user.name, "chat.admin", "You can't mute a staff member or a fellow officer.")
					return "NO"
				end if
			else
				if checkAdminAccess(user.name, 2) = FALSE then
					if checkAdminAccess(playername, 8) then
						sendMovieMessage(movie, user.name, "chat.admin", "You can't mute a fellow staff member.")
						return "NO"
					end if
				end if
			end if

			pdir = playername.char[1] & "\"
			playerFile = string(file("DAT\CHARS\DATA\" & pdir & playername & ".dam").read)

			if not (playerFile contains ":") then
				sendMovieMessage(movie, user.name, "chat.admin", "You mistyped the player's name.")
				return "NO"
			end if

			if isExistsInGenericList(playername & "-", "DAT\FILTERS\MutedList.dam") then 
				sendMovieMessage(movie, user.name, "chat.admin", playername & " has already been muted.")
				return "NO"
			end if

			addToGenericList(playername & "-" & gMuteCounter, "DAT\FILTERS\MutedList.dam")
			sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|" & playername &" has been muted by " & user.name )
			return "Yes"
		
		end if
		
		return "ERR"
end


--"------------------------------------------------------
-- // VoicePlayer()
--------------------------------------------------------
-- This method permits a character to broadcast
--------------------------------------------------------
-- Needed directories:	/
--------------------------------------------------------
-- Needed methodes: /
--------------------------------------------------------
-- Returns:
--		*	if success:		"Yes"
--		*	if success:		"NO"
--		*	if error:		"ERR"
--------------------------------------------------------
-- Triggers:
--		*	Trigger Voice
--------------------------------------------------------
on voicePlayer(movie, user, playername)

 	if checkAdminAccess(user.name, 8) then
		if checkAdminAccess(user.name, 7) then
			if checkAdminAccess(playername, 6) then
				sendMovieMessage(movie, user.name, "chat.admin", "You can't voice a staff member or a fellow officer.")
				return "NO"
			end if
		else
			if checkAdminAccess(user.name, 2) = FALSE then
				if checkAdminAccess(playername, 8) then
					sendMovieMessage(movie, user.name, "chat.admin", "You can't voice a fellow staff member.")
					return "NO"
				end if
			end if
		end if
		
		if removeFromGenericList(playername, "DAT\FILTERS\MutedList.dam", "-") then
			sendMovieMessage(movie, "@AllUsers", "chat.broadcast", "4|" & playername &" has been voiced by " & user.name )
			return "Yes"
		else
			sendMovieMessage(movie, user.name, "chat.admin", playername & " isn't muted.")
			return "NO"
		end if
		
	end if
	
	return "ERR"
end


--------------------------------------------------------
-- // Check File Access
--------------------------------------------------------

on checkFileAccess(userName, folderName)

	if (FolderName contains "../" or FolderName contains "..\") then return FALSE
	userName = "*" & userName & "*"

	set FileAdmins = file("DAT\ACCESSLIST\File Admins.txt").read
	if FileAdmins contains userName then
		set savei = the itemdelimiter
		set the itemdelimiter = ":"
		set n = 1
		repeat while line n of FileAdmins <> ""
			if item 1 of line n of FileAdmins = userName then
				if item 2 of line n of FileAdmins = "*" then
					set the itemdelimiter = savei
					return TRUE
				else
					set nn = 2
					repeat while item nn of line n of FileAdmins <> ""
						if item nn of line n of FileAdmins = FolderName then
							set the itemdelimiter = savei
							return TRUE
						end if
						set nn = nn + 1
					end repeat
				end if
				set the itemdelimiter = savei
				return FALSE

				exit repeat
			end if
			set n = n + 1
		end repeat
		set the itemdelimiter = savei
		return FALSE
	else
		return FALSE
	end if

end
