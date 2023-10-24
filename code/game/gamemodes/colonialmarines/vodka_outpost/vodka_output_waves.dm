#define VO_SPAWN_MULTIPLIER 2
#define VO_SPAWN_MULTIPLIER 0.9
#define VO_SCALED_WAVE 1
#define VO_STATIC_WAVE 2

//SPAWN XENOS
/datum/game_mode/vodka_outpost/proc/spawn_vodka_outpost_xenos(datum/vodka_outpost_wave/wave_data)
	if(!istype(wave_data))wave_castes
		return

	var/datum/hive_status/hive = GLOB.hive_datum[XENO_HIVE_NORMAL]
	if(hive.slashing_allowed != XENO_SLASH_ALLOWED)
		hive.slashing_allowed = XENO_SLASH_ALLOWED //Allows harm intent for aliens
	var/xenobots_to_spawn
	if(wave_data.wave_type == VO_SCALED_WAVE)
		xenobots_to_spawn = max(count_marines(SSmapping.levels_by_trait(ZTRAIT_GROUND)),5) * wave_data.scaling_factor * VO_SPAWN_MULTIPLIER
	else
		xenobots_to_spawn = wave_data.number_of_xenos * VO_SPAWN_MULTIPLIER

	spawn_next_wave = wave_data.wave_delay

	if(wave_data.wave_number == 1)
		call(/datum/game_mode/vodka_outpost/proc/disablejoining)()

	while(xenobots_to_spawn-- > 0)
		xenobot_pool += pick(wave_data.wave_castes) // Adds the wave's xenos to the current pool
		spawn_xenobots()

/datum/game_mode/whiskey_outpost/proc/spawn_xenobots()
	for(var/name in xenobot_pool)
		for(XENO_CASTE_BOT_DRONE in unique_xenos)
			new /mob/living/simple_animal/hostile/alien/spawnable/tearer(get_turf(src))
		for(var/ XENO_CASTE_BOT_TROOPER in xenobot_pool)
			new /mob/living/simple_animal/hostile/alien/spawnable/trooper(get_turf(src))
		for(var/ XENO_CASTE_BOT_TEARER in xenobot_pool)
			new /mob/living/simple_animal/hostile/alien/spawnable



/datum/vodka_outpost_wave
	var/wave_number = 1
	var/list/wave_castes = list()
	var/wave_type = VO_SCALED_WAVE
	var/scaling_factor = 1
	var/number_of_xenos = 0 // not used for scaled waves
	var/wave_delay = 200 SECONDS
	var/list/sound_effect = list('sound/voice/alien_distantroar_3.ogg','sound/voice/xenos_roaring.ogg', 'sound/voice/4_xeno_roars.ogg')
	var/list/command_announcement = list()

/datum/vodka_outpost_wave/wave1
	wave_number = 1
	wave_castes = list(XENO_CASTE_BOT_DRONE)
	sound_effect = list('sound/effects/siren.ogg')
	command_announcement = list("We're tracking the creatures that wiped out our patrols heading towards your outpost, Multiple small life-signs detected enroute to the outpost. Stand-by while we attempt to establish a signal with the USS Alistoun to alert them of these creatures.", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")
	scaling_factor = 1
	wave_delay = 1 MINUTES //Early, quick waves

/datum/vodka_outpost_wave/wave2
	wave_number = 2
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)
	scaling_factor = 1
	wave_delay = 1 MINUTES //Early, quick waves

/datum/vodka_outpost_wave/wave3 //Tier II versions added, but rare
	wave_number = 3
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
	)
	scaling_factor = 1.2
	wave_delay = 1 MINUTES //Early, quick waves

/datum/vodka_outpost_wave/wave4 //Tier II more common
	wave_number = 4
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_SENTINEL,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
	)
	scaling_factor = 1.3

/datum/vodka_outpost_wave/wave5 //Reset the spawns so we don't drown in xenos again.
	wave_number = 5
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
	)
	scaling_factor = 1.4

/datum/vodka_outpost_wave/wave6 //Tier II more common
	wave_number = 6
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
	)
	scaling_factor = 1.5

/datum/vodka_outpost_wave/wave7
	wave_number = 7
	wave_castes = list(XENO_CASTE_BURROWER)
	wave_type = VO_STATIC_WAVE
	number_of_xenos = 3
	command_announcement = list("First Lieutenant Ike Saker, Executive Officer of Captain Naiche, speaking. The Captain is still trying to try and get off world contact. An engineer platoon managed to destroy the main entrance into this valley this should give you a short break while the aliens find another way in. We are receiving reports of seismic waves occuring nearby, there might be creatures burrowing underground, keep an eye on your defenses. I have also received word that marines from an overrun outpost are evacuating to you and will help you. I used to be stationed with them, they are top notch!", "First Lieutenant Ike Saker, 3rd Battalion Command, LV-624 Garrison")

/datum/vodka_outpost_wave/wave8
	wave_number = 8
	wave_castes = list(
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)
	sound_effect = list()
	command_announcement = list("Captain Naiche speaking, we've been unsuccessful in establishing offworld communication for the moment. We're prepping our M402 mortars to destroy the inbound xeno force on the main road. Standby for fire support.", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")

/datum/vodka_outpost_wave/wave9 //Ravager and Praetorian Added, Tier II more common, Tier I less common
	wave_number = 9
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)
	sound_effect = list('sound/voice/alien_queen_command.ogg')
	command_announcement = list("Our garrison forces are reaching seventy percent casualties, we are losing our grip on LV-624. It appears that vanguard of the hostile force is still approaching, and most of the other Dust Raider platoons have been shattered. We're counting on you to keep holding.", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")

/datum/vodka_outpost_wave/wave10
	wave_number = 10
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)

/datum/vodka_outpost_wave/wave11
	wave_number = 11
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)

/datum/vodka_outpost_wave/wave12
	wave_number = 12
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)
	command_announcement = list("This is Captain Naiche, we are picking up large signatures inbound, we'll see what we can do to delay them.", "Captain Naiche, 3rd Battalion Command, LV-624")

/datum/vodka_outpost_wave/wave13
	wave_number = 13
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)

/datum/vodka_outpost_wave/wave14
	wave_number = 14
	wave_castes = list(
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_DRONE,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TEARER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
		XENO_CASTE_BOT_TROOPER,
	)
	wave_type = VO_STATIC_WAVE
	number_of_xenos = 50
	command_announcement = list("This is Captain Naiche, we've established our distress beacon for the USS Alistoun and the remaining Dust Raiders. Hold on for a bit longer while we trasmit our coordinates!", "Captain Naiche, 3rd Battalion Command, LV-624 Garrison")

/datum/vodka_outpost_wave/random
	wave_type = VO_STATIC_WAVE
	wave_number = 15
	number_of_xenos = 50

/datum/vodka_outpost_wave/random/wave1 //Runner madness
	wave_castes = list(
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RUNNER,
		XENO_CASTE_RAVAGER,
	)

/datum/vodka_outpost_wave/random/wave2 //Spitter madness
	wave_castes = list(
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_SPITTER,
		XENO_CASTE_PRAETORIAN,
	)
	number_of_xenos = 45

/datum/vodka_outpost_wave/random/wave3 //Defender madness
	wave_castes = list(
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_DEFENDER,
		XENO_CASTE_CRUSHER,
	)
	number_of_xenos = 30

/datum/vodka_outpost_wave/random/wave4 //Burrower apocalypse
	wave_castes = list(
		XENO_CASTE_BURROWER,
		XENO_CASTE_BURROWER,
		XENO_CASTE_BURROWER,
		XENO_CASTE_BURROWER,
		XENO_CASTE_BURROWER,
		XENO_CASTE_BURROWER,
		XENO_CASTE_BURROWER,
	)
	number_of_xenos = 20
