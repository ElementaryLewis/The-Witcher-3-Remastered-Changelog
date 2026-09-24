/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CGhost extends CNewNPC
{
	editable var isCastingShadows : bool;
	editable var soundEffectType  : EFocusModeSoundEffectType; default soundEffectType = FMSET_None;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var i 					: int;
		var components 			: array < CComponent >;
		var drawableComponent 	: CDrawableComponent;
		
		super.OnSpawned( spawnData );
		EnableCharacterCollisions( false );
		SetFocusModeSoundEffectType( soundEffectType );
		
		
		if ( !isCastingShadows )
		{
			components =  GetComponentsByClassName ( 'CDrawableComponent' );
			
			for ( i = 0; i < components.Size(); i+=1 )
			{
				drawableComponent = ( CDrawableComponent)components[i];
				drawableComponent.SetCastingShadows ( false );
			}
		}

		if( FactsQuerySum( "q106_magic_oillamp_used" ) > 0  )
		{
			theGame.HapticStart( "haptic_lamp_discovery" );
		}
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
	
	}
	event OnAardHit( sign : W3AardProjectile )
	{
	
	}
	event OnIgniHit( sign : W3IgniProjectile )
	{
	
	}
}

class CGhostComponent extends CR4Component
{
	editable var isCastingShadows : bool;
	editable var soundEffectType  : EFocusModeSoundEffectType; default soundEffectType = FMSET_None;
	
	event OnComponentAttachFinished()
	{
		var i 					: int;
		var components 			: array < CComponent >;
		var drawableComponent 	: CDrawableComponent;
		var npc					: CNewNPC;
		
		
		npc = (CNewNPC)GetEntity();
		
		npc.EnableCharacterCollisions(false);
		npc.SetFocusModeSoundEffectType( soundEffectType );
		
		if ( !isCastingShadows )
		{
			components =  npc.GetComponentsByClassName ( 'CDrawableComponent' );
			
			for ( i = 0; i < components.Size(); i+=1 )
			{
				drawableComponent = ( CDrawableComponent)components[i];
				drawableComponent.SetCastingShadows ( false );
			}
		}
	}
	
}