on saveMap(movie, user, fullMsg)

	mapData = fullMsg.content

	the itemdelimiter = "|"
	mapName = mapData.item[1]

	delete mapData.item[1]
	file("DAT\MAPS\MAPS\" & mapName & ".dam").write(mapData)
	sendMovieMessage(movie, user.name, "secure.notify", "Map " & mapName  & " has been saved.")

end saveMap

on saveMapItems(movie, user, fullMsg)

	savei = the itemdelimiter

	wediMapItems = fullMsg.content

	the itemdelimiter = "^"
	mapName = wediMapItems.item[1]
	killed = wediMapItems.item[2]
	added = wediMapItems.item[3]

	mapItemFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)

	the itemdelimiter = "|"
	n = 1

	repeat while killed.item[n] <> ""
		mapItemFile = remItemFromMap2(killed.item[n], mapItemFile)
		n = n + 1
	end repeat

	repeat while mapItemFile.char[mapItemFile.length] = "|"
		delete mapItemFile.char[mapItemFile.length]
	end repeat

	if mapItemFile = "" then
		mapItemFile = added
	else
		mapItemFile = mapItemFile & "|" & added
	end if

	if mapItemFile = "|" then mapItemFile = ""
	file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").write(mapItemFile)

	the itemdelimiter = savei
	return TRUE

end saveMapItems


on saveMapNPCs(movie, user, fullMsg)
	savei = the itemdelimiter
	wediNPCs = fullMsg.content

	the itemdelimiter = "^"
	mapName = wediNPCs.item[1]
	npcMapFile = wediNPCs.item[2]
	npcCurFile = wediNPCs.item[3]

	file("DAT\MAPS\NPCS\" & mapName & "-n.dam").write(npcMapFile)
	file("DAT\MAPS\NPCSTMP\" & mapName & "-n.dam").write(npcCurFile)
	the itemdelimiter = savei

end saveMapNPCs

on dropItemOnMap(movie, username, mapName, toX, toY, itemiser, dropNum, invIndex)

	mapItemFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)
	mapItemFile = _addItemToMap(itemiser & "-" & dropNum & ":" & toX & "-" & toY, mapItemFile)

	if mapItemFile <> VOID then
		-- if u cannot add to the map, then theres no need to continue

		udir = username.char[1] & "\"
		pointer = [#pos:invIndex, #itmDat:""]

		itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)
		itmFile = _remItemOrGoldFromInvnt(itemiser, dropNum, itmFile, pointer)

		if (itmFile <> "" and pointer.pos = invIndex) then

			file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(itmFile)

			if pointer.pos = 0 then
				sendMovieMessage(movie, username, "invnt.upd_gold", pointer.itmDat)
			else
				sendMovieMessage(movie, username, "invnt.upd_invitm", pointer.pos & ":" & pointer.itmDat)
			end if

			-- now to save mapItemFile & send a message to everyone on the map to update the mapItem
			file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").write(mapItemFile)
			sendMovieMessage(movie, "@" & mapName, "mevent.upd_addmapi", itemiser & "-" & dropNum & ":" & toX & "-" & toY)

			return TRUE
		end if
	end if

end dropItemOnMap

on switchMapItem(movie, user, mapName, addMapItemDat, remMapItemDat)

	savei = the itemdelimiter

	mapItemFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)
  mapItemFile = remItemFromMap2(remMapItemDat, mapItemFile)
	mapItemFile = _addItemToMap(addMapItemDat, mapItemFile)

	file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").write(mapItemFile)

	sendMovieMessage(movie, "@" & mapName, "mevent.upd_addmapi", addMapItemDat)
	sendMovieMessage(movie, "@" & mapName, "mevent.upd_remmapi", remMapItemDat)

	the itemdelimiter = savei

end switchMapItem

on removeMapItem(movie, user, mapName, remMapItemDat)

	savei = the itemdelimiter

	mapItemFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)
  mapItemFile = remItemFromMap2(remMapItemDat, mapItemFile)

	file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").write(mapItemFile)

	sendMovieMessage(movie, "@" & mapName, "mevent.upd_remmapi", remMapItemDat)

	the itemdelimiter = savei

end removeMapItem

on addMapItem(movie, user, mapName, mapItemDat)

	savei = the itemdelimiter

	mapItemFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)
  mapItemFile = _addItemToMap(mapItemDat, mapItemFile)
	file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").write(mapItemFile)

	sendMovieMessage(movie, "@" & mapName, "mevent.upd_addmapi", mapItemDat)

	the itemdelimiter = savei

end addMapItem

on _addItemToMap(mapItemDat, mapItemFile)

	savei = the itemdelimiter

	the itemdelimiter = "|"
	n = 1

	repeat while (mapItemFile.item[n] <> "")
		n = n + 1
	end repeat

	put (mapItemDat) into mapItemFile.item[n]

	if mapItemFile.char[mapItemFile.length] <> "|" then
		mapItemFile = mapItemFile & "|"
	end if

	the itemdelimiter = savei
	return mapItemFile

end _addItemToMap

on pickItemFromMap(movie, username, mapName, fromX, fromY, itemiser, itmCount)

	mapItemFile = string(file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").read)
	mapItemFile = _remItemFromMap(itemiser, itmCount, fromX, fromY, mapItemFile)

	if mapItemFile <> VOID then
		-- if u cannot add to the map, then theres no need to continue

		udir = username.char[1] & "\"
		pointer = [#pos:-1, #itmDat:""]

		itmFile = string(file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").read)
		itmFile = _addItemOrGoldToInvnt(itemiser, itmCount, itmFile, pointer)

    if (itmFile <> "" and pointer.pos > -1) then
			file("DAT\CHARS\ITEMS\" & udir & username & "-i.dam").write(itmFile)

			if pointer.pos = 0 then
				sendMovieMessage(movie, username, "invnt.upd_gold", pointer.itmDat)
			else
				sendMovieMessage(movie, username, "invnt.upd_invitm", pointer.pos & ":" & pointer.itmDat)
			end if

			-- now to save mapItemFile & send a message to everyone on the map to update the mapItem
			if mapItemFile = "|" then mapItemFile = ""
			file("DAT\MAPS\ITEMS\" & mapName & "-i.dam").write(mapItemFile)
			sendMovieMessage(movie, "@" & mapName, "mevent.upd_remmapi", itemiser & "-" & itmCount & ":" & fromX & "-" & fromY)

			return TRUE
    end if

	end if

end pickItemFromMap

on _remItemFromMap(itemiser, itmCount, locX, locY, mapItemFile)

	savei = the itemdelimiter
	mapItemDat = itemiser & "-" & itmCount & ":" & locX & "-" & locY

	-- check if the item exists. Otherwise no point continuing
	if not mapItemFile contains (mapItemDat & "|") then return ""

	the itemdelimiter = "|"
	n = 1

	repeat while (mapItemFile.item[n] <> "")
		if mapItemFile.item[n] = mapItemDat then
			delete mapItemFile.item[n]

			the itemdelimiter = savei
			return mapItemFile
		end if

		n = n + 1
	end repeat

	the itemdelimiter = savei
	return VOID
end _remItemFromMap

on remItemFromMap2(mapItemDat, mapItemFile)

	savei = the itemdelimiter

	-- check if the item exists. Otherwise no point continuing
	if not mapItemFile contains (mapItemDat & "|") then return mapItemFile

	the itemdelimiter = "|"
	n = 1

	repeat while (mapItemFile.item[n] <> "")
		if mapItemFile.item[n] = mapItemDat then
			delete mapItemFile.item[n]

			the itemdelimiter = savei
			return mapItemFile
		end if

		n = n + 1
	end repeat

	the itemdelimiter = savei
	return mapItemFile

end remItemFromMap2

on changeMapTile(movie, user, mapName, oldTile, newTile, layer, locX, locY)

	mapFile = string(file("DAT\MAPS\MAPS\" & mapName & ".dam").read)

	the itemdelimiter = "#"
	lineNo = integer((layer - 1) * 14 + locY)
	locX = integer(locX)

	mapTile = mapFile.item[lineNo].word[integer(locX)]

	if mapTile = oldTile then

		put newTile into mapFile.item[lineNo].word[locX]
		file("DAT\MAPS\MAPS\" & mapName & ".dam").write(mapFile)

		chgTile = mapName & ":" & oldTile & ":" & newTile & ":" & layer & ":" & locX & ":" & locY
		sendMovieMessage(movie, "@" & mapName, "mevent.tilechange", chgTile)
	end if

	return FALSE

end