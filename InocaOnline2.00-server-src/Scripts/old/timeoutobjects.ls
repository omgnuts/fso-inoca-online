Global FactionPowers, TreasureList, CharList, LastPhoto, PhotoName, PhotoList, TodaysMonth, TimeOutGo
Global gDispatcher

on InvAdd(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

   if nItem = "Crate" then set nItem = "Crate#" & random(999999)
   if nItem = "Cabinet" then set nItem = "Cabinet#" & random(999999)
   if nItem = "Wind Cabinet" then set nItem = "Wind Cabinet#" & random(999999)

   if nItem contains " Gold" then
     set MyItemsFile = file("DAT\CHAR\" & string(MyName) & "-i.txt").read
     set the itemdelimiter = "|"
     set MyGold = integer(item 1 of MyItemsFile)
     set the itemdelimiter = " "
     set GoldAmount = integer(item 1 of nItem)
     set MyGold = MyGold + GoldAmount
     set the itemdelimiter = "|"
     put MyGold into item 1 of MyItemsFile
     file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
     sendMovieMessage(movie, MyName, "inx", MyItemsFile)
     exit
    end if


   set the itemdelimiter = "|"
   set MyInv = string(item 2 of MyItemsFile)
   set the itemdelimiter = ":"
   set FileContains = FALSE
   set SearchStringItem = nItem & "-"

   set SpotToAddAt = 0

   repeat with x = 1 to 15
     set ThisItt = item x of MyInv
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
     if item 15 of MyInv = "" then set SpotToAddAt = 15
     if item 14 of MyInv = "" then set SpotToAddAt = 14
     if item 13 of MyInv = "" then set SpotToAddAt = 13
     if item 12 of MyInv = "" then set SpotToAddAt = 12
     if item 11 of MyInv = "" then set SpotToAddAt = 11
     if item 10 of MyInv = "" then set SpotToAddAt = 10
     if item 9 of MyInv = "" then set SpotToAddAt = 9
     if item 8 of MyInv = "" then set SpotToAddAt = 8
     if item 7 of MyInv = "" then set SpotToAddAt = 7
     if item 6 of MyInv = "" then set SpotToAddAt = 6
     if item 5 of MyInv = "" then set SpotToAddAt = 5
     if item 4 of MyInv = "" then set SpotToAddAt = 4
     if item 3 of MyInv = "" then set SpotToAddAt = 3
     if item 2 of MyInv = "" then set SpotToAddAt = 2
     if item 1 of MyInv = "" then set SpotToAddAt = 1
   end if


   if SpotToAddAt = 0 then
     sendMovieMessage(movie, MyName, "inx", MyItemsFile)
     exit
   end if

   if FileContains = TRUE then
     set CurItem = item SpotToAddAt of MyInv
     set the itemdelimiter = "-"
     set CurAmount = integer(item 2 of CurItem)
     set ItemNum = CurAmount + integer(ItemNum)
   end if

   set TheLine = nItem & "-" & ItemNum
   set the itemdelimiter = ":"
   put TheLine into item SpotToAddAt of MyInv
   set the itemdelimiter = "|"
   put MyInv into item 2 of MyItemsFile

   set ItsBad = 0
   if MyInv contains "|-" then set ItsBad = 1
   if MyInv contains ":-" then set ItsBad = 1
   if MyInv contains "-:" then set ItsBad = 1

   if ItsBad = 1 then
     sendMovieMessage(movie, MyName, "sqa",  "!@@ Error!")
     exit
   end if

   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, MyName, "inx", MyItemsFile)
end

-----------------------------------------------------------------------------------------------

on InvDel(MyName, MyItemsFile, nItem, ItemNum, user, fullmsg, group, movie)

 set the itemdelimiter = "|"
   set MyInv = string(item 2 of MyItemsFile)
   set the itemdelimiter = ":"

   set SearchStringItem = nItem & "-"

   repeat with x = 1 to 15
     if item x of MyInv contains SearchStringItem then
      set FileContains = TRUE
      set SpotToAddAt = x
      exit repeat
     end if
   end repeat

   if FileContains = FALSE then exit

   set CurItem = item SpotToAddAt of MyInv
   set the itemdelimiter = "-"
   set CurAmount = integer(item 2 of CurItem)
   set ItemNum = CurAmount - integer(ItemNum)

   set TheLine = nItem & "-" & ItemNum
   if ItemNum = 0 then set TheLine = ""
   if ItemNum < 0 then exit
   set the itemdelimiter = ":"
   put TheLine into item SpotToAddAt of MyInv
   set the itemdelimiter = "|"
   put MyInv into item 2 of MyItemsFile

   set ItsBad = 0
   if MyInv contains "|-" then set ItsBad = 1
   if MyInv contains ":-" then set ItsBad = 1
   if MyInv contains "-:" then set ItsBad = 1

   if ItsBad = 1 then
     sendMovieMessage(movie, user.name, "sqa",  "!@@ Error!")
     exit
   end if

   file("DAT\CHAR\" & string(MyName & "-i") & ".txt").write(MyItemsFile)
   sendMovieMessage(movie, user.name, "inx", MyItemsFile)
end



on Grabitems (me, movie, group, user, fullmsg)

	set FileDT = fullMsg.content

   set the itemdelimiter = "`"
   set FilName = item 1 of FileDT
   set NewItem = item 2 of FileDT
   set ItemList = file("DAT\ITEMS\" & FilName).read

   if ItemList contains NewItem then
     set the itemdelimiter = "|"

		repeat with n = 1 to 20
			if NewItem = item n of Itemlist then
				put "" into item n of ItemList
				exit repeat
			end if
		end repeat

		set the itemdelimiter = ":"
		set ItemToAdd = item 1 of NewItem
		set NumToAdd = 1

		if (NewItem contains " Boat") or (NewItem contains " Battleship") or (NewItem contains " Airship") then
			sendMovieMessage(movie, user.name, "YouGotItem", NewItem)
			file("DAT\ITEMS\" & FilName).write(ItemList)
			exit
		end if

   	if ItemToAdd contains " Gold" then
   		set the itemdelimiter = " "
   		set NumToAdd = integer(item 1 of ItemToAdd)
   		set ItemToAdd = "Gold"
   	end if

		if ItemToAdd contains " Crystals" then
		  set the itemdelimiter = " "
		  set NumToAdd = integer(item 1 of ItemToAdd)
		  set ItemToAdd = item 2 of ItemToAdd & " " & item 3 of ItemToAdd
		end if

		if ItemToAdd = "Blue Flag" or ItemToAdd = "Red Flag" then
			if equipFlag(user, movie, ItemToAdd) then
				file("DAT\ITEMS\" & FilName).write(ItemList)
				sendMovieMessage(movie, user.name, "YouGotItem", NewItem)
			end if
			exit
		end if

		if AddSaveItemX (ItemToAdd, NumToAdd, User.Name, movie) then
			sendMovieMessage(movie, user.name, "YouGotItem", NewItem)
			file("DAT\ITEMS\" & FilName).write(ItemList)
		else
		  set talkDat = "Please check that you have space in your inventory"
		  sendMovieMessage(movie, user.name, "sqa",  talkDat)
		end if
   else
     	sendMovieMessage(movie, user.name, "BadItem", NewItem, 0)
   end if
end



-------------------------------------------------------------------
--// Buying from NPC
-------------------------------------------------------------------

on NPCBuy (me, movie, group, user, fullmsg)


	set NPCDat = fullMsg.content
   set the itemdelimiter = ":"
   set NPCName = item 1 of NPCDat

   set ItemToSell = item 2 of NPCDat
   set ItemPrice = integer(item 3 of NPCDat)
   set AmountIWant = integer(item 4 of NPCDat)

	set ItemToAdd = ItemToSell --// ItemToAdd differs from ItemToSell in the case of containers

	if (ItemToAdd = "Crate#") or (ItemToAdd = "Cabinet#") or (ItemToAdd = "Wind Cabinet#") then
   	set ItemToAdd = getCabbyCounter(ItemToAdd)
   	set AmountIWant = 1
   	--// only allowed to buy one wind cabby a time as it no longer stacks
   end if

   set TotalCost = ItemPrice * AmountIWant

   set FilName = "DAT\NPC\" & NPCName
   set LList = file(FilName).read

   set LineToSearchFor = "SEL|" & ItemToSell & ":"
   if LList contains LineToSearchFor then
		set n = 1
		repeat while line n of LList <> ""
			if line n of LList contains LineToSearchFor then
			  set the itemdelimiter = "|"
			  set TheGoods = item 2 of line n of LList

			  set the itemdelimiter = ":"
			  set ItemName = item 1 of TheGoods
			  set ItemPrice = integer(item 2 of TheGoods)
			  set ItemAmount = integer(item 3 of TheGoods)

			  if AmountIWant > ItemAMount then
				  sendMovieMessage(movie, user.name, "NEI", AmountIWant)
				  exit
			  end if

			  set ItemAmount = ItemAmount - AmountIWant
			  set NewLine = "SEL|" & ItemName & ":" & ItemPrice & ":" & ItemAmount
			  put NewLine into line n of LList

			end if
			if line n of LList contains "GLD|" then
			  set the itemdelimiter = "|"
			  set NPCGold = integer(item 2 of line n of LList)
			  set NPCGold = "GLD|" & string(NPCGold + TotalCost)
			  put NPCGold into line n of LList
			end if

			set n = n + 1
		end repeat

		if ExchSaveItemX (ItemToAdd, AmountIWant, "Gold", TotalCost, User.Name, movie) then
			file("DAT\NPC\" & NPCName).write(LList)
			sendMovieMessage(movie, user.name, "YouGotItem", ItemToSell)
		else
		  	set DTTT = "You do not have enough gold or inventory space."
        	sendMovieMessage(movie, user.name, "sqa", DTTT)
		end if
 	else
     	sendMovieMessage(movie, user.name, "NEI", AmountIWant)
     	exit
   end if

end






-------------------------------------------------------------------
--// Selling to NPC
-------------------------------------------------------------------

on NPCSell (me, movie, group, user, fullmsg)

  set NPCDat = fullMsg.content
   set the itemdelimiter = ":"
   set NPCName = item 1 of NPCDat
   set ItemToSell = item 2 of NPCDat
   set ItemPrice = integer(item 3 of NPCDat)
   set AmountISell = integer(item 4 of NPCDat)


   set ItemToGo = ItemToSell
   if (ItemToGo = "Cabinet") or (ItemToGo = "Wind Cabinet") or (ItemToGo = "Crate") then
   	set ItemToGo = ItemToGo & "#"
   end if

	if (ItemToGo = "Crate#") or (ItemToGo = "Cabinet#") or (ItemToGo = "Wind Cabinet#") then
   	set AmountISell = 1
   	--// only allowed to sell one wind cabby a time as it no longer stacks
   end if

   set TotalSales = ItemPrice * AmountISell

   set FilName = "DAT\NPC\" & NPCName
   set LList = file(FilName).read
   set LineToSearchFor  = "BUY|" & ItemToSell & ":"

   if LList contains LineToSearchFor then  --"// Just quick check to see if the NPC will buy.

   	set LineToSearchFor  = "SEL|" & ItemToSell & ":"
   	if LList contains LineToSearchFor then
			set n = 1
			repeat while line n of LList <> ""

				if line n of LList contains LineToSearchFor then
				  set the itemdelimiter = "|"
				  set TheGoods = item 2 of line n of LList

				  set the itemdelimiter = ":"
				  set ItemName = item 1 of TheGoods
				  set ItemPrice = integer(item 2 of TheGoods)
				  set ItemAmount = integer(item 3 of TheGoods)

				  set ItemAmount = ItemAmount + AmountISell
				  set NewLine = "SEL|" & ItemName & ":" & ItemPrice & ":" & ItemAmount
				  put NewLine into line n of LList
				end if

				if line n of LList contains "GLD|" then
				  set the itemdelimiter = "|"
				  set NPCGold = integer(item 2 of line n of LList)
				  set NPCGold = NPCGold - TotalSales
				  if NPCGold < 0 then
					 sendMovieMessage(movie, user.name, "BadSelling", "x")
					 exit
				  end if
				  set NPCGold = "GLD|" & string(NPCGold)
				  put NPCGold into line n of LList
				end if

				set n = n + 1
			end repeat

		else

			set n = 1
			repeat while line n of LList <> ""

				if line n of LList contains "GLD|" then
				  set the itemdelimiter = "|"
				  set NPCGold = integer(item 2 of line n of LList)
				  set NPCGold = NPCGold - TotalSales
				  if NPCGold < 0 then
					 sendMovieMessage(movie, user.name, "BadSelling", "x")
					 exit
				  end if
				  set NPCGold = "GLD|" & string(NPCGold)
				  put NPCGold into line n of LList
				end if

				set n = n + 1
			end repeat

		end if

		if ExchSaveItemX ("Gold", TotalSales, ItemToGo, AmountISell, User.name, movie) then
			file("DAT\NPC\" & NPCName).write(LList)
			sendMovieMessage(movie, user.name, "SoldSuccessfully", "x")
		else
			set DTTT = "You do not have the item to sell."
			sendMovieMessage(movie, user.name, "sqa", DTTT)
		end if

   else
   	sendMovieMessage(movie, user.name, "errsel", "x")
   	exit
   end if
end



on JusticarReset TodaysMonth

  set LastMonth = file("DAT\SETTINGS\month.txt").read
  if LastMonth = TodaysMonth then exit
  if LastMonth <> TodaysMonth then file("DAT\SETTINGS\month.txt").write(TodaysMonth)

  set Justicars = file("DAT\SETTINGS\justicars.txt").read
  set the itemdelimiter = ":"

  repeat with x = 1 to 100
    set the itemdelimiter = ":"

    if item x of Justicars <> "" then

      set ThisJusticar = item x of Justicars
      set the itemdelimiter = "-"
      set CurJust = item 1 of ThisJusticar
      put "j" into item 2 of ThisJusticar
      set the itemdelimiter = ":"
      put ThisJusticar into item x of Justicars
    end if
  end repeat

  file("DAT\SETTINGS\justicars.txt").write(Justicars)

end



on AddJusticar (me, movie, group, user, fullmsg)

 set username = fullMsg.content
 set Justicars = file("DAT\SETTINGS\justicars.txt").read
 set LineToAdd = UserName & "-10"
 set Justicars = Justicars & LineToAdd & ":"
 file("DAT\SETTINGS\justicars.txt").write(Justicars)

 set DTTT = "You have just been promoted to a justicar. You can now pardon 10 vile murderers per month from their crimes."
 sendMovieMessage(movie, user.name, "sqa", DTTT)
 set DTTT = "To pardon someone, type /pardon name. "
 sendMovieMessage(movie, user.name, "sqa", DTTT)

end


on RemoveJusticar (me, movie, group, user, fullmsg)

 set userName = fullMsg.content

 set Justicars = file("DAT\SETTINGS\justicars.txt").read

   repeat with x = 1 to 500

     set the itemdelimiter = ":"
     if item x of Justicars <> "" then
       set ThisLine = item x of Justicars
       set the itemdelimiter = "-"
         if item 1 of ThisLine = UserName then
            set the itemdelimiter = ":"
            put "" into item x of Justicars
            set DTTT = "You have been fired as justicar."
            sendMovieMessage(movie, user.name, "sqa", DTTT)
         end if
     end if
   end repeat

 file("DAT\SETTINGS\justicars.txt").write(Justicars)
end



on PardonPlayer (me, movie, group, user, fullmsg)

 set MyName = string(user.name)
 set userName = fullMsg.content

 set Justicars = file("DAT\SETTINGS\justicars.txt").read

   repeat with x = 1 to 500

     set the itemdelimiter = ":"
     if item x of Justicars <> "" then
       set ThisLine = item x of Justicars
       set the itemdelimiter = "-"

         if item 1 of ThisLine = MyName then
            set MyCurPardons = integer(item 2 of ThisLine)
            if MyCurPardons < 1 then
              set DTTT = "You have 0 pardons left, cannot pardon " & UserName & "."
              sendMovieMessage(movie, user.name, "sqa", DTTT)
              exit
            end if

            set MyCurPardons = MyCurpardons - 1
            put MyCurPardons into item 2 of ThisLine
            set the itemdelimiter = ":"
            put ThisLine into item x of Justicars

            set MyFile = file("DAT\CHAR\" & string(UserName) & ".txt").read
            set the itemdelimiter = "/"
            put "0" into item 8 of MyFile
            file("DAT\CHAR\" & string(UserName) & ".txt").write(MyFile)
            sendMovieMessage(movie, UserName, "PRDN", MyName)
            set the itemdelimiter = ":"
         end if

     end if
   end repeat


 file("DAT\SETTINGS\justicars.txt").write(Justicars)

end


on AmIJusticar(me, movie, group, user, fullMsg)

set userName = string(user.name)

 set Justicars = file("DAT\SETTINGS\justicars.txt").read

   repeat with x = 1 to 500

     set the itemdelimiter = ":"
     if item x of Justicars <> "" then
       set ThisLine = item x of Justicars
       set the itemdelimiter = "-"
         if item 1 of ThisLine = UserName then
            sendMovieMessage(movie, UserName, "YouIsJust", UserName)
         end if
     end if
   end repeat

end
