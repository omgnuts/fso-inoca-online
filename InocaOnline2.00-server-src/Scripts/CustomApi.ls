--"------------------------------------------------------
-- // gets an item from a delimited string
--------------------------------------------------------
-- convenience method - only use it occassionally
--------------------------------------------------------
-- Return: the item (i) from the base
--------------------------------------------------------

on getItemOf(i, base)

	savei = the itemdelimiter
	the itemdelimiter = ":"

	retVal = base.item[i]

	the itemdelimiter = savei
	return retVal

end getItemOf

on isExistsInGenericList(dataToFind, dataFilePath)

	dataFile = string(file(dataFilePath).read)

	if dataFile contains ("@" & dataToFind) then
		dataFile = VOID
		return TRUE
	end if

	dataFile = VOID
	return FALSE
end

--"------------------------------------------------------
-- // Add an item to a list
--------------------------------------------------------
-- Adds a list item to a listfile
--------------------------------------------------------
-- Return:
-- 		* if successful: TRUE
-- 		* otherwise 	 : FALSE
--------------------------------------------------------
on addToGenericList(data, dataFilePath)

	dataFile = string(file(dataFilePath).read)
  dataFile = "@" & data & ":" & dataFile

	file(dataFilePath).write(dataFile)
	dataFile = VOID

end

--"------------------------------------------------------
-- // Remove an item to a list
--------------------------------------------------------
-- Remove a list item to a listfile
--------------------------------------------------------
-- Return:
-- 		* if successful: TRUE
-- 		* otherwise 	 : FALSE
--------------------------------------------------------
on removeFromGenericList(dataToFind, dataFilePath, dlm) -- dlm is optional

	-- dataToFind should not contain "*jtducky" the asterisk is used to
	-- do a faster check

	dataFile = string(file(dataFilePath).read)

	dataToFind = "@" & dataToFind

	if dataFile contains (dataToFind & dlm) then

		the itemdelimiter = ":"
		n = 1

		if dlm = ":" then -- ":" is the default delimiter

			repeat while dataFile.item[n] <> ""

				if dataFile.item[n] = dataToFind then
					delete dataFile.item[n]
					file(dataFilePath).write(dataFile)

					dataFile = VOID
					return TRUE
				end if
				n = n + 1

			end repeat

		else

			dataToFind = dataToFind & dlm

			repeat while dataFile.item[n] <> ""

				if dataFile.item[n] contains (dataToFind) then
					delete dataFile.item[n]
					file(dataFilePath).write(dataFile)

					dataFile = VOID
					return TRUE
				end if
				n = n + 1

			end repeat

		end if

	end if

	dataFile = VOID
	return FALSE

end




------------ old methods

on addToList(listItem , listFile)

	listContent = file("DAT\" & listFile).read

	the itemdelimiter = ":"

	n = 1
	repeat while (listContent.item[n] <> "")
		if listContent.item[n] = "@@" then
			put listItem into listContent.item[n]
			file("DAT\" & listFile).write(listContent)
			return TRUE
		end if
		n = n + 1
	end repeat

	if listContent = "" then
		listContent = ".:" & listItem & ":"
	else
		listContent = listContent & listItem & ":"
	end if
	file("DAT\" & listFile).write(listContent)

	return TRUE
end


on removeFromList(listItem, listFile, dLm)

	listContent = file("DAT\" & listFile).read

	if listContent contains (":" & listItem & dLm) then
		n = 1
		the itemdelimiter = ":"

		if dLm = ":" then

			repeat while listContent.item[n] <> ""
				if listContent.item[n] = listItem  then
					put "@@" into listContent.item[n]
					file("DAT\" & listFile).write(listContent)
					return TRUE
				end if
				n = n + 1
			end repeat
			return FALSE

		else if dLm = "-" then

			repeat while listContent.item[n] <> ""
				if listContent.item[n] contains (listItem & dLm) then

					currPointer = listContent.item[n]
					the itemdelimiter = "-"

					if currPointer.item[1] = listItem then
						the itemdelimiter = ":"
						put "@@" into listContent.item[n]
						file("DAT\" & listFile).write(listContent)
						return TRUE
					end if

					the itemdelimiter = ":"

				end if
				set n = n + 1
			end repeat

			return FALSE

		end if

	end if

	return FALSE
end removeFromList
