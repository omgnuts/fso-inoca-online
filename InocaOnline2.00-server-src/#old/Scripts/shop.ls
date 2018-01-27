Global QuestList, NewQuest, FactionPowers

on ShopCommand(me, movie, group, user, fullmsg)
  set FileDT = fullMsg.content
  set MyName = user.name
  set the itemdelimiter = ":"

  set Method = item 1 of FileDT

  if Method = "CreateNPC" then
    set MapName = item 2 of FileDT
    set NPCName = item 3 of FileDT

    set MOBDat = NPCName & ":128:10:4||||+" & NPCName & ":128:10:4||||"
    file("DAT\MOBS\" & MapName & ".txt").write(MOBDat)

    set NPCScript = "OWN|" & MyName & RETURN
    set NPCScript = NPCScript & "BIO|Name: " & NPCName & RETURN
    set NPCScript = NPCScript & "BIO|Class: Shopkeeper" & RETURN
    set NPCScript = NPCScript & "PRO|" & RETURN
    set NPCScript = NPCScript & "GLD|0" & RETURN
    set NPCScript = NPCScript & "SEL|Apple:2:0" & RETURN
    set NPCScript = NPCScript & "BUY|Apple:1"

    file("DAT\NPC\" & NPCName & ".txt").write(NPCScript )
  end if

-----------------------------------------------------------------------------------------
  if Method = "Header" then
    set MapDT = fullMsg.content
    set MyName = string(user.name)
    set TheMap = item 2 of MapDT
    set Header = item 3 of MapDT
    set FilName = "DAT\MAPS\" & TheMap & ".txt"
    set MapFile = file(FilName).read
    set the itemdelimiter = "#"
    if item 16 of MapFile contains MyName then
       put Header into item 17 of MapFile
       file("DAT\MAPS\" & TheMap & ".txt").write(MapFile)
       set TheText = "Your shop title has been updated."
       sendMovieMessage(movie, user.name, "sqa",  TheText)
       exit
    end if

    set TheText = "You can't change the title of this area!"
    sendMovieMessage(movie, user.name, "sqa",  TheText)
  end if


  if Method = "Profile" then
    set the itemdelimiter = ":"
    set NPCDat = fullMsg.content
    set NPCName = item 2 of NPCDat
    set Profile = item 3 of NPCDat
    set MyName = user.name
    set FilName = "DAT\NPC\" & NPCName & ".txt"
    set NPCFile = file(FilName).read

    if NPCFile contains "OWN|" & MyName then

      else

      exit
    end if


    repeat with x = 1 to 30
      if line x of NPCFile contains "PRO|" then
        set NewLine = "PRO|" & string(Profile)
        put NewLine into line x of NPCFile
      end if
    end repeat

    set TheText = NPCName & "'s profile has been updated."
    sendMovieMessage(movie, user.name, "sqa",  TheText)
    file("DAT\NPC\" & NPCName & ".txt").write(NPCFile)
  end if



  if Method = "Inventory" then
    set the itemdelimiter = ":"
    set NPCDat = fullMsg.content
    set NPCName = item 2 of NPCDat
    set MyName = user.name

    set FilName = "DAT\NPC\" & NPCName & ".txt"
    set NPCFile = file(FilName).read

    if NPCFile contains "OWN|" & MyName then

      else

      exit
    end if

   repeat with x = 1 to 30
      if line x of NPCFile contains "GLD|" then
        set the itemdelimiter = "|"
        set MyGold = integer(item 2 of line x of NPCFile )
       set TheText = NPCName & " says " & QUOTE & "I have " & MyGold & " gold in the register..."
       sendMovieMessage(movie, user.name, "sqa",  TheText)
      end if
   end repeat

   set InvenList = ""

   repeat with x = 1 to 30
      if line x of NPCFile contains "SEL|" then
        set the itemdelimiter = "|"
        set CurItem = item 2 of line x of NPCFile
        set the itemdelimiter = ":"
        set ItemName = item 1 of CurItem
        set InvenAmount = item 3 of CurItem
        if InvenAmount <> 1 then set InvenList = InvenList & NPCName & " says " & QUOTE & "I have " & InvenAmount & " " & ItemName & "s." & QUOTE
        if InvenAmount = 1 then set InvenList = InvenList & NPCName & " says " & QUOTE & "I have " & InvenAmount & " " & ItemName & "." & QUOTE
        set InvenList = InvenList & RETURN
      end if
   end repeat

   if InvenList <> "" then sendMovieMessage(movie, user.name, "aqs",  InvenList)
  end if
------------------------------------------------------------------------------------------------
  if Method = "Register" then
   set MyName =  user.name
   set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read

   set NPCDat = fullMsg.content
   set the itemdelimiter = ":"
   set NPCName = item 2 of NPCDat
   set NewGold = integer(item 3 of NPCDat)
   set the itemdelimiter = "|"
   set myCharGold = integer(item 1 of MyitemsFile)
   set MycharGold = MyCharGold + integer(NewGold)
   put MycharGold into item 1 of MyItemsFile

   set FilName = "DAT\NPC\" & NPCName & ".txt"
   set LList = file(FilName).read

   if LList contains "OWN|" & MyName then

     else

     set TheText = NPCName & " says " & QUOTE & "I don't think my boss would like you trying to steal from us." & QUOTE
     sendMovieMessage(movie, user.name, "sqa",  TheText)
     exit
   end if

   repeat with x = 1 to 30
      if line x of LList contains "GLD|" then
        set the itemdelimiter = "|"
        set MyGold = integer(item 2 of line x of LList)
        set MyGold = MyGold - NewGold
        set GoldToAddLine = "GLD|" & string(MyGold)
        put GoldToAddLine into line x of LList
      end if
   end repeat

   if MyGold < 0 then
     set TheText = NPCName & " says " & QUOTE & "I don't have that much gold!" & QUOTE
     sendMovieMessage(movie, user.name, "sqa",  TheText)
     exit
   end if

   file("DAT\NPC\" & NPCName & ".txt").write(LList)
   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)

   set TheText = NPCName & " says " & QUOTE & "Here's the gold." & QUOTE
   sendMovieMessage(movie, user.name, "sqa",  TheText)

  end if
--------------------------------------------------------------------------------------

  if Method = "RemoveItem" then
    set NPCName = item 2 of FileDT
    set ItemName = item 3 of FileDT

    set SearchString = "SEL|" & ItemName

    set NPCDat = file("DAT\NPC\" & NPCName & ".txt").read

    if NPCDat contains "OWN|" & MyName then

    else

      set TheText = NPCName & " is not your employee!"
      sendMovieMessage(movie, user.name, "sqa",  TheText)
      exit
    end if

    if NPCDat contains SearchString then

      else

      set TheText = NPCName & " says " & QUOTE & "I'm not currently selling that item, boss!" & QUOTE
      sendMovieMessage(movie, user.name, "sqa",  TheText)
      exit
    end if

   ------------------- ********************

    set NewNPCFile = ""
    set InvAmount = 0

    repeat with x = 1 to 30
       if line x of NPCDat <> "" then
        if line x of NPCDat contains ItemName then

          if line x of NPCDat contains "SEL" then set InvAmount = item 3 of line x of NPCDat

            if InvAmount > 0 then
              set TheText = NPCName & " says " & QUOTE & "We have that in stock, you need to buy it all back first." & QUOTE
              sendMovieMessage(movie, user.name, "sqa",  TheText)
              exit
            end if

         else
          set NewNPCFile = NewNPCFile & line x of NPCDat & RETURN
         end if
       end if
    end repeat

    file("DAT\NPC\" & NPCName & ".txt").write(NewNPCFile)

    set TheText = NPCName & " says " & QUOTE & "OK boss, I removed the item!" & QUOTE
    sendMovieMessage(movie, user.name, "sqa",  TheText)


   ------------------- *********************
  end if





  if Method = "SetPrices" then
    set NPCName = item 2 of FileDT
    set ItemName = item 3 of FileDT
    set SellPrice = item 4 of FileDT
    set BuyPrice = item 5 of FileDT

    set SearchString = "SEL|" & ItemName

    set NPCDat = file("DAT\NPC\" & NPCName & ".txt").read

    if NPCDat contains "OWN|" & MyName then

    else
      set TheText = NPCName & " is not your employee!"
      sendMovieMessage(movie, user.name, "sqa",  TheText)
      exit
    end if

    set NumberOfSales = 0

    repeat with x = 1 to 30
      if line x of NPCDat contains "SEL|" then set NumberOfSales = NumberOfSales + 1
    end repeat


    if NPCDat contains SearchString then

      else

      if NumberOfSales > 9 then
       set TheText = NPCName & " is currently selling the maximum number of items allowed!"
       sendMovieMessage(movie, user.name, "sqa",  TheText)
       exit
      end if
    end if


    set NewNPCFile = ""
    set InvAmount = 0

    repeat with x = 1 to 30
       if line x of NPCDat <> "" then
        if line x of NPCDat contains ItemName then

          if line x of NPCDat contains "SEL" then set InvAmount = item 3 of line x of NPCDat

         else
          set NewNPCFile = NewNPCFile & line x of NPCDat & RETURN
         end if
       end if
    end repeat

    set NewNPCFile = NewNPCFile & "SEL|" & ItemName & ":" & SellPrice & ":" & InvAmount & RETURN
    set NewNPCFile = NewNPCFile & "BUY|" & ItemName & ":" & BuyPrice & RETURN

    file("DAT\NPC\" & NPCName & ".txt").write(NewNPCFile)

    set TheText = NPCName & " says " & QUOTE & "OK boss, I've added the item!" & QUOTE
    sendMovieMessage(movie, user.name, "sqa",  TheText)

  end if

end
