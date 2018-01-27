
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
			-- // "View Cheaters "
			----------------------------------------------------------------
			if fullMsg.content = "viewCheaters" then
					if checkAdminAccess(user.name, 2) then
					ViewCheaters(me, movie, group, user, fullmsg)
				end if
					exit
			end if

			
			

	end case
		
		
