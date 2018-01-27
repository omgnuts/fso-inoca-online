
on DidWeBooyaSomeWitchcraft(MyName, user, fullmsg, group, movie, VaultName, VaultInfo)

  set WitchCraftItem = "NOTHING"


 if VaultInfo contains "Chunk of Star" then
  if VaultInfo contains "Silver Crown" then
   set WitchCraftItem = "Gold Crown"
  end if
 end if

 if VaultInfo contains "Chunk of Star" then
  if VaultInfo contains "Axe" then
   set WitchCraftItem = "Gold Axe"
  end if
 end if

if VaultInfo contains "Lord's Staff" then
   if VaultInfo contains "Fireball Book" then
    set WitchCraftItem = "Fire Staff"
   end if
  end if

 if VaultInfo contains "Magic Shield Spell Book" then
   if VaultInfo contains "Small Shield" then
    set WitchCraftItem = "Magic Shield"
   end if
  end if

 if VaultInfo contains "Parry Book" then
   if VaultInfo contains "Ruby Ring" then
    set WitchCraftItem = "Ring of Quickness"
   end if
  end if

 if VaultInfo contains "Ninja Outfit" then
   if VaultInfo contains "Ring of Quickness" then
    set WitchCraftItem = "Royal Ninja Uniform"
   end if
  end if

 if VaultInfo contains "White Robe" then
   if VaultInfo contains "Magic Shield Spell Book" then
    set WitchCraftItem = "Wizard's Robe"
   end if
  end if

  if WitchCraftItem = "NOTHING" then
    sendMovieMessage(movie, user.name, "sqa", "The cauldron bubbles...but then fizzles out.")
    exit
  end if

  sendMovieMessage(movie, user.name, "sqa", "The cauldron bubbles...and with a huge puff of smoke, a new item appears inside.")

  set VaultInfo = WitchCraftItem & RETURN
  if VaultInfo contains "|" then exit
  file("DAT\VAULTS\" & VaultName).write(VaultInfo)

end



on SecureTradeInProgress(me, movie, group, user, fullmsg)

 set TheDat = string(fullmsg.content)
 set the itemdelimiter = "`"
 set Trader1 = item 1 of TheDat
 set Trader2 = item 2 of TheDat
 set Trader1Items = item 3 of TheDat
 set Trader2Items = item 4 of TheDat

 set Trader1ItemsFile = file("DAT\CHAR\" & string(Trader1) & "-i.txt").read
 set Trader2ItemsFile = file("DAT\CHAR\" & string(Trader2) & "-i.txt").read

 set the itemdelimiter = "|"
 set Trader1inv = item 2 of Trader1ItemsFile
 set Trader2inv = item 2 of Trader2ItemsFile
 set Trader1Gold = integer(item 1 of Trader1ItemsFile)
 set Trader2Gold = integer(item 1 of Trader2ItemsFile)
 set Trader1Eq = item 3 of Trader1ItemsFile
 set Trader2Eq = item 3 of Trader2ItemsFile

 repeat with x = 1 to 16
  set the itemdelimiter = "|"
  if item x of Trader1Items <> "" then
    set TheLine = item x of Trader1Items
    set the itemdelimiter = ":"
    set nItem = item 1 of TheLine
    set ItemNum = integer(item 2 of TheLine)
    if item 3 of TheLine <> "" then set SpotToAddAt = integer(item 3 of TheLine)
    set FileContains = FALSE
    ----------------------------------------------------------------
    if nItem = "Gold" then
      set Trader1Gold = Trader1Gold - ItemNum
      if Trader1Gold < 0 then set ErrorInTransaction = TRUE

    else   ------------ above is Gold, below is other crap

    set SearchStringItem = nItem & "-"
    if item SpotToAddAt of Trader1inv contains SearchStringItem then
      set FileContains = TRUE
    end if

    set the itemdelimiter = ":"
    if FileContains = FALSE then set ErrorInTransaction = TRUE
    set CurItem = item SpotToAddAt of Trader1inv
    set the itemdelimiter = "-"
    set CurAmount = integer(item 2 of CurItem)
    set ItemNum = CurAmount - integer(ItemNum)
    set TheLine = nItem & "-" & ItemNum
    if ItemNum = 0 then set TheLine = ""
    if ItemNum < 0 then set ErrorInTransaction = TRUE
    set the itemdelimiter = ":"
    put TheLine into item SpotToAddAt of Trader1inv
    set the itemdelimiter = "|"
    put Trader1inv into item 2 of Trader1ItemsFile
    set ItsBad = 0
    if Trader1inv contains "|-" then set ItsBad = 1
    if Trader1inv contains ":-" then set ItsBad = 1
    if Trader1inv contains "-:" then set ItsBad = 1
    if ItsBad = 1 then set ErrorInTransaction = TRUE

    end if
    ----------------------------------------------------------------
  end if
 end repeat



repeat with x = 1 to 16
  set the itemdelimiter = "|"
  if item x of Trader2Items <> "" then
    set TheLine = item x of Trader2Items
    set the itemdelimiter = ":"
    set nItem = item 1 of TheLine
    set ItemNum = integer(item 2 of TheLine)
    if item 3 of TheLine <> "" then set SpotToAddAt = integer(item 3 of TheLine)
    set FileContains = FALSE
    ----------------------------------------------------------------
    if nItem = "Gold" then
      set Trader2Gold = Trader2Gold - ItemNum
      if Trader2Gold < 0 then set ErrorInTransaction = TRUE

    else   ------------ above is Gold, below is other crap

    set SearchStringItem = nItem & "-"
    if item SpotToAddAt of Trader2inv contains SearchStringItem then
      set FileContains = TRUE
    end if

    set the itemdelimiter = ":"
    if FileContains = FALSE then set ErrorInTransaction = TRUE
    set CurItem = item SpotToAddAt of Trader2inv
    set the itemdelimiter = "-"
    set CurAmount = integer(item 2 of CurItem)
    set ItemNum = CurAmount - integer(ItemNum)
    set TheLine = nItem & "-" & ItemNum
    if ItemNum = 0 then set TheLine = ""
    if ItemNum < 0 then set ErrorInTransaction = TRUE
    set the itemdelimiter = ":"
    put TheLine into item SpotToAddAt of Trader2inv
    set the itemdelimiter = "|"
    put Trader2inv into item 2 of Trader2ItemsFile
    set ItsBad = 0
    if Trader2inv contains "|-" then set ItsBad = 1
    if Trader2inv contains ":-" then set ItsBad = 1
    if Trader2inv contains "-:" then set ItsBad = 1
    if ItsBad = 1 then set ErrorInTransaction = TRUE

    end if
    ----------------------------------------------------------------
  end if
 end repeat

-----------------------------------------------------------------------------------------------------------------------------------

repeat with xtt = 1 to 16
  set the itemdelimiter = "|"

 if item xtt of Trader2Items <> "" then

    set TheLine = item xtt of Trader2Items
    set the itemdelimiter = ":"
    set nItem = item 1 of TheLine
    set ItemNum = integer(item 2 of TheLine)

   if nItem = "Gold" then
     set Trader1Gold = Trader1Gold + ItemNum

   else

   set the itemdelimiter = ":"
   set FileContains = FALSE
   set SearchStringItem = nItem & "-"

   set SpotToAddAt = 0

   repeat with x = 1 to 15
     set ThisItt = item x of Trader1Inv
     set the itemdelimiter = "-"
     set SearchXString = item 1 of ThisItt
     set the itemdelimiter = ":"

     if SearchXString = nItem then
      set FileContains = TRUE
      set SpotToAddAt = x
      exit repeat
     end if
   end repeat

   if FileContains = FALSE then
     if item 15 of Trader1Inv = "" then set SpotToAddAt = 15
     if item 14 of Trader1Inv = "" then set SpotToAddAt = 14
     if item 13 of Trader1Inv = "" then set SpotToAddAt = 13
     if item 12 of Trader1Inv = "" then set SpotToAddAt = 12
     if item 11 of Trader1Inv = "" then set SpotToAddAt = 11
     if item 10 of Trader1Inv = "" then set SpotToAddAt = 10
     if item 9 of Trader1Inv = "" then set SpotToAddAt = 9
     if item 8 of Trader1Inv = "" then set SpotToAddAt = 8
     if item 7 of Trader1Inv = "" then set SpotToAddAt = 7
     if item 6 of Trader1Inv = "" then set SpotToAddAt = 6
     if item 5 of Trader1Inv = "" then set SpotToAddAt = 5
     if item 4 of Trader1Inv = "" then set SpotToAddAt = 4
     if item 3 of Trader1Inv = "" then set SpotToAddAt = 3
     if item 2 of Trader1Inv = "" then set SpotToAddAt = 2
     if item 1 of Trader1Inv = "" then set SpotToAddAt = 1
   end if


   if SpotToAddAt = 0 then set ErrorInTransaction = TRUE

   if FileContains = TRUE then
     set CurItem = item SpotToAddAt of Trader1Inv
     set the itemdelimiter = "-"
     set CurAmount = integer(item 2 of CurItem)
     set ItemNum = CurAmount + integer(ItemNum)
   end if

   set TheLine = nItem & "-" & ItemNum
   set the itemdelimiter = ":"
   put TheLine into item SpotToAddAt of Trader1Inv

   if Trader1Inv contains "|-" then set ErrorInTransaction = TRUE
   if Trader1Inv contains ":-" then set ErrorInTransaction = TRUE
   if Trader1Inv contains "-:" then set ErrorInTransaction = TRUE

  end if
 end if
end repeat
------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
repeat with xtt = 1 to 16
  set the itemdelimiter = "|"

 if item xtt of Trader1Items <> "" then

    set TheLine = item xtt of Trader1Items
    set the itemdelimiter = ":"
    set nItem = item 1 of TheLine
    set ItemNum = integer(item 2 of TheLine)

   if nItem = "Gold" then
     set Trader2Gold = Trader2Gold + ItemNum

   else

   set the itemdelimiter = ":"
   set FileContains = FALSE
   set SearchStringItem = nItem & "-"

   set SpotToAddAt = 0

   repeat with x = 1 to 15
     set ThisItt = item x of Trader2Inv
     set the itemdelimiter = "-"
     set SearchXString = item 1 of ThisItt
     set the itemdelimiter = ":"

     if SearchXString = nItem then
      set FileContains = TRUE
      set SpotToAddAt = x
      exit repeat
     end if
   end repeat

   if FileContains = FALSE then
     if item 15 of Trader2Inv = "" then set SpotToAddAt = 15
     if item 14 of Trader2Inv = "" then set SpotToAddAt = 14
     if item 13 of Trader2Inv = "" then set SpotToAddAt = 13
     if item 12 of Trader2Inv = "" then set SpotToAddAt = 12
     if item 11 of Trader2Inv = "" then set SpotToAddAt = 11
     if item 10 of Trader2Inv = "" then set SpotToAddAt = 10
     if item 9 of Trader2Inv = "" then set SpotToAddAt = 9
     if item 8 of Trader2Inv = "" then set SpotToAddAt = 8
     if item 7 of Trader2Inv = "" then set SpotToAddAt = 7
     if item 6 of Trader2Inv = "" then set SpotToAddAt = 6
     if item 5 of Trader2Inv = "" then set SpotToAddAt = 5
     if item 4 of Trader2Inv = "" then set SpotToAddAt = 4
     if item 3 of Trader2Inv = "" then set SpotToAddAt = 3
     if item 2 of Trader2Inv = "" then set SpotToAddAt = 2
     if item 1 of Trader2Inv = "" then set SpotToAddAt = 1
   end if


   if SpotToAddAt = 0 then set ErrorInTransaction = TRUE

   if FileContains = TRUE then
     set CurItem = item SpotToAddAt of Trader2Inv
     set the itemdelimiter = "-"
     set CurAmount = integer(item 2 of CurItem)
     set ItemNum = CurAmount + integer(ItemNum)
   end if

   set TheLine = nItem & "-" & ItemNum
   set the itemdelimiter = ":"
   put TheLine into item SpotToAddAt of Trader2Inv

   if Trader2Inv contains "|-" then set ErrorInTransaction = TRUE
   if Trader2Inv contains ":-" then set ErrorInTransaction = TRUE
   if Trader2Inv contains "-:" then set ErrorInTransaction = TRUE

  end if
 end if
end repeat
------------------------------------------------------------------------------------------------------------------------------------

 if ErrorInTransaction = TRUE then
   sendMovieMessage(movie, Trader1, "sqa", "There was a problem with the transaction. Try again!")
   sendMovieMessage(movie, Trader2, "sqa", "There was a problem with the transaction. Try again!")
   exit
 end if

 set Trader1LastFile = Trader1Gold & "|" & Trader1Inv & "|" & Trader1Eq
 set Trader2LastFile = Trader2Gold & "|" & Trader2Inv & "|" & Trader2Eq

 file("DAT\CHAR\" & string(Trader1 & "-i") & ".txt").write(Trader1LastFile )
 sendMovieMessage(movie, Trader1, "inx", Trader1LastFile)

 file("DAT\CHAR\" & string(Trader2 & "-i") & ".txt").write(Trader2LastFile )
 sendMovieMessage(movie, Trader2, "inx", Trader2LastFile)

end
