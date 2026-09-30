/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CRagdoll extends CResource {
    import var windScaler: Float;
    import var densityScaler: Float;
    import var autoStopDelay: Float;
    import var autoStopTime: Float;
    import var autoStopSpeed: Float;
    import var resetDampingAfterStop: Bool;
    import var forceWakeUpOnAttach: Bool;
    import var customDynamicGroup: CPhysicalCollision;
    import var disableConstrainsTwistAxis: Bool;
    import var disableConstrainsSwing1Axis: Bool;
    import var disableConstrainsSwing2Axis: Bool;
    import var jointBounce: Float;
    import var modifyTwistLower: Float;
    import var modifyTwistUpper: Float;
    import var modifySwingY: Float;
    import var modifySwingZ: Float;
    import var projectionIterations: Int32;
}

import struct SSkeletonBone {
    
    import var nameAsCName: CName;
    
}

import struct SSkeletonTrack {
    
    import var nameAsCName: CName;
}

import class CSkeleton extends CResource {
    import var lodBoneNum_1: Int32;
    import var walkSpeed: Float;
    import var slowRunSpeed: Float;
    import var fastRunSpeed: Float;
    import var sprintSpeed: Float;
    import var walkSpeedRel: Float;
    import var slowRunSpeedRel: Float;
    import var fastRunSpeedRel: Float;
    import var sprintSpeedRel: Float;
    
    
    
    
    
    
    
    import var lastNonStreamableBoneName: CName;
    import var bones: array<SSkeletonBone>;
    import var tracks: array<SSkeletonTrack>;
    import var parentIndices: array<Int16>;
}

import class CExtAnimEventsFile extends CResource {
    import var requiredSfxTag: CName;
}

import class CSkeletalAnimationSet extends CExtAnimEventsFile {
    
    import var extAnimEvents: array<CExtAnimEventsFile>;
    import var skeleton: CSkeleton;
    
    
    
}

import class CBehaviorGraph extends CResource {
    
    
    import var sourceDataRemoved: Bool;
    import var customTrackNames: array<CName>;
    import var generateEditorFragments: Bool;
    
    
}

import struct SBehaviorGraphInstanceSlot {
    import var instanceName: CName;
    import var graph: CBehaviorGraph;
    import var alwaysOnTopOfStack: Bool;
}