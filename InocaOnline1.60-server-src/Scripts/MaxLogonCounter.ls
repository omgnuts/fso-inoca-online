Global CurrentNumUsers

on userLogOna (user, movie)
   if user.name contains "newchar" then
   else
		set CurrentNumUsers = integer(CurrentNumUsers) + 1
	   sendMovieMessage(movie, "@Admins", "sqa", user.name & " has just logged on.")
	   sendMovieMessage(movie, "@AllUsers", "934", user.name)
		CheckUserMax(user, movie)
	end if

end

on UserLogOffa (user, movie)
   if user.name contains "newchar" then
   else
		set CurrentNumUsers = integer(CurrentNumUsers) - 1
		file("DAT\TimeStamp\" & user.name & ".txt").write("")
		sendMovieMessage(movie, "@Admins", "sqa", user.name & " has just logged off.")
		sendMovieMessage(movie, "@AllUsers", "935", user.name)
	end if
end

on CheckUserMax(user, movie)

	set the itemdelimiter = "|"
	set UserMaxFile = file("DAT\settings\usermax.txt").read

	if UserMaxFile contains "|" then
		set UserMax = integer(item 1 of string(UserMaxFile))
		if CurrentNumUsers > UserMax then
			set UserMaxFile = integer(CurrentNumUsers) & "|" & getDateTime()
			file("DAT\settings\UserMax.txt").write(UserMaxFile)
		end if
	else
		file("DAT\settings\UserMax.txt").write("1|" & getDateTime())
	end if
end

on IncreaseTotalChar()
	set tChar = file("DAT\settings\userscreated.txt").read
	file("DAT\settings\userscreated.txt").write(string(integer(tChar) + 1))
end

on IncreaseTotalMaps()
	set tMaps = file("DAT\settings\TotalMaps.txt").read
	file("DAT\settings\TotalMaps.txt").write(string(integer(tMaps) + 1))
end