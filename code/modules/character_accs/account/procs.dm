/proc/getUsernameID( var/username )
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM account.accounts WHERE username = '[username]'")
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
		return sql_id

	return 0

/datum/account/New( var/key )
	ckey = ckey( key )

	..()

	temporary = 1

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


	var/usern = ""

	for( var/i = 0, i < 50, i++ )
		usern += pick( adjectives )
		usern += add_zero( rand( 0, 9999 ), rand( 1, 4 ))

		if( !getUsernameID( usern ) && usern != "username" )
			username = usern
			return usern

/datum/account/proc/generateEmail()
	return "[username]@[domain_name]"

/datum/account/proc/saveAccount( var/force = 0 )
	if( temporary && !force ) // If we're just a temporary character and we're not forcing a save, dont save to database
		return 0

	var/list/variables = list()

	variables["ckey"] = ckey( ckey )

	variables["domain_name"] = html_encode( sql_sanitize_text( domain_name ))

	variables["username"] = html_encode( sql_sanitize_text( username ))
	variables["password"] = html_encode( sql_sanitize_text( password ))
	variables["pin"] = html_encode( sql_sanitize_text( pin ))

	variables["security_level"] = sanitize_integer( security_level, 0, 255, 0 )
	variables["clearence_level"] = html_encode( sql_sanitize_text( clearence_level ))

	variables["record_access"] = sanitize_integer( record_access, 0, 65536, 0 )

	var/list/names = list()
	var/list/values = list()
	for( var/N in variables )
		names += sql_sanitize_text( N )
		values += variables[N]

	establish_db_connection()
	if( !dbcon.IsConnected() )
		log_debug( "SAVE CHARACTER: Didn't save [username]'s account / ([ckey]) because the database wasn't connected" )
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM account.accounts WHERE id = '[id]'")
	query.Execute()
	var/sql_id = getUsernameID( username )

	if(sql_id)
		if( names.len != values.len )
			log_debug( "SAVE CHARACTER: Didn't save [username]'s account / ([ckey]) because the variables length did not match the values" )
			return 0

		var/query_params = ""
		for( var/i = 1; i <= names.len; i++ )
			query_params += "[names[i]]='[values[i]]'"
			if( i != names.len )
				query_params += ","

		var/DBQuery/query_update = dbcon.NewQuery("UPDATE account.accounts SET [query_params] WHERE id = '[id]'")
		if( !query_update.Execute())
			log_debug( "SAVE CHARACTER: Didn't save [username]'s account / ([ckey]) because the SQL update failed" )
			return 0
	else
		var/query_names = list2text( names, "," )
		query_names += sql_sanitize_text( ", id" )

		var/query_values = list2text( values, "','" )
		query_values += "', null"

		// This needs a single quote before query_values because otherwise there will be an odd number of single quotes
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO account.accounts ([query_names]) VALUES ('[query_values])")
		if( !query_insert.Execute() )
			log_debug( "SAVE CHARACTER: Didn't save [username]'s account / ([ckey]) because the SQL insert failed" )
			return 0

		sql_id = getUsernameID( username )

	new_account = 0

	return sql_id

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

	variables["ckey"] = ckey( ckey )
	variables["id"] = "number"

	variables["domain_name"] = "text"

	variables["username"] = "text"
	variables["password"] = "text"
	variables["pin"] = "text"

	variables["security_level"] = "number"
	variables["clearence_level"] = "text"

	variables["record_access"] = "number"

	var/query_names = list2text( variables, "," )

	temporary = 1 // All characters are temporary until they enter the game

	var/DBQuery/query = dbcon.NewQuery("SELECT [query_names] FROM account.accounts WHERE id = '[character_ident]'")
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

		src.vars[variables[i]] = value

	new_account = 0

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

	return character_ident
