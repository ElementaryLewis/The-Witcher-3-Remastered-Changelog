/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskActivateMagicBubble extends IBehTreeTask
{
	public var entityTemplate 		: CEntityTemplate;
	public var onAnimEvent 			: bool;
	public var animEventName 		: name;
	public var resourceName 		: name;
	
	private var spawnedEntity 		: CEntity;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !onAnimEvent && entityTemplate )
		{
			CreateAndAttachEntity();
			ToggleActivateEntity( true );
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( !entityTemplate )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( resourceName );
		}
		
		if ( !entityTemplate )
		{
			return BTNS_Failed;
		}
		
		if ( !onAnimEvent )
		{
			CreateAndAttachEntity();
			ToggleActivateEntity( true );
			return	BTNS_Completed;
		}
		
		
		return BTNS_Active;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( onAnimEvent && animEventName == 'animEventName' )
		{
			CreateAndAttachEntity();
			ToggleActivateEntity( true );
			return true;
		}
		return false;
	}
	
	
	function ToggleActivateEntity( toggle : bool )
	{
		((W3MagicBubbleEntity)spawnedEntity).ToggleActivate(toggle);
	}
	
	function CreateAndAttachEntity()
	{
		var tags : array<name>;
		spawnedEntity = theGame.CreateEntity( entityTemplate, GetActor().GetWorldPosition(), GetActor().GetWorldRotation() );
		spawnedEntity.CreateAttachment( GetActor(), 'magic_bubble' );
		tags = spawnedEntity.GetTags();
		tags.PushBack('q104_magicBubble_AITask');
		spawnedEntity.SetTags(tags);
	}
};

class CBTTaskActivateMagicBubbleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskActivateMagicBubble';

	
	editable var resourceName 			: CBehTreeValCName;
	editable var onAnimEvent 			: bool;
	editable var animEventName 			: name;
	
	default animEventName = 'Attach';
	
	
}


class CBTTaskDeactivateMagicBubble extends IBehTreeTask
{
	public var tag : name;
	public var onAnimEvent 			: bool;
	public var animEventName 		: name;
	
	default tag = 'q104_magicBubble_AITask';
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !onAnimEvent )
		{
			DespawnEntity();
		}
		
		return BTNS_Active;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( onAnimEvent && animEventName == 'animEventName' )
		{
			DespawnEntity();
			return true;
		}
		return false;
	}
	
	function DespawnEntity()
	{
		var entities : array<CGameplayEntity>;
		var magicBubble : W3MagicBubbleEntity;
		
		FindGameplayEntitiesInRange(entities,GetActor(),1,1,tag);
		
		if ( entities.Size() > 0 )
		{
			magicBubble = (W3MagicBubbleEntity)entities[0];
			if ( magicBubble )
			{
				magicBubble.ToggleActivate(false);
				magicBubble.DestroyAfter(5);
			}
			else
				entities[0].DestroyAfter(5);
		}
	}
};

class CBTTaskDeactivateMagicBubbleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDeactivateMagicBubble';

	
	editable var onAnimEvent 			: bool;
	editable var animEventName 			: name;
	
	default animEventName = 'Attach';
}