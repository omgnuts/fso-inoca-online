on GetCurrentMap(userName)

	set MyFile = file("DAT\Char\" & userName & ".txt").read
	--if MyFile contains ":" then
	--else
	--	MyFile = "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
	--end if
	set the itemdelimiter = ":"
	set MyMap = item 5 of string(MyFile)
	return MyMap

end

--"----------------------------------------------------
-- Release Passwords
------------------------------------------------------
-- To use the script you have to put the following
-- files and dirs in the directory of the server:
--		DAT\PasswordGainMaps\
--		DAT\Passwords\ [CreatePasswords()]
------------------------------------------------------
-- This methode tell a password to the user
-- (use it in combination with the CreatePasswords()
--  methode)
------------------------------------------------------

on ReleasePassword(user, movie, CurrentMap) -- based on map

	set pCode = string(file("DAT\QuestPassMap\rp-" & CurrentMap & ".txt").read)
	ReleasePasswordX(user, movie, pCode)

end

on ReleasePasswordX(user, movie, pCode) -- direct from NPC

	set savei = the itemdelimiter

	if pCode = "" then exit -- the current npc doesnt release a password
	set QPFile = file("DAT\QuestPass\" & string(user.name) & "-qp.txt").read

	set the itemdelimiter = "/"
	set userPassList = item 1 of QPFile

	if userPassList contains ":" & pCode then --  User has the map's password already
		set TalkDat = "You have already learned the '" & pCode & "' password. Type '+password list' to view your passwords."
		sendMovieMessage(movie, user.name, "sqa", TalkDat)
	else
		set rndPass = random(900) + 99
	   set newPass = pCode & string(rndPass)

	   if string(userPassList) = "" then
	   	set userPassList = "@:" & newPass
			-- file("DAT\QuestPass\" & string(user.name) & "-qp.txt").write("@:" & newPass)
		else
			set userPassList = userPassList & ":" & newPass
			-- file("DAT\QuestPass\" & string(user.name) & "-qp.txt").write(userPassList & ":" & newPass)
		end if

		put userPassList into item 1 of QPFile
		file("DAT\QuestPass\" & string(user.name) & "-qp.txt").write(QPFile)

		set TalkDat = "You have just learnt the password '" & newPass & "'. Type '+password list' to view your passwords."
		sendMovieMessage(movie, user.name, "sqa", TalkDat)
	end if

	set the itemdelimiter = savei

end

on LockedMobsCheck(user, MapName)

	set Lockfile = file("DAT\Settings\LockedMobs.txt").read
	if Lockfile contains MapName then
		set bResult = "true"
		return bResult
	else
		set bResult = "false"
		return bResult
	end if

end

on CanDoOneTimeQuest(QuestName, UName)

	set QPFile = file("DAT\QuestPass\" & UName & "-qp.txt").read

	set the itemdelimiter = "/"
	set QPOner = string(item 2 of QPFile)

	if QPOner contains ":" & QuestName then
		return FALSE
	else
		if QPOner = "" then
			set QPOner = "@:" & QuestName
		else
			set QPOner = QPOner & ":" & QuestName
		end if

		set the itemdelimiter = "/"
		put QPOner into item 2 of QPFile

		file("DAT\QuestPass\" & UName & "-qp.txt").write(QPFile)

		return TRUE
	end if

end