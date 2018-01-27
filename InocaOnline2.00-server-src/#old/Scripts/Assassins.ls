--// Only IMMORTALS can start assassin

on StartLightningAssGame(me, movie, group, user, fullmsg)

  if checkAdminAccess(user.name, 1) then
  else
		exit
  end if

  set xrun = "*** The Lightning Assassin's Game has begun!"
  sendMovieMessage(movie, "@AllUsers", "sqa", xrun)
  set xrun = "*** Kill everyone in sight to become the greatest assassin ever!"
  sendMovieMessage(movie, "@AllUsers", "sqa", xrun)
  set xrun = "*** 1 hit is 1 kill and all death penalties are OFF!"
  sendMovieMessage(movie, "@AllUsers", "sqa", xrun)

  sendMovieMessage(movie, "@AllUsers", "ltass", "x")
  sendMovieMessage(movie, "@AllUsers", "ltass", "x")

  file("DAT\SETTINGS\assassinsscore.txt").write("|||||||||||")

  set PastAssassins = "DAT\ASSASSINS\ASSASSINLIST.txt"
  set PastAssassins = file(PastAssassins).read
  set the itemdelimiter = "*"


  if PastAssassins <> VOID then

    repeat with x = 1 to 300

      set CurAss = item x of PastAssassins

      if CurAss <> "" then

         file("DAT\ASSASSINS\" & CurAss & ".txt").write("0")

      end if

    end repeat

  end if

  file("DAT\ASSASSINS\ASSASSINLIST.txt").write("*")
  file("DAT\ASSASSINS\MODE.txt").write("LIGHTNING")

end




on StartAssGame(me, movie, group, user, fullmsg)

   if checkAdminAccess(user.name, 1) then

     else

     exit

  end if


  set xrun = "*** The Assassin's Game has begun!"
  sendMovieMessage(movie, "@AllUsers", "sqa", xrun)
  set xrun = "*** Kill everyone in sight to become the greatest assassin ever!"
  sendMovieMessage(movie, "@AllUsers", "sqa", xrun)

  file("DAT\SETTINGS\assassinsscore.txt").write("|||||||||||")

  set PastAssassins = "DAT\ASSASSINS\ASSASSINLIST.txt"
  set PastAssassins = file(PastAssassins).read
  set the itemdelimiter = "*"


  if PastAssassins <> VOID then

    repeat with x = 1 to 300

      set CurAss = item x of PastAssassins

      if CurAss <> "" then

         put "resetting " & CurAss & "'s assassin score."
         file("DAT\ASSASSINS\" & CurAss & ".txt").write("0")

      end if

    end repeat

  end if

  file("DAT\ASSASSINS\ASSASSINLIST.txt").write("*")
  file("DAT\ASSASSINS\MODE.txt").write("GO")

end




on EndAssGame(me, movie, group, user, fullmsg)

   if checkAdminAccess(user.name, 1) then

     else

     exit

  end if


   sendMovieMessage(movie, "@AllUsers", "xltoff", "x")
   sendMovieMessage(movie, "@AllUsers", "xltoff", "x")

   set xrun = "*** The assassin's game has ended!!!"
   sendMovieMessage(movie, "@AllUsers", "sqa", xrun)

   set FilName = "DAT\SETTINGS\assassinsscore.txt"
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
   set Winner1 = item 1 of HScore1
   set Winner2 = item 1 of HScore2
   set Winner3 = item 1 of HScore3
   set Winner4 = item 1 of HScore4
   set Winner5 = item 1 of HScore5
   set Winner6 = item 1 of HScore6
   set Winner7 = item 1 of HScore7
   set Winner8 = item 1 of HScore8
   set Winner9 = item 1 of HScore9
   set Winner10 = item 1 of HScore10
   set Pttts = item 2 of HScore1

   set xrun = "*** " & Winner1 & " has won first place with " & Pttts & " points!"
   sendMovieMessage(movie, "@AllUsers", "sqa", xrun)
   set xrun = "*** " & Winner2 & " has won second place and " & Winner3 & " has come in third."
   sendMovieMessage(movie, "@AllUsers", "sqa", xrun)
   set xrun = "*** Check back soon for yet another assassin's game."
   sendMovieMessage(movie, "@AllUsers", "sqa", xrun)

   AssLegend(Winner1)

  file("DAT\ASSASSINS\MODE.txt").write("STOP")

   set FilName = "DAT\SETTINGS\ASSASSINPRIZES.txt"
   set Prizess = file(FilName).read
   set the itemdelimiter = ":"

   set nItem = item 1 of Prizess
   if nItem = VOID then exit
   if nItem = "" then exit
   set ItemNum = 1
   set MyItemsFile = file("DAT\CHAR\" & string(Winner1) & "-i.txt").read
   set MyName = Winner1
   InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   set nItem = item 2 of Prizess
   if nItem = VOID then exit
   if nItem = "" then exit
   set ItemNum = 1
   set MyItemsFile = file("DAT\CHAR\" & string(Winner2) & "-i.txt").read
   set MyName = Winner2
   InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   set nItem = item 3 of Prizess
   if nItem = VOID then exit
   if nItem = "" then exit
   set ItemNum = 1
   set MyItemsFile = file("DAT\CHAR\" & string(Winner3) & "-i.txt").read
   set MyName = Winner3
   InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

end




on AssGameAddScore(me, movie, group, user, fullmsg)

   set FilName = "DAT\ASSASSINS\MODE.txt"
   set AssSystem = file(FilName).read
   if AssSystem contains "OFF" then exit
   if AssSystem contains "PAUSE" then exit
   if AssSystem contains "STOP" then exit
   if AssSystem = VOID then exit
   if AssSystem = "" then exit

   set MyName = string(user.name)
   set Scre = integer(fullmsg.content)

   if AssSystem contains "NING" then set Scre = 10

   set FilName = "DAT\ASSASSINS\" & MyName & ".txt"
   set myScore = file(FilName).read
   if MyScore = VOID then set MyScore = 0
   set myScore = integer(myScore)


   set FilName = "DAT\ASSASSINS\ASSASSINLIST.txt"
   set TheListtt = file(FilName).read
   set SrchString = "*" & MyName & "*"

   if TheListtt contains SrchString then

    else

   set TheListtt= TheListtt & MyName & "*"
   file("DAT\ASSASSINS\ASSASSINLIST.txt").write(TheListtt)

  end if

   set xrun = "*** " & MyName & " just received " & Scre & " assassin points!"
   sendMovieMessage(movie, "@AllUsers", "sqa", xrun)

   set Scre = myScore + Scre

   file("DAT\ASSASSINS\" & MyName & ".txt").write(string(Scre))

   set FilName = "DAT\SETTINGS\assassinsscore.txt"
   set HighScoreList = file(FilName).read
   if HighScoreList = VOID then set HighScoreList = "||||||||||"

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

 file("DAT\SETTINGS\assassinsscore.txt").write(TheHighScoreList)

end




on AssLegend Winner1

   set MyName = Winner1
   set Scre = 1

   set FilName = "DAT\ASSASSINS\" & MyName & "X.txt"
   set myScore = file(FilName).read
   if MyScore = VOID then set MyScore = 0
   set myScore = integer(myScore)

   set Scre = myScore + Scre

   file("DAT\ASSASSINS\" & MyName & "X.txt").write(string(Scre))

   set FilName = "DAT\SETTINGS\permassassinsscore.txt"
   set HighScoreList = file(FilName).read
   if HighScoreList = VOID then set HighScoreList = "||||||||||"

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

 file("DAT\SETTINGS\permassassinsscore.txt").write(TheHighScoreList)

end
