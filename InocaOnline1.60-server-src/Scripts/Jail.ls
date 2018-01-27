Global TodaysMonth, ServerName

----------------------------------------------------------------
-- // "jail " -- Set as map x0y0 4-5
----------------------------------------------------------------
on Jailscript(user, movie, fullmsg)

	if checkAdminAccess(user.name, 6) then

		set the itemdelimiter = " "
		Set JailCharName = item 2 of fullmsg.content

		set JailList = file("DAT\settings\JAILLIST.txt").read
		if JailList contains ":" & JailCharName & ":" then
			-- guy has already been jailed.
			exit
		end if

		BackupChar(JailCharName)

		--set TheIp = movie.sendmessage("system.user.getAddress", "sqa", JailCharName)
		--if TheIp.content.IPAddress = "0.0.0.0" then

		set MyFile = file("DAT\CHAR\" & JailCharName & ".txt").read
		set the itemdelimiter = "/"
		set firstPart = item 1 of MyFile
		set the itemdelimiter = ":"
		put "x1000y992" into item 5 of firstPart
		put "4-5" into item 6 of firstPart
		set the itemdelimiter = "/"
		put firstPart into item 1 of MyFile
		file("DAT\char\" & JailCharName & ".txt").write(MyFile)

		set WarpDat = "/warp " & JailCharName & " x1000y992 4 5"
		sendMovieMessage(movie, JailCharName, "Warp1937931", WarpDat)

		set MyFile = "0|::::::::::::::|NOTHING:NOTHING:NOTHING:NOTHING:NOTHING:NOTHING:NOTHING:NOTHING"
		file("DAT\char\" & JailCharName & "-i.txt").write(MyFile)

		AddToList(JailCharName, "settings\JAILLIST.txt")
		sendMovieMessage(movie, JailCharName, "inx", MyFile)
		sendMovieMessage(movie, "@AllUsers", "broadcast|4", JailCharName & " has been jailed by " & user.name)
		sendMovieMessage(movie, user.name, "sqa", "You jailed " & JailCharName)

		auditLog(user.name & " jailed " & JailCharName, "jail")

		return "yes"

	end if
	return "no"
end

--"--------------------------------------------------------------
-- // "unjail " -- Set as map x0y0 4-5
----------------------------------------------------------------
on UnJailscript(user, movie, fullmsg)

	if checkAdminAccess(user.name, 6) then

		set the itemdelimiter = " "
		Set JailCharName = item 2 of fullmsg.content

		set JailList = file("DAT\settings\JAILLIST.txt").read

		if JailList contains ":" & JailCharName & ":" then
			-- guy is jailed.

			set MyFile = file("DAT\CHAR\" & JailCharName & ".txt").read
			set the itemdelimiter = ":"

			RestoreLastBackup(JailCharName, movie)
			RemoveFromList(JailCharName, "settings\JAILLIST.txt", ":")

			set oldPlace = file("DAT\DM\" & JailCharName & ".txt").read
			--set oldPlace = parseWarp(oldPlace)
			set WarpDat = "/warp " & JailCharName & " " & oldPlace
			sendMovieMessage(movie, JailCharName, "Warp1937931", WarpDat)

			sendMovieMessage(movie, "@AllUsers", "broadcast|4", JailCharName& " was just released from jail by, " & user.name)
			sendMovieMessage(movie, user.name, "sqa", "You unjailed " & JailCharName)

			auditLog(user.name & " released " & JailCharName, "release")
			return "yes"

		end if

	end if
	return "no"
end



------------------------------------------------
-- This can be used to check if the map is set
-- as savemap, NoPvP or Indoor
------------------------------------------------
--	set Mapfile = file("DAT\maps\" & MapName & ".txt").read
--	set TempItem = item 12 of string(Mapfile)
--	set the itemdelimiter = ":"
--	set SaveMap = item 1 of string(TempItem)
--	set NoPvP = item 2 of string(TempItem)
--	set Indoor = item 2 of string(TempItem)