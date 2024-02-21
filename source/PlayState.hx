package;

import flixel.ui.FlxVirtualPad;
import js.Browser;
import js.html.SpeechSynthesisUtterance;
import js.html.SpeechSynthesis;
import lime.utils.Float32Array;
import haxe.Http;
import openfl.Assets;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.input.keyboard.FlxKey;
import flixel.FlxCamera;
import flixel.effects.particles.FlxParticle;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.sound.FlxSound;
import haxe.ds.HashMap;
import io.colyseus.error.MatchMakeError;
import io.colyseus.Room;
import io.colyseus.Client;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;
import flixel.FlxState;

class PlayState extends FlxState
{
	var plr:Player = new Player(120,120);
	var bg:FlxSprite;
	var gamePaused:Bool = false;
	var title:FlxText = new FlxText(0,0,0,"", 128);
	var tooltip:FlxSprite = new FlxSprite(0,-284, AssetPaths.movetip__png);
	var client = new Client("wss://ws.agmas.org/");
	var host:String = "";
	var isit = false;
	var otherPlayers:FlxTypedGroup<NetPlayer> = new FlxTypedGroup();
	var otherAddlongs:FlxGroup = new FlxGroup();
	var curmessage:FlxText = new FlxText(20, FlxG.height-35, 640, "Press Enter To Chat", 16);
	public static var roome:Room<MyRoomState> = null;
	public static var ischatting:Bool = false;
	var playernames:Array<String> = [];
	var hintText:FlxText = new FlxText(0,40,0,"Connecting...", 24);

	var map:FlxOgmo3Loader;
	var point:FlxPoint;
	var corruptionout:Map<Int, FlxPoint> = new Map();
	var corruptions:FlxSpriteGroup = new FlxSpriteGroup();
	var nwc:FlxSpriteGroup = new FlxSpriteGroup();
	var decorations:FlxSpriteGroup = new FlxSpriteGroup();
	var ammo:Int = 0;
	var cmbg:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
	var walls:FlxTilemap;
	var state:Int = 0;
	var time:Int = 0;
	var gamecam:FlxCamera = new FlxCamera();
	var chatcam:FlxCamera;
	var chat:FlxText;
	public static var plrx:Float = 0;
	public static var plry:Float = 0;

	var tabcam:FlxCamera;
	var tab:FlxText;
	var black:FlxSprite = new FlxSprite();
	var mic:Microphone;
	var pad:FlxVirtualPad = new FlxVirtualPad(FlxDPadMode.FULL, FlxActionMode.A_B);


	override public function create()
	{
		
		new FlxTimer().start(1, (tmr) -> {
			mic = Microphone.getMicrophone(-1);
		});
		bg = new FlxSprite(0,-32,AssetPaths.game_bg_22_001_uhd__png);
		bg.scale.set(2,2);
		bg.scrollFactor.set(0.25,0.25);
		add(bg);
		trace(FlxColor.RED.toHexString());
		bg.color = FlxColor.GRAY;
		roome = null;
		FlxG.autoPause = false;
		map = new FlxOgmo3Loader(AssetPaths.maps__ogmo, AssetPaths.lvl1t__json);
		walls = map.loadTilemap(AssetPaths.tilesDBG__png, "walls");
		walls.setTileProperties(16, NONE);
		walls.follow();
		add(title);
		add(walls);
		walls.immovable = true;
		add(otherPlayers);
		add(otherAddlongs);
		add(plr);
		FlxG.camera.follow(plr);
		plr.scale.set(1, 1);
		plr.angle = 0;
		add(plr.staminaBar);
		add(plr.particles);
		map.loadEntities(placeEntities, "entities");
		tooltip.scrollFactor.set(0,0);
		add(tooltip);
		hintText.scrollFactor.set(0,0);
		add(hintText);
		title.scrollFactor.set(0,0);
		
		title.alpha = 0;
		chat = new FlxText(0, 0, 640, "Joining Room", 16);
		chatcam = new FlxCamera(20, FlxG.height-(290), 640, 256);
		chatcam.bgColor.alphaFloat = 0.5;
		chat.camera = chatcam;
		add(chat);

		tab = new FlxText(0, 0, 640, "", 32);
		tabcam = new FlxCamera(0,0, 0, 0);
		tabcam.bgColor.alphaFloat = 0.5;
		tab.camera = tabcam;
		add(tab);

		curmessage.scrollFactor.set(0,0);
		add(curmessage);
		cmbg.alpha = 0.5;
		cmbg.scrollFactor.set(0,0);
		add(cmbg);
		add(corruptions);
		add(decorations);
		add(nwc);
		FlxG.cameras.add(chatcam, false);
		FlxG.cameras.add(tabcam, false);
		ischatting = false;
		chatcam.setScrollBounds(0, null, 0, null);
		FlxTween.tween(tooltip, {y: 0}, 1.5, {ease: FlxEase.bounceOut});
		new FlxTimer().start(0.0166666667, function(tmr:FlxTimer)
			{
				if (plr.stamina != 100)
					{
						plr.stamina += 3 + plr.SPEED / 1000;
					}
					if (plr.SUPERSPEEEED > 0)
					{
						plr.SUPERSPEEEED -= 1;
					}
					if (plr.SPEED < 350)
					{
						plr.stamina = 0;
						plr.SPEED += 40;
					}
					plr.particleEmitDelay -= 100 * (plr.SUPERSPEEEED / 100);
					if (plr.SUPERSPEEEED >= 1 && plr.particleEmitDelay <= 0)
					{
						plr.particleEmitDelay = 100;
						plr.particles.color.set(plr.color);
						plr.particles.alpha.set(plr.SUPERSPEEEED / 100, plr.SUPERSPEEEED / 100, 0, 0);
						plr.particles.start(true, 0.0005, 1);
					}
		}, 0);
		if (NameState.tojoin == null)
			{
				client.create("myRoom", ["roomName" => NameState.tocreate], MyRoomState, function(err, room)
				{
					roome = room;
					epic(err, room);
				});
			}
			else
			{
				if (NameState.tojoin == "quick") {
					client.joinOrCreate("myRoom", [], MyRoomState, function(err, room)
						{
							roome = room;
							epic(err, room);
						});
				} else {
				client.joinById(NameState.tojoin, [], MyRoomState, function(err, room)
				{
					roome = room;
					epic(err, room);
				});
			}
			}
		//pad.scrollFactor.set(0,0);
		//add(pad);
		super.create();
	}
	function epic(err:MatchMakeError, room:Room<MyRoomState>)
		{
			roome = room;				
			if (err != null)
			{
				trace("JOIN ERROR: " + err);
				hintText.text = err.message;
				return;
			}
			room.send("name", NameState.playerName.substr(0, 24));
			hintText.text = "Connected! Waiting for host...";
			new FlxTimer().start(0.0016, (tmr) -> {
				room.send("pos", {x: plr.x, y: plr.y, angle: plr.angle, color: plr.color.toHexString(), sspeed: plr.SUPERSPEEEED});
			}, 0);
			room.state.listen("time", (c,p) -> {
				time = c;
			});
			room.state.listen("state", (c,p) -> {
				if (c == 0) {
					title.alpha = 1;
					if (state == 1) {
						title.text = "GAME END!";
						title.color = FlxColor.ORANGE;
						new FlxTimer().start(2, (tmr) -> {
							FlxTween.tween(title, {alpha: 0, "scale.x": 1, "scale.y":1}, 2.5, {ease: FlxEase.expoOut});
						});
					}
				} 
				state = c;
				if (state == 1) {
					FlxTween.globalManager.cancelTweensOf(title);
					FlxTween.tween(title, {alpha: 0.1, "scale.x": 1.5, "scale.y":1.5}, 5, {ease: FlxEase.expoOut});
				}
			});
			room.onMessage("effectDash", function(x) {
				for (oplr in otherPlayers) {
					if (oplr.key == x.sessionId) {
						oplr.particles.alpha.set(1, 1, 0, 0);
						oplr.particles.color.set(FlxColor.fromRGB(0, 183, 233));
						oplr.particles.start(true, 0.01, 4);
					}
				}
			});
			room.state.listen("hostkey", (c,p) -> {
				if (c==room.sessionId) {
					host = c;
					hintText.text = "You are the host! Press [X] to begin.";
				}
			});
			room.onMessage("loadMap", function(x) {
				loadNewMap(x.url);
			});
			room.onMessage("startGame", function(x) {
				title.alpha = 1;
				title.scale.set(1,1);
				title.color = FlxColor.LIME;
				title.text = "3";
				FlxG.camera.shake(0.0025, 1, null, true);
				FlxTween.tween(FlxG.camera, {alpha:1, zoom: 1.25}, 1, {ease: FlxEase.expoOut, onComplete: (twn) -> {
					title.color = FlxColor.ORANGE;
					title.text = "2";
					FlxG.camera.shake(0.005, 1, null, true);
					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 1, {ease: FlxEase.expoOut, onComplete: (twn2) -> {
						title.color = FlxColor.RED;
						title.text = "1";
						FlxG.camera.shake(0.025, 1, null, true);
						FlxTween.tween(FlxG.camera, {zoom: 1.75}, 1, {ease: FlxEase.expoOut, onComplete: (twn3) -> {
							FlxG.camera.shake(0.005, 1.25, null, true);
							FlxTween.tween(FlxG.camera, {zoom: 1}, 0.25);
						}});
					}});
				}});
			});
			room.onMessage("chatm", function(x)
				{
					chat.text += "\n[" + x.plr + "] " + x.msg;
					
					for (oplr in otherPlayers) {
						if (oplr.key == x.id) {
							oplr.utter.text = x.msg;
							oplr.utter.pitch = oplr.pitch;
							oplr.utter.voice = oplr.ss.getVoices()[oplr.voice];
							var distance = calculateDistance(PlayState.plrx, PlayState.plry,oplr.x,oplr.y);
        					var maxDistance = 1000.0; // Adjust this value based on your scene scale
        					var volume = 1.0 - (distance / maxDistance); // Invert volume based on distance	
        					if (oplr.utter.volume != volume) {
            					oplr.utter.volume = volume;
        					}
							oplr.ss.speak(oplr.utter);
							oplr.ss.resume();
						}
					}
					
					if (chat.textField.height > chatcam.height)
					{
						chatcam.scroll.y = chat.textField.textHeight - 256;
					}
				});
				room.onMessage("chatms", function(x)
				{
					chat.text += "\n" + x.msg;
					if (chat.textField.height > chatcam.height)
					{
						chatcam.scroll.y = chat.textField.textHeight - 256;
					}
				});
				room.onMessage("voiceChat", function(x)
					{
						if (x.sessionId == roome.sessionId) {
							return;
						}
						 // Convert string to array of numbers
						 var s:String = x.input;
						 var dataArray:Array<String> = s.split(",");
						 var floatArray:Array<Float> = dataArray.map(Std.parseFloat);
						 
						 // Convert array of numbers to Float32Array
						 var float32Array:Float32Array = new Float32Array(floatArray);
						var distance = calculateDistance(plr.x, plr.y,x.x,x.y);
              		  	var maxDistance = 1000.0; // Adjust this value based on your scene scale
                		var volume = 1.0 - (distance / maxDistance); // Invert volume based on distance	
						for (oplr in otherPlayers) {
							if (oplr.key == x.sessionId) {
								mic.playAudio(float32Array, volume, oplr.source, x.x, x.y);
							}
						}
					});
			room.state.players.onAdd(function(item:OtherPlayer, key:String)
				{
					trace("New player!");
					if (key != roome.sessionId)
					{
						var oplr:NetPlayer = new NetPlayer(item.x, item.y);
						oplr.key = item.key;
						otherPlayers.add(oplr);
						otherAddlongs.add(oplr.emitter);
						otherAddlongs.add(oplr.particles);
						var playerNm:FlxText = new FlxText(0, 0, 0, "", 16);
						playerNm.text = item.pname;
						playerNm.alpha = 0.5;
						playernames.push(playerNm.text + "\n");
						otherAddlongs.add(playerNm);
						var plnm:String = "?";

						item.listen("pname", function(cur, prev)
						{
							playernames.remove(playerNm.text + "\n");
							playerNm.text = cur;
							plnm = cur;
							playernames.push(playerNm.text + "\n");
						});
						item.onRemove(() -> {
							playernames.remove(playerNm.text + "\n");
							remove(playerNm);
							playerNm.destroy();
							remove(oplr);
							oplr.destroy();
						});
						item.listen("x", (c, p) -> {
							var xsixteen:Int = c;
							FlxTween.tween(oplr, {x: c}, 0.075);
							FlxTween.tween(playerNm, {x: xsixteen + (oplr.width - playerNm.width) / 2}, 0.025);
						});
						item.listen("angle", (c, p) -> {
							FlxTween.tween(oplr, {angle: c}, 0.05);
						});
						item.listen("sspeed", (c, p) -> {
							oplr.sspeed = c;
						});
						item.listen("color", (c, p) -> {
							if (c == FlxColor.LIME.toHexString()) {
								c = FlxColor.BLUE.toHexString();
							}
							oplr.color = FlxColor.fromString(c);
						});
						item.listen("y", (c, p) -> {
							var xsixteen:Int = c;
							var xsixteen2:Int = c;
							FlxTween.tween(oplr, {y: c}, 0.05);
							FlxTween.tween(playerNm, {y: xsixteen2 - 32}, 0.05);
						});
					} else {
						playernames.push(NameState.playerName + "\n");
						item.listen("isIT", (c, p) -> {
							isit = c;
							if (c) {
								FlxG.camera.flash(FlxColor.RED, 0.25);
							} else {
								FlxG.camera.flash(FlxColor.BLUE, 0.25);
							}
						});
					}
				});
		}

		function calculateDistance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
			var dx = x2 - x1;
			var dy = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
	public function loadNewMap(mapURL:String) {
		trace("LOAD: " + mapURL);
		gamePaused = true;
		new FlxTimer().start(1.5, (tmr) -> {
			walls.destroy();
		map = new FlxOgmo3Loader(AssetPaths.maps__ogmo, "assets/data/" + mapURL + ".json");
		walls = map.loadTilemap(AssetPaths.tilesDBG__png, "walls");
		walls.setTileProperties(16, NONE);
		walls.follow();
		add(walls);
		walls.immovable = true;
		for (i in corruptionout) {
			i.destroy();
		}
		corruptionout.clear();
		for (i in corruptions) {
			i.destroy();
		}
		corruptions.clear();
		map.loadEntities(placeEntities, "entities");
		gamePaused = false;
		});
		
	}

	public function shootParticle(emitter:FlxEmitter, dir:Float) {
		emitter.launchAngle.set(dir, dir);
		emitter.angle.set(dir, dir, dir, dir);
		emitter.emitParticle();
	}

	override function tryUpdate(elapsed:Float) {
		if (!gamePaused) {
			super.tryUpdate(elapsed);
		}
	}

	override public function update(elapsed:Float)
	{
		plrx = plr.x;
		plry = plr.y;
		if (FlxG.keys.justPressed.L) {
			mic.bitrate++;
		}
		tabcam.visible = FlxG.keys.pressed.TAB;
		tab.text = "Player List\n";
		tab.alignment = FlxTextAlign.JUSTIFY;
		for (nm in playernames) {
			tab.text += nm;
		}
		tabcam.width = Math.round(tab.textField.textWidth);
		tabcam.height = Math.round(tab.textField.textHeight);
		tabcam.x = Math.round((FlxG.width/2)-(tabcam.width/2));
		tabcam.y = 30;
		if (!FlxG.worldBounds.containsPoint(plr.getPosition())) {
			plr.setPosition(point.x, point.y);
			plr.SPEED = 250;
			FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
		}
		if (FlxG.overlap(plr, nwc))
			{
				plr.wallclimb = false;
			}
			else
			{
				plr.wallclimb = true;
			}
		chatcam.scroll.y -= FlxG.mouse.wheel / 24;
		cmbg.scale.set(curmessage.textField.width, curmessage.textField.textHeight);
		cmbg.updateHitbox();
		cmbg.x = curmessage.x;
		cmbg.y = curmessage.y;
		if (FlxG.keys.pressed.ESCAPE) {
			ischatting = false;
		}
		FlxG.collide(plr, corruptions, function(plr, cor)
			{
				var point:FlxPoint = corruptionout.get(cor.health);
				var lastvel = plr.velocity;
				plr.setPosition(point.x, point.y);
				plr.velocity.set(lastvel.x, lastvel.y);
			});
		chatHandler();
		chatcam.scroll.y -= FlxG.mouse.wheel / 24;
		if (curmessage.text == "")
		{
			curmessage.visible = false;
		}
		else
		{
			curmessage.visible = true;
		}
		title.screenCenter();
		
		if (state == 1) {
			hintText.text = "Time Left: " + Math.floor(time/60);
			if (host == roome.sessionId) 
			{
				FlxG.overlap(otherPlayers, (op1:NetPlayer, op2:NetPlayer) -> {
					roome.send("collision", {one: op1.key, two: op2.key});
				});
				FlxG.overlap(otherPlayers, plr, (op1:NetPlayer, op2) -> {
					roome.send("collision", {one: op1.key, two: roome.sessionId});
				});
				FlxG.overlap(otherPlayers, plr, (op1:NetPlayer, op2) -> {
					roome.send("collision", {one: roome.sessionId, two: op1.key});
				});
			}
			if (isit) {
				title.color = FlxColor.RED;
				title.text = "HUNTER";
			} else {
				title.color = FlxColor.BLUE;
				title.text = "RUNNER";
			}
		}
		
		if (state == 0) {
			if (roome != null) {
			if (host==roome.sessionId) {
				hintText.text = "You are the host! Press [X] to begin.";
			} else {
				hintText.text = "Waiting for host...";
			}
			}
			if (FlxG.keys.justPressed.X) {
				roome.send("startGame");
			}
		}
		hintText.screenCenter(X);
		if (FlxG.keys.justPressed.SPACE) {
			FlxTween.tween(tooltip, {alpha: 0}, 1);
		}
		super.update(elapsed);
		
		var collistrue:Bool = FlxG.collide(plr, walls);
		
	}

	function placeEntities(entity:EntityData)
		{
			if (entity.name == "player")
			{
				plr.setPosition(entity.x, entity.y);
				point = plr.getPosition();
			}
			if (entity.name == "nowallclimb")
			{
				var nowallc:FlxSprite = new FlxSprite(entity.x, entity.y);
				nowallc.makeGraphic(entity.width, entity.height, FlxColor.RED);
				nowallc.alpha = 0.25;
				nwc.add(nowallc);
			}
			if (entity.name == "Corruption")
			{
				var nowallc:FlxSprite = new FlxSprite(entity.x, entity.y, AssetPaths.corrupt__png);
				nowallc.health = Reflect.field(entity.values, "a");
				corruptions.add(nowallc);
				FlxTween.tween(nowallc, {angle: 360}, 1.5, {type: LOOPING, ease: FlxEase.sineInOut});
				nowallc.immovable = true;
			}
			if (entity.name == "CorruptTeleportEnd")
			{
				var portal:FlxSprite = new FlxSprite(entity.x, entity.y, AssetPaths.portal__png);
				FlxTween.tween(portal, {"scale.x": 1.25, "scale.y": 1.25}, 3, {type: PINGPONG, ease: FlxEase.bounceInOut});
				decorations.add(portal);
				corruptionout.set(Reflect.field(entity.values, "a"), new FlxPoint(entity.x, entity.y));
			}
		}

	function chatHandler() {
		if (ischatting)
			{
				chat.alpha = 1;
				curmessage.alpha = 1;
				curmessage.color = FlxColor.YELLOW;
				if (curmessage.text == "Press Enter To Chat")
				{
					curmessage.text = "";
				}
				if (FlxG.keys.justPressed.BACKSPACE)
				{
					curmessage.text = curmessage.text.substr(0, curmessage.text.length - 1);
					if (curmessage.text == "")
					{
						curmessage.text = "";
					}
				}
				if (FlxG.keys.firstJustPressed() >= 65 && FlxG.keys.firstJustPressed() <= 90)
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						curmessage.text += FlxKey.toStringMap.get(FlxG.keys.firstJustPressed());
					}
					else
					{
						curmessage.text += FlxKey.toStringMap.get(FlxG.keys.firstJustPressed()).toLowerCase();
					}
				}
				if (FlxG.keys.firstJustPressed() == 32)
				{
					curmessage.text += " ";
				}
				if (FlxG.keys.firstJustPressed() >= 48 && FlxG.keys.firstJustPressed() <= 57)
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						var map2:Map<Int, String> = [
							49 => "!", 50 => "@", 51 => "#", 52 => "$", 53 => "%", 54 => "^", 55 => "&", 56 => "*", 57 => "(", 48 => ")"
						];
						if (map2.exists(FlxG.keys.firstJustPressed()))
						{
							curmessage.text += map2.get(FlxG.keys.firstJustPressed());
						}
					}
					else
					{
						curmessage.text += FlxG.keys.firstJustPressed() - 48;
					}
				}
				if (FlxG.keys.pressed.SHIFT)
				{
					var map:Map<Int, String> = [
						186 => ":", 187 => "+", 188 => "<", 189 => "_", 190 => ">", 191 => "?", 192 => "~", 219 => "{", 221 => "}", 222 => "\""
					];
					if (map.exists(FlxG.keys.firstJustPressed()))
					{
						curmessage.text += map.get(FlxG.keys.firstJustPressed());
					}
				}
				else
				{
					var map:Map<Int, String> = [
						186 => ";", 187 => "=", 188 => ",", 189 => "-", 190 => ".", 191 => "/", 192 => "`", 219 => "[", 221 => "]", 222 => "\'"
					];
					if (map.exists(FlxG.keys.firstJustPressed()))
					{
						curmessage.text += map.get(FlxG.keys.firstJustPressed());
					}
				}
			}
			else
			{
				curmessage.color = FlxColor.WHITE;
				curmessage.alpha = 0.5;
				chat.alpha = 0.85;
			}
			if (FlxG.keys.justPressed.ENTER && FlxG.state.subState == null)
			{
				if (ischatting)
				{
					if (curmessage.text != "")
						roome.send("chat", {msg: curmessage.text});
					ischatting = false;
				}
				else
				{
					ischatting = true;
					curmessage.text = "";
				}
			}
	
			if (!ischatting)
			{
				curmessage.text = "Press Enter To Chat";
			}
	}
}
