// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.26
// 


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class MyRoomState extends Schema {
	@:type("map", OtherPlayer)
	public var players: MapSchema<OtherPlayer> = new MapSchema<OtherPlayer>();

	@:type("map", Enemy)
	public var enemies: MapSchema<Enemy> = new MapSchema<Enemy>();

	@:type("number")
	public var state: Dynamic = 0;

	@:type("number")
	public var mode: Dynamic = 0;

	@:type("number")
	public var ITInvul: Dynamic = 0;

	@:type("number")
	public var time: Dynamic = 0;

	@:type("string")
	public var hostDisplayName: String = "";

	@:type("string")
	public var hostkey: String = "";

}
