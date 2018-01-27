Global myPMovie, MovementQueue

on TimeOutRun(TInterval)

	case TInterval of
		"MQue":

				if MovementQueue <> "" then
					set the itemdelimiter = "`"
					repeat with n = 1 to 12
						set the itemdelimiter = "`"
						set cMQ = item n of MovementQueue
						if cMQ <> VOID then
							set the itemdelimiter = ":"
							set WhichMap = item 1 of cMQ
							sendMovieMessage(myPMovie, WhichMap , "ServerQueue", cMQ)
						end if
					end repeat
					set MovementQueue = ""
				end if

			exit

		"OneSec":

			exit


		"OneMin":

			Global MuteCounter

			if MuteCounter = 15 then set MuteCounter = 1
			else set MuteCounter = MuteCounter + 1

			set MuteList = file("DAT\settings\MutePlayerList.txt").read

			set theitemdelimiter = ":"
			set n = 1

			if MuteCounter > 10 then

				repeat while item n of MuteList <> ""
					if item n of Mutelist <> "@@" then
						set muteda = item n of Mutelist
						set the itemdelimiter = "-"
						set username = string(item 1 of muteda)
						set ucount = integer(item 2 of muteda)

						if (MuteCounter - ucount >= 10) then
							RemoveFromList(username, "settings\MutePlayerList.txt", "-")
							sendMovieMessage(myPMovie, username, "sqa",  "You have been voiced by the server.")
						end if

						set the itemdelimiter = ":"
					end if
					set n = n +1
				end repeat

			else

				repeat while item n of MuteList <> ""
					if item n of Mutelist <> "@@" then
						set muteda = item n of Mutelist
						set the itemdelimiter = "-"
						set username = string(item 1 of muteda)
						set ucount = integer(item 2 of muteda)

						if (MuteCounter +15 - ucount >= 10) and (ucount > MuteCounter) then
							RemoveFromList(username, "settings\MutePlayerList.txt", "-")
							sendMovieMessage(myPMovie, username, "sqa",  "You have been voiced by the server.")
						end if

						set the itemdelimiter = ":"
					end if
					set n = n +1
				end repeat

			end if

			--// Games

			exit

		"ThreeMin":
			sendMovieMessage(myPMovie, "@AllUsers", "broadcast|5",  "Play Capture The Flag (Beta)! Type +joinctf to play CTF on Inoca for free!")

		"HalfHour":
			sendMovieMessage(myPMovie, "@AllUsers", "broadcast|5",  "Win the Inoca Lottery! Buy a ticket for 500g and stand a chance to win $15,000 gold. Type +buy lottery ticket now!")
			exit

	end case


end




on DoorSwitch(MapName, OldDoor, NewDoor, DoorX, DoorY)

 set TheDt = "!`( " & OldDoor & ":" & NewDoor & ":" & DoorX & ":" & DoorY

 set the itemdelimiter = "i"
 set GroupN = "@" & item 1 of MapName
 sendMovieMessage(myPMovie, GroupN, "chatmsg", TheDt)
 set the itemdelimiter = "|"

 set MapFile = file("DAT\ITEMS\" & MapName).read

  repeat with x = 1 to 20
     if item x of MapFile contains OldDoor then
        set DoorFL = item x of MapFile
        set the itemdelimiter = ":"
        put NewDoor into item 1 of DoorFL
        set the itemdelimiter = "|"
        put DoorFL into item x of MapFile
     end if
  end repeat

  file("DAT\ITEMS\" & MapName).write(MapFile)
end


on DropSomethingNPC(TheMap, TheItem)

set the itemdelimiter = "`"
   set FilName = TheMap
   set NewItem = TheItem
   set ItDt = TheItem

   set ItemList = file("DAT\ITEMS\" & FilName).read
   set the ItemDelimiter = "|"
   if item 20 of ItemList = "" then set OneToPlace = 20
   if item 19 of ItemList = "" then set OneToPlace = 19
   if item 18 of ItemList = "" then set OneToPlace = 18
   if item 17 of ItemList = "" then set OneToPlace = 17
   if item 16 of ItemList = "" then set OneToPlace = 16
   if item 15 of ItemList = "" then set OneToPlace = 15
   if item 14 of ItemList = "" then set OneToPlace = 14
   if item 13 of ItemList = "" then set OneToPlace = 13
   if item 12 of ItemList = "" then set OneToPlace = 12
   if item 11 of ItemList = "" then set OneToPlace = 11
   if item 10 of ItemList = "" then set OneToPlace = 10
   if item 9 of ItemList = "" then set OneToPlace = 9
   if item 8 of ItemList = "" then set OneToPlace = 8
   if item 7 of ItemList = "" then set OneToPlace = 7
   if item 6 of ItemList = "" then set OneToPlace = 6
   if item 5 of ItemList = "" then set OneToPlace = 5
   if item 4 of ItemList = "" then set OneToPlace = 4
   if item 3 of ItemList = "" then set OneToPlace = 3
   if item 2 of ItemList = "" then set OneToPlace = 2
   if item 1 of ItemList = "" then set OneToPlace = 1

   set the itemdelimiter = ":"

   set TheGoods = item 1 of ItDt & ":" & item 2 of ItDt
   set the ItemDelimiter = "|"
   put TheGoods into item OnetoPlace of ItemList

   if ItemList contains "|" then
    else
    exit
   end if

   file("DAT\ITEMS\" & FilName).write(ItemList)

 set the itemdelimiter = ":"
 set WhichItemYo = item 1 of ItDt
 set WhichItemXY = item 2 of ItDt
 set the itemdelimiter = "-"
 set WhichX = item 1 of WhichItemXY
 set WhichY = item 2 of WhichItemXY

 set TheDt = "!(( " & WhichItemYo & ":" & WhichX & ":" & WhichY

 set the itemdelimiter = "i"
 set GroupN = "@" & item 1 of TheMap
 sendMovieMessage(myPMovie, GroupN, "chatmsg", TheDt)


   end if
  end
