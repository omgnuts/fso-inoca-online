-- itmDat = itemiser-itmCount
-- itemiser = itm%serial#plus#curse etc.
-- itmCode = itm or itm#plus -- serial & plus should be mutually exclusive.
-- itmic = itm%serial        -- serial & plus should be mutually exclusive.
-- itm = itm

--------------------------------------------------------
-- // addItemToInventory(AddSaveItemX)
--------------------------------------------------------
-- This method adds an item to the person's inventory
-- a check is done to see if he has the item, then only
-- the counter is raised. Save the file at the same time
--------------------------------------------------------
-- Returns:
--          * if success: TRUE
--          * otherwise : FALSE
--------------------------------------------------------
on addItemToInventory(movie, username, itemiser, itmAddNo)
    savei = the itemdelimiter

    udir = username.char[1] & "\"
    pointer = [#pos:-1, #itmDat:""]

    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)
    newItmFile = _addItemOrGoldToInvnt(itemiser, itmAddNo, itmFile, pointer)

    if (newItmFile <> "" and pointer.pos > -1) then
        file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(newItmFile)

        if pointer.pos = 0 then
            sendMovieMessage(movie, username, "invnt.upd_gold", pointer.itmDat)
        else
            sendMovieMessage(movie, username, "invnt.upd_invitm", pointer.pos & ":" & pointer.itmDat)
        end if

        the itemdelimiter = savei
        return TRUE
    end if

    the itemdelimiter = savei
    return FALSE

end addItemToInventory

--"------------------------------------------------------
-- // removeItemFromInventory(RemSaveItemX)
--------------------------------------------------------
-- This method removes an item to the person's inventory
-- a check is done to see if he has the item, then only
-- the counter is reduced. Save the file at the same time
--------------------------------------------------------
-- Returns:
--          * if success: TRUE
--          * otherwise : FALSE
--------------------------------------------------------
on removeItemFromInventory(movie, username, itemiser, itmLessNo, invIndex, findAnyEmpty)

    savei = the itemdelimiter

    udir = username.char[1] & "\"

    if invIndex = "" then invIndex = -1
    pointer = [#pos:invIndex , #itmDat:""]

    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)
    newItmFile = _remItemOrGoldFromInvnt(itemiser, itmLessNo, itmFile, pointer, findAnyEmpty)

    if (newItmFile <> "" and pointer.pos > -1) then
        file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(newItmFile)

        if pointer.pos = 0 then
            sendMovieMessage(movie, username, "invnt.upd_gold", pointer.itmDat)
        else
            sendMovieMessage(movie, username, "invnt.upd_invitm", pointer.pos & ":" & pointer.itmDat)
        end if

        the itemdelimiter = savei
        return TRUE
    end if

    the itemdelimiter = savei
    return FALSE

end removeItemFromInventory

---------- Helper methods to ADD / REMOVE from inventory calls ---------------------------------------------

--// Add Inv to ItemFile (_AddItemX)
--// returns itemFile

on _addItemOrGoldToInvnt(itemiser, itmAddNo, itmFile, pointer)
    savei = the itemdelimiter
    the itemdelimiter = "|"

    -- You can update both gold /inventory items.
    -- However, use the other EQ-based methods for EQitems

    if itemiser = "Gold" then

        newGold  = integerX(itmFile.item[1]) + integerX(itmAddNo)
        if newGold < 0 then newGold = 0
        put newGold into itmFile.item[1]

        pointer.pos = 0
        pointer.itmDat = "Gold-" & newGold

        the itemdelimiter = savei
        return itmFile

    else

        newInvFile = _addItemToInvnt(itemiser, itmAddNo, itmFile.item[2], pointer)

        if newInvFile <> "" then
            put newInvFile into itmFile.item[2]

            the itemdelimiter = savei
            return itmFile
        else

            the itemdelimiter = savei
            return ""
        end if

    end if

end _addItemOrGoldToInvnt


--// Add Inv in CurrFile (_AddInvX)
--// returns NewInv
on _addItemToInvnt(itemiser, itmAddNo, invFile, pointer)

    savei = the itemdelimiter

    if itemiser.char[1] <> "s" then -- if it is a serial based itemiser, then just find an empty slot
        itmCount = _findItmPos(itemiser, invFile, pointer)
        if pointer.pos > 0 and itmCount > 0 then

            newInvFile = _insertItemToInvtPos(itemiser, invFile, pointer, itmCount, itmAddNo)

            the itemdelimiter = savei
            return newInvFile
        else
            if pointer.pos > 0 or itmCount > 0 then
                put "ERROR in '_addItemToInvnt' ... " & itemiser
            end if
        end if
    end if


    empPos = _findInvEmptySlot(invFile)
    if empPos > 0 then

        pointer.pos = empPos
        newInvFile = _insertItemToInvtPos(itemiser, invFile, pointer, 0, itmAddNo)

        the itemdelimiter = savei
        return newInvFile
    end if

    the itemdelimiter = savei
    return "" -- blank newInvFile

end _addItemToInvnt

--// Insert the inventory to a position (_InsInv)
--// return newInv (from CurrInv)
on _insertItemToInvtPos(itemiser, invFile, pointer, itmCount, itmAddNo) -- itmCount = current amount
    savei = the itemdelimiter

    newAmt = integer(itmCount) + integer(itmAddNo)
    the itemdelimiter = ":"

    pointer.itmDat = itemiser & "-" & newAmt
    put (pointer.itmDat) into invFile.item[pointer.pos]

    the itemdelimiter = savei
    return invFile

end _insertItemToInvtPos

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

--// Rem Inv from ItemFile(_RemItemX )
--// returns itemFile
on _remItemOrGoldFromInvnt(itemiser, itmLessNo, itmFile, pointer, findAnyEmpty)

    savei = the itemdelimiter
    the itemdelimiter = "|"

    if itemiser = "Gold" then
        newGold  = integerX(itmFile.item[1]) - integerX(itmLessNo)
        if newGold  >= 0 then
            put newGold into itmFile.item[1]

            pointer.pos = 0
            pointer.itmDat = "Gold-" & newGold

            the itemdelimiter = savei
            return itmFile
        end if
    else

        newInvFile = _remItemFromInvnt(itemiser, itmLessNo, itmFile.item[2], pointer, findAnyEmpty)

        if newInvFile <> "" then
            put newInvFile into itmFile.item[2]

            the itemdelimiter = savei
            return itmFile
        end if

    end if

		the itemdelimiter = savei
		return ""

end _remItemOrGoldFromInvnt

--// Rem Inv in CurrInvFile(_RemInvX )
--// returns NewInv
on _remItemFromInvnt(itemiser, itmLessNo, invFile, pointer, findAnyEmpty)

    savei = the itemdelimiter

    if itemiser.char[1..2] = "$s" AND findAnyEmpty then

			the itemdelimiter = "%"
			itemToFind = itemiser.item[1] & "%"

			itmCount = _findItmPosContain(itemToFind, invFile, pointer)

    else
			-- removing a specific item.

      itmCount = _findItmPos(itemiser, invFile, pointer)

    end if

    if pointer.pos > 0 and itmCount > 0 then

        if itemiser.char[1..2] = "$s" then
        	newInvFile = _deleteSerialItemFromInvtPos(invFile, pointer, itmCount, itmLessNo)
        else
        	newInvFile = _deleteItemFromInvtPos(itemiser, invFile, pointer, itmCount, itmLessNo)

        end if

        if newInvFile <> "" then
            the itemdelimiter = savei
            return newInvFile
        else
            put "ERROR in '_remItemFromInvnt' ... Not enough items or no serial item to remove"
        end if
    else

        if pointer.pos > 0 or  itmCount > 0 then
            put "ERROR in '_remItemFromInvnt' ... " & itemiser
        end if
    end if

    the itemdelimiter = savei
    return "" -- blank newInvFile

end _remItemFromInvnt

--// Remove the inventory from a position(_RemInv)
--// return newInv (from CurrInv)
on _deleteItemFromInvtPos(itemiser, invFile, pointer, itmCount, itmLessNo)
    savei = the itemdelimiter

    newAmt = integer(itmCount) - integer(itmLessNo)

    if newAmt >= 0 then
        the itemdelimiter = ":"

        if newAmt = 0 then
            pointer.itmDat = ""
        else
            pointer.itmDat = itemiser & "-" & newAmt
        end if

        put (pointer.itmDat) into invFile.item[pointer.pos]

        the itemdelimiter = savei
        return invFile
    end if

    the itemdelimiter = savei
    return ""

end

on _deleteSerialItemFromInvtPos(invFile, pointer, itmCount, itmLessNo)
    savei = the itemdelimiter

    if (itmCount = 1 and itmLessNo = 1) then
        the itemdelimiter = ":"

        pointer.itmDat = ""
        put (pointer.itmDat) into invFile.item[pointer.pos]

        the itemdelimiter = savei
        return invFile
    end if

    the itemdelimiter = savei
    return ""

end _deleteSerialItemFromInvtPos

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- // end helpers for ADD/ REMOVE invenotry items

--"------------------------------------------------------
-- // removeEQItemWithSave (new)
--------------------------------------------------------
-- This method removes an equipped item from the user's
-- inventory and does save it back into his unequipped
-- inventory list. Eg. removing ur worn armour / broken item
--------------------------------------------------------
-- Returns:
--          * if success: TRUE
--          * otherwise : FALSE
--------------------------------------------------------
on remEQItemWithSave(movie, username, itemiser, myitype)
    savei = the itemdelimiter
    the itemdelimiter = "|"

    udir = username.char[1] & "\"
    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)

    pointer = [#pos:-1, #itmDat:""]
    invEqFile = _remEQItemNoSave(itemiser, myitype, itmFile.item[3], itmFile.item[2], pointer)

    if invEqFile <> "" then
			itmFile = itmFile.item[1] & "|" & invEqFile

			file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(itmFile)
			sendMovieMessage(movie, username, "invnt.upd_remEQ", myitype & ":" & pointer.pos & ":" & pointer.itmDat)
			the itemdelimiter = savei
			return TRUE
    end if

    the itemdelimiter = savei
    return FALSE
end remEQItemWithSave

--"------------------------------------------------------
-- // loseEQItemWithSave (RemSaveEQX)
--------------------------------------------------------
-- This method removes an equipped item from the user's
-- inventory and does not save it back into his unequipped
-- inventory list. Eor example. dropping a CTF flag in the
-- shield slot onto the ground
--------------------------------------------------------
-- Returns:
--          * if success: TRUE
--          * otherwise : FALSE
--------------------------------------------------------

on loseEQItemWithSave(movie, username, itemiser, myitype)
    savei = the itemdelimiter
    the itemdelimiter = "|"

    udir = username.char[1] & "\"
    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)

    eqFile = itmFile.item[3]
    eqPos = _getEQItemPos(myitype)

		the itemdelimiter = ":"
    if eqFile.item[eqPos] = itemiser then
			put "" into eqFile.item[eqPos]

			the itemdelimiter = "|"
			put eqFile into itmFile.item[3]

			file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(itmFile)

			sendMovieMessage(movie, username, "invnt.upd_remEQ", myitype)

			the itemdelimiter = savei
			return TRUE
    end if

    the itemdelimiter = savei
    return FALSE
end loseEQItemWithSave


--"------------------------------------------------------
-- // removeEQItemNoSave (new)
--------------------------------------------------------
-- This method removes an equipped item from the user's
-- inventory and saves it to inventory. but does not save
-- this file to the directory
--------------------------------------------------------
-- Returns:
--          * if success: invEqFile
--          * otherwise : ""
--------------------------------------------------------
--on _remItemFromInvnt(itemiser, itmLessNo, invFile, pointer)
--on _addItemFromInvnt(itemiser, itmLessNo, invFile, pointer)

on _remEQItemNoSave(itemiser, myitype, eqFile, invFile, pointer)

    savei = the itemdelimiter

    eqPos = _getEQItemPos(myitype)

    the itemdelimiter = ":"

    if eqFile.item[eqPos] = itemiser then

			invFile = _addItemToInvnt(itemiser, 1, invFile, pointer)

			if invFile <> "" then

					put "" into eqFile.item[eqPos]
					the itemdelimiter = savei
					return invFile & "|" & eqFile

			end if

    end if

    the itemdelimiter = savei
    return ""

end _remEQItemNoSave

--"------------------------------------------------------
-- // wearEQItemWithSave(new)
--------------------------------------------------------
-- This method allows user to wear and item
-- then removes one count from the inventory
--------------------------------------------------------
-- Returns:
--          * if success: TRUE
--          * otherwise : FALSE
--------------------------------------------------------

on wearEQItemWithSave(movie, username, itemiser, myitype)
    savei = the itemdelimiter
    the itemdelimiter = "|"

    udir = username.char[1] & "\"
    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)

    pointer = [#pos:-1, #itmDat:""]
    invEqFile = _wearEQItemNoSave(itemiser, myitype, itmFile.item[3], itmFile.item[2], pointer)

    if invEqFile <> "" then
			itmFile = itmFile.item[1] & "|" & invEqFile

			file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(itmFile)

			sendMovieMessage(movie, username, "invnt.upd_wearEQ", myitype & ":" & itemiser & \
												":" & pointer.pos & ":" & pointer.itmDat)
			the itemdelimiter = savei
			return TRUE
    end if

    the itemdelimiter = savei
    return FALSE
end wearEQItemWithSave

--"------------------------------------------------------
-- // _wearEQItemNoSave(new)
--------------------------------------------------------
-- This method makes the user wear the EQ and removes
-- the item from the inventory. does not save to file yet
--------------------------------------------------------
-- Returns:
--          * if success: TRUE
--          * otherwise : FALSE
--------------------------------------------------------

on _wearEQItemNoSave(itemiser, myitype, eqFile, invFile, pointer)

    savei = the itemdelimiter

    eqPos = _getEQItemPos(myitype)

    the itemdelimiter = ":"

		if eqFile.item[eqPos] = "" then

        invFile = _remItemFromInvnt(itemiser, 1, invFile, pointer)

        if invFile <> "" then

            put itemiser into eqFile.item[eqPos]

            the itemdelimiter = savei
            return invFile & "|" & eqFile

        end if

    end if

    the itemdelimiter = savei
    return ""

end _wearEQItemNoSave
--"------------------------------------------------------
-- // _getEQItemPos
--------------------------------------------------------
-- Finds the item position of an equipped myItype (eg. ringA)
-- shuold be consistent with the read in at the client.
--------------------------------------------------------
-- Returns: position Number
--------------------------------------------------------
on _getEQItemPos(myitype)
    case (myitype) of
        "xcap"      : return 1
        "xringA"    : return 2
        "xringB"    : return 3
        "xmantle"   : return 4
        "xbelt"     : return 5
        "xcloak"    : return 6
        "xgloves"   : return 7
        "xweapon"   : return 8
        "xshield"   : return 9
        "xarmour"   : return 10
        "xshoes"    : return 11
    end case
end _getEQItemPos


-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

--// Exchange & Save Inv in ItemFile (_ExchSaveItemX)
-- for example give an apple to an NPC for a reward
--// returns TRUE or FALSE

on exchangeSingleInvntItem(movie, username, itemiserToAdd, itmAddNo, itemiserToLess, itmLessNo, findAnyEmpty)
    savei = the itemdelimiter

    udir = username.char[1] & "\"

    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)
    newItmFile = _exchSingleItem(itemiserToAdd, itmAddNo, itemiserToLess, itmLessNo, itmFile, findAnyEmpty)

    if newItmFile <> "" then
        the itemdelimiter = "|"

        file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(newItmFile)

        put "" into newItmFile.item[3] -- dont have to send EQ data

        sendMovieMessage(movie, username, "invnt.upd_allnonEQ", newItmFile)

        the itemdelimiter = savei
        return TRUE
    end if

    the itemdelimiter = savei
    return FALSE

end exchangeSingleInvntItem

on _exchSingleItem(itemiserToAdd, itmAddNo, itemiserToLess, itmLessNo, itmFile, findAnyEmpty)
    savei = the itemdelimiter

    pointer = [#pos:-1, #itmDat:""]
    itmFile = _remItemOrGoldFromInvnt(itemiserToLess, itmLessNo, itmFile, pointer, findAnyEmpty)

    if itmFile <> "" then -- successfully removed itm. now lets add item
			pointer = [#pos:-1, #itmDat:""]
			itmFile = _addItemOrGoldToInvnt(itemiserToAdd, itmAddNo, itmFile, pointer)
			if itmFile <> "" then
					the itemdelimiter = savei
					return itmFile
			end if
    end if

    the itemdelimiter = savei
    return ""

end _exchSingleItem

--// Exchange & Save Multiple Inv in ItemFile (MultiExchSaveItemX )
-- for example give an apple to an NPC for a reward
--// returns TRUE or FALSE

on exchangeMultipleInvntItems(movie, username, itemisersToAdd, itemisersToLess)
-- format is itemiser-count:itemiserB-countB:itemiserC-countC

    savei = the itemdelimiter

		udir = username.char[1] & "\"
    itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)
    set newItmFile = _exchMultipleItems(itemisersToAdd, itemisersToLess, itmFile)

    if newItmFile <> "" then
        the itemdelimiter = "|"

        file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(newItmFile)

        put "" into newItmFile.item[3] -- dont have to send EQ data

        sendMovieMessage(movie, username, "invnt.upd_allnonEQ", newItmFile)

        the itemdelimiter = savei
        return TRUE
    end if

    the itemdelimiter = savei
    return FALSE

end exchangeMultipleInvntItems

on _exchMultipleItems(itemisersToAdd, itemisersToLess, itmFile)
    savei = the itemdelimiter

    the itemdelimiter = ":"

    n = 1
    repeat while (itemisersToLess.items[n] <> "")
        itemiserToLessDat = itemisersToLess.item[n]

        -- for each itemiserToLess
        the itemdelimiter = "-"
        pointer = [#pos:-1, #itmDat:""]
        itmFile = _remItemOrGoldFromInvnt(itemiserToLessDat.item[1], itemiserToLessDat.item[2], itmFile, pointer)

        if itmFile = "" then
            the itemdelimiter = savei
            return ""
        end if

        the itemdelimiter = ":"
        n = n + 1

    end repeat

    n = 1
    repeat while (itemisersToAdd.items[n] <> "")
        itemiserToAddDat = itemisersToAdd.item[n]

        -- for each itemiserToAdd
        the itemdelimiter = "-"
        pointer = [#pos:-1, #itmDat:""]
        itmFile =  _addItemOrGoldToInvnt(itemiserToAddDat.item[1], itemiserToAddDat.item[2], itmFile, pointer)

        if itmFile = "" then
            the itemdelimiter = savei
            return ""
        end if

        the itemdelimiter = ":"
        n = n + 1

    end repeat

    the itemdelimiter = savei
    return itmFile

end _exchMultipleItems

-- - - - - - - - - - - - helper methods - - - - - - - - - - - -
--// finds the first empty position
--// returns EmptyPos or -1
on _findInvEmptySlot(invFile)

    global INVNT_MAX_NO

    savei = the itemdelimiter

    the itemdelimiter = ":"
    repeat with pos = 1 to INVNT_MAX_NO
        if invfile.item[pos] = "" then
            the itemdelimiter = savei
            return pos
        end if
    end repeat

    the itemdelimiter = savei
    return -1 --// No empty position

end _findInvEmptySlot

--------------------------------------------------------
-- // _findItmPos(itemiser, invFile, pointer)
--------------------------------------------------------
-- This method finds a specific itemiser
--------------------------------------------------------
-- Returns: itmCount of the itemiser
--------------------------------------------------------

on _isPresentInvnt(itemiser, invFile)
	-- checks if the itmCode exists in the inventory

    invFile = ":" & invFile
    if invFile contains ":" & itemiser & "-" then return TRUE

    return FALSE
end _isPresentInvnt

on _findItmPos(itemiser, invFile, pointer)

	--// finds the item
	--// return format = itmCount
	-- pointer.pos is -1 unless & if its > 0 then
	-- it is used only for item removal at specific positions

    global INVNT_MAX_NO

    if _isPresentInvnt(itemiser, invFile) then

			savei = the itemdelimiter
			the itemdelimiter = ":"

			if pointer.pos > 0 then
					startN = pointer.pos
					endN = pointer.pos -- only search one position for item removal
			else
					startN = 1
					endN = INVNT_MAX_NO
			end if

			repeat with pos = startN to endN
					if invFile.item[pos] contains (itemiser & "-") then
						itmDat = invFile.item[pos] -- contains the invCount
						the itemdelimiter = "-"

						if itemiser = itmDat.item[1] then -- double check

								pointer.pos = pos
								itmCount = integerXOne(itmDat.item[2]) -- current inventory count

								the itemdelimiter = savei
								return itmCount
						else
								the itemdelimiter = ":"
						end if
					end if

			end repeat

			the itemdelimiter = savei

    end if

    -- cannot find the itm

    pointer.pos = -1
    return 0

end _findItmPos

--------------------------------------------------------
-- // _findItmPosContain(itemTofind, invFile, pointer)
--------------------------------------------------------
-- This method finds any serialised item.
-- for storage type serialised items that begin with "$sc"
-- we check whether it is empty.
--------------------------------------------------------
-- Returns: itmCount
--------------------------------------------------------
on _isPresentInvntContain(itemToFind, invFile)

    invFile = ":" & invFile
    if invFile contains ":" & itemToFind  then return TRUE

    return FALSE

end _isPresentInvntContain

on _findItmPosContain(itemTofind, invFile, pointer)

		-- itemToFind is in the format like $sccab%
		-- itemToFind can only be used for serialised items

    global INVNT_MAX_NO

    savei = the itemdelimiter

		if itemTofind.char[1..3] = "$sc" then isStorage = TRUE

    if _isPresentInvntContain(itemTofind, invFile) then

        the itemdelimiter = ":"

        if pointer.pos > 0 then
            startN = pointer.pos
            endN = pointer.pos -- only search one position for item removal
        else
            startN = 1
            endN = INVNT_MAX_NO
        end if

        repeat with pos = startN to endN
            the itemdelimiter = ":"

            if invFile.item[pos] contains (itemTofind) then

                itmDat = invFile.item[pos]
                the itemdelimiter = "%"

                if itemToFind = itmDat.item[1] & "%" then

                	-- in cases where we need to check if the serial item containter is empty then we do this.

									if isStorage then
										the itemdelimiter = "#"
										if not _isStoreEmpty(itmDat.item[1]) then
											the itemdelimiter = ":"
											next repeat
										end if
									end if

									the itemdelimiter = "-"
									pointer.pos = pos
									itmCount = integerXOne(itmDat.item[2])
									the itemdelimiter = savei
									return itmCount

                end if
            end if
        end repeat

    end if

    the itemdelimiter = savei

    pointer.pos = -1
    return 0

end _findItmPosContain


------------------------------------------------------------------------------------
-- Helpers for Vaults
------------------------------------------------------------------------------------

--------------------------------------------------------
-- // _isStoreEmpty(itmic)
--------------------------------------------------------
-- This method checks if the storage if a storage
-- is empty or not.
--------------------------------------------------------
-- Returns:
-- 				* successful: TRUE
--				* otherwise : FALSE
--------------------------------------------------------
on _isStoreEmpty(itmic)
    storeFile = string(file("DAT\SERIALS\STORES\" & itmic & ".dam").read)
    if (storeFile = "") or (storeFile = void) then return TRUE
    return FALSE
end _isStoreEmpty

--------------------------------------------------------
-- // getStorePath(user, itemiser, itmic)
--------------------------------------------------------
-- This method checks if the storage if a (1) a user vault[$xcvault],
-- (2) a guild vault [$xcguild] or (3) a storage container[$sc]
-- itmic is $sccab%serial for storage,
-- itmic is user.name for $xcvault
-- itmic is guildname for $xcguild
--------------------------------------------------------
-- Returns: the storage path
--------------------------------------------------------
on getStorePath(username, itmic, owner)
	specialCode = itmic.char[1..3]

	case specialCode of
		"$sc": return "DAT\SERIALS\STORES\" & itmic & ".dam"
		"$xc":
			if itmic = "$xcvault" then
				-- we could use owner (contains ownership) or user.name
				-- but we are using user.name just for security purposes to ensure that
				-- only the user can access his vault.
				udir = username.char[1] & "\"
				return "DAT\CHARS\VAULTS\" & udir & "\" & username & ".dam"
			else if itmic = "$xcguild" then
				return "DAT\GUILDS\VAULTS\" & owner & ".dam"
			end if

	end case

	return VOID

end getStorePath

--------------------------------------------------------
-- // remFromVault(storeFile, itemiser, lessNo)
--------------------------------------------------------
-- removes an itemiser from the storage container.
-- calculates how many of the item is left and puts
-- the remainder in the storage container
--------------------------------------------------------
-- Returns: the new storage file info
--------------------------------------------------------
on remFromVault(storeFile, itemiser, lessNo)

	the itemdelimiter = ":"
	n = 1
	repeat while storeFile.item[n] <> ""
		itemDat = storeFile.item[n]

		if itemDat contains itemiser then
			the itemdelimiter = "-"
			if itemDat.item[1] = itemiser then
				-- we found the itemNo.
				amtInstore = integerX(itemDat.item[2])

				nettamt = amtInstore - integer(lessNo)
				if nettamt > 0 then
					itemDat = itemiser & "-" & nettamt
					the itemdelimiter = ":"
					put itemDat into storeFile.item[n]
				else
					the itemdelimiter = ":"
					delete storeFile.item[n]
				end if

				return storeFile

			end if
		end if

		the itemdelimiter = ":"
		n = n + 1

	end repeat

	return VOID
end

--------------------------------------------------------
-- // addToVault(movie, user, storeFile, itemiser, addNo)
--------------------------------------------------------
-- adds an itemiser from the storage container.
-- calculates the new total of the itemiser and puts
-- the itmCount in the storage container
--------------------------------------------------------
-- Returns: the new storage file info
--------------------------------------------------------

on addToVault(movie, username, storeFile, itemiser, addNo)

	global MAX_ITEM_IN_VAULT

	if itemiser.char[1..3] = "$sc" then
		sendMovieMessage(movie, username, "secure.notify", "You cannot store a container in a container.")
		exit
	end if

	if storeFile contains itemiser & "-" then

			the itemdelimiter = ":"
			n = 1
			repeat while storeFile.item[n] <> ""
				itemDat = storeFile.item[n]

				if itemDat contains itemiser then

					the itemdelimiter = "-"
					if itemDat.item[1] = itemiser then
						-- we found the itemNo.
						nettamt = integerX(itemDat.item[2]) + integer(addNo)
						itemDat = itemiser & "-" & nettamt

						the itemdelimiter = ":"
						put itemDat into storeFile.item[n]

						return storeFile

					end if
				end if

				the itemdelimiter = ":"
				n = n + 1

			end repeat

	end if

	-- in case the condiion storeFile contains itemiser & "-"  is checked wrongly.
	-- eg. if the real itemiser is similar to another one in the storeFile

	repeat while storeFile.char[storeFile.length] = ":"
		delete storeFile.char[storeFile.length]
	end repeat

	the itemdelimiter = ":"
	if storeFile.items.count < MAX_ITEM_IN_VAULT then
		storeFile = storeFile & ":" & itemiser & "-" & addNo
		if storeFile.char[1] = ":" then delete storeFile.char[1]
		return storeFile
	else
		return VOID
	end if

end addToVault

--------------------------------------------------------
-- // makeSerialObject(itemiser)
--------------------------------------------------------
-- creates a serialised object
--------------------------------------------------------
-- Returns: the serialised itemiser
--------------------------------------------------------

on makeSerialObject(itemiser)

	serialType = itemiser.char[1..3]
	
	the itemdelimiter = "#" 
	itm = itemiser.item[1]

	case serialType of

		"$sc": -- containers

			curSerial = integer(file("DAT\SERIALS\stores.dam").read)
			curSerial = curSerial + 1
			file("DAT\SERIALS\stores.dam").write(string(curSerial))
			
		"$sp": -- photos
			
			if (itm = "$sphoto") then 
				curSerial = integer(file("DAT\SERIALS\photos.dam").read)
				curSerial = curSerial + 1
				file("DAT\SERIALS\photos.dam").write(string(curSerial))
			else if (itm = "$spaint") then 
				curSerial = integer(file("DAT\SERIALS\paints.dam").read)
				curSerial = curSerial + 1
				file("DAT\SERIALS\paints.dam").write(string(curSerial))
			else
				return VOID
			end if
		
		otherwise: 
			return VOID

	end case

	itmic = itm & "%" & curSerial
	put itmic into itemiser.item[1]

	return itemiser

end makeSerialObject

on storeGetItem(movie, username, itmic, owner, itemiser, lessNo)

	if itemiser <> "" AND lessNo > 0 then

		storeFilePath = getStorePath(username, itmic, owner)
		if storeFilePath = VOID then
			sendMovieMessage(movie, username, "store.error", "Invalid container code.")
			exit
		end if

		storeFile = string(file(storeFilePath).read)

		storeFile = remFromVault(storeFile, itemiser, lessNo)
		if storeFile = VOID then
			sendMovieMessage(movie, username, "store.error", "Unable to remove item from container.")
			exit
		end if

		if addItemToInventory(movie, username, itemiser, lessNo) then
			file(storeFilePath).write(storeFile)
			sendMovieMessage(movie, username, "store.remitem", itmic & "/" & owner & "/" & itemiser & "/" & lessNo)
			return TRUE
		end if

	end if

	return FALSE
end storeGetItem

on storePutItem(movie, username, itmic, owner, itemiser, addNo)

	-- adds an item to vault & remove from ur inventory

	if itemiser <> "" AND addNo > 0 then

		storeFilePath = getStorePath(username, itmic, owner)
		if storeFilePath = VOID then
			sendMovieMessage(movie, username, "secure.gamemsg", "Invalid container code.")
			exit
		end if

		storeFile = string(file(storeFilePath).read)

		storeFile = addToVault(movie, username, storeFile, itemiser, addNo)
		if storeFile = VOID then
			sendMovieMessage(movie, username, "secure.gamemsg", "The container is full.")
			exit
		end if

		if removeItemFromInventory(movie, username, itemiser, addNo) then
			file(storeFilePath).write(storeFile)
			sendMovieMessage(movie, username, "secure.gamemsg", "The item has been added to the container.")
			return TRUE
		end if

	end if
	
	return FALSE
end storePutItem


on storeAddItem(movie, username, itmic, owner, itemiser, addNo)

	if itemiser <> "" AND addNo > 0 then

		storeFilePath = getStorePath(username, itmic, owner)
		if storeFilePath = VOID then
			sendMovieMessage(movie, username, "store.error", "Invalid container code.")
			exit
		end if

		storeFile = string(file(storeFilePath).read)

		storeFile = addToVault(movie, username, storeFile, itemiser, addNo )
		if storeFile = VOID then
			sendMovieMessage(movie, username, "store.error", "The container is full.")
			exit
		end if

		file(storeFilePath).write(storeFile)
		sendMovieMessage(movie, username, "secure.gamemsg", "The item has been added to the container.")

	end if
		  
end storeAddItem