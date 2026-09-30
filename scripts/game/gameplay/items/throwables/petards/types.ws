/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SPetardParams
{
	saved var damages : array<SRawDamage>;
	saved var buffs	: array<SEffectInfo>;
	saved var ignoresArmor : bool;
	
	editable var range : float;
	editable var cylinderHeight : float;
	editable var cylinderOffsetZ : float;
	editable var playHitAnimMode : EActionHitAnim;
	editable var disabledAbilities : array<SBlockedAbility>;
	editable var fxPlayedWhenAbilityDisabled : array<name>;
	editable var fxStoppedWhenAbilityDisabled : array<name>;
	editable var fxPlayedOnHit : array<name>;
	editable var surfaceFX : SFXSurfacePostParams;
	editable var fx : array<name>;
	editable var fxCluster : array<name>;
	editable var fxClusterWater : array<name>;
	editable var fxWater : array<name>;
	editable var componentsToSnap : array<name>;
	editable var decalComponentNames : array< name >;
	editable var decalComponentVisibleTimes : array< float >;
	editable var decalComponentUseRandom : bool;
	editable var decalComponentScaleModifier : float;
	
		default playHitAnimMode = EAHA_ForceYes;
	
		hint playHitAnimMode = "How to handle playing hit animation";
		hint fxPlayedSingleWhenAbilityDisabled = "Name of FX played one time on target when abilities are disabled";
		hint fxPlayedLoopedWhenAbilityDisabled = "Name of FX played looped on target when abilities are disabled";
		hint fxStoppedWhenAbilityDisabled = "Names of FXs stopped on target when abilities are disabled";
		hint surfaceFX = "Params for surface fx";
		hint fx = "FXs to play when NOT in water";
		hint fxCluster = "FXs to play when NOT in water AND cluster bomb";
		hint fxWater = "FXs to play when in water";
		hint fxClusterWater = "FXs to play when in water AND cluster bomb";
		hint componentsToSnap = "Components to be snapped to terrain";
		hint range = "Effect's mechanics' radius (sphere - if no height) or range (if cylinder)";
		hint fxPlayedOnHit = "FX played on target when target hit";
		hint decalComponentName = "Name of decal components to spawn";
		hint decalComponentVisibleTimes = "How long the decals will remain visible";
		hint decalComponentUseRandom = "Show single random decal from decalComponentNames list";
		hint decalComponentScaleModifier = "Random scale modifier in modifier's range";
};

struct SPetardShownDecals
{
	var componentName : name;
	var remainingShowTime : float;
};