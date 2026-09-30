/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SpawnEntityOnAnimEvent extends CScriptedComponent
{
	editable var animEvent 		: name;
	editable var entityName		: name;
	
	default animEvent = 'SpawnEntityEvent';
	
	hint animEvent = "Animation Event Name";
	hint entityName = "Resource Name";
	
	private var entityTemplate	: CEntityTemplate;
	
	
	event OnComponentAttached()
	{
		var l_actor : CActor;
		l_actor = (CActor) GetEntity();
		if( l_actor )
		{
			l_actor.AddAnimEventChildCallback(this,animEvent,'OnAnimEvent_Custom');
		}	
		
		entityTemplate = (CEntityTemplate) LoadResource( entityName );
	}
	
	
	event OnAnimEvent_Custom( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		SpawnEntity();
	}
	
	function SpawnEntity()
	{
		var spawnPos 			: Vector;
		var entity 				: CEntity;
		var damageAreaEntity 	: CDamageAreaEntity;
		
		
		if( !entityTemplate )
		{
			return;
		}
		
		spawnPos = GetEntity().GetWorldPosition();
		entity = theGame.CreateEntity( entityTemplate, spawnPos, GetEntity().GetWorldRotation() );
		damageAreaEntity = (CDamageAreaEntity)entity;
		if ( damageAreaEntity )
		{
			damageAreaEntity.owner = (CActor) GetEntity();
		}
	}
}