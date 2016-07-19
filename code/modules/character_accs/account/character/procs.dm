/proc/getCharRecordID( var/id )
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM character_records WHERE acc_id = '[id]'")
	query.Execute()

	var/sql_id = 0
	while( query.NextRow() )
		sql_id = query.item[1]
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return 0

	if( sql_id )
		return sql_id

/datum/account/character/New( var/key )
	ckey = ckey( key )

	if( !department )
		LoadDepartment( CIVILIAN )

	owner = new( acc = src )

	..()

	temporary = 1

/datum/account/character/proc/copyFrom( var/datum/character/C )
	if( !istype( C ))
		return 0

	owner = C

	birth_date = owner.birth_date

	updateVar( "char_id", "id" )
	updateVar( "name" )
	updateVar( "gender" )
	updateVar( "species" )
	updateVar( "DNA" )
	updateVar( "fingerprints" )
	updateVar( "birth_date" )
	updateVar( "blood_type" )

	if( !username || username == "username" )
		username = generateUsername( 1 )

	if( istype( owner.char_mob ) && crew )
		var/assignment
		var/job

		if( owner.char_mob.mind && owner.char_mob.mind.assigned_role)
			job = owner.char_mob.mind.assigned_role
		else if(owner.char_mob.job)
			job = owner.char_mob.job
		else
			job = "Unassigned"

		if( owner.char_mob.mind && owner.char_mob.mind.role_alt_title)
			assignment = owner.char_mob.mind.role_alt_title
		else
			assignment = job

		if( last_job != job )
			last_job = job
			log_debug( "Updating job" )
			temporary = 0

		if( last_role != assignment )
			last_role = assignment
			log_debug( "Updating assignment" )
			temporary = 0

	return 1

/datum/account/character/proc/updateVar( var/copy_to, var/copy_from )
	if( !copy_to )
		return 0

	if( !copy_from )
		copy_from = copy_to // Using the same value for both if the second one isnt given

	if( !istype( owner ))
		return 0

	if( !owner.vars[copy_from] )
		return 0

	if( !src.vars[copy_to] )
		return 0

	if( src.vars[copy_to] == owner.vars[copy_from] )
		return 0

	src.vars[copy_to] = owner.vars[copy_from]
	temporary = 0

	return 1

/datum/account/character/generateUsername( var/temp = 0 )
	temporary = temp

	if( owner )
		name = owner.name

	var/stripped_name = ckey( name )
	var/usern = ""
	var/max_size = 10

	for( var/i = 0, i < 50, i++ )
		var/firstchar = 1
		var/lastchar = max_size-2
		if( lentext( name ) < lastchar )
			lastchar = lentext( name )+1

		usern += copytext( stripped_name, firstchar, lastchar )
		if( birth_date && birth_date.len == 3 )
			usern += add_zero( num2text( birth_date[3] ), 2 )
		else
			usern += add_zero( rand( 0, 99 ), 2 )
		usern += num2text( rand( 0, 9 ))

		if( !getUsernameID( usern ) && usern != "username" )
			username = usern
			return usern

/datum/account/character/saveAccount( var/force = 0 )
	if( temporary && !force ) // If we're just a temporary character and we're not forcing a save, dont save to database
		return 0

	id = ..()

	if( !id )
		log_debug( "SAVE CHARACTER: Didn't save [username]'s account / ([ckey]) because they didnt have a valid acc_id" )
		return 0

	var/sql_id = getCharRecordID( id )

	var/list/variables = list()

	variables["acc_id"] = num2text( id )

	variables["name"] = html_encode( sql_sanitize_text( name ))
	variables["gender"] = html_encode( sql_sanitize_text( gender ))
	variables["birth_date"] = html_encode( list2params( birth_date ))
	variables["spawnpoint"] = html_encode( sql_sanitize_text( spawnpoint ))

	// Character species
	variables["species"] = html_encode( sql_sanitize_text( species ))

	// Secondary language
	variables["additional_language"] = html_encode( sql_sanitize_text( additional_language ))

	// Some faction information.
	variables["home_system"] = html_encode( sql_sanitize_text( home_system ))
	variables["citizenship"] = html_encode( sql_sanitize_text( citizenship ))
	variables["faction"] = html_encode( sql_sanitize_text( faction ))
	variables["religion"] = html_encode( sql_sanitize_text( religion ))

	// Jobs, uses bitflags
	variables["department"] = sanitize_integer( department.department_id, 0, 255, 0 )
	variables["last_job"] = html_encode( sql_sanitize_text( last_job ))
	variables["last_role"] = html_encode( sql_sanitize_text( last_role ))
	variables["roles"] = html_encode( list2params( roles ))

	// The default name of a job like "Medical Doctor"
	variables["player_alt_titles"] = html_encode( list2params( player_alt_titles ))

	// Character records, these are written by the player
	variables["med_record"] = html_encode( sql_sanitize_text( med_record ))
	variables["sec_record"] = html_encode( sql_sanitize_text( sec_record ))
	variables["gen_record"] = html_encode( sql_sanitize_text( gen_record ))
	variables["exploit_record"] = html_encode( sql_sanitize_text( exploit_record ))

	// Relation to NanoTrasen
	variables["nanotrasen_relation"] = html_encode( sql_sanitize_text( nanotrasen_relation ))

	// Unique identifiers
	variables["DNA"] = html_encode( sql_sanitize_text( DNA ))
	variables["fingerprints"] = html_encode( sql_sanitize_text( fingerprints ))
	variables["blood_type"] = html_encode( sql_sanitize_text( blood_type ))

	// Status effects
	variables["employment_status"] = html_encode( sql_sanitize_text( employment_status ))
	variables["felon"] = sanitize_integer( felon, 0, BITFLAGS_MAX, 0 )
	variables["prison_date"] = html_encode( list2params( prison_date ))

	variables["antag_data"] = html_encode( list2params( antag_data ))

	// Location of traitor uplink
	variables["uplink_location"] = html_encode( sql_sanitize_text( uplink_location ))

	// Some extra account info
	variables["first_shift_day"] = sanitize_integer( first_shift_day, 0, 1.8446744e+19, 0 )
	variables["last_shift_day"] = sanitize_integer( last_shift_day, 0, 1.8446744e+19, 0 )

	var/list/names = list()
	var/list/values = list()
	for( var/name in variables )
		names += sql_sanitize_text( name )
		values += variables[name]

	if(sql_id)
		if( names.len != values.len )
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the variables length did not match the values" )
			return 0

		var/query_params = ""
		for( var/i = 1; i <= names.len; i++ )
			query_params += "[names[i]]='[values[i]]'"
			if( i != names.len )
				query_params += ","

		var/DBQuery/query_update = dbcon.NewQuery("UPDATE character_records SET [query_params] WHERE id = '[sql_id]'")
		if( !query_update.Execute())
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the SQL update failed" )
			return 0
	else
		var/query_names = list2text( names, "," )
		query_names += sql_sanitize_text( ", id" )

		var/query_values = list2text( values, "','" )
		query_values += "', null"

		// This needs a single quote before query_values because otherwise there will be an odd number of single quotes
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO character_records ([query_names]) VALUES ('[query_values])")
		if( !query_insert.Execute() )
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the SQL insert failed" )
			return 0

		id = getUsernameID( username )
		sql_id = getCharRecordID( id )

	new_account = 0

	return sql_id

/datum/account/character/loadAccount( var/character_ident )
	if( !character_ident )
		log_debug( "No character identity!" )
		return 0

	if( ckey && !checkCharacter( character_ident, ckey ))
		log_debug( "Character's account does not belong to the given ckey!" )
		return 0

	establish_db_connection()
	if( !dbcon.IsConnected() )
		log_debug( "Database is not connected!" )
		return 0

	if( !..() )
		return 0

	var/list/variables = list()

	variables["name"] = "text"
	variables["gender"] = "text"
	variables["birth_date"] = "birth_date"
	variables["spawnpoint"] = "text"

	// Character species
	variables["species"] = "text"

	// Secondary language
	variables["additional_language"] = "text"

	// Some faction information.
	variables["home_system"] = "text"
	variables["citizenship"] = "text"
	variables["faction"] = "text"
	variables["religion"] = "text"

	// Jobs, uses bitflags
	variables["department"] = "department"
	variables["last_job"] = "text"
	variables["last_role"] = "text"
	variables["roles"] = "params"

	// The default name of a job like "Medical Doctor"
	variables["player_alt_titles"] = "params"

	// Character records, these are written by the player
	variables["med_record"] = "text"
	variables["sec_record"] = "text"
	variables["gen_record"] = "text"
	variables["exploit_record"] = "text"

	// Relation to NanoTrasen
	variables["nanotrasen_relation"] = "text"

	// Unique identifiers
	variables["DNA"] = "text"
	variables["fingerprints"] = "text"
	variables["blood_type"] = "text"

	// Status effects
	variables["employment_status"] = "text"
	variables["felon"] = "number"
	variables["prison_date"] = "prison_date"

	variables["antag_data"] = "antag_data"

	// Location of traitor uplink
	variables["uplink_location"] = "text"

	// Some extra account info
	variables["first_shift_day"] = "number"
	variables["last_shift_day"] = "number"

	var/query_names = list2text( variables, "," )

	temporary = 1 // All characters are temporary until they enter the game

	var/DBQuery/query = dbcon.NewQuery("SELECT [query_names] FROM character_records WHERE id = '[character_ident]'")
	if( !query.Execute() )
		log_debug( "Could not execute query!" )
		return 0

	if( !query.NextRow() )
		log_debug( "Query has no data!" )
		return 0

	for( var/i = 1; i <= variables.len; i++ )
		var/value = query.item[i]

		switch( variables[variables[i]] )
			if( "text" )
				value = html_decode( sanitize_text( value, "ERROR" ))
			if( "number" )
				value = text2num( value )
			if( "params" )
				value = params2list( html_decode( value ))
				if( !value )
					value = list()
			if( "list" )
				value = text2list( html_decode( value ))
				if( !value )
					value = list()
			if( "language" )
				if( value in all_languages )
					value = all_languages[value]
				else
					value = "None"
			if( "birth_date" )
				birth_date = list()

				for( var/num in params2list( value ))
					if( istext( num ))
						num = text2num( html_decode( num ))
						if( num )
							birth_date.Add( num )

				continue
			if( "department" )
				LoadDepartment( text2num( value ))
				continue // Dont need to set the variable on this one
			if( "antag_data" )
				var/list/L = params2list( html_decode( value ))
				if( !L || !L.len )
					L = list( "notoriety" =  0, "persistant" = 0, "faction" = "Gorlex Marauders", "career_length" = 0 )
				for(var/V in L)
					if( V != "faction" ) // hardcode but pls go away
						L[V] = text2num( L[V] )
				value = L
			if( "prison_date" )
				prison_date = list()

				for( var/num in params2list( html_decode( value )))
					if( istext( num ))
						num = text2num( num )
						if( num )
							prison_date.Add( num )

				value = prison_date
			if( "roles" )
				var/list/L = params2list( html_decode( value ))

				if( !L )
					L = list()

				for( var/role in L )
					switch( role )
						if( "Chemist" )
							L.Remove( "Chemist" )
							L["Scientist"] = "High"
						if( "Roboticist" )
							L.Remove( "Roboticist" )
							L["Scientist"] = "High"
						if( "Xenobiologist" )
							L.Remove( "Xenobiologist" )
							L["Senior Scientist"] = "High"
						if( "Atmospheric Technician" )
							L.Remove( "Atmospheric Technician" )
							L["Senior Engineer"] = "High"
						if( "Virologist" )
							L.Remove( "Virologist" )
							L["Senior Medical Doctor"] = "High"
						if( "Psychiatrist" )
							L.Remove( "Psychiatrist" )
							L["Medical Doctor"] = "High"
				value = L

		src.vars[variables[i]] = value

	new_account = 0

	owner.loadCharacter( char_id )
	owner.update_preview_icon()

	// Src vars dont update quick enough to use immediately
	if( !username || username == "username" )
		username = generateUsername()

	if( !password || password == "password" )
		password = generatePassword()

	if( !pin || pin == "0000" )
		pin = generatePin()

	return character_ident

// Primarily for copying role data to antags
/datum/account/character/proc/copy_metadata_to( var/datum/account/character/A )
	if( !istype( A ))
		return

	A.roles = src.roles
	A.department = src.department
	A.antag_data = src.antag_data.Copy()
	A.uplink_location = src.uplink_location

/datum/account/character/proc/useCharacterToken( var/type, var/mob/user )
	var/num = user.client.character_tokens[type]
	if( !num || num <= 0 )
		return

	switch( type )
		if( "Command" )
			if( !istype( department ))
				LoadDepartment( CIVILIAN )

			roles |= getAllPromotablePositions()

		if( "Antagonist" )
			antag_data["persistant"] = 1

	num--

	user.client.character_tokens[type] = num
	user.client.saveTokens()

/datum/account/character/proc/isPersistantAntag()
	if( !antag_data )
		return 0

	if( !antag_data["persistant"] )
		return 0

	return 1

/datum/account/character/proc/getAntagFaction()
	if( !isPersistantAntag() )
		return 0

	return faction_controller.get_faction( antag_data["faction"] )

/datum/account/character/proc/canJoin()
	if( employment_status != "Active" )
		return 0

	if( prison_date && prison_date.len )
		var/days = daysTilDate( universe.date, prison_date )
		if( days > 0 )
			return 0

	return 1

/datum/account/character/proc/enterMob()
	crew = 1

	last_shift_day = universe.round_number

	if( !first_shift_day )
		first_shift_day = universe.round_number
