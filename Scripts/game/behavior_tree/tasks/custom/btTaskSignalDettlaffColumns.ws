/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSignalDettlaffColumns extends IBehTreeTask
{
	var npc 						: CNewNPC;
	var summonerComponent 			: W3SummonerComponent;
	var summonsArray				: array <CEntity>;
	var columnEntity				: CDettlaffColumn;
	var cocoonEntity				: CEntity;
	var shouldComplete				: bool;
	var startPumping				: bool;
	var stopPumping					: bool;
	
	
	latent function Main() : EBTNodeStatus
	{
		var i : int;
		npc = GetNPC();
		theGame.GetEntitiesByTag( 'arena_support', summonsArray );
		cocoonEntity = theGame.GetEntityByTag('q704_cocoon_on_layer');
		for( i=0; i<summonsArray.Size(); i+=1 )
		{
			columnEntity = (CDettlaffColumn)summonsArray[i];
			if( startPumping )
			{
				columnEntity.StartPumping();
				cocoonEntity.PlayEffect('pumping');
			}
			else if( stopPumping )
			{
				columnEntity.StopPumping();
				cocoonEntity.StopEffect('pumping');
			}
		}
		
		if( shouldComplete )
		{
			return BTNS_Completed;
		}
		else return BTNS_Active;
	}
}
class CBTTaskSignalDettlaffColumnsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSignalDettlaffColumns';
	
	var npc 						: CNewNPC;
	var summonerComponent 			: W3SummonerComponent;
	var summonsArray				: array <CEntity>;
	var columnEntity				: CDettlaffColumn;
	editable var shouldComplete		: bool;
	editable var startPumping		: bool;
	editable var stopPumping		: bool;
	
	default shouldComplete = false;

}

class CBTTaskSignalDettlaffArenaDestruction extends IBehTreeTask
{
	var npc : CNewNPC;
	var entity : CEntity;
	var destroyTime	:float;
	
	function OnActivate() : EBTNodeStatus
	{
		destroyTime = 10.f;
		npc = GetNPC();
		SignalDettlaffArena();
		return BTNS_Active;
	}
	
	function SignalDettlaffArena()
	{
		entity = theGame.GetEntityByTag('dettlaff_minion');
		entity.PlayEffect('avatar_death');
		entity.DestroyAfter(1.0f);
		
		entity = theGame.GetEntityByTag('q704_cocoon_on_layer');
		entity.PlayEffect('disappearing');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_arena_on_layer');
		entity.PlayEffect('arena_end');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_lights_on_arena');
		entity.StopEffect('lightning');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_tree_001_on_layer');
		entity.PlayEffect('disappearing');
		entity.DestroyAfter(destroyTime);
		entity = theGame.GetEntityByTag('q704_tree_002_on_layer');
		entity.PlayEffect('disappearing');
		entity.DestroyAfter(destroyTime);
		entity = theGame.GetEntityByTag('q704_tree_003_on_layer');
		entity.PlayEffect('disappearing');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_outer_on_layer');
		entity.PlayEffect('disappearing');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_gotoplanes');
		entity.PlayEffect('gotoplanes');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_ground_collision');
		entity.DestroyAfter(destroyTime);
		
		entity = theGame.GetEntityByTag('q704_lights_on_layer');
		entity.DestroyAfter(destroyTime);
		
	}
	
		
	function OnDeactivate()
	{
		
	}
}
class CBTTaskSignalDettlaffArenaDestructionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSignalDettlaffArenaDestruction';
	
	var npc : CNewNPC;
	var entity : CEntity;
	var destroyTime	:float;
	
	
	
}
class CBTTaskLockViewToDettlaff extends IBehTreeTask
{
	var actor : CActor;
	var lock : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if(lock)
		{
			actor = theGame.GetActorByTag('dettlaff_monster');
			thePlayer.SetPlayerTarget(actor);
			thePlayer.SetPlayerCombatTarget(actor);
			thePlayer.HardLockToTarget(true);
			thePlayer.BlockAction(EIAB_CameraLock,'dettlaff');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_CameraLock,'dettlaff');
		}
		return BTNS_Active;
	}

}
class CBTTaskLockViewToDettlaffDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskLockViewToDettlaff';
	editable var lock : bool;
	var actor : CActor;
	
	default lock = true; 
}
class ManageProjectilesDettlaff extends IBehTreeTask
{
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( animEventName == 'RepulseProjectiles' && animEventType == AET_DurationStart )
		{
			GetNPC().RemoveAbility('RepulseProjectiles');
		}
		else if( animEventName == 'RepulseProjectiles' && animEventType == AET_DurationEnd )
		{
			GetNPC().AddAbility('RepulseProjectiles');
		}
		return true;
	}
}
class ManageProjectilesDettlaffDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'ManageProjectilesDettlaff';
}