/datum/character
	var/mob/living/carbon/human/char_mob
	var/datum/account/account

	var/ckey

	// Basic information
	var/name							//our character's name
	var/gender = MALE					//gender of character (well duh)
	var/age = AGE_DEFAULT				//age of character

	var/blood_type = "A+"				//blood type (not-chooseable)

	// Default clothing
	var/underwear = 1					// underwear type
	var/undershirt = 1					// undershirt type
	var/backpack = 2					// backpack type

	// Cosmetic features
	var/hair_style = "Bald"				// Hair type
	var/hair_face_style = "Shaved"		// Facial hair type
	var/hair_color = "#000000"			// Hair color
	var/hair_face_color	= "#000000"		// Face hair color

	var/skin_tone = SKIN_TONE_DEFAULT	// Skin tone
	var/skin_color = "#000000"			// Skin color

	var/eye_color = "#000000"			// Eye color

	// Character species
	var/species = "Human"               // Species to use.

	// Secondary language
	var/additional_language = "None"

	// Custom spawn gear
	var/list/gear

	// Maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	// Flavor texts
	var/flavor_texts_human
	var/flavor_texts_robot

	// Character disabilities
	var/disabilities = 0

	var/DNA
	var/fingerprints
	var/hash // The character's unique md5 hash

	// Skills
	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	var/datum/browser/menu

	// Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null
	var/species_preview   // Used for the species selection window.

	var/new_character = 1 // Is this a new character?
	var/temporary = 1 // Should we avoid saving this datum on round end?
