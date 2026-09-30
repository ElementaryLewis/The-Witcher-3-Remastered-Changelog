/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EActionHitAnim
{
	EAHA_Default,		
	EAHA_ForceYes,		
	EAHA_ForceNo		
}


import class CDamageData extends CBaseDamage
{
	
	import var processedDmg : SProcessedDamage;
	
	
	import var hitLocation  : Vector ;	
	import var momentum  	: Vector ;
	
	
	import var causer 		: IScriptable;							
	import var attacker 	: CGameplayEntity ;
	import var victim   	: CGameplayEntity ;
	
	import var hitReactionAnimRequested				: bool;
	import var additiveHitReactionAnimRequested		: bool;
	import var customHitReactionRequested			: bool;
	import var isDoTDamage							: bool;			
	
	var isActionMelee : bool;	
}


class W3DamageAction extends CDamageData
{
	protected var dmgInfos		: array< SRawDamage >;				
	protected var effectInfos	: array< SEffectInfo >;				
	protected var cannotReturnDamage : bool;						
	protected var isPointResistIgnored : bool;						
	protected var canPlayHitParticle : bool;						
	protected var hitAnimationPlayType : EActionHitAnim;			
	protected var hitReactionType : EHitReactionType;				
	private var buffSourceName : string;							
	protected var canBeParried : bool;								
	protected var canBeDodged : bool;								
	protected var hitFX,hitBackFX,hitParriedFX,hitBackParriedFX : name;		
	protected var powerStatType : ECharacterPowerStats;				
	protected var swingType : EAttackSwingType;						
	protected var swingDirection : EAttackSwingDirection;			
	protected var signSkill : ESkill;								
	protected var isDodged : bool;									
	protected var shouldProcessBuffsIfNoDamage : bool;				
	private var ignoreImmortalityMode : bool;						
	private var dealtFireDamage : bool;								
	protected var isHeadShot : bool;								
	protected var killedBySingleHit : bool;							
	protected var ignoreArmor : bool;								
	protected var supressHitSounds : bool;							
	protected var dealtDamage : bool;								
	protected var endsQuen : bool;									
	protected var armorReducedDamageToZero : bool;					
	protected var underwaterDisplayDamageHack : bool;				
	protected var parryStagger : bool;								
	protected var bouncedArrow : bool;								
	protected var forceExplosionDismemberment : bool;					
	protected var isCriticalHit : bool;								
	protected var instantKill : bool;								
	protected var instantKillFloater : bool;						
	protected var instantKillCooldownIgnore : bool;					
	protected var wasFrozen	: bool;									
	protected var mutation4Triggered : bool;						
	protected var didReturnDamageToAttacker : bool;					
	
	
	private var DOTdt : float;										
	
	
	
	private var isActionRanged : bool;
	private var isActionWitcherSign : bool;
	private var isActionEnvironment : bool;
	
	default hitAnimationPlayType 			= EAHA_Default;
	default cannotReturnDamage 				= false;
	default isPointResistIgnored 			= false;
	default canPlayHitParticle 				= true;
	default isDodged						= false;
	default isActionMelee					= false;
	default isActionRanged					= false;
	default isActionWitcherSign				= false;
	default isActionEnvironment				= false;
	default shouldProcessBuffsIfNoDamage	= true;
	default ignoreImmortalityMode   		= false;
	default dealtFireDamage					= false;
	default isHeadShot						= false;
	default killedBySingleHit				= false;
	default endsQuen						= false;
	default armorReducedDamageToZero		= false;
	default underwaterDisplayDamageHack 	= false;
	default parryStagger					= false;
	default bouncedArrow					= false;
		
	public function Initialize( att : CGameplayEntity, vict : CGameplayEntity, caus : IScriptable, src : string, hrt : EHitReactionType, pwrStatType : ECharacterPowerStats, isM : bool, isR : bool, isW : bool, isE : bool, optional hitFX_ : name, optional hitBackFX_ : name, optional hitParriedFX_ : name, optional hitBackParriedFX_ : name)
	{
		Clear();
		
		attacker = att;
		victim = vict;
		causer = caus;
		buffSourceName = src;
		hitReactionType = hrt;
		powerStatType = pwrStatType;
		swingType = AST_NotSet;
		swingDirection = ASD_NotSet;
		isActionMelee = isM;
		isActionRanged = isR;
		isActionWitcherSign = isW;
		isActionEnvironment = isE;

		if(IsNameValid(hitFX_) || IsNameValid(hitBackFX_) || IsNameValid(hitParriedFX_) || IsNameValid(hitBackParriedFX_))
		{
			hitFX = hitFX_;
			hitBackFX = hitBackFX_;
			hitParriedFX = hitParriedFX_;
			hitBackParriedFX = hitBackParriedFX_;
		}
		else
		{
			SetDefaultHitFXs();
		}
	}
	
	protected function Clear()
	{
		processedDmg.essenceDamage = 0;
		processedDmg.vitalityDamage = 0;
		processedDmg.moraleDamage = 0;
		processedDmg.staminaDamage = 0;
		hitLocation = Vector(0,0,0);
		momentum = Vector(0,0,0);
		causer = NULL;
		attacker = NULL;
		victim = NULL;
		hitReactionAnimRequested = false;
		additiveHitReactionAnimRequested = false;
		customHitReactionRequested = false;
		isActionMelee = false;
		isCriticalHit = false;
		
		dmgInfos.Clear();
		effectInfos.Clear();
		cannotReturnDamage = false;
		isPointResistIgnored = false;
		canPlayHitParticle = true;
		hitAnimationPlayType = EAHA_Default;
		hitReactionType = EHRT_None;
		buffSourceName = "";
		canBeParried = false;
		canBeDodged = false;
		hitFX = '';
		hitBackFX = '';
		hitParriedFX = '';
		hitBackParriedFX = '';
		powerStatType = CPS_Undefined;
		swingType = AST_NotSet;
		swingDirection = ASD_NotSet;
		signSkill = S_SUndefined;
		isDodged = false;
		shouldProcessBuffsIfNoDamage = false;
		ignoreImmortalityMode = false;
		dealtFireDamage = false;
		isDoTDamage = false;
		isHeadShot = false;
		killedBySingleHit = false;
		ignoreArmor = false;
		DOTdt = 0;
		isActionRanged = false;
		isActionWitcherSign = false;
		isActionEnvironment = false;
		endsQuen = false;
		armorReducedDamageToZero = false;
		underwaterDisplayDamageHack = false;
		parryStagger = false;
		bouncedArrow = false;
		forceExplosionDismemberment = false;
		instantKill = false;
		instantKillFloater = false;
		instantKillCooldownIgnore = false;
		wasFrozen = false;
	}
	
	
	public function SetSignSkill(skill : ESkill)
	{
		signSkill = skill;
	}
		
	
	public function GetSignSkill() : ESkill
	{
		return signSkill;
	}

	public function GetSignType() : ESignType
	{	
		if( signSkill == S_Magic_1 )
		{
			return ST_Aard;
		}
		else if( signSkill == S_Magic_2 )
		{
			return ST_Igni;
		}
		else if( signSkill == S_Magic_3 || signSkill == S_Magic_s03)
		{
			return ST_Yrden;
		}
		else if( signSkill == S_Magic_4 || signSkill == S_Magic_s04 || signSkill == S_Magic_s13)
		{
			return ST_Quen;
		}	
		
		return ST_None;
	}
	
	
	function AddDamage( dmgType : name, dmgVal : float )
	{
		var dmgInfo : SRawDamage;
		var i : int;
		
		if(dmgVal <= 0)
			return;
		
		
		for(i=0; i<dmgInfos.Size(); i+=1)
		{
			if(dmgInfos[i].dmgType == dmgType)
			{
				dmgInfos[i].dmgVal += dmgVal;
				return;
			}
		}
		
		dmgInfo.dmgType = dmgType;
		dmgInfo.dmgVal = dmgVal;
		
		dmgInfos.PushBack( dmgInfo );
	}
	
	
	function AddEffectInfo(effectType : EEffectType, optional duration : float, optional effectCustomValue : SAbilityAttributeValue, optional effectAbilityName : name, optional customParams : W3BuffCustomParams, optional buffApplyChance : float )
	{
		var effectInfo : SEffectInfo;
		
		if(effectType == EET_Undefined)
			return;
			
		effectInfo.effectType = effectType;
		effectInfo.effectDuration = duration;
		effectInfo.effectCustomValue = effectCustomValue;
		effectInfo.effectAbilityName = effectAbilityName;
		effectInfo.effectCustomParam = customParams;
				
		if(buffApplyChance == 0)
			buffApplyChance = 1;	
		effectInfo.applyChance = buffApplyChance;
		
		effectInfos.PushBack( effectInfo );
	}
	
	public function RemoveBuff(index : int)
	{
		if(index >= 0 && index < effectInfos.Size())
		{
			effectInfos.Erase(index);
		}
	}
	
	public final function RemoveBuffsByType(type : EEffectType)
	{
		var i : int;
		
		for(i=effectInfos.Size()-1; i>=0; i-=1)
		{
			if(effectInfos[i].effectType == type)
				effectInfos.EraseFast(i);
		}
	}
		
	
	public function SetHitReactionType(hrt : EHitReactionType, optional setDefaultHitFXs : bool)
	{
		hitReactionType = hrt;
		
		if(setDefaultHitFXs)
			SetDefaultHitFXs();
	}
	
	public function SetHitAnimationPlayType(type : EActionHitAnim)
	{
		hitAnimationPlayType = type;
	}
	
	public function GetHitAnimationPlayType() : EActionHitAnim
	{
		return hitAnimationPlayType;
	}

	public function GetEffects( out effects : array< SEffectInfo > ) : int
	{
		effects.Clear();
		effects = effectInfos;

		return effects.Size();
	}
	
	public function GetEffectsCount() : int
	{
		return effectInfos.Size();
	}
	
	public function HasAnyCriticalEffect() : bool
	{
		var i : int;
		
		for ( i=0 ; i < effectInfos.Size() ; i+=1 )
		{
			if ( IsCriticalEffectType(effectInfos[i].effectType) )
				return true;
		}
		return false;
	}
	
	public function GetEffectTypes(out effectTypes : array< EEffectType > ) : int
	{
		var i : int;
		
		effectTypes.Clear();
		for ( i=0 ; i < effectInfos.Size() ; i+=1 )
		{
			effectTypes.PushBack(effectInfos[i].effectType);
		}
			
		return effectTypes.Size();
	}
	
	public function HasBuff( type : EEffectType ) : bool
	{
		var i : int;
		
		for ( i=0 ; i < effectInfos.Size() ; i+=1 )
		{
			if( effectInfos[i].effectType == type )
			{
				return true;
			}
		}
			
		return false;
	}
	
	
	public function GetDTs( out dmgTypes : array< SRawDamage > ) : int
	{
		dmgTypes.Clear();
		dmgTypes = dmgInfos;
		
		return dmgTypes.Size();
	}
	
	public function GetDTCount() : int
	{
		return dmgInfos.Size();
	}	
	
	
	public function GetDTsNames(out dtNames : array< name > ) : int
	{
		var i : int;
		
		dtNames.Clear();
		for ( i=0 ; i < dmgInfos.Size() ; i+=1 )
			dtNames.PushBack(dmgInfos[i].dmgType);
			
		return dtNames.Size();
	}
	
	
	protected function SetDefaultHitFXs()
	{
		switch(hitReactionType)
		{
			case EHRT_Light:
			case EHRT_LightClose:
				hitFX 			 = theGame.params.LIGHT_HIT_FX;
				hitBackFX 		 = theGame.params.LIGHT_HIT_BACK_FX;
				hitParriedFX 	 = theGame.params.LIGHT_HIT_PARRIED_FX;
				hitBackParriedFX = theGame.params.LIGHT_HIT_BACK_PARRIED_FX;
				break;
			case EHRT_Heavy:
				hitFX 			 = theGame.params.HEAVY_HIT_FX;
				hitBackFX 		 = theGame.params.HEAVY_HIT_BACK_FX;
				hitParriedFX 	 = theGame.params.HEAVY_HIT_PARRIED_FX;
				hitBackParriedFX = theGame.params.HEAVY_HIT_BACK_PARRIED_FX;
				break;
			case EHRT_None:
				hitFX 			 = theGame.params.LIGHT_HIT_FX;
				hitBackFX 		 = theGame.params.LIGHT_HIT_BACK_FX;
				hitParriedFX 	 = theGame.params.LIGHT_HIT_PARRIED_FX;
				hitBackParriedFX = theGame.params.LIGHT_HIT_BACK_PARRIED_FX;
				break;
			default:
				hitFX 			 = '';
				hitBackFX 		 = '';
				hitParriedFX 	 = '';
				hitBackParriedFX = '';
				break;
		}
	}
	
	
	public function GetPowerStatBonusAbilityTag() : name		{return '';}
	
	public function CanBeParried() : bool						{return canBeParried;}
	public function CanBeDodged() : bool						{return canBeDodged;}
	public function SetPointResistIgnored(b : bool)				{isPointResistIgnored = b;}
	public function CanPlayHitParticle() : bool					{return canPlayHitParticle;}
	public function SetCanPlayHitParticle(b : bool)				{canPlayHitParticle = b;}
	public function GetBuffSourceName() : string				{return buffSourceName;}
	public function SetBuffSourceName( s : string )				{buffSourceName = s;}
	public function GetCannotReturnDamage() : bool				{return cannotReturnDamage;}
	public function SetCannotReturnDamage(b : bool)				{cannotReturnDamage = b;}
	public function ClearDamage()								{dmgInfos.Clear();}
	public function ClearEffects()								{effectInfos.Clear();}	
	public function GetHitReactionType() : EHitReactionType		{return hitReactionType;}
	public function IsPointResistIgnored() : bool				{return isPointResistIgnored;}	
	public function GetSwingType() : EAttackSwingType			{return swingType;}
	public function GetSwingDirection() : EAttackSwingDirection	{return swingDirection;}
	public function SetWasDodged()								{isDodged = true;}
	public function WasDodged() : bool							{return isDodged;}	
	public function IsDoTDamage() : bool						{return isDoTDamage;}
	public function SetForceExplosionDismemberment()			{forceExplosionDismemberment = true;}
	public function HasForceExplosionDismemberment() : bool		{return forceExplosionDismemberment;}
	
	
	public function SetIsDoTDamage(dt : float)
	{
		isDoTDamage = (dt > 0);
		DOTdt = dt;
	}
	
	public function GetDoTdt() : float
	{
		return DOTdt;
	}
	
	public function GetHitEffect( optional isBack : bool, optional isParried : bool ) : name
	{		
		if( isBack && !isParried )
		{
			return hitBackFX;			
		}
		else if( !isBack && isParried )
		{
			return hitParriedFX;
		}
		else if( isBack && isParried )
		{
			return hitBackParriedFX;
		}
		
		if( isCriticalHit && !IsActionWitcherSign() )
		{
			return theGame.params.CRITICAL_HIT_FX;
		}
		
		return hitFX;
	}
	
	public function SetHitEffect(newFX : name, optional isBack : bool, optional isParried : bool)
	{
		if(!isBack && !isParried)			{hitFX 				= newFX;}
		else if(isBack && !isParried)		{hitBackFX 			= newFX;}			
		else if(!isBack && isParried)		{hitParriedFX 		= newFX;}
		else								{hitBackParriedFX 	= newFX;}	
	}
	
	public function SetHitEffectAllTypes(newFX : name)
	{
		hitFX = newFX;
		hitBackFX = newFX;
		hitParriedFX = newFX;
		hitBackParriedFX = newFX;
	}
	
	
	public function DealsAnyDamage() : bool
	{
		var actorVictim : CActor;
		
		if(isDodged)
			return false;
			
		actorVictim = (CActor)victim;
		
		if(actorVictim)
			return (actorVictim.UsesVitality() && processedDmg.vitalityDamage > 0) || (actorVictim.UsesEssence() && processedDmg.essenceDamage > 0);
		else
			return processedDmg.vitalityDamage > 0 || processedDmg.essenceDamage > 0;
	}
	
	
	public function DealtDamage() : bool
	{
		return dealtDamage;
	}
	
	public function SetDealtDamage()
	{
		dealtDamage = true;
	}
	
	
	public function DealsPhysicalOrSilverDamage() : bool
	{
		var i, size : int;
		
		size = dmgInfos.Size();
		for(i=0; i<size; i+=1)
			if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
				dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
				dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
				dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
				dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_RENDING ||
				dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_SILVER )
				return true;
				
		return false;		
	}
	
	
	public function GetDamageDealt() : float
	{
		var actor : CActor;
		
		actor = (CActor)victim;
		if(actor && actor.UsesEssence())
			return processedDmg.essenceDamage;
		
		return processedDmg.vitalityDamage;
	}
	
	
	public function GetPowerStatValue() : SAbilityAttributeValue
	{
		var result : SAbilityAttributeValue;
		var actor : CActor;
		var signEntity : W3SignEntity;
		var signProjectile : W3SignProjectile;

		actor = (CActor)attacker;
		if(!actor || powerStatType == CPS_Undefined)
		{
			result.valueBase = 0;
			result.valueMultiplicative = 1;
			return result;
		}
		
		signEntity = (W3SignEntity)causer;
		signProjectile = (W3SignProjectile)causer;
		if(!signEntity && signProjectile)
			signEntity = signProjectile.GetSignEntity();
			
		if(signEntity)
		{
			result = actor.GetTotalSignSpellPower(signEntity.GetSkill());
		}
		else
		{
			
			result = actor.GetPowerStatValue(powerStatType);
			if(IsNameValid(GetPowerStatBonusAbilityTag()))
				result += actor.GetPowerStatValue(powerStatType, GetPowerStatBonusAbilityTag());
		}
		
		
		if(result.valueMultiplicative < 0)
			result.valueMultiplicative = 0.001;
			
		return result;
	}
	
	
	public function SetAllProcessedDamageAs(val : float)
	{
		if(val < 0.f)
			val = 0.f;
			
		processedDmg.essenceDamage = val;
		processedDmg.vitalityDamage = val;
		processedDmg.staminaDamage = val;
		processedDmg.moraleDamage = val;
	}
	
	public function MultiplyAllDamageBy(val : float)
	{
		if(val < 0.f)
			val = 0.f;
			
		processedDmg.essenceDamage *= val;
		processedDmg.vitalityDamage *= val;
		processedDmg.staminaDamage *= val;
		processedDmg.moraleDamage *= val;
	}
	
	
	public final function IsActionMelee() : bool			{return isActionMelee;}
	public final function IsActionRanged() : bool			{return isActionRanged;}
	public final function IsActionWitcherSign() : bool		{return isActionWitcherSign;}	
	public final function IsActionEnvironment() : bool		{return isActionEnvironment;}
	
	public final function IsParryStagger() : bool				{return parryStagger;}
	public final function SetParryStagger()						{parryStagger = true;}
	public final function ProcessBuffsIfNoDamage() : bool		{return shouldProcessBuffsIfNoDamage;}
	public final function SetProcessBuffsIfNoDamage(b : bool)	{shouldProcessBuffsIfNoDamage = b;}
	public final function SetIgnoreImmortalityMode(b : bool)	{ignoreImmortalityMode = b;}
	public final function GetIgnoreImmortalityMode() : bool		{return ignoreImmortalityMode;}
	public final function SetDealtFireDamage(b : bool)			{dealtFireDamage = b;}
	public final function HasDealtFireDamage() : bool			{return dealtFireDamage;}
	public final function SetHeadShot()							{isHeadShot = true;}
	public final function GetIsHeadShot() : bool				{return isHeadShot;}
	public final function SetWasKilledBySingleHit()				{killedBySingleHit = true;}
	public final function WasKilledBySingleHit() : bool			{return killedBySingleHit;}
	public final function GetIgnoreArmor() : bool				{return ignoreArmor;}
	public final function SetIgnoreArmor(b : bool)				{ignoreArmor = b;}
	public final function SuppressHitSounds() : bool				{return supressHitSounds;}
	public final function SetSuppressHitSounds(b : bool)			{supressHitSounds = b;}
	
	public final function SetEndsQuen(b : bool)					{endsQuen = b;}
	public final function EndsQuen() : bool						{return endsQuen;}
	public final function SetArmorReducedDamageToZero( b : bool )	{armorReducedDamageToZero = b;} 
	public final function DidArmorReduceDamageToZero() : bool	{return armorReducedDamageToZero;}
	public final function SetUnderwaterDisplayDamageHack()		{underwaterDisplayDamageHack = true;}
	public final function GetUnderwaterDisplayDamageHack() : bool	{return underwaterDisplayDamageHack;}
	public final function SetBouncedArrow()						{bouncedArrow = true;}
	public final function IsBouncedArrow() : bool				{return bouncedArrow;}
	public final function IsCriticalHit() : bool				{return isCriticalHit;}
	public final function SetInstantKillFloater()				{instantKillFloater = true;}
	public final function GetInstantKillFloater() : bool		{return instantKillFloater;}
	public final function SetInstantKill()						{instantKill = true;}
	public final function GetInstantKill() : bool				{return instantKill;}
	public final function SetIgnoreInstantKillCooldown()		{instantKillCooldownIgnore = true;}
	public final function GetIgnoreInstantKillCooldown() : bool {return instantKillCooldownIgnore;}
	public final function SetWasFrozen() 						{wasFrozen = true;}
	public final function GetWasFrozen() : bool					{return wasFrozen;}
	public final function SetMutation4Triggered()				{mutation4Triggered = true;}
	public final function GetMutation4Triggered() : bool		{return mutation4Triggered;}
	public final function WasDamageReturnedToAttacker() : bool  {return didReturnDamageToAttacker;}
	public final function SetWasDamageReturnedToAttacker( b : bool ) {didReturnDamageToAttacker = b;}

	public final function SetCriticalHit()
	{
		isCriticalHit = true;
		
		if( ( W3PlayerWitcher )attacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) && IsActionWitcherSign() )
		{
			theGame.MutationHUDFeedback( MFT_PlayOnce );
		}
	}
	
	public final function GetDamageValue(damageName : name) : float
	{
		var i : int;
		
		for(i=0; i<dmgInfos.Size(); i+=1)
			if(dmgInfos[i].dmgType == damageName)
				return dmgInfos[i].dmgVal;
				
		return 0;
	}
	
	
	public final function GetDamageValueTotal() : float
	{
		var i : int;
		var ret : float;
		
		ret = 0;
		for(i=0; i<dmgInfos.Size(); i+=1)
			ret += dmgInfos[i].dmgVal;
				
		return ret;
	}
	
	public final function IsMutation2PotentialKill() : bool
	{
		var isOk : bool;
		var burning : W3Effect_Burning;
		
		
		
		
		isOk = ( attacker == thePlayer && IsActionWitcherSign() && IsCriticalHit() && ( GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) || GetWitcherPlayer().IsSuperchargedSign() ) );
		
		
		
		if( !isOk )
		{
			burning = ( W3Effect_Burning ) causer;
			isOk = burning && burning.IsFromMutation2();
		}
		
		return isOk;
	}
	
	
	public final function GetPowerStatType() : ECharacterPowerStats
	{
		return powerStatType;
	}
}
