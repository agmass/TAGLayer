import { Room, Client } from "@colyseus/core";
import { MyRoomState, OtherPlayer } from "./schema/MyRoomState";

export class MyRoom extends Room<MyRoomState> {
  maxClients = 16;

  onCreate (options: any) {
    this.setState(new MyRoomState());
    console.log(options);
        if(options["h"]["roomName"] != null || options["h"]["roomName"] != "null" || options["h"]["roomName"] != undefined) {
          this.setMetadata({ roomNam: options["h"]["roomName"] });
        } else {
          this.setMetadata({ roomNam: "Unnamed Room" });
        }
    this.onMessage("dash", (client, x) => {
      this.broadcast("effectDash", client);
    });
    this.onMessage("startGame", (client, x) => {
      if (client.sessionId == this.state.hostkey) {
      this.broadcast("startGame", client);
      this.state.players.forEach((op, k) => {
        op.isIT = false;
      });
      let keys = Array.from(this.state.players.entries());
      let player = keys[Math.floor(Math.random() * keys.length)];
      player[1].isIT = true;
      setTimeout(() => {
        this.state.time = 60*128//60*(60*3)
        this.state.state = 1;
      }, 3000);
      }
    });

    this.onMessage("proximitychat", (client, x) => {
      const player2 = this.state.players.get(client.sessionId);
      this.broadcast("voiceChat", {x: player2.x, y: player2.y, input: x.toString(), sessionId: client.sessionId});
    });

    this.onMessage("chat", (client, x) => {
      const player2 = this.state.players.get(client.sessionId);
      if (x.msg.toString().startsWith("!")) {
        if (x.msg.toString().startsWith("!loadmap")) {
           this.broadcast("loadMap", {url: x.msg.toString().split(" ")[1]}); 
           this.broadcast("chatms", {msg: "Loading new map from URL..."})
        }
        switch(x.msg) {
          case "!host":
            client.send("chatms", {msg: "The current host is " + this.state.players.get(this.state.hostkey).pname})
            break;
          case "!id":
            client.send("chatms", {msg: "The room id is " + this.roomId})
            break;
          case "!infection":
            this.state.mode == 1;
            this.broadcast("chatms", {msg: "Infection mode enabled!"})
            break;
          case "!tag":
            this.state.mode == 0;
            this.broadcast("chatms", {msg: "Tag mode enabled!"})
            break;
          case "!help":
            client.send("chatms", {msg: "GAMEMODES: !infection, !tag MISC: !id, !host, !help"})
            break;
          default:
            client.send("chatms", {msg: "Invalid command."})
        }
        return;
      } 
      this.broadcast("chatm", {plr: player2.pname, msg: x.msg.toString().substring(0, 128), id: client.sessionId});
    }); 

    this.onMessage("name", (client, y) => {
      const player = this.state.players.get(client.sessionId);
        player.pname = y; 
        if (player != null) {
        
        console.log(client.sessionId, "joined! (known as " + this.state.players.get(client.sessionId).pname + ")");
        this.broadcast("chatms", {msg: this.state.players.get(client.sessionId).pname + " joined the room."})
        client.send("chatms", {msg: "Use !help to see commands."})
      } else {
        client.leave();
      }
      player.pname = y; 
    }); 

    this.onMessage("collision", (client, x) => {
      if (this.state.ITInvul <= 0 && this.state.players.get(x.one).isIT) {
        if (this.state.mode == 1) {
        } else {
          this.state.players.get(x.one).isIT = false;
         }
        this.state.players.get(x.two).isIT = true;
        this.state.ITInvul = 60*3;
      }
      if (this.state.ITInvul <= 0 && this.state.players.get(x.two).isIT) {
         if (this.state.mode == 1) {
        } else {
          this.state.players.get(x.two).isIT = false;
         }
        this.state.players.get(x.one).isIT = true;
        this.state.ITInvul = 60*3;
      }
    });

    this.onMessage("pos", (client, x) => {
      const player = this.state.players.get(client.sessionId);
      player.x = x.x;
      player.y = x.y;
      player.angle = x.angle;
      if (player.isIT) {
        player.color = "0xFFFF0000";
      } else {
        player.color = x.color;
      }
      player.sspeed = x.sspeed;
    }); 
    this.setSimulationInterval(() => {
      this.state.time--;
      this.state.ITInvul--;
      if (this.state.time <= 0) {
        if (this.state.state == 1) {
          this.state.state = 0;
          this.state.players.forEach((op, k) => {
            op.isIT = false;
          });
        }
      } else {
        if (this.state.state == 1) {
          let alive = 0;
          this.state.players.forEach((op, k) => {
            if (!op.isIT) {
              alive++;
            }
          });
          if (alive == 0) {
            if (this.state.time >= 70) {
              this.state.time = 60;
            }
          }
        }
      }
      if (this.state.hostkey == null || this.state.players.get(this.state.hostkey) == null) {
        let keys = Array.from(this.state.players.keys());
        console.log(Math.floor(Math.random() * keys.length));
        this.state.hostkey = keys[Math.floor(Math.random() * keys.length)];
        console.log("NEW HOST: " + this.state.hostkey);
        if (this.state.players.get(this.state.hostkey) != undefined) {
          try {
            console.log(this.state.players.get(this.state.hostkey).pname);
            setTimeout(() => {
              if (this.state.players.get(this.state.hostkey) != undefined)
                this.broadcast("chatms", {msg: this.state.players.get(this.state.hostkey).pname + " is the new room host."})
            }, 250);
          } catch {
            this.state.hostkey = null;
          }
        } else {
          this.state.hostkey = null;
        }
    } else {
      this.state.hostDisplayName = this.state.players.get(this.state.hostkey).pname;
    }
  });
  }

  onJoin (client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    const player = new OtherPlayer();
    this.state.players.set(client.sessionId, player);
    player.x = Math.random() * 600;
    player.y = Math.random() * 400;
    player.key = client.sessionId;
  }

  onLeave (client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    this.state.players.delete(client.sessionId); 
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}
