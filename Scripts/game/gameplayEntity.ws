/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class IPerformableAction extends CObject
{
	import final function Trigger( parnt : CEntity );
	import final function TriggerArgNode( parnt : CEntity, node : CNode );
	import final function TriggerArgFloat( parnt : CEntity, value : float );
}

function TriggerPerformableEvent( actionList : array< IPerformableAction >, parnt : CEntity )
{
	var i : int;
	var size : int = actionList.Size();
	
	for( i = 0; i < size; i += 1 )
	{
		actionList[ i ].Trigger( parnt );
	}
}

function TriggerPerformableEventArgNode( actionList : array< IPerformableAction >, parnt : CEntity, node : CNode )
{
	var i : int;
	var size : int = actionList.Size();
	
	for( i = 0; i < size; i += 1 )
	{
		actionList[ i ].TriggerArgNode( parnt, node );
	}
}

import class CScriptedAction extends IPerformableAction
{
	function Perform( parnt : CEntity )
	{
		LogAssert( false, "CScriptedAction::Perform() not implemented" );
	}

	function PerformArgNode( parnt : CEntity, node : CNode )
	{
		Perform( parnt );
	}

	function PerformArgFloat( parnt : CEntity, value : float )
	{
		Perform( parnt );
	}
}

import class CGameplayEntityParam extends CEntityTemplateParam
{

};

import class CBloodTrailEffect extends CGameplayEntityParam
{
	import final function GetEffectName() : name;
};

import class CGameplayEntity extends CPeristentEntity
{
	editable var minLootParamNumber			: int;					default minLootParamNumber = -1; 
	editable var maxLootParamNumber			: int;					default maxLootParamNumber = -1; 

	import final function GetInventory() : CInventoryComponent;
	import public final function GetCharacterStats() : CCharacterStats;
	public final function GetAllAttributes() : array<name>
	{
		var atts : array<name>;
		GetCharacterStats().GetAllAttributesNames(atts);
		return atts;
	}
	
	
	event OnSpawnedEditor( spawnData : SEntitySpawnData ){}

	
	import final function GetDisplayName( optional fallBack : bool  ) : string;
	
	
	import final function PlayPropertyAnimation( animationName : name, optional count : int, optional lengthScale : float, optional mode : EPropertyCurveMode );
	
	import final function StopPropertyAnimation( animationName : name, optional restoreInitialValues : bool );
	
	import final function RewindPropertyAnimation( animationName : name, time : float );
	
	import final function GetPropertyAnimationInstanceTime( propertyName : name, animationName : name ) : float;
	
	import final function GetPropertyAnimationLength( propertyName : name, animationName : name ) : float;
	
	import final function GetPropertyAnimationTransformAt( propertyName : name, animationName : name, time : float ) : Matrix;

	import final function GetGameplayEntityParam( className : name ) : CGameplayEntityParam;

	
	import final function AddAnimEventCallback( eventName : name, functionName : name );
	
	import final function RemoveAnimEventCallback( eventName : name );
	
	import final function AddAnimEventChildCallback( child : CNode, eventName : name, functionName : name );
	
	import final function RemoveAnimEventChildCallback( child : CNode, eventName : name );
	
	
	import final function GetSfxTag() : CName;

	
	import function GetStorageBounds( out box : Box );
	
	
	
	
	
	
	
	
	
	
	
	import final function GetGameplayInfoCache( type : EGameplayInfoCacheType ) : bool;

	
	import final function GetFocusModeVisibility() : EFocusModeVisibility;
	
	
	
	
	import final function SetFocusModeVisibility( focusModeVisibility : EFocusModeVisibility, optional persistent : bool, optional force : bool );

	
	
	
	import final function EnableVisualDebug( flag : EShowFlags, enable : bool );
	
	import var aimVector : Vector;
	editable var iconOffset	: Vector;
	
	public	var highlighted			: bool;					
	
	public var focusModeSoundEffectType : EFocusModeSoundEffectType;
	default focusModeSoundEffectType = FMSET_None;
	var isPlayingFocusSound			: bool;
	default isPlayingFocusSound		= false;

	var isColorBlindMode			: bool;
	default isColorBlindMode		= false;
	
	
	
	
	
	var	focusSoundVisualEffectBoneName	: name;
	default focusSoundVisualEffectBoneName = '';

	editable var isHighlightedByMedallion : bool;
	editable var isMagicalObject 			: bool;
	hint isHighlightedByMedallion = "Highlight entity when it is scanned by Player's medallion";
	
	default isHighlightedByMedallion = true;
	default isMagicalObject = false;
	
	
	editable var soundEntityName : string;
	editable var soundEntityGender : string;
	editable var soundEntitySet : string;
	
	
	
	
	event OnGameplayPropertyChanged( propertyName : name ){}
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		isPlayingFocusSound = false;
		if ( soundEntityName )
			SoundSwitch("entity_name",soundEntityName);
		if ( soundEntityGender )
			SoundSwitch("entity_gender",soundEntityGender);
		if ( soundEntitySet )
			SoundSwitch("entity_sound_set",soundEntitySet);
	} 
	
	
	event OnDestroyed()
	{
	}
	
	
	event OnPlayerActionEnd()
	{
	}
	
	
	event OnPlayerActionStartFinished()
	{
	}
	
	
	event OnSyncAnimEnd()
	{
	}

	
	event OnPreAttackEvent( animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{
	}	

	
	
	
	
	public function IsAlive() : bool 																	{return true;}	
	public function HasAbility(abilityName : name, optional includeInventoryAbl : bool) : bool			{return GetCharacterStats().HasAbility(abilityName, includeInventoryAbl);}
	public function AddAbility(abilityName : name, optional allowMultiple : bool) : bool				{return GetCharacterStats().AddAbility(abilityName,allowMultiple);}	
	public function RemoveAbility(abilityName : name)													{GetCharacterStats().RemoveAbility(abilityName);}
	public function AddAbilityMultiple(abilityName : name, count : int)									{GetCharacterStats().AddAbilityMultiple(abilityName, count);}
	public function RemoveAbilityMultiple(abilityName : name, count : int)								{GetCharacterStats().RemoveAbilityMultiple(abilityName, count);}
	public function RemoveAbilityAll(abilityName : name)												{GetCharacterStats().RemoveAbilityAll(abilityName);}
	public function GetAbilityCount(abilityName : name) : int											{return GetCharacterStats().GetAbilityCount(abilityName);}

	
	
	
	
	public function AddTag(tag : name)
	{
		var i : int;
		var ents : array<CGameplayEntity>;
		var area : CTriggerAreaComponent;
		var toxic : W3ToxicCloud;
		
		super.AddTag(tag);
		
		
		if(tag == theGame.params.TAG_OPEN_FIRE)
		{
			FindGameplayEntitiesInSphere(ents, GetWorldPosition(), 20, 100000, theGame.params.TAG_EXPLODING_GAS);
			for(i=0; i<ents.Size(); i+=1)
			{
				toxic = (W3ToxicCloud)ents[i];
				if(toxic)
				{
					area = toxic.GetGasAreaUnsafe();
					if(area && area.TestEntityOverlap(this))
						ents[i].OnFireHit(this);
				}
			}
		}
	}
		
	timer function MedallionEffectOff( deltaTime : float , id : int)
	{
		SetHighlighted( false );
		StopEffect( 'medalion_detection_fx' );
	}
	
	timer function EnemyHighlightOff(dt : float, id : int)
	{
		var catComponent : CGameplayEffectsComponent;
		
		catComponent = GetGameplayEffectsComponent(this);
		if(catComponent)
		{
			catComponent.ResetGameplayEffectFlag(EGEF_CatViewHiglight);
		}
	}
	
	timer function SonarEffectOff( deltaTime : float , id : int)
	{
		StopEffect( 'fx_sonar_detection' );
	}
	
	function FocusEffectOff()
	{
		StopEffect( 'focus_activation_fx' );
	}
	
	private var cutsceneForbiddenFXs: array<name>;
	
	public function AddCutsceneForbiddenFX( fx : name )
	{
		if( !cutsceneForbiddenFXs.Contains( fx ) )
		{
			cutsceneForbiddenFXs.PushBack( fx );
		}
	}
	public function StopCutsceneForbiddenFXs()
	{
		var i : int;
		for ( i = 0; i < cutsceneForbiddenFXs.Size() ; i += 1 )
		{
			StopEffectIfActive( cutsceneForbiddenFXs[i] );
		}
	}
	
	public function SetHighlighted( b : bool )
	{
		highlighted = b;
	}
	
	public function IsHighlighted() : bool
	{
		return highlighted;
	}
	
	public function ShouldBlockGameplayActionsOnInteraction() : bool
	{
		return false;
	}
	
	
	
	
	
	event OnItemGiven(data : SItemChangedData){}
	
	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int){}
	
	
	
	
	function SenseMagic()
	{
		if ( thePlayer.PlayerCanComment() )
		{
			GetComponent("Medallion").SetEnabled( true );
			thePlayer.PlayerCommentary( PC_MedalionWarning );
		}
		GetWitcherPlayer().GetMedallion().Activate( true, 5.0f );
	}
	
	function AddSignHitFacts( sign : W3SignProjectile, signType : string )
	{
		AddHitFacts( GetTags(), sign.caster.GetTags(), signType );
	}
	
	event OnWeaponHit (act : W3DamageAction)
	{
	}
	
	event OnBoltHit()
	{
	
	}
		
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var i : int;
		var doors : array<CComponent>;
		var R4Components : array < CComponent >;
		var gameLightComp : CGameplayLightComponent;
		
		AddSignHitFacts( sign, "_aard_hit" );
		
		
		doors = GetComponentsByClassName('CDoorComponent');
		for(i=0; i<doors.Size(); i+=1)
		{
			((CDoorComponent)doors[i]).AddForceImpulse( sign.caster.GetWorldPosition(), 3000.0f );
		}
		
		R4Components = GetComponentsByClassName('CR4Component');
		for(i=0; i< R4Components.Size(); i+=1)
		{
			((CR4Component) R4Components[i]).OnAardHit();
		}
		
		if ( HasEffect('aardReaction') && !IsEffectActive('aardReaction') )
		{
			PlayEffect('aardReaction');
		}

		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		if(gameLightComp)
		{
			gameLightComp.AardHit();
		}
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		var i : int;
		var gameLightComp : CComponent;
		var R4Components : array < CComponent >;
		
		AddSignHitFacts( sign, "_igni_hit" );

		
		gameLightComp = GetComponentByClassName('CGameplayLightComponent');
		if(gameLightComp)
		{
			((CGameplayLightComponent)gameLightComp).IgniHit();
		}
		
		R4Components = GetComponentsByClassName('CR4Component');
		for(i=0; i < R4Components.Size(); i+=1)
		{
			((CR4Component) R4Components[i]).OnIgniHit();
		}
	
		OnFireHit(sign);
	}
	
	event OnAxiiHit( sign : W3AxiiProjectile )
	{
		AddSignHitFacts( sign, "_axii_hit" );
	}
	
	event OnFrostHit(source : CGameplayEntity)
	{
		var gameLightComp 	: CGameplayLightComponent;
		var fireAuraCmp		: W3FireAuraManagerComponent;
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');

		if(gameLightComp)
		{
			gameLightComp.FrostHit();
		}
		
		fireAuraCmp = (W3FireAuraManagerComponent) GetComponentByClassName('W3FireAuraManagerComponent');
		if( fireAuraCmp )
		{
			fireAuraCmp.DeactivateAura();
		}
	}
	
	
	event OnFireHit(source : CGameplayEntity)
	{
		var w3FoodComponents : array<CComponent>;
		var i : int;
		var actor : CActor;
		var gameLightComp : CGameplayLightComponent;
		
		
		actor = (CActor)this;
		if(!actor || !actor.IsAlive())
		{
			w3FoodComponents = GetComponentsByClassName('W3FoodComponent');
			for (i=0; i<w3FoodComponents.Size(); i+=1)
			{
				((W3FoodComponent)w3FoodComponents[i]).OnFireHit();
			}
		}
		
		gameLightComp = (CGameplayLightComponent)GetComponentByClassName('CGameplayLightComponent');
		if(gameLightComp)
		{
			gameLightComp.FireHit();
		}
	}	
	
	event OnYrdenHit( caster : CGameplayEntity )
	{
		
		AddHitFacts( GetTags(), caster.GetTags(), "_yrden_hit" );
	}
	
	
	event OnRootHit()
	{
		var i : int;
		var tags : array<name>;
		
		
		tags = GetTags();
		for(i=0; i<tags.Size(); i+=1)
			FactsAdd( NameToString(tags[i])+"_roots_hit", 1, 1 );		
	}
		
	event OnDamageFromJump( activator : CComponent, jumpDistance : float, jumpHeightDiff : float )
	{
		WhenFallen(jumpHeightDiff);
	}	
	event OnDamageFromFalling( activator : CComponent, fallingDistance : float, fallingHeightDiff : float )
	{
		WhenFallen(fallingHeightDiff);
	}
	
	protected function WhenFallen(fallingHeightDiff : float)
	{
		var vehicleComp : CVehicleComponent;
		var gpEnt : CGameplayEntity;
	
		if(-fallingHeightDiff > 0)
		{
			if(this == thePlayer || GetAttitudeBetween(thePlayer, this) == AIA_Hostile)
			{
				ApplyFallingDamage(-fallingHeightDiff);
			}			
		}
		
		if(IsVehicle())
		{
			vehicleComp = (CVehicleComponent)GetComponentByClassName('CVehicleComponent');
			gpEnt = (CGameplayEntity)vehicleComp.user;
			if(gpEnt)
			{
				gpEnt.WhenFallen(fallingHeightDiff);
					
				if( ((CNewNPC)this).IsHorse() && !gpEnt.IsAlive() )
				{
					((CNewNPC)this).GetHorseComponent().OnKillHorse();
				}
			}
		}
	}
	
	public function IsVehicle() : bool
	{
		return GetComponentByClassName('CVehicleComponent');
	}
	
	function ApplyFallingDamage( heightDiff : float, optional reducing : bool ) : float
	{
		return 0;
	}
	
	
	
	
	
	function GetFocusModeSoundEffectName( colorBlindMode : bool ) : name
	{	
		if ( focusModeSoundEffectType == FMSET_Gray )
		{
			return 'focus_sound_fx';
		}
		else if ( focusModeSoundEffectType == FMSET_Red )
		{
			if( colorBlindMode ) return 'focus_sound_red_alt_fx';
			else
				return 'focus_sound_red_fx';
		}
		else if ( focusModeSoundEffectType == FMSET_Green )
		{
			return 'focus_sound_green_fx';
		}		
		return '';
	}
	
	function PlayFocusSoundVisualEffect( effectName : name )
	{
		var focusSoundParam : CFocusSoundParam;
		if ( focusSoundVisualEffectBoneName == '' ) 
		{
			focusSoundParam = (CFocusSoundParam)GetGameplayEntityParam( 'CFocusSoundParam' );
			if ( focusSoundParam )
			{
				focusSoundVisualEffectBoneName = focusSoundParam.GetVisualEffectBoneName();
			}
			if ( focusSoundVisualEffectBoneName == '' ) 
			{
				focusSoundVisualEffectBoneName = 'entity';
			}
		}
		if ( focusSoundVisualEffectBoneName != 'entity' )
		{
			PlayEffectOnBone( effectName, focusSoundVisualEffectBoneName );
		}
		else
		{
			PlayEffect( effectName );		
		}
	}
	
	public function SetFocusModeSoundEffectType( type : EFocusModeSoundEffectType )
	{
		if ( focusModeSoundEffectType == type )
		{
			return;
		}
		
		if ( isPlayingFocusSound )
		{
			StopEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );
		}

		focusModeSoundEffectType = type;

		if ( isPlayingFocusSound && type != FMSET_None )
		{
			PlayFocusSoundVisualEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );			
		}
	}
	
	event OnFocusModeSound( enabled : bool, colorBlind : bool )
	{
		
		isColorBlindMode = colorBlind;

		if ( !IsAlive() )
		{
			enabled = false;
		}
		
		if ( enabled == isPlayingFocusSound )
		{
			return false;
		}
		isPlayingFocusSound = enabled;

		if ( isPlayingFocusSound )
		{
			PlayFocusSoundVisualEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );
		}
		else
		{
			StopEffect( GetFocusModeSoundEffectName( isColorBlindMode ) );
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
	
	public function GetInteractionData( out actionName : name, out text : string ) : bool
	{
		
		
		return false;
	}
}	


import class IEntityStateChangeRequest extends CObject
{
};

import abstract class CScriptedEntityStateChangeRequest extends IEntityStateChangeRequest
{
	function Execute( entity : CGameplayEntity );
};

import class CEnableDeniedAreaRequest extends IEntityStateChangeRequest
{
	import var enable	: bool;
};



import class CPlaySoundOnActorRequest extends IEntityStateChangeRequest
{
	import function Initialize( boneName : name, soundName : string, optional fadeTime : float );
};