/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SummonerComponent extends CScriptedComponent
{
	
	
	
	public 	editable var forgetDeadEntities 	: bool;
	private var m_SummonedEntities 				: array <CEntity>;
	
	default forgetDeadEntities = true;
	
	
	public function AddEntity( _EntityToAdd : CEntity )
	{
		var summonedEntityComponent : W3SummonedEntityComponent;
		
		if( !m_SummonedEntities.Contains( _EntityToAdd ) && _EntityToAdd ) 
		{
			m_SummonedEntities.PushBack( _EntityToAdd );
			
			summonedEntityComponent = (W3SummonedEntityComponent) _EntityToAdd.GetComponentByClassName('W3SummonedEntityComponent');
			if( summonedEntityComponent )
			{
				summonedEntityComponent.Init( (CActor) GetEntity() );
			}			
		}
	}
	
	
	public function RemoveEntity( _EntityToRemove : CEntity )
	{
		m_SummonedEntities.Remove( _EntityToRemove );
	}	
	
	
	public function GetSummonedEntities() :  array <CEntity>
	{
		UpdateArray();
		return m_SummonedEntities;
	}
	
	
	public function GetNumberOfSummonedEntities() :  int
	{
		UpdateArray();
		return m_SummonedEntities.Size();
	}
	
	
	private function UpdateArray()
	{
		var i		: int;
		var actor 	: CActor;
		
		for	( i = m_SummonedEntities.Size() - 1 ; i >= 0 ; i -= 1 )
		{
			actor = (CActor) m_SummonedEntities[i];
			
			if( !m_SummonedEntities[i] )
			{
				m_SummonedEntities.EraseFast( i );
			}			
			else if( forgetDeadEntities && actor && !actor.IsAlive() )
			{
				m_SummonedEntities.EraseFast( i );
			}
		}
	}
	
	
	public function OnDeath()
	{
		var i 			: int;
		var	summonedCmp	: W3SummonedEntityComponent;
		
		for ( i = 0; i < m_SummonedEntities.Size(); i += 1 )
		{
			summonedCmp = (W3SummonedEntityComponent) m_SummonedEntities[i].GetComponentByClassName('W3SummonedEntityComponent');
			if( summonedCmp )
			{
				summonedCmp.OnSummonerDeath();
			}
		}
	}
}