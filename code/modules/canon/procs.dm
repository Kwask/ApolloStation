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
			continue

		if( C.new_character )
			continue

		if( C.temporary ) // If they've been saved to the database previously
			continue

		C.saveCharacter( 0, 0 )

/proc/saveAllActiveAccounts()
	for( var/datum/character/C in all_characters )
		var/datum/account/A = C.account

		if( !istype( A ))
			continue

		if( A.new_account )
			continue

		if( A.temporary ) // If they've been saved to the database previously
			continue

		A.saveAccount()
