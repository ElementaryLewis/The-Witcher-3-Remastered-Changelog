/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DestroyableClue extends W3MonsterClue
{
	editable var destroyable : bool;

	editable var reactsToAard : bool;
	editable var reactsToIgni : bool;
	editable var reactsToSwords : bool;
	editable var reactsToBolts : bool;
	editable var reactsToBombs : bool;
	


	editable var defaultEffect : name;
	
	editable var effectOnReaction : name;
	editable var effectOnBurning  : name;
	editable var effectInstant : bool;
	
	editable var reactionDelay : float;
	
	editable var onDestroyedFact : array<string>;
	
	editable var performDestructionSystemCheck : bool;
	private saved var isBurning				   : bool;
	
	saved var destroyed : bool;

	default destroyable = true;
	default performDestructionSystemCheck = true;
	
	hint destroyable = "Should the entity's destruction be handled (don't set to false if you're using CDestructionSystemComponents)";
	
	hint reactsToAard = "Entity processes destruction when hit by Aard";
	hint reactsToIgni = "Entity processes destruction when hit by Igni";
	hint reactsToSwords = "Entity processes destruction when hit by Swords";
	hint reactsToBolts = "Entity processes destruction when hit by Aard";
	hint reactsToBombs = "Entity processes destruction when hit by Fire/Ice effect dealing Bombs";
	
	hint defaultEffect = "Effect to be played on spawn";
	hint effectOnReaction = "Effect to be played when hit";
	hint effectInstant = "Effect should be played instantly when hit";
	hint reactionDelay = "How long should we wait before processing destruction";
	hint onDestroyedFact = "Fact to be added after destruction has been completed";
	hint performDestructionSystemCheck = "Should the entity check for actual destruction system components being destroyed if any are found";

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if(destroyed)
		{
			ApplyAppearance( 'destroyed' );
			SetAutoEffect( '' );
		}
		else
		{
			ApplyAppearance( 'intact' );
			SetAutoEffect( defaultEffect );
			if (reactsToBombs)
			{
				 this.AddTag('TargetableByBomb');
			}
		}
		super.OnSpawned( spawnData );
	}

	event OnAardHit( sign : W3AardProjectile )
	{
		if( reactsToAard && !destroyed && destroyable )
		{
			ProcessDestruction();
		}
		super.OnAardHit( sign );		
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		if(reactsToIgni && !destroyed && destroyable )
		{
			PlayEffectSingle( effectOnBurning );
			isBurning = true;
			ProcessDestruction();
		}
		super.OnIgniHit( sign );			
	}
	
	event OnWeaponHit(act : W3DamageAction)
	{
		if (( reactsToSwords || reactsToBolts )&& !destroyed && destroyable )
		{
			if( !GetAreFistsEquipped() )
			{
				
				if (!act.IsActionWitcherSign()) 
				{
					if ( reactsToSwords && act.IsActionMelee())
					{
						isBurning = false;
						ProcessDestruction();
					}
					else if ( reactsToBolts && act.IsActionRanged())
					{
						isBurning = false;
						ProcessDestruction();
					}
				}
			}
		}
		super.OnWeaponHit(act);
	}
	
	
	event OnFireHit(entity : CGameplayEntity)
	{
		ProcessBombDestruction(entity);
	}
	
	event OnFrostHit(entity : CGameplayEntity)
	{
		isBurning = false;
		ProcessBombDestruction(entity);
	}
	
	private function ProcessBombDestruction(entity: CGameplayEntity)
	{
		if((W3Petard)entity && reactsToBombs && !destroyed && destroyable)
		{
				PlayEffectSingle( effectOnBurning );
				isBurning = false;
				ProcessDestruction();
		}
	}
	
	public function GetFocusActionName() : name
	{
		var focusComponent : CFocusActionComponent;
		focusComponent = (CFocusActionComponent)GetComponentByClassName( 'CFocusActionComponent' );
		if ( focusComponent )
		{
			return focusComponent.actionName;		
		}
		return '';
	}	
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return true;
	}
	
	private function ProcessDestructionWrapper()
	{
		RemoveTimer('ProcessDestructionTimer');
		if( reactionDelay > 0.0 )
		{
			AddTimer( 'DelayedDestruction', reactionDelay, false, , , true );
		}
		else
		{
			ExecuteDestruction();
		}
		
		if(effectInstant)
		{			
			PlayEffectSingle( effectOnReaction );			
		}
	}
	
	timer function ProcessDestructionTimer( deltaTime : float , id : int )
	{
		if( DestructionSystemCheck() )
		{
			ProcessDestructionWrapper();
		}
	}
	
	public function ProcessDestruction()
	{
		if( !performDestructionSystemCheck )
		{
			ProcessDestructionWrapper();
		}
		else
		{
			AddTimer( 'ProcessDestructionTimer', 0.1f, true, , , true );
		}
		
	}
	
	public function SetDestroyable( isDestroyable : bool)
	{
		destroyable = isDestroyable;
	}
	
	function ExecuteDestruction()
	{
		var i : int;
		
		ApplyAppearance( 'destroyed' );			
		SetAutoEffect( '' );
		DestroyEffect(effectOnBurning);
		if(!effectInstant)
		{
			PlayEffectSingle( effectOnReaction );
		}		
		
		SetAvailable( false );
		
		for( i=0; i < onDestroyedFact.Size(); i+=1 )
		{
			FactsAdd( onDestroyedFact[i], 1 );
		}
		
		destroyed = true;	
	}
	
	timer function DelayedDestruction(dt : float, id : int)
	{
		ExecuteDestruction();
	}

	function GetAreFistsEquipped() : bool
	{
		var i : int;
		var fistsIds : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		
		inv = thePlayer.inv;
		fistsIds = inv.GetItemsByCategory('fist');
		
		for(i=0; i < fistsIds.Size(); i+=1)
		{
			if( inv.IsItemHeld(fistsIds[i]))
				return true;
		}
		
		return false;
	}
	
	
	private function DestructionSystemCheck() : bool
	{
		var components : array<CComponent>;
		var component : CDestructionSystemComponent;
		var i: int;
		var destroyed : bool;
		
		components = this.GetComponentsByClassName( 'CDestructionSystemComponent' );
		
		if(components.Size() == 0 )
		{
			return true;
		}
		
		destroyed = true;
		
		for( i=0; i < components.Size(); i += 1)
		{
			component = (CDestructionSystemComponent) components[i];
			
			if( component )
			{
				if ( !isBurning || (isBurning && effectOnBurning == '') )
				{
					component.ApplyFracture();
				}
				
				if( component.IsDestroyed() == false )
				{
					destroyed = false;
				}
				
			}
		}
		
		return destroyed;
	}

}