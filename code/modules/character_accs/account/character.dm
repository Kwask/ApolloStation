/datum/account/character
	var/datum/character/owner

	// Basic information
	var/name
	var/gender = MALE					//gender of character (well duh)
	var/list/birth_date = list()

	var/spawnpoint = "Arrivals Shuttle" //where this character will spawn (0-2).

	// Character species
	var/species = "Human"               // Species to use.

	// Secondary language
	var/additional_language = "None"

	// Some faction information.
	var/home_system = "Unset"           //System of birth.
	var/citizenship = "None"            //Current home system.
	var/faction = "None"                //Antag faction/general associated faction.
	var/religion = "None"               //Religious association.

	// Job vars, these are used in the job selection screen and hiring computer
	var/datum/department/department
	var/last_job = "Unassigned"
	var/last_role = "Unassigned"
	var/list/roles = list( "Assistant" = "Low" ) // Roles that the player has unlocked

	// The default name of a job like "Medical Doctor"
	var/list/player_alt_titles = list()

	// Character records, these are written by the player
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""

	// Relation to NanoTrasen
	var/nanotrasen_relation = "Neutral"

	var/DNA
	var/fingerprints
	var/blood_type = "A+"				//blood type (not-chooseable)

	// A few status effects
	var/employment_status = "Active" // Is this character employed and alive or gone for good?
	var/felon = 0 // Is this character a convicted felon?
	var/list/prison_date // The date that they get released from prison

	/*
	The var below stores antag data, all current indexes are
		notoriety	-	How infamous this antag is, the more infamous, the better contracts they can acquire
		persistant 	-	Is this character a persistant antag? If not, none of the following indexes will be used

	/// - persistant antag variables - ///
		faction		-	Which syndicate faction is this antag a member of?
		dismissed	-	Has this player been dismissed from the syndicate?
	*/
	var/list/antag_data = list()

	// Location of traitor uplink
	var/uplink_location = "PDA"

	var/first_shift_day = 0 // When was this character first played?
	var/last_shift_day = 0 // When was this character last played?

	var/char_id = 0

	var/datum/browser/menu

	// Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null
	var/species_preview   // Used for the species selection window.
