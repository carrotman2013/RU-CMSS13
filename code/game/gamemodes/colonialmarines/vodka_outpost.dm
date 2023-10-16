#define WO_MAX_WAVE 15

//Global proc for checking if the game is whiskey outpost so I dont need to type if(gamemode == whiskey outpost) 50000 times
/datum/game_mode/vodka_outpost
	name = GAMEMODE_VODKA_OUTPOST
	config_tag = GAMEMODE_VODKA_OUTPOST
	required_players = 0
	xeno_bypass_timer = 1
	flags_round_type = MODE_NEW_SPAWN
	role_mappings = list(
		/datum/job/command/commander/whiskey = JOB_CO,
		/datum/job/command/executive/whiskey = JOB_XO,
		/datum/job/civilian/synthetic/whiskey = JOB_SYNTH,
		/datum/job/command/warrant/whiskey = JOB_CHIEF_POLICE,
		/datum/job/command/bridge/whiskey = JOB_SO,
		/datum/job/command/tank_crew/whiskey = JOB_CREWMAN,
		/datum/job/command/police/whiskey = JOB_POLICE,
		/datum/job/command/pilot/whiskey = JOB_PILOT,
		/datum/job/logistics/requisition/whiskey = JOB_CHIEF_REQUISITION,
		/datum/job/civilian/professor/whiskey = JOB_CMO,
		/datum/job/civilian/doctor/whiskey = JOB_DOCTOR,
		/datum/job/civilian/researcher/whiskey = JOB_RESEARCHER,
		/datum/job/logistics/engineering/whiskey = JOB_CHIEF_ENGINEER,
		/datum/job/logistics/tech/maint/whiskey = JOB_MAINT_TECH,
		/datum/job/logistics/cargo/whiskey = JOB_CARGO_TECH,
		/datum/job/civilian/liaison/whiskey = JOB_CORPORATE_LIAISON,
		/datum/job/marine/leader/whiskey = JOB_SQUAD_LEADER,
		/datum/job/marine/specialist/whiskey = JOB_SQUAD_SPECIALIST,
		/datum/job/marine/smartgunner/whiskey = JOB_SQUAD_SMARTGUN,
		/datum/job/marine/medic/whiskey = JOB_SQUAD_MEDIC,
		/datum/job/marine/engineer/whiskey = JOB_SQUAD_ENGI,
		/datum/job/marine/standard/whiskey = JOB_SQUAD_MARINE,
	)


	latejoin_larva_drop = 0 //You never know

	//var/mob/living/carbon/human/Commander //If there is no Commander, marines wont get any supplies
	//No longer relevant to the game mode, since supply drops are getting changed.
	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 10 //This is a simple timer so we don't accidently check win conditions right in post-game
	var/randomovertime = 0 //This is a simple timer so we can add some random time to the game mode.
	var/spawn_next_wave = 12 MINUTES //Spawn first batch at ~12 minutes
	var/last_wave_time = 0 // Stores the time the last wave (wave 15) started
	var/xeno_wave = 1 //Which wave is it

	var/wave_ticks_passed = 0 //Timer for xeno waves

	var/list/players = list()

	var/list/turf/xeno_spawns = list()
	var/list/turf/xenobot_spawns = list()
	var/list/turf/supply_spawns = list()

	//Who to spawn and how often which caste spawns
		//The more entires with same path, the more chances there are to pick it
			//This will get populated with spawn_xenos() proc
	var/list/spawnxeno = list()
	var/list/xeno_pool = list()
	var/list/xenobot_pool = list()

	var/next_supply = 1 MINUTES //At which wave does the next supply drop come?

	var/ticks_passed = 0
	var/lobby_time = 0 //Lobby time does not count for marine 1h win condition

	var/map_locale = 0 // 0 is Jungle Whiskey Outpost, 1 is Big Red Whiskey Outpost, 2 is Ice Colony Whiskey Outpost, 3 is space
	var/spawn_next_vo_wave = FALSE

	var/list/vodka_outpost_waves = list()

	hardcore = TRUE

	votable = TRUE
	vote_cycle = 2

	taskbar_icon = 'icons/taskbar/gml_wo.png'

/datum/game_mode/vodka_outpost/get_roles_list()
	return ROLES_WO

/datum/game_mode/vodka_outpost/announce()
	return 1

/datum/game_mode/vodka_outpost/pre_setup()
	SSticker.mode.toggleable_flags ^= MODE_HARDCORE_PERMA
	for(var/obj/effect/landmark/whiskey_outpost/xenospawn/X)
		xeno_spawns += X.loc
	for(var/obj/effect/landmark/whiskey_outpost/xenobotspawn/XB)
		xenobot_spawns += XB.loc
	for(var/obj/effect/landmark/whiskey_outpost/supplydrops/S)
		supply_spawns += S.loc


	//  WO waves
	var/list/paths = typesof(/datum/vodka_outpost_wave) - /datum/vodka_outpost_wave - /datum/vodka_outpost_wave/random
	for(var/i in 1 to WO_MAX_WAVE)
		vodka_outpost_waves += i
		vodka_outpost_waves[i] = list()
	for(var/T in paths)
		var/datum/vodka_outpost_wave/WOW = new T
		if(WOW.wave_number > 0)
			vodka_outpost_waves[WOW.wave_number] += WOW

	return ..()

/datum/game_mode/vodka_outpost/post_setup()
	set waitfor = 0
	update_controllers()
	initialize_post_marine_gear_list()
	lobby_time = world.time

	CONFIG_SET(flag/remove_gun_restrictions, TRUE)
	sleep(10)
	to_world(SPAN_ROUND_HEADER("Режим игры - VODKA OUTPOST!"))
	to_world(SPAN_ROUNDBODY("События происходят на планете LV-624 в 2177 году, за пять лет до прибытия военного корабля USS «Almayer» и 2-го батальона «Падающие соколы» в сектор."))
	to_world(SPAN_ROUNDBODY("3 Батальону 'Dust Raiders' выдана задача распространять влияние USCM в Секторе Нероид."))
	to_world(SPAN_ROUNDBODY("[SSmapping.configs[GROUND_MAP].map_name], одна из баз 'Dust Raiders' расположившаяся в этом секторе, попала под атаку неизвестных инопланетных форм жизни."))
	to_world(SPAN_ROUNDBODY("С ростом количества жертв и постепенно истощающимися припасами, 'Dust Raiders' на [SSmapping.configs[GROUND_MAP].map_name] должны прожить еще час, чтобы оповестить оставшуюся часть своего батальона в секторе о надвигающейся опасности."))
	to_world(SPAN_ROUNDBODY("Продержитесь столько, сколько сможете."))
	world << sound('sound/effects/siren.ogg')

	sleep(10)
	switch(map_locale) //Switching it up.
		if(0)
			marine_announcement("This is Captain Hans Naiche, commander of the 3rd Battalion 'Dust Raiders' forces here on LV-624. In our attempts to establish a base on this planet, several of our patrols were wiped out by hostile creatures.  We're setting up a distress call, but we need you to hold [SSmapping.configs[GROUND_MAP].map_name] in order for our engineers to set up the relay. We're prepping several M402 mortar units to provide fire support. If they overrun your positon, we will be wiped out with no way to call for help. Hold the line or we all die.", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")
	addtimer(CALLBACK(src, PROC_REF(story_announce), 0), 3 MINUTES)
	return ..()

/datum/game_mode/vodka_outpost/proc/story_announce(time)
	switch(time)
		if(0)
			marine_announcement("This is Captain Hans Naiche, Commander of the 3rd Bataillion, 'Dust Raiders' forces on LV-624. As you already know, several of our patrols have gone missing and likely wiped out by hostile local creatures as we've attempted to set our base up.", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")
		if(1)
			marine_announcement("Our scouts report increased activity in the area and given our intel, we're already preparing for the worst. We're setting up a comms relay to send out a distress call, but we're going to need time while our engineers get everything ready. All other stations should prepare accordingly and maximize combat readiness, effective immediately.", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")
		if(2)
			marine_announcement("Captain Naiche here. We've tracked the bulk of enemy forces on the move and [SSmapping.configs[GROUND_MAP].map_name] is likely to be hit before they reach the base. We need you to hold them off while we finish sending the distress call. Expect incoming within a few minutes. Godspeed, [SSmapping.configs[GROUND_MAP].map_name].", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")

	if(time <= 2)
		addtimer(CALLBACK(src, PROC_REF(story_announce), time+1), 3 MINUTES)

/datum/game_mode/vodka_outpost/proc/update_controllers()
	//Update controllers while we're on this mode
	if(SSitem_cleanup)
		//Cleaning stuff more aggressively
		SSitem_cleanup.start_processing_time = 0
		SSitem_cleanup.percentage_of_garbage_to_delete = 1
		SSitem_cleanup.wait = 1 MINUTES
		SSitem_cleanup.next_fire = 1 MINUTES
		spawn(0)
			//Deleting Almayer, for performance!
			SSitem_cleanup.delete_almayer()
	if(SSxenocon)
		//Don't need XENOCON
		SSxenocon.wait = 30 MINUTES


//PROCCESS
/datum/game_mode/vodka_outpost/process(delta_time)
	. = ..()
	checkwin_counter++
	ticks_passed++
	wave_ticks_passed++

	if(wave_ticks_passed >= (spawn_next_wave/(delta_time SECONDS)))
		wave_ticks_passed = 0
		spawn_next_vo_wave = TRUE

	if(spawn_next_vo_wave)
		spawn_next_xeno_wave()

	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(world.time > next_supply)
		place_vodka_outpost_drop()
		next_supply += 2 MINUTES

	if(checkwin_counter >= 10) //Only check win conditions every 10 ticks.
		if(xeno_wave == WO_MAX_WAVE && last_wave_time == 0)
			last_wave_time = world.time
		if(!finished && round_should_check_for_win && last_wave_time != 0)
			check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/vodka_outpost/proc/spawn_next_xeno_wave()
	spawn_next_vo_wave = FALSE
	var/wave = pick(vodka_outpost_waves[xeno_wave])
	spawn_vodka_outpost_xenos(wave)
	announce_xeno_wave(wave)
	if(xeno_wave == 7)
		//Wave when Marines get reinforcements!
		get_specific_call("Marine Reinforcements (Squad)", FALSE, TRUE, FALSE)
	xeno_wave = min(xeno_wave + 1, WO_MAX_WAVE)


/datum/game_mode/vodka_outpost/proc/announce_xeno_wave(datum/vodka_outpost_wave/wave_data)
	if(!istype(wave_data))
		return
	if(wave_data.command_announcement.len > 0)
		marine_announcement(wave_data.command_announcement[1], wave_data.command_announcement[2])
	if(wave_data.sound_effect.len > 0)
		playsound_z(SSmapping.levels_by_trait(ZTRAIT_GROUND), pick(wave_data.sound_effect))

//CHECK WIN
/datum/game_mode/vodka_outpost/check_win()
	var/C = count_humans_and_xenos(SSmapping.levels_by_trait(ZTRAIT_GROUND))

	if(C[1] == 0)
		finished = 1 //Alien win
	else if(world.time > last_wave_time + 15 MINUTES) // Around 1:12 hh:mm
		finished = 2 //Marine win

/datum/game_mode/vodka_outpost/proc/disablejoining()
	for(var/i in RoleAuthority.roles_by_name)
		var/datum/job/J = RoleAuthority.roles_by_name[i]

		// If the job has unlimited job slots, We set the amount of slots to the amount it has at the moment this is called
		if (J.spawn_positions < 0)
			J.spawn_positions = J.current_positions
			J.total_positions = J.current_positions
		J.current_positions = J.get_total_positions(TRUE)
	to_world("<B>New players may no longer join the game.</B>")
	message_admins("Wave one has begun. Disabled new player game joining.")
	message_admins("Wave one has begun. Disabled new player game joining except for replacement of cryoed marines.")
	world.update_status()

/datum/game_mode/vodka_outpost/count_xenos()//Counts braindead too
	var/xeno_count = 0
	for(var/i in GLOB.living_xenobot_list)
		var/mob/living/simple_animal/hostile/alien/spawnable/X = i
		if(is_ground_level(X.z) && !istype(X.loc,/turf/open/space)) // If they're connected/unghosted and alive and not debrained
			xeno_count += 1 //Add them to the amount of people who're alive.

	return xeno_count

/datum/game_mode/vodka_outpost/proc/pickovertime()
	var/randomtime = ((rand(0,6)+rand(0,6)+rand(0,6)+rand(0,6))*50 SECONDS)
	var/maxovertime = 20 MINUTES
	if (randomtime >= maxovertime)
		return maxovertime
	return randomtime

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/vodka_outpost/check_finished()
	if(finished != 0)
		return 1

	return 0

//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/vodka_outpost/declare_completion()
	if(round_statistics)
		round_statistics.track_round_end()
	if(finished == 1)
		log_game("Round end result - xenos won")
		to_world(SPAN_ROUND_HEADER("The Xenos have succesfully defended their hive from colonization."))
		to_world(SPAN_ROUNDBODY("Well done, you've secured LV-624 for the hive!"))
		to_world(SPAN_ROUNDBODY("It will be another five years before the USCM returns to the Neroid Sector, with the arrival of the 2nd 'Falling Falcons' Battalion and the USS Almayer."))
		to_world(SPAN_ROUNDBODY("The xenomorph hive on LV-624 remains unthreatened until then..."))
		world << sound('sound/misc/Game_Over_Man.ogg')
		if(round_statistics)
			round_statistics.round_result = MODE_INFESTATION_X_MAJOR
			if(round_statistics.current_map)
				round_statistics.current_map.total_xeno_victories++
				round_statistics.current_map.total_xeno_majors++

	else if(finished == 2)
		log_game("Round end result - marines won")
		to_world(SPAN_ROUND_HEADER("Against the onslaught, the marines have survived."))
		to_world(SPAN_ROUNDBODY("The signal rings out to the USS Alistoun, and Dust Raiders stationed elsewhere in the Neroid Sector begin to converge on LV-624."))
		to_world(SPAN_ROUNDBODY("Eventually, the Dust Raiders secure LV-624 and the entire Neroid Sector in 2182, pacifiying it and establishing peace in the sector for decades to come."))
		to_world(SPAN_ROUNDBODY("The USS Almayer and the 2nd 'Falling Falcons' Battalion are never sent to the sector and are spared their fate in 2186."))
		world << sound('sound/misc/hell_march.ogg')
		if(round_statistics)
			round_statistics.round_result = MODE_INFESTATION_M_MAJOR
			if(round_statistics.current_map)
				round_statistics.current_map.total_marine_victories++
				round_statistics.current_map.total_marine_majors++

	else
		log_game("Round end result - no winners")
		to_world(SPAN_ROUND_HEADER("NOBODY WON!"))
		to_world(SPAN_ROUNDBODY("How? Don't ask me..."))
		world << 'sound/misc/sadtrombone.ogg'
		if(round_statistics)
			round_statistics.round_result = MODE_INFESTATION_DRAW_DEATH

	if(round_statistics)
		round_statistics.game_mode = name
		round_statistics.round_length = world.time
		round_statistics.end_round_player_population = GLOB.clients.len

		round_statistics.log_round_statistics()

		round_finished = 1

	calculate_end_statistics()


	return 1

/datum/game_mode/proc/auto_declare_completion_vodka_outpost()
	return

/datum/game_mode/vodka_outpost/proc/place_vodka_outpost_drop(OT = "sup") //Art revamping spawns 13JAN17
	var/turf/T = pick(supply_spawns)
	var/randpick
	var/list/randomitems = list()
	var/list/spawnitems = list()
	var/choosemax
	var/obj/structure/closet/crate/crate

	if(!OT)
		OT = "sup" //no breaking anything.

	else if (OT == "sup")
		randpick = rand(0,50)
		switch(randpick)
			if(0 to 5)//Marine Gear 10% Chance.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(5,10)
				randomitems = list(/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/head/helmet/marine,
								/obj/item/clothing/suit/storage/marine/medium,
								/obj/item/clothing/suit/storage/marine/medium,
								/obj/item/clothing/suit/storage/marine/medium,
								/obj/item/clothing/head/helmet/marine/tech,
								/obj/item/clothing/head/helmet/marine/medic,
								/obj/item/clothing/under/marine/medic,
								/obj/item/clothing/under/marine/engineer,
								/obj/effect/landmark/wo_supplies/storage/webbing,
								/obj/item/device/binoculars)

			if(6 to 10)//Lights and shiet 10%
				new /obj/structure/largecrate/supply/floodlights(T)
				new /obj/structure/largecrate/supply/supplies/flares(T)


			if(11 to 13) //6% Chance to drop this !FUN! junk.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				spawnitems = list(/obj/item/storage/belt/utility/full,
									/obj/item/storage/belt/utility/full,
									/obj/item/storage/belt/utility/full,
									/obj/item/storage/belt/utility/full)

			if(14 to 18)//Materials 10% Chance.
				crate = new /obj/structure/closet/crate/secure/gear(T)
				choosemax = rand(3,8)
				randomitems = list(/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/metal,
								/obj/item/stack/sheet/plasteel,
								/obj/item/stack/sandbags_empty/half,
								/obj/item/stack/sandbags_empty/half,
								/obj/item/stack/sandbags_empty/half)

			if(19 to 20)//Blood Crate 4% chance
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus,
								/obj/item/reagent_container/blood/OMinus)

			if(21 to 25)//Advanced meds Crate 10%
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/storage/firstaid/fire,
								/obj/item/storage/firstaid/regular,
								/obj/item/storage/firstaid/toxin,
								/obj/item/storage/firstaid/o2,
								/obj/item/storage/firstaid/adv,
								/obj/item/bodybag/cryobag,
								/obj/item/bodybag/cryobag,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/clothing/glasses/hud/health,
								/obj/item/device/defibrillator)

			if(26 to 30)//Random Medical Items 10% as well. Made the list have less small junk
				crate = new /obj/structure/closet/crate/medical(T)
				spawnitems = list(/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full,
								/obj/item/storage/belt/medical/lifesaver/full)

			if(31 to 35)//Random explosives Crate 10% because the lord commeth and said let there be explosives.
				crate = new /obj/structure/closet/crate/ammo(T)
				choosemax = rand(1,5)
				randomitems = list(/obj/item/storage/box/explosive_mines,
								/obj/item/storage/box/explosive_mines,
								/obj/item/explosive/grenade/high_explosive/m15,
								/obj/item/explosive/grenade/high_explosive/m15,
								/obj/item/explosive/grenade/high_explosive,
								/obj/item/storage/box/nade_box
								)
			if(36 to 40) // Junk
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(
									/obj/item/attachable/heavy_barrel,
									/obj/item/attachable/heavy_barrel,
									/obj/item/attachable/heavy_barrel,
									/obj/item/attachable/heavy_barrel)

			if(40 to 48)//Weapon + supply beacon drop. 6%
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon,
								/obj/item/device/whiskey_supply_beacon)

			if(49 to 50)//Rare weapons. Around 4%
				crate = new /obj/structure/closet/crate/ammo(T)
				spawnitems = list(/obj/effect/landmark/wo_supplies/ammo/box/rare/m41aap,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/m41aapmag,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/m41aextend,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/smgap,
								/obj/effect/landmark/wo_supplies/ammo/box/rare/smgextend)
	if(crate)
		crate.storage_capacity = 60

	if(randomitems.len)
		for(var/i = 0; i < choosemax; i++)
			var/path = pick(randomitems)
			var/obj/I = new path(crate)
			if(OT == "sup")
				if(I && istype(I,/obj/item/stack/sheet/mineral/phoron) || istype(I,/obj/item/stack/rods) || istype(I,/obj/item/stack/sheet/glass) || istype(I,/obj/item/stack/sheet/metal) || istype(I,/obj/item/stack/sheet/plasteel) || istype(I,/obj/item/stack/sheet/wood))
					I:amount = rand(30,50) //Give them more building materials.
				if(I && istype(I,/obj/structure/machinery/floodlight))
					I.anchored = FALSE


	else
		if(crate)
			for(var/path in spawnitems)
				new path(crate)

/datum/game_mode/vodka_outpost/announce_bioscans(variance = 2)
	return // No bioscans needed in VO

/datum/game_mode/vodka_outpost/get_escape_menu()
	return "Making a last stand on..."
