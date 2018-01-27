on BlackJackGameOver(me, movie, group, user, fullmsg)

   set TheDat = string(fullmsg.content)
   set the itemdelimiter = ":"
   set WinnerName = item 1 of TheDat
   set LoserName = item 2 of TheDat
   set GoldAmount = integer(item 3 of TheDat)

   if LoserName = WinnerName then exit
   if GoldAmount < 1 then exit

   set MyItemsFile = file("DAT\CHAR\" & string(LoserName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)
   set the itemdelimiter = ":"
   set MyGold = MyGold - GoldAmount
   if MyGold < 0 then exit
   set the itemdelimiter = "|"
   put MyGold into item 1 of MyItemsFile
   file("DAT\CHAR\" & string(LoserName & "-i") & ".txt").write(MyItemsFile)

   set MyItemsFile2 = file("DAT\CHAR\" & string(WinnerName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGoldx = integer(item 1 of MyItemsFile2)
   set the itemdelimiter = ":"
   set MyGoldx = MyGoldx + GoldAmount
   set the itemdelimiter = "|"
   put MyGoldx into item 1 of MyItemsFile2
   file("DAT\CHAR\" & string(WinnerName & "-i") & ".txt").write(MyItemsFile2)
end


on BlackJackGoldcheck(me, movie, group, user, fullmsg)

   set TheCost = integer(fullmsg.content)

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)
   set the itemdelimiter = ":"

   if MyGold >= TheCost then
     sendMovieMessage(movie, user.name, "GameLockBid", TheCost)
   else
     sendMovieMessage(movie, user.name, "GameNoBid", "x")
   end if

end



on SlotDone(me, movie, group, user, fullMsg)
   set TheCost = integer(fullmsg.content)
   set GoldOwed = 5
   set TheCost = 10

   set FirstOne = random(4)
   set SecondOne = random(4)
   set ThirdOne = random(4)

   set Winner = 0

   if FirstOne = 1 then
     if SecondOne = 1 then
        if ThirdOne = 1 then set Winner = 1
        if ThirdOne = 1 then set TheCost = TheCost + 10
     end if
   end if

   if FirstOne = 2 then
     if SecondOne = 2 then
        if ThirdOne = 2 then set Winner = 1
        if ThirdOne = 2 then set TheCost = TheCost + 15
     end if
   end if

   if FirstOne = 3 then
     if SecondOne = 3 then
        if ThirdOne = 3 then set Winner = 1
        if ThirdOne = 3 then set TheCost = TheCost + 20
     end if
   end if

   if FirstOne = 4 then
     if SecondOne = 4 then
        if ThirdOne = 4 then set Winner = 1
        if ThirdOne = 4 then set TheCost = TheCost + 40
     end if
   end if

   if FirstOne = 2 then
     if SecondOne = 3 then
        if ThirdOne = 2 then set Winner = 1
        if ThirdOne = 2 then set TheCost = TheCost + 70
     end if
   end if

   if FirstOne = 3 then
     if SecondOne = 4 then
        if ThirdOne = 3 then set Winner = 1
        if ThirdOne = 3 then set TheCost = TheCost + 30
     end if
   end if

   set MyName = user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)
   set the itemdelimiter = ":"
   set MyGold = MyGold - GoldOwed
   if MyGold < 0  then exit
   if Winner = 1 then set MyGold = MyGold + TheCost
   set the itemdelimiter = "|"
   put MyGold into item 1 of MyItemsFile
   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

   set Results = FirstOne & ":" & SecondOne & ":" & ThirdOne

   if Winner = 1 then
     sendMovieMessage(movie, user.name, "winslot", Results)
    else
     sendMovieMessage(movie, user.name, "loseslot", Results)
   end if
end

--"
on updateHighScore(movie, playername, playerscore)

	scoreFile = string(file("DAT\SETTINGS\HighScores.dam").read)
	the itemdelimiter = ":"

	set nRank = 0
	set cRank = 0

	repeat with n = 1 to 10
		set curHS = item n of HSList
		set the itemdelimiter = "-"
		if nRank = 0 then
			if scre >= integer(item 2 of curHS) then set nRank = n
		end if
		if cRank = 0 then
			if myName = string(item 1 of curHS) then set cRank = n
		end if
		set the itemdelimiter = "|"
	end repeat

	if nRank = 0 then exit
	if cRank = 0 then set cRank = 10

	if nRank = 1 then
		set newHS = myName & "-" & scre & "|"
	else
		repeat with n = 1 to (nRank - 1)
			set newHS = item n of HSList & "|"
		end repeat

		set newHS = newHS & myName & "-" & scre & "|"
	end if

	if (cRank > nRank) then --// inserting myscore

		if (nRank < 10) then
			repeat with n = (nRank + 1) to cRank
				set newHS = newHS & item (n - 1) of HSList & "|"
			end repeat
		end if

		if cRank < 10 then
			repeat with n = (cRank + 1) to 10
				set newHS = newHS & item n of HSList & "|"
			end repeat
		end if

	else if (cRank = nRank) then --// replacing my score
		set cRank = 10

		if (nRank < 10) then
			repeat with n = (nRank + 1) to cRank
				set newHS = newHS & item (n) of HSList & "|"
			end repeat
		end if

	end if


	file("DAT\SETTINGS\highscore.txt").write(newHS)
	
	sendMovieMessage(movie, playername, "load.highscore", scoreFile)
end

on CheckHighScore_old MyName, scre

   set FilName = "DAT\SETTINGS\highscore.txt"
   set HighScoreList = file(FilName).read
   set the itemdelimiter = "|"
   set HScore1 = item 1 of HighScoreList
   set HScore2 = item 2 of HighScoreList
   set HScore3 = item 3 of HighScoreList
   set HScore4 = item 4 of HighScoreList
   set HScore5 = item 5 of HighScoreList
   set HScore6 = item 6 of HighScoreList
   set HScore7 = item 7 of HighScoreList
   set HScore8 = item 8 of HighScoreList
   set HScore9 = item 9 of HighScoreList
   set HScore10 = item 10 of HighScoreList

   set the Itemdelimiter = "-"
   if item 1 of HScore1 = MyName then set HScore1 = ""
   if item 1 of HScore2 = MyName then set HScore2 = ""
   if item 1 of HScore3 = MyName then set HScore3 = ""
   if item 1 of HScore4 = MyName then set HScore4 = ""
   if item 1 of HScore5 = MyName then set HScore5 = ""
   if item 1 of HScore6 = MyName then set HScore6 = ""
   if item 1 of HScore7 = MyName then set HScore7 = ""
   if item 1 of HScore8 = MyName then set HScore8 = ""
   if item 1 of HScore9 = MyName then set HScore9 = ""
   if item 1 of HScore10 = MyName then set HScore10 = ""
   set MyGoods = MyName & "-" & scre

   set NewHighScoreList = ":" & HScore1 & "::" & HScore2 & "::" & HScore3 & "::" & HScore4 & "::" & HScore5 & "::" & HScore6
   set NewHighScoreList = NewHighScoreList & "::" & HScore7 & "::" & HScore8 & "::" & HScore9 & "::" & HScore10 & "::"

   set WeRanked = FALSE
   set scre = integer(scre)

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre > integer(item 2 of HScore1) then
     set the itemdelimiter = ":"
     put MyGoods into item 1 of NewHighScoreList
     set WeRanked = TRUE
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore1) then
     if scre > integer(item 2 of HScore2) then
      set the itemdelimiter = ":"
      put MyGoods into item 3 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore2) then
     if scre > integer(item 2 of HScore3) then
      set the itemdelimiter = ":"
      put MyGoods into item 5 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore3) then
     if scre > integer(item 2 of HScore4) then
      set the itemdelimiter = ":"
      put MyGoods into item 7 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore4) then
     if scre > integer(item 2 of HScore5) then
      set the itemdelimiter = ":"
      put MyGoods into item 9 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore5) then
     if scre > integer(item 2 of HScore6) then
      set the itemdelimiter = ":"
      put MyGoods into item 11 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore6) then
     if scre > integer(item 2 of HScore7) then
      set the itemdelimiter = ":"
      put MyGoods into item 13 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore7) then
     if scre > integer(item 2 of HScore8) then
      set the itemdelimiter = ":"
      put MyGoods into item 15 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore8) then
     if scre > integer(item 2 of HScore9) then
      set the itemdelimiter = ":"
      put MyGoods into item 17 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then
    set the itemdelimiter = "-"
    if scre < integer(item 2 of HScore9) then
     if scre > integer(item 2 of HScore10) then
      set the itemdelimiter = ":"
      put MyGoods into item 19 of NewHighScoreList
      set WeRanked = TRUE
     end if
    end if
   end if

   if WeRanked = FALSE then exit

   set the itemdelimitere = ":"

   set TheHighScoreList = ""
   set NumberONames = 0
   set the itemdelimiter = ":"

   repeat with x = 1 to 21
      if item x of NewHighScoreList <> "" then
        if NumberONames < 10 then set TheHighScoreList = TheHighScoreList & item x of NewHighScoreList & "|"
        set NumberONames = NumberONames + 1
      end if
   end repeat

 file("DAT\SETTINGS\highscore.txt").write(TheHighScoreList)

end
