------------------------------------------------------------------------------------------
-- Dispatcher Script for Server Side Lingo Scripting
--
--    Version 3.0
--
-- This script is the main program that interfaces between the server
-- and lingo.  It controls how messages and events are dispatched to
-- lingo scripts.
------------------------------------------------------------------------------------------

-- Public properties
property pServer            -- Server supplied Server object.
property pUser              -- Server supplied user object for the LingoVM xtra
property pMovie
property Movie

-- Private properties
property pScriptMap         -- Map between movies & groups to scripts.
property pGlobalList        -- Global scripts
property pScriptObjectList  -- List of scripts to create objects from

global gDispatcher, TreasureList, MoveProp, MapPropList, Dispt, myPMovie          -- This object
global MovementQueue, CDKeys, tServer

------------------------------------------------------------------------------------------
-- First event from the Server
--    Initialize key variables.
------------------------------------------------------------------------------------------


on initialize (me, aUser, aServer)

  set CDKeys = file("DAT\SETTINGS\cd.txt").read
  set CDKeys = string(CDKeys)
  set MovementQueue = ""
  -- Save the parameters passed in
  set tServer = aServer
  pServer = aServer
  pUser = aUser
  gDispatcher = me
  gDispatcher.name = "Dispatcher"

  pGlobalList = []
  pScriptObjectList = []

  -- Load the Dispatcher configuration file
  me.loadScriptMap()

  -- Set the server abort check period.  If you have really long scripts, you
  -- can increase this.  You may, however, want to use threads instead
  pServer.abortCheckPeriod = 8000
  set Dispt = 0

   BuildTreasureList
   put "treasure loaded..."
   myPMovie=aServer.createServerMovie("inomov")

   UpdateBroadcastFiles()
	iniCounters()
	iniGames()

-- 1000 = 1sec
	timeout("TimeOutMQue").new(500, #RunTimeOutMQue, me)
-- timeout("TimeOutOneSec").new(1000, #RunTimeOutOneSec, me)
   timeout("TimeOutOneMin").new(60000, #RunTimeOutOneMin, me)
   timeout("TimeOutThreeMin").new(300000, #RunTimeOutThreeMin, me)
   timeout("TimeOutHalfHour").new(1800000, #RunTimeOutHalfHour, me)


end initialize


------------------------------------------------------------------------------------------
-- Last lingo call before the server shuts down.
------------------------------------------------------------------------------------------
on shutdown (me, aUser, aServer)

  pUser = VOID
  pServer = VOID
  pScriptMap = VOID
  pGlobalList = VOID
  pScriptObjectList = VOID

  clearGlobals()

end shutdown


------------------------------------------------------------------------------------------
-- Server issued config commands
--    Config commands are read by the Server from it's config file.
--    "ConfigDone" is the last one.
------------------------------------------------------------------------------------------
on configCommand (me, cmd)

  -- This version of Dispatcher.ls doesn't do anything with config commands.  You could
  -- add your own to the server configuration files (multiuser.cfg, etc) and pass in
  -- information as desired.

  --put "LingoVM configuration command " & cmd

end configCommand



------------------------------------------------------------------------------------------
-- Some event has happened on the server, so call the right routines
------------------------------------------------------------------------------------------
on serverEvent (me, event, movie, group, user)

  -- If we don't have a movie reference, derive one from the user object
  if voidP(movie) then
    if not voidP(user) then
      movie = user.serverMovie
    end if
    -- If we can't get it from the user, try the group
    if voidP(movie) then
      if not voidP(group) then
        movie = group.serverMovie
      end if
    end if
  end if

  case event of
   #userlogon:
   	checkAllowedMovieList (movie, user)
--   	userLogOna()
   #userLogoff:
   	UserLogOffa(user, movie)
  end case

  -- Use this code if you want to watch event order in the server console
  --  case event of
  --    #movieCreate, #movieDelete:
  --      put "LingoVM server event: " & event && movie.name
  --
  --    #groupCreate, #groupDelete:
  --      put "LingoVM server event: " & event && group.name && "in" && movie.name
  --
  --    #userLogon, #userLogoff:
  --      put "LingoVM server event: " & event && user.name && "in" && movie.name
  --
  --    #groupJoin, #groupLeave:
  --      put "LingoVM server event: " & event && user.name && "in" && group.name
  --
  --    otherwise:
  --      put "LingoVM server event: " & event
  --  end case


  -- Distribute the server event to the script objects in the script map
  distributeServerEvent(me, pScriptMap, event, movie, group, user)

end serverEvent


------------------------------------------------------------------------------------------
-- The server has received a message addressed to "System.Script"
------------------------------------------------------------------------------------------
on incomingMessage (me, recipientID, subject, senderID, errorCode, timeStamp, msg, sender, isUDP)

--put "LingoVM incomingMessage recipientID: " & recipientID & " subject:" & subject & " senderID:" & senderID & " errorCode:" & errorCode & " timeStamp:" & timeStamp & " sender:" & sender & " udp:" & isUDP

	if senderid <> sender.name then exit
  -- These commands may be useful during development; be sure to
  -- disable them for a production server
  --
  --  case subject of
  --    "System.Script.Admin.Reload":
  --      put "LingoVM: reloading all scripts."
  --        tlist = thread().list
  --        repeat with t in tlist
  --          t.forget()
  --        end repeat
  --      the timeoutList = []
  --      me.loadScriptMap()
  --      exit
  --    "System.Script.Admin.Ping":
  --      sender.sendMessage(subject, msg)
  --      exit
  --    "System.Script.Admin.ShowState":
  --      showServerState()
  --      exit
  --  end case

  -- Use the sender's movie as the movie. This effectively blocks inter-movie
  -- messaging for Lingo commands.  If you want to enable it, you could send the movie
  -- ID with the subject or as part of the command.
  movie = sender.serverMovie
  user = sender

  -- This code can extract a group name from the command, like "System.Script.myGroup"
  -- This allows you to direct messages to a particular group script

  -- Get the group name from the recipient's 3rd item
  lastDelimiter = the itemDelimiter
  the itemDelimiter = "."
  targetGroup = recipientID.item[3]
  the itemDelimiter = lastDelimiter
  groupID = VOID
  if targetGroup <> "" then
    groupID = "@" & targetGroup -- Pass in group as string
  end if

  fullMsg = [ errorCode: errorCode, recipientID: recipientID, \
  senderID: senderID, subject: subject, \
  timeStamp: timeStamp, content: msg, udp: isUDP ]

  didCall = distributeServerEvent( me, pScriptMap, #incomingMessage, movie, groupID, user, fullMsg )

  -- If we didn't call a function for this, send a message back to the user
  if not didCall then
    sender.sendMessage( subject, msg, -2147216193, isUDP, recipientID )
  end if

end incomingMessage



------------------------------------------------------------------------------------------
-- Issued by Lingo engine when break point hit.  This normally isn't called, since a
-- debugger script should be installed to actually handle debugging.
------------------------------------------------------------------------------------------
on breakPoint( me, thread )
  -- Since we shouldn't be called here (use a debug script instead), we assume something's
  -- wrong and just try to resume running the thread
  if objectp( thread ) then
    thread.resume()
  end if
end

------------------------------------------------------------------------------------------
-- Issued by Lingo engine when error hit.
------------------------------------------------------------------------------------------
on error( me, thread, errMsg, errLine, errVal )
  -- Un-comment this section if you're getting unexpected errors.  Better yet, use the debugger.
  --  put "LingoVM encountered an error:"
  --  put "  thread is  " & thread
  --  put "  errMsg is  " & errMsg
  --  put "  errLine is " & errLine
  --  put "  errVal is  " & errVal
end

------------------------------------------------------------------------------------------
-- Issued by Lingo when abortCheckPeriod has been reached during script execution.
-- This normally aborts the script, assuming it's taking too long
--
-- Return value 0 means stop script
-- Return value non-zero means continue script execution
------------------------------------------------------------------------------------------
on abortCheck (me, thread)

  -- Add any code you want to handle a script aborting

  -- The abortCheckPeriod must be reset before returning
  pServer.abortCheckPeriod = 5000
  return 0
end




------------------------------------------------------------------------------------------
-- Test. Display Server state.
------------------------------------------------------------------------------------------
on showServerState
  -- Loop through all movies
  nmovies = pServer.serverMovieCount
  repeat with im = 1 to nmovies
    mov = pServer.serverMovie(im)
    if not voidP(mov) then
      -- Loop through all groups
      ngroup = mov.serverGroupCount
      put "Movie:" & mov.name & " serverUserCount:" && mov.serverUserCount & " groupCount:" & ngroup
      repeat with ig = 1 to ngroup
        grp = mov.serverGroup(ig)
        if not voidP(grp) then
          msg = "Group: "& grp.name & " members:"
          -- Loop through all users in each group
          nuser = grp.serverUserCount
          repeat with iu = 1 to nuser
            user = grp.serverUser(iu)
            if not voidP(user) then
              msg = msg &" "&user.name
            end if
          end repeat
          put msg
        end if
      end repeat
    end if
  end repeat
end



------------------------------------------------------------------------------------------
--  Load in the script map file
------------------------------------------------------------------------------------------
on loadScriptMap ( me )
  me.loadScriptMapFile ("ScriptMap.ls")
end


------------------------------------------------------------------------------------------
-- Read in and run the script that defines the Script Map
-- The handler scriptMap should return a list of property lists in the following form
--     [ [ movieID: "Chat", scriptFileName: "Chat.ls" ] ] or
--     [ [ movieID: "Chat", groupID: "RedRoom", scriptFileName: "Chat.ls" ] ]
--
-- For each entry we add:
--     #scriptObject: parent script object compiled from the .ls file
--     #childMap: property list for mapping movieID+groupID to a child of parent script
------------------------------------------------------------------------------------------
on loadScriptMapFile( me, fileName )

  -- First read in the script map file
  fn = pServer.scriptsPath & fileName
  str = file(fn).read -- loadScriptMapFile
  if not stringp(str) then
    put "LingoVM xtra error - failed reading" & " " & fn
    return
  end if

  -- Now compile it into a script object
  scr = createScript(str)
  if voidP(scr) then
    put "LingoVM xtra error - failed loading" & " " & fn
    return
  end if

  -- Call the scriptMap function
  if( scr.handler( #scriptMap ) ) then
    val = scr.scriptMap()
    if not listP( val ) then
      put "LingoVM xtra error - scriptMap() didn't return a valid list."
      put val
      return
    else
      -- Process each entry in the scriptmap list
      repeat with i = 1 to val.count
        curScriptEntry = val[i]
        if listp(curScriptEntry) then
          -- Try to compile a script object from the filename
          scriptObject = me.compileOneScriptFile( curScriptEntry[ #scriptFileName ], #script )
          if not voidP(scriptObject) then

            -- Add the entry in script Map and make an empty childmap
            curScriptEntry[ #scriptObject ] = scriptObject
            curScriptEntry[ #childMap ] = [:]

            -- See if the newly loaded script has any script objects or global scripts to load

            me.readGlobalScripts( scriptObject )

            me.readScriptObjects( scriptObject )
          end if
        else
          put "LingoVM scriptMap returned an entry that's not a list" & " " & curScriptEntry
        end if
      end repeat
      -- Save the whole list in our property
      pScriptMap = val

    end if
  end if

  -- Load the global scripts
  me.readGlobalScripts( scr )

  -- Load in the script objects
  me.readScriptObjects( scr )

  -- If you're interested, display what was loaded
  -- put "ScriptMap:      " & pScriptMap
  -- put "Global scripts: " & pGlobalList
  -- put "Script objects: " & pScriptObjectList

end  loadScriptMapFile


-------------------------------------------------------------------------------------------
-- Routine to read in a list of global scripts and load them.  The targetScript has
-- a handler called globalScriptList() which returns a list of scripts to load.
-------------------------------------------------------------------------------------------
on readGlobalScripts( me, targetScript )
  if( targetScript.handler( #globalScriptList ) ) then
    val = targetScript.globalScriptList()
    if listP( val ) then
      -- Compile each entry in the global script list
      repeat with i = 1 to val.count
        me.loadOneGlobalScriptFile( val[i] )
      end repeat
    end if
  end if
end readGlobalScripts


-------------------------------------------------------------------------------------------
-- Routine to read in a list of global scripts and load them.  The targetScript has
-- a handler called scriptObjectList() which returns a list of scripts to load.
-------------------------------------------------------------------------------------------
on readScriptObjects( me, targetScript )
  if( targetScript.handler( #scriptObjectList ) ) then
    val = targetScript.scriptObjectList()
    if listP( val ) then
      -- Compile each entry in the global script list
      repeat with i = 1 to val.count
        me.loadOneScriptObjectFile( val[i] )
      end repeat
    end if
  end if
end readScriptObjects


-------------------------------------------------------------------------------------------
-- Routine to read in and load one file for script objects
--
-- You can call this routine while the server is running to re-compile an existing script.
-- It won't replace previously compiled verisons, but future script objects will use the
-- new code.
-------------------------------------------------------------------------------------------
on loadOneScriptObjectFile( me, scriptFileName )

  me.loadOneScriptFile( scriptFileName, #script, pScriptObjectList )

end loadOneScriptObjectFile


-------------------------------------------------------------------------------------------
-- Routine to read in and load one file for global scripts
--
-- You can call this routine while the server is running to re-compile an existing script.
-------------------------------------------------------------------------------------------
on loadOneGlobalScriptFile( me, scriptFileName )

  me.loadOneScriptFile( scriptFileName, #global, pGlobalList )

end loadOneGlobalScriptFile



-------------------------------------------------------------------------------------------
-- Routine to read in and load one file for script objects
--
-- You can call this routine while the server is loading to re-compile an existing script.
-- It won't replace previously compiled verisons, but future script objects will use the
-- new code.
-------------------------------------------------------------------------------------------
on loadOneScriptFile( me, scriptFileName, kindOfScript, listOfScripts )

  scriptObject = me.compileOneScriptFile( scriptFileName, kindOfScript )
  if not voidP( scriptObject ) then
    -- Add it to the global script list.  First see if there is an existing match,
    -- otherwise append it to the list.
    targetScriptName = removeFileExtension( scriptFileName )
    repeat with i = 1 to listOfScripts.count
      if ( listP( listOfScripts[i] ) ) then
        if ( listOfScripts[i].name = targetScriptName ) then
          -- Found it in the list already, so replace it with the new one
          listOfScripts[i] = scriptObject
          scriptObject = VOID
        end if
      end if
    end repeat

    -- If we didn't find it in the list, add to the end
    if objectP( scriptObject ) then
      listOfScripts.append( scriptObject )
    end if
  end if

end loadOneScriptFile


-------------------------------------------------------------------------------------------
-- Utility routine to read in one script file and compile it
-------------------------------------------------------------------------------------------
on compileOneScriptFile( me, scriptFileName, scriptType )

  scriptObject = VOID
  if stringP( scriptFileName ) then

    -- Read in all the text from the file
    str = file( pServer.scriptsPath & scriptFileName ).read
    if not stringP( str ) then
      -- Couldn't find the file ?  Try appending ".ls"
      fileTypeStr = offset( ".ls", scriptFileName )
      if ( fileTypeStr = 0 ) then
        fullName = pServer.scriptsPath & scriptFileName & ".ls"
        str = file( fullName ).read
      end if
    end if

    if stringP(str) then
      -- Now compile it into a script object
      scriptObject = createScript( str, scriptType )
      if not voidP( scriptObject ) then
        -- Strip off the extension and set the object name
        scriptObject.name = removeFileExtension( scriptFileName )
      else
        put "LingoVM problems compiling script file " & " " & scriptFileName
      end if
    else
      put "LingoVM problems reading script file " & " " & scriptFileName
    end if
  else
    put "LingoVM scriptMap doesn't have a valid scriptFileName in " & " " & string( scriptFileName )
  end if
  return scriptObject

end compileOneScriptFile


-------------------------------------------------------------------------------------------
-- Utility routine to strip off the file extension from the name
-------------------------------------------------------------------------------------------
on removeFileExtension fromFileName

  dot = offset(".ls", fromFileName )
  if ( dot = 0 ) then
    dot = offset(".txt", fromFileName )
  end if

  if dot > 1 and dot >= fromFileName.length - 3 then
    retValue = fromFileName.char[1..dot-1]
  else
    retValue = fromFileName
  end if

  return retValue

end removeFileExtension



-------------------------------------------------------------------------------------------
-- Send Event to all the script objects in the list map that match movie and/or group.
-- We could setup sorted tables to quickly find by event, movie, and group
-- so we don't blindly issues call in the inner loop
-- !! We could have sort prop list that maps movie+group to script map index
-- !! we only search map linearly when pair not found
-- !! Issue is when to remove entries from prop list
-- !! maybe never remove, 'cause if sorted not much of a hit
-------------------------------------------------------------------------------------------
on distributeServerEvent(me, map, event, movie, group, user, fullMsg)

  didCall = false

  if not voidP(movie) then
    if stringp(movie) then
      movieID = movie
    else
      movieID = movie.name
    end if
  end if

  if not voidP(group) then
    if stringp(group) then
      groupID = group
    else
      groupID = group.name
    end if
  end if

  -- Loop through the script map and find one that matches this event
  n = map.count
  repeat with i = 1 to n
    ent = map[i]
    ent_movieID = ent[ #movieID ]

    if wildCompare(ent_movieID, movieID) then
      -- It matched the movie ID (or it was VOID), so get the group ID
      ent_groupID = ent[ #groupID ]

      -- If both movie ID and group ID are void, continue searching for another match
      if ( voidP( ent_movieID ) and voidP( ent_groupID ) ) then
        next repeat
      end if

      if wildCompare(ent_groupID, groupID) then

        -- Matched on group ID (or it was VOID), so get the corresponding script object
        ent_scriptObject = ent[#scriptObject]
        if voidP(ent_scriptObject) then
          -- There's no script available for this entry
          next repeat
        end if

        -- Find the child object matching the movie/group pair.  We use a combination of the movieID
        -- and groupID.   On #movieCreate, the groupID will be void, and we end up with just the movieID.
        movieGroupID = movieID & groupID
        childMap = ent[ #childMap ]

        -- Check for messages that creates child object
        case event of
          #movieCreate:
            if voidP(ent_groupID) then
              -- If no groupID is given then #movieCreate makes the child
              child = ent_scriptObject.new()
              child[ #server ] = pServer
              childMap[ movieID ] = child
            end if
          #groupCreate:
            if not voidP(ent_groupID) then
              -- If any groupID is given then #groupCreate makes child
              child = ent_scriptObject.new()
              child[ #server ] = pServer
              childMap[ movieGroupID ] = child
            end if
        end case

        -- Dispatch only if handler is present in object
        if (ent_scriptObject.handler(event)) then

          -- First see if there's an offspring script for this movie and group name
          child = childMap[ movieGroupID ]

          if voidP(child) then
            -- If none for movie and group name, use just the movie to get the offspring script
            child = childMap[ movieID ]
          end if

          if voidP(child) then
            -- There's no child in the map, so just use parent script
            child = ent_scriptObject
          end if

          -- Actually call the handler
          call(event, child, movie, group, user, fullMsg)
          didCall = true

        end if

        -- Check for messages that dispose of a child object
        case event of
          #movieDelete:
            if voidP(ent_groupID) then
              -- If no groupID is given then #movieDelete deletes child
              childMap.deleteProp( movieGroupID )
              --put "Deleted child "&event&" childMap="&childMap&" child="&child
            end if
          #groupDelete:
            if not voidP(ent_groupID) then
              -- If any groupID is given then #groupDelete deletes child
              childMap.deleteProp( movieGroupID )
              --put "Deleted child "&event&" childMap="&childMap&" child="&child
            end if
        end case

      end if
    end if
  end repeat

  return didCall

end


------------------------------------------------------------------------------------------
-- Compare wild string against plain string.
-- Wild string may end in a "*" to do partial compare
------------------------------------------------------------------------------------------
on wildCompare(wildStr, plainStr)
  if voidP(wildStr) then wildStr = "*"
  if voidP(plainStr) then plainStr = ""
  L = length(wildStr)
  if wildStr.char[L] = "*" then
    if L <= 1 then return 1
    if length(plainStr) < L-1 then return 0
    return wildStr.char[1..L-1] = plainStr.char[1..L-1]
  else
    return wildStr = plainStr
  end if
end


------------------------------------------------------------------------------------------
-- Search the script map to find a script by it's script name.
-- Returns the script object or Void
-- The LingoVM xtra calls this routine to locate a script object we want to create
------------------------------------------------------------------------------------------
on findScriptByName( me, scriptName )

  scriptName = removeFileExtension( scriptName )

  -- First look in the script object list
  sciptObj = me.findScriptObjectByName( scriptName )
  if objectP( sciptObj ) then
    return sciptObj
  end if

  -- Next try to find the script in the script map
  if not voidP( pScriptMap ) then
    repeat with ce in pScriptMap
      scriptObj = ce[#scriptObject]
      if not voidP( scriptObj ) then
        if ( scriptObj.name = scriptName ) then
          return scriptObj
        end if
      end if
    end repeat
  end if

  -- Finally, see if it's the Dispatcher script
  if ( scriptName = "Dispatcher" ) then
    return gDispatcher
  end if

  -- OK, the script's not found.  See if we can compile it
  if ( objectP( pServer ) ) then
    if ( scriptName contains ".ls" ) then
      scriptFileName = scriptName
    else
      scriptFileName = scriptName & ".ls"
    end if

    if ( file( pServer.scriptsPath & scriptFileName ).exists ) then
      me.loadOneScriptFile( scriptFileName, #script, pScriptObjectList )
    end if

    -- See if it was compiled and added to the list
    scriptObj = findScriptObjectByName( me, scriptName )
    if objectP( scriptObj ) then
      return scriptObj
    end if
  end if

  -- Script not found, so return VOID
  -- put "findScriptByName() failed to locate " & scriptName
  -- put "   script map is: " & pScriptMap
  -- put "   script object list is " & pScriptObjectList
  return VOID

end



------------------------------------------------------------------------------------------
-- Search the script object list to find a script by it's script name.
-- Returns the script object or Void
------------------------------------------------------------------------------------------
on findScriptObjectByName( me, scriptName )

  repeat with ce in pScriptObjectList
    if objectP( ce ) then
      if ( ce.name = scriptName ) then
        return ce
      end if
    end if
  end repeat
  return VOID

end findScriptObjectByName



-------------------------------------------------------------------------------------------
-- Return a list of all script objects
-------------------------------------------------------------------------------------------
on getListOfAllScripts( me )

  listOScripts = []

  -- First get all the scripts in pScriptObjectList
  if not voidP( pScriptObjectList ) then
    repeat with ce in pScriptObjectList
      if objectP( ce ) then
        if ( listOScripts.getPos( ce ) = 0 ) then
          listOScripts.Append( ce )
        end if
      end if
    end repeat
  end if

  -- Next get all from the script map
  if not voidP( pScriptMap ) then
    repeat with ce in pScriptMap
      scriptObj = ce[#scriptObject]
      if not voidP( scriptObj ) then
        if ( listOScripts.getPos( scriptObj ) = 0 ) then
          listOScripts.Append( scriptObj )
        end if
      end if
    end repeat
  end if

  -- Finally add the Dispatcher script
  if not voidP( gDispatcher ) then
    if ( listOScripts.getPos( gDispatcher ) = 0 ) then
      listOScripts.Append( gDispatcher )
    end if
  end if

  return listOScripts

end getListOfAllScripts

on RunTimeOutMQue
	TimeOutRun("MQue")
end

on RunTimeOutOneSec
	TimeOutRun("OneSec")
end

on RunTimeOutOneMin
	TimeOutRun("OneMin")
end

on RunTimeOutThreeMin
	TimeOutRun("ThreeMin")
end

on RunTimeOutHalfHour
	TimeOutRun("HalfHour")
end

