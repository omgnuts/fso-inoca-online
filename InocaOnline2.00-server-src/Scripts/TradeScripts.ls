-------------------------------------------------------------------
--// NPC Sell, I Buy
-------------------------------------------------------------------

on buyFromNPC(movie, username, npcCode, buyItemiser, howMany)

	npcServerFile = string(file("DAT\DATAS\NPCS\" & npcCode & ".dam").read)

	if buyItemiser.char[1..2] = "$s" then
	-- if its a $s itemiser then use makeSerialObject(itemiser)
		itemiser = makeSerialObject(buyItemiser)
		howMany = 1 -- you can only buy one serialised item at a time
	else
		itemiser = buyItemiser
	end if

	searchVal = "BNS|" & buyItemiser

	if npcServerFile contains (searchVal & ":") then

		the itemdelimiter = ":"
		ln = 1

		repeat while npcServerFile.line[ln] <> ""
			lineDat = npcServerFile.line[ln]

			if lineDat.item[1] = searchVal then
				-- linedat = "BNS|itemiser:buyprice:sellprice:quantity"

				howMany = integerX(howMany)

				nett = integerX(lineDat.item[4]) - howMany

				if nett < 0 then
					sendMovieMessage(movie, username, "npc.shoperror", "SERR: There is insufficient stock in this item.")
					return FALSE
				end if

				cost = integerX(lineDat.item[3]) * howMany

				if exchangeSingleInvntItem(movie, username, itemiser, howMany, "gold", cost) then

					put nett into lineDat.item[4]
					put lineDat into npcServerFile.line[ln]

					lngld = 1
					repeat while npcServerFile.line[lngld] <> ""
						goldLine = npcServerFile.line[lngld]

						if goldLine.char[1..4] = "GLD|" then

							the itemdelimiter = "|"
							nettGold = integerX(goldLine.item[2]) + cost

							put nettGold into goldLine.item[2]
							put goldLine into npcServerFile.line[lngld]

							exit repeat

						end if

						lngld = lngld + 1
					end repeat

					file("DAT\DATAS\NPCS\" & npcCode & ".dam").write(npcServerFile)
					sendMovieMessage(movie, username, "npc.solditem", "Item is sold")

					return TRUE
				end if

				exit repeat

			end if

			ln = ln + 1

		end repeat

	end if

	sendMovieMessage(movie, username, "npc.shoperror", "SERR: You may have insufficient gold to buy all these items.")
	return FALSE

end buyFromNPC


-------------------------------------------------------------------
--// NPC Buy, I Sell
-------------------------------------------------------------------

on sellToNPC(movie, username, npcCode, sellItemiser, howMany)

	npcServerFile = string(file("DAT\DATAS\NPCS\" & npcCode & ".dam").read)

	itemiser = sellItemiser

	if itemiser.char[1..2] = "$s" then

		the itemdelimiter = "#"
		itmic = itemiser.item[1] & "%"
		put itmic into itemiser.item[1]

	end if

	searchVal = "BNS|" & sellItemiser

	if npcServerFile contains (searchVal & ":") then

		the itemdelimiter = ":"
		ln = 1

		repeat while npcServerFile.line[ln] <> ""
			lineDat = npcServerFile.line[ln]

			if lineDat.item[1] = searchVal then
				-- linedat = "BNS|itemiser:buyprice:sellprice:quantity"
				if sellItemiser.char[1..2] = "$s" then
					howMany = 1
				else
					howMany = integerX(howMany)
				end if

				nett = integerX(lineDat.item[4]) + howMany
				cost = integerX(lineDat.item[2]) * howMany

				put nett into lineDat.item[4]
				put lineDat into npcServerFile.line[ln]

				lngld = 1
				repeat while npcServerFile.line[lngld] <> ""
					goldLine = npcServerFile.line[lngld]

					if goldLine.char[1..4] = "GLD|" then

						the itemdelimiter = "|"
						nettGold = integerX(goldLine.item[2]) - cost

						if nettGold < 0 then
							sendMovieMessage(movie, username, "npc.shoperror", "SERR: There is insufficient gold to buy this item.")
							return FALSE
						end if

						put nettGold into goldLine.item[2]
						put goldLine into npcServerFile.line[lngld]

						exit repeat

					end if

					lngld = lngld + 1

				end repeat

				if exchangeSingleInvntItem(movie, username, "gold", cost, itemiser, howMany, TRUE) then

					file("DAT\DATAS\NPCS\" & npcCode & ".dam").write(npcServerFile)
					sendMovieMessage(movie, username, "npc.boughtitem", "Item is bought")

					return TRUE

				end if

				exit repeat

			end if

			ln = ln + 1

		end repeat

	end if

	sendMovieMessage(movie, username, "npc.shoperror", "SERR: You may not have the items to be sold.")
	return FALSE


end sellToNPC


