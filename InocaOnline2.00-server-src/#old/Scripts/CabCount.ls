
on getCabbyCounter(cabType)
	set saveDemi = the itemdelimiter

	set OrigCabType = cabType

	set counterFile = file("DAT\CABCOUNT\CabCounter.txt").read
	if cabType = "Cabinet#" then set cabType = "Normal Cabinet#" --// Double check cos cabinet is badly mixed with Wind Cabby

	set n = 1
	set the itemdelimiter = "|"
	repeat while item n of counterFile <> ""
		if item n of counterFile contains cabType then
			set foundCounter = item n of counterFile
			set the itemdelimiter = ":"
			if item 1 of foundCounter = cabType then
				-- // found the item
				set newValue = integer(item 2 of foundCounter) + 1

				set the itemdelimiter = "|"
				put (cabType & ":" & newValue) into item n of counterFile
				file("DAT\CABCOUNT\CabCounter.txt").write(counterFile)

				set the itemdelimiter = saveDemi
				return OrigCabType & newValue
			else
				set the itemdelimiter = saveDemi
				return ""
			end if
		end if
		set n = n + 1
	end repeat

	set the itemdelimiter = saveDemi
	return "" -- // if there is no such cabType

end