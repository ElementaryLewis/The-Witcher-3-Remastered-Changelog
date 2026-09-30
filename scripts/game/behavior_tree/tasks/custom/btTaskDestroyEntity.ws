/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDestroyEntity extends IBehTreeTask
{
	var entityTag 			: name;
	var playEffectName		: name;
	var stopEffectName		: name;
	var eventToRaise		: name;
	var playEffect			: bool;
	var stopEffect			: bool;
	var destroyAfter		: float;
	var onActivate			: bool;
	var onDeactivate		: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if( entityTag != '' && onActivate )
		{
			FindAndDestroyEntity();
		}
		
		return BTNS_Active;
	}
	
	private function FindAndDestroyEntity()
	{
		var entitiesArray   : array<CEntity>; 
		var i				: int;

		theGame.GetEntitiesByTag( entityTag, entitiesArray );
		
		if( entitiesArray.Size() > 0 )
		{
			for( i=0; i<entitiesArray.Size(); i+=1)
			{
				entitiesArray[i].RaiseEvent( eventToRaise );
				
				if( playEffect )
				{
					entitiesArray[i].PlayEffect( playEffectName );
				}
				else if( stopEffect )
				{
					entitiesArray[i].StopEffect( stopEffectName );
				}
				
				entitiesArray[i].DestroyAfter( destroyAfter );
				
			}
		}
	}
	
	function OnDeactivate()
	{
		if( entityTag != '' && onDeactivate )
		{
			FindAndDestroyEntity();
		}
	}
};

class CBTTaskDestroyEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDestroyEntity';
	
	editable var entityTag 		: name;
	editable var playEffectName	: name;
	editable var stopEffectName	: name;
	editable var eventToRaise	: name;
	editable var playEffect		: bool;
	editable var stopEffect		: bool;
	editable var destroyAfter	: float;
	editable var onActivate		: bool;
	editable var onDeactivate	: bool;
	
	default onActivate = true;
	default playEffect = false;
	default destroyAfter = 1.0f;
	default eventToRaise = 'Death';
};