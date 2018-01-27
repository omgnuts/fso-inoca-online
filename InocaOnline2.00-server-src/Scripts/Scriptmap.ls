------------------------------------------------------------------------------------------
-- Multiuser Server version 3.0
-- ScriptMap.ls
--
-- This file is used by the Dispatcher.ls script provided with the server.
-- The loadScriptMapFile handler loads this file into memory and calls three handlers
-- to determine what scripts to load:
--
--    scriptMap() - lists scripts to attachto server movies and groups
--    globalScriptList() - lists scripts for global access
--    scriptObjectList() - lists script objects
--
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
--
-- As an alternative to listing all your global and object scripts here, your server
-- scripts can have their own globalScriptList() and scriptObjectList() handlers.
-- The Dispather.ls script will call these when the movie is created, and load the
-- scripts you specify.
--
-- Finally, it is possible for your scripts to call gDispatcher.loadOneScriptObjectFile() and
-- gDispatcher.loadOneGlobalScriptFile() to reload specific scripts.  This can be done without
-- restarting the server.  See the code in Dispatcher.ls for more details.
--
------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
--
-- The scriptMap() handler returns a list showing the associations between
-- movies, groups and scripts.  This list controls which scripts get called when
-- server events and messages arrive from movies that connect to the server.
--
-- Each element in the list is a property list.  Each property list should
-- have a #movieID property, a #groupID property, or both.  The #movieID identifies
-- the target movie.  The #groupID property identifies target groups.  Each property
-- list should also have a #scriptFileName property that indicates the name of the
-- script that receives server events.
--
-- The scriptMap handler below uses the append() command to construct its
-- list of property lists by adding them one at a time to the list variable
-- theMap.  To add additional scripts to the ScriptMap, add lines to the
-- handler below using the identical theMap.append() syntax and specifying
-- your own #movieID's and #scriptFileNames.
--
------------------------------------------------------------------------------------------
on scriptMap

  theMap = []

	theMap.append( [ #movieID: "inomov", #scriptFileName: "GameScripts.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "CommandScripts.ls" ] )

	theMap.append( [ #movieID: "inomov", #scriptFileName: "Initializations.ls" ] )
  theMap.append( [ #movieID: "inomov", #scriptFileName: "GlobalScripts.ls" ] )
  theMap.append( [ #movieID: "inomov", #scriptFileName: "GuildScripts.ls" ] )

	theMap.append( [ #movieID: "inomov", #scriptFileName: "Antihack.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "Md5Digester.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "Timers.ls" ] )

	theMap.append( [ #movieID: "inomov", #scriptFileName: "LogonHandler.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "LoaderHandler.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "InventoryHandler.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "MapHandler.ls" ] )
	
	theMap.append( [ #movieID: "inomov", #scriptFileName: "TradeScripts.ls" ] )
	theMap.append( [ #movieID: "inomov", #scriptFileName: "CustomApi.ls" ] )

	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Timeoutobjects.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "games.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "quests.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "building.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "treasure.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "shop.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "npcs.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "books.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Assassins.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Boss.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Cauldron.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Timers.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "CharCreate.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "GameEvents.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "CabCount.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Jail.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "BackupChar.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Events.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "MapRestrictions.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "cleanFunctions.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "Marriage.ls" ] )
	--theMap.append( [ #movieID: "inomov", #scriptFileName: "CaptureFlag.ls" ] )

  return theMap

end


----------------------------------------------------------------------------------------
-- The globalScriptList handler returns a list containing names of scripts that should
-- be loaded as global scripts.   To add additional scripts to the globalScriptList,
-- add lines to the handler below using the theList.Append() syntax and
-- specifying the names of the desired scripts.
----------------------------------------------------------------------------------------
on globalScriptList

  -- theList = [ "GlobalScripts.ls", "Assassins.ls", "Cauldron.ls", "Timers.ls", "games.ls", "quests.ls", "building.ls", "treasure.ls", "shop.ls", "npcs.ls", "books.ls", "Boss.ls", "Timeoutobjects.ls", "CharCreate", "GameEvents.ls", "CabCount.ls", "Antihack.ls", "Jail.ls", "BackupChar.ls", "Events.ls", "MapRestrictions.ls", "cleanFunctions.ls", "Marriage.ls", "CaptureFlag.ls" ]
  -- Add the names of any scripts that you want to load as global scripts
  -- theList.Append( "MyGlobalScripts.ls" )

	theList = [ "Initializations.ls", \
							"CommandScripts.ls", \
							"CustomApi.ls", \
							"Timers.ls" , \
							"GlobalScripts.ls", \
							"GuildScripts.ls", \
							"Antihack.ls", \
							"Md5Digester.ls", \
							"LogonHandler.ls", \
							"LoaderHandler.ls", \
							"InventoryHandler.ls", \
							"MapHandler.ls", \
							"TradeScripts.ls", \
							"GameScripts.ls" ]

  return theList

end


----------------------------------------------------------------------------------------
-- The scriptObjectList handler returns a list containing the names of script files
-- that should be loaded as script objects.  To add additional scripts to the scriptObjectList,
-- add lines to the handler below using the identical theList.Append() syntax and
-- specifying the names of the desired scripts.
----------------------------------------------------------------------------------------
on scriptObjectList

  theList = []

  -- Add the names of any scripts that you want to load as script objects
  -- theList.Append( "MyScriptObject.ls" )

  return theList

end
