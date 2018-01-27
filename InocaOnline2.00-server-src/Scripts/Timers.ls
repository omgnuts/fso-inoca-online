on TimeOutRun(TInterval)

	global myPMovie

	case TInterval of

		"HalfSec":
			--
			--global MovementQueue
			--if MovementQueue <> "" then
			--  set the itemdelimiter = "`"
			--  repeat with n = 1 to 12
			--    set the itemdelimiter = "`"
			--    set cMQ = item n of MovementQueue
			--    if cMQ <> VOID then
			--      set the itemdelimiter = ":"
			--      set WhichMap = item 1 of cMQ
			--      sendMovieMessage(myPMovie, WhichMap , "ServerQueue", cMQ)
			--    end if
			--  end repeat
			--  set MovementQueue = ""
			--end if


			exit

		"OneSec":

			exit


		"OneMin":

			--Global MuteCounter
			--
			--if MuteCounter = 15 then set MuteCounter = 1
			--else set MuteCounter = MuteCounter + 1
			--
			--set MuteList = file("DAT\settings\MutePlayerList.txt").read
			--
			--set theitemdelimiter = ":"
			--set n = 1
			--
			--if MuteCounter > 10 then
			--
			--  repeat while item n of MuteList <> ""
			--    if item n of Mutelist <> "@@" then
			--      set muteda = item n of Mutelist
			--      set the itemdelimiter = "-"
			--      set username = string(item 1 of muteda)
			--      set ucount = integer(item 2 of muteda)
			--
			--      if (MuteCounter - ucount >= 10) then
			--        RemoveFromList(username, "settings\MutePlayerList.txt", "-")
			--        sendMovieMessage(myPMovie, username, "sqa",  "You have been voiced by the server.")
			--      end if
			--
			--      set the itemdelimiter = ":"
			--    end if
			--    set n = n +1
			--  end repeat
			--
			--else
			--
			--  repeat while item n of MuteList <> ""
			--    if item n of Mutelist <> "@@" then
			--      set muteda = item n of Mutelist
			--      set the itemdelimiter = "-"
			--      set username = string(item 1 of muteda)
			--      set ucount = integer(item 2 of muteda)
			--
			--      if (MuteCounter +15 - ucount >= 10) and (ucount > MuteCounter) then
			--        RemoveFromList(username, "settings\MutePlayerList.txt", "-")
			--        sendMovieMessage(myPMovie, username, "sqa",  "You have been voiced by the server.")
			--      end if
			--
			--      set the itemdelimiter = ":"
			--    end if
			--    set n = n +1
			--  end repeat
			--
			--
			--end if

			--// Games

			exit

		"ThreeMin":

			checkUserMax()


			-- sendMovieMessage(myPMovie, "@AllUsers", "broadcast|5",  "Play Capture The Flag (Beta)! Type +joinctf to play CTF on Inoca for free!")
			exit

		"HalfHour":

			--sendMovieMessage(myPMovie, "@AllUsers", "broadcast|5",  "Win the Inoca Lottery! Buy a ticket for 500g and stand a chance to win $15,000 gold. Type +buy lottery ticket now!")
			exit

	end case


end
