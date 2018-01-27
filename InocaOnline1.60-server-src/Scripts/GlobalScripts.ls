Global FactionPowers, TreasureList, CharList, LastPhoto, PhotoName, PhotoList, TodaysMonth, TimeOutGo
Global gDispatcher, LegitUsers, CDKeys
Global GlobalMute, FactionCounter, CurrentNumUsers
Global listAdmins, listOfficers, listMappers
Global WeddingStatus, Bride, Groom, Priest
-- movie.sendmessage("system.user.delete", "x", User.Name)
-- // ####### Need to Figure out these issues
-- sendMovieMessage(movie, user.name, "234882347782347923482347", "x")  <<-- to log off the char
-- 234882347782347923482347 :: logoff/kick

on sendEmailActivation(movie, user, charName, email, actCode, myIP)
	set inoUrl = "http://forums.inocaonline.com/inomail.php"
	sendMovieMessage(movie, user.name, "Server Response", "EmailedActivation#" & charName & "#" & email & "#" & actCode & "#" & myIP & "#" & inoUrl)
end

on resetEmailPassword(movie, user, charName, email, myPass, myIP)
	set inoUrl = "http://forums.inocaonline.com/inomail.php"
	sendMovieMessage(movie, user.name, "Server Response", "EmailedResetPass#" & charName & "#" & email & "#" & myPass & "#" & myIP & "#" & inoUrl)
end

on getDateTime()
	return "[ " & the short date & " " & the short time & "] "
end

on loadGameIniFile(user, movie)
	set aniList = file("DAT\Settings\GameDat\aniList-a.txt").read
	sendMovieMessage(movie, user.name, "AppdList|aniList", aniList)
	set aniList = file("DAT\Settings\GameDat\aniList-b.txt").read
	sendMovieMessage(movie, user.name, "AppdList|aniList", aniList)
	set aniList = file("DAT\Settings\GameDat\weapList.txt").read
	sendMovieMessage(movie, user.name, "AppdList|weaponList", aniList)
	set aniList = value(VOID)

	--   set HPMax = "305"
	--   set SkillMax = "100"
	set startmap = file("DAT\Settings\GameDat\StartMap.txt").read
	sendMovieMessage(movie, user.name, "SendSettings", "305:200:" & startmap)
end

on getWelcomeText()
	welNews = string(file("DAT\Settings\News.txt").read)

	set n = 1
	repeat while line n of welNews <> ""
		if n = 1 then
			set tWelNews = line n of welNews
		else
			set tWelNews = tWelNews & line n of welNews
		end if
		set n = n + 1
	end repeat

	tChars = (file("DAT\Settings\UsersCreated.txt").read)
	tChars = "Total number of characters created is " & tChars
	tMaps = string(file("DAT\Settings\TotalMaps.txt").read)
	tMaps = "Total number of maps created is " & tMaps

	return tWelNews & RETURN & tChars & RETURN & tMaps
end


on checkAdminAccess(uname, level)

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
		   set Immname = "@*" & uname & "*@"
		   if listAdmins contains Immname then return TRUE
		2:
		   set Immname = "*" & uname & "*"
		   if listAdmins contains Immname then return TRUE
		3:
		   set Immname = "*" & uname & "*"
		   set PMName = ">*" & uname & "*<"
		   if (listMappers contains PMName) then return FALSE
		   if (listAdmins contains Immname) or (listMappers contains Immname) then return TRUE
		4:
		   set Immname = "*" & uname & "*"
		   if (listAdmins contains Immname) or (listMappers contains Immname) then return TRUE
		5:
		   set Immname = "*" & uname & "*"
		   if (listAdmins contains Immname) or (listMappers contains Immname) or (listOfficers contains Immname) then return TRUE
		6:
		   set Immname = "*" & uname & "*"
		   if (listAdmins contains Immname) or (listOfficers contains Immname) then return TRUE
		7:
		   set Immname = "*" & uname & "*"
		   if (listOfficers contains Immname) then return TRUE
		8:
		   set Immname = "*" & uname & "*"
			set PMName = ">*" & uname & "*<"
		   if (listMappers contains PMName) then return FALSE
		   if (listAdmins contains Immname) or (listMappers contains Immname) or (listOfficers contains Immname) then return TRUE
		9:
		   set Immname = "*" & uname & "*"
		   if (listMappers contains Immname) then return TRUE

	end case
	return FALSE
end


on AuditLog(logText, action)

	case action of
	"IPbanlock":
		set auditFile = "IPbanlock_log.txt"
	"banlock":
		set auditFile = "banlock_log.txt"
	"admindrop":
		set auditFile = "admindrop_log.txt"
	"jail":
		set auditFile = "jail_log.txt"
	"release":
		set auditFile = "jail_log.txt"
	"error":
		set auditFile = "error_log.txt"
	"bankHack":
		set auditFile = "bankHack_log.txt"
	"vaultHack":
		set auditFile = "vaultHack_log.txt"
	"resetPass":
		set auditFile = "resetPass_log.txt"
	"cheat":
		set auditFile = "cheat_log.txt"
	"ipLog":
		set auditFile = "ip_log.txt"
	"newMap":
		set auditFile = "newmap_log.txt"
	end case

	set theFile = file("DAT\AUDITLOGS\" & auditFile).read
	set theFile = theFile & RETURN & getDateTime() & logText
	file("DAT\AUDITLOGS\" & auditFile).write(theFile)

end

on gLog(GuildName, LogInfo)
	set theFile = file("DAT\AUDITLOGS\GUILDS_LOG\" & GuildName & "_log.txt").read
	set theFile = theFile & RETURN & getDateTime() & LogInfo
	file("DAT\AUDITLOGS\GUILDS_LOG\" & GuildName & "_log.txt").write(theFile)
end

on UpdateBroadcastFiles()
	set listAdmins = file("DAT\ACCESSLIST\Immortals.txt").read
	set listOfficers = file("DAT\ACCESSLIST\Officers.txt").read
	set listMappers = file("DAT\ACCESSLIST\Mappers.txt").read
end

on iniCounters()
	global MuteCounter, oldTime

	set oldTime = 0
	set MuteCounter = 0
end

on checkTimeStamp(currTime, username)

	set lastTime = Integer(file("DAT\TimeStamp\" & username & ".txt").read)

	if (lastTime > 0) and (currTime <= lastTime) then RETURN FALSE

	file("DAT\TimeStamp\" & username & ".txt").write(string(currTime))
	return TRUE

end checkTimeStamp

on IncomingMessage (me, movie, group, user, fullMsg)

  if (fullMsg.subject <> "SavePhoto") and (fullMsg.subject <> "SavePainting") then
		set the itemdelimiter = "\"
		set md5str = item 3 of string(fullMsg.subject)
		set curTime = item 2 of string(fullMsg.subject)
		set fullMsg.subject = item 1 of string(fullMsg.subject)

		set md5HashContent = string(fullMsg.content) & string(fullMsg.subject) & "\" & string(curTime) & "\" & "oheavens"

		set md5Chk = CoMD5DigestFastest(md5HashContent)
		if md5Chk <> md5str then
			sendMovieMessage(movie, user.name, "234882347782347923482347",  "x")
			movie.sendmessage("system.user.delete", "x", user.name)
		end if

		if checkTimeStamp(curTime, user.name) = False then
			sendMovieMessage(movie, user.name, "234882347782347923482347",  "x")
			movie.sendmessage("system.user.delete", "x", user.name)
		end if

	end if

	if fullMsg.content contains ";" then
		set the itemdelimiter = ";"
		set xxl = string(item 1 of fullmsg.content)
		set fullmsg.content = string(item 2 of fullmsg.content)

		if xxl <> string(user.name) then
			exit
		end if
	end if

 	if string(user.name) <> string(fullmsg.SenderID) then
		sendMovieMessage(movie, user.name, "5697838",  "x")
		movie.sendmessage("system.user.delete", "x", user.name)
		exit
	end if

	if (user.name contains "newchar") and (string(fullmsg.subject = "QueryCreate") = FALSE) then
		sendMovieMessage(movie, user.name, "5697838",  "x")
		movie.sendmessage("system.user.delete", "x", user.name)
		exit
	end if

put "* * * * ||  " & user.name & " - " & fullMsg.subject & " - " & fullMsg.content


---------------------------------------
-- // Check Blocks
---------------------------------------

if fullMsg.subject contains "Broadcast" then

	----------------------------------
	-- // Broadcast messages
	----------------------------------

	set ReturnMSG = MuteBroadcastCheck(user,movie) -- // Check Mute - For individuals only
	if ReturnMSG = "Block" then exit

	----------------------------------------------------------------
	-- "Wedding Mute"
	----------------------------------------------------------------

	if WeddingStatus > 0 then

		if string(user.name) = Groom or string(user.name) = Bride or string(user.name) = Priest then
			-- // continue
		else
			if checkAdminAccess(user.name, 8) = FALSE then
				sendMovieMessage(movie, user.name, "sqa", "There is a wedding ceremony going on at the moment. Please wait a while before broadcasting.")
		 		exit
			end if
	  	end if

	    ----------------------------------------------------------------
	    -- "Wed Spouses"
	    ----------------------------------------------------------------
	  	if string(fullmsg.content) contains "@Wed Spouses" then
	  		if (WeddingStatus = 1) or (WeddingStatus = 3) then WedSpouses(movie, user)
	  		exit
	  	end if

	    ----------------------------------------------------------------
	    -- "I do"
	    ----------------------------------------------------------------
	  	if string(fullmsg.content) = "I do" then
	  		if (WeddingStatus = 2) and string(user.name) = Groom then
	  			MarAgreed(movie, user, "Groom")
	  			exit
	  		end if
	  		if (WeddingStatus = 4) and string(user.name) = Bride then
	  			MarAgreed(movie, user, "Bride")
	  			exit
	  		end if
		end if

	end if

	----------------------------------------------------------------
	-- "Start Wedding "
	----------------------------------------------------------------
	if string(fullmsg.content) contains "@Begin Wedding " then

		if WeddingStatus = 0 then
			set fullmsg.content = string(fullmsg.content)
			set groomName = word 3 of fullmsg.content
			set brideName = word 4 of fullmsg.content

			StartMarriage(movie, user, groomName, brideName)

			exit
		else
			sendMovieMessage(movie, user.name, "sqa", "There is already a wedding going on.")
			exit
		end if

	end if

	if string(fullmsg.content) contains "@Reset Wedding" then
		if checkAdminAccess(user.name, 2) then ResetWedding()
	end if

	----------------------------------------------------------------
	-- "Divorce Wedding "
	----------------------------------------------------------------
	if string(fullmsg.content) contains "@Divorce " then

		set fullmsg.content = string(fullmsg.content)
		set groomName = word 2 of fullmsg.content
		set brideName = word 3 of fullmsg.content

		divorceMe(movie, user, groomName, brideName)
		exit

	end if

  -----------------------------------------------------
  -- "Badword Filter"
  -----------------------------------------------------

   set TheName = string(user.name)
   set TheBCast = fullMsg.content

	if BadWord(movie, user, TheBCast) then exit

	set powerRank = ""
	set the itemdelimiter = "|"
	set guildd = item 2 of fullMsg.subject
	if guildd <> "" then set guildd = " of the " & guildd

	if (listAdmins contains "*" & user.name & "*") then set powerRank = "Admin "
	if (listAdmins contains "@*" & user.name & "*@") then set powerRank = "Host Admin "
	if (listAdmins contains "+*" & user.name & "*+") then set powerRank = "Chief Admin "
	if (listAdmins contains ">*" & user.name & "*<") then set powerRank = "Security Admin "
	if (listOfficers contains "*" & user.name & "*") then set powerRank = "Officer "
	if (listOfficers contains "@*" & user.name & "*@") then set powerRank = "Trade Officer "
	if (listOfficers contains "+*" & user.name & "*+")  then set powerRank = "Chief Officer "
	if (listMappers contains "*" & user.name & "*") then set powerRank = "Mapper "
	if (listMappers contains "+*" & user.name & "*+") then set powerRank = "Chief Mapper "
	if (listMappers contains "@*" & user.name & "*@") then set powerRank = "Asst.Chief Mapper "
	if (listMappers contains ">*" & user.name & "*<") then set powerRank = "Practice Mapper "

-- 4 bright yellow
-- 120 cyan
-- 16 / 19 orange
-- 7 / 8 / 86 light grey

	if (powerRank <> "") and (powerRank <> "Practice Mapper ") then
		set BCastDat = powerRank & TheName & " broadcasts " & QUOTE & TheBCast & QUOTE
		if powerRank contains "officer" then
			sendMovieMessage(movie, "@AllUsers", "broadcast|120" , BCastDat)
		else
			sendMovieMessage(movie, "@AllUsers", "broadcast|16" , BCastDat)
		end if
	else  --// normal users
		if globalMute = 1 then exit

		set BCastDat =  powerRank & TheName & guildd & " broadcasts " & QUOTE & TheBCast & QUOTE
		sendMovieMessage(movie, "@AllUsers", "broadcast|7" , BCastDat)
	end if

   exit

end if

case fullMsg.subject of

--------------------------------
-- // Update Player Last Login
--------------------------------
   "TodaysMonth":
   set TodaysMonth = fullMsg.content
   set MyName = string(user.name)
   UpdateLastLogin(MyName)

   exit

----------------------------------
-- // Update player respawn point
----------------------------------

   "WriteDeathMap":
   if random(1000) = 1 then RunBoss(me, movie, group, user, fullMsg)
   set MyName = string(user.name)
   set DMap = fullMsg.content
   file("DAT\DM\" & MyName & ".txt").write(DMap)

   exit

----------------------------------
-- // Create new character
----------------------------------

   "QueryCreate":

	if CheckForBlockedIP(User.Name, movie) = "Block" then
		sendMovieMessage(movie, user.name, "455934785938712364852348", "x") -- Tell Player that IP has been banned
		movie.sendmessage("system.user.delete", "x", user.name)
		exit
	end if

   CharCreate(me, movie, group, user, fullMsg, CDKeys)

   exit

----------------------------------
-- // Reset password character
----------------------------------

	"resetpassword":

	set the itemdelimiter = ":"
	set uname = string(item 1 of fullmsg.content)
	set uemail = (item 2 of fullmsg.content)
	set myPass = (item 3 of fullmsg.content)
	set myIP = Iplogger(user, uname, movie)

	if checkAdminAccess(uname, 5) then
		AuditLog("ADMIN RESET: " & user.name & " resetted " & uname & "from  IP = " & myIP, "resetPass")
		exit
	end if

	set myFile = file("DAT\CHAR\" & uname & ".txt").read
	set the itemdelimiter = "`"
	set aCodes = string(item 3 of myFile)

	set the itemdelimiter = ":"
	-- set myPass = item 2 of myFile
	set myEmail = item 1 of aCodes

	if myEmail <> uemail then
		AuditLog("EMAIL MISMATCH: " & user.name & " resetted " & uname & "from  IP = " & myIP, "resetPass")
		exit
	end if

	AuditLog("OK: " & user.name & " resetted " & uname & "from  IP = " & myIP, "resetPass")
	resetEmailPassword(movie, user, uname, uemail, myPass, myIP)
	exit

--"--------------------------------
-- // Allow admin to write files
----------------------------------

   "FileTransToYou":
   set FileAdmins = file("DAT\ACCESSLIST\File Admins.txt").read
   set MyNamee = "*" & string(user.name) & "*"
   set the itemdelimiter = "~"
   set TheFolder = item 1 of fullmsg.content
   set TheFileName = item 2 of fullmsg.content
   set MyNewFileContent = item 3 of fullmsg.content
   set FullPathx = TheFolder & "\" & TheFileName

	if FileAdmins contains MyNamee then

		if (FullPathx contains "../" or FullPathx contains "..\") then exit

     	set the itemdelimiter = ":"
		set n = 1
     	repeat while line n of FileAdmins <> ""
       	if item 1 of line n of FileAdmins = MyNamee then
				if item 2 of line n of FileAdmins = "*" then
					file("DAT\" & FullPathX).write(MyNewFileContent)
					sendMovieMessage(movie, user.name, "sqa", "File has been uploaded.")
				else
					set nn = 2
					repeat while item nn of line n of FileAdmins <> ""
						if item nn of line n of FileAdmins = TheFolder then
							file("DAT\" & FullPathX).write(MyNewFileContent)
							sendMovieMessage(movie, user.name, "sqa", "File has been uploaded.")
							exit
						end if
						set nn = nn + 1
					end repeat
				end if
       		exit repeat
       	end if
       	set n = n + 1
     	end repeat

   end if

   exit

----------------------------------
-- // Allow admin to read files
----------------------------------

   "FileTransToMe":
   set FileAdmins = file("DAT\ACCESSLIST\File Admins.txt").read
   set MyNamee = "*" & string(user.name) & "*"
   set the itemdelimiter = ":"
   set TheFolder = item 1 of fullmsg.content
   set TheFileName = item 2 of fullmsg.content
   -- set MyNewFileContent = item 3 of fullmsg.content
   set FullPathx = TheFolder & "\" & TheFileName

	if FileAdmins contains MyNamee then

		if (FullPathx contains "../" or FullPathx contains "..\") then exit

     	set the itemdelimiter = ":"
		set n = 1
     	repeat while line n of FileAdmins <> ""
       	if item 1 of line n of FileAdmins = MyNamee then
				if item 2 of line n of FileAdmins = "*" then
					set TheFile = file("DAT\" & FullPathx).read
					sendMovieMessage(movie, user.name, "FTSF", TheFile)
				else
					set nn = 2
					repeat while item nn of line n of FileAdmins <> ""
						if item nn of line n of FileAdmins = TheFolder then
							set TheFile = file("DAT\" & FullPathx).read
							sendMovieMessage(movie, user.name, "FTSF", TheFile)
							exit repeat
						end if
						set nn = nn + 1
					end repeat
				end if
       		exit repeat
       	end if
       	set n = n + 1
     	end repeat

   end if

   exit



	"JoinCTF":
		CTFJoinTeam(user, movie)
	exit

	"DropAnItemCTF":
		dropFlag(user, movie, fullMsg.content)
   exit

	"ScoreCTF":
		calculateCTFScore(user.name, movie)
	exit

	"GetFlagCarrierCTF":
		getFlagCarrier(user, movie)
	exit

	"LeaveCTF":
		CTFLeaveTeam(user, movie)
	exit

----------------------------------
-- // Check for special commands
----------------------------------

	"callcommands":

		if fullmsg.content contains "startctf" then
			if checkAdminAccess(user.name, 2) then
				startCTF("BUILD", movie)
				exit
			end if
		end if

		if fullmsg.content contains "endctf" then
			if checkAdminAccess(user.name, 2) then
				endCTFGame(movie)
				exit
			end if
		end if

		if fullmsg.content contains "resetflags" then
			if checkAdminAccess(user.name, 2) then
				resetFlags(movie)
				exit
			end if
		end if


		----------------------------------
		-- // Broadcasts with "*** " infront
		----------------------------------
		if fullMsg.content contains "rpg ***" then

			if checkAdminAccess(user.name, 3) then
				set blastMsg = fullmsg.content
				delete word 1 of blastMsg
				if char 1 of blastMsg = " " then delete char 1 of blastMsg
				sendMovieMessage(movie, "@allusers", "broadcast|4", blastMsg)
				sendMovieMessage(movie, "@admin", "broadcast|0", user.name & " sent the RPG message.")
			end if

			exit
		end if

	  ----------------------------------------------------------------
	  -- // "Global Mute"  -- only Immortals can do global mute
	  ----------------------------------------------------------------
		if fullMsg.content = "muteall" then
		   if globalMute = 1 then exit

		   if checkAdminAccess(user.name, 2) then
				set globalMute = 1
				sendMovieMessage(movie,  "@AllUsers", "Broadcast|4", "*** Global mute has been activated" )
			end if
			exit
	  end if

	  ----------------------------------------------------------------
	  -- // "Global UnMute"  -- only Immortals can do global unmute
	  ----------------------------------------------------------------
		if fullMsg.content = "unmuteall" then
		   if globalMute = 0 then exit

		   if checkAdminAccess(user.name, 2) then
				set globalMute = 0
				sendMovieMessage(movie,  "@AllUsers", "Broadcast|4", "*** Global mute has been deactivated" )
			end if
			exit
	  end if

	  ----------------------------------------------------------------
	  -- // "Mute "
	  ----------------------------------------------------------------
	  if fullMsg.content contains "Mute " then
		set Returnmsg = MutePlayer(user, fullmsg, movie)
		if Returnmsg = "yes" or Returnmsg = "no" then exit
		if Returnmsg = "err" then auditlog(user.name & " tried to " & fullmsg.content, "error")
		exit
	  end if

	  ----------------------------------------------------------------
	  -- // "Voice "
	  ----------------------------------------------------------------
	  if fullMsg.content contains "voice " then
		set Returnmsg = VoicePlayer(user, fullmsg, movie)
		if Returnmsg = "yes" or Returnmsg = "no" then exit
		if Returnmsg = "err" then auditlog(user.name & " tried to " & fullmsg.content, "error")
		exit
	  end if

	  ----------------------------------------------------------------
	  -- // "Mass Save "
	  ----------------------------------------------------------------
	  if fullMsg.content = "masssave" then
			if checkAdminAccess(user.name, 1) then
				sendMovieMessage(movie,  "@AllUsers", "MassSave", "x")
			end if
			exit
		end if

	  ----------------------------------------------------------------
	  -- // "Mass Reload System Settings "
	  ----------------------------------------------------------------
	  if fullMsg.content = "massreload" then
			if checkAdminAccess(user.name, 1) then
				sendMovieMessage(movie,  "@AllUsers", "ReloadSystemPlease", "x")
			end if
			exit
		end if

	  ----------------------------------------------------------------
	  -- // "View Cheaters "
	  ----------------------------------------------------------------
	  if fullMsg.content = "viewCheaters" then
	  		if checkAdminAccess(user.name, 2) then
 				ViewCheaters(me, movie, group, user, fullmsg)
 			end if
 	  		exit
 	  end if

     ----------------------------------------------------------------
     -- // "StaffList refresh"
     ----------------------------------------------------------------
	  if fullMsg.content = "refresh stafflist" then

		   if checkAdminAccess(user.name, 1) then
				UpdateBroadcastFiles()
				exit
			end if
			exit
	  end if

	  ----------------------------------------------------------------
	  -- // "jail "
	  ----------------------------------------------------------------
	  if fullMsg.content contains "jail " then
			set Returnmsg = Jailscript(user, movie, fullmsg)
			--if Returnmsg = "yes" then exit
			exit
	  end if

	  ----------------------------------------------------------------
	  -- // "release "
	  ----------------------------------------------------------------
	  if fullMsg.content contains "release " then
		set Returnmsg = UnJailscript(user, movie, fullmsg)
		--if Returnmsg = "yes" then exit
		exit
	  end if

		----------------------------------------------------------------
		-- // "maximum who"
		----------------------------------------------------------------
		if fullMsg.content = "maxonline" or fullMsg.content = "maxonline all" then
			set the itemdelimiter = "|"
			set UserMaxFile = file("DAT\settings\usermax.txt").read
			if UserMaxFile contains "|" then
				set CNU = item 1 of string(UserMaxFile)

			   if checkAdminAccess(user.name, 1) then
			   	if (fullMsg.content = "maxonline all") then sendMovieMessage(movie,  "@AllUsers", "broadcast|4", "*** Maximum number of users online is " & CNU)
					if (fullMsg.content = "maxonline") then sendMovieMessage(movie,  user.name, "sqa", "*** Maximum number of users online is " & CNU & " on the " &  item 2 of string(UserMaxFile))
				end if
			end if
			exit
		end if

		----------------------------------
		-- // Get User IP
		----------------------------------
		if fullMsg.content contains "getIP " then
			if checkAdminAccess(user.name, 2) then
				set UserName = word 2 of fullMsg.content
				set theIP = GetIP(UserName, movie)
				sendMovieMessage(movie, user.name, "sqa", "The IP of " & UserName & " is: " & theIP)
			end if
			exit
		end if

		----------------------------------
		-- // Get Player Info
		----------------------------------

		if fullMsg.content contains "getInv " then
			if checkAdminAccess(user.name, 2) then
				set Uname = string(word 2 of fullMsg.content)
				set itemFile = file("DAT\Char\" & Uname &"-i.txt").read
				sendMovieMessage(movie, user.name, "sqa", Uname & " has " & itemFile)
			end if
			exit
		end if

		--"--------------------------------
		-- // KickTheDOOD
		----------------------------------
		if fullMsg.content contains "kick " then

			if checkAdminAccess(user.name, 2) then

				set the itemdelimiter = " "
				set UserName = item 2 of fullMsg.content
				sendMovieMessage(movie, UserName, "234882347782347923482347", "x")
				movie.sendmessage("system.user.delete", "x", UserName)
				sendMovieMessage(movie, "@Admins", "sqa", UserName & " has been kicked by " & user.name)
			end if
			exit
		end if

		if fullMsg.content contains "purge " then -- purging out of the group
			if checkAdminAccess(user.name, 1) then
				set the itemdelimiter = " "
				set UserName = item 2 of fullMsg.content
				movie.sendmessage("system.user.delete", "x", UserName)
			end if
			exit
		end if


		----------------------------------
		-- // Lock Player
		----------------------------------

		if fullMsg.content contains "lock " then
			--set UserToBan = fullMsg.content
			if checkAdminAccess(user.name, 2) then

				set the itemdelimiter = " "
				set UserToBan = item 2 of fullMsg.content
				set MyFile = file("DAT\CHAR\" & string(UserToBan) & ".txt").read

				if myFile contains ":" then

					if MyFile contains "BANNED!!!!!!!!!!!%%" then
						sendMovieMessage(movie, user.name, "sqa", usertoban & " is already locked.")
					else

						if checkAdminAccess(UserToBan, 2) then exit

						set MyFile = "BANNED!!!!!!!!!!!%%" & MyFile
						file("DAT\CHAR\" & string(UserToBan) & ".txt").write(MyFile)
						set theIP = GetIP(UserToBan, movie)

						movie.sendmessage("system.user.delete", "x", UserToBan)
						sendMovieMessage(movie, UserToBan, "5697838", "x")

						sendMovieMessage(movie, "@Admins", "sqa", usertoban & " (" & theIP & ") has been locked by " & user.name)
						auditLog(UserToBan & " (" & theIP & ") banned by " & user.name , "banlock")
					end if
				else
					sendMovieMessage(movie, user.name, "sqa", usertoban & " is an invalid character.")
				end if
			end if

			exit
		end if

		if fullMsg.content contains "unlock " then
			--set UserToBan = fullMsg.content

			if checkAdminAccess(user.name, 2) then
				set the itemdelimiter = " "
				set UserToUnBan = item 2 of fullMsg.content
				set CharFile = file("DAT\char\" & string(UserToUnBan) & ".txt").read
				if CharFile contains "BANNED!!!!!!!!!!!%%" then
					set the itemdelimiter = "%"
					set CharFile = item 3 of string(CharFile)
					file("DAT\char\" & string(UserToUnBan) & ".txt").write(CharFile)
					sendMovieMessage(movie, "@Admins", "sqa", usertoban & " has been locked.")
					auditLog(UserToBan & " unbanned by " & user.name , "banlock")
				else
					sendMovieMessage(movie, user.name, "sqa", usertoban & " is not locked at all.")
				end if

			end if

			exit
		end if

		if fullMsg.content contains "PermLock " then

			if checkAdminAccess(user.name, 2) then
				set UserToPermBan = item 2 of fullMsg.content
				set MyFile = file("DAT\CHAR\" & string(UserToPermBan) & ".txt").read

				if myFile contains ":" then
					if checkAdminAccess(UserToPermBan, 2) then exit

					set IPtoBan = GetIP(UserToPermBan, movie)
					set FilName = "DAT\SETTINGS\BannedIPs.txt"
					set BannedIPs = file(FilName).read

					if BannedIPs contains IPtoBan then
						sendMovieMessage(movie, user.name, "sqa", UserToPermBan & " was already permanently locked.")
					else
						set BannedIPs = BannedIPs & RETURN & IPtoBan
						file("DAT\SETTINGS\BannedIPs.txt").write(BannedIPs)

						set MyFile = "BANNED!!!!!!!!!!!%%" & MyFile
						file("DAT\CHAR\" & string(UserToPermBan) & ".txt").write(MyFile)

						movie.sendmessage("system.user.delete", "x", UserToPermBan)
						sendMovieMessage(movie, UserToPermBan, "5697838", "x")

						sendMovieMessage(movie, "@Admins", "sqa", "The IP Address " & IPtoBan & " is now permanently locked.")
						auditLog(UserToPermBan & " (" & IPtoBan & ") perm banned by " & user.name , "banlock")
					end if
				else
					sendMovieMessage(movie, user.name, "sqa", UserToPermBan & " is an invalid character.")
				end if
			end if
			exit
		end if

		----------------------------------
		-- // Add IP Ban
		----------------------------------
		if fullMsg.content contains "BanIP " then

			if checkAdminAccess(user.name, 2) then
				set IPtoBan = word 2 of fullMsg.content
				set FilName = "DAT\SETTINGS\BannedIPs.txt"
				set BannedIPs = file(FilName).read
				if BannedIPs contains IPtoBan then
				else
					set BannedIPs = BannedIPs & RETURN & IPtoBan
					file("DAT\SETTINGS\BannedIPs.txt").write(BannedIPs)
					sendMovieMessage(movie, user.name, "sqa", "The IP Address " & IPtoBan & " has been banned.")
					auditLog(IPtoBan & " banned by " & user.name , "IPbanlock")
				end if
			end if
			exit
		end if
		----------------------------------
		-- // Remove IP Ban
		----------------------------------

		if fullMsg.content contains "unBanIP " then

			if checkAdminAccess(user.name, 2) then

				set IPtoRemove = word 2 of fullMsg.content
				set FilName = "DAT\SETTINGS\BannedIPs.txt"
				set BannedIPs = file(FilName).read
				if BannedIPs contains IPtoRemove then
					set the itemdelimiter = "."

					set ReplaceIP = "-" & item 1 of IPtoRemove & "-" & item 2 of IPtoRemove & "-" & item 3 of IPtoRemove & "-" & item 4 of IPtoRemove

					set the itemdelimiter = RETURN
					set n = 1
					repeat while line n of BannedIPs <> ""
						if item n of BannedIPs = IPtoRemove then
							put ReplaceIP into item n of BannedIPs
							exit repeat
						end if
						n = n + 1
					end repeat
					file("DAT\SETTINGS\BannedIPs.txt").write(BannedIPs)
					sendMovieMessage(movie, user.name, "sqa", "The IP Address " & IPtoBan & " has been unbanned.")
					auditLog(IPtoRemove & " unbanned by " & user.name , "IPbanlock")
					exit
				end if
			end if
			exit
		end if
		----------------------------------------------------------------
		-- // "Set as password map"
		----------------------------------------------------------------

		if fullMsg.content contains "set passwordmap " then -- actual map

		-- set passwordmap sillyboy %x999y1000 5 5

			set TheFolder = "QuestPassMap"
			set TheMap = GetCurrentMap(user.name)
			set FullPathx = "DAT\" & TheFolder & "\" & TheMap & "-qp.txt"

			set isEmpty = file(FullPathx).read
			if string(isEmpty) <> "" then
				sendMovieMessage(movie, user.name, "sqa", "The password script is already active on this map.")
				exit
			end if

			if checkFileAccess(user.name, TheFolder) then
				set passCode = word 3 of fullMsg.content
				set the itemdelimiter = "%"
				set newLoc = item 2 of fullMsg.content

				file(FullPathX).write(passCode & ":" & newLoc)
				sendMovieMessage(movie, user.name, "sqa", "You have set the password for the current map, " & TheMap & ".")
			end if
			exit
		end if

		----------------------------------------------------------------
		-- // "Set as password release map"
		----------------------------------------------------------------

		if fullMsg.content contains "set releasepassmap " then -- map that releases password

		-- set passwordmap sillyboy

			set TheFolder = "QuestPassMap"
			set TheMap = GetCurrentMap(user.name)
			set FullPathx = "DAT\" & TheFolder & "\rp-" & TheMap & ".txt"

			if checkFileAccess(user.name, TheFolder) then

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
		end if

		--"--------------------------------
		-- // Admin Item Drop
		----------------------------------

		if fullMsg.content contains "create " then -- create item in inventory
			if checkAdminAccess(user.name, 2) then
				set FilName = "DAT\ACCESSLIST\immortaldrops.txt"
				set Immortals = file(FilName).read
				set Immname = "*" & user.name & "*"

				if Immortals contains Immname then
					set msgDat = fullMsg.content
					set the itemdelimiter = "#"

					set toCreate = string(item 2 of msgDat)
					set toPerson = string(item 3 of msgDat)

					if toCreate = "" then exit

					set the itemdelimiter = "-"
					set amtCreate = integer(item 2 of toCreate)
					set toCreate = string(item 1 of toCreate)

					if amtCreate < 1 then set amtCreate = 1
					if toPerson = "" then set toPerson = user.name

					if AddSaveItemX (toCreate, amtCreate, toPerson, movie) then
						AuditLog(user.name & " created the item for " & toPerson, "admindrop")
						sendMovieMessage(movie, user.name, "sqa", "Item has been created in your inventory")
					end if
				end if
			end if
		   exit
		end if

		if fullmsg.content contains "clearInv " or fullmsg.content = "clearinv" then -- create item in inventory

			if checkAdminAccess(user.name, 2) then
				set FilName = "DAT\ACCESSLIST\immortaldrops.txt"
				set Immortals = file(FilName).read
				set Immname = "*" & user.name & "*"

				if Immortals contains Immname then
					set toPerson = word 2 of fullmsg.content
					if toPerson = "" then set toPerson = user.name

					set filName = "DAT\Char\" & toPerson & "-i.txt"
					set filDT = file(filName).read

					set the itemdelimiter = "|"
					put "::::::::::::::" into item 2 of filDT
					file(filName).write(filDT)
					sendMovieMessage(movie, toPerson, "inx", filDT)
				end if
			end if
		end if

		if fullmsg.content contains "showInv " then -- create item in inventory
			if checkAdminAccess(user.name, 8) then
					set toPerson = word 2 of fullmsg.content
					if toPerson = "" then set toPerson = user.name

					set filName = "DAT\Char\" & toPerson & "-i.txt"
					set filDT = file(filName).read

					sendMovieMessage(movie, user.name, "sqa", filDT)
			end if
		end if

----------------------------------
-- // Kick / Ban The Dood
----------------------------------
   "KickHacker":
		--set UserName = fullMsg.content
		--sendMovieMessage(movie, UserName, "234882347782347923482347", "x")
		--sendMovieMessage(movie, "@Admins", "sqa", UserName & " has been kicked for hacking " & user.name)
	exit

	"AutoLock":
		set the itemdelimiter = " "
		set UserToBan = string(user.name)
		set MyFile = file("DAT\CHAR\" & UserToBan & ".txt").read

		if myFile contains ":" then

			if MyFile contains "BANNED!!!!!!!!!!!%%" then
				sendMovieMessage(movie, user.name, "sqa", "You were already locked.")
			else

				if checkAdminAccess(UserToBan, 1) then exit

				set MyFile = "BANNED!!!!!!!!!!!%%" & MyFile
				file("DAT\CHAR\" & UserToBan & ".txt").write(MyFile)
				set theIP = GetIP(UserToBan, movie)

				movie.sendmessage("system.user.delete", "x", UserToBan)
				sendMovieMessage(movie, UserToBan, "5697838", "x")

				sendMovieMessage(movie, "@Admins", "sqa", usertoban & " (" & theIP & ") has been autolocked.")
				auditLog(UserToBan & " (" & theIP & ") has been autobanned by the program.", "banlock")
			end if
		end if
	exit

----------------------------------
-- // Buy Lottery
----------------------------------
   "BuyLottery":

		buyLottery(user, movie)

	exit

----------------------------------
-- // Grab Password List
----------------------------------

   "GrabPassList":

	set infoUser = file("DAT\QuestPass\" & string(user.name) & "-qp.txt").read

	set the itemdelimiter = "/"
	set infoUser = item 1 of infoUser

	if string(infoUser) = "" then
		sendMovieMessage(movie, user.name, "sqa", "Sorry, you have not obtained any passwords yet.")
	else
		sendMovieMessage(movie, user.name, "ListPass", infoUser)
	end if

   exit

--"--------------------------------
-- // Check PasswordMap
----------------------------------

   "QPCheck":
   set infoStr = fullMsg.content
   set the itemdelimiter = ":"

   set fileName = item 2 of infoStr
   set infoMap = string(file("DAT\QuestPassMap\" & fileName & "-qp.txt").read)

	if infoMap = "" then
		sendMovieMessage(movie, user.name, "sqa", "Sorry, this map does not require a password.")
	else
   	set infoUser = file("DAT\QuestPass\" & string(user.name) & "-qp.txt").read
   	set the itemdelimiter = "/"
		set infoUser = item 1 of infoUser
		sendMovieMessage(movie, user.name, "CheckedQP", infoStr & "|" & infoMap & "|" & infoUser)
	end if

   exit

----------------------------------
-- // Get Guild List
----------------------------------

  "GetGList":
   set Guilds = file("DAT\GUILDS\GuildList.txt").read
   sendMovieMessage(movie, user.name, "GLDLST", Guilds)

   exit

----------------------------------
-- // Create New Guild
----------------------------------

  "GuildCreate":

   set MyName = fullMsg.content
   set CharFile = fullMsg.content
   set the itemdelimiter = ":"
   set MyName = item 1 of MyName
   set GuildDat = item 2 of CharFile

	if (MyName contains "../" or MyName contains "..\") then exit
   set MyFile = file("DAT\GUILDS\" & string(MyName) & ".txt").read

   if myFile contains "-" then

     sendMovieMessage(movie, user.name, "Server Response", "CannnotGuild")
    else
     sendMovieMessage(movie, user.name, "Server Response", "Guild Created")
     if (MyName contains "../" or MyName contains "..\") then exit
     file("DAT\GUILDS\" & string(MyName) & ".txt").write(GuildDat)
     sendMovieMessage(movie, user.name, "LoadGuild", GuildDat)
     set Guilds = file("DAT\GUILDS\GuildList.txt").read
     set Guilds = Guilds & MyName & ":"
     file("DAT\GUILDS\GuildList.txt").write(Guilds)
   end if

   exit

----------------------------------
-- // 937oom
----------------------------------

   "937oom":
    set TheDt = fullMsg.content
    set FilNme = file("DAT\SETTINGS\cd.txt").read
    --put string(User.name) & " logs in with code: " & TheDt
    if char 4 of TheDt = "" then exit
    set HesLegit = 0

    if CDKeys contains TheDt then
      set LegitUsers = LegitUsers & "*" & user.name & "*"
      sendMovieMessage(movie, user.name, "okok", "x")
    end if

   exit


----------------------------------
-- // Load My Guild
----------------------------------

   "LoadMyGuild":
    set MyName = fullMsg.content
    set the itemdelimiter = ";"
    if fullMsg.content contains ";" then set MyName = string(item 2 of fullmsg.content)
    if (MyName contains "../" or MyName contains "..\") then exit
    set MyFile = file("DAT\GUILDS\" & string(MyName) & ".txt").read
    sendMovieMessage(movie, user.name, "LoadGuild", MyFile)

   exit

----------------------------------
-- // View A Guild
----------------------------------

   "ViewAGuild":
    set MyName = fullMsg.content
    if (MyName contains "../" or MyName contains "..\") then exit
    set MyFile = file("DAT\GUILDS\" & string(MyName) & ".txt").read
    sendMovieMessage(movie, user.name, "ViewAGuild", MyFile)

   exit

----------------------------------
-- // Guild dell
----------------------------------

   "GuildDell":
   set GuildToDel = fullMsg.content
   set Guilds = file("DAT\GUILDS\GuildList.txt").read
   set the itemdelimiter = ":"
   set NewList = ""
   repeat with x = 1 to 800
     if item x of Guilds <> "" then
      if item x of Guilds <> GuildToDel then set NewList = NewList & item x of Guilds & ":"
     end if
   end repeat
   file("DAT\GUILDS\GuildList.txt").write(NewList)

   exit
----------------------------------
-- // Change Password
----------------------------------

   "changePass":

	set newPass = fullMsg.content
   set MyFile = file("DAT\CHAR\" & string(user.name) & ".txt").read
	set the itemdelimiter = ":"

	put newPass into item 2 of MyFile
	file("DAT\CHAR\" & string(user.name) & ".txt").write(MyFile)
	sendMovieMessage(movie, user.name, "PasswordChanged", "x")

	exit
--"--------------------------------
-- // Load Character
----------------------------------

   "LoadChar":

   set tDT = fullMsg.content
   set the itemdelimiter = ":"
   set MyName = item 1 of tDT
   set PPW = item 2 of tDT
   set MyCode = item 3 of tDT  -- Activation Code
   set ClientVer = item 4 of tDT

   set MyFile = file("DAT\CHAR\" & string(MyName) & ".txt").read
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read

	if ClientVer <> "1.5888jtd88" then
		sendMovieMessage(movie, user.name, "ClientVersion",  "v1.52")
		movie.sendmessage("system.user.delete", "x", user.name)
		exit
	end if

	if MyFile contains "BANNED!!!!!!" then
		sendMovieMessage(movie, user.name, "5697838",  "x")
		movie.sendmessage("system.user.delete", "x", user.name)
		exit
	end if

	if CheckForBlockedIP(User.Name, movie) = "Block" then
		sendMovieMessage(movie, user.name, "455934785938712364852348", "x") -- Tell Player that IP has been banned
		movie.sendmessage("system.user.delete", "x", user.name)
		exit
	end if

	if myFile contains ":" then

		set the itemdelimiter = "`"
		set activateString = item 3 of myFile
		set myFile = item 1 of myFile & "`" & item 2 of myFile

		set the itemdelimiter = ":"
		if item 3 of activateString <> "1" then --// account is not yet activated
			if myCode = item 2 of activateString then
				put "1" into item 3 of activateString
				myFile = myFile & "`" & activateString
				file("DAT\CHAR\" & string(MyName) & ".txt").write(myFile)
			else
				sendMovieMessage(movie, user.name, "AccountNotActive", "X")
				exit
			end if
		else
			myFile = myFile & "`" & activateString
		end if

		set correctPass = FALSE
		set fPass = item 2 of string(MyFile)

		if fPass = PPW then
			correctPass = TRUE
		else
			set fPass = CoMD5DigestFastest(fPass)
			if fPass = PPW then correctPass = TRUE
		end if

	correctPass = TRUE
		if correctPass then

			userLogOna (user, movie)
			loadGameIniFile(user, movie)

			if (MyItemsFile contains ":") = FALSE then
				set MyItemsFile = "0|Apple-2:Dagger-1:::::::::::::|NOTHING:NOTHING:NOTHING:NOTHING:NOTHING:NOTHING:NOTHING:NOTHING"
				file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
			end if

       	sendMovieMessage(movie, user.name, "LoadCharFile", MyFile)
       	sendMovieMessage(movie, user.name, "inx", MyItemsFile)

       	set FactionPowers = file("DAT\POLITICAL\factions.txt").read
       	sendMovieMessage(movie, user.name, "factnrtrn",  FactionPowers)

			set wText = getWelcomeText()
			sendMovieMessage(movie, user.name, "News", wText)

       	set AssSystem = file("DAT\ASSASSINS\MODE.txt").read
       	if AssSystem contains "LIGHT" then sendMovieMessage(movie, user.name, "ltass",  "x")

       	if checkAdminAccess(user.name, 3) then sendMovieMessage(movie, user.name, "ImTrue", "x")

       	set SysFill = file("DAT\SETTINGS\System.txt").read
       	if SysFill contains "Speed Hack Protection:OFF" then sendMovieMessage(movie, user.name, "DontSHP", "x")

--       	set MyFile = file("DAT\SETTINGS\Guest Access.txt").read
--       	if MyFile <> "ON" then sendMovieMessage(movie, user.name, "455934785938712364852348", "455934785938712364852348")

		else

			sendMovieMessage(movie, user.name, "Server Response", "Invalid PW")
		end if

   else
     sendMovieMessage(movie, user.name, "Server Response", "Nonexistant")
   end if


   exit

----------------------------------
-- // Supa Warp (warp, warptome, warpme)
----------------------------------

   "SupaWarp":

   set the itemdelimiter = "*"
   set WarpUser = string(item 1 of fullmsg.content)
   set WarpDat = string(item 2 of fullmsg.content)

   if checkAdminAccess(user.name, 3) then
   	if WarpDat contains " to " then set WarpDat = WarpShortcuts(WarpDat, user, movie)
		if WarpDat = "NoFile" then exit
     	sendMovieMessage(movie, WarpUser, "Warp1937931", WarpDat)
   end if

   exit

   "SuparWarp":

   if checkAdminAccess(user.name, 3) then
     	sendMovieMessage(movie, fullmsg.content, "ChatMsg", "WRP|" & user.name)
   end if

   exit
----------------------------------
-- // cql
----------------------------------
   "cq1":

   set xFilName = string(fullmsg.SenderID) & ".txt"
   set HisName = string(user.name)
   set FilName = HisName & ".txt"
   set SrStr = "*" & user.name & "*"

   if LegitUsers contains SrStr then

	else

     sendMovieMessage(movie, user.name, "GetItems", "#@(*|18983|292|123|444|12389")
     sendMovieMessage(movie, user.name, "YouGotKicked", "The Mighty Server God")
     sendMovieMessage(movie, user.name, "NewspaperX", "@!#H!@*!@#H*!@H#")
     sendMovieMessage(movie, user.name, "inv", "@!#H!@*!@#H*!@H#")
     exit
   end if

   if FilName <> xFilName then
      set MyFile = file("DAT\CHAR\" & string(HisName) & ".txt").read
      set MyFile = "BANNED!!!!!!!!!!!" & MyFile
      file("DAT\CHAR\" & string(HisName) & ".txt").write(MyFile)
      sendMovieMessage(movie, user.name, "YouGotKicked", "The Mighty Server God")
      exit
   end if

   set FilDT = fullMsg.content

   set MyFile = file("DAT\CHAR\" & HisName & ".txt").read

   set the itemdelimiter = "`"
   set ActivateCode = item 3 of myFile

   set the itemdelimiter = "."
   if item 1 of FilDT <> HisName then exit
   if HisName contains "NewChar" then exit

   file("DAT\CHAR\" & FilName).write(FilDt & "`" & ActivateCode)
--   if random(4000) = 1 then QuestChest
   exit

----------------------------------
-- // Save Guild
----------------------------------

   "SaveGuild":
   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set FilDat = item 2 of FileDT
   if (FilName contains "../" or FilName contains "..\") then exit
   file("DAT\GUILDS\" & FilName).write(FilDat)

   exit

----------------------------------
-- // Save Items
----------------------------------

   "SaveItems":

   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set FilDat = item 2 of FileDT

   file("DAT\ITEMS\" & FilName).write(FilDat)


   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT

   set FilDat = item 2 of FileDT
   set the itemdelimiter = "-"
   set FilNameX = item 1 of FilName
	------------------------------
	-- Trigger LimitedSafeCheck()
	------------------------------

	if checkAdminAccess(user.name, 4) then
		set Check = LimitedSafeCheck( user , FilNameX )
		if Check = "ok" then
			file("DAT\ITEMS\" & FilName).write(FilDat)
			file("DAT\MapsToUpdate\" & FilName).write(FilDat)
		end if
	else
		file("DAT\ITEMS\" & FilName).write(FilDat)
	end if


   exit

----------------------------------
-- // Hacked Items
----------------------------------

   "HckItm":

   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set NewItem = item 2 of FileDT
   set ItDt = item 2 of FileDT
   set ItemList = file("DAT\ITEMS\" & FilName).read

   if ItemList contains NewItem then
     set the itemdelimiter = "|"

     repeat with itemIndexs = 1 to 20
        if NewItem = item itemIndexs of Itemlist then put "" into item itemIndexs of ItemList
     end repeat

     file("DAT\ITEMS\" & FilName).write(ItemList)
    else
   end if

   exit

----------------------------------
-- // Remove Equipment
----------------------------------

   "remEQ":

--   if checkAdminAccess(user.name, 9) then exit

   set FileDT = fullMsg.content
   set the itemdelimiter = ":"
   set ItemToRemove = item 1 of FileDT
   set ItemType = item 2 of FileDT
   if ItemToRemove = "NOTHING" then exit

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set MyEquipped = item 3 of MyItemsFile
   set the itemdelimiter = ":"

   set ItsAGo = 0

   repeat with xxx = 1 to 15
     if item xxx of MyEquipment = "" then set ItsAGo = 1
   end repeat

   if MyEquipment contains ItemToRemove then set ItsAGo = 1

   if ItsAGo < 1 then
      sendMovieMessage(movie, user.name, "flinv", MyItemsFile)
      exit
	end if

    if ItemType = "Head" then set EquipSlot = 1
    if ItemType = "Body" then set EquipSlot = 2
    if ItemType = "LeftHand" then set EquipSlot = 3
    if ItemType = "RightHand" then set EquipSlot = 4
    if ItemType = "Feet" then set EquipSlot = 5
    if ItemType = "Ring" then set EquipSlot = 6
    if ItemType = "Neck" then set EquipSlot = 7
    if ItemType = "Belt" then set EquipSlot = 8

    if item EquipSlot of MyEquipped = ItemToRemove then
      put "NOTHING" into item EquipSlot of MyEquipped
      set the itemdelimiter = "|"
      put MyEquipped into item 3 of MyItemsFile

      set nItem = ItemtoRemove
      set ItemNum = 1
      InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)
      exit
     end if

     sendMovieMessage(movie, user.name, "sqa", "You've already unequipped this!.")

   exit

--"--------------------------------
-- // Save Newspaper
----------------------------------

   "SaveNewsPaper":
   file("DAT\NEWSPAPERS\" & string(user.name) & ".txt").write(fullMsg.content)

   exit

--"--------------------------------
-- // ReadNewspaperGUI
----------------------------------

   "ReadNewspaperGUI":
   set NewsName = string(user.name) & ".txt"
   set NPFile = file("DAT\NEWSPAPERS\" & NewsName).read
   sendMovieMessage(movie, user.name, "NewspaperX", NPFile)

   exit

--"--------------------------------
-- // ReadNewspaper
----------------------------------

   "ReadNewspaper":
   set NewsName = fullMsg.content & ".txt"
   set NPFile = file("DAT\NEWSPAPERS\" & NewsName).read
   sendMovieMessage(movie, user.name, "Newspaper", NPFile)
   set the itemdelimiter = "`"
   set Photo1 = item 1 of NPFile
   set Photo2 = item 2 of NPFile
   set Photo3 = item 3 of NPFile
   set ThePainting = file("DAT\ART\" & Photo1).readvalue()
   sendMovieMessage(movie, user.name, "Photo1Send", ThePainting)
   set ThePainting = file("DAT\ART\" & Photo2).readvalue()
   sendMovieMessage(movie, user.name, "Photo2Send", ThePainting)
   set ThePainting = file("DAT\ART\" & Photo3).readvalue()
   sendMovieMessage(movie, user.name, "Photo3Send", ThePainting)

   exit

----------------------------------
-- // rhnd
----------------------------------

   "rhnd":
   set FileDT = fullMsg.content
   set the itemdelimiter = ":"
   set ItemToRemove = item 1 of FileDT
   set ItemType = item 2 of FileDT

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipped = item 3 of MyItemsFile
   set the itemdelimiter = ":"

   put "NOTHING" into item 4 of MyEquipped

   set the itemdelimiter = "|"
   put MyEquipped into item 3 of MyItemsFile
   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

   exit

----------------------------------
-- // return inventory
----------------------------------

   "rtrninv":
   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

   exit

--"--------------------------------
-- // Save Painting
----------------------------------

   "SavePainting":
   set MyName = user.name
   set FileNme = random(10000000)
   set TheImage = fullmsg.content
   file("DAT\ART\" & string(FileNme) & ".txt").write(String(MyName))
   file("DAT\ART\" & FileNme).writevalue(TheImage)
   sendMovieMessage(movie, user.name, "OKPaint", "x")
   set nItem = "Painting#" & FileNme
   set ItemNum = 1
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   exit

--"--------------------------------
-- // Save The Big Map
----------------------------------

   "SaveTheBigMap":
   set MyName = user.name
   set TheImage = fullmsg.content
   file("DAT\WORLD MAP\WMAP").writevalue(TheImage)
   sendMovieMessage(movie, user.name, "TheBigMapWasSaved", "x")

   exit

----------------------------------
-- // Grab The Big Map
----------------------------------

   "GrabTheBigMap":
   set TheBigMap = file("DAT\WORLD MAP\WMAP").readvalue()
   sendMovieMessage(movie, user.name, "HeresTheBigMap", TheBigMap)

   exit

----------------------------------
-- // View Painting
----------------------------------

   "ViewPainting":
   set CodeNum = fullMsg.content
   set PaintingAuthor = file("DAT\ART\" & CodeNum & ".txt").read
   sendMovieMessage(movie, user.name, "PaintingAuthor", PaintingAuthor)
   set ThePainting = file("DAT\ART\" & CodeNum).readvalue()
   sendMovieMessage(movie, user.name, "ViewPainting", ThePainting)
   exit

----------------------------------
-- // Save Photo
----------------------------------

   "SavePhoto":
   set MyName = user.name
   set FileNme = random(10000000)
   set TheImage = fullmsg.content
   file("DAT\ART\" & string(FileNme) & ".txt").write(String(MyName))
   file("DAT\ART\" & FileNme).writevalue(TheImage)
   sendMovieMessage(movie, user.name, "OKPaint", "x")
   set nItem = "Photo#" & FileNme
   set ItemNum = 1
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   exit

--"--------------------------------
-- // Equipment Information
----------------------------------

   "EqNfo":
   set FileDT = fullMsg.content
   set the itemdelimiter = ":"
   set ItemToEquip = item 1 of FileDT
   set ItemIndex = integer(item 2 of FileDT)
   set EquipType = item 3 of FileDT

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set MyEquipped = item 3 of MyItemsFile
   set the itemdelimiter = ":"

   if item ItemIndex of MyEquipment contains ItemToEquip & "-" then
      if EquipType = "Head" then set EquipSlot = 1
      if EquipType = "Body" then set EquipSlot = 2
      if EquipType = "LeftHand" then set EquipSlot = 3
      if EquipType = "RightHand" then set EquipSlot = 4
      if EquipType = "Feet" then set EquipSlot = 5
      if EquipType = "Ring" then set EquipSlot = 6
      if EquipType = "Neck" then set EquipSlot = 7
      if EquipType = "Belt" then set EquipSlot = 8

      if EquipSlot < 1 then exit
      set ItemToSwitch = item EquipSlot of MyEquipped
      put ItemToEquip into item EquipSlot of MyEquipped

      if ItemToSwitch <> "NOTHING" then
         put ItemToSwitch into item ItemIndex of MyEquipment
       else
         put "" into item ItemIndex of MyEquipment
      end if

      set the itemdelimiter = "|"
      put MyEquipped into item 3 of MyItemsFile

      if ItemToSwitch <> "NOTHING" then
        set RemItem = ItemToSwitch
        set AddItem = ItemToEquip
        setItemNum = 1
        set dattt = "You have to remove the current item you're wearing to equip this!"
        sendMovieMessage(movie, user.name, "sqa", dattt)
        exit
      end if

      set nItem = ItemToEquip
      set ItemNum = 1
      InvDel(MyName, MyItemsFile, nItem, ItemNum, User, fullmsg, group, movie)
   end if

   exit

--"--------------------------------
-- // Key Usage
----------------------------------

   "KeyUsage":
   set FileDT = fullMsg.content

   set the itemdelimiter = ":"
   set ItemName = item 1 of FileDT
   set InvenNum = integer(item 2 of FileDT)
   set KeyFile = file("DAT\SETTINGS\Keys.txt").read
   if KeyFile contains ItemName & ":Inf" then exit

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set the itemdelimiter = ":"

   set MyItemToDrop = item InvenNum of MyEquipment

   if MyItemToDrop contains ItemName & "-" then
     set nItem = ItemName
     set ItemNum = 1
     InvDel(MyName, MyItemsFile, nItem, ItemNum, User, fullmsg, group, movie)
   end if

   exit

--"--------------------------------
-- // Remove Item Inventory
----------------------------------

   "RemItmInv":
   set FileDT = fullMsg.content

   set the itemdelimiter = ":"
   set ItemName = item 1 of FileDT
   set InvenNum = integer(item 2 of FileDT)

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set the itemdelimiter = ":"

   set MyItemToDrop = item InvenNum of MyEquipment

   if MyItemToDrop contains ItemName & "-" then
     set nItem = ItemName
     set ItemNum = 1
     InvDel(MyName, MyItemsFile, nItem, ItemNum, User, fullmsg, group, movie)
   end if

   exit

--"--------------------------------
-- // Drop Crystals
----------------------------------

   "DropCrystals":
   set FileDT = fullMsg.content

   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set NewItem = item 2 of FileDT
   set ItDt = item 2 of FileDT
   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"

   repeat with n = 1 to 20
   	if item n of ItemList = "" then
   		set OneToPlace = n
   		exit repeat
   	end if
   end repeat

   set the itemdelimiter = ":"
   set TheGoods = item 1 of ItDt & ":" & item 2 of ItDt
   set the ItemDelimiter = "|"
   put TheGoods into item OnetoPlace of ItemList

   if ItemList contains "|" then

   else
   	exit
   end if

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set the itemdelimiter = ":"
   set CurItemDrop = item 1 of NewItem
   set the itemdelimiter = " "
   set CurItemDropx = item 2 of CurItemDrop & " " & item 3 of CurItemDrop
   set nItem = CurItemDropx
   set ItemNum = integer(item 1 of CurItemDrop)

   set the itemdelimiter = ":"
   set InvenNum = integer(item 3 of FileDT)
   set MyItemToDrop = item InvenNum of MyEquipment

   if MyItemToDrop contains nItem & "-" then
     set the itemdelimiter = "-"
     set CurrentAmount = integer(item 2 of MyItemToDrop)
     if CurrentAmount < ItemNum then
       set TextNfo = "You don't have enough to drop this amount!"
       sendMovieMessage(movie, user.name, "sqa", TextNfo)
       exit
     end if
     file("DAT\ITEMS\" & FilName).write(ItemList)
     InvDel(MyName, MyItemsFile, nItem, ItemNum, User, fullmsg, group, movie)
   end if

   exit

--"--------------------------------
-- // Rm Cr
----------------------------------

   "RmCr":
   set FileDT = fullMsg.content
   set the itemdelimiter = ":"
   set CrName = item 1 of FileDT
   set Amount = integer(item 2 of FileDT)
   set InvenNum = item 3 of FileDT
   if InvenNum <> "x" then set InvenNum = integer(InvenNum )
   if Amount < 1 then set Amount = 1

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set the itemdelimiter = ":"

   if InvenNum = "x" then
     repeat with xx = 1 to 15
       if item xx of MyEquipment contains CrName & "-" then set InvenNum = xx
      end repeat
   end if

   set MyLine = item InvenNum of MyEquipment

   if MyLine contains CrName & "-" then
     set the itemdelimiter = "-"
     set CurrentAmount = integer(item 2 of MyLine)

     if CurrentAmount < Amount then
       exit
     end if

    set nItem = CrName
    set ItemNum = Amount
    InvDel(MyName, MyItemsFile, nItem, ItemNum, User, fullmsg, group, movie)
   end if

   exit

--"--------------------------------
-- // Add to Queue
----------------------------------

   "AddToQueue":
    Global MovementQueue
    set DtToAdd = fullMsg.content
    set the itemdelimiter = ":"
    set WhichMap = item 1 of DtToAdd
    set the itemdelimiter = "`"

    repeat with x = 1 to 7
     if item x of MovementQueue contains WhichMap & ":" then
      set theLine = item x of MovementQueue & DtToAdd & "/"
      put theLine into item x of MovementQueue
      exit
     end if
    end repeat

    if MovementQueue = "" then
      set MovementQueue = DtToAdd & "/"
      exit
    end if

    set MovementQueue = MovementQueue & "`" & DtToAdd & "/"

   exit

----------------------------------
-- // Drop An ItemX
----------------------------------
-- Differs from DropAnItem cos DropAnItemX deletes from inventory

   "DropAnItemX":
   set FileDT = fullMsg.content

   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set NewItem = item 2 of FileDT

   set ItDt = item 2 of FileDT
   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"

	repeat with n = 1 to 20
		if item n of ItemList = "" then
			set OneToPlace = n
			exit repeat
		end if
	end repeat

   set the itemdelimiter = ":"

   if item 1 of ItDt = "Newspaper Kit" then
     put string(user.name) & "'s Newspaper" into item 1 of ItDt
   end if

   set TheGoods = item 1 of ItDt & ":" & item 2 of ItDt
   set the ItemDelimiter = "|"
   put TheGoods into item OnetoPlace of ItemList

   if ItemList contains "|" then
   else
    	exit
   end if

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyEquipment = item 2 of MyItemsFile
   set the itemdelimiter = ":"
   set CurItemDrop = item 1 of NewItem
   set InvenNum = integer(item 3 of FileDT)
   set MyItemToDrop = item InvenNum of MyEquipment

   if MyItemToDrop contains CurItemDrop & "-" then
     file("DAT\ITEMS\" & FilName).write(ItemList)
     set nItem = CurItemDrop
     set ItemNum = 1
     InvDel(MyName, MyItemsFile, nItem, ItemNum, User, fullmsg, group, movie)
   end if

   exit

--"--------------------------------
-- // Drop Some Gold
----------------------------------

   "DropSomeGold":
   set FileDT = fullMsg.content

   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set NewItem = item 2 of FileDT
   set ItDt = item 2 of FileDT
   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"

	repeat with n = 1 to 20
		if item n of ItemList = "" then
			set OneToPlace = n
			exit repeat
		end if
	end repeat

   set the itemdelimiter = ":"
   set stuffin = item 1 of ItDt & ":" & item 2 of ItDt
   set the ItemDelimiter = "|"
   put stuffin into item OnetoPlace of ItemList

   if ItemList contains "|" then
    else
    exit
   end if

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)
   set the itemdelimiter = ":"
   set CurItemDrop = item 1 of NewItem
   set the itemdelimiter = " "
   set GoldAmount = integer(item 1 of CuritemDrop)

   if MyGold >= GoldAmount then
     set MyGold = MyGold - GoldAmount
     put "" into item InvenNum of MyEquipment
     set the itemdelimiter = "|"
     put MyGold into item 1 of MyItemsFile
     file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
     file("DAT\ITEMS\" & FilName).write(ItemList)
     sendMovieMessage(movie, user.name, "inx", MyItemsFile)
   end if

   exit

----------------------------------
-- // Miscellaneous Cases Part A
----------------------------------

 "AddMeToCheaters":
    AddMeToCheaters(me, movie, group, user, fullmsg)

   exit

 "SecureTradeInProgress":
    SecureTradeInProgress(me, movie, group, user, fullmsg)

   exit

 "b94013":
    DisxItm(me, movie, group, user, fullmsg)

   exit

 "x91":
    RunAdd(me, movie, group, user, fullmsg)

   exit

 "bookrd":
    ReadBook(me, movie, group, user, fullmsg)

   exit

 "bjchk":
    BlackJackGoldCheck(me, movie, group, user, fullmsg)

   exit

 "snx38":
    snx38(me, movie, group, user, fullmsg)

   exit

-- //"GiveToPlayer":
--    GiveToPlayer(me, movie, group, user, fullmsg)
--
--   exit

-- //"GiveGoldToPlayer":
--    GiveGoldToPlayer(me, movie, group, user, fullmsg)
--
--   exit

 "QuestGive":
    QuestGive(me, movie, group, user, fullmsg)

   exit

 "RefNPC":
    RefNPC(me, movie, group, user, fullmsg)

   exit

"GetSomeFaction":
    sendMovieMessage(movie, user.name, "factnrtrn",  FactionPowers)

   exit

"GetHelp":
    GetHelp(me, movie, group, user, fullmsg)

   exit

----------------------------------
-- // Door Switch
----------------------------------

"DoorSwitch":
  set FileDT = fullMsg.content
  set the itemdelimiter = "|"
  set MapName = item 1 of FileDT
  set OldDoor = item 2 of FileDT
  set NewDoor = item 3 of FileDT

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

   exit

----------------------------------
-- // Miscellaneous Cases Part B
----------------------------------
"returnVehicleWarp":
	unboardVehicle(movie, user)
	exit

"DeathTxt":

	if globalmute then
		sendMovieMessage(movie, user.name, "DeathTxt",  fullmsg.content)
	else
		sendMovieMessage(movie, "@Allusers", "DeathTxt",  fullmsg.content)
	end if
	exit

"DeathMapGo":
    DeathMapGo(me, movie, group, user, fullmsg)

   exit

"SaveHouse":
    SaveHouse(me, movie, group, user, fullmsg)

   exit

"SpCmd":
    ShopCommand(me, movie, group, user, fullmsg)

   exit

"MpTlCng":
    MapTileChange(me, movie, group, user, fullmsg)

   exit

"MpT2Cng":
    BuildLand(me, movie, group, user, fullmsg)

   exit

"MpT3Cng":
    BuyLand(me, movie, group, user, fullmsg)

   exit

-- //"SayTreasure":
--    SayTreasure(me, movie, group, user, fullmsg)
--
--   exit

"SayFaction":
    SayFaction(me, movie, group, user, fullmsg)
   exit

"PrtlExt":
    Portal(me, movie, group, user, fullmsg)

   exit

-- //"SayQuest":
--    SayQuest(me, movie, group, user, fullmsg)
--
--   exit

"treack":
    TreasureCheck(me, movie, group, user, fullmsg)

   exit

"BlkJckExch":
    BlackJackGameOver(me, movie, group, user, fullmsg)

   exit

"STARTASSGAME":
    STARTASSGAME(me, movie, group, user, fullmsg)

   exit

"StartLightningAssGame":
    StartLightningAssGame(me, movie, group, user, fullmsg)

   exit

"ENDASSGAME":
    ENDASSGAME(me, movie, group, user, fullmsg)

   exit

"ASSGAMEADDSCORE":
    AssGameAddScore(me, movie, group, user, fullmsg)

   exit

"ShowAssScores":
   set FilName = "DAT\SETTINGS\permassassinsscore.txt"
   set HighScoreList = file(FilName).read
   sendMovieMessage(movie, user.name, "assscrlstx", HighScoreList)

   set FilName = "DAT\SETTINGS\assassinsscore.txt"
   set HighScoreList = file(FilName).read
   sendMovieMessage(movie, user.name, "assscrlst", HighScoreList)

   exit

"Sccr":

   if checkAdminAccess(user.name, 8) = FALSE then
   	set scre = integer(fullmsg.content)
      set MyName = user.name
   	CheckHighScore(MyName, scre)
   end if

   exit

"ShowScores":
   set FilName = "DAT\SETTINGS\highscore.txt"
   set HighScoreList = file(FilName).read
   sendMovieMessage(movie, user.name, "scrlst", HighScoreList)

   exit

"sltwn":
	SlotDone(me, movie, group, user, fullMsg)

   exit

----------------------------------
-- // Slot Machine
----------------------------------

"SltMcn":
   set TheCost = integer(fullmsg.content)

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)
   set the itemdelimiter = ":"

   if MyGold >= TheCost then

     sendMovieMessage(movie, user.name, "goslt", TheCost)
   else
     sendMovieMessage(movie, user.name, "noslt", "x")
   end if

   exit

--"--------------------------------
-- // Drop An Item
----------------------------------

   "DropAnItem":

   set FileDT = fullMsg.content
   if FileDT contains " battleship" then set ItsAGo = 1
   if FileDT contains " boat" then set ItsAGo = 1
   if FileDT contains " Airship" then set ItsAGo = 1

   if FileDT contains "Crystal" then set ItsAGo = 1
   if FileDT contains "logs" then set ItsAGo = 1
   if FileDT contains "exit" then set ItsAGo = 1
   if FileDT contains "mailbox" then set ItsAGo = 1
   if FileDT contains "trout" then set ItsAGo = 1
   if FileDT contains "catfish" then set ItsAGo = 1
   if FileDT contains "squid" then set ItsAGo = 1
   if FileDT contains "swordfish" then set ItsAGo = 1
   if FileDT contains "Crab" then set ItsAGo = 1
   if FileDT contains "fish" then set ItsAGo = 1
   if FileDT contains "Head" then set ItsAGo = 1
   if FileDT contains "Street" then set ItsAGo = 1
   if FileDT contains "Corn" then set ItsAGo = 1
   if FileDT contains "Nectar" then set ItsAGo = 1
   if FileDT contains "Watermelon" then set ItsAGo = 1
   if FileDT contains "Flowers" then set ItsAGo = 1
   if FileDT contains "Roses" then set ItsAGo = 1
   if FileDT contains "Chunk" then set ItsAGo = 1

   if ItsAGo <> 1 then exit

   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   --set NewItem = item 2 of FileDT
   set ItDt = item 2 of FileDT
   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"

	repeat with n = 1 to 20
	   if item n of ItemList = "" then
			set OneToPlace = n
			exit repeat
		end if
	end repeat

   set the itemdelimiter = ":"
   set dItem = item 1 of ItDt
   set dXY = item 2 of ItDt
   if (dItem contains " battleship") or (dItem contains " boat") or (dItem contains " Airship") then
		dItem = returnVehicles(user, dItem)
		set the itemdelimiter = "-"
		sendMovieMessage(movie, user.name, "RefreshVehicleDrop", "!(( " & dItem & ":" & item 1 of dXY & ":" & item 2 of dXY)
	end if

   set stuffin = dItem & ":" & dXY
   set the ItemDelimiter = "|"
   put stuffin into item OnetoPlace of ItemList

   if (ItemList contains "|") = FALSE then exit

   file("DAT\ITEMS\" & FilName).write(ItemList)

   exit

----------------------------------
-- // Grab Items
----------------------------------

   "GrabItems":
     GrabItems(me, movie, group, user, fullmsg)

   exit

----------------------------------
-- // Load & Send Mail
----------------------------------

   "LoadMail":
   if (fullmsg.content contains "../" or fullmsg.content contains "..\") then exit
   set FilName = "DAT\MAIL\" & fullmsg.content
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "MailList", MyFile)

   "SendMail":
   set FileDT = fullMsg.content
   if (FileDT contains "../" or FileDT contains "..\") then exit
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set MyMessage = item 2 of FileDT
   set CurMail = "DAT\MAIL\" & FilName
   set CurMail = file(CurMail).read
   set CurMail = CurMail & MyMessage
   file("DAT\MAIL\" & FilName).write(CurMail)

   exit

--"--------------------------------
-- // Save Mail
----------------------------------

   "SaveMail":
   set FileDT = fullMsg.content
   if (FileDT contains "../" or FileDT contains "..\") then exit
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set FilDat = item 2 of FileDT
   file("DAT\MAIL\" & FilName).write(FilDat)

   exit

----------------------------------
-- // Check IP Ban
----------------------------------

   "SortIP":
   MyIPP = fullmsg.content
   set FilName = "DAT\SETTINGS\bans.txt"
   set MyFile = file(FilName).read
   if MyFile contains MyIPP then sendMovieMessage(movie, user.name, "455934785938712364852348", "x")

   exit

----------------------------------
-- // Load Stuff (Items, Board, Map, Monsters)
----------------------------------

   "LoadItems":
   set FilName = "DAT\ITEMS\"
   FilName = FilName & fullmsg.content
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "GetItems", MyFile)

   "LoadItemsW":
   set FilName = "DAT\ITEMS\"
   FilName = FilName & fullmsg.content
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "GetItemsW", MyFile)

   "LoadItemsX":
   set FilName = "DAT\ITEMS\"
   FilName = FilName & fullmsg.content
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "GetItemsX", MyFile)

   exit

--"--------------------------------
-- // Load & Save Board
----------------------------------

   "LoadBoard1":
   set FilName = "DAT\BOARDS\"
   FilName = FilName & fullmsg.content
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "GetBoards", MyFile)

   "SaveBoard1":
   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set FilDat = item 2 of FileDT
   file("DAT\BOARDS\" & FilName).write(FilDat)


-- // Load & Save Board2 are pretty redundant, as they are not applied in Inoca's Client Version

--   "LoadBoard2":
--   set FilName = "DAT\BOARDS\"
--   FilName = FilName & fullmsg.content
--   set MyFile = file(FilName).read
--   sendMovieMessage(movie, user.name, "GetBoards", MyFile)

--   "SaveBoard2":
--   set FileDT = fullMsg.content
--   set the itemdelimiter = "`"
--   set FilName = item 1 of FileDT
--   delete item 1 of FileDT
--   if char 1 of FileDT = "`" then delete char 1 of FileDT
--   file("DAT\BOARDS\" & FilName).write(FileDT)

   exit

----------------------------------
-- // Load & Save Map
----------------------------------

   "LoadMap":
   set TheName = fullmsg.content

   set FilName = "DAT\MAPS\" & TheName
   set MyFile = file(FilName).read

   set FilxName = "DAT\MOBS\" & TheName
   set MyxFile = file(FilxName).read

   set the itemdelimiter = "."
   set FilName = "DAT\ITEMS\" & item 1 of TheName & "i.txt"
   set ItemFile = file(FilName).read

   set TheFiles = MyFile & "^" & ItemFile & "^" & MyxFile & "^"
   SendNPCs (MyxFile, me, movie, group, user, fullMsg, TheFiles)
   set the itemdelimiter = "."
   ReleasePassword (user, movie, item 1 of TheName)

   "LoadMapX":
   set FilName = "DAT\MAPS\"
   FilName = FilName & fullmsg.content
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "GetMapX", MyFile)


	"SM8910291X": -- Save Map for house building
	set FileDT = fullMsg.content
	set the itemdelimiter = "`"
	set FilName = item 1 of FileDT
	set FilDat = item 2 of FileDT
	file("DAT\MAPS\" & FilName).write(FilDat)
	sendMovieMessage(movie, user.name, "MapIsCreated", "x")

	--"

   "SaveMap":
   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set FilDat = item 2 of FileDT
	------------------------------
	-- Trigger LimitedSafeCheck()
	------------------------------

	if checkAdminAccess(user.name, 4) then

		set isPresent = string(file("DAT\MAPS\" & FilName).read)
		if isPresent = "" or isPresent = void then
			auditLog(filName & " was created by " & user.name, "newmap")
			IncreaseTotalMaps()
		end if

		set Check = LimitedSafeCheck( user , FilName )
		if Check = "ok" then
			file("DAT\MAPS\" & FilName).write(FilDat)
			file("DAT\MapsToUpdate\" & FilName).write(FilDat)
			sendMovieMessage(movie, user.name, "MapIsCreated", "x")
		end if
	end if

--"--------------------------------
-- // Load & Save Monster
----------------------------------

	"LoadMobsX":
	set FilName = "DAT\MOBS\"
	FilName = FilName & fullmsg.content
	set MyFile = file(FilName).read
	sendMovieMessage(movie, user.name, "GetMobsX", MyFile)

   "SveMb":
   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set FilDat = item 2 of FileDT

   set the itemdelimiter = "."
   set MapName = item 1 of FilName

   ------------------------------
   -- Trigger CheckSaveMobs()
   ------------------------------
   set ReturnMSG = CheckSaveMobs(user, MapName, FilDat, movie)
   if ReturnMSG = "Hacked" then exit
   ------------------------------
   -- Trigger LockedMobsCheck()
   ------------------------------
	set Check = LockedMobsCheck(user, MapName)  --locks MobMaps
	if Check = "False" then
		------------------------------
		-- Trigger LimitedSafeCheck()
		------------------------------
			set Check = LimitedSafeCheck( user , FilName )
			if Check = "ok" then
			file("DAT\MOBS\" & FilName).write(FilDat)
			end if
		------------------------------
	end if
   ------------------------------
   exit

----------------------------------
-- // Drop in vault
----------------------------------

   "DropInVault":
   set FileDT = fullMsg.content
   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyInv = String(item 2 of MyItemsFile)

   set the itemdelimiter = "`"
   set VaultName = item 1 of FileDT
   set ItemToAdd = item 2 of FileDT
   set InvenNum = integer(item 3 of FileDT)
   set the itemdelimiter = ":"

   set VaultIsFull = FALSE

   set FilName = "DAT\VAULTS\" & VaultName
   set VaultInfo = file(FilName).read
   if VaultInfo = VOID then set VaultInfo = ""

   set MaxAmnt = 15
   if VaultName contains "Crate" then set MaxAmnt = 3
   if VaultName contains "Vault" then set MaxAmnt = 15
   if VaultName contains "Chest" then set MaxAmnt = 15
   if VaultName contains "Cabinet" then set MaxAmnt = 10
   if VaultName contains "Wind Cabinet" then set MaxAmnt = 20

   if line MaxAmnt of VaultInfo <> "" then set VaultIsFull = TRUE

   if VaultIsFull = TRUE then
      sendMovieMessage(movie, user.name, "sqa", "This is too full to store anything else!")
      exit
   end if

   if item InvenNum of MyInv contains ItemToAdd & "-" then
      set ItsAGo = 1
   end if

   if ItsAGo <> 1 then exit

   set nItem = ItemToAdd
   set ItemNum = 1
   InvDel(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   set VaultInfo = VaultInfo & ItemToAdd & RETURN
   if VaultInfo contains "|" then exit
   file("DAT\VAULTS\" & VaultName).write(VaultInfo)

   if VaultName contains "Cauldron" then
     DidWeBooyaSomeWitchcraft(MyName, user, fullmsg, group, movie, VaultName, VaultInfo)
   end if

   exit

--"--------------------------------
-- // Get item info from vault
----------------------------------

   "GetChest":
   set FiletoGet = fullMsg.content

	set the itemdelimiter = "."
	set TheVault = item 1 of fullMsg.content

	if TheVault contains "#" then
		-- continue
	else
		if (TheVault = user.name) or (TheVault = user.name & "'s house vault") then
			-- continue
		else if (TheVault contains "'s guild vault") then
			-- continue
		else
			auditlog(user.name & " tried to hack " & fullmsg.content, "vaultHack")
			exit
		end if
	end if

   set FilName = "DAT\VAULTS\" & FiletoGet
   set VaultInfo = file(FilName).read

   sendMovieMessage(movie, user.name, "VaultReturned", VaultInfo)

   exit

--"--------------------------------
-- // Get balance from bank
----------------------------------

   "GetBalance":
	set balOwner = fullMsg.content

	if balOwner <> user.name then
		auditlog(user.name & " tried to view " & balOwner, "bankHack")
		exit
   end if

   set FilName = "DAT\BANK\" & string(balOwner) & ".txt"
   set Bankk = string(file(FilName).read)

   if Bankk = "" then
   	set Bankk = "0"
   	file(FilName).write(Bankk)
   end if

   sendMovieMessage(movie, user.name, "BalanceReturned", Bankk)

   exit

--"--------------------------------
-- // Deposit into bank
----------------------------------

   "Deposit":
	set the itemdelimiter = ":"

	set fContent = fullMsg.content
	set balOwner = item 1 of fContent
	set amtDeposit = integer(item 2 of fContent)

	if balOwner <> user.name then
		auditlog(user.name & " tried to deposit for " & balOwner, "bankHack")
		exit
   end if

	if RemSaveItemX ("Gold", amtDeposit, user.name, movie) then
		set FilName = "DAT\BANK\" & string(balOwner) & ".txt"
   	set Bankk = string(file(FilName).read)
   	set nBankk = integer(Bankk) + amtDeposit
	   file(FilName).write(String(nBankk))
		sendMovieMessage(movie, user.name, "DepositDone", nBankk)
	else
		sendMovieMessage(movie, user.name, "sqa", "Sorry, you do not seem to have that much to deposit.")
	end if

   exit

----------------------------------
-- // Withdraw from bank
----------------------------------

   "Withdraw":
	set the itemdelimiter = ":"
	set fContent = fullMsg.content
	set balOwner = item 1 of fContent
	set amtWithdraw = integer(item 2 of fContent)

	if balOwner <> user.name then
		auditlog(user.name & " tried to withdraw for " & balOwner, "bankHack")
		exit
   end if

	set FilName = "DAT\BANK\" & string(balOwner) & ".txt"
	set Bankk = string(file(FilName).read)
	set nBankk = integer(Bankk) - amtWithdraw

	if nBankk < 0 then
		sendMovieMessage(movie, user.name, "sqa", "Sorry, you do not seem to have that much to withdraw.")
		exit
	end if

	if AddSaveItemX ("Gold", amtWithdraw, user.name, movie) then
		file(FilName).write(String(nBankk))
   	sendMovieMessage(movie, user.name, "DepositDone", nBankk)
	else
		sendMovieMessage(movie, user.name, "sqa", "Sorry, there seems to be a problem with your withdrawl. Contact an admin for help.")
	end if

   exit

----------------------------------
-- // Add NextFood, NextPotion, NextBuild
----------------------------------

   "itremovv":

      set ItemToAdd = fullMsg.content
      --set CanIGoOK = FALSE

   	if (itemToAdd = "Crate#") or (itemToAdd = "Cabinet#") or (itemToAdd = "Wind Cabinet#") then
   		set ItemToAdd = getCabbyCounter(ItemToAdd)
   	end if

      --if ItemToAdd contains "Crate#" then set CanIGoOK = TRUE
      --if ItemToAdd contains "Wind Cabinet#" then set CanIGoOK = TRUE
      --if ItemToAdd contains "Cabinet#" then set CanIGoOK = TRUE
      --if ItemToAdd contains "Potion" then set CanIGoOK = TRUE
      --if ItemToAdd = "Apple" then set CanIGoOK = TRUE
      --if ItemToAdd = "Pie" then set CanIGoOK = TRUE
      --if ItemToAdd = "Corn" then set CanIGoOK = TRUE
      --if ItemToAdd = "Fish" then set CanIGoOK = TRUE
      --if ItemToAdd = "Ale" then set CanIGoOK = TRUE
      --if ItemToAdd = "Pig" then set CanIGoOK = TRUE
      --if ItemToAdd = "Chair" then set CanIGoOK = TRUE
      --if ItemToAdd = "Table" then set CanIGoOK = TRUE
      --if ItemToAdd = "Stool" then set CanIGoOK = TRUE

      --if CanIGoOK = FALSE then exit

      set FileDT = fullMsg.content
      set MyName = user.name
      set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read 			--"

      set the itemdelimiter = "|"
      set MyInv = String(item 2 of MyItemsFile)

      if ItemToAdd contains " Crystals" then
       set the itemdelimiter = " "
       set ItemNum = integer(item 1 of ItemToAdd)
       set ItemToAdd = item 2 of ItemToAdd & " " & item 3 of ItemToAdd
      end if

      set the itemdelimiter = ":"

      repeat with xxx = 1 to 15
       if item xxx of MyInv = "" then set ItsAGo = 1
       end repeat

      if MyInv contains ItemToAdd & "-" then set ItsAGo = 1

      if ItsAGo = 0 then exit
      set ItemNum = 1

     set nItem = ItemToAdd
     InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   exit

----------------------------------
-- // Get from vaults
----------------------------------

   "GetFromVault":
   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set VaultName = item 1 of FileDT
   set ItemToAdd = item 2 of FileDT
   set NumToAdd = 1

   set the itemdelimiter = "."
   set VaultName = item 1 of VaultName
   set VaultInfo = file("DAT\VAULTS\" & VaultName & ".txt").read

  set the itemdelimiter = RETURN
  set NewVault = ""

  repeat with x = 1 to 200
    if item x of VaultInfo <> "" then set NewVault = NewVault & item x of VaultInfo & RETURN
  end repeat

   repeat with x = 1 to 200
    if line x of NewVault = ItemToAdd then
      ----------------------
      set MyName = user.name
      set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
      set the itemdelimiter = "|"
      set MyInv = String(item 2 of MyItemsFile)

		if VaultName contains "#" then
			if myItemsFile contains VaultName then
				-- continue
			else
				exit
			end if
		end if

      if ItemToAdd contains " Crystals" then
       set the itemdelimiter = " "
       set NumToAdd = integer(item 1 of ItemName)
       set ItemToAdd = item 2 of ItemToAdd & " " & item 3 of ItemToAdd
      end if

      --set the itemdelimiter = ":"

      --repeat with xxx = 1 to 15
      -- if item xxx of MyInv = "" then set ItsAGo = 1
      --end repeat

      --if MyInv contains ItemToAdd & "-" then set ItsAGo = 1

      --if ItsAGo = 0 then exit
      --set ItemNum = 1

      --set nItem = ItemToAdd
      --InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

		AddSaveItemX (ItemToAdd, NumToAdd, MyName, movie)
      delete line x of NewVault

      if VaultName contains "'s guild vault" then
			set the itemdelimiter = "'"
			gLog(item 1 of VaultName, MyName & " removed " & ItemToAdd)
      end if
      exit repeat
    end if
   end repeat

   if NewVault contains "|" then exit
   file("DAT\VAULTS\" & VaultName & ".txt").write(NewVault)

   exit

--"--------------------------------
-- // Load News
----------------------------------

--   "LoadNews":
--   set MyFile = getWelcomeText()
--   sendMovieMessage(movie, user.name, "News", MyFile)
--   exit

----------------------------------
-- // Load & Complete Quests
----------------------------------
   "LoadQuests":
   set FilName = "DAT\SETTINGS\CurQuest.txt"
   set MyFile = file(FilName).read
   sendMovieMessage(movie, user.name, "Quests", MyFile)

   "QuestComplete":
   set FileDT = fullMsg.content
   file("DAT\SETTINGS\CurQuest.txt").write(FileDT)

   exit

----------------------------------
-- // View Char (DEFUNCT)
----------------------------------

   --"ViewChar":
   --set CharName = fullMsg.content
   --set FilName = "DAT\CHAR\" & CharName & ".txt"
   --set MyFile = file(FilName).read
   --sendMovieMessage(movie, user.name, "ViewChar", MyFile)

   exit

--"-------------------------------
-- // Load & Save NPC
----------------------------------

   "LoadTheNPC":
   if checkAdminAccess(user.name, 1) then
   	set CharName = fullMsg.content
   	set FilName = "DAT\NPC\" & CharName & ".txt"
   	set MyFile = file(FilName).read
   	sendMovieMessage(movie, user.name, "NPCLoaded", MyFile)
   else
      sendMovieMessage(movie, user.name, "kick", "x")
   end if

   "SaveTheNPC":

   if checkAdminAccess(user.name, 1) then
     set FileDT = fullMsg.content
     set the itemdelimiter = "`"
     set FilName = item 1 of FileDT
     set FilDat = item 2 of FileDT
     file("DAT\NPC\" & FilName).write(FilDat)
     sendMovieMessage(movie, user.name, "NPCIsCreated", "x")
   else
     sendMovieMessage(movie, user.name, "kick", "x")
   end if

   exit

---------------------------------
-- // Load System
----------------------------------

   "LoadSystem":
	if checkAdminAccess(user.name, 1) then
		set FilName = "DAT\SETTINGS\System.txt"
		set MyFile = file(FilName).read
		sendMovieMessage(movie, user.name, "LoadSystem", MyFile)
	end if
   exit

---------------------------------
-- // Load NPC Buy & Sell List
----------------------------------

   "LoadNPCSellList":
   	set CharName = fullMsg.content
		set FilName = "DAT\NPC\" & CharName
		set LList = file(FilName).read
		set BuyItems = ""
		set BuyItemPrices = ""

		repeat with x = 1 to 30
		  if string(line x of LList) contains "SEL|" then
			set the itemdelimiter = "|"
			set TheGoods = item 2 of line x of LList
			set the itemdelimiter = ":"
			set ItemName = item 1 of TheGoods
			set ItemPrice = item 2 of TheGoods
			set BuyItems = BuyItems & ItemName & RETURN
			set BuyItemPrices = BuyItemPrices & ItemPrice & RETURN
		  end if
		end repeat
		set TheList = BuyItems & ":" & BuyItemPrices
		sendMovieMessage(movie, user.name, "NPCSellList", TheList)

  "LoadNPCBuyList":
		set CharName = fullMsg.content
		set FilName = "DAT\NPC\" & CharName
		set LList = file(FilName).read
		set BuyItems = ""
		set BuyItemPrices = ""

		repeat with x = 1 to 60
		  if string(line x of LList) contains "BUY|" then
			set the itemdelimiter = "|"
			set TheGoods = item 2 of line x of LList
			set the itemdelimiter = ":"
			set ItemName = item 1 of TheGoods
			set ItemPrice = item 2 of TheGoods
			set BuyItems = BuyItems & ItemName & RETURN
			set BuyItemPrices = BuyItemPrices & ItemPrice & RETURN
		  end if
		end repeat
		set TheList = BuyItems & ":" & BuyItemPrices
		sendMovieMessage(movie, user.name, "NPCBuyList", TheList)

   exit

---------------------------------
-- // Reduce Gold From Spell
---------------------------------
  "ReduceGoldFromSpell":
   set MyName =  user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set myCharGold = integer(item 1 of MyitemsFile)
   set MycharGold = MyCharGold - integer(fullmsg.content)
   if MyCharGold < 0 then exit
   if string(MyCharGold) contains "-" then exit
   put MycharGold into item 1 of MyItemsFile
   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

   exit

---------------------------------
-- // Give Gold To NPC
---------------------------------

  "GiveGoldToNPC":

   set MyName =  user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read

   set NPCDat = fullMsg.content
   set the itemdelimiter = ":"
   set NPCName = item 1 of NPCDat
   set NewGold = integer(item 2 of NPCDat)
   set the itemdelimiter = "."
   set FNPCxName = item 1 of NPCName
   set NPCTalkDAt = FNPCxName & " says " & QUOTE & "Thanks for the gold!"
   set the itemdelimiter = "|"
   set myCharGold = integer(item 1 of MyitemsFile)
   set MycharGold = MyCharGold - integer(NewGold)
   if MyCharGold < 0 then exit
   put MycharGold into item 1 of MyItemsFile
   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)
   sendMovieMessage(movie, user.name, "sqa",  NPCTalkDAt)

   set FilName = "DAT\NPC\" & NPCName
   set LList = file(FilName).read

   repeat with x = 1 to 60
      if line x of LList contains "GLD|" then
        set the itemdelimiter = "|"
        set MyGold = integer(item 2 of line x of LList)
        set GoldtoAdd = MyGold + NewGold
        set GoldToAdd = "GLD|" & string(GoldToAdd)
        put GoldToAdd into line x of LList
      end if
   end repeat

   file("DAT\NPC\" & NPCName).write(LList)

   exit

---------------------------------
-- // Buy and Sell from NPC
---------------------------------

   "BuyFromNPC":
     NPCBuy(me, movie, group, user, fullmsg)

   exit

   "SellToNPC":
     NPCSell(me, movie, group, user, fullmsg)

   exit

---------------------------------
-- // Buy and Sell from NPC
---------------------------------

   "Mkilldrp":

   set FileDT = fullMsg.content
   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set NPCname = item 2 of FileDT
   set ItemDat = item 3 of FileDT

   set NPCFilName = "DAT\NPC\" & NPCname
   set NPCFile = file(NPCFilName).read
   if NPCFile = VOID then exit

   set CurInvLst = ""
   set InvAmnt = 0

   set x = 1
--   repeat with x = 1 to 80
   repeat while line x of NPCFile <> ""
     if line x of NPCFile contains "INV|" then
      set the itemdelimiter = "|"
      set TheGoods = item 2 of line x of NPCFile
      set CurInvLst = CurInvLst & TheGoods & RETURN
      set InvAmnt = InvAmnt + 1
     end if
     set x = x + 1
   end repeat

   if InvAmnt = 0 then exit
   set WhichOneLine = random(InvAmnt)

   set CurItttm = line WhichOneLine of CurInvLst
   set the itemdelimiter = ":"
   set RndAmnt = integer(item 2 of CurItttm)
   set DoWeDrop = random(RndAmnt)
   if DoWeDrop <> 1 then exit
   set TheItemm = item 1 of CurItttm

   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"
   set OneToPlace = 0
   if item 8 of ItemList = "" then set OneToPlace = 8
   if item 7 of ItemList = "" then set OneToPlace = 7
   if item 6 of ItemList = "" then set OneToPlace = 6
   if item 5 of ItemList = "" then set OneToPlace = 5
   if item 4 of ItemList = "" then set OneToPlace = 4
   if item 3 of ItemList = "" then set OneToPlace = 3
   if item 2 of ItemList = "" then set OneToPlace = 2
   if item 1 of ItemList = "" then set OneToPlace = 1
   if OneToPlace = 0 then exit
   set the itemdelimiter = ":"
   set TheItemDrp = TheItemm & ":" & ItemDat
   set the ItemDelimiter = "|"
   put TheItemDrp into item OnetoPlace of ItemList

   if ItemList contains "|" then
    else
    exit
   end if

   file("DAT\ITEMS\" & FilName).write(ItemList)

   sendMovieMessage(movie, user.name, "drelxu", TheItemDrp)

   exit

--"
---------------------------------
-- // Barber Shop
---------------------------------

   "barberHair":
		changeHair(movie, user, string(fullmsg.content))
		exit
end case

end
