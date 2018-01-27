-- "Backup" dir in the DAT dir is needed

on BackupChar(UserName)

	set CharFile = file("DAT\char\" & UserName & ".txt").read
	set ItemFile = file("DAT\char\" & UserName & "-i.txt").read
	set DMFile = file("DAT\DM\" & UserName & ".txt").read
	file("DAT\Backup\" & UserName & ".txt").write(CharFile)
	file("DAT\Backup\" & UserName & "-i.txt").write(ItemFile)
	file("DAT\backup\" & UserName & "-DM.txt").write(DMFile)

--	set BackupSettings = file("DAT\Backup\BackupSettings.txt").Read
--	if BackupSettings contains ":" then
--		set the itemdelimiter = ":"
--		set MaxBackup = integer(item 1 of BackupSettings)
--	else
--		set MaxBackup = 10
--		set BackupSettings = "10::::::::::::"
--		file("DAT\Backup\BackupSettings.txt").Write(BackupSettings)
--	end if
--
--	set MySettings = file("DAT\Backup\" & UserName & "Settings.txt").Read
--	if MySettings contains ":" then
--		set the itemdelimiter = ":"
--		set MyNumber = integer(item 1 of MySettings) + 1
--		if MyNumber > MaxBackup then
--			set MyNumber = 1
--		end if
--	else
--		set MyNumber = 1
--		file("DAT\Backup\" & UserName & "Settings.txt").write( MyNumber & "::::::::::::" )
--	end if
--
--	set MySettings = string(MyNumber) & "::::::::::::"
--	file("DAT\Backup\" & UserName & "Settings.txt").Write(MySettings)
--
--	-- put "Backup charfiles"
--	--------------------------
--	set MyDM = file("DAT\DM\" & UserName & ".txt").read
--	file("DAT\backup\DM\" & UserName & "-DM" & MyNumber & ".txt").write(MyDM)
--	---------
--	set CharFile = file("DAT\char\" & UserName & ".txt").read
--	file("DAT\Backup\Stats\" & UserName & MyNumber & ".txt").write(CharFile)
--	---------
--	set ItemFile = file("DAT\char\" & UserName & "-i.txt").read
--	file("DAT\Backup\Items\" & UserName & "-i" & MyNumber & ".txt").write(ItemFile)

end


on RestoreLastBackup(UserName, movie)

	set MyDM = file("DAT\backup\" & UserName & "-DM.txt").read
	file("DAT\DM\" & UserName & ".txt").write(MyDM)
	---------
	set Charfile = file("DAT\Backup\" & UserName & ".txt").read
	set CharDM = file("DAT\DM\" & UserName & ".txt").read
	set the itemdelimiter = "/"
	set FirstCharPart = item 1 of string(Charfile)
	set the itemdelimiter = ":"
	set MapName = item 1 of string(CharDM)
	set Coords = item 2 of string(CharDM)
	put MapName into item 5 of FirstCharPart
	put Coords into item 6 of FirstCharPart
	set the itemdelimiter = "/"
	put FirstCharPart into item 1 of Charfile
	file("DAT\char\" & UserName & ".txt").write(CharFile)
	---------
	set ItemFile = file("DAT\Backup\" & UserName & "-i" & ".txt").read
	file("DAT\char\" & UserName & "-i.txt").write(ItemFile)
	sendMovieMessage(movie, UserName, "inx", ItemFile)
end






-- on RestoreLastBackup(UserName, movie)

--	sendMovieMessage(movie, UserName, "234882347782347923482347", "x")
--	set BackupSettings = file("DAT\Backup\BackupSettings.txt").Read
--	if BackupSettings contains ":" then
--		set the itemdelimiter = ":"
--		set MaxBackup = integer(item 1 of BackupSettings)
--	else
--		set MaxBackup = 10
--		set BackupSettings = "10::::::::::::"
--		file("DAT\Backup\BackupSettings.txt").Write(BackupSettings)
--	end if

--	set MySettings = file("DAT\Backup\" & UserName & "Settings.txt").Read
--	if MySettings contains ":" then
--		set the itemdelimiter = ":"
--		set MyNumber = integer(item 1 of MySettings)
--	else
--		return "No Backup Found"
--	end if

	-- put "Restore charfiles"
	--------------------------
--	set MyDM = file("DAT\backup\DM\" & UserName & "-DM" & MyNumber & ".txt").read
--	file("DAT\DM\" & UserName & ".txt").write(MyDM)
	---------
--	set Charfile = file("DAT\Backup\Stats\" & UserName & MyNumber & ".txt").read
--	set CharDM = file("DAT\DM\" & UserName & ".txt").read
--	set the itemdelimiter = "/"
--	set FirstCharPart = item 1 of string(Charfile)
--	set the itemdelimiter = ":"
--	set MapName = item 1 of string(CharDM)
--	set Coords = item 2 of string(CharDM)
--	put MapName into item 5 of FirstCharPart
--	put Coords into item 6 of FirstCharPart
--	set the itemdelimiter = "/"
--	put FirstCharPart into item 1 of Charfile
--	file("DAT\char\" & UserName & ".txt").write(Charfile)
--	---------
--	set ItemFile = file("DAT\Backup\Items\" & UserName & "-i" & MyNumber & ".txt").read
--	file("DAT\char\" & UserName & "-i.txt").write(ItemFile)
--	sendMovieMessage(movie, UserName, "inx", ItemFile)

-- end

--on RestoreItemBackup(UserName, movie)
--
--	set BackupSettings = file("DAT\Backup\BackupSettings.txt").Read
--	if BackupSettings contains ":" then
--		set the itemdelimiter = ":"
--		set MaxBackup = integer(item 1 of BackupSettings)
--	else
--		set MaxBackup = 10
--		set BackupSettings = "10::::::::::::"
--		file("DAT\Backup\BackupSettings.txt").Write(BackupSettings)
--	end if
--
--	set MySettings = file("DAT\Backup\" & UserName & "Settings.txt").Read
--	if MySettings contains ":" then
--		set the itemdelimiter = ":"
--		set MyNumber = integer(item 1 of MySettings)
--	else
--		return "No Backup Found"
--	end if
--
--	-- put "Restore ItemBackup"
--	--------------------------
--	set ItemFile = file("DAT\Backup\Items\" & UserName & "-i" & MyNumber & ".txt").read
--	file("DAT\char\" & UserName & "-i.txt").write(ItemFile)
--	sendMovieMessage(movie, UserName, "inx", ItemFile)
--
--end