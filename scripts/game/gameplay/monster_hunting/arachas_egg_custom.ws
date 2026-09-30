/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ArachasEggCustom extends W3MonsterClue
{
	editable var morphTimeIgni : float;
	editable var morphTimeAard : float;
	editable var burnoutTime   : float;
	
	saved var destroyed : bool;
	
	editable var igniReactionEffect : name;
	editable var aardReactionEffect : name;
	
	editable var onDestroyedFact : array<name>;
	
	var morphManager : CMorphedMeshManagerComponent;
	var morphTime : float;
	var allowFactAdding : bool;
	
	private const var APPEARANCE_INTACT : name;
	private const var APPEARANCE_DESTROYED : name;
	
	default APPEARANCE_INTACT = 'intact';
	default APPEARANCE_DESTROYED = 'destroyed';
	
	default morphTimeIgni = 3.0;
	default morphTimeAard = 0.1;
	default burnoutTime = 20.0;
	default allowFactAdding = true;	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		morphManager = (CMorphedMeshManagerComponent) this.GetComponentByClassName('CMorphedMeshManagerComponent');
		
		if(destroyed)
		{
			morphManager.SetMorphBlend( 1.0, 0.0 );
			ApplyAppearance( APPEARANCE_DESTROYED );
		}
		else
		{
			ApplyAppearance( APPEARANCE_INTACT );
		}
		
		super.OnSpawned( spawnData );
	}
	

	event OnIgniHit( sign : W3IgniProjectile )
	{
		if(!destroyed)
		{
			ArachasEggSignReaction( morphTimeIgni, igniReactionEffect );
		}
		
	}	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if(!destroyed)
		{
			ArachasEggSignReaction( morphTimeAard, aardReactionEffect );
		}
		
	}	

	
	private function ArachasEggSignReaction( selectedMorphTime : float, reactionEffect : name )
	{
		destroyed = true;
		PlayEffectSingle( reactionEffect );
		
		morphTime = selectedMorphTime;
		
		AddTimer('MorphEgg', 0.1f, false);
		
		this.SetAttributes(FCAA_ForceSet, false, false, false, false, false, false);
		
	}
	
	timer function DestroyedFinalizeTimer( time : float, optional id : int)
	{
		var i : int;
		
		ApplyAppearance( APPEARANCE_DESTROYED );
		
		if( allowFactAdding )
		{
			for( i=0; i < onDestroyedFact.Size(); i+=1 )
			{
				FactsAdd( onDestroyedFact[i], 1 );
			}
		}
	}
	
	timer function TurnEffectsOffTimer( time : float, optional id : int)
	{
		this.StopAllEffects();
	}
	
	timer function MorphEgg( time : float, optional id : int)
	{
		morphManager.SetMorphBlend( 1.0, morphTime );
		
		AddTimer('TurnEffectsOffTimer', burnoutTime, false);
		AddTimer('DestroyedFinalizeTimer', morphTime + 0.1, false);
		
	}
	
	public function ManualEggDestruction( addFact : bool )
	{
		allowFactAdding = addFact;
		ArachasEggSignReaction( 0.1f, '' );	
	}
	
}