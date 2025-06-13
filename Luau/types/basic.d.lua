--- Log a message to the console using the default log level.
declare function print(message: any): ()

declare class Vec3
	x: number
	y: number
	z: number
	function __mul (self, rhr: number): Vec3
	function __add (self, rhr: Vec3): Vec3
	function __sub (self, rhr: Vec3): Vec3
	function __div (self, rhr: number): Vec3
	function __unm (self, rhr: Vec3): Vec3
	function __len (self, rhr: Vec3): Vec3

	function __eq (self, rhr: Vec3): boolean
	function __tostring (self): string


	--- Dot product of two vectors
	function dot (self, rhr: Vec3): number
	--- Cross product of two vectors
	function cross (self, rhr: Vec3): Vec3

	--- Project self onto rhr
	function projectOnTo (self, rhr: Vec3): Vec3
	--- Magnitude of the vector
	function length (self): number
	--- Squared magnitude of the vector
	function squaredLength (self): number
	--- Creates a unit vector of length 1
	function normalize (self): Vec3
	--- Returns a unit length copy of the vector
	function getSafeNormal (self): Vec3
	--- Linearly interpolate between self and other by 0 <= t <= 1
	function lerp(self, other: Vec3, t: number): Vec3
	--- Distance between self and other
	function distance(self, other: Vec3): number
	
end

declare Vec3: {
	--- Construct a new vector (x,y,z)
	new: (x:number, y: number, z: number) -> Vec3,
	--- Calculate the dot product of two vectors.
	dot: (lhs: Vec3, rhs: Vec3) -> number,
	--- Calculate the cross product of two vectors.
	cross: (lhs: Vec3, rhs: Vec3) -> Vec3,
	--- Linearly interpolate between a and b by 0 <= t <= 1
	lerp: (a: Vec3, b: Vec3, t: number) -> Vec3,
	distance: (a: Vec3, b: Vec3) -> number,
	rotate: (a: Vec3, b: Quat) -> Vec3,
	--- Checks component-wise equality with a tolerance value, 0.0001 used if not specified
	nearlyEqual: (a: Vec3, b: Vec3, t: number) -> boolean,
}

declare class Quat
	x: number
	y: number
	z: number
	w: number
	function __mul (self, rhr: Quat): Quat
	function __eq (self, rhr: Quat): boolean
	function __tostring (self): string

	--- Convert a Quaternion into floating-point Euler angles (in degrees).
	function euler (self): Vec3
	--- Get the up direction (Y axis) after it has been rotated by this Quaternion.
	function getUpVector (self): Vec3
end

--- Quaternions
declare Quat: {
	--- Construct a new quaternion (x,y,z,w)
	new: (x: number, y: number, z: number, w: number) -> Quat,
	--- Convert a (roll, pitch, yaw) to a quaternion
	fromEuler: (roll: number, pitch: number, yaw: number) -> Quat,
	--- Create a quaternion from a foward direction, with global up as the reference up
	fromDirection: (direction: Vec3) -> Quat,
}

declare InRoom: boolean

declare function emitEvent(eventName: string, data: {any}) : () -- Emits event to other players only

declare function playSound(idx: number, position: Vec3, vol: number) : () -- Plays a sound at the given position
declare function startVibration(leftHand: boolean, strength: number, duration: number) : ()