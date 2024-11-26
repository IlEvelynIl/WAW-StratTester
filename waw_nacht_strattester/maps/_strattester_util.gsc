#include maps\_utility;
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
#include maps\_hud_util;

get_current_zone()
{
    // zkeys = GetArrayKeys( level.zones );
    // zone_name = undefined;
    // for ( i = 0; i < zkeys.size; i++ )
    // {
    //     zone = zkeys[i];
    //     in_zone = player_in_zone(zone);

    //     if (in_zone)
    //     {
    //         zone_name = zone;
    //         break;
    //     }
    // }
    
    return "No Zones";
}

open_doors()
{
    doors = getentarray( "zombie_door", "targetname" );
    for ( i = 0; i < doors.size; i++ )
    {
        door_target = doors[i].target;

        if ( !isDefined( door_target ) )
        {
            continue;
        }

        doors[i] notify( "trigger", self, true );
        wait( 0.05 );
    }

    debris = getentarray( "zombie_debris", "targetname" );
    for ( i = 0; i < debris.size; i++ )
    {
        debris_target = debris[i].target;

        if ( !isDefined( debris_target ) )
        {
            continue;
        }

        if ( level.script == "nazi_zombie_factory" && i == 1 ) continue; // thompson stairs debris
        if ( level.script == "nazi_zombie_prototype" && debris[i].target == "upstairs_blocker" ) continue;
        if ( level.script == "nazi_zombie_prototype" && debris[i].target == "upstairs_blocker2" ) continue;

        debris[i] notify( "trigger", self, true );
        wait( 0.05 );
    }
}

break_all_barriers()
{
    window_boards = getstructarray( "exterior_goal", "targetname" );
    for ( i = 0; i < window_boards.size; i++ )
    {
        thread clear_window( window_boards[i] );
        wait( 0.05 );
    }
}

clear_window(window)
{
	if ( !all_chunks_destroyed(window.barrier_chunks) )
	{
		chunks = window.barrier_chunks;
		for ( j = 0; j < chunks.size; j++ )
		{
			window thread maps\_zombiemode_blockers::remove_chunk( chunks[j], window );
			wait_network_frame();
			wait( 0.05 );
		}
			
		if ( all_chunks_destroyed(window.barrier_chunks) )
		{
			if ( IsDefined(window.clip) )
			{

				window.clip ConnectPaths();
				wait( 0.05 ); 
				window.clip disable_trigger();  
			}
			else
			{
				for( k = 0; k < window.barrier_chunks.size; k++ )
				{
					window.barrier_chunks[k] ConnectPaths(); 
				}
			}
		}

		wait_network_frame();	
	}
}

seconds_to_string(seconds) {
	hours = int(seconds / 3600);
	minutes = int((seconds - (hours * 3600)) / 60);
	seconds = seconds % 60;

	if(seconds < 10) {
		seconds = "0" + seconds;
	}

	if(minutes < 10 && hours >= 1) {
		minutes = "0" + minutes;
	}

	time = "";

	if(hours > 0) {
		time = hours + ":";
	}
		time += minutes + ":" + seconds;

	return time;
}