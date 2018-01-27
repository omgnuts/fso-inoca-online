Global TodaysMonth

on RunBoss (me, movie, group, user, fullMsg)


end



on SaveHouse (me, movie, group, user, fullMsg)

  set HouseDat = String(fullmsg.content)
  set MyName = user.name
  set the itemdelimiter = "+"
  set CharMap = item 1 of HouseDat

  file("DAT\HOUSES\" & MyName & "-" & CharMap & ".txt").write(HouseDat)

  set HouseFile = file("DAT\HOUSES\houselist.txt").read

  set TheLine = "*" & MyName & "+" & CharMap & "+" & TodaysMonth & "|"
  set HouseFile = HouseFile & TheLine
  file("DAT\HOUSES\houselist.txt").write(HouseFile)
end



on UpdateLastLogin MyName


  set SearchString = "*" & myName & "+"
  set HouseFile = file("DAT\HOUSES\houselist.txt").read

  if HouseFile contains SearchString then set x = 1

  if x = 1 then

  set the itemdelimiter = "|"


  repeat with x = 1 to 500
   if item x of HouseFile contains SearchString then

    set ThisLine = item x of HouseFile
    set the itemdelimiter = "+"
    put TOdaysMonth into item 3 of ThisLine

    set the itemdelimiter = "|"
    put ThisLine into item x of HouseFile
   end if
  end repeat


  file("DAT\HOUSES\houselist.txt").write(HouseFile)

end if

 if Random(50) = 1 then RemoveOldHouses(HouseFile)

end


on RemoveOldHouses HouseFile


  set the itemdelimiter = "|"

  repeat with x = 1 to 500

   set the itemdelimiter = "|"

   if string(item x of HouseFile) <> "" then

    set the itemdelimiter = "|"
    set ThisLine = item x of HouseFile
    set the itemdelimiter = "+"
    set HisName = item 1 of ThisLine
    set HisMap = item 2 of ThisLine
    set HisLastLogin = item 3 of ThisLine
    if char 1 of HisName = "*" then delete char 1 of HisName

    if TodaysMonth = "1" then set AcceptableMonth1 = "1"
    if TodaysMonth = "1" then set AcceptableMonth2 = "12"

    if TodaysMonth = "2" then set AcceptableMonth1 = "2"
    if TodaysMonth = "2" then set AcceptableMonth2 = "1"

    if TodaysMonth = "3" then set AcceptableMonth1 = "3"
    if TodaysMonth = "3" then set AcceptableMonth2 = "2"

    if TodaysMonth = "4" then set AcceptableMonth1 = "4"
    if TodaysMonth = "4" then set AcceptableMonth2 = "3"

    if TodaysMonth = "5" then set AcceptableMonth1 = "5"
    if TodaysMonth = "5" then set AcceptableMonth2 = "4"

    if TodaysMonth = "6" then set AcceptableMonth1 = "5"
    if TodaysMonth = "6" then set AcceptableMonth2 = "6"

    if TodaysMonth = "7" then set AcceptableMonth1 = "7"
    if TodaysMonth = "7" then set AcceptableMonth2 = "6"

    if TodaysMonth = "8" then set AcceptableMonth1 = "8"
    if TodaysMonth = "8" then set AcceptableMonth2 = "7"

    if TodaysMonth = "9" then set AcceptableMonth1 = "9"
    if TodaysMonth = "9" then set AcceptableMonth2 = "8"

    if TodaysMonth = "10" then set AcceptableMonth1 = "10"
    if TodaysMonth = "10" then set AcceptableMonth2 = "9"

    if TodaysMonth = "11" then set AcceptableMonth1 = "11"
    if TodaysMonth = "11" then set AcceptableMonth2 = "10"

    if TodaysMonth = "12" then set AcceptableMonth1 = "12"
    if TodaysMonth = "12" then set AcceptableMonth2 = "11"

    set WeDontDelete = 2
    if HisLastLogin = AcceptableMonth1 then set WeDontDelete = 1
    if HisLastLogin = AcceptableMonth2 then set WeDontDelete = 1
    if WeDontDelete = 2 then RemoveHouse(x, HisMap, HisName, HouseFile)
   end if
  end repeat


end




on RemoveHouse x, HisMap, HisName, HouseFile

  set SearchString = "*" & HisName & "+"

  set nHouseFile = ""
  set the itemdelimiter = "|"


  repeat with Remm = 1 to 500

   if item Remm of HouseFile <> "" then

    if item Remm of HouseFile contains SearchString then

      set ThisLine = item Remm of HouseFile
      set the itemdelimiter = "+"
      set MyName = item 1 of ThisLine
      set MapName = item 2 of ThisLine
      if char 1 of MyName = "*" then delete char 1 of MyName
      HRemNOW(MyName, MapName)
      set the itemdelimiter = "|"

     else

      set nHouseFile = nHouseFile & item Remm of HouseFile
      set nHouseFile = nHouseFile & "|"

    end if
   end if

  end repeat

  file("DAT\HOUSES\houselist.txt").write(nHouseFile)
  set HouseFile = nHouseFile
end


on HRemNOW MyName, MapName

  set FileNm = MyName & "-" & MapName

  set mHouseFile = file("DAT\HOUSES\" & FileNm & ".txt").read
  set the itemdelimiter = "+"

  set Item1 = item 3 of mHouseFile
  set Item2 = item 2 of mHouseFile
  RemoveDisItem1(Item1, MapName)
  RemoveDisItem2(Item2, MapName)

  repeat with yeh = 4 to 24
    if item yeh of mHouseFile <> "" then
      set ThisOne = item yeh of mHouseFile
      set the itemdelimiter = "-"
      set OldTile = item 1 of ThisOne
      set NewTile = "G3"
      set TileX = integer(item 2 of ThisOne)
      set TileY = integer(item 3 of ThisOne)
      HouseTileRevert(MapName, OldTile, NewTile, TileX, TileY, MyName)
      set the itemdelimiter = "+"
    end if
  end repeat

end


on HouseTileRevert(MapName, OldTile, NewTile, TileX, TileY, MyName)

  set MapFile = file("DAT\MAPS\" & MapName & ".txt").read

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

  file("DAT\MAPS\" & MapName & ".txt").write(MapFile)

  end if
end



on RemoveDisItem1 Item1, MapName

   set NewItem =Item1

   set ItemList = file("DAT\ITEMS\" & MapName & "i.txt").read

   if ItemList contains NewItem then
     set the itemdelimiter = "|"

     repeat with itemIndexs = 1 to 20
        if NewItem = item itemIndexs of Itemlist then put "" into item itemIndexs of ItemList
     end repeat

     file("DAT\ITEMS\" & MapName & "i.txt").write(ItemList)
    else
   end if

end



on RemoveDisItem2 Item2, MapName

   set NewItem =Item2

   set ItemList = file("DAT\ITEMS\" & MapName & "i.txt").read

   if ItemList contains NewItem then
     set the itemdelimiter = "|"

     repeat with itemIndexs = 1 to 20
        if NewItem = item itemIndexs of Itemlist then put "" into item itemIndexs of ItemList
     end repeat

     file("DAT\ITEMS\" & MapName & "i.txt").write(ItemList)
    else
   end if

end
