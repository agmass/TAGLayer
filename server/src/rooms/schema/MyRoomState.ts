import { Schema, Context, type, MapSchema } from "@colyseus/schema";

export class Enemy extends Schema {
  @type("number") x: number;
  @type("number") y: number;
}

export class OtherPlayer extends Schema {
  @type("number") x: number;
  @type("number") y: number;
  @type("number") sspeed: number;
  @type("number") angle: number;
  @type("string") color: string;
  @type("boolean") isIT: boolean;
  @type("string") pname: string;
  @type("string") key:string;
}

export class MyRoomState extends Schema {
  
  @type({ map: OtherPlayer }) players = new MapSchema<OtherPlayer>();
  @type({ map: Enemy }) enemies = new MapSchema<Enemy>();
  @type("number") state:number = 0;
  @type("number") mode:number = 0;
  @type("number") ITInvul:number = 60*3;
  @type("number") time:number = 0;
  @type("string") hostDisplayName:string;
  @type("string") hostkey:string = "HOST_NEEDED";

}
