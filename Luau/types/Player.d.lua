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