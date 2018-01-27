on returnVehicles(user, vehicle)
	set vehOwners = file("DAT\AccessList\Vehicles.txt").read
	if vehOwners contains "*" & user.name & "*" then
		if vehicle contains " boat" then set vehicle = user.name & "'s Boat"
		if vehicle contains " battleship" then set vehicle = user.name & "'s Battleship"
		if vehicle contains " airship" then set vehicle = user.name & "'s Airship"
	end if
	return vehicle
end

on buyLottery(user, movie)

	Global gLotteryON

	if gLotteryON then

		set ticketPrice = 500
		set numBuyers = 30

		set the itemdelimiter = ":"
		set curLottList = file("DAT\GameEvents\LotteryList.txt").read

		if curLottList contains ":" & user.name & ":" then
			sendMovieMessage(movie, user.name, "sqa", "You have already bought a ticket.")
			exit
		end if

		if string(curLottList) = "" then set curLottList = "@:"

		if RemSaveItemX("Gold", 500, user.name, movie) then

			put user.name & ":" after curLottList

			set lottNum = random(89999) + 10000

			sendMovieMessage(movie, user.name, "sqa", "You have bought a ticket #" & lottNum & ". Good luck!")

			if the number of items in curLottList >= (numBuyers + 2) then

				set winner = random(numBuyers) + 1
				set winner = string(item winner of curLottList)

				set winMsg = "Congratulations!! " & winner & " has won $30,000 from the lottery!"

				AddSaveItemX("Gold", 30000, winner, movie)
				sendMovieMessage(movie, "@AllUsers", "broadcast|5" , winMsg)

				set curLottList = "@:"
			end if

			file("DAT\GameEvents\LotteryList.txt").write(curLottList)

		end if

	end if

end buyLottery

on changeHair(movie, user, newHair)

	set myCharFile = file("DAT\Char\" & user.name & ".txt").read
	set the itemdelimiter = ":"

	if char 1 of (item 14 of myCharFile) = "1" then  --//male
  		set hairTypes = ":19:23:24:25:26:27:1:9:16:17:18:12:14:15:3:4:5:6:10:13:"
  	else --// females
  		set hairTypes = ":28:29:30:31:32:33:7:34:35:36:37:2:8:11:20:21:22:38:39:40:41:42:43:"
  	end if

  	if hairTypes contains ":" & newHair & ":" then
		set hairLog = file("DAT\GameEvents\buyHair.txt").read
		if hairLog contains ":" & user.name & ":" then

			-- Set Marriage Name --
			sendMovieMessage(movie, user.name, "setHair", newHair)
			put string(newHair) into item 14 of myCharFile
			file("DAT/CHAR/" & user.name & ".txt").write(myCharFile)

			set MyItemsFile = file("DAT/CHAR/" & user.name & "-i.txt").read
			sendMovieMessage(movie, user.name, "inx", MyItemsFile)
			RemoveFromList(user.name, "GameEvents\buyHair.txt", ":")
		end if

  	end if

end changeHair