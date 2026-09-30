/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CDamageAreaEntity extends CInteractiveEntity
{
	editable var owner: CActor;
	editable var buff : EEffectType;
	editable var buffDuration : float;
	editable var customDamageValuePerSec : SAbilityAttributeValue;
	editable var effectOnSpawn : name;
	editable var activeFor : float;
	editable var stopSpawnEffectDelay : float;
	editable var dealDamagePerc : int;
	editable var range	: float;
	default dealDamagePerc = 0;
	
	private var isActive : bool;
	private var actorsInRange : array<CActor>;
	private var buffParams : SCustomEffectParams;
	
	private autobind interaction 	: CInteractionComponent = single;
	
	default buffDuration = 0.2f;
	default stopSpawnEffectDelay = -1;
	
	hint range = "range to use if there is NO interaction component";
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var components : array<CComponent>;
		var comp : CComponent;
		var i : int;
		var zDiff : float;
		var newPosition : Vector;
		var area : CDamageAreaEntity;
		
		super.OnSpawned( spawnData );
		
		components = this.GetComponentsByClassName('CEffectDummyComponent');
		
		for ( i=0 ; i < components.Size() ; i += 1 )
		{
			comp = components[i];
			
			if( !comp )
			{
				continue;
			}
			
			if ( doTrace ( comp, zDiff) )
			{
				newPosition = comp.GetLocalPosition();
				newPosition.Z += zDiff;
				comp.SetPosition( newPosition );
			}
			else
			{
				comp.SetEnabled(false);
			}
		}
		
		this.PlayEffect(effectOnSpawn);
		isActive = true;
		if ( activeFor > 0 )
		{
			AddTimer('TurnOff',activeFor, false, , , true );
		}
		
		if( stopSpawnEffectDelay > 0 )
		{
			AddTimer( 'StopSpawnEffect', stopSpawnEffectDelay, false, , , true );
		}
		
		
		AddTimer('ProcessArea', 0.01, true);
		
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		var victim : CActor;
		
		victim = (CActor)activator;
		
		if ( victim && victim != owner && !actorsInRange.Contains(victim) )
			actorsInRange.PushBack(victim);
			
		if(actorsInRange.Size() == 1)
			AddTimer('ProcessArea', 0.01, true);
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		var victim : CActor;
		victim = (CActor)activator;
		
		if ( victim && victim != owner)
			actorsInRange.Remove(victim);
		
		if(actorsInRange.Size() == 0)
			RemoveTimer('ProcessArea');
	}
	
	timer function ProcessArea( dt : float, id : int)
	{
		var i : int;
		var actor : CActor;
		var action : W3DamageAction;
		
		if ( !isActive )
			return;
		
		if( interaction )
		{
			range = interaction.GetRangeMax();			
		}
		
		actorsInRange = GetActorsInRange( this, range, -1, , true);
		
		
		if(buffParams.effectType == EET_Undefined)
		{
			buffParams.effectType = buff;
			buffParams.creator = this;
			buffParams.sourceName = 'none';
			buffParams.duration = buffDuration;
			buffParams.effectValue = customDamageValuePerSec;
		}
		
		for(i = actorsInRange.Size() - 1; i>=0; i-=1)
		{
			actor = actorsInRange[i];
			
			actor.AddEffectCustom(buffParams);
					
			if ( dealDamagePerc > 0 )
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize(NULL, actor, NULL, 'console', EHRT_Light, CPS_Undefined, false, false, false, false);
				action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, (actor.GetStatMax( BCS_Vitality )* dealDamagePerc )/100);
				action.SetHitAnimationPlayType(EAHA_Default);
				action.SetSuppressHitSounds(true);
				theGame.damageMgr.ProcessAction(action);
				delete action;
			}
			
		}
	}
	
	timer function TurnOff( dt : float, id : int)
	{
		this.isActive = false;
		this.StopAllEffects();
		this.DestroyAfter(3.0);
	}
	
	timer function StopSpawnEffect( dt : float, id : int)
	{
		this.StopEffect(effectOnSpawn);
	}
	
	private final function doTrace( comp: CComponent, out outZdiff : float ) : bool
	{
		var currPosition,outPosition, outNormal, tempPosition1, tempPosition2 : Vector;
		
		currPosition = comp.GetWorldPosition();
		
		tempPosition1 = currPosition;
		tempPosition1.Z -= 1;
		
		tempPosition2 = currPosition;
		tempPosition2.Z += 1;
		
		if ( theGame.GetWorld().StaticTrace( tempPosition2, tempPosition1, outPosition, outNormal ) )
		{
			outZdiff = outPosition.Z - currPosition.Z;
			return true;
		}
		
		return false;
	}
}