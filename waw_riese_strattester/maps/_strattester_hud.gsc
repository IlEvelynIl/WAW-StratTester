#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

total_timer_hud()
{
	self.total_timer = create_simple_hud( self );
	self.total_timer.foreground = true; 
	self.total_timer.sort = 1; 
	self.total_timer.hidewheninmenu = true; 
	self.total_timer.fontscale = 1.5;
	self.total_timer.alignX = "right"; 
	self.total_timer.alignY = "top";
	self.total_timer.horzAlign = "right"; 
	self.total_timer.vertAlign = "top";
	self.total_timer.x = self.total_timer.x - 3;
	self.total_timer.y = self.total_timer.y + 20;
	self.total_timer.color = (1, 1, 1);
	self.total_timer.alpha = 1;
	self thread update_total_timer();
	self thread total_timer_hud_watcher();
}

total_timer_hud_watcher()
{
	level endon("end_game");
    self endon("disconnect");

	if ( GetDvar( "st_total_timer_hud" ) == "1" )
	{
		self.total_timer SetText("Total Time: " + maps\_strattester_util::seconds_to_string( level.game_time ) );
	} 
	else {
		self.total_timer SetText("");
	}

	level waittill("st_total_timer_hud_changed");
	self thread total_timer_hud_watcher();
}

update_total_timer()
{
	level endon("intermission");
	level.game_time = 0;

	wait 1.5;

	while (1)
	{
		level.game_time++;

		if ( GetDvar( "st_total_timer_hud" ) == "1" )
		{
			self.total_timer SetText("Total Time: " + maps\_strattester_util::seconds_to_string( level.game_time ) );
		}

		wait(1);
	}
}

round_timer_hud()
{
	self.round_timer = create_simple_hud( self );
	self.round_timer.foreground = true; 
	self.round_timer.sort = 1; 
	self.round_timer.hidewheninmenu = true; 
	self.round_timer.fontscale = 1.5;
	self.round_timer.alignX = "right"; 
	self.round_timer.alignY = "top";
	self.round_timer.horzAlign = "right"; 
	self.round_timer.vertAlign = "top";
	self.round_timer.x = self.round_timer.x - 3;
	self.round_timer.y = self.round_timer.y + 35;
	self.round_timer.color = (1, 1, 1);
	self.round_timer.alpha = 1;
	self thread round_timer_hud_watcher();
}

round_timer_hud_watcher()
{
	level endon("end_game");
    self endon("disconnect");

	if ( GetDvar( "st_round_timer_hud" ) == "1" )
	{
		self thread update_round_timer();
	} 
	else {
		self.round_timer SetText("");
	}

	level waittill("st_round_timer_hud_changed");
	self thread round_timer_hud_watcher();
}

update_round_timer()
{
	level.round_time = 0;
	self.round_timer SetText( "Round Time: " + maps\_strattester_util::seconds_to_string( level.round_time ) );

	if ( IsDefined(level.current_round_start_time) )
	{
		round_time = int(gettime() / 1000) - level.current_round_start_time;
		if ( !IsDefined( round_time ) || round_time == 0 )
		{
			level waittill( "start_of_round" );
		}
	} 
	else {
		level waittill( "start_of_round" );
	}

	while (1)
	{
		if ( GetDvar( "st_round_timer_hud" ) == "0" )
		{
			break;
		}

		level.round_time = int(gettime() / 1000) - level.current_round_start_time;
		self.round_timer SetText( "Round Time: " + maps\_strattester_util::seconds_to_string( level.round_time ) );
		wait( 0.5 );
	}
}

remaining_hud()
{
	self.remaining_hud = newHudElem();
	self.remaining_hud.foreground = true; 
	self.remaining_hud.sort = 1; 
	self.remaining_hud.hidewheninmenu = true; 
	self.remaining_hud.fontscale = 1.5;
	self.remaining_hud.x = self.remaining_hud.x + 3;
	self.remaining_hud.alignX = "left";
	self.remaining_hud.alignY = "top";
	self.remaining_hud.horzAlign = "left";
	self.remaining_hud.vertAlign = "top";
	self.remaining_hud.color = (1, 1, 1);
	self.remaining_hud.alpha = 1;
	self thread remaining_hud_watcher();
}

remaining_hud_watcher()
{
	level endon("end_game");
    self endon("disconnect");

	if ( GetDvar( "st_remaining_hud" ) == "1" )
	{
		self thread update_remaining_hud();
	} 
	else {
		self.remaining_hud SetText("");
	}

	level waittill("st_remaining_hud_changed");
	self thread remaining_hud_watcher();
}

update_remaining_hud()
{   
	flag_wait("all_players_spawned");

	while (1)
	{
		if ( GetDvar( "st_remaining_hud" ) == "0" )
		{
			break;
		}

		wait_network_frame();
		zombies = level.zombie_total + get_enemy_count();
		self.remaining_hud SetText("Remaining: " + zombies);
		wait .25;
	}
}

sph_hud()
{
	self.sph_hud = newHudElem();
	self.sph_hud.foreground = true; 
	self.sph_hud.sort = 1; 
	self.sph_hud.hidewheninmenu = true; 
	self.sph_hud.fontscale = 1.5;
	self.sph_hud.x = self.sph_hud.x + 3;
	self.sph_hud.y = self.sph_hud.y + 15;
	self.sph_hud.alignX = "left";
	self.sph_hud.alignY = "top";
	self.sph_hud.horzAlign = "left";
	self.sph_hud.vertAlign = "top";
	self.sph_hud.color = (1, 1, 1);
	self.sph_hud.alpha = 1;
	self.sph_hud SetText( "SPH: 0" );
	self thread sph_hud_watcher();
}

sph_hud_watcher()
{
	level endon("end_game");
    self endon("disconnect");

	if ( GetDvar( "st_sph_hud" ) == "1" )
	{
		self thread update_sph_hud();
	} 
	else {
		self.sph_hud SetText("");
	}

	level waittill("st_sph_hud_changed");
	self thread sph_hud_watcher();
}

update_sph_hud()
{
	flag_wait("all_players_spawned");

	if ( IsDefined(level.current_round_start_time) )
	{
		round_time = int(gettime() / 1000) - level.current_round_start_time;
		if ( !IsDefined( round_time ) || round_time == 0 )
		{
			level waittill( "start_of_round" );
		}
	} 
	else {
		level waittill( "start_of_round" );
	}

	while (1)
	{
		if ( GetDvar( "st_sph_hud" ) == "0" )
		{
			break;
		}

		zombies_thus_far = level.global_zombies_killed_round;
		hordes = zombies_thus_far / 24;
		current_time = int(GetTime() / 1000) - level.current_round_start_time;

		if( level.zombie_total + get_enemy_count() == 0 )
		{
			current_time = level.current_round_end_time - level.current_round_start_time;
		}

		if (hordes <= 0)
		{
			self.sph_hud SetText( "SPH: 0" );
		}
		else {
			level.round_seconds_per_horde = int(current_time / hordes * 100) / 100;
			self.sph_hud SetText( "SPH: " + level.round_seconds_per_horde );
		}

		wait 1;
	}
}

zone_hud()
{   
	self.zone_hud = newHudElem();
	self.zone_hud.foreground = true; 
	self.zone_hud.sort = 1; 
	self.zone_hud.hidewheninmenu = true; 
	self.zone_hud.x = 0;
	self.zone_hud.y = -100;
	self.zone_hud.alignX = "left";
	self.zone_hud.alignY = "bottom";
	self.zone_hud.horzAlign = "left";
	self.zone_hud.vertAlign = "bottom";
	self.zone_hud.color = (1, 1, 1);
	self.zone_hud.alpha = 1;
	self.zone_hud SetText( "Zone: None" );
	self thread zone_hud_watcher();
}

zone_hud_watcher()
{
	level endon("end_game");
    self endon("disconnect");

	if ( GetDvar( "st_zone_hud" ) == "1" )
	{
		self thread update_zone_hud();
	} 
	else {
		self.zone_hud SetText("");
	}

	level waittill("st_zone_hud_changed");
	self thread zone_hud_watcher();
}

update_zone_hud()
{
	flag_wait("all_players_spawned");

	while (1)
	{
		if ( GetDvar( "st_zone_hud" ) == "0" )
		{
			break;
		}

		wait_network_frame();
		zone = maps\_strattester_util::get_current_zone();
		if (!IsDefined(zone) || zone == "")
		{
			zone = "None";
		}
		self.zone_hud SetText("Zone: " + zone);
		wait .25;
	}
}