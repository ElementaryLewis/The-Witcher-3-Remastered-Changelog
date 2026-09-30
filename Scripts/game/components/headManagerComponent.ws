/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CHeadManagerComponent extends CSelfUpdatingComponent
{
	import final function SetTattoo( hasTattoo : bool );
	import final function SetDemonMark( hasDemonMark : bool );	
	import final function SetBeardStage( maxStage : bool, optional stage : int );
	import final function SetCustomHead( head : name );
	import final function RemoveCustomHead();
	import final function BlockGrowing( block : bool );
	import final function Shave();
	import final function MimicTest( animName : name );
	import final function GetCurHeadName() : name;
}

exec function blockbeard( optional block : bool )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).BlockGrowing( block );
}

exec function settattoo( hasTattoo : bool )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).SetTattoo( hasTattoo );
}

exec function shave()
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).Shave();
}

exec function setbeard( maxBeard : bool, optional stage : int )
{
	var acs : array< CComponent >;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).SetBeardStage( maxBeard, stage );
}

exec function setcustomhead( head : name, optional barberSystem : bool )
{
	var acs : array< CComponent >;
	
	if( barberSystem )
	{
		thePlayer.RememberCustomHead( head );
	}
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).SetCustomHead( head );
}

exec function removecustomhead( optional barberSystem : bool )
{
	var acs : array< CComponent >;
	var barberHead : name;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );

	if(!barberSystem)
	{
		barberHead = thePlayer.GetRememberedCustomHead();
		
		if( IsNameValid(barberHead) )
		{
			( ( CHeadManagerComponent ) acs[0] ).SetCustomHead( barberHead );
		}
		else
		{
			( ( CHeadManagerComponent ) acs[0] ).RemoveCustomHead();
		}
	}
	else
	{
		thePlayer.ClearRememberedCustomHead();
		( ( CHeadManagerComponent ) acs[0] ).RemoveCustomHead();
	}
}

exec function mimictest( optional animName : name )
{
	var acs : array< CComponent >;
	
	if ( animName == '' )
		animName = 'normal_blend_test_face';
		
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	( ( CHeadManagerComponent ) acs[0] ).MimicTest( animName );
}

exec function headname()
{
	var acs : array< CComponent >;
	var head : name;
	
	acs = thePlayer.GetComponentsByClassName( 'CHeadManagerComponent' );
	head = ( ( CHeadManagerComponent ) acs[0] ).GetCurHeadName();
	LogChannel( 'head', head );
}