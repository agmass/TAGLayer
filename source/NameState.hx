package;

import js.html.InputElement;
import js.Browser;
import openfl.ui.Keyboard;
import flixel.input.actions.FlxActionInputDigital.FlxActionInputDigitalKeyboard;
import flixel.input.keyboard.FlxKeyboard;
import flixel.util.FlxTimer;
import io.colyseus.Client;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class NameState extends FlxState
{
	public static var playerName:String = "??";
	public static var tojoin:String = null;
	public static var tocreate:String = null;
	var client = new Client("wss://ws.agmas.org/");

	var name:FlxUIInputText;
	var tm:FlxTimer;
	var roomname:FlxUIInputText;
	var createroom:FlxText;
	var version:FlxText = new FlxText(0,0,0,"taglayer v1.0.1",24);
	var news:FlxText = new FlxText(0,0,0,"v1.0.1\n- fixed some crashing (hopefully)\n- added processing and further compression to VC",24);
	var playing:FlxText = new FlxText(0,30,0,"Waiting on server..",8);
	var joinroom:FlxText;
	var joinroom2:FlxText;
	var bg:FlxSprite = new FlxSprite(0,0,AssetPaths.menubg__png);

	override public function create()
	{
		version.scrollFactor.set(0,0);
		news.scrollFactor.set(0,0);
		playing.scrollFactor.set(0,0);
		playing.screenCenter();
		playing.y -= 64+32;
		version.screenCenter();
		version.y -= (64+32)+25;
		news.alignment = FlxTextAlign.CENTER;
		news.scale.set(0.5,0.5);
		news.screenCenter();
		news.color = FlxColor.BLUE;
		news.y += 128;
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
		bg.y = (-bg.height / 2.75) - (FlxG.mouse.y - FlxG.height / 2) / 2;
		bg.screenCenter();
		add(bg);
		name = new FlxUIInputText(0, 0, 256, "Choose a name to play!", 8);
		name.screenCenter();
		name.y -= 32;
		add(name);

		createroom = new FlxText(0, 0, 0, "Host", 16);
		createroom.screenCenter();
		createroom.y += 32;
		add(createroom);

		joinroom = new FlxText(0, 0, 0, "Join", 16);
		joinroom.screenCenter();
		joinroom.y += 64;
		add(joinroom);

		joinroom2 = new FlxText(0, 0, 0, "Quickplay", 16);
		joinroom2.color = FlxColor.BLUE;
		joinroom2.screenCenter();
		add(joinroom2);

		roomname = new FlxUIInputText(0, 0, 256, "Room Name", 8);
		roomname.screenCenter();
		roomname.y -= 64;
		add(roomname);
		add(playing);
		add(version);
		add(news);
		super.create();
		FlxG.camera.zoom = 2;
		tm = new FlxTimer().start(0.5, function helo(tmr)
			{
				client.getAvailableRooms("myRoom", function(err, rooms)
				{
					if (err != null)
					{
						trace(err);
						return;
					}
					var playertally:Int = 0;
					for (room in rooms)
					{
						playertally += room.clients;
					}
					playing.color = FlxColor.PINK;
					playing.screenCenter(X);
					playing.text = rooms.length + " public room(s) with " + playertally + " player(s)";
				});
			} #if html5, 0 #end);
			version.color = FlxColor.PINK;
	
	
	}

	override public function destroy() {
		tm.cancel();
		super.destroy();
	}

	override public function update(elapsed:Float)
	{
		FlxTween.tween(bg, {y: (-bg.height / 2.75) - (FlxG.mouse.y - FlxG.height / 2) / 8}, 0.075);
		bg.alpha = 0.5;
		FlxG.autoPause = false;
		createroom.scale.set(0.75, 0.75);
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(name)) {
			name.text = "";
		}
		
		createroom.color = FlxColor.WHITE;
		if (FlxG.mouse.overlaps(createroom))
		{
			if (name.text != "Choose a name to play!") {
			createroom.scale.set(1, 1);
			createroom.color = FlxColor.YELLOW;
			playerName = name.text;
			if (FlxG.mouse.justPressed)
			{
				tocreate = roomname.text;
				FlxG.switchState(new PlayState());
			}
			}
		}
		joinroom.scale.set(0.75, 0.75);
		joinroom.color = FlxColor.WHITE;
		if (FlxG.mouse.overlaps(joinroom))
		{
			if (name.text != "Choose a name to play!") {
			joinroom.scale.set(1, 1);
			joinroom.color = FlxColor.YELLOW;
			playerName = name.text;
			if (FlxG.mouse.justPressed)
				FlxG.switchState(new RoomsState());
			}
		}
		joinroom2.scale.set(0.75, 0.75);
		joinroom2.color = FlxColor.WHITE;
		if (FlxG.mouse.overlaps(joinroom2))
		{
			joinroom2.scale.set(1, 1);
			joinroom2.color = FlxColor.YELLOW;
			playerName = name.text;
			if (FlxG.mouse.justPressed)
			{
				if (name.text != "Choose a name to play!") {
					tojoin = "quick";
					FlxG.switchState(new PlayState());
				}
			}
		}
		super.update(elapsed);
	}
}
