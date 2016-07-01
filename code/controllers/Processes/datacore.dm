/datum/controller/process/datacore
	var/global/list/medical = list()
	var/global/list/general = list()
	var/global/list/security = list()

	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/global/list/locked = list()

	var/max_employee_inactivity = 60 // If they've not been on-station within this many rounds, then they're not loaded

	var/global/list/employee_pool = list() // A list of all employees who have participated within at least one of the last max_employee_inactivity rounds
	var/global/list/crewmembers = list() // A list of all employees currently on-station

/datum/controller/process/datacore/New()
	..()

	data_core = src
	active_controllers += src

/datum/controller/process/datacore/setup()
	name = "employee database"
	schedule_interval = 50

	data_core.loadFromDB()

/datum/controller/process/datacore/proc/get_manifest(monochrome, OOC)
	var/list/heads = new()
	var/list/sec = new()
	var/list/eng = new()
	var/list/med = new()
	var/list/sci = new()
	var/list/crg = new()
	var/list/civ = new()
	var/list/bot = new()
	var/list/misc = new()
	var/list/isactive = new()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Activity</th></tr>
	"}
	var/even = 0
	// sort mobs
	for(var/datum/data/record/t in data_core.general)
		if( !t.fields["is_crew"] )
			continue

		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]
		if(OOC)
			var/active = 0
			for(var/mob/M in player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 * 60 * 10)
					active = 1
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = t.fields["p_stat"]
			//world << "[name]: [rank]"
			//cael - to prevent multiple appearances of a player/job combination, add a continue after each line
		var/department = 0
		if(real_rank in command_positions)
			heads[name] = rank
			department = 1
		if(real_rank in security_positions)
			sec[name] = rank
			department = 1
		if(real_rank in engineering_positions)
			eng[name] = rank
			department = 1
		if(real_rank in medical_positions)
			med[name] = rank
			department = 1
		if(real_rank in science_positions)
			sci[name] = rank
			department = 1
		if(real_rank in cargo_positions)
			crg[name] = rank
			department = 1
		if(real_rank in civilian_positions)
			civ[name] = rank
			department = 1
		if(real_rank in nonhuman_positions)
			bot[name] = rank
			department = 1
		if(!department && !(name in heads))
			misc[name] = rank
	if(heads.len > 0)
		dat += "<tr><th colspan=3>Heads</th></tr>"
		for(name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(sec.len > 0)
		dat += "<tr><th colspan=3>Security</th></tr>"
		for(name in sec)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sec[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(eng.len > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(med.len > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(sci.len > 0)
		dat += "<tr><th colspan=3>Science</th></tr>"
		for(name in sci)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[sci[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(crg.len > 0)
		dat += "<tr><th colspan=3>Supply</th></tr>"
		for(name in crg)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[crg[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(civ.len > 0)
		dat += "<tr><th colspan=3>Civilian</th></tr>"
		for(name in civ)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[civ[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// in case somebody is insane and added them to the manifest, why not
	if(bot.len > 0)
		dat += "<tr><th colspan=3>Silicon</th></tr>"
		for(name in bot)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[bot[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// misc guys
	if(misc.len > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat


/*
We can't just insert in HTML into the nanoUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /datum/controller/process/datacore/proc/manifest_inject( ), or manifest_insert( )
*/

var/global/list/PDA_Manifest = list()
var/global/ManifestJSON

/datum/controller/process/datacore/proc/get_manifest_json()
	if(PDA_Manifest.len)
		return
	var/heads[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/crg[0]
	var/civ[0]
	var/bot[0]
	var/misc[0]
	for(var/datum/data/record/t in data_core.general)
		if( !t.fields["is_crew"] )
			continue

		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]
		var/isactive = t.fields["p_stat"]
		var/department = 0
		var/depthead = 0 			// Department Heads will be placed at the top of their lists.
		if(real_rank in command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			depthead = 1
			if(rank=="Captain" && heads.len != 1)
				heads.Swap(1,heads.len)

		if(real_rank in security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sec.len != 1)
				sec.Swap(1,sec.len)

		if(real_rank in engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && eng.len != 1)
				eng.Swap(1,eng.len)

		if(real_rank in medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && med.len != 1)
				med.Swap(1,med.len)

		if(real_rank in science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && sci.len != 1)
				sci.Swap(1,sci.len)

		if(real_rank in cargo_positions)
			crg[++crg.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && crg.len != 1)
				crg.Swap(1,crg.len)

		if(real_rank in civilian_positions)
			civ[++civ.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && civ.len != 1)
				civ.Swap(1,civ.len)

		if(real_rank in nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive)


	PDA_Manifest = list(\
		"heads" = heads,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"crg" = crg,\
		"civ" = civ,\
		"bot" = bot,\
		"misc" = misc\
		)
	ManifestJSON = list2json(PDA_Manifest)
	return

/datum/controller/process/datacore/proc/getCharacter( var/ident )
	if( !ident )
		return null

	for( var/datum/character/C in employee_pool )
		if( C.id == ident )
			return C

/datum/controller/process/datacore/proc/loadFromDB()
	establish_db_connection()
	if( !dbcon.IsConnected() )
		return

	var/min_round_number = universe.round_number-max_employee_inactivity

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM accounts WHERE last_shift_day > [min_round_number] ORDER BY name")
	query.Execute()

	while( query.NextRow() )
		var/datum/character/C = new()
		var/ident = text2num( query.item[1] )

		if( !ident )
			log_debug( "Failed to load character" )
			qdel( C )
			continue

		C.loadCharacter( ident )
		employee_pool += C

/datum/controller/process/datacore/proc/queue_manifest(var/nosleep = 0)
	if(!nosleep)
		manifest()
		return

	spawn(40)
		manifest()

/datum/controller/process/datacore/proc/manifest()
	for(var/mob/living/carbon/human/H in player_list)
		crewmembers += H.character
		manifest_inject(H.character.account)
	return

/datum/controller/process/datacore/proc/manifest_sort()
	// Keep 'em boys in neat rows
	general = sortRecord(general, "name", 1)
	medical = sortRecord(medical, "name", 1)
	security = sortRecord(security, "name", 1)
	locked = sortRecord(locked, "name", 1)

/datum/controller/process/datacore/proc/manifest_modify(var/name, var/assignment)
	if(PDA_Manifest.len)
		PDA_Manifest.Cut()
	var/datum/data/record/foundrecord
	var/real_title = assignment

	for(var/datum/data/record/t in data_core.general)
		if (t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	var/list/all_jobs = get_job_datums()

	for(var/datum/job/J in all_jobs)
		var/list/alttitles = get_alternate_titles(J.title)
		if(!J)	continue
		if(assignment in alttitles)
			real_title = J.title
			break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["real_rank"] = real_title

	manifest_sort()

/datum/controller/process/datacore/proc/manifest_inject( var/datum/account/character/A )
	if( !istype( A ))
		return

	if(PDA_Manifest.len)
		PDA_Manifest.Cut()

	var/is_crew = A.crew

	//General Record
	var/datum/data/record/G = new()
	G.fields["id"]			= A.username
	G.fields["name"]		= A.name
	G.fields["real_rank"]	= A.last_job
	G.fields["rank"]		= A.last_role
	G.fields["birth_date"]	= print_date( A.birth_date )
	G.fields["fingerprint"]	= A.fingerprints
	G.fields["p_stat"]		= A.employment_status
	G.fields["m_stat"]		= "Stable"
	G.fields["sex"]			= A.gender
	G.fields["species"]		= A.species
	G.fields["home_system"]	= A.home_system
	G.fields["citizenship"]	= A.citizenship
	G.fields["faction"]		= A.faction
	G.fields["religion"]	= A.religion
	G.fields["photo_front"]	= A.preview_icon_front
	G.fields["photo_side"]	= A.preview_icon_side
	G.fields["account"]		= A
	if( A.gen_record )
		G.fields["notes"] = A.gen_record
	else
		G.fields["notes"] = "No notes found."
	G.fields["is_crew"] = is_crew

	general += G

	//Medical Record
	var/datum/data/record/M = new()
	M.fields["id"]			= A.username
	M.fields["name"]		= A.name
	M.fields["b_type"]		= A.blood_type
	M.fields["b_dna"]		= A.DNA
	M.fields["mi_dis"]		= "None"
	M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
	M.fields["ma_dis"]		= "None"
	M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
	M.fields["alg"]			= "None"
	M.fields["alg_d"]		= "No allergies have been detected in this patient."
	M.fields["cdi"]			= "None"
	M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
	if( A.med_record )
		M.fields["notes"] = A.med_record
	else
		M.fields["notes"] = "No notes found."
	M.fields["account"]		= A
	M.fields["is_crew"] = is_crew

	medical += M

	//Security Record
	var/datum/data/record/S = new()
	S.fields["id"]			= A.username
	S.fields["name"]		= A.name
	S.fields["criminal"]	= "None"
	S.fields["mi_crim"]		= "None"
	S.fields["mi_crim_d"]	= "No minor crime convictions."
	S.fields["ma_crim"]		= "None"
	S.fields["ma_crim_d"]	= "No major crime convictions."
	S.fields["notes"]		= "No notes."
	if( A.sec_record )
		S.fields["notes"] = A.sec_record
	else
		S.fields["notes"] = "No notes."
	S.fields["is_crew"] = is_crew
	S.fields["account"]		= A

	security += S

	//Locked Record
	var/datum/data/record/L = new()
	L.fields["id"]			= A.username
	L.fields["name"]		= A.name
	L.fields["rank"] 		= A.last_role
	L.fields["birth_date"]	= print_date( A.birth_date )
	L.fields["fingerprint"]	= A.fingerprints
	L.fields["sex"]			= A.gender
	L.fields["b_type"]		= A.blood_type
	L.fields["b_dna"]		= A.DNA
	L.fields["species"]		= A.species
	L.fields["home_system"]	= A.home_system
	L.fields["citizenship"]	= A.citizenship
	L.fields["faction"]		= A.faction
	L.fields["religion"]	= A.religion
	L.fields["image"]		= A.preview_icon
	if( A.exploit_record )
		L.fields["exploit_record"] = A.exploit_record
	else
		L.fields["exploit_record"] = "No additional information acquired."
	L.fields["is_crew"] = is_crew
	L.fields["account"]	= A

	locked += L

	manifest_sort()

	return

/*
proc/get_id_photo(var/mob/living/carbon/human/H)
	var/icon/preview_icon = null

	var/g = "m"
	if (H.gender == FEMALE)
		g = "f"

	var/icon/icobase = H.species.icobase

	preview_icon = new /icon(icobase, "torso_[g]")
	var/icon/temp
	temp = new /icon(icobase, "groin_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)
	temp = new /icon(icobase, "head_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)

	for(var/datum/organ/external/E in H.organs)
		if(E.status & ORGAN_CUT_AWAY || E.status & ORGAN_DESTROYED) continue
		temp = new /icon(icobase, "[E.name]")
		if(E.status & ORGAN_ROBOT)
			temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		preview_icon.Blend(temp, ICON_OVERLAY)

	//Tail
	if(H.species.tail)
		temp = new/icon("icon" = H.species.effect_icons, "icon_state" = "[H.species.tail]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)

	// Skin tone
	if(H.species.flags & HAS_SKIN_TONE)
		if (H.character.skin_tone >= 0)
			preview_icon.Blend(rgb(H.character.skin_tone, H.character.skin_tone, H.character.skin_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-H.character.skin_tone,  -H.character.skin_tone,  -H.character.skin_tone), ICON_SUBTRACT)

	// Skin color
	if(H.species.flags & HAS_SKIN_TONE)
		if(!H.species || H.species.flags & HAS_SKIN_COLOR)
			preview_icon.Blend(H.character.skin_color, ICON_ADD)

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = H.species ? H.species.eyes : "eyes_s")

	if (H.species.flags & HAS_EYE_COLOR)
		eyes_s.Blend(H.character.eye_color, ICON_ADD)

	var/datum/sprite_accessory/hair_style = hair_styles_list[H.character.hair_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		hair_s.Blend(H.character.hair_color, ICON_ADD)
		eyes_s.Blend(hair_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.character.hair_face_style]
	if(facial_hair_style)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		facial_s.Blend(H.character.hair_face_color, ICON_ADD)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/clothes_s = null
	switch(H.mind.assigned_role)
		if("Head of Personnel")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hop_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Bartender")
			clothes_s = new /icon('icons/mob/uniform.dmi', "ba_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Gardener")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hydroponics_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Chef")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Janitor")
			clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Librarian")
			clothes_s = new /icon('icons/mob/uniform.dmi', "red_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Quartermaster")
			clothes_s = new /icon('icons/mob/uniform.dmi', "qm_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Cargo Technician")
			clothes_s = new /icon('icons/mob/uniform.dmi', "cargotech_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Shaft Miner")
			clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Lawyer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "internalaffairs_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Chaplain")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chapblack_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Research Director")
			clothes_s = new /icon('icons/mob/uniform.dmi', "director_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if("Scientist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "sciencewhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
		if("Chemist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
		if("Chief Medical Officer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "cmo_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
		if("Medical Doctor")
			clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
/*		if("Geneticist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "geneticswhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)*/
		if("Virologist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "virologywhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
		if("Captain")
			clothes_s = new /icon('icons/mob/uniform.dmi', "captain_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Head of Security")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hosred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Warden")
			clothes_s = new /icon('icons/mob/uniform.dmi', "warden_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Detective")
			clothes_s = new /icon('icons/mob/uniform.dmi', "detective_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
		if("Security Officer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "secred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Chief Engineer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chief_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Station Engineer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "engine_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Atmospheric Technician")
			clothes_s = new /icon('icons/mob/uniform.dmi', "atmos_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Roboticist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "robotics_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		else
			clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	preview_icon.Blend(eyes_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	qdel(eyes_s)
	qdel(clothes_s)

	return preview_icon
*/
