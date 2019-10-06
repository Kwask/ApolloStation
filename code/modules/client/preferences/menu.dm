/datum/preferences/proc/ClientMenu( mob/user )
	if( !user || !istype( user ))
		return

	if( IsGuestKey( user.key ))
		return

	var/menu_name = "client_menu"

	. = "<h2>Client Menu</h2><hr>"
	. += "<table border='1' width='320'>"
	if( character )
		character.update_preview_icon()
		user << browse_rsc(character.preview_icon_front, "previewicon.png")
		user << browse_rsc(character.preview_icon_side, "previewicon2.png")
		. += "<tr>"
		. += "<td><b><a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>Selected:</a></b></td>"
		. += "<td colspan='2'>[character.name]</td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td><b>Preview:</b></td>"
		. += "<td colspan='2'><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=new_character'>New Character</a></td>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=edit_character'>Edit</a></td>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=delete_character'>Delete</a></td>"
		. += "</tr>"
	else
		. += "<tr>"
		. += "<td colspan='3'><a href='byond://?src=\ref[user];preference=[menu_name];task=select_character'>Select a Character</a></td>"
		. += "</tr>"

		. += "<tr>"
		. += "<td colspan='3'><a href='byond://?src=\ref[user];preference=[menu_name];task=new_character'>New Character</a></td>"
		. += "</tr>"

	. += "<tr>"
	. += "<td colspan='3'><a href='byond://?src=\ref[user];preference=[menu_name];task=client_prefs'>Client Preferences</a></td>"
	. += "</tr>"
	. += "</table>"

	. += "<hr><a href='byond://?src=\ref[user];preference=[menu_name];task=close'>\[Done\]</a>"

	var/datum/browser/popup = new(user, "[menu_name]", "Client Menu", 360, 300)
	popup.set_content(.)
	popup.open()

/datum/preferences/proc/ClientMenuDisable( mob/user )
	winshow( user, "client_menu", 0)

/datum/preferences/proc/ClientMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "select_character" )
			SelectCharacterMenu( user )
			ClientMenuDisable( user )
		if( "edit_character" )
			if( !character )
				character = new( client.ckey )
				data_core.employee_pool.Add( character )
			ClientMenuDisable( user )
			character.owner.EditCharacterMenu( user )
		if( "delete_character" )
			if( alert( user, "Are you sure you want to permanently delete [character.name]?", "Delete Character","Yes","No" ) == "No" )
				return

			if( deleteCharacter( client.ckey, character.name ))
				client << "[character.name] deleted from your account."

				qdel( character )
				character = null
				savePreferences()
			else
				client << "[character.name] could not be deleted from your account."

			ClientMenu( user )
		if( "new_character" )
			character = new( client.ckey )
			data_core.employee_pool.Add( character )
			savePreferences()

			ClientMenuDisable( user )
			character.owner.EditCharacterMenu( user )
		if( "client_prefs" )
			ClientMenuDisable( user )
			PreferencesMenu( user )
		if( "close" )
			ClientMenuDisable( user )

/datum/preferences/proc/PreferencesMenu( mob/user )
	if( !user || !istype( user ))
		return

	var/menu_name = "pref_menu"

	. = "<h3>Client Preference Menu</h3><hr>"

	. += "<table border='1' width='100%'>"

	if( client && (( donator_tier( client ) && donator_tier( client ) != DONATOR_TIER_1 ) || check_rights(  R_ADMIN|R_MOD )))
		. += "<tr>"
		. += "<td><b>OOC Color:</b></td>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=OOC_color'>[OOC_color]</a></td>"
		. += "</tr>"

	. += "<tr>"
	. += "<td><b>UI Style:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=UI_style'>[UI_style]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>UI Transparency:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=UI_trans'>[UI_style_alpha]</a></td>"
	. += "</tr>"
	if( UI_style == "White" ) // Only white UI gets custom colors
		. += "<tr>"
		. += "<td><b>UI Color:</b></td>"
		. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=UI_color'>[UI_style_color]</a></td>"
		. += "</tr>"
	else
		UI_style_color = initial( UI_style_color )

	. += "<tr>"
	. += "<td><b>Admin Midis:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=hear_midis'>[(toggles & SOUND_MIDI) ? "On" : "Off"]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Lobby Music:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=lobby_music'>[(toggles & SOUND_LOBBY) ? "On" : "Off"]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Ghost Ears:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=ghost_ears'>[(toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearby Speech"]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Ghost Sight:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=ghost_sight'>[(toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearby Emotes"]</a></td>"
	. += "</tr>"

	. += "<tr>"
	. += "<td><b>Ghost Radio:</b></td>"
	. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=ghost_radio'>[(toggles & CHAT_GHOSTRADIO) ? "All Radio" : "Nearby Radio"]</a></td>"
	. += "</tr>"
	. += "</table>"

	. += "<hr><a href='byond://?src=\ref[user];preference=[menu_name];task=close'>\[Done\]</a>"

	var/datum/browser/popup = new(user, "[menu_name]", "Client Preferences", 350, 340)
	popup.set_content(.)
	popup.open()


/datum/preferences/proc/PreferencesMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "OOC_color" )
			var/new_OOC_color = input(user, "Choose your OOC colour:", "Game Preference") as color|null
			if(new_OOC_color)
				OOC_color = new_OOC_color
		if( "UI_style" )
			switch(UI_style)
				if("Midnight")
					UI_style = "Orange"
				if("Orange")
					UI_style = "old"
				if("old")
					UI_style = "White"
				else
					UI_style = "Midnight"
		if( "UI_color" )
			var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
			if(!UI_style_color_new)
				return
			UI_style_color = UI_style_color_new
		if( "UI_trans" )
			var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
			if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50))
				return
			UI_style_alpha = UI_style_alpha_new
		if("hear_midis")
			toggles ^= SOUND_MIDI

		if("lobby_music")
			toggles ^= SOUND_LOBBY
			if(toggles & SOUND_LOBBY)
				user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
			else
				user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

		if("ghost_ears")
			toggles ^= CHAT_GHOSTEARS

		if("ghost_sight")
			toggles ^= CHAT_GHOSTSIGHT

		if("ghost_radio")
			toggles ^= CHAT_GHOSTRADIO

		if( "close" )
			ClientMenu( user )
			winshow( user, "pref_menu", 0)
			return

	savePreferences()
	PreferencesMenu( user )

/datum/preferences/proc/SelectCharacterMenu( mob/user )
	if( !user || !istype( user ) || !user.client)
		return

	var/menu_name = "select_character_menu"

	. = ""
	. += "<h3>Character Selection Menu</h3><hr>"
	. += "<table border='1' width='100%'>"


	// MAKE THIS NOT DISPLAY ALL CHARACTERS

	var/sql_ckey = ckey( user.client.ckey )

	establish_db_connection()
	if(dbcon.IsConnected())
		var/DBQuery/query = dbcon.NewQuery("SELECT employment_status, prison_date, name, id, gender, department FROM character_records ORDER BY name")
		query.Execute()

		. += "<tr>"
		. += "<td><b>Name</b></td>"
		. += "<td><b>Gender</b></td>"
		. += "<td><b>Employment Status</b></td>"
		. += "<td><b>Department</b></td>"
		. += "</tr>"

		while( query.NextRow() )
			var/status = query.item[1]
			var/list/prison_date = params2list( html_decode( query.item[2] ))

			for( var/i in prison_date )
				prison_date[i] = text2num( prison_date[i] )

			var/employment = status
			if( prison_date && prison_date.len )
				var/days = daysTilDate( universe.date, prison_date )
				if( employment == "Active" && days > 0 )
					employment = "[days] days left in prison"

			. += "<tr>"
			var/name = query.item[3]
			var/ident = text2num( query.item[4] )
			if( character && character.name == name )
				. += "<td><b>[name]</b> - Selected</td>"
			else
				if( employment != "Active" )
					. += "<td>[name] - Locked</td>"
				else
					. += "<td><a href='byond://?src=\ref[user];preference=[menu_name];task=choose;ident=[ident]'>[name]</a></td>"

			. += "<td>[capitalize( query.item[5] )]</td>"
			. += "<td style='text-align:left'>[employment]</td>"

			var/datum/department/D = job_master.GetDepartment( text2num( query.item[6] ))
			if( D )
				. += "<td>[D.name]</td>"
			else
				. += "<td>Civilian</td>"

			. += "</tr>"

		. += "</table>"

	. += "<hr><center><a href='byond://?src=\ref[user];preference=[menu_name];task=close'>\[Done\]</a></center>"

	var/datum/browser/popup = new(user, "[menu_name]", "Character Selection Menu", 710, 560)
	popup.set_content(.)
	popup.open()


/datum/preferences/proc/SelectCharacterMenuProcess( mob/user, list/href_list )
	switch( href_list["task"] )
		if( "choose" )
			var/chosen_ident = text2num( href_list["ident"] )

			var/datum/character/C = data_core.getCharacter( chosen_ident )

			if( C )
				character = C
				SelectCharacterMenu( user )
				winshow( user, "select_character_menu", 0)
				ClientMenu( user )
				return

			character = new( client.ckey )
			data_core.employee_pool.Add( character )
			if( !character.loadAccount( chosen_ident ))
				qdel( character )

			savePreferences()
			winshow( user, "select_character_menu", 0)
			ClientMenu( user )
		if( "close" )
			savePreferences()
			winshow( user, "select_character_menu", 0)
			ClientMenu( user )
			return

/datum/preferences/proc/process_links( mob/user, list/href_list )
	if( !user )	return

	if( !istype( user, /mob/new_player ))	return

	if( href_list["preference"] == "client_menu" )
		ClientMenuProcess( user, href_list )
		return 1
	else if( href_list["preference"] == "pref_menu" )
		PreferencesMenuProcess( user, href_list )
		return 1
	else if( href_list["preference"] == "select_character_menu" )
		SelectCharacterMenuProcess( user, href_list )
		return 1
