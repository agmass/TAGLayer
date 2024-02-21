// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.26
// 


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class OtherPlayer extends Schema {
	@:type("number")
	public var x: Dynamic = 0;

	@:type("number")
	public var y: Dynamic = 0;

	@:type("number")
	public var sspeed: Dynamic = 0;

	@:type("number")
	public var angle: Dynamic = 0;

	@:type("string")
	public var color: String = "";

	@:type("boolean")
	public var isIT: Bool = false;

	@:type("string")
	public var pname: String = "";

	@:type("string")
	public var key: String = "";

}
