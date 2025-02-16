/var/security_level = 0
//0 = code green
//1 = code blue
//2 = code red
//3 = code delta

//config.alert_desc_blue_downto


/proc/set_security_level(level, no_sound = FALSE, announce = TRUE, log = ARES_LOG_SECURITY)
	if(level != security_level)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SECURITY_LEVEL_CHANGED, level)

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				if(announce)
					ai_announcement("Внимание: Уровень безопасности понижен до ЗЕЛЕНОГО  - все чисто.", no_sound ? null : 'sound/AI/code_green.ogg', log)
				security_level = SEC_LEVEL_GREEN

			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					if(announce)
						ai_announcement("Внимание: Уровень безопасности повышен до СИНЕГО - возможна враждебная активность на борту.", no_sound ? null : 'sound/AI/code_blue_elevated.ogg', log)
				else
					if(announce)
						ai_announcement("Внимание: Уровень безопасности понижен до СИНЕГО - возможна враждебная активность на борту.", no_sound ? null : 'sound/AI/code_blue_lowered.ogg', log)
				security_level = SEC_LEVEL_BLUE

			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					if(announce)
						ai_announcement("Внимание: Уровень безопасности повышен до КРАСНОГО - прямая угроза кораблю.", no_sound ? null : 'sound/AI/code_red_elevated.ogg', log)
				else
					if(announce)
						ai_announcement("Внимание: Уровень безопасности понижен до КРАСНОГО - прямая угроза кораблю.", no_sound ? null : 'sound/AI/code_red_lowered.ogg', log)
				security_level = SEC_LEVEL_RED

			if(SEC_LEVEL_DELTA)
				if(announce)
					var/name = "СИСТЕМА САМОУНИЧТОЖЕНИЯ АКТИВНА"
					var/input = "ОПАСНОСТЬ, СИСТЕМА АВАРИЙНОГО САМОУНИЧТОЖЕНИЯ АКТИВИРОВАНА. ПРОСЛЕДУЙТЕ К КОНСОЛИ ДЛЯ АКТИВАЦИИ СТЕРЖНЕЙ УПРАВЛЕНИЯ."
					marine_announcement(input, name, 'sound/AI/selfdestruct_short.ogg', logging = log)
				security_level = SEC_LEVEL_DELTA
				EvacuationAuthority.enable_self_destruct()

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA
