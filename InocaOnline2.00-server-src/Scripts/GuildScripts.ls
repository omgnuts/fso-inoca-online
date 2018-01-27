on mainGuildDispatcher(movie, user, fullmsg)
	
	username = user.name
	action = fullmsg.subject

	if (action = "guild.loadedit") then 

		guildName = fullMsg.content
		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)

		if not(guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			-- the guild was disbanded while this guild is being loaded.
			sendMovieMessage(movie, username, "guild.error", "This guild has just been disbanded!")
			exit
		end if

		sendMovieMessage(movie, username, "guild.loadedit", guildName & "/" & guildDatFile)

	else if (action = "guild.getall") then 

		guildList = string(file("DAT\GUILDS\GuildList.dam").read)

		sendMovieMessage(movie, username, "guild.getall", guildList)

	else if (action = "guild.reloadedit") then 

		guildName = fullMsg.content
		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)

		if not(guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			-- the guild was disbanded while this guild is being loaded.
			sendMovieMessage(movie, username, "guild.error", "This guild has just been disbanded!")
			exit
		end if

		sendMovieMessage(movie, username, "guild.reloadedit", guildName & "/" & guildDatFile)

	else if (action = "guild.create") then 

		-- lets do some preliminary checks to see if the guild can be created or not			
		the itemdelimiter = "-"
		newGuild = fullMsg.content.item[1]
		founder = fullMsg.content.item[3]

		guildDatFile = string(file("DAT\GUILDS\DATA\" & newGuild & ".dam").read)

		if guildDatFile contains "-" OR guildDatFile.char[1..10] = "DISBANDED`" then 
			sendMovieMessage(movie, username, "guild.error", "This guild name cannot be used!")
			exit
		end if

		-- lets check if the guy has enough money & the required items to create the guild 
		-- For example the guild orb, 150K etc



		-- ok there's no such guild in the system. Lets carry on.
		-- now lets really create the guild

		guildDatFile = fullMsg.content & RETURN & username & ":Leader:1:1"
		file("DAT\GUILDS\DATA\" & newGuild & ".dam").write(guildDatFile)

		addToGenericList(newGuild, "DAT\GUILDS\GuildList.dam")

		sendMovieMessage(movie, username, "guild.created", newGuild)
		sendMovieMessage(movie, username, "guild.reloadedit", newGuild & "/" & guildDatFile)

	else if (action = "guild.savedata") then

		the itemdelimiter = "/"
		guildName = fullMsg.content.item[1]
		guildDat = fullMsg.content.item[2]

		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
		if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			sendMovieMessage(movie, username, "guild.error", "This guild name cannot be used!")
			exit
		end if

		file("DAT\GUILDS\DATA\" & guildName & ".dam").write(guildDat)

		-- reload all the guild's information to everyone
		
		sendMovieMessage(movie, "@" & guildName, "guild.loadplay", guildName & "/" & guildDat)
		sendMovieMessage(movie, username, "guild.saveddata", "x")

	else if (action = "guild.resignguild") then 

		guildName = fullMsg.content

		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
		if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			sendMovieMessage(movie, username, "guild.error", "This guild name cannot be used!")
			exit
		end if

		the itemdelimiter = "-"
		if guildDatFile.line[1].item[3] = username then
			sendMovieMessage(movie, username, "guild.error", "You cannot leave the guild as a leader!")
			exit
		end if
		
		if guildDatFile contains (username & ":") then
		
			n = 2
			the itemdelimiter = ":"

			repeat while guildDatFile.line[n] <> ""
				if guildDatFile.line[n].item[1] = username then
				
					delete guildDatFile.line[n]
					file("DAT\GUILDS\DATA\" & guildName & ".dam").write(guildDatFile)
					
					sendMovieMessage(movie, username, "guild.reloadedit", guildName & "/" & guildDatFile)
					sendMovieMessage(movie, "@" & guildName, "chat.guild", "*** " & username & " has just left from " & guildName)

					exit
					
				end if					
				n = n + 1
			end repeat

			sendMovieMessage(movie, username, "guild.error", "You are not in this guild!")
			exit
			
		else
		
			sendMovieMessage(movie, username, "guild.error", "You are not in this guild!")
			exit
			
		end if

	else if (action = "guild.disband") then
	
		guildName = fullMsg.content
		
		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
		if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			sendMovieMessage(movie, username, "guild.error", "This guild name cannot be used!")
			exit
		end if
		
		the itemdelimiter = "-"
		if guildDatFile.line[1].item[3] <> username then
			sendMovieMessage(movie, username, "guild.error", "Only the guild leader can disband the guild!")
			exit
		end if
		
		guildDatFile = "DISBANDED`" & guildDatFile
		
		removeFromGenericList(guildName, "DAT\GUILDS\GuildList.dam", ":")
		file("DAT\GUILDS\DATA\" & guildName & ".dam").write(guildDatFile)
		
		-- get everyone to leave the guild
		sendMovieMessage(movie, "@" & guildName, "guild.leave", guildName)
		sendMovieMessage(movie, username, "guild.disbanded", "x")

	else if (action = "guild.exile") then
	
		the itemdelimiter = "/"

		player = fullMsg.content.item[1]
		guildName = fullMsg.content.item[2]
		
		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
		if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			sendMovieMessage(movie, username, "guild.error", "This guild name cannot be used!")
			exit
		end if
		
		the itemdelimiter = "-"
		if guildDatFile.line[1].item[3] <> username then
			sendMovieMessage(movie, username, "guild.error", "Only the guild leader can exile a player!")
			exit
		end if

		if guildDatFile contains (player & ":") then
		
			the itemdelimiter = ":"
			n = 2
			repeat while guildDatFile.line[n] <> ""

				lineDat = guildDatFile.line[n]

				if lineDat.item[1] = player then
					delete guildDatFile.line[n]
					file("DAT\GUILDS\DATA\" & guildName & ".dam").write(guildDatFile)

					-- tell everyone player has been exiled
					sendMovieMessage(movie, "@" & guildName, "chat.guild", "*** " & player & " has been exiled from " & guildName)
					sendMovieMessage(movie, username, "guild.reloadedit", guildName & "/" & guildDatFile)
					sendMovieMessage(movie, player, "guild.leave", guildName)

					exit
				end if

				n = n + 1
			end repeat

			sendMovieMessage(movie, username, "guild.error", "Error: Unable to find the player name!")
			exit

		else
		
			sendMovieMessage(movie, username, "guild.error", "Error: Unable to find the player name!")
			exit
			
		end if
		
	else if (action = "guild.abdicate") then
	
		the itemdelimiter = "/"

		player = fullMsg.content.item[1]
		guildName = fullMsg.content.item[2]
		
		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
		if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			sendMovieMessage(movie, username, "guild.error", "This guild name cannot be used!")
			exit
		end if
		
		the itemdelimiter = "-"
		if guildDatFile.line[1].item[3] <> username then
			sendMovieMessage(movie, username, "guild.error", "Only the guild leader can abdicate himself!")
			exit
		end if
				
		if guildDatFile contains (player & ":") then

			n = 2
			the itemdelimiter = ":"

			repeat while guildDatFile.line[n] <> ""
				if guildDatFile.line[n].item[1] = player then

					put username into guildDatFile.line[n].item[1]
					put player into guildDatFile.line[2].item[1]
					
					the itemdelimiter = "-" 
					put player into guildDatFile.line[1].item[3]
					
					file("DAT\GUILDS\DATA\" & guildName & ".dam").write(guildDatFile)

					sendMovieMessage(movie, username, "guild.loadplay", guildName & "/" & guildDatFile)
					sendMovieMessage(movie, player, "guild.loadplay", guildName & "/" & guildDatFile)
					
					sendMovieMessage(movie, username, "guild.reloadedit", guildName & "/" & guildDatFile)
					sendMovieMessage(movie, "@" & guildName, "chat.guild", "*** " & player & " has just assumed leadership of " & guildName)

					exit

				end if					
				n = n + 1
			end repeat

			sendMovieMessage(movie, username, "guild.error", "Error: Unable to find the player name!")
			exit

		else

			sendMovieMessage(movie, username, "guild.error", "Error: Unable to find the player name!")
			exit

		end if

	else if (action = "guild.addmember") then
	
		the itemdelimiter = "/"
		player = fullMsg.content.item[1]
		guildName = fullMsg.content.item[2]
		playerDat = fullMsg.content.item[3]

		guildDatFile = string(file("DAT\GUILDS\DATA\" & guildName & ".dam").read)
		if not (guildDatFile contains "-") OR guildDatFile.char[1..10] = "DISBANDED`" then 
			exit
		end if
		
		inGuild = FALSE
		if guildDatFile contains (player & ":") then
			n = 2
			the itemdelimiter = ":"
			repeat while guildDatFile.line[n] <> ""
				if guildDatFile.line[n].item[1] = player then
					-- the player is already in the guild.
					inGuild = TRUE
				end if					
				n = n + 1
			end repeat
		end if

		if not inGuild then
			-- in case we added the guy to the guild but it does not reflect that he is in the guild. 
			-- this way we can add him again.
			
			if guildDatFile.char[guildDatFile.length] = RETURN then
				delete guildDatFile.char[guildDatFile.length]
			end if

			guildDatFile = guildDatFile & RETURN & playerDat
			file("DAT\GUILDS\DATA\" & guildName & ".dam").write(guildDatFile)		
			sendMovieMessage(movie, "@" & guildName, "chat.guild", "*** " & player & " has just joined " & guildName)		
		end if
				
		sendMovieMessage(movie, player, "guild.joined", guildName)		
		
	end if		
			
end mainGuildDispatcher