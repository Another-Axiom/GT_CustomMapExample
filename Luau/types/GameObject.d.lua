declare class GameObject
	position: Vec3
	rotation: Quat
	scale: Vec3
	function setCollision (self, enabled: boolean): nil
	function setVisibility (self, enabled: boolean): nil 
end

declare GameObject: {
	--- Find a GameObject using its name
	findGameObject: (name: string) -> GameObject,
}
