/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageMistForm extends CBTTaskPlayAnimationEventDecorator
{
	public var manageMistFormOnAnimEvents		: bool;
	public var enableOnActivate					: bool;
	public var enableOnMain						: bool;
	public var disableOnDeactivate				: bool;
	public var affectVisibility					: bool;
	public var affectGameplayVisibility			: bool;
	public var affectCollision					: bool;
	public var affectHitAnims					: bool;
	public var affectImmortality				: bool;
	public var delayExecutionInMain				: float;
	public var appearanceOnActivate				: name;
	public var appearanceOnMain					: name;
	public var restoreAppearanceOnDeactivate	: bool;
	public var appearanceOnDeactivate			: name;
	public var previousAppearanceName			: name;
	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( enableOnActivate )
		{
			DisableMistForm( false );
			if ( affectImmortality )
			{
				npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			}
		}
		
		if ( IsNameValid( appearanceOnActivate ) )
		{
			previousAppearanceName = npc.GetAppearance();
			npc.SetAppearance( appearanceOnActivate );
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( delayExecutionInMain > 0 )
		{
			Sleep( delayExecutionInMain );
		}
		
		if ( enableOnMain )
		{
			DisableMistForm( false );
			if ( affectImmortality )
			{
				npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			}
		}
		
		if ( IsNameValid( appearanceOnMain ) )
		{
			previousAppearanceName = npc.GetAppearance();
			npc.SetAppearance( appearanceOnMain );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( disableOnDeactivate )
		{
			DisableMistForm( true );
			if ( affectImmortality )
			{
				npc.SetImmortalityMode( AIM_None, AIC_Combat );
			}
		}
		
		if ( restoreAppearanceOnDeactivate && IsNameValid( previousAppearanceName ) )
		{
			npc.SetAppearance( previousAppearanceName );
		}
		else if ( IsNameValid( appearanceOnDeactivate ) )
		{
			npc.SetAppearance( appearanceOnDeactivate );
		}
	}
	
	function DisableMistForm( b : bool )
	{
		var npc : CNewNPC = GetNPC();
		
		if ( affectVisibility )
		{
			npc.SetVisibility( b );
		}
		if ( affectGameplayVisibility )
		{
			npc.SetGameplayVisibility( b );
		}
		if ( affectCollision )
		{
			npc.EnableCharacterCollisions( b );
		}
		if ( affectHitAnims )
		{
			npc.SetCanPlayHitAnim( b );
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if ( manageMistFormOnAnimEvents )
		{
			if ( animEventName == 'Appear' )
			{
				DisableMistForm( true );
				
				
				return true;
			}
			else if ( animEventName == 'Disappear' || animEventName == 'Vanish' )
			{
				DisableMistForm( false );
				
				
				return true;
			}
		}
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
};



class BTTaskManageMistFormDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'BTTaskManageMistForm';

	editable var enableOnActivate				: bool;
	editable var enableOnMain					: bool;
	editable var disableOnDeactivate			: bool;
	editable var affectVisibility				: bool;
	editable var affectGameplayVisibility		: bool;
	editable var affectCollision				: bool;
	editable var affectHitAnims					: bool;
	editable var affectImmortality				: bool;
	editable var delayExecutionInMain			: float;
	editable var appearanceOnActivate			: name;
	editable var appearanceOnMain				: name;
	editable var restoreAppearanceOnDeactivate	: bool;
	editable var appearanceOnDeactivate			: name;
	
	default affectGameplayVisibility 			= true;
	default affectCollision 					= true;
	default affectHitAnims 						= true;
	
	hint restorePreviousAppearance 				= "Overrides appearanceOnDeactivate";
};