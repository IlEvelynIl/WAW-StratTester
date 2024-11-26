#include maps\_utility;
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
#include maps\_hud_util;

turn_on_power()
{
	host = get_players()[0];
	flag_wait( "all_players_connected" );
	wait 1;
	elec_trig = GetEnt( "use_master_switch", "targetname" );
	if( !IsDefined( elec_trig ) ) elec_trig = GetEnt( "use_power_switch", "targetname" );
	if(  IsDefined( elec_trig ) ) elec_trig notify( "trigger", host );
}

give_perk( perk )
{
    self SetPerk( perk );
    if ( perk == "specialty_armorvest" )
    {
    	if ( level.script == "nazi_zombie_factory" )
        {
            self.maxhealth = level.zombie_vars["zombie_perk_juggernaut_health"];
            self.health = level.zombie_vars["zombie_perk_juggernaut_health"];
        }
        else
        {
            self.maxhealth = 160;
            self.health = 160;
        }
    }
    
    self perk_hud_create(perk);
    self thread perk_think(perk);
}

perk_think( perk )
{
    self waittill_any( "fake_death", "death", "player_downed" );
    self UnsetPerk( perk );
    self.maxhealth = 100;
    self perk_hud_destroy( perk );
}

perk_hud_create( perk )
{
	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
	}

    shader = "";
    
    switch( perk )
    {
        case "specialty_armorvest":
            shader = "specialty_juggernaut_zombies";
            break;
        
        case "specialty_quickrevive":
            shader = "specialty_quickrevive_zombies";
            break;
        
        case "specialty_fastreload":
            shader = "specialty_fastreload_zombies";
            break;
        
        case "specialty_rof":
            shader = "specialty_doubletap_zombies";
            break;
        
        default:
            shader = "";
            break;
    }
    
    hud = NewClientHudElem(self);
    hud.foreground = true; 
    hud.sort = 1; 
    hud.hidewheninmenu = false; 
    hud.alignX = "left"; 
    hud.alignY = "bottom";
    hud.horzAlign = "left"; 
    hud.vertAlign = "bottom";
    hud.x = self.perk_hud.size * 30; 
    hud.y = hud.y - 70; 
    hud.alpha = 1;
    hud SetShader( shader, 24, 24 );
    
    self.perk_hud[ perk ] = hud;
}

perk_hud_destroy( perk )
{
	self.perk_hud[perk] Destroy();
	self.perk_hud[perk] = undefined;
}

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