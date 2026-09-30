/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3CiriPhantom extends CGameplayEntity
{
	private var owner : CActor;
	private var target : CActor;
		
	private var rotationDamper : EulerAnglesSpringDamper;
	
	public function Init( setOwner : CActor, setTarget : CActor )
	{
		owner = setOwner;
		target = setTarget;
		
		InitDamper();
		AddTimer('Rotate',0,true);
		
		AddAnimEventCallback( 'AllowBlend',		'OnAnimEvent_AllowBlend' );
		AddAnimEventCallback( 'fx_trail',		'OnAnimEvent_fx_trail' );
	}
	
	private function InitDamper()
	{
		rotationDamper = new EulerAnglesSpringDamper in this;
		rotationDamper.Init(GetWorldRotation(),GetWorldRotation());
		rotationDamper.SetSmoothTime(0.1);
	}
	
	private timer function Rotate( dt : float, id : int )
	{
		RotateToTarget( dt );
	}
	
	private timer function SlowMoStart( dt : float, id : int )
	{
		theGame.SetTimeScale( 0.1f, 'CiriPhantom', 500, true, true );
		AddTimer('SlowMoEnd', 0.05f );
	}
	
	private timer function SlowMoEnd( dt : float, id : int )
	{
		theGame.RemoveTimeScale( 'CiriPhantom' );
	}
	
	private function RotateToTarget( dt : float )
	{
		var rot : EulerAngles;
		var targetPos : Vector;
		var headingVec : Vector;
		var thisPos : Vector;
		var velocity : Vector;
		
		velocity = target.GetMovingAgentComponent().GetVelocity();
		velocity.Z = 0;
		targetPos = target.GetWorldPosition() + velocity*0.5;
		
		thisPos = this.GetWorldPosition();
		headingVec = targetPos - thisPos;
		rot = VecToRotation(headingVec);
		rot = rotationDamper.UpdateAndGet(dt,rot);
		this.TeleportWithRotation(thisPos, rot );
		
	}
	
		
	event OnPreAttackEvent(animEventName : name, animEventType : EAnimationEventType, data : CPreAttackEventData, animInfo : SAnimationEventAnimInfo )
	{		
		var parriedBy : array<CActor>;
		var hitTargets : array<CActor>;
		var weaponId : SItemUniqueId;
		var inventory : CInventoryComponent;
		var weaponEntity : CItemEntity;		
	
		
		
		
		if(animEventType == AET_DurationStart)
		{
			owner.SetAttackData(data);
		}
		
		else if(animEventType == AET_DurationEnd)
		{
			inventory = owner.GetInventory();
			weaponId = inventory.GetItemFromSlot(data.weaponSlot);
			
			if(!inventory.IsIdValid(weaponId) || data.attackName == '')
			{
				LogAttackEvents("No valid attack data set - skipping hit!");
				LogAssert(false, "No valid attack data set - skipping hit!");
				return false;
			}
				
			
			
			data.canBeDodged = false;
			data.attackName = 'attack_heavy';
			Attack(target, data, weaponId, parriedBy, GetAnimNameFromEventAnimInfo( animInfo ), GetLocalAnimTimeFromEventAnimInfo( animInfo ), weaponEntity);
			
		}
	}
	
	protected function Attack( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity)
	{
		var action : W3Action_Attack;
		var tags : array<name>;
		
		if(PrepareAttackAction(hitTarget, animData, weaponId, parriedBy, attackAnimationName, hitTime, weaponEntity, action))
		{
			theGame.damageMgr.ProcessAction(action);
			delete action;
		}
		AddHitFacts( hitTarget.GetTags(), tags, "_phantom_hit", false);
		
		AddTimer('SlowMoStart', 0.1f );
		RemoveTimer('Rotate');
	}
	
	protected function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
	{
		var actor : CActor;
	
		if(!hitTarget)
			return false;
			
		attackAction = new W3Action_Attack in theGame.damageMgr;
		attackAction.Init( owner, hitTarget, this, weaponId, animData.attackName, GetName(), EHRT_Heavy, false, false, animData.attackName, animData.swingType, animData.swingDir, true, false, false, false, animData.hitFX, animData.hitBackFX, animData.hitParriedFX, animData.hitBackParriedFX);
		
		attackAction.SetAttackAnimName(attackAnimationName);
		attackAction.SetHitTime(hitTime);
		attackAction.SetWeaponEntity(weaponEntity);
		attackAction.SetSoundAttackType(animData.soundAttackType);
		
		actor = (CActor)hitTarget;
		if(actor && parriedBy.Contains(actor))
			attackAction.SetIsParried(true);
		
		return true;
	}
	
	
	event OnAnimEvent_AllowBlend( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventType == AET_DurationStart )
		{
			SmartSetVisible(false);
		}
	}
	
	event OnAnimEvent_fx_trail( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		this.PlayEffectOnHeldWeapon('light_trail_fx');
	}
	
	
	
	function PlayEffectOnHeldWeapon( effectName : name ) : bool
	{
		var itemId : SItemUniqueId;
		var inv : CInventoryComponent;
		
		inv = GetInventory();		
		itemId = inv.GetItemFromSlot('steel_sword_back_slot');
		
		if ( !inv.IsIdValid(itemId) )
		{
			itemId = inv.GetItemFromSlot('r_weapon');
			
			if ( !inv.IsIdValid(itemId) )
				return false;
		}
			
		inv.PlayItemEffect(itemId,effectName);
		
		return true;
	}
	
	private function SmartSetVisible( toggle : bool )
	{
		SetHideInGame(!toggle);
	}
}