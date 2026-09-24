/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSpawnEntityOffset extends CBTTaskPlayAnimationEventDecorator
{
	var positionOffset						: Vector;
	var npc 								: CNewNPC;	
	var resourceName						: name;
	var entityTemplate						: CEntityTemplate;
	var completeAfterSpawn					: bool;
	var complete							: bool;
	var spawnEntityOnAnimEvent				: bool;
	var addEntityToSummonerComponent		: bool;
	var spawnAnimEventName					: name;
	var tagToAdd							: name;
	var onActivate							: bool;
	var onDeactivate						: bool;
	var addTagToEntity						: bool;
	var destroyTaggedEntitiesOnDeactivate	: bool;
	var entity 								: CEntity;
	var entities							: array<CEntity>;
	var destroyEntityAfter					: float;
	var spawnEntityAtNode					: bool;
	var tagToFindNode						: name;
	
	protected var m_summonerComponent		: W3SummonerComponent;
	
	private var couldntLoadResource : bool;
	
	function Initialize()
	{
		m_summonerComponent = (W3SummonerComponent) GetNPC().GetComponentByClassName('W3SummonerComponent');
		complete = false;
	}
	
	function IsAvailable() : bool
	{
		return super.IsAvailable();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		if( onActivate)
		{
			SpawnEntity();
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if( !entityTemplate )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( resourceName );
		}
		
		if( !spawnEntityOnAnimEvent )
		{
			SpawnEntity();
		}
			
		if( complete )
		{
			return BTNS_Completed;
		}
		return BTNS_Active;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( IsNameValid( spawnAnimEventName ) && animEventName == spawnAnimEventName && spawnEntityOnAnimEvent )
		{
			SpawnEntity();
			return true;
		}
		
		if ( IsNameValid( spawnAnimEventName ) && animEventName == 'Attach'  )
		{
			entity.CreateAttachment( npc );
		}
		else if ( IsNameValid( spawnAnimEventName ) && animEventName == 'Detach' )
		{
			entity.BreakAttachment();
		}
		
		return res;
	}
	
	function SpawnEntity()
	{
		var matrix				: Matrix;
		var spawnPos 			: Vector;
		var rotation			: EulerAngles;
		var l_node				: CNode;
		var createEntityHelper	: CCreateEntityHelper;
		
		if( spawnEntityAtNode )
		{
			l_node = theGame.GetNodeByTag( tagToFindNode );
			
			spawnPos = l_node.GetWorldPosition();
			rotation = l_node.GetWorldRotation();
		}
		else
		{
			matrix = npc.GetLocalToWorld();
			spawnPos = VecTransform( matrix, positionOffset);
			rotation = npc.GetWorldRotation();
		}
		
		
		
		
		entity = theGame.CreateEntity( entityTemplate, spawnPos, rotation );
		
		if( m_summonerComponent && addEntityToSummonerComponent )
		{
			m_summonerComponent.AddEntity( entity );
		}
		
		if( addTagToEntity )
		{
			entity.AddTag( tagToAdd );
		}
			
		if( completeAfterSpawn )
		{
			complete = true ;
		}
	}

	function OnDeactivate()
	{
		var i : int;
		
		if( onDeactivate )
		{
			SpawnEntity();
		}
		
		if( destroyTaggedEntitiesOnDeactivate )
		{
			theGame.GetEntitiesByTag( tagToAdd,entities );
			for( i=0; i<entities.Size(); i+=1 )
			{
				entities[i].Destroy();
			}
		}
		
		if( destroyEntityAfter > 0 )
		{
			entity.StopAllEffects();
			entity.DestroyAfter( destroyEntityAfter );
		}
	}
}

class CBTTaskSpawnEntityOffsetDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskSpawnEntityOffset';
	
			 var npc 								: CNewNPC;
	editable var resourceName						: CBehTreeValCName;
	editable var entityTemplate						: CEntityTemplate;
	editable var positionOffset						: Vector;	
	editable var completeAfterSpawn					: bool;
			 var complete							: bool;
	editable var spawnEntityOnAnimEvent				: bool;
	editable var spawnAnimEventName					: name;
	editable var addEntityToSummonerComponent		: bool;
	editable var addTagToEntity						: bool;
	editable var tagToAdd							: name;
	editable var onActivate							: bool;
	editable var onDeactivate						: bool;
	editable var destroyTaggedEntitiesOnDeactivate	: bool;
	editable var destroyEntityAfter					: float;
			 var entity 							: CEntity;
			 var entities							: array<CEntity>;
	editable var spawnEntityAtNode					: bool;
	editable var tagToFindNode						: name;
	
	default addEntityToSummonerComponent = false;
	default destroyEntityAfter = 5.0;
	default complete = false;
	default spawnAnimEventName = 'SpawnEntity';
}

class CBTTaskSpawnSlidingEntity extends CBTTaskSpawnEntityOffset
{
	var component				: CComponent;
	var slideComponent			: W3SlideToTargetComponent;
	var targetNode				: CNode ;
	var timeToFollow			: int;
	var timeStamp 				: float;
	var destroyAfter			: float;
	var destroyAfterTimerEnds	: bool;
	var destroyOnDeactivate		: bool;
	
	latent function Main() : EBTNodeStatus
	{
		super.Main();
		
		component = entity.GetComponentByClassName( 'W3SlideToTargetComponent' );
		slideComponent = ( W3SlideToTargetComponent ) component ;
		
		if( !slideComponent )
		{
			return BTNS_Failed;
		}
		
		slideComponent.SetTargetNode( thePlayer );
		timeStamp = GetLocalTime();
		
		if( destroyAfter > 0 )
		{
			entity.StopAllEffects();
			entity.DestroyAfter( destroyAfter );
		}
		
		Sleep( timeToFollow );
		
		
		
		slideComponent.SetTargetNode(NULL);
		
		
		
		if( destroyAfterTimerEnds )
		{
			entity.StopAllEffects();
			entity.Destroy();
		}
			
		
		return BTNS_Active;
		
	}
		
	function OnDeactivate()
	{
		if( destroyOnDeactivate )
		{
			entity.Destroy();
		}
	}
}
class CBTTaskSpawnSlidingEntityDef extends CBTTaskSpawnEntityOffsetDef
{
	default instanceClass = 'CBTTaskSpawnSlidingEntity';
	
	var slideComponent						: W3SlideToTargetComponent;
	var targetNode							: CNode ;
	editable var timeToFollow				: int;
	editable var destroyAfter				: float;
	editable var destroyAfterTimerEnds		: bool;
	editable var destroyOnDeactivate		: bool;
}
