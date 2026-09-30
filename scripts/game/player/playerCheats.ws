/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function ParseCameraViewString( cameraViewString : string, position: Vector, orientation: EulerAngles) : bool;


exec function killall( optional range : float )
{	
	var enemies: array<CActor>;
	var i, enemiesSize : int;
	var npc : CNewNPC;
	
	if( range <= 0.0f )
	{
		range = 20.0f;
	}
	
	enemies = GetActorsInRange(thePlayer, range);
	
	enemiesSize = enemies.Size();
	
	for( i = 0; i < enemiesSize; i += 1 )
	{
		npc = (CNewNPC)enemies[i];
		
		if( npc )
		{
			if( npc.GetAttitude( thePlayer ) == AIA_Hostile )
			{
				npc.Kill( 'Debug' );
			}
		}
	}
}


exec function RestoreStamina( optional val : int )
{	
	if( val == 0 )
	{
		val = 1000;
	}
	
	thePlayer.GainStat( BCS_Stamina, val );
}


exec function staminaboy()
{
	StaminaBoyInternal(!FactsDoesExist("debug_fact_stamina_boy"));
	thePlayer.GainStat(BCS_Stamina, thePlayer.GetStatMax(BCS_Stamina));
}

function StaminaBoyInternal(on : bool)
{
	if(on)
	{
		FactsAdd("debug_fact_stamina_boy");			
		LogCheats( "Stamina Boy is now ON" );
	}
	else
	{
		FactsRemove("debug_fact_stamina_boy");
		LogCheats( "Stamina Boy is now OFF" );
	}
}

exec function staminapony()
{
	StaminaPonyInternal(!FactsDoesExist("debug_fact_stamina_pony"));
}

function StaminaPonyInternal(on : bool)
{
	if(on)
	{
		FactsAdd("debug_fact_stamina_pony");			
		LogCheats( "Stamina Pony is now ON" );
	}
	else
	{
		FactsRemove("debug_fact_stamina_pony");
		LogCheats( "Stamina Pony is now OFF" );
	}
}


exec function buffgeralt( buffName : name, optional duration : float, optional src : string )
{
	var type : EEffectType;
	var customAb : name;
	var params : SCustomEffectParams;
	
	EffectNameToType(buffName, type, customAb);		
	
	if(src == "")
		src = "console";
	
	if(duration > 0)
	{
		params.effectType = type;
		params.sourceName = src;
		params.duration = duration;
		thePlayer.AddEffectCustom(params);
	}
	else
	{
		thePlayer.AddEffectDefault(type, NULL, src);
	}
}

exec function knockdown()
{
	thePlayer.AddEffectDefault( EET_HeavyKnockdown, NULL, "console" );
}

exec function bufftarget( type : EEffectType, optional duration : float, optional src : name )
{
	var params : SCustomEffectParams;
	
	var target : CActor;
	
	target = thePlayer.GetTarget();
	
	if (!target)
		return;
	
	if(duration > 0)
	{
		params.effectType = type;
		params.sourceName = src;
		params.duration = duration;
		target.AddEffectCustom(params);
	}
	else
	{
		target.AddEffectDefault(type, NULL, src);
	}
}


exec function HealGeralt( )
{
	thePlayer.GainStat(BCS_Vitality, 10);
}





exec function addexp( amount : int )
{
	if( amount > 0 )
	{
		GetWitcherPlayer().AddPoints(EExperiencePoint, amount, false );
	}
}


exec function setlevel( targetLvl : int )
{
	var lm : W3PlayerWitcher;
	var exp, prevLvl, currLvl : int;
	
	lm = GetWitcherPlayer();
	prevLvl = lm.GetLevel();
	currLvl = lm.GetLevel();
		
	while(currLvl < targetLvl)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false);
		currLvl = lm.GetLevel();
		
		if(prevLvl == currLvl)
			break;				
		
		prevLvl = currLvl;
	}	
}


exec function levelup( optional times : int )
{
	var lm : W3PlayerWitcher;
	var i,exp : int;
	
	if(times < 1)
		times = 1;
		
	lm = GetWitcherPlayer();
	for(i=0; i<times; i+=1)
	{
		exp = lm.GetTotalExpForNextLevel() - lm.GetPointsTotal(EExperiencePoint);
		lm.AddPoints(EExperiencePoint, exp, false );
	}
}

exec function addskillpoints( optional value : int )
{	
	if(value < 1)
		value = 1;
		
	GetWitcherPlayer().levelManager.AddPoints(ESkillPoint,value, true);
}






exec function LogPlayerDev()
{

}

exec function testsw( tag : name )
{
	var e : CEntity;
	var sw : W3Switch;
	
	e = theGame.GetEntityByTag( tag );


	sw = (W3Switch)e;

	if( sw )
	{
		LogChannel( 'Switch', "USING " + sw );
		sw.Toggle( thePlayer, false, false );
	}

}


exec function readbook( bookName : name )
{
	thePlayer.inv.ReadBookByName( bookName, false );
}


exec function bookread( bookName : name )
{
	var read : bool;
	
	read = thePlayer.inv.IsBookReadByName( bookName );
	
	LogChannel( 'BooksDebug', bookName + " -> " + read );
}


exec function slog()
{
	thePlayer.LogStates();
}

exec function sgo( sname : name, optional bforce : bool, optional bkeep : bool )
{
	thePlayer.GotoState( sname, bkeep, bforce );
}

exec function spop( optional ball : bool )
{
	thePlayer.PopState( ball );
}

exec function spush( sname : name )
{
	thePlayer.PushState( sname );
}


exec function CombatStage( npcTag : name, stage : ENPCFightStage )
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( npcTag );
	
	npc.ChangeFightStage( stage );

	
}
exec function ChangeAp( npcTag : name, appearanceName : name )
{
	var npc : CNewNPC;
	
	npc = theGame.GetNPCByTag( npcTag );
	
	npc.SetAppearance( appearanceName );
}

exec function tptonode( nodeName : name )
{
	var node : CNode;
	
	node = theGame.GetNodeByTag( nodeName );
	
	thePlayer.TeleportToNode( node );
}

exec function tptopos( x : float, y : float, z : float )
{
	thePlayer.Teleport( Vector( x, y, z) );
}

exec function tlp( cameraString : string )
{
	var parseSuccessful : bool;
	var position : Vector;
	var orientation : EulerAngles;
	
	parseSuccessful = ParseCameraViewString( cameraString, position, orientation );
	if ( parseSuccessful )
	{
		thePlayer.TeleportWithRotation( position, orientation );
	}
	else
	{
		LogCheats( "tlp() Error : Cannot parse camera view string : " + cameraString );
	}
}

exec function xy( x : float, y : float )
{
	var z : float;
	var pos, norm : Vector;
	if ( theGame.GetWorld().StaticTrace( Vector( x, y, 1000.f ), Vector( x, y, -1000.f ), pos, norm ) )
	{
		z = pos.Z + 0.1f;
	}
	else
	{
		z = 500.1f;
	}
	thePlayer.Teleport( Vector( x, y, z ) );
}

exec function moveCamera(x : float, y : float, z : float, rx : float, ry : float, rz : float) {
	theGame.MoveFreeCamera(Vector(x, y, z), EulerAngles(rx, ry, rz));
}

exec function TrajectoryDebug( actorTag : name )
{
	var actor : CActor;
	
	
	actor = theGame.GetActorByTag( actorTag );
	
	
	
}

exec function BoatTeleport( tag : name, optional offset : float )
{
	var entities 		: array< CGameplayEntity >;
	var i 				: int;
	var boat			: W3Boat;
	var playerPos		: Vector;
	var totalOffset		: float;
	
	totalOffset = 5.0f;
	
	boat = (W3Boat)theGame.GetEntityByTag( tag );
	
	if( boat )
	{
		if( offset != 0 )
			totalOffset = offset;
			
		playerPos = VecNormalize2D( theCamera.GetCameraDirection() );
		playerPos.Z = 0;
		playerPos *= totalOffset;
		playerPos += thePlayer.GetWorldPosition();
		boat.Teleport( playerPos );
	}
}

exec function boatdealdamage()
{
	var boat : W3Boat;
	var destruction : CBoatDestructionComponent;
	var boatPos : Vector;
	var i : int;
	
	boat = NULL;
	destruction = NULL;
	
	boat = (W3Boat)thePlayer.GetUsedVehicle();
	
	if( boat )
	{
		destruction = (CBoatDestructionComponent)boat.GetComponentByClassName('CBoatDestructionComponent');
	
		if( destruction )
		{
			boatPos = boat.GetWorldPosition();
			
			for(i=0; i<destruction.partsConfig.Size(); i+=1)
			{
				destruction.DealDamage( 90, i, boatPos );
			}
		}
	}	
}

exec function mountboat( optional passenger : bool )
{
	var entities 		: array< CGameplayEntity >;
	var i 				: int;
	var boat			: W3Boat;
	var boatComponent	: CBoatComponent;
	
	boat = NULL;
	
	FindGameplayEntitiesInRange( entities, thePlayer, 10, 50 );
	
	for( i=0; i<entities.Size(); i+=1 )
	{
		boat = (W3Boat)entities[i];
		
		if( boat )
			break;
	}
	
	if( boat )
	{
		boatComponent = (CBoatComponent)boat.GetComponentByClassName( 'CBoatComponent' );
		
		if( boatComponent )
		{
			if( passenger )				
				boatComponent.Mount( thePlayer, VMT_ImmediateUse, EVS_passenger_slot );
			else
				boatComponent.Mount( thePlayer, VMT_ImmediateUse, EVS_driver_slot );
		}
	}
}