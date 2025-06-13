declare class AIAgent -- Read only
    entityID : number 
    agentPosition : Vec3
    agentRotation : Quat

    function __toString (self) : string
    function setDestination (self, destination: Vec3)
    function destroyAgent (self)
    function playAgentAnimation (self, animationStateName: string)
end

declare AIAgent : {
    getAIAgentByEntityID : (id: number) -> AIAgent,
    findPrePlacedAIAgentByID : (id: number) -> AIAgent,
    spawnAIAgent : (agentTypeID: number, position: Vec3, rotation: Quat) -> AIAgent,
}

declare AIAgents : {AIAgent}
