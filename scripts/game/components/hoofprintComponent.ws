/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SHoofprintState
{
    var boneName : name;
    var isAtGround : bool;
    var activeEntities : array<CEntity>;
}

class W3HoofprintsComponent extends CSelfUpdatingComponent
{
    protected editable var hoofprint : CEntityTemplate;
    protected editable var maxPrintsPerHoof : int;
        default maxPrintsPerHoof = 8;
    protected editable var lifetime : float;
        default lifetime = 5.0f;

    protected var owningActor : CActor;
    private var wasInitialized : bool;
    private var bonesArray : array<name>;
    private var collisionArray : array<name>;
    private var speedThreshold : float;
        default speedThreshold = 0.6f;
    private var hoofprintStates : array<SHoofprintState>;

    private function Initialize()
    {
        var initialState : SHoofprintState;
        var i : int;

        wasInitialized = true;

        bonesArray.PushBack('r_toe2');
        bonesArray.PushBack('l_toe2');
        bonesArray.PushBack('r_thumb2');
        bonesArray.PushBack('l_thumb2');

        collisionArray.PushBack('Terrain');
        owningActor = (CActor)GetEntity();

        for (i = 0; i < bonesArray.Size(); i += 1)
        {
            initialState.boneName = bonesArray[i];
            initialState.isAtGround = true;
            hoofprintStates.PushBack(initialState);
        }
    }

    private function ResetIsAtGround()
    {
        var i : int;

        for (i = 0; i < hoofprintStates.Size(); i += 1)
            hoofprintStates[i].isAtGround = false;
    }

    public function ToggleComponent(isEnabled : bool)
    {
        if (!wasInitialized)
            Initialize();

        if (isEnabled)
            StartTicking();
        else
            StopTicking();
    }

    event OnComponentTick( _Dt : float )
    {
        var i : int;
        var boneIndex : int;
        var hitPos : Vector; 
        var hitNormal : Vector;
        var boneMatrix : Matrix;
        var bonePosition : Vector;
        var traceVector : Vector;
        var boneRotation : EulerAngles;
        var traceOffset : Vector;
        var tempDistance : float;
        var success : bool;
        var currentSpeed : float;

        currentSpeed = VecLength(owningActor.GetMovingAgentComponent().GetVelocity());

        if (currentSpeed < speedThreshold)
        {
            ResetIsAtGround();
            return false;
        }

        for (i = 0; i < bonesArray.Size(); i += 1)
        {
            traceOffset = Vector(0.105f, 0.105f, 0.105f, 1.f);

            boneIndex = owningActor.GetBoneIndex(bonesArray[i]);
            boneMatrix = owningActor.GetBoneWorldMatrixByIndex(boneIndex);
            boneRotation = MatrixGetRotation(boneMatrix);
            bonePosition = MatrixGetTranslation(boneMatrix);
            traceVector = RotRight(boneRotation);

            success = theGame.GetWorld().StaticTrace(bonePosition, bonePosition + (traceVector*traceOffset), hitPos, hitNormal, collisionArray);

            TrySpawningHoofprint(bonesArray[i], success, hitPos, GetOppositeRotation180(boneRotation));
        }
    }

    private function TrySpawningHoofprint(bone : name, newAtGround : bool, hitPos : Vector, boneRotation : EulerAngles)
    {
        var i : int;
        var hoofprintEntity : CEntity;
        var oldestHoofprint : CEntity;

        for (i = 0; i < hoofprintStates.Size(); i += 1)
        {
            if (hoofprintStates[i].boneName == bone && hoofprintStates[i].isAtGround != newAtGround)
            {
                hoofprintStates[i].isAtGround = newAtGround;

                if (newAtGround)
                {
                   hoofprintEntity = theGame.CreateEntity(hoofprint, hitPos, boneRotation);
                   hoofprintEntity.DestroyAfter(lifetime);
                   hoofprintStates[i].activeEntities.Insert(0, hoofprintEntity);

                   if (hoofprintStates[i].activeEntities.Size() > maxPrintsPerHoof)
                   {
                        oldestHoofprint = hoofprintStates[i].activeEntities.Last();

                        if (oldestHoofprint)
                            oldestHoofprint.Destroy();

                        hoofprintStates[i].activeEntities.PopBack();
                   }
                }
            }
        }
    }
}