/datum/account
	var/ckey
	var/id

	var/domain_name = "apollo.nt"

	// Login information
	var/username = "username"				// Account username to login with
	var/password = "password"				// Simple password to login with
	var/pin = "0000"						// Less secure form of password, number between 0000 and 9999

	/* What level of security does their account have?
		0 - PIN only
		1 - Password only
		2 - Password and ID
	*/
	var/security_level = 1

	// Record access information
	var/clearence_level = "None"
	var/record_access = 0


	// Non-saved variables, these are for one round
	var/new_account = 1 // Is this a new character?
	var/temporary = 1 // Should we avoid saving this datum on round end? By default it isnt saved unless changes are made
	var/crew = 0 // Is the associated character aboard the station?

