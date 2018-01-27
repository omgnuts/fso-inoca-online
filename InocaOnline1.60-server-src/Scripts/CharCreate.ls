------------------------------------------------------
--  CharCreate
------------------------------------------------------
-- To implement this script into the Server you'll
-- have to replace the "QueryCreate": case in the
-- GlobalScripts.ls file with the one underneath:
--
-- "QueryCreate":
--
-- 	CharCreate(me, movie, group, user, fullMsg)
--
------------------------------------------------------

------------------------------------------------------
-- Don't forget to edit the Scriptmap.ls file!!!
------------------------------------------------------
-- add this code to the "on scriptMap" event:
-- theMap.append( [ #movieID: "inomov", #scriptFileName: "CharCreate.ls" ] )
--
-- And add "CharCreate.ls" to "theList" in the
-- "on globalScriptList" event
------------------------------------------------------

------------------------------------------------------
-- To use the script you have to put the following
-- files in the directory of the server:
--
--		DAT\NewChar\ImmortalsFighter.txt
--		DAT\NewChar\ImmortalsFighter-i.txt
--		DAT\NewChar\ImmortalsMage.txt
--		DAT\NewChar\ImmortalsMage-i.txt
--		DAT\NewChar\ImmortalsRanger.txt
--		DAT\NewChar\ImmortalsRanger-i.txt
--		DAT\NewChar\Fighter.txt
--		DAT\NewChar\Fighter-i.txt
--		DAT\NewChar\Mage.txt
--		DAT\NewChar\Mage-i.txt
--		DAT\NewChar\Ranger.txt
--		DAT\NewChar\Ranger-i.txt
--
--	(The files are included in this package)
------------------------------------------------------

-----------------------------------
-- // Log IP of created characters
-----------------------------------

on Iplogger(user, triedcharname, movie)

	set MyIP = GetIP(user.name, movie)
	set IPFile = IPFile & user.name & ":" & triedcharname & ":" & myIP & "|" & RETURN
	auditLog(IPFile, "ipLog")
	return MyIP
end

------------------------------------
-- // Set new character information
------------------------------------

on CharCreate(me, movie, group, user, fullMsg, CDKeys)

	set CharFile = string(fullmsg.content)

	set the itemdelimiter = "`"
	set MyCode = item 1 of CharFile
	set ActivateCode = item 3 of CharFile
	set CharFile = item 2 of CharFile

	set the itemdelimiter = ":"

	-- if char 4 of Mycode = "" then exit
	-- if CDKeys contains MyCode then
	-- else
   	-- sendMovieMessage(movie, user.name, "Server Response", "Wrong Code")
      -- exit
	--	end if

	set MyName = item 1 of CharFile
	set MyPass = item 2 of CharFile

	if MyPass contains "'" or MyPass contains ":" then exit

   if user.name contains " " or user.name contains ":" or user.name contains ";" or user.name contains "/" or user.name contains "'" or user.name contains "\" or user.name contains "*" or user.name contains "+" then exit


   set the itemdelimiter = "/"
   if char 1 of item 2 of string(CharFile) = "1" then set extfile = "fighter"
   if char 1 of item 2 of string(CharFile) = "2" then set extfile = "mage"
   if char 1 of item 2 of string(CharFile) = "3" then set extfile = "ranger"

   set MyFile = file("DAT\CHAR\" & string(MyName) & ".txt").read
   if myFile contains ":" then
		sendMovieMessage(movie, user.name, "Server Response", "Cannot Create")
   else

		set the itemdelimiter = ":"
		-- myCode = email:activatecode:activatedstatus
		set myEmail = item 1 of ActivateCode
		set myActCode = item 2 of ActivateCode

--// remove this after you figure out Hotmail/MSN
 		if (myEmail contains "@hotmail.com") or (myEmail contains "@msn.com") or (myEmail contains "@aol.com") then
 			sendMovieMessage(movie, user.name, "alertNotes", "Sorry, we are currently unable to accept hotmail, msn & aol accounts. Please use another email.")
 			exit
 		end if

		set maxCharPerEmail = 100
		set numChars = integer(file("DAT\CharEmails\" & myEmail & ".txt").read)

		if numChars >= maxCharPerEmail then
			sendMovieMessage(movie, user.name, "Server Response", "Too Many Chars:" & maxCharPerEmail)
			exit
		else
			file("DAT\CharEmails\" & myEmail & ".txt").write(string(numChars + 1))

			if numChars = 0 then
				set emailList = file("DAT\CharEmails\#AllEmails.ino").read
				file("DAT\CharEmails\#AllEmails.ino").write(emailList & RETURN & myEmail)

			end if

		end if

		--// At this point, the email has been checked

		--------------------------------
		-- //Read the right source file
		--------------------------------
		if checkAdminAccess(MyName, 2) then
			set StartingStats = file("DAT\NewChar\Immortal" & extfile & ".txt").read
			set CharItems = file("DAT\NewChar\Immortal" & extfile & "-i.txt").read
		else
			set StartingStats = file("DAT\NewChar\" & extfile & ".txt").read
			set CharItems = file("DAT\NewChar\" & extfile & "-i.txt").read
		end if

		--------------------------------
		-- //Write ItemsFile
		--------------------------------
		file("DAT\CHAR\" & String(MyName) & "-i.txt").write(CharItems)

		set the itemdelimiter = "/"

		set FirstSS = item 1 of StartingStats
		set FirstCF = item 1 of CharFile

		set the itemdelimiter = ":"

		put item 4 of FirstSS into item 4 of FirstCF
		put item 5 of FirstSS into item 5 of FirstCF
		put item 6 of FirstSS into item 6 of FirstCF

		set the itemdelimiter = "/"
		put FirstCF into item 1 of StartingStats
		put item 2 of CharFile into item 2 of StartingStats

        --"---------------------------------------------
        -- // To control HP change the following
        ------------------------------------------------

        -- [Replace]
        -- put item 2 of CharFile into item 2 of StartingStats

        -- [With this]
        -- set SecondSS = item 2 of StartingStats
        -- set SecondCF = item 2 of CharFile
        -- repeat with n = 3 to 6
        --   put item n of SecondSS into item n of SecondCF
        -- end repeat
        -- put item n of SecondSSSecondCF into item 2 of StartingStats

		--------------------------------
		-- // Write StatsFile
		--------------------------------
		file("DAT\CHAR\" & String(MyName) & ".txt").write(string(MyName) & ".txt`" & StartingStats & "`" & ActivateCode)
      file("DAT\CHAR\" & String(MyName) & "-i.txt").write(CharItems)

		------------------------------------
		-- // Iplogger(user, movie)
		------------------------------------
		set myIP = Iplogger(user, myName, movie)
		IncreaseTotalChar()
		sendEmailActivation(movie, user, myName, myEmail, MyPass & ":" & myActCode, myIP)

		sendMovieMessage(movie, user.name, "Server Response", "Character Created")

   end if
end