/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_PlayAnimationOnEntity extends W3SwitchEvent
{
	editable var entityTag		: name;
	editable var animationName	: name;
	editable var operation		: EPropertyAnimationOperation;
	editable var playCount		: int;								default playCount = 1;
	editable var playLengthScale: float;							default playLengthScale = 1;
	editable var playMode		: EPropertyCurveMode;
	editable var rewindTime		: float;							default rewindTime = 0;
	
	
	hint entityTag		= "Entity tag to to play animation on";
	hint animationName	= "Animation to play on entity (needs to be defined in CGameplayEntity properties)";
	hint operation		= "Operation to perform";
	hint playCount		= "Number of times to play animation (applies only to 'Play' operation)";
	hint playLengthScale= "Playing length scale (applies only to 'Play' operation)";
	hint playMode		= "Playing mode (applies only to 'Play' operation)";
	hint rewindTime		= "Time position to rewind animation to (applies only to 'Rewind' operation)";
	
	
	public function Perform( parnt : CEntity )
	{	
		var entities : array<CEntity>;
		var i : int;
		var animatingEntity : CGameplayEntity;
						
		if ( animationName == '' )
		{
			LogAssert( false, "W3SE_PlayAnimationOnEntity: no animation name was defined" );
			return;
		}

		theGame.GetEntitiesByTag( entityTag, entities );
			
		if ( entities.Size() == 0 )
		{
			LogAssert( false, "No entities found with tag <" + entityTag + ">" );
			return;
		}
		
		for ( i = 0; i < entities.Size(); i += 1 )
		{
			animatingEntity = (CGameplayEntity)entities[ i ];
			if ( !animatingEntity )
			{
				LogAssert( false, "W3SE_PlayAnimationOnEntity: no gameplay entity with tag <" + entityTag + "> was found" );
			}
			else
			{
				switch ( operation )
				{
				case PAO_Play:
					DamageIfDamager(animatingEntity);
					animatingEntity.PlayPropertyAnimation( animationName, playCount, playLengthScale, playMode );
					break;
				case PAO_Stop:
					animatingEntity.StopPropertyAnimation( animationName );
					break;
				case PAO_Rewind:
					animatingEntity.RewindPropertyAnimation( animationName, rewindTime );
					break;
				}
			}
		}
	}
	
	private function DamageIfDamager( animatingEntity : CGameplayEntity )
	{
		var animatingDamageEntity : W3PhysicalDamageMechanism; 
		animatingDamageEntity = (W3PhysicalDamageMechanism)animatingEntity;
		if (animatingDamageEntity)
		{
			LogAssert( false, "W3SE_PlayAnimationOnEntity: Should be doing damage." );
			animatingDamageEntity.Activate();
		}
	}
}