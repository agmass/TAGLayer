package;

import js.Browser;
import js.html.SpeechSynthesis;
import js.html.SpeechSynthesisUtterance;
import flixel.FlxG;
import js.html.audio.AudioBufferSourceNode;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class NetPlayer extends FlxSprite {

    public var key:String = "";
    public var sspeed:Int = 0;
    public var particleEmitDelay:Float = 0;
    public var ss = Browser.window.speechSynthesis;
    public var utter = new SpeechSynthesisUtterance();
    public var pitch:Float = 1;
    public var voice:Int = 0;
    public var source:AudioBufferSourceNode;
    public var emitter:FlxEmitter = new FlxEmitter(0,0,50);
    public var particles:FlxEmitter = new FlxEmitter(0,0,50);

    override public function new(x,y) {
        super(x,y);
        makeGraphic(32,32,FlxColor.WHITE);
        emitter.makeParticles(12,8,FlxColor.WHITE);
		emitter.color.set(FlxColor.ORANGE, FlxColor.ORANGE, FlxColor.YELLOW, FlxColor.YELLOW);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
		emitter.speed.set(1800, 1800);
		emitter.drag.set(0, 0, 0, 0);
		emitter.allowCollisions = ANY;
		emitter.angularDrag.set(0, 0, 0, 0);
        pitch = FlxG.random.float(0.5,1.5);
        voice = FlxG.random.int(0,ss.getVoices().length);
		emitter.start(false, 999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999, 0);
		particles.makeParticles(8, 8, FlxColor.WHITE, 50);
        particles.lifespan.set(0.25, 0.5); 
    }

    function calculateDistance(x1:Float, y1:Float, x2:Float, y2:Float):Float {
        var dx = x2 - x1;
        var dy = y2 - y1;
        return Math.sqrt(dx * dx + dy * dy);
    }

    override function update(elapsed:Float) {
        var distance = calculateDistance(PlayState.plrx, PlayState.plry,x,y);
        var maxDistance = 1000.0; // Adjust this value based on your scene scale
        var volume = 1.0 - (distance / maxDistance); // Invert volume based on distance	
        if (utter.volume != volume) {
            utter.volume = volume;
            Browser.window.speechSynthesis.pause();
            Browser.window.speechSynthesis.resume();
        }
		
        
        particleEmitDelay -= 100 * (sspeed / 100);

        particles.x = x+16;
        particles.y = y+16;
        emitter.x = x+16;
        emitter.y = y+16;
    
		if (sspeed >= 1 && particleEmitDelay <= 0)
		{
			particleEmitDelay = 100;
			particles.color.set(color);
			particles.alpha.set(sspeed / 100, sspeed / 100, 0, 0);
			particles.start(true, 0.0005, 1);
		}
        super.update(elapsed);
    }
}