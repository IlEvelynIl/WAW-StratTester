#include maps\_utility; 
#include common_scripts\utility;

init_st_dvars()
{
    init_dvar( "st_fixed_backspeed", "1", true );
	init_dvar( "st_open_barriers", "1" ); // restart
	init_dvar( "st_open_doors", "1" ); // restart
    init_dvar( "st_give_weapons", "1" ); // restart

	init_dvar( "st_total_timer_hud", "1", true );
	init_dvar( "st_round_timer_hud", "1", true );
	init_dvar( "st_remaining_hud", "0", true );
	init_dvar( "st_sph_hud", "0", true );
	init_dvar( "st_health_hud", "0", true );
	init_dvar( "st_zone_hud", "0", true );

	init_dvar( "st_round_number", "100" );
	init_dvar( "st_round_start_delay", "5" );
	init_dvar( "st_insta_kill", "0" );

	level.kills_last_60_seconds = 0;
}

init_dvar( dvar, value, watch )
{
	if ( GetDvar( dvar ) == "" )
	{
        SetDvar( dvar, value );
	}

	if (IsDefined(watch) && watch == true)
        level thread watch_dvar(dvar);
}

watch_dvar(dvar)
{
    level endon("end_game");

    dvar_state = getDvar(dvar);
    while (true)
    {
        wait 0.05;

        if (dvar_state == getDvar(dvar))
            continue;

        level notify(dvar + "_changed");
        dvar_state = getDvar(dvar);
    }
}

on_player_spawn()
{
	if ( GetDvar( "st_open_barriers" ) == "1" )
	{
		level thread maps\_strattester_util::break_all_barriers();
	}

	if ( GetDvar( "st_give_weapons" ) == "1" )
	{
		self thread give_player_weapons();
	}

	self thread maps\_strattester_hud::total_timer_hud();

	self thread maps\_strattester_hud::round_timer_hud();

	self thread maps\_strattester_hud::remaining_hud();

	self thread maps\_strattester_hud::sph_hud();

	map_has_zones = level.script == "nazi_zombie_sumpf" || level.script == "nazi_zombie_factory";
	if ( map_has_zones && GetDvar( "st_zone_hud" ) == "1" )
	{
		self thread maps\_strattester_hud::zone_hud();
	}

	self thread backspeed_watcher();

	self.score = 500000;
	if ( level.script == "nazi_zombie_factory" )
	{
		self.score = 650000;
	}

	wait(2);

	if ( GetDvar( "st_open_doors" ) == "1" )
	{
		self thread maps\_strattester_util::open_doors();
	}
}

backspeed_watcher()
{
	level endon("end_game");
    self endon("disconnect");

	if ( GetDvar( "st_fixed_backspeed" ) == "1" )
	{
		self SetClientDvars( "player_backSpeedScale", "1", "player_strafeSpeedScale", "1" );
	} 
	else {
		self SetClientDvars( "player_backSpeedScale", "0.7", "player_strafeSpeedScale", "0.8" );
	}

	level waittill("st_fixed_backspeed_changed");
	self thread backspeed_watcher();
}

give_player_weapons()
{
    flag_wait( "all_players_connected" );
	wait 0.05;
    
	if ( level.script == "nazi_zombie_prototype" )
	{
		self takeweapon( "zombie_colt" );
		self giveweapon( "ray_gun" );
		self giveweapon( "m2_flamethrower_zombie" );
		self switchtoweapon( "m2_flamethrower_zombie" );
	}
	else if ( level.script == "nazi_zombie_asylum" )
	{
		self takeweapon( "zombie_colt");
		self giveweapon( "ray_gun");
		self giveweapon( "m2_flamethrower_zombie" );
		self switchtoweapon( "m2_flamethrower_zombie" );
	}
	else if ( level.script == "nazi_zombie_sumpf" )
	{
		self takeweapon( "zombie_colt" );
		self giveweapon( "zombie_ppsh" );
		self giveweapon( "tesla_gun" );
		self switchtoweapon( "tesla_gun" );
	}
	else if ( level.script == "nazi_zombie_factory" )
	{	
		self takeweapon( "zombie_colt" );
		//self maps\_zombiemode_cymbal_monkey::player_give_cymbal_monkey(); // uncomment on riese strattester mod
		self giveweapon( "zombie_shotgun_upgraded" );
		self giveweapon( "zombie_thompson" );
		self switchtoweapon( "zombie_thompson" );
	}
}

calculate_zombie_health()
{
	level.zombie_health = level.zombie_vars["zombie_health_start"]; 

	if ( GetDvar( "st_insta_kill" ) == "1" )
	{
		return;
	}

	for ( i=2; i <= level.round_number; i++ )
	{
		// After round 10, get exponentially harder
		if( i >= 10 )
		{
			level.zombie_health += Int( level.zombie_health * level.zombie_vars["zombie_health_increase_percent"] ); 
		}
		else
		{
			level.zombie_health = Int( level.zombie_health + level.zombie_vars["zombie_health_increase"] ); 
		}
	}

	if ( level.zombie_health <= 0 )
	{
		level.zombie_health = level.zombie_vars["zombie_health_start"]; 
	}
}

calculate_zombie_speed()
{
	level.zombie_vars["zombie_spawn_delay"] = 2;
	level.zombie_move_speed = 1;
	timer = level.zombie_vars["zombie_spawn_delay"];
	for(i = 1; i < level.round_number; i++) {
		if(level.zombie_vars["zombie_spawn_delay"] > .08) {
			level.zombie_vars["zombie_spawn_delay"] = level.zombie_vars["zombie_spawn_delay"] * .95;
		}			
		else if(level.zombie_vars["zombie_spawn_delay"] < .08) {
			level.zombie_vars["zombie_spawn_delay"] = .08;
		}

		level.zombie_move_speed = i * 8;
	}
}

round_pause( delay )
{
	if ( !IsDefined( delay ) )
	{
		delay = 30;
	}

	level.countdown_hud = newHudElem();
	level.countdown_hud.horzAlign = "center";
	level.countdown_hud.vertAlign = "top";
	level.countdown_hud.color = ( 1, 1, 1 );
	level.countdown_hud.fontscale = 32;
	level.countdown_hud.alpha = 1;
	level.countdown_hud SetValue( delay );
	level.countdown_hud FadeOverTime( 2.0 );
	wait( 2.0 );

	level.countdown_hud.color = ( 0.21, 0, 0 );
	level.countdown_hud FadeOverTime( 3.0 );
	wait(3);

	while (delay >= 1)
	{
		wait (1);
		delay--;
		level.countdown_hud SetValue( delay );
	}

	level.countdown_hud FadeOverTime( 1.0 );
	level.countdown_hud.color = (1,1,1);
	level.countdown_hud.alpha = 0;
	wait( 1.0 );

	level.countdown_hud Destroy();
}