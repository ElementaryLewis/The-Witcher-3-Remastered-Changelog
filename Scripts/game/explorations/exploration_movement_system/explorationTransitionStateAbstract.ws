/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateTransitionAbstract extends CExplorationStateAbstract
{
	protected	editable	var			m_TransitionOriginStateN	: name;
	protected	editable	var			m_TransitionEndStateN		: name;


	
	public function IsMachForThisStates( _FromN, _ToN : name ) : bool
	{
		if( IsNameValid( m_TransitionOriginStateN ) && _FromN != m_TransitionOriginStateN )
		{
			return false;
		}
		if( IsNameValid( m_TransitionEndStateN ) && _ToN != m_TransitionEndStateN )
		{
			return false;
		}
		
		return _FromN == m_TransitionOriginStateN && m_TransitionEndStateN == _ToN;
	}	
	
}