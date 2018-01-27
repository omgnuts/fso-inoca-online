--------------------------------------------------------
-- // Word Check for Broadcast Filter
--------------------------------------------------------
Global MuteCounter

On BadWord(movie, user, TheMessage)

	set WordFil = file("DAT/Filter/BadWords.txt").read
	set the itemdelimiter = ":"
	set WordCnt = integer(item 1 of WordFil) + 1
	set Count = 0

	repeat with Count = 2 to WordCnt

		if string(TheMessage) contains string(item Count of WordFil) then

			set WarnFil = file("DAT/Filter/Users/" & string(user.name) & ".txt").read
			NeWWarns = integer(WarnFil) + 1

			sendMovieMessage(movie, user.name, "sqa", "You were warned for saying " & QUOTE & string(item Count of WordFil) & QUOTE & ". Your current warning level is " & NewWarns & "/5, please refrain from swearing!")

			if NewWarns >= 5 then
				file("DAT/Filter/Users/" & string(user.name) & ".txt").write("0")
				sendMovieMessage(movie, user.name, "sqa", "You were warned 5 times, you are now muted!")
				--------------------------
				-- "Mute Him"
				--------------------------

				set UserName = string(user.name)

				set ListFile = file("DAT\settings\MutePlayerList.txt").read
				if ListFile contains ":" & UserName & "-" then exit

				AddToList(UserName & "-" & MuteCounter, "settings\MutePlayerList.txt")
				sendMovieMessage(movie, "@AllUsers", "broadcast|4", username &" has been muted by the server")

				return TRUE
			end if

			exit repeat

		end if
	end repeat

	return FALSE
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

--"------------------------------------------------------
-- // Get IP Address
--------------------------------------------------------

on GetIP(UserName, movie)
	set UserIP = movie.sendmessage("system.user.getAddress", "LookingUpIp", UserName)
	return string(UserIP.content.IPAddress)
end


--------------------------------------------------------
-- // Check for Blocked IP Address
--------------------------------------------------------
-- This methode checks if an ip or an iprange is banned
--------------------------------------------------------
-- Returns:
--		*	if not banned:	"Allow"
--		*	if banned:		"Block"
--		*	if ip wrong:	"Error"
--------------------------------------------------------

on CheckForBlockedIP(UserName, movie)
	set UserIP = GetIP(UserName, movie)
	set the itemdelimiter = "."

	set UserIPRange4 = UserIP
	set UserIPRange3 = item 1 of string(UserIP) & "." & item 2 of string(UserIP) & "." & item 3 of string(UserIP) & ".*"
	set UserIPRange2 = item 1 of string(UserIP) & "." & item 2 of string(UserIP) & ".*.*"
   set UserIPRange1 = item 1 of string(UserIP) & ".*.*.*"

	set Blocklist = file("DAT\settings\BannedIPs.txt").read
	-- set the itemdelimiter = ":"

	if UserIP contains "." then
		if (Blocklist contains UserIPRange4) or (Blocklist contains UserIPRange3) or (Blocklist contains UserIPRange2) or (Blocklist contains UserIPRange1) then
			set ReturnMSG = "Block"
		else
			set ReturnMSG = "Allow"
		end if
	else
		set ReturnMSG = "Error"
	end if
	return ReturnMSG
end

--------------------------------------------------------
-- // Muted Broadcast Check()
--------------------------------------------------------
-- This methode checks if a char is allowed to broadcast
--------------------------------------------------------
-- Returns:
--		*	if voiced:		"OK"
--		*	if muted:		"Block"
--------------------------------------------------------
-- Triggers:
--		*	Trigger Mute Check
--------------------------------------------------------
on MuteBroadcastCheck(user,movie)
	set MutePlayerList = file("DAT\settings\MutePlayerList.txt").read
	if MutePlayerList contains ":" & user.name & "-" then
		sendMovieMessage(movie, user.name, "sqa", "You are muted, you can't broadcast.")
		return "Block"
	else
		return "OK"
	end if
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

on MutePlayer(user, fullmsg, movie)

    if checkAdminAccess(user.name, 8) then
		set the itemdelimiter = " "
		Set username = item 2 of fullmsg.content

		if checkAdminAccess(user.name, 7) then
			if checkAdminAccess(username, 6) then
				sendMovieMessage(movie, user.name, "sqa", "You can't mute a staff member or a fellow officer.")
				return "NO"
			end if
		else
			if checkAdminAccess(user.name, 2) = FALSE then
				if checkAdminAccess(username, 8) then
					sendMovieMessage(movie, user.name, "sqa", "You can't mute a fellow staff member.")
					return "NO"
				end if
			end if
		end if

		set CharFile = file("DAT\char\" & username & ".txt").read

		if CharFile contains ":" then
		else
			sendMovieMessage(movie, user.name, "sqa", "You mistyped the player's name.")
			return "NO"
		end if

		set ListFile = file("DAT\settings\MutePlayerList.txt").read
		if ListFile contains ":" & UserName & "-" then
			sendMovieMessage(movie, user.name, "sqa", UserName & " has already been muted.")
			return "NO"
		end if

		AddToList(UserName & "-" & MuteCounter, "settings\MutePlayerList.txt")
		sendMovieMessage(movie,  "@AllUsers", "broadcast|4", username &" has been muted by " & user.name )
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
on VoicePlayer(user, fullmsg, movie)

    if checkAdminAccess(user.name, 8) then
		set the itemdelimiter = " "
		Set username = item 2 of fullmsg.content

		if checkAdminAccess(user.name, 7) then
			if checkAdminAccess(username, 6) then
				sendMovieMessage(movie, user.name, "sqa", "You can't voice a staff member or a fellow officer.")
				return "NO"
			end if
		else
			if checkAdminAccess(user.name, 2) = FALSE then
				if checkAdminAccess(username, 8) then
					sendMovieMessage(movie, user.name, "sqa", "You can't voice a fellow staff member.")
					return "NO"
				end if
			end if
		end if

		set MutePlayerList = file("DAT\settings\MutePlayerList.txt").read
		if MutePlayerList contains ":" & username & "-" then
			RemoveFromList(username, "settings\MutePlayerList.txt", "-")
			sendMovieMessage(movie,  "@AllUsers", "broadcast|4", username &" has been voiced by " & user.name )
			return "Yes"
		else
			sendMovieMessage(movie, user.name, "sqa", UserName & " isn't muted.")
			return "NO"
		end if
	end if
	return "ERR"
end


--"------------------------------------------------------
-- // RemoveFromList() -- Generic remove item from list
--------------------------------------------------------
-- uses delimiter ":"
--------------------------------------------------------

on AddToList(ListItem, ListFile)

	set ListContent = file("DAT\" & ListFile).read

	set the itemdelimiter = ":"
	set n = 1
	repeat while (item n of ListContent <> "")
		if item n of ListContent = "@@" then
			put ListItem into item n of ListContent
			file("DAT\" & ListFile).write(ListContent)
			exit
		end if
		set n = n + 1
	end repeat

	if ListContent = "" then
		ListContent = ".:" & ListItem & ":"
	else
		ListContent = ListContent & ListItem & ":"
	end if
	file("DAT\" & ListFile).write(ListContent)

end

on RemoveFromList(ListItem, ListFile, dLm)
	set ListContent = file("DAT\" & ListFile).read
	if ListContent contains ":" & ListItem & dLm then
		set n = 1
		set the itemdelimiter = ":"

		if dlm = ":" then
			repeat while item n of listContent <> ""
				if item n of listContent = ListItem  then
					put "@@" into item n of listContent
					file("DAT\" & ListFile).write(ListContent)
					exit
				end if
				set n = n + 1
			end repeat
		end if

		if dlm = "-" then
			repeat while item n of listContent <> ""
				if item n of listContent contains ListItem & dlm then

					set currPointer = item n of listContent
					set the itemdelimiter = "-"

					if item 1 of currPointer = ListItem then
						set the itemdelimiter = ":"
						put "@@" into item n of listContent
						file("DAT\" & ListFile).write(ListContent)
						exit
					end if

					set the itemdelimter = ":"
				end if
				set n = n + 1
			end repeat
		end if

	end if
end


--------------------------------------------------------
-- CheckSaveMobs() v1.0 for FSOb37  www.terraworldonline.net
--------------------------------------------------------
-- This methode checks if the mobs are not hacked
-- by a normal user
--------------------------------------------------------
-- Needed directories:	/
--------------------------------------------------------
-- Needed methodes: /
--------------------------------------------------------
-- Returns:
--		*	if no new mobs:		"OK"
--		*	if new mobs:		"Hacked"
--------------------------------------------------------
-- Triggers:
--		*	Trigger CheckSaveMobs
--------------------------------------------------------
on CheckSaveMobs(user, MapName, FilDat, movie)

	if checkAdminAccess(user.name, 4) then
		set ReturnMSG = "OK"
	else
		set MobList = file("DAT\mobs\" & MapName & ".txt").read
		set the itemdelimiter = "+"
		set FirstPart = item 1 of string(FilDat)

		set SecondPart = item 2 of string(FilDat)
		set ReturnMSG = "OK"
		repeat with count = 1 to 4
			set the itemdelimiter = "|"
			set Mob = item count of string(FirstPart)
			set the itemdelimiter = ":"
			set Mob = item 1 of string(Mob)
			if MobList contains Mob then
			else
				set ReturnMSG = "Hacked"
			end if
		end repeat
		repeat with count = 1 to 4
			set the itemdelimiter = "|"
			set Mob = item count of string(SecondPart)
			set the itemdelimiter = ":"
			set Mob = item 1 of string(Mob)
			if MobList contains Mob then
			else
				set ReturnMSG = "Hacked"
			end if
		end repeat
	end if
	return ReturnMSG
end



on sendMovieMessage(movie, recipient, subject, content)
Global oldTime, tServer

	set msec = tServer.timestamp
	if msec <= oldTime then
	 set msec = oldTime + 1
	 set oldTime = oldTime + 1
	else
	 set oldTime = msec
	end if

	set msec = string(msec)

	if (subject <> "ViewPainting") then
		set md5HashContent = string(content) & string(subject) & "\" & msec & "\" & "oheavens"
		set md5Str = CoMD5DigestFastest(md5HashContent)
		movie.sendmessage(recipient, subject & "\" & msec & "\" & md5Str, content)
	else
		movie.sendmessage(recipient, subject, content)
	end if
end

--Message
--Digester
--MD5

--( public:
--(  <#string> CoMD5DigestFastest (<#string>)
--(
--( abstract:
--(   Fast lingo implementation of the MD5 algorithm.
--(   Implementation by Joni Huhmarniemi (21/2/2004).
--(   © 1991-2, RSA Data Security, Inc.

--( public )-- -- -- -- -- -- -- -- -- -- -- -- --//

--( Returns the hex representation of string's MD5.
--( i:<#string>
--( o: -
--( r:<#string>

on CoMD5DigestFastest(a_sInput)

  -- Convert string to list of little-endian words...

  t_iLen = length(a_sInput) * 8
  t_iCnt = (t_iLen + 64) / 512 * 16 + 16

  -- Create list, fill with zeros...

  x = []
  x.SetAt(t_iCnt, 0)

  t_fArr = [1, 256, 65536, 16777216]
  i = 0
  j = 0
  repeat while i < t_iLen
    j = j + 1
    t_iNext = i / 32 + 1
    t_iTemp = bitAnd(charToNum(char (i / 8 + 1) of a_sInput), 255) * t_fArr[j]
    x[t_iNext] = bitOr(x[t_iNext], t_iTemp)
    i = i + 8
    j = j mod 4
  end repeat

  -- Append padding...

  t_iNext = t_iLen / 32 + 1
  x[t_iNext] = bitOr(x[t_iNext], 128 * t_fArr[j + 1])
  x[(t_iLen + 64) / 512 * 16 + 15] = t_iLen

  -- Actual algorithm starts here...

  a =  1732584193
  b = -271733879
  c = -1732584194
  d =  271733878
  i =  1

  t_iWrap = the maxInteger + 1
  t_iCount = x.count + 1

  repeat while i < t_iCount

    olda = a
    oldb = b
    oldc = c
    oldd = d

    -- Round(1) --

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i] - 680876936
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 1] - 389564586
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 2] + 606105819
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 3] - 1044525330
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i + 4] - 176418897
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 5] + 1200080426
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 6] - 1473231341
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 7] - 45705983
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i + 8] + 1770035416
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 9] - 1958414417
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 10] - 42063
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 11] - 1990404162
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i + 12] + 1804603682
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 13] - 40341101
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 14] - 1502002290
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 15] + 1236535329
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    -- Round(2) --

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 1] - 165796510
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 6] - 1069501632
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 11] + 643717713
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i] - 373897302
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 5] - 701558691
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 10] + 38016083
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 15] - 660478335
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i + 4] - 405537848
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 9] + 568446438
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 14] - 1019803690
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 3] - 187363961
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i + 8] + 1163531501
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 13] - 1444681467
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 2] - 51403784
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 7] + 1735328473
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i + 12] - 1926607734
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    -- Round(3) --

    n = bitXor(bitXor(b, c), d) + a + x[i + 5] - 378558
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i + 8] - 2022574463
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 11] + 1839030562
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 14] - 35309556
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    n = bitXor(bitXor(b, c), d) + a + x[i + 1] - 1530992060
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i + 4] + 1272893353
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 7] - 155497632
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 10] - 1094730640
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    n = bitXor(bitXor(b, c), d) + a + x[i + 13] + 681279174
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i] - 358537222
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 3] - 722521979
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 6] + 76029189
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    n = bitXor(bitXor(b, c), d) + a + x[i + 9] - 640364487
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i + 12] - 421815835
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 15] + 530742520
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 2] - 995338651
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    -- Round(4) --

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i] - 198630844
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 7] + 1126891415
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 14] - 1416354905
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 5] - 57434055
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i + 12] + 1700485571
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 3] - 1894986606
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 10] - 1051523
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 1] - 2054922799
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i + 8] + 1873313359
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 15] - 30611744
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 6] - 1560198380
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 13] + 1309151649
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i + 4] - 145523070
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 11] - 1120210379
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 2] + 718787259
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 9] - 343485551
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    a = a + olda
    b = b + oldb
    c = c + oldc
    d = d + oldd
    i = i + 16

  end repeat

  -- Construct 32 byte 'little-endian' hex string...

  t_sHex = "0123456789abcdef"
  t_iArr = [a, b, c, d]
  t_sOut = EMPTY

  repeat with i in t_iArr
    if(i > 0) then
      repeat with n = 1 to 4
        j = i mod 16
        i = i / 16
        k = i mod 16
        i = i / 16
        put char (k + 1) of t_sHex after t_sOut
        put char (j + 1) of t_sHex after t_sOut
      end repeat
    else
      i = bitNot(i)
      repeat with n = 1 to 4
        j = i mod 16
        i = i / 16
        k = i mod 16
        i = i / 16
        put char (16 - k) of t_sHex after t_sOut
        put char (16 - j) of t_sHex after t_sOut
      end repeat
    end if
  end repeat

  return(t_sOut)

end

--( end )-- -- -- -- -- -- -- -- -- -- -- -- -- --//
