package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Exception;

class Player extends FlxSprite
{
	public var SPEED:Float = 350;

	public var particleEmitDelay:Float = 100;
	var jumpAllowed:Bool = false;
	var jumpAllowedAtAll:Int = 2;

	public var SUPERSPEEEED:Float = 0;
	public var wallclimb:Bool = true;
	public var stamina:Float = 100;

	public var staminaBar:FlxBar;

	public var particles:FlxEmitter;

	public var camerapoint:FlxPoint = new FlxPoint();

	var runSound:FlxSound = new FlxSound();

	override public function new(x:Int, y:Int)
	{
		FlxG.autoPause = false;
		staminaBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, 68, 10);
		stamina = 100;
		runSound.loadEmbedded(AssetPaths.click__wav);
		particles = new FlxEmitter(0, 0);
		particles.makeParticles(8, 8, FlxColor.WHITE, 50);
        particles.lifespan.set(0.25, 0.5); 
		super(x, y);
		makeGraphic(32, 32, FlxColor.WHITE);
		color = FlxColor.LIME;
		maxVelocity.y = 600;
		acceleration.y = 600;
		drag.x = 4800;
	}

	override public function update(elapsed:Float)
	{
		if (SPEED >= 650)
		{
			color = FlxColor.YELLOW;
		}
		else
		{
			color = FlxColor.LIME;
		}
		if (stamina != 100)
		{
			if (staminaBar.alpha == 0)
			{
				FlxTween.tween(staminaBar, {alpha: 1}, 0.1);
			}
		}
		if (stamina >= 100 && staminaBar.alpha == 1)
		{
			stamina = 100;
			FlxTween.tween(staminaBar, {alpha: 0}, 0.1);
		}
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		up = FlxG.keys.anyPressed([UP, W]);
		down = FlxG.keys.anyPressed([DOWN, S]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		if (PlayState.ischatting) {
			up = false;
			down = false;
			left = false;
			right = false;
		}
		if (SPEED >= 400)
		{
			FlxG.camera.shake(SPEED / 800000, 0.1,null, false);
		}
		if (FlxG.keys.justPressed.SPACE && stamina >= 100 && !isTouching(WALL) && !PlayState.ischatting)
		{
			PlayState.roome.send("dash");
			FlxG.sound.play(AssetPaths.explosion__wav);
			FlxTween.tween(this, {angle: angle + 360}, 0.5, {
				onComplete: function(twn:FlxTween)
				{
					angle = 0;
				}
			});
			FlxG.camera.shake(0.005, 0.25,null, false);
			if (jumpAllowedAtAll > 0)
			{
				jumpAllowedAtAll -= 1;
				jumpAllowed = true;
			}
			particles.alpha.set(1, 1, 0, 0);
			particles.color.set(FlxColor.fromRGB(0, 183, 233));
			particles.start(true, 0.01, Std.int(SPEED / 100));
			SPEED += 25;
			SUPERSPEEEED = 100;
			particleEmitDelay = 150;
			stamina = 0;
		}

		var justOrNot = false;

		if (isTouching(FLOOR))
		{
			justOrNot = true;
			jumpAllowed = true;
			jumpAllowedAtAll = 2;
		}
		if (up && jumpAllowed || up && jumpAllowed && !justOrNot)
		{
			FlxG.sound.play(AssetPaths.jump__wav);
			jumpAllowed = false;
			velocity.y = -maxVelocity.y / 2;
		}

		if (left && right)
		{
			left = right = false;
		}
		if (left || right)
		{
			if (left)
			{
				velocity.x = -SPEED - SUPERSPEEEED;
			}
			if (right)
			{
				velocity.x = SPEED + SUPERSPEEEED;
			}
		}
		else
		{
			if (SPEED > 375)
				SPEED -= 3;
		}
		if (down)
		{
			FlxG.camera.shake(0.005, 0.025,null, false);
			velocity.y += SPEED;
		}

		if (isTouching(WALL) && wallclimb)
		{
			if (SUPERSPEEEED <= 30)
			{
				if (SPEED >= 400)
				{
					SPEED = -SPEED;
					SUPERSPEEEED = 0;
					FlxG.camera.shake(0.005, 0.25,null, false);
					velocity.x = -SPEED;
					FlxG.sound.play(AssetPaths.hitHurt__wav);
					runSound.stop();
				}
			}
			else
			{
				runSound.play(false);
				velocity.y = -SPEED;
			}
		}
		else
		{
			runSound.stop();
		}

	
		FlxG.camera.followLerp = (SPEED / 1000);

		super.update(elapsed);

		/*if (staminaBar != null && particles != null && stamina != null)
			{ */
		staminaBar.value = stamina;
		staminaBar.x = x - 16;
		staminaBar.y = y - 16;
		particles.x = x + 16;
		particles.y = y + 16;
		// }
	}
}