declare class Player -- Read only except for playerMaterial
    playerID : number -- Actor Number
    playerName : string -- Name when they join the room
    playerMaterial : number -- Used to show things like tag state, frozen, lava monkey etc.
    isMasterClient : boolean -- True when they are the master client
    bodyPosition : Vec3
    leftHandPosition : Vec3
    rightHandPosition : Vec3
    leftHandRotation : Quat
    rightHandRotation : Quat
    headRotation : Quat
    isInVStump : boolean
    isEntityAuthority : boolean
end


declare class PSettings
    maxJumpSpeed : number -- Between 0 and 100
    jumpMultiplier : number -- Between 0 and 100
end

declare PSettings : {

}

declare Player : {
    getPlayerByID : (id: string) -> Player
}

declare Players : {Player}
declare LocalPlayer : Player

declare PlayerSettings : PSettings

declare class PInput
    leftXAxis : number
    rightXAxis : number
    leftYAxis : number
    rightYAxis : number
    leftTrigger : number
    rightTrigger : number
    leftGrip : number
    rightGrip : number
    leftPrimaryButton : boolean
    rightPrimaryButton : boolean
    leftSecondaryButton : boolean
    rightSecondaryButton : boolean
end

declare PlayerInput : PInput