#include maps\_utility; 
#include common_scripts\utility;
#include maps\_zombiemode_utility;

total_timer_hud()
{
	level endon("end_game");
	flag_wait( "all_players_connected" );

	level.game_time = 0;
	wait 1.5;

	while (1)
	{
		level.game_time++;
		SetDvar( "st_total_timer_value", maps\_strattester_util::seconds_to_string( level.game_time ) );
		wait( 1 );
	}
}

round_timer_hud()
{
	level endon("end_game");
	flag_wait( "all_players_connected" );

	level.round_time = 0;

	while (1)
	{
		level waittill( "start_of_round" );

		while (1)
		{
			level.round_time = int(GetTime() / 1000) - level.current_round_start_time;
			SetDvar( "st_round_timer_value", maps\_strattester_util::seconds_to_string( level.round_time ) );
			wait( 0.5 );
		}
	}
}

remaining_hud()
{
	level endon("end_game");
	flag_wait( "all_players_connected" );

	while (1)
	{
		wait_network_frame();
		zombies = level.zombie_total + get_enemy_count();
		SetDvar( "st_remaining_hud_value", zombies );
		wait .25;
	}
}

sph_hud()
{
	level endon("end_game");
	flag_wait( "all_players_connected" );

	while (1)
	{
		level waittill( "start_of_round" );

		while (1)
		{
			zombies_thus_far = level.global_zombies_killed_round;
			hordes = zombies_thus_far / 24;
			current_time = int( GetTime() / 1000 ) - level.current_round_start_time;

			if ( level.zombie_total + get_enemy_count() == 0 )
			{
				current_time = level.current_round_end_time - level.current_round_start_time;
			}

			if (hordes <= 0)
			{
				SetDvar( "st_sph_hud_value", "0" );
			}
			else {
				level.round_seconds_per_horde = int( current_time / hordes * 100 ) / 100;
				SetDvar( "st_sph_hud_value", level.round_seconds_per_horde );
			}

			wait 1;
		}
	}
}

// zone_hud()
// {   
// 	level endon("end_game");
// 	flag_wait( "all_players_connected" );

// 	while (1)
// 	{
// 		wait_network_frame();
// 		zone = maps\_strattester_util::get_current_zone();
		
// 		if ( zone == "" )
// 		{
// 			zone = "None";
// 		}

// 		SetDvar("st_zone_hud_value", zone);
		
// 		wait .25;
// 	}
// }