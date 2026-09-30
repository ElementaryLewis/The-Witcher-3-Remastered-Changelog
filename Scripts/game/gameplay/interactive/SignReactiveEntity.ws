/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CSignReactiveEntity extends W3MonsterClue
{
	editable var factOnSignCast 			: string;
	editable saved  var igni 				: bool;
	editable saved  var aard 				: bool;
	editable var clueActionWhenDestroyed	: EClueOperation; default clueActionWhenDestroyed = CO_None;
	editable var igniteOnInteraction		: bool; default igniteOnInteraction = false;
	
	editable var destroyingTimeout			: float; default destroyingTimeout = 5;
	editable var destroyedEffectsTimeout	: float; default destroyedEffectsTimeout = 10;
	
	editable var destroyingEffectName		: name; default destroyingEffectName = 'destroy';
	editable var destroyedEffectName		: name; default destroyedEffectName = 'destroyed';
	
	private var isDestroyed					: bool;
	private var clueActionArray				: array <EClueOperation>;
	
	private var currentAppearance 			: string;   default currentAppearance = "default";
	
	private var interactionComponents		: array <CComponent>;
	private var i							: int;
	
	public function IsDestroyed() : bool
	{
		return isDestroyed;
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		ApplyAppearance( currentAppearance );
		super.OnSpawned( spawnData );
		Init();
	}
	event OnIgniHit( sign : W3IgniProjectile )
	{
		if ( igni && !isDestroyed  )
		{
			HitByFire();
			super.OnIgniHit(sign);
		}	
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if ( aard && !isDestroyed )
		{
			StartDestroyed(true);
			currentAppearance = "destroyed";
			PlayEffect(destroyingEffectName, this );
			AddTimer ( 'ApplyDestroyAppearance', destroyingTimeout, , , , true );
			super.OnAardHit(sign);
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if ( !igni )
		{
			return false;
		}
	}
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator == thePlayer && actionName == "Ignite" )
		{
			if(!thePlayer.CanPerformPlayerAction())
				return false;
			
			if(!isDestroyed)
			{
				thePlayer.PlayerStartAction( PEA_IgniLight );
				HitByFire();
			}		
		}
		else
		{
			super.OnInteraction(actionName,activator);
		}
	}
	
	public function EnableSignReactivness ( enable : bool )
	{
		 igni = enable;
		 aard = enable;
	}
	private function Init()
	{
		
	}
	
	private function HitByFire()
	{	
		interactionComponents = this.GetComponentsByClassName('CInteractionComponent');
		if (interactionComponents.Size()>0)
		{
			for (i = 0; i < interactionComponents.Size(); i += 1)
			{
				interactionComponents[i].SetEnabled(false);
			}
		}
		if ( factOnSignCast != "" )
		{
			FactsAdd( factOnSignCast, 1, -1 );
		}
		StartDestroyed(true);
		currentAppearance = "destroyed";
		PlayEffect(destroyingEffectName);
		AddTimer ( 'ApplyDestroyAppearance', destroyingTimeout, , , , true );
	}
	
	private timer function StopDestroyedEffect ( timeDelta : float , id : int)
	{
		StopEffect ( destroyedEffectName );
	}
	
	private timer function ApplyDestroyAppearance ( timeDelta : float , id : int)
	{
		ApplyAppearance( currentAppearance );
		PlayEffect(destroyedEffectName);
		StopEffect ( destroyingEffectName );
		AddTimer ( 'StopDestroyedEffect', destroyedEffectsTimeout, , , , true );
		SetDestroyed(true);
	}
	
	event OnClueDetected()
	{
		if (igniteOnInteraction) this.GetComponent("Burn").SetEnabled(true);
		super.OnClueDetected();
	}
	
	private function StartDestroyed(destroyed : bool)
	{
		isDestroyed = destroyed;
		clueActionArray.Clear();
		clueActionArray.PushBack(CO_Disable);
		this.OnManageClue(clueActionArray);
	}
	
	private function SetDestroyed(destroyed : bool)
	{
		clueActionArray.Clear();
		clueActionArray.PushBack(clueActionWhenDestroyed);
		this.OnManageClue(clueActionArray);
	}
	
	
	
	
}