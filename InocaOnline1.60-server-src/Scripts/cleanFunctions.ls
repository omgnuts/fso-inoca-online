on isPresentInv(ItemToFind, CurrInv)
	set CurrInv = ":" & CurrInv
	if CurrInv Contains ":" & ItemToFind & "-" then return TRUE

	if (ItemToFind = "Crate#") or (ItemToFind = "Cabinet#") or (ItemToFind = "Wind Cabinet#") then
		if CurrInv Contains ":" & ItemToFind then return TRUE
   end if

	return FALSE
end isPresentInv

--// finds the item
--// return format = InvPos|InvCount
on findInvPos(ItemToFind, CurrInv, MAXI, InvLoc)
	set saveDemi = the itemdelimiter
	set the itemdelimiter = ":"

	set startN = 1
	if integer(InvLoc) > 0 then startN = integer(InvLoc)

	repeat with n = startN to MAXI
		if item n of CurrInv contains (ItemToFind & "-") then

			set ItemStr = item n of CurrInv
			set the itemdelimiter = "-"

			if item 1 of ItemStr = ItemToFind then
				set ItemPosStr = string(n) & "|" & item 2 of ItemStr
				set the itemdelimiter = saveDemi
				return ItemPosStr
			else
				set the itemdelimiter = ":"
			end if

		end if

	end repeat

	set the itemdelimiter = saveDemi
	return ""
end findInvPos

on isEmpty(TheCab)
	set cabContent = file("DAT\VAULTS\" & TheCab & ".txt").read
	if (cabContent = "") or (cabContent = void) then return TRUE
	return FALSE
end

--"// finds any (ItemToFind = "Crate#") or (ItemToFind = "Cabinet#") or (ItemToFind = "Wind Cabinet#")
--// the serial number is not impt but should empty
--// return format = InvPos|InvCount
on findInvPosContain(ItemToFind, CurrInv, MAXI)
	set saveDemi = the itemdelimiter
	set the itemdelimiter = ":"

	repeat with n = 1 to MAXI
		if item n of CurrInv contains (ItemToFind) then

			set ItemStr = item n of CurrInv
			set the itemdelimiter = "-"

			set TheContainer = item 1 of ItemStr
			set the itemdelimiter = "#"

			if ItemToFind = item 1 of TheContainer & "#" then
				set the itemdelimiter = "-"
				if isEmpty(TheContainer) then
					set ItemPosStr = string(n) & "|" & item 2 of ItemStr
					set the itemdelimiter = saveDemi
					return ItemPosStr
				end if
			else
				set the itemdelimiter = ":"
			end if

		end if
	end repeat
	set the itemdelimiter = saveDemi
	return ""
end findInvPosContain


--// finds the first empty position
--// returns EmptyPos
on findInvEmpty(CurrInv, MAXI)
	set saveDemi = the itemdelimiter

	set the itemdelimiter = ":"
	repeat with n = 1 to MAXI
		if item n of CurrInv = "" then
			set the itemdelimiter = saveDemi
			return n
		end if
	end repeat

	set the itemdelimiter = saveDemi
	return 0 --// No empty position

end findInvEmpty

--// Insert the inventory to a position
--// return newInv (from CurrInv)
on InsInv(ItemToAdd, CurrInv, ItemPos, CurrAmt, NumToAdd)
	set saveDemi = the itemdelimiter

	set NewAmt = Integer(CurrAmt) + Integer(NumToAdd)
	set the itemdelimiter = ":"

	put (ItemToAdd & "-" & string(NewAmt)) into item integer(ItemPos) of CurrInv

	set the itemdelimiter = saveDemi
	return CurrInv

end InsInv

--// Add Inv in CurrFile
--// returns NewInv
on AddInvX (ItemToAdd, NumToAdd, CurrInv)
	set saveDemi = the itemdelimiter

	set MAXI = 15

	if isPresentInv(ItemToAdd, CurrInv) then
		set ItemPosStr = findInvPos(ItemToAdd, CurrInv, MAXI)
		if ItemPosStr <> "" then
			set the itemdelimiter = "|"
			set CurrInv = InsInv(ItemToAdd, CurrInv, item 1 of ItemPosStr, item 2 of ItemPosStr, NumToAdd)

			set the itemdelimiter = saveDemi
			return CurrInv
		else
			put "ERROR in 'on AddInvX'"
		end if
	else
		set empPos = findInvEmpty(CurrInv, MAXI)
		if empPos > 0 then
			set CurrInv = InsInv(ItemToAdd, CurrInv, empPos, 0, NumToAdd)

			set the itemdelimiter = saveDemi
			return CurrInv
		end if
	end if

	set the itemdelimiter = saveDemi
	return ""

end AddInvX

--// Add Inv from ItemFile
--// returns itemFile
on AddItemX (ItemToAdd, NumToAdd, ItemFile)
	set saveDemi = the itemdelimiter
	set the itemdelimiter = "|"

	if ItemToAdd = "Gold" then
		set NewGold = integer(item 1 of ItemFile) + Integer(NumToAdd)
		if NewGold >= 0 then
			put NewGold into item 1 of ItemFile
			set the itemdelimiter = saveDemi
			return ItemFile
		end if
	else
		set NewInv = AddInvX (ItemToAdd, NumToAdd, item 2 of ItemFile)
		if NewInv <> "" then
			put NewInv into item 2 of ItemFile
			set the itemdelimiter = saveDemi
			return ItemFile
		end if
	end if

	set the itemdelimiter = saveDemi
	return ""
end AddItemX

--// Add & Save Inv in ItemFile
--// returns TRUE or FALSE
on AddSaveItemX (ItemToAdd, NumToAdd, MyName, Movie)
	set saveDemi = the itemdelimiter

	set myItemFile = file("DAT\CHAR\" & myName & "-i.txt").read
	set NewItemFile = AddItemX (ItemToAdd, NumToAdd, myItemFile)

	if NewItemFile <> "" then
		file("DAT\CHAR\" & myName & "-i.txt").write(NewItemFile)
		sendMovieMessage(movie, myName, "inx", NewItemFile)
		set the itemdelimiter = saveDemi
		return TRUE
	end if

	set the itemdelimiter = saveDemi
	return FALSE
end AddSaveInvX


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--// Remove the inventory to a position
--// return newInv (from CurrInv)
on RemInv(ItemToGo, CurrInv, ItemPos, CurrAmt, NumToGo)
	set saveDemi = the itemdelimiter

	set NewAmt = Integer(CurrAmt) - Integer(NumToGo)

	if NewAmt >= 0 then
		set the itemdelimiter = ":"

		if NewAmt = 0 then put "" into item integer(ItemPos) of CurrInv
		if NewAmt > 0 then put (ItemToGo & "-" & string(NewAmt)) into item integer(ItemPos) of CurrInv

		set the itemdelimiter = saveDemi
		return CurrInv
	end if

	set the itemdelimiter = saveDemi
	return ""
end RemInv

--// Rem Inv in CurrFile
--// returns NewInv
on RemInvX (ItemToGo, NumToGo, CurrInv, InvLoc)
	set saveDemi = the itemdelimiter

	set MAXI = 15

	if isPresentInv(ItemToGo, CurrInv) then

	 	if (ItemToGo = "Crate#") or (ItemToGo = "Cabinet#") or (ItemToGo = "Wind Cabinet#") then
	 		set ItemPosStr = findInvPosContain(ItemToGo, CurrInv, MAXI, InvLoc)
	 	else
			set ItemPosStr = findInvPos(ItemToGo, CurrInv, MAXI, InvLoc)
		end if
		if ItemPosStr <> "" then
			set the itemdelimiter = "|"
			set CurrInv = RemInv(ItemToGo, CurrInv, item 1 of ItemPosStr, item 2 of ItemPosStr, NumToGo)

			if CurrInv <> "" then
				set the itemdelimiter = saveDemi
				return CurrInv
			end if
		else
			put "ERROR in 'on RemInvX'"
		end if
	end if


	set the itemdelimiter = saveDemi
	return ""

end RemInvX

--// Rem Inv from ItemFile
--// returns itemFile
on RemItemX (ItemToGo, NumToGo, ItemFile, InvLoc)
	set saveDemi = the itemdelimiter
	set the itemdelimiter = "|"

	if ItemToGo = "Gold" then
		set NewGold = integer(item 1 of ItemFile) - Integer(NumToGo)
		if NewGold >= 0 then
			put NewGold into item 1 of ItemFile
			set the itemdelimiter = saveDemi
			return ItemFile
		end if
	else
		set NewInv = RemInvX (ItemToGo, NumToGo, item 2 of ItemFile, InvLoc)
		if NewInv <> "" then
			put NewInv into item 2 of ItemFile
			set the itemdelimiter = saveDemi
			return ItemFile
		end if
	end if

	set the itemdelimiter = saveDemi
	return ""
end RemItemX

--// Rem & Save Inv in ItemFile
--// returns TRUE or FALSE
on RemSaveItemX (ItemToGo, NumToGo, MyName, Movie, InvLoc)
	set saveDemi = the itemdelimiter

	set myItemFile = file("DAT\CHAR\" & myName & "-i.txt").read
	set NewItemFile = RemItemX (ItemToGo, NumToGo, myItemFile, InvLoc)

	if NewItemFile <> "" then
		file("DAT\CHAR\" & myName & "-i.txt").write(NewItemFile)
		sendMovieMessage(movie, myName, "inx", NewItemFile)
		set the itemdelimiter = saveDemi
		return TRUE
	end if

	set the itemdelimiter = saveDemi
	return FALSE
end RemSaveItemX

on RemSaveEQX(ItemToGo, MyName, Movie)
	set saveDemi = the itemdelimiter

	set myItemFile = file("DAT\CHAR\" & myName & "-i.txt").read
	set the itemdelimiter = "|"
	set curEQs = string(item 3 of myItemFile)

	set the itemdelimiter = ":"
	repeat with n = 1 to 8
		if item n of curEQs = ItemToGo then
			put "NOTHING" into item n of curEQs
			set the itemdelimiter = "|"
			put curEQs into item 3 of myItemFile
			file("DAT\CHAR\" & myName & "-i.txt").write(myItemFile)
			sendMovieMessage(movie, myName, "inx", myItemFile)
			set the itemdelimiter = saveDemi
			return TRUE
		end if
	end repeat

	set the itemdelimiter = saveDemi
	return FALSE

end RemSaveEQX

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--// Exchange & Save Inv in ItemFile
--// returns TRUE or FALSE

on ExchSaveItemX (ItemToAdd, NumToAdd, ItemToGo, NumToGo, MyName, Movie, InvLoc)
	set saveDemi = the itemdelimiter

	set myItemFile = file("DAT\CHAR\" & myName & "-i.txt").read
	set NewItemFile = ExchItemX (ItemToAdd, NumToAdd, ItemToGo, NumToGo, myItemFile, InvLoc)

	if NewItemFile <> "" then
		file("DAT\CHAR\" & myName & "-i.txt").write(NewItemFile)
		sendMovieMessage(movie, myName, "inx", NewItemFile)
		set the itemdelimiter = saveDemi
		return TRUE
	end if

	set the itemdelimiter = saveDemi
	return FALSE
end ExchSaveItemX

on ExchItemX (ItemToAdd, NumToAdd, ItemToGo, NumToGo, ItemFile, InvLoc)
	set saveDemi = the itemdelimiter
	set ItemFile = RemItemX (ItemToGo, NumToGo, ItemFile, InvLoc)
	if ItemFile <> "" then
		set ItemFile = AddItemX (ItemToAdd, NumToAdd, ItemFile)
		if ItemFile <> "" then
			set the itemdelimiter = saveDemi
			return ItemFile
		end if
	end if
	set the itemdelimiter = saveDemi
	return ""
end ExchItemX


on MultiExchSaveItemX (ItemsToAdd, ItemsToGo, MyName, Movie)
	set saveDemi = the itemdelimiter

	set myItemFile = file("DAT\CHAR\" & myName & "-i.txt").read
	set NewItemFile = MultiExchItemX (ItemsToAdd, ItemsToGo, myItemFile)

	if NewItemFile <> "" then
		file("DAT\CHAR\" & myName & "-i.txt").write(NewItemFile)
		sendMovieMessage(movie, myName, "inx", NewItemFile)
		set the itemdelimiter = saveDemi
		return TRUE
	end if

	set the itemdelimiter = saveDemi
	return FALSE
end MultiExchSaveItemX

on MultiExchItemX (ItemsToAdd, ItemsToGo, ItemFile)
	set saveDemi = the itemdelimiter

	set the itemdelimiter = "%"
	set n = 1
	repeat while (item n of ItemsToGo <> "")
		set ThisItemToGo = item n of ItemsToGo
		set the itemdelimiter = "-"
		set ItemFile = RemItemX (item 1 of ThisItemToGo, item 2 of ThisItemToGo, ItemFile)
		if ItemFile = "" then
			set the itemdelimiter = saveDemi
			return ""
		end if
		set the itemdelimiter = "%"
		set n = n + 1
	end repeat

	set n = 1
	repeat while (item n of ItemsToAdd <> "")
		set ThisItemToAdd = item n of ItemsToAdd
		set the itemdelimiter = "-"
		set ItemFile = AddItemX (item 1 of ThisItemToAdd, item 2 of ThisItemToAdd, ItemFile)
		if ItemFile = "" then
			set the itemdelimiter = saveDemi
			return ""
		end if
		set the itemdelimiter = "%"
		set n = n + 1
	end repeat

	set the itemdelimiter = saveDemi
	return ItemFile
end MultiExchItemX
