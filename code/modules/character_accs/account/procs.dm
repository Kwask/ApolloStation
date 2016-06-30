/proc/accUsernameExists( var/username )
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM accounts WHERE username = '[username]'")
	query.Execute()

	var/sql_id = 0
	while( query.NextRow() )
		sql_id = query.item[1]
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)

	if( sql_id )
		return 1

	return 0

/datum/account/New( var/key, var/datum/character/char )
	if( istype( char ))
		owner = char

	ckey = ckey( key )

	if( !department )
		LoadDepartment( CIVILIAN )

	..()

	temporary = 1

/datum/account/proc/copyFrom( var/datum/character/C )
	if( !istype( C ))
		return 0

	owner = C
	owner_hash = owner.hash

	birth_date = owner.birth_date

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

/datum/account/proc/updateVar( var/var_name )
	if( !istype( owner ))
		return 0

	if( !var_name )
		return 0

	if( !owner.vars[var_name] )
		return 0

	if( !src.vars[var_name] )
		return 0

	if( src.vars[var_name] == owner.vars[var_name] )
		return 0

	src.vars[var_name] = owner.vars[var_name]
	temporary = 0

	return 1

/datum/account/proc/generatePin( var/temp = 0 )
	temporary = temp

	pin = add_zero( num2text( rand( 0, 9999 )), 4 )

	return pin

/datum/account/proc/generatePassword( var/temp = 0 )
	temporary = temp

	password = ckey( "[pick( adjectives )][rand( 0, 100 )]" )

	return password

/datum/account/proc/generateUsername( var/temp = 0 )
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

		if( !accUsernameExists( usern ) && usern != "username" )
			username = usern
			return usern

/datum/account/proc/generateEmail()
	return "[username]@[domain_name]"

/datum/account/proc/saveAccount( var/force = 0 )
	if( temporary && !force ) // If we're just a temporary character and we're not forcing a save, dont save to database
		return 0

	var/list/variables = list()

	variables["ckey"] = ckey( ckey )
	variables["owner_hash"] = html_encode( sql_sanitize_text( owner_hash ))

	variables["domain_name"] = html_encode( sql_sanitize_text( domain_name ))

	variables["username"] = html_encode( sql_sanitize_text( username ))
	variables["password"] = html_encode( sql_sanitize_text( password ))
	variables["pin"] = html_encode( sql_sanitize_text( pin ))

	variables["security_level"] = sanitize_integer( security_level, 0, 255, 0 )
	variables["clearence_level"] = html_encode( sql_sanitize_text( clearence_level ))

	variables["record_access"] = sanitize_integer( record_access, 0, 65536, 0 )

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

	establish_db_connection()
	if( !dbcon.IsConnected() )
		log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the database wasn't connected" )
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM accounts WHERE owner_hash = '[variables["owner_hash"]]'")
	query.Execute()
	var/sql_id = 0
	while(query.NextRow())
		sql_id = query.item[1]
		break

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because of an invalid sql ID" )
			return 0

	if(sql_id)
		if( names.len != values.len )
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the variables length did not match the values" )
			return 0

		var/query_params = ""
		for( var/i = 1; i <= names.len; i++ )
			query_params += "[names[i]]='[values[i]]'"
			if( i != names.len )
				query_params += ","

		var/DBQuery/query_update = dbcon.NewQuery("UPDATE accounts SET [query_params] WHERE owner_hash = '[variables["owner_hash"]]'")
		if( !query_update.Execute())
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the SQL update failed" )
			return 0
	else
		var/query_names = list2text( names, "," )
		query_names += sql_sanitize_text( ", id" )

		var/query_values = list2text( values, "','" )
		query_values += "', null"

		// This needs a single quote before query_values because otherwise there will be an odd number of single quotes
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO accounts ([query_names]) VALUES ('[query_values])")
		if( !query_insert.Execute() )
			log_debug( "SAVE CHARACTER: Didn't save [name]'s account / ([ckey]) because the SQL insert failed" )
			return 0

	new_account = 0

	return 1

/datum/account/proc/loadAccount( var/character_ident )
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

	var/list/variables = list()

	variables["owner_hash"] = "text"
	variables["domain_name"] = "text"

	variables["username"] = "text"
	variables["password"] = "text"
	variables["pin"] = "text"

	variables["security_level"] = "text"
	variables["clearence_level"] = "text"

	variables["record_access"] = "text"

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
	var/sql_ident = html_encode( sql_sanitize_text( character_ident ))

	temporary = 1 // All characters are temporary until they enter the game

	var/DBQuery/query = dbcon.NewQuery("SELECT [query_names] FROM accounts WHERE owner_hash = '[sql_ident]'")
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
	owner.update_preview_icon()

	// Src vars dont update quick enough to use immediately
	if( !username || username == "username" )
		log_debug( "Username was [username], regen'ing" )
		username = generateUsername()

	if( !password || password == "password" )
		log_debug( "Password was [password], regen'ing" )
		password = generatePassword()

	if( !pin || pin == "0000" )
		log_debug( "Pin was [pin], regen'ing" )
		pin = generatePin()

	return 1
