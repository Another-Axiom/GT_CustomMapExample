declare class GameObject
	position: Vec3
	rotation: Quat
	scale: Vec3
	function setCollision (self, enabled: boolean): nil
	function setVisibility (self, enabled: boolean): nil 
	function setActive (self, enabled: boolean): nil
	function setText (self, text: string): nil 
	function onTouched (self, callback: ()->nil) : nil
	function getVelocity (self) : Vec3
	function setVelocity (self, velocity: Vec3) : nil
	function setColor (self, color: Vec3) : nil -- rgb
	function clone (self) : GameObject
	function findChild (self, name: string) : GameObject
	function destroy (self) : nil
	function findComponent (self, component: string) : any
end

declare GameObject: {
	--- Find a GameObject using its name
	findGameObject: (name: string) -> GameObject,
}

declare class rayHit
	distance : number
	point : Vec3
	normal : Vec3
	object : GameObject -- Can Be nil
	player : Player -- Can Be nil
end

declare function rayCast(position: Vec3, direction: Vec3) : rayHit -- Can Be nil

declare class ParticleSystem
	function play(self) : nil
	function stop(self) : nil
	function clear(self) : nil

end

declare class AudioSource
	function play(self) : nil
	function setVolume(self, volume: number) : nil
	function setLoop(self, loop: boolean) : nil
	function setPitch(self, pitch: number) : nil
	function setMinDistance(self, distance: number) : nil
	function setMaxDistance(self, distance: number) : nil
end

declare class Light
	function setColor(self, color: Vec3) : nil
	function setIntensity(self, intensity: number) : nil
	function setRange(self, distance: number) : nil
end

declare class Animator
	function setSpeed(self, speed: number) : nil
	function startPlayback(self) : nil
	function stopPlayback(self) : nil
	function reset(self) : nil
end