/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CLightEntitySimple extends CScheduledUsableEntity
{
	private var isOn : bool;

	function Activate( flag : bool )
	{
		if( flag )
		{	
			TurnLightOn();
		}
		else
		{
			TurnLightOff();
		}
		
		super.Activate( flag );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		PlayEffect('aard');
		TurnLightOff();
		super.OnAardHit( sign );
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		PlayEffect('igni');
		TurnLightOn();
		super.OnIgniHit( sign );
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
		TurnLightOn();
	}
	
	event OnFrostHit(source : CGameplayEntity)
	{
		super.OnFrostHit(source);
		
		TurnLightOff();
	}
	
	
	protected function TurnLightOn()
	{
		var comp : CComponent;
		
		if(isOn)
		{
			return;
		}
		
		
		StopEffect('smoke');
		
		
		AddTag(theGame.params.TAG_OPEN_FIRE);
		
		comp = GetComponentByClassName('CLightComponent');
		if(comp)
		{
			comp.SetEnabled(true);
			PlayEffect( 'fire' );
		}
			
		isOn = true;
 	}
	
	protected function TurnLightOff()
	{
		var comp : CComponent;
		
		if(!isOn)
			return;
	
		StopEffect( 'fire' );
		
		RemoveTag(theGame.params.TAG_OPEN_FIRE);
		
		comp = GetComponentByClassName('CLightComponent');
		if(comp)
			comp.SetEnabled(false);
			
		PlayEffect('smoke');
		AddTimer('StopSmoke', 15);
			
		isOn = false;
	}
	
	timer function StopSmoke(dt : float, id : int)
	{
		StopEffect('smoke');
	}
	
	public function IsOn() : bool
	{
		return isOn;
	}
}

class CLightEntitySimpleWithEffectImmunity extends CLightEntitySimple
{
	editable var effectImmunity : EEffectType;
	editable var duration : float;							default duration = 60.0;
	private var areaComponent : CTriggerAreaComponent;

	private function TurnLightOn()
	{
		super.TurnLightOn();
		
		if( duration != -1 )
			AddTimer( 'TurnLightOffAfter', duration );
		
		areaComponent = (CTriggerAreaComponent)GetComponentByClassName( 'CTriggerAreaComponent' );
		if( areaComponent.TestEntityOverlap( thePlayer ) )
		{
			ApplyEffects( thePlayer );
		}
 	}
 	
 	private timer function TurnLightOffAfter( td : float, id : int )
 	{
		if( IsOn() )
			TurnLightOff();
 	}
 	
 	private function TurnLightOff()
	{
		super.TurnLightOff();
		RemoveEffects( thePlayer );
 	}
 	
 	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		if( IsOn() )
		{
			actor = (CActor)activator.GetEntity();
			ApplyEffects( actor );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var actor : CActor;
		
		actor = (CActor)activator.GetEntity();
		RemoveEffects( actor );
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if( !IsOn() )
			TurnLightOn();
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		if( !IsOn() )
			return true;
		return false;
	}
	
	private function ApplyEffects( target : CActor )
	{
		target.AddBuffImmunity( effectImmunity, 'CLightEntitySimpleWithEffectImmunity', true );
		target.AddAbility( 'BoostedVitalityRegen', false );
	}
	
	private function RemoveEffects( target : CActor )
	{
		target.RemoveBuffImmunity( effectImmunity, 'CLightEntitySimpleWithEffectImmunity' );
		target.RemoveAbility( 'BoostedVitalityRegen' );
	}
}