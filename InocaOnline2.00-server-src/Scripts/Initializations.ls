on initializeGlobalConstants()
	global INVNT_MAX_NO, MAX_ITEM_IN_VAULT

	INVNT_MAX_NO = 20		-- maximum number of inventory items
	MAX_ITEM_IN_VAULT = 25

end

on refreshGlobals()

	refreshCounters()
	refreshFilterList()
	refreshAccessList()
	refreshGames()

end refreshGlobals

on refreshCounters()
	global gMuteCounter, gOldTime
	global gGlobalMute

	gOldTime			= 0 -- for MD5 checking
	gMuteCounter 	= 0 -- clears playermutes
	gGlobalMute 	= 0 -- checks whether users can do broadcasts
end

on refreshFilterList()
	global gFoulWordList

	gFoulWordList = string(file("DAT\FILTERS\Foulwords.dam").read)
end

on refreshAccessList()
	global gListAdmins, gListOfficers, gListMappers

	gListAdmins= file("DAT\ACCESSLIST\ACCESS\Immortals.dam").read
	gListOfficers= file("DAT\ACCESSLIST\ACCESS\Officers.dam").read
	gListMappers= file("DAT\ACCESSLIST\ACCESS\Mappers.dam").read
end

on refreshGames()

	exit

	Global gLotteryON, CTF

	set GSFilName = "DAT\GAMEEVENTS\GameStatus.txt"
	set GSFil = file(GSFilName).read

	if GSFil contains "Lottery:On" then set gLotteryON = TRUE

	set CTF = "OFF"

end refreshGames

on loadGameIniFiles(movie, username)

	exit

	aniList = file("DAT\DATAS\LOCALS\aniList-a.txt").read
	sendMovieMessage(movie, username, "AppdList|aniList", aniList)

	aniList = file("DAT\DATAS\LOCALS\aniList-b.txt").read
	sendMovieMessage(movie, username, "AppdList|aniList", aniList)

	aniList = file("DAT\DATAS\LOCALS\weapList.txt").read
	sendMovieMessage(movie, username, "AppdList|weaponList", aniList)

	aniList = value(VOID)
	--   set HPMax = "305"
	--   set SkillMax = "100"
	startmap = file("DAT\DATAS\LOCALS\StartMap.txt").read
	sendMovieMessage(movie, username, "SendSettings", "305:200:" & startmap)

end loadGameIniFiles

on loadGameModes(movie, username)

	modeFile = string(file("DAT\SETTINGS\GameModes.dam").read)
	sendMovieMessage(movie, username, "load.game_modes", modeFile)

	exit

	set FactionPowers = file("DAT\GAMEPLAY\POLITICAL\factions.txt").read
	sendMovieMessage(movie, username, "factnrtrn",  FactionPowers)

	set wText = getWelcomeText()
	sendMovieMessage(movie, username, "News", wText)

	set AssSystem = file("DAT\ASSASSINS\MODE.txt").read
	if AssSystem contains "LIGHT" then sendMovieMessage(movie, username, "ltass",  "x")

	set SysFill = file("DAT\SETTINGS\System.txt").read
	if SysFill contains "Speed Hack Protection:OFF" then sendMovieMessage(movie, username, "DontSHP", "x")

end loadGameModes

on getWelcomeText()
	welNews = string(file("DAT\SETTINGS\News.txt").read)

	n = 1
	repeat while welNews.line[n] <> ""
		if n = 1 then
			set tWelNews = welNews.line[n]
		else
			set tWelNews = tWelNews & welNews.line[n]
		end if
		set n = n + 1
	end repeat

	tChars = (file("DAT\SETTINGS\UsersCreated.txt").read)
	tChars = "Total number of characters created is " & tChars

	tMaps = string(file("DAT\SETTINGS\TotalMaps.txt").read)
	tMaps = "Total number of maps created is " & tMaps

	return tWelNews & RETURN & tChars & RETURN & tMaps
end