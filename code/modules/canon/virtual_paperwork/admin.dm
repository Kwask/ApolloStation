/client/proc/modifyCharacterPromotions( mob/living/carbon/human/M as mob in world )
	set name = "Promote / Demote"
	set category = "Fun"

	if(!check_rights( R_MOD|R_ADMIN ))
		return

	var/mob/user = usr

	var/datum/account/character/A = M.character.account

	var/type = input( user, "What type of role modification?", "Set Department" ) as null|anything in list( "Set Department", "Promotion", "Demotion" )

	if( !type )
		return

	switch( type )
		if( "Promotion" )
			var/list/promotions = A.getAllPromotablePositions()
			var/role = input( user, "Choose a role to promote them to:", "Role Promote" ) as null|anything in promotions
			if( !role )
				return

			A.AddJob( role )
			message_admins( "Admin [key_name_admin(usr)] has added role [role] from [key_name_admin(M)]", "CANON:" )
		if( "Demotion" )
			var/role = input( user, "Choose a role to demote them from:", "Role Demotion" ) as null|anything in A.getAllDemotablePositions()
			if( !role )
				return

			message_admins( "Admin [key_name_admin(usr)] has removed role [role] from [key_name_admin(M)]", "CANON:" )
			A.RemoveJob( role )
		if( "Set Department" )
			var/department = input( user, "Choose a department to induct them into:", "Department Induction" ) as null|anything in job_master.departments
			if( !department )
				return

			message_admins( "Admin [key_name_admin(usr)] has set the department of [key_name_admin(M)] to [department]", "CANON:" )
			A.SetDepartment( department )
