/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBombardmentAttack extends IBehTreeTask
{
	private var npc : CNewNPC;
	private var performBombardment : bool;
	private var entityTemplate : CEntityTemplate;
	
	private var resourceName : string;
	private var afterSpawnDelay : float;
	private var initialDelay : float;
	private var yOffset : float;
	private var fxName	: name;
	
	default performBombardment = false;
	default resourceName = "dlc\bob\data\fx\monsters\fairytale_witch\liquid_hit_ground.w2ent";
	
	function Initialize()
	{
		npc = GetNPC();
	}
	
	latent function Main() : EBTNodeStatus
	{
		if( !entityTemplate )
		{
			entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName, true );
		}
		
		while( !performBombardment )
		{
			SleepOneFrame();
		}
		
		Sleep( initialDelay );
		
		while( performBombardment )
		{
			Spawn( FindPosition() );
			
			Sleep( afterSpawnDelay );
		}

		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		performBombardment = false;
		npc.StopEffect( 'liquid' );
	}
	
	private function FindPosition() : Vector
	{
		var basePos : Vector;
		var offsetedHeadingVector : Vector;
		var outZ : float;
		
		basePos = npc.GetWorldPosition();
		offsetedHeadingVector =  npc.GetHeadingVector() * yOffset;
		basePos += offsetedHeadingVector;
		
		theGame.GetWorld().NavigationComputeZ( basePos, basePos.Z - 30.0, basePos.Z + 30.0, outZ );
		basePos.Z = outZ;
		
		return basePos;
	}
	
	private function Spawn( position : Vector )
	{
		var entity : CEntity;
		var randYaw : float;
		var rotation : EulerAngles;
		var bulb : W3ArchesporBulb;
		
		if( entityTemplate )
		{
			randYaw = RandRangeF( 180.0, -180.0 );
			rotation.Yaw = randYaw;
			entity = theGame.CreateEntity( entityTemplate, position, rotation );
		}
		
		bulb = (W3ArchesporBulb)entity;
		
		if( bulb )
		{
			bulb.AddTag( 'immediateExplode' );
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'StartBombardment' )
		{
			performBombardment = true;
			npc.PlayEffect( 'liquid' );
			return true;
		}
		else if( animEventName == 'StopBombardment' )
		{
			performBombardment = false;
			npc.StopEffect( 'liquid' );
			return true;
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{	
		if( eventName == 'DamageTaken' )
		{
			performBombardment = false;
			npc.StopEffect( 'liquid' );
		}
		
		return true;
	}
}

class CBTTaskBombardmentAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskBombardmentAttack';

	editable var initialDelay : float;
	editable var afterSpawnDelay : float;
	editable var yOffset : float;
	editable var fxName	: name;

	default initialDelay = 0.1;
	default afterSpawnDelay = 0.1;
	default yOffset = -1.0;
	default fxName = '';
}



class CBTIsPlayerInsideDiveAttackArea extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return thePlayer.IsInsideDiveAttackArea();
	}
}

class CBTIsPlayerInsideDiveAttackAreaDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTIsPlayerInsideDiveAttackArea';
}



class CBTIsPlayerInsideSelectedDiveAttackArea extends IBehTreeTask
{
	var areaNumber : int;
	
	function IsAvailable() : bool
	{
		return thePlayer.GetDiveAreaNumber() == areaNumber;
	}
}

class CBTIsPlayerInsideSelectedDiveAttackAreaDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTIsPlayerInsideSelectedDiveAttackArea';
	
	editable var areaNumber : int;
}