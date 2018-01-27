on parseWarp(wdat)
	set demiSave = the itemdelimiter

	if (wdat contains ":") and (wdat contains "-") then
		set the itemdelimiter = ":"

		set mv = item 1 of wdat
		set xy = item 2 of wdat

		set the itemdelimiter = "-"
		set x = item 1 of xy
		set y = item 2 of xy

		set the itemdelimiter = demiSave
		return mv & " " & x & " " & y

	end if

	set the itemdelimiter = demiSave
	return ""
end parseWarp



------------------------------
-- Limited safe
-- user , FilName
------------------------------
on LimitedSafeCheck( user , FilName )
	----------------------------------------------------
	-- Global Mapper exeption
	----------------------------------------------------
	set Mapperfile = file("DAT\Mappers\" & user.name & ".txt").read

	if Mapperfile contains "Global" then return "ok"

	----------------------------------------------------
	-- Check if the letter restrictions are respected
	-- and get the XCoord and the YCoord
	----------------------------------------------------
	set the itemdelimiter = "."
	set FilName = item 1 of string(FilName)  -- x100y300

	set the itemdelimiter = "x"
	set FilName = item 2 of string(FilName)  -- 100y300

	set the itemdelimiter = "y"

	set XCoord = item 1 of string(FilName) -- 100
	set YCoord = item 2 of string(FilName) -- 300

	if integer(XCoord) = void or integer(YCoord) = void or integer(XCoord) < 0 or integer(YCoord) < 0 then

		set alphabets = "abcdefghijklmnopqrstuvwxyz"

			set xN = 1
			repeat while alphabets contains (char integer(xN) of XCoord)
				set xN = xN + 1
			end repeat
			set xN = xN - 1

			set yN = 1
			repeat while alphabets contains (char integer(yN) of XCoord)
				set yN = yN + 1
			end repeat
			set yN = yN - 1

			set xST = ""
			set yST = ""

			if xN > 0 then
				set xST = chars(XCoord, 1, xN)
				repeat with n = 1 to xN
					delete char 1 of XCoord
				end repeat
			end if

			if yN > 0 then
				set yST = chars(YCoord, 1, yN)
				repeat with n = 1 to yN
					delete char 1 of YCoord
				end repeat
			end if

			if xST <> yST then return "Not" -- both x y must be same cannot have xK100yf300

--			if char 1 of xST = "H" then set HMap = true

--	put "b4_XCoord = " & XCoord

			set iXCoord = integer(XCoord)
			set iYCoord = integer(YCoord)

			if string(iXcoord) <> string(XCoord) then return "Not"
			if string(iYcoord) <> string(YCoord) then return "Not"

			set Xcoord = iXCoord
			set Ycoord = iYCoord

--	put "aft_XCoord = " & XCoord

			if XCoord = void then return "Not"
			if YCoord = void then return "Not"
	end if


	----------------------------------------------------
	-- Check if you are allowed to save on those coords
	----------------------------------------------------
	set Counter = 0
	set allow = "Busy"

	set the itemdelimiter = "|"
	set lettersX = item 1 of string(Mapperfile)
	set rangeX = item 2 of string(Mapperfile)

	if lettersX contains ":" & xST & ":" then

--		if (XCoord > 10000 and XCoord < 20000) and (YCoord > 10000 and YCoord < 20000) and HMap = true then
--			return "Ok"
--		end if

		repeat while allow = "Busy"
			set the itemdelimiter = ":"
			XFloor = integer(item Counter + 1 of rangeX)
			XCeiling = integer(item Counter + 2 of rangeX)
			YFloor = integer(item Counter + 3 of rangeX)
			YCeiling = integer(item Counter + 4 of rangeX)
			set Counter = Counter + 4


			if XFloor = void or XCeiling = void or YFloor = void or YCeiling = void then
				return "Not"
			end if
			if XCoord > XFloor and XCoord < XCeiling and YCoord > YFloor and YCoord < YCeiling then
				return "ok"
			end if

		end repeat
	end if


---------------------------------------------
--// For practice mappers
--	set MapperLister = file("DAT\AccessList\Mappers.txt").read
--	if MapperLister contains ">*" & user.name & "*<" then set isPractice = TRUE
--	if isPractice and string(xST) = "" and string(yST) = "" then return "ok"
---------------------------------------------

	return "Not"
end