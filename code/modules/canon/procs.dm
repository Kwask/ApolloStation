/proc/canonHandleRoundEnd()
	if( !config.canon )
		log_debug( "Didn't save the world because the round was non-canon" )
		return

	if( ticker.current_state == GAME_STATE_PREGAME )
		log_debug( "Didn't save the world because we were in the lobby" )
		return

	saveAllActiveCharacters()
	saveAllActiveAccounts()
	universe.saveToDB()

/proc/saveAllActiveCharacters()
	for( var/datum/character/C in all_characters )
		if( !C.ckey )
			log_debug( "Didn't save [C.name] because they had no ckey" )
			continue

		if( C.new_character )
			log_debug( "Didn't save [C.name] / ([C.ckey]) because they were a new character" )
			continue

		if( C.temporary ) // If they've been saved to the database previously
			log_debug( "Didn't save [C.name] / ([C.ckey]) because they were temporary" )
			continue

		if( !C.saveCharacter( 0, 0 ))
			log_debug( "Couldn't save [C.name] / ([C.ckey]) for some other reason" )
		else
			log_debug( "Saved [C.name] / ([C.ckey])" )

/proc/saveAllActiveAccounts()
	for( var/datum/character/C in all_characters )
		var/datum/account/A = C.account

		if( !istype( A ))
			continue

		if( A.new_account )
			log_debug( "Didn't save [A.name]'s account because they were a new character" )
			continue

		if( A.temporary ) // If they've been saved to the database previously
			log_debug( "Didn't save [A.name]'s account because they were temporary" )
			continue

		if( !A.saveAccount() )
			log_debug( "Couldn't save [A.name]'s account for some other reason" )
		else
			log_debug( "Saved [A.name]'s account" )
