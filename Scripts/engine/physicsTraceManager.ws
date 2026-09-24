/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SScriptRaycastId {}

import struct SScriptSweepId {}

import struct SRaycastHitResult
{
	import var position		: Vector;
	import var normal		: Vector;
	import var distance		: float;
	import var component	: CComponent;
}

import struct SSweepHitResult
{
	import var position		: Vector;
	import var normal		: Vector;
	import var distance		: float;
	import var component	: CComponent;
}

import class CScriptBatchQueryAccessor
{
	
	
	
	import final latent function RayCast( start : Vector, end : Vector, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	import final latent function RayCastDir( start : Vector, direction : Vector, distance : float, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	
	import final function RayCastSync( start : Vector, end : Vector, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name> ) : bool;
	import final function RayCastDirSync( start : Vector, direction : Vector, distance : float, out result : array<SRaycastHitResult>, optional collisionGroupsNames : array<name> ) : bool;
	
	import final function RayCastAsync( start : Vector, end : Vector, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptRaycastId;
	import final function RayCastDirAsync( start : Vector, direction : Vector, distance : float, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptRaycastId;
	
	import final function GetRayCastState( queryId : SScriptRaycastId, out result : array<SRaycastHitResult> ) : EBatchQueryState;
	
	import final latent function Sweep( start, end : Vector, radius : float, out result : array<SSweepHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	import final latent function SweepDir( start, direction : Vector, radius, distance : float, out result : array<SSweepHitResult>, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : bool;
	
	import final function SweepAsync( start, end : Vector, radius : float, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptSweepId;
	import final function SweepDirAsync( start, direction : Vector, radius, distance : float, optional collisionGroupsNames : array<name>, optional queryFlags : int ) : SScriptSweepId;
	
	import final function GetSweepState( queryId : SScriptSweepId, out result : array<SSweepHitResult> ) : EBatchQueryState;
}