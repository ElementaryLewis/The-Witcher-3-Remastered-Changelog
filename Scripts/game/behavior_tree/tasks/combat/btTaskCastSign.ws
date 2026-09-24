/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskCastSign extends CBTTaskAttack
{
	protected var resourceName 		: name;
	
	protected var entityTemplate 	: CEntityTemplate;
	protected var signEntity 		: W3SignEntity;
	protected var action 			: W3DamageAction;
	protected var signType 			: ESignType;
	
	protected var attackRangeName	: name;
	
	private	  var signOwner			: W3SignOwnerBTTaskCastSign;
	
	
	default signType = ST_None;
	
	function IsAvailable() : bool
	{
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{
		
		signOwner = new W3SignOwnerBTTaskCastSign in this;
		signOwner.Init( GetActor(), this );
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);	
		if ( entityTemplate )
		{
			signEntity = (W3SignEntity)theGame.CreateEntity( entityTemplate, GetActor().GetWorldPosition(), GetActor().GetWorldRotation() );
			LogAssert( signEntity, "Sign entity in CBTTaskCastSign is not a W3SignEntity type" );
		}
		
		SetupSignType();		
		GetActor().SetBehaviorVariable( 'signType',(int)signType);

		
		if ( signEntity )
		{
			signEntity.Init( signOwner, NULL );
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		Ended();
		delete signOwner;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( signEntity )
		{
			signEntity.OnProcessSignEvent( animEventName );
		}
		if ( animEventName == 'cast_begin')
		{
			Started();
		}
		else if ( animEventName == 'cast_throw')
		{
			Throw();
		}
		else if ( animEventName == 'cast_end')
		{
			Ended();
		}
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
	
	function Started()
	{
	}
	
	function Throw()
	{
	}
	
	function Ended()
	{
		signEntity.StopAllEffects();
		signEntity.OnEnded();
		signEntity = NULL;
	}
	
	function SetupSignType()
	{
		if ( (W3SignEntity)signEntity )
		{
			signType = ( (W3SignEntity)signEntity ).GetSignType();
		}
		else
		{
			LogAssert( false, "Sign entity not found or SetupSignType not specialized in CBTTaskCastSign" );
			signType = ST_None;
		}
	}
	
	public function GetAttackRangeType() : name
	{		
		return attackRangeName;
	}
};

abstract class CBTTaskCastSignDef extends CBTTaskPlayAnimationEventDecoratorDef
{
};




class CBTTaskCastAard extends CBTTaskCastSign
{
	function IsAvailable() : bool
	{
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{	
		if ( !IsNameValid(attackRangeName) )
			attackRangeName = 'cone';
			
		if ( !IsNameValid(resourceName) )
			resourceName = 'aard';
			
		
		if ( GetNPC().HasTag('mq1060_witcher') )
			resourceName = 'aard_mq1060';
		
		return super.OnActivate();
	}		
};

class CBTTaskCastAardDef extends CBTTaskCastSignDef
{	
	default instanceClass = 'CBTTaskCastAard';
};




class CBTTaskCastIgni extends CBTTaskCastSign
{
	function IsAvailable() : bool
	{
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{
		if ( !IsNameValid(attackRangeName) )
			attackRangeName = 'cone';
			
		if ( !IsNameValid(resourceName) )
			resourceName = 'igni';
			
		
		if ( GetNPC().HasTag('mq1060_witcher') )
			resourceName = 'igni_mq1060';
		
		return super.OnActivate();
	}	
};

class CBTTaskCastIgniDef extends CBTTaskCastSignDef
{
	default instanceClass = 'CBTTaskCastIgni';
};




class CBTTaskCastQuen extends CBTTaskCastSign
{
	public var completeAfterHit 				: bool;
	public var alternateFireMode 				: bool;
	public var processQuenOnCounterActivation 	: bool;
	public var hitEventReceived					: bool;
	private var hitEntity 						: CEntity;
	private var hitEntityTemplate				: CEntityTemplate;
	private var ownerBoneIndex 					: int;
	private var shieldActive					: bool;
	
	protected var humanCombatDataStorage : CHumanAICombatStorage;
	
	default ownerBoneIndex = -1;
	
	function IsAvailable() : bool
	{
		return true;
	}

	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if( !IsNameValid(attackRangeName) )
			attackRangeName = 'quen';
		if( !IsNameValid(resourceName) )
			resourceName = 'quen';
			
		
		if ( GetNPC().HasTag('mq1060_witcher') )
			resourceName = 'quen_mq1060';
		
		npc.SetGuarded(true);
		npc.SetParryEnabled( true );
		npc.customHits = true;
		npc.SetCanPlayHitAnim( true );
		
		npc.AddBuffImmunity( EET_Swarm, 'TaskCastQuen', false );
		npc.AddBuffImmunity( EET_Burning, 'TaskCastQuen', false );
		
		if( ownerBoneIndex == -1 )
			ownerBoneIndex = npc.GetBoneIndex( 'pelvis' );
		
		npc.SetBehaviorVariable('CastSignEnd',0.f);
		
		InitializeCombatDataStorage();
		humanCombatDataStorage.SetProtectedByQuen(true);
		shieldActive = true;
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		
		if(GetNPC().HasTag('mq1060_witcher'))
			hitEntityTemplate = (CEntityTemplate) LoadResourceAsync( "gameplay\sign\quen_hit_new_mq1060" );
		else
			hitEntityTemplate = (CEntityTemplate) LoadResourceAsync( "gameplay\sign\quen_hit_new" );
		
		super.Main();
		Started();
		Throw();
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		super.OnDeactivate();
		
		if( hitEntity )
		{
			hitEntity.DestroyAfter(3.0);
			hitEntity = NULL;
		}
		
		npc.SetGuarded(false);
		npc.SetParryEnabled( false );
		npc.customHits = false;
		
		npc.RemoveBuffImmunity( EET_Swarm, 'TaskCastQuen' );
		npc.RemoveBuffImmunity( EET_Burning, 'TaskCastQuen' );
		
		npc.SetBehaviorVariable('CastSignEnd',1.f);
		
		if ( signEntity )
			signEntity.BreakAttachment();
		
		humanCombatDataStorage.SetProtectedByQuen(false);
		shieldActive = false;
	}
	
	function Started()
	{
		if( signEntity )
		{
			
			
			if( alternateFireMode )
				signEntity.SetAlternateCast( S_Magic_s04 );
			signEntity.OnStarted();
		}
		super.Started();
	}
	
	function Throw()
	{
		if( signEntity )
		{
			signEntity.OnThrowing();
		}		
	}
	
	function ProcessAction( data : CDamageData )
	{
		var npc 	: CNewNPC = GetNPC();
		var params 	: SCustomEffectParams;
		
		if ( data.isActionMelee )
		{
			params.effectType = EET_Stagger;
			params.creator = GetActor();
			params.sourceName = "quen";
			params.duration = 0.1;
			
			((CActor)data.attacker).AddEffectCustom( params );
		}
		
		
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 	: CNewNPC = GetNPC();
		var data 	: CDamageData;
		
		if ( eventName == 'BeingHit' && shieldActive )
		{
			data = (CDamageData) GetEventParamBaseDamage();
			
			PlayHitEffect( data );
			ProcessAction( data );
			super.Throw();
			
			if ( completeAfterHit )
			{
				npc.SetBehaviorVariable('CastSignEnd',1.f);
			}
			return true;
		}
		else if ( eventName == 'FinishQuen' )
		{
			Complete(true);
		}
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		PlayHitEffect();
		super.Throw();
		return true;
	}
	
	private var playEffectTimeStamp : float;
	function PlayHitEffect( optional data : CDamageData )
	{
		
		var rot : EulerAngles;
		var localTime : float;
		
		localTime = GetLocalTime();
		
		if ( playEffectTimeStamp + 0.4 >= localTime )
			return;
		
		
		if ( data )
		{
			
			
			rot = VecToRotation ( data.attacker.GetWorldPosition() - data.victim.GetWorldPosition() );
			rot.Yaw -= 90;
		}
		else
		{
			
			rot.Pitch += 90;
		}
		
		hitEntity = theGame.CreateEntity( hitEntityTemplate, signEntity.GetWorldPosition(), rot );
		if(hitEntity)
		{
			hitEntity.CreateAttachment( GetActor(), 'quen_sphere' );
			
			hitEntity.PlayEffect('quen_rebound_sphere');
		}
		
		playEffectTimeStamp = localTime;
	}
	
	function SetupSignType()
	{
		signType = ST_Quen;
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !humanCombatDataStorage )
		{
			super.InitializeCombatDataStorage();
			humanCombatDataStorage = (CHumanAICombatStorage)combatDataStorage;
		}
	}
};

class CBTTaskCastQuenDef extends CBTTaskCastSignDef
{
	default instanceClass = 'CBTTaskCastQuen';

	editable var completeAfterHit : bool;
	editable var alternateFireMode : bool;
	editable var processQuenOnCounterActivation : bool;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CustomHit' );
	}
};
