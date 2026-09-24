/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EFoodGroup
{
	FG_Corpse 		= 1,
	FG_Meat			= 2,
	FG_Vegetable	= 4,
	FG_Water		= 8,
	FG_Monster		= 16
}
class W3ScentComponent extends CR4Component
{
	
	
	
	protected editable 	var 	foodGroup					: EFoodGroup;
	protected editable 	var		attractionRange				: float;
	protected editable  var		deadAttractionRange			: float;
	protected editable 	var		bleedingAttractionRange		: float;
	
	default foodGroup					= FG_Corpse;
	default	attractionRange 			= 100;	
	default	deadAttractionRange			= -1;	
	default	bleedingAttractionRange		= -1;	
	
	hint deadAttractionRange		= "Should the attraction range be different when the actor is dead (-1 means no change)";
	hint bleedingAttractionRange	= "Should the attraction range be different when the actor bleeds (-1 means no change)";
	
	
	
	
	
	public function GetFoodGroup() 		: EFoodGroup				{		return foodGroup;			}
	
	
	
	public function SetAttractionRange ( _Value : float )			{	attractionRange = _Value;		}
	
	
	public function IsInGroup( _FoodGroup : int ) : bool
	{
		var enumInt	: int;		
		enumInt = (int) foodGroup;		
		if( ( enumInt & _FoodGroup ) > 0 )
		{
			return true;
		}
		return false;
	}
	
	
	public function IsDetected( _ByWhom : CActor ) : bool
	{
		var l_pos, l_actorPos	: Vector;
		var l_distance			: float;
		
		if( _ByWhom == GetEntity() ) return false;
		
		l_pos 		= GetEntity().GetWorldPosition();
		l_actorPos 	= _ByWhom.GetWorldPosition();
		l_distance 	= VecDistance( l_pos, l_actorPos );
		
		if( l_distance > GetAttractionRange() )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function GetAttractionRange()	: float
	{
		var l_actor 			: CActor;
		
		l_actor = (CActor) GetEntity();
		
		if( deadAttractionRange > -1 && l_actor && !l_actor.IsAlive())
		{
			return deadAttractionRange;
		}
		
		if( bleedingAttractionRange > -1 && l_actor && l_actor.IsAlive())
		{
			if ( l_actor.HasBuff( EET_BleedingTracking ) || l_actor.HasBuff( EET_Bleeding ) )
			{
				return bleedingAttractionRange;
			}
		}
		
		return attractionRange;
	}
}