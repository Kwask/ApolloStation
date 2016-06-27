/datum/account/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/account/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/account/proc/SelectDepartment( mob/user )
	var/list/choices = list()
	for( var/datum/department/D in job_master.departments )
		choices[D.name] = D

	var/choice = input("Select your desire department.", "Branch Selection", null) in choices
	if( !choice )
		return null

	SetDepartment( choices[choice] )

/datum/account/proc/SetDepartment( var/datum/department/new_department )
	if( !new_department )
		return

	var/datum/department/old_department
	if( department && department.department_id != CIVILIAN ) // If we were in a department that wasn't civilian
		old_department = department

	if( old_department )
		roles -= old_department.getAllPositionNames() // Removing all old departmental roles

	department = new_department
	roles |= new_department.starting_positions

/datum/account/proc/LoadDepartment( var/id )
	if( !job_master )
		return

	var/D = job_master.GetDepartment( id )
	SetDepartment( D )

/datum/account/proc/AddJob( var/job_name )
	for( var/role in roles )
		if( roles[role] == "High" )
			roles[role] = "Medium"

	roles.["[job_name]"] = "High"

/datum/account/proc/RemoveJob( var/job_name )
	roles.Remove( "[job_name]" )

/datum/account/proc/SetJob(mob/user, role)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		owner.EditCharacterMenu(user)
		return

	if(( job.title in roles ) && DepartmentCheck( job ))
		ChangeJobLevel( job.title )
	else if( DepartmentCheck( job ))
		roles[job.title] = "None" // Adding the new roles

	owner.JobChoicesMenu(user)
	return 1

// This checks if the given job is part of our department
/datum/account/proc/DepartmentCheck( var/datum/job/job )
	if( job.department_id == CIVILIAN )
		return 1 // If the job isn't in a department, a la civilian roles

	return department.department_id == job.department_id

/datum/account/proc/ChangeJobLevel( var/role )
	if( !( role in roles ))
		return 0

	switch( roles[role] )
		if( "None" )
			roles[role] = "Low"
			return 2
		if( "Low" )
			roles[role] = "Medium"
			return 3
		if( "Medium" )
			roles[role] = "High"
			return 4
		if( "High" )
			roles[role] = "None"
			return 1

/datum/account/proc/GetJobLevel( var/role )
	if( !( role in roles ))
		return 0

	return roles[role]

/datum/account/proc/GetJobLevelNum( var/role )
	if( !( role in roles ))
		return 0

	switch( roles[role] )
		if( "High" )
			return 1
		if( "Medium" )
			return 2
		if( "Low" )
			return 3
		else
			return 0

/datum/account/proc/GetHighestLevelJob()
	var/list/levels = list( "High", "Medium", "Low", "None" )

	for( var/level in levels )
		if( level == "None" )
			return "Assistant"

		for( var/role in roles )
			if( roles[role] == level )
				return role

/datum/account/proc/ResetJobs()
	LoadDepartment( CIVILIAN )

/datum/account/proc/SetJobDepartment( var/datum/job/job )
	department = job.department_id

/datum/account/proc/getAllPromotablePositions( var/succession_level )
	. = list()

	if( department.department_id == CIVILIAN )
		. |= department.getAllPositionNamesWithPriority()
	else
		var/datum/department/D = job_master.GetDepartment( CIVILIAN )
		. |= D.getAllPositionNamesWithPriority()
		. |= department.getAllPositionNamesWithPriority()

	for( var/role in . )
		var/datum/job/J = job_master.GetJob( role )
		if( !J )
			continue

		if( J.rank_succesion_level < succession_level )
			continue

		. -= J

	. -= getAllDemotablePositions()

	return .

/datum/account/proc/getAllDemotablePositions( var/succession_level )
	. = list()

	for( var/role in roles )
		var/datum/job/J = job_master.GetJob( role )
		if( !J )
			continue

		if( succession_level && ( J.rank_succesion_level >= succession_level ))
			continue

		. += role

	return .

