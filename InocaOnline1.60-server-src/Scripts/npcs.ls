Global QuestList, NewQuest, FactionPowers


on SendNPCs MyxFile, me, movie, group, user, fullMsg, TheFiles

  set NPCList = string(MyxFile)
  set the itemdelimiter = "+"

  set NPC1 = VOID
  set NPC2 = VOID
  set NPC3 = VOID
  set NPC4 = VOID

  set the itemdelimiter = "|"
  if item 1 of NPCList <> VOID then set NPC1 = item 1 of NPCList
  if item 2 of NPCList <> VOID then set NPC2 = item 2 of NPCList
  if item 3 of NPCList <> VOID then set NPC3 = item 3 of NPCList
  if item 4 of NPCList <> VOID then set NPC4 = item 4 of NPCList

  set the itemdelimiter = ":"

  if NPC1 <> VOID then set NPC1 = item 1 of NPC1
  if NPC2 <> VOID then set NPC2 = item 1 of NPC2
  if NPC3 <> VOID then set NPC3 = item 1 of NPC3
  if NPC4 <> VOID then set NPC4 = item 1 of NPC4

-------------------------------------------------------
  if NPC1 <> "" then
   set NPCName = NPC1 & ".txt"
   set FilName = "DAT\NPC\"
   FilName = FilName & NPCName
   set MyFile = string(file(FilName).read)
   set MyFile = NPC1 & "*" & MyFile
   --if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC1", MyFile)
   if MyFile <> VOID then set TheFiles = TheFiles & MyFile & "^"
   if MyFile = VOID then set TheFiles = TheFiles & "^"
  end if

  if NPC2 <> "" then
   set NPCName = NPC2 & ".txt"
   set FilName = "DAT\NPC\"
   FilName = FilName & NPCName
   set MyFile = string(file(FilName).read)
   set MyFile = NPC2 & "*" & MyFile
   --if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC2", MyFile)
   if MyFile <> VOID then set TheFiles = TheFiles & MyFile & "^"
   if MyFile = VOID then set TheFiles = TheFiles & "^"
  end if

  if NPC3 <> "" then
   set NPCName = NPC3 & ".txt"
   set FilName = "DAT\NPC\"
   FilName = FilName & NPCName
   set MyFile = string(file(FilName).read)
   set MyFile = NPC3 & "*" & MyFile
   --if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC3", MyFile)
   if MyFile <> VOID then set TheFiles = TheFiles & MyFile & "^"
   if MyFile = VOID then set TheFiles = TheFiles & "^"
  end if

  if NPC4 <> "" then
   set NPCName = NPC4 & ".txt"
   set FilName = "DAT\NPC\"
   FilName = FilName & NPCName
   set MyFile = string(file(FilName).read)
   set MyFile = NPC4 & "*" & MyFile
   --if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC4", MyFile)
   if MyFile <> VOID then set TheFiles = TheFiles & MyFile & "^"
   if MyFile = VOID then set TheFiles = TheFiles & "^"
  end if

  sendMovieMessage(movie, user.name, "GetMap", TheFiles)
end



on RefNPC(me, movie, group, user, fullmsg)

  set TheDat = fullmsg.content
  set the itemdelimiter = ":"
  set NPCPos = item 1 of TheDat
  set NPCName = item 2 of TheDat

  if NPCPos = "180" then
    set FilName = "DAT\NPC\" & NPCName & ".txt"
    set MyFile = file(FilName).read
    set MyFile = NPCName & "*" & MyFile
    if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC1", MyFile)
  end if

  if NPCPos = "181" then
    set FilName = "DAT\NPC\" & NPCName
    set MyFile = file(FilName).read
    set MyFile = NPCName & "*" & MyFile
    if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC2", MyFile)
  end if

  if NPCPos = "182" then
    set FilName = "DAT\NPC\" & NPCName
    set MyFile = file(FilName).read
    set MyFile = NPCName & "*" & MyFile
    if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC3", MyFile)
  end if

  if NPCPos = "183" then
    set FilName = "DAT\NPC\" & NPCName
    set MyFile = file(FilName).read
    set MyFile = NPCName & "*" & MyFile
    if Myfile <> VOID then sendMovieMessage(movie, user.name, "SendNPC4", MyFile)
  end if


end

