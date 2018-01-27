on MapTileChange(me, movie, group, user, fullmsg)
  set FileDT = string(fullmsg.content)
  set MyName = user.name

  set the itemdelimiter = "`"
  set MapName = item 1 of FileDT
  set MapGoods = item 2 of FileDT

  set MapFile = file("DAT\MAPS\" & MapName).read

  set the itemdelimiter = ":"
  set OldTile = item 1 of MapGoods
  set NewTile = item 2 of MapGoods
  set TileX = integer(item 3 of MapGoods)
  set TileY = integer(item 4 of MapGoods)

  set the itemdelimiter = "#"

  if TileY = 1 then
     if word TileX of item 19 of MapFile <> OldTile then exit
  end if

  if TileY = 2 then
     if word TileX of item 20 of MapFile <> OldTile then exit
  end if

  if TileY = 3 then
     if word TileX of item 21 of MapFile <> OldTile then exit
  end if

  if TileY = 4 then
     if word TileX of item 22 of MapFile <> OldTile then exit
  end if

  if TileY = 5 then
     if word TileX of item 23 of MapFile <> OldTile then exit
  end if

  if TileY = 6 then
     if word TileX of item 24 of MapFile <> OldTile then exit
  end if

  if TileY = 7 then
     if word TileX of item 25 of MapFile <> OldTile then exit
  end if

  if TileY = 8 then
     if word TileX of item 26 of MapFile <> OldTile then exit
  end if

  if TileY = 9 then
     if word TileX of item 27 of MapFile <> OldTile then exit
  end if

  if TileY = 10 then
     if word TileX of item 49 of MapFile <> OldTile then exit
  end if

  if TileY = 11 then
     if word TileX of item 50 of MapFile <> OldTile then exit
  end if

  if TileY = 12 then
     if word TileX of item 51 of MapFile <> OldTile then exit
  end if

  if TileY = 1 then put NewTile into word TileX of item 19 of MapFile
  if TileY = 2 then put NewTile into word TileX of item 20 of MapFile
  if TileY = 3 then put NewTile into word TileX of item 21 of MapFile
  if TileY = 4 then put NewTile into word TileX of item 22 of MapFile
  if TileY = 5 then put NewTile into word TileX of item 23 of MapFile
  if TileY = 6 then put NewTile into word TileX of item 24 of MapFile
  if TileY = 7 then put NewTile into word TileX of item 25 of MapFile
  if TileY = 8 then put NewTile into word TileX of item 26 of MapFile
  if TileY = 9 then put NewTile into word TileX of item 27 of MapFile
  if TileY = 10 then put NewTile into word TileX of item 49 of MapFile
  if TileY = 11 then put NewTile into word TileX of item 50 of MapFile
  if TileY = 12 then put NewTile into word TileX of item 51 of MapFile

  file("DAT\MAPS\" & MapName).write(MapFile)

  end if
end






on BuildLand(me, movie, group, user, fullmsg)
  set FileDT = string(fullmsg.content)
  set MyName = user.name

  set the itemdelimiter = "`"
  set MapName = item 1 of FileDT
  set MapGoods = item 2 of FileDT

  set MapFile = file("DAT\MAPS\" & MapName).read
  set the itemdelimiter = "."
  set RawMapName = item 1 of MapName
  set NMapName = RawMapName & "o.txt"
  set OwnerMapFile = file("DAT\MAPS\" & NMapName).read

  set the itemdelimiter = ":"
  set OldTile = item 1 of MapGoods
  set NewTile = item 2 of MapGoods
  set TileX = integer(item 3 of MapGoods)
  set TileY = integer(item 4 of MapGoods)
  set WhichLayer = integer(item 5 of MapGoods)

  set the itemdelimiter = "#"

  if word TileX of item TileY of OwnerMapFile <> MyName then
    set TalkDat = "*** This land does not belong to you, you cannot build here!"
    sendMovieMessage(movie, user.name, "sqa",  TalkDat)
  end if

  if WhichLayer = 2 then

  if TileY = 1 then
     if word TileX of item 19 of MapFile <> OldTile then exit
  end if

  if TileY = 2 then
     if word TileX of item 20 of MapFile <> OldTile then exit
  end if

  if TileY = 3 then
     if word TileX of item 21 of MapFile <> OldTile then exit
  end if

  if TileY = 4 then
     if word TileX of item 22 of MapFile <> OldTile then exit
  end if

  if TileY = 5 then
     if word TileX of item 23 of MapFile <> OldTile then exit
  end if

  if TileY = 6 then
     if word TileX of item 24 of MapFile <> OldTile then exit
  end if

  if TileY = 7 then
     if word TileX of item 25 of MapFile <> OldTile then exit
  end if

  if TileY = 8 then
     if word TileX of item 26 of MapFile <> OldTile then exit
  end if

  if TileY = 9 then
     if word TileX of item 27 of MapFile <> OldTile then exit
  end if

  if TileY = 10 then
     if word TileX of item 49 of MapFile <> OldTile then exit
  end if

  if TileY = 11 then
     if word TileX of item 50 of MapFile <> OldTile then exit
  end if

  if TileY = 12 then
     if word TileX of item 51 of MapFile <> OldTile then exit
  end if

  if TileY = 1 then put NewTile into word TileX of item 19 of MapFile
  if TileY = 2 then put NewTile into word TileX of item 20 of MapFile
  if TileY = 3 then put NewTile into word TileX of item 21 of MapFile
  if TileY = 4 then put NewTile into word TileX of item 22 of MapFile
  if TileY = 5 then put NewTile into word TileX of item 23 of MapFile
  if TileY = 6 then put NewTile into word TileX of item 24 of MapFile
  if TileY = 7 then put NewTile into word TileX of item 25 of MapFile
  if TileY = 8 then put NewTile into word TileX of item 26 of MapFile
  if TileY = 9 then put NewTile into word TileX of item 27 of MapFile
  if TileY = 10 then put NewTile into word TileX of item 49 of MapFile
  if TileY = 11 then put NewTile into word TileX of item 50 of MapFile
  if TileY = 12 then put NewTile into word TileX of item 51 of MapFile

  end if




 if WhichLayer = 1 then

  if TileY = 1 then
     if word TileX of item 1 of MapFile <> OldTile then exit
  end if

  if TileY = 2 then
     if word TileX of item 2 of MapFile <> OldTile then exit
  end if

  if TileY = 3 then
     if word TileX of item 3 of MapFile <> OldTile then exit
  end if

  if TileY = 4 then
     if word TileX of item 4 of MapFile <> OldTile then exit
  end if

  if TileY = 5 then
     if word TileX of item 5 of MapFile <> OldTile then exit
  end if

  if TileY = 6 then
     if word TileX of item 6 of MapFile <> OldTile then exit
  end if

  if TileY = 7 then
     if word TileX of item 7 of MapFile <> OldTile then exit
  end if

  if TileY = 8 then
     if word TileX of item 8 of MapFile <> OldTile then exit
  end if

  if TileY = 9 then
     if word TileX of item 9 of MapFile <> OldTile then exit
  end if

  if TileY = 10 then
     if word TileX of item 46 of MapFile <> OldTile then exit
  end if

  if TileY = 11 then
     if word TileX of item 47 of MapFile <> OldTile then exit
  end if

  if TileY = 12 then
     if word TileX of item 48 of MapFile <> OldTile then exit
  end if

  if TileY = 1 then put NewTile into word TileX of item 1 of MapFile
  if TileY = 2 then put NewTile into word TileX of item 2 of MapFile
  if TileY = 3 then put NewTile into word TileX of item 3 of MapFile
  if TileY = 4 then put NewTile into word TileX of item 4 of MapFile
  if TileY = 5 then put NewTile into word TileX of item 5 of MapFile
  if TileY = 6 then put NewTile into word TileX of item 6 of MapFile
  if TileY = 7 then put NewTile into word TileX of item 7 of MapFile
  if TileY = 8 then put NewTile into word TileX of item 8 of MapFile
  if TileY = 9 then put NewTile into word TileX of item 9 of MapFile
  if TileY = 10 then put NewTile into word TileX of item 46 of MapFile
  if TileY = 11 then put NewTile into word TileX of item 47 of MapFile
  if TileY = 12 then put NewTile into word TileX of item 48 of MapFile

  end if


  file("DAT\MAPS\" & MapName).write(MapFile)

  end if
end



on BuyLand(me, movie, group, user, fullmsg)

  set FileDT = string(fullmsg.content)
  set MyName = user.name

  set the itemdelimiter = "`"
  set MapName = item 1 of FileDT
  set MapGoods = item 2 of FileDT

  set MapFile = file("DAT\MAPS\" & MapName).read
  set the itemdelimiter = "."
  set RawMapName = item 1 of MapName
  set NMapName = RawMapName & "o.txt"
  set OwnerMapFile = file("DAT\MAPS\" & NMapName).read

  set the itemdelimiter = ":"
  set TileX = item 1 of MapGoods
  set TileY = item 2 of MapGoods

  set the itemdelimiter = "#"

  if word TileX of item TileY of OwnerMapFile <> "AVAILABLE" then
    set TalkDat = "*** This land is not for sale!"
    sendMovieMessage(movie, user.name, "sqa",  TalkDat)
    exit
  end if


   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
   set the itemdelimiter = "|"
   set MyGold = integer(item 1 of MyItemsFile)

   set MyGold = MyGold - 500

   if MyGold < 0 then
     set TalkDat = "*** You cannot afford this land!"
     sendMovieMessage(movie, user.name, "sqa",  TalkDat)
     exit
   end if

   set the itemdelimiter = "|"
   put MyGold into item 1 of MyItemsFile
   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)

   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

   put MyName into word TileX of item TileY of OwnerMapFile
   file("DAT\MAPS\" & NMapName).write(OwnerMapFile)


   set OldTile = "U6"
   set NewTile = "G3"

 if TileY = 1 then
     if word TileX of item 19 of MapFile <> OldTile then exit
  end if

  if TileY = 2 then
     if word TileX of item 20 of MapFile <> OldTile then exit
  end if

  if TileY = 3 then
     if word TileX of item 21 of MapFile <> OldTile then exit
  end if

  if TileY = 4 then
     if word TileX of item 22 of MapFile <> OldTile then exit
  end if

  if TileY = 5 then
     if word TileX of item 23 of MapFile <> OldTile then exit
  end if

  if TileY = 6 then
     if word TileX of item 24 of MapFile <> OldTile then exit
  end if

  if TileY = 7 then
     if word TileX of item 25 of MapFile <> OldTile then exit
  end if

  if TileY = 8 then
     if word TileX of item 26 of MapFile <> OldTile then exit
  end if

  if TileY = 9 then
     if word TileX of item 27 of MapFile <> OldTile then exit
  end if

  if TileY = 10 then
     if word TileX of item 49 of MapFile <> OldTile then exit
  end if

  if TileY = 11 then
     if word TileX of item 50 of MapFile <> OldTile then exit
  end if

  if TileY = 12 then
     if word TileX of item 51 of MapFile <> OldTile then exit
  end if

  if TileY = 1 then put NewTile into word TileX of item 19 of MapFile
  if TileY = 2 then put NewTile into word TileX of item 20 of MapFile
  if TileY = 3 then put NewTile into word TileX of item 21 of MapFile
  if TileY = 4 then put NewTile into word TileX of item 22 of MapFile
  if TileY = 5 then put NewTile into word TileX of item 23 of MapFile
  if TileY = 6 then put NewTile into word TileX of item 24 of MapFile
  if TileY = 7 then put NewTile into word TileX of item 25 of MapFile
  if TileY = 8 then put NewTile into word TileX of item 26 of MapFile
  if TileY = 9 then put NewTile into word TileX of item 27 of MapFile
  if TileY = 10 then put NewTile into word TileX of item 49 of MapFile
  if TileY = 11 then put NewTile into word TileX of item 50 of MapFile
  if TileY = 12 then put NewTile into word TileX of item 51 of MapFile

end
