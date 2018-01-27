On StartMarriage(movie, user, groomName, brideName)
	Global WeddingStatus, Bride, Groom, Priest, ChurchMap

	set saveDemi = the itemdelimiter

	set churchMap = string(file("DAT/SpecialMaps/Church.txt").read)

	set PriestList = file("DAT/Marriage/Priests.txt").read
	if PriestList contains "*" & string(user.name) & "*" then
		-- continue
	else
		sendMovieMessage(movie, user.name, "sqa", "You cannot start a wedding.")
		exit
	end if

	------------------------------------------
	-- "Check for char exist and Divorce Check"
	------------------------------------------
	set chkCharFile = file("DAT/Char/" & groomName & ".txt").read

	if chkCharFile contains ":" then

		set oldLoveChar = item 4 of string(chkCharFile)
		if oldLoveChar contains "loves " then
			sendMovieMessage(movie, "@" & churchMap, "sqa", "Priest says 'I see that the groom is already married to " & word 2 of oldLoveChar & "'")
			exit
		end if

		set chkCharFile = file("DAT/Char/" & brideName & ".txt").read
		if chkCharFile contains ":" then
			set oldLoveChar = item 4 of string(chkCharFile)
			if oldLoveChar contains "loves " then
				sendMovieMessage(movie, "@" & churchMap, "sqa", "Priest says 'I see that the bride is already married to " & word 2 of oldLoveChar & "'")
				exit
			end if
			-- // both exist
		else
			sendMovieMessage(movie, user.name, "sqa", brideName & " is not an existing character.")
			exit
		end if
	else
		sendMovieMessage(movie, user.name, "sqa", groomName & " is not an existing character.")
		exit
	end if

	------------------------------------------
	-- "Priest Check" / Admin
	------------------------------------------

	if PriestList contains "*" & string(groomName) & "*" or PriestList contains "*" & string(brideName) & "*" then
		sendMovieMessage(movie, "@" & churchMap, "sqa", "Priests cannot marry.")
		exit
	end if

	if checkAdminAccess(groomName, 8) or checkAdminAccess(brideName, 8) then
		sendMovieMessage(movie, "@" & churchMap, "sqa", "Staff members cannot marry.")
		exit
	end if

	------------------------------------------
	-- "Check for wedding bands"
	------------------------------------------
	set chkItemFile = file("DAT\CHAR\" & groomName & "-i.txt").read
	if chkItemFile contains ":Wedding Ring:" then
		set chkItemFile = file("DAT\CHAR\" & brideName & "-i.txt").read
		if chkItemFile contains ":Wedding Ring:" then
			-- // both are wearing a wedding ring
		else
			sendMovieMessage(movie, brideName, "sqa", "Please put on your wedding ring.")
			sendMovieMessage(movie, user.name, "sqa", "Request for the couple to put on their wedding rings and restart the wedding.")
		end if
	else
		sendMovieMessage(movie, groomName, "sqa", "Please put on your wedding ring.")
		sendMovieMessage(movie, user.name, "sqa", "Request for the couple to put on their wedding rings and restart the wedding.")
	end if
	-----------------------------------------------------------------------
	-- announce the marriage
	-----------------------------------------------------------------------
	set WeddingStatus = 1   -- // wedding started
	set Groom = groomName
	set Bride = brideName

	sendMovieMessage(movie, "@AllUsers", "broadcast|4", Groom & " and " & Bride & " are getting married! You may wish to attend the wedding at the church.")

end

On WedSpouses(movie, user)
	Global WeddingStatus, Bride, Groom, Priest, ChurchMap

	set PriestList = file("DAT/Marriage/Priests.txt").read
	if PriestList contains "*" & string(user.name) & "*" then
		if WeddingStatus = 1 then
			sendMovieMessage(movie, "@" & ChurchMap, "sqa", "Priest says '" & Groom & ", do you take " & Bride & " to be your lawfully wedded wife?'")
			set WeddingStatus = 2 -- // await reply
		end if
		if WeddingStatus = 3 then
			sendMovieMessage(movie, "@" & ChurchMap, "sqa", "Priest says '" & Bride & ", do you take " & Groom & " to be your lawfully wedded husband?'")
			set WeddingStatus = 4 -- // await reply
		end if
	end if

end

On MarAgreed(movie, user, personName)

	Global WeddingStatus, Bride, Groom, Priest, ChurchMap

	if string(personName) = "Groom" then
		sendMovieMessage(movie, "@" & ChurchMap, "sqa", Groom & " says, 'I do.'")
		set WeddingStatus = 3
	end if
	if string(personName) = "Bride" then
		sendMovieMessage(movie, "@" & ChurchMap, "sqa", Bride & " says, 'I do.'")
		set WeddingStatus = 5
	end if

	---------------------------------
     	-- "Check if married"
     	---------------------------------
	if WeddingStatus = 5 then
		if RemSaveEQX("Wedding Ring", Groom, movie) and RemSaveEQX("Wedding Ring", Bride, movie) then
			sendMovieMessage(movie, "@" & ChurchMap, "sqa", "Priest says 'I now pronounce " & Groom & " and " & Bride & " as husband and wife. You may kiss the bride!")

			sendMovieMessage(movie, "@allusers", "SoundPlay", "Churchy:5:200")
			sendMovieMessage(movie, "@allusers", "broadcast|4", "Priest says '" & Groom & " and " & Bride & " are the newest couple. Congratulations to them!'")

			-- Set Marriage Name --
			sendMovieMessage(movie, Groom, "setSurName", "loves " & Bride)
			sendMovieMessage(movie, Bride, "setSurName", "loves " & Groom)

			--// In case of disconnections
			set GroomFile = file("DAT/CHAR/" & Groom & ".txt").read
			set BrideFile = file("DAT/CHAR/" & Bride & ".txt").read

			set the itemdelimiter = ":"

			put string("loves " & Bride) into item 4 of GroomFile
			put string("loves " & Groom) into item 4 of BrideFile

			file("DAT/CHAR/" & Groom & ".txt").write(GroomFile)
			file("DAT/CHAR/" & Bride & ".txt").write(BrideFile)

			----------------

			ResetWedding()

		end if
	end if
end

On ResetWedding()
	Global WeddingStatus, Bride, Groom, Priest, ChurchMap

	set WeddingStatus = 0
	set Bride = ""
	set Groom = ""
	set Priest = ""
end

on divorceMe(movie, user, groomName, brideName)

	set PriestList = file("DAT/Marriage/Priests.txt").read
	if PriestList contains "*" & string(user.name) & "*" then
		-- continue
	else
		sendMovieMessage(movie, user.name, "sqa", "You cannot divorce married couples.")
		exit
	end if

	set the itemdelimiter = ":"

	set GroomFile = file("DAT/CHAR/" & groomName & ".txt").read
	set BrideFile = file("DAT/CHAR/" & brideName & ".txt").read

	set gSurName = item 4 of GroomFile
	set bSurName = item 4 of BrideFile

	set gSurName = word 2 of gSurName
	set bSurName = word 2 of bSurName

	if (gSurName = brideName) and (bSurName = groomName) then

		sendMovieMessage(movie, groomName, "setSurName", "Inocian")
		sendMovieMessage(movie, brideName, "setSurName", "Inocian")

		--// In case of disconnections
		put string("Inocian") into item 4 of GroomFile
		put string("Inocian") into item 4 of BrideFile

		file("DAT/CHAR/" & groomName & ".txt").write(GroomFile)
		file("DAT/CHAR/" & brideName & ".txt").write(BrideFile)

	end if

end