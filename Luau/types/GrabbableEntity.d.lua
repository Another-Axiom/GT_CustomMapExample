declare class GrabbableEntity -- Read only
    entityID : number 
    entityPosition : Vec3
    entityRotation : Quat

    function __toString (self) : string
end

declare GrabbableEntity : {
    findPrePlacedGrabbableEntityByID : (id: number) -> GrabbableEntity,
    getGrabbableEntityByEntityID : (id: number) -> GrabbableEntity,
    getHoldingActorNumberByEntityID : (id: number) -> GrabbableEntity,
    getHoldingActorNumberByLuauID : (id: number) -> GrabbableEntity,
    spawnGrabbableEntity : (entityTypeID: number, position: Vec3, rotation: Quat) -> GrabbableEntity,
}

declare GrabbableEntity : {GrabbableEntity}
