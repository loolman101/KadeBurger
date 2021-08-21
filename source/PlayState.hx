package;

import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import funkin.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import openfl.Assets;
import haxe.Json;
import flixel.math.FlxMath;

using StringTools;

class PlayState extends FlxUIState
{
    private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

    private var kade:KadeDev;

    private var _song:KadeDevsTunes;

    private var burgerTimes:Array<Float> = [];

    private var burgers:FlxTypedGroup<Burger>;
    private var flipping_burgers:FlxTypedGroup<FlxSprite>;
    private var burgsFlipped:Array<FlxSprite> = [];
    private var missed:Int = 0;
    private var missCounter:Array<FlxSprite> = [];

    private var paused:Bool = false;

    override function create() // 185
    {
        add(new FlxSprite().loadGraphic('assets/images/kitch.png'));
        add(new FlxSprite(97, 431).loadGraphic('assets/images/belt.png'));
        var blu:FlxSprite = new FlxSprite(97, 431).loadGraphic('assets/images/belt.png');
        blu.color = FlxColor.BLUE;
        blu.alpha = 0.5;
        add(blu);
        var dark:FlxSprite = new FlxSprite(97, 431).loadGraphic('assets/images/belt.png');
        dark.color = FlxColor.BLACK;
        dark.alpha = 0.9;
        add(dark);
        add(new FlxSprite(-516, 546).loadGraphic('assets/images/belt.png'));

        flipping_burgers = new FlxTypedGroup<FlxSprite>();
        add(flipping_burgers);

        kade = new KadeDev(FlxG.width - 818 + 100, FlxG.height - 755 + 100);
        add(kade);

        FlxG.sound.playMusic('assets/music/song.${TitleState.ext}');
        FlxG.sound.music.looped = false;
        FlxG.sound.music.onComplete = function() FlxG.switchState(new TitleState());

        burgers = new FlxTypedGroup<Burger>();
        add(burgers);

        if (_song == null)
            _song = loadSong('song');

        burgerTimes = _song.burgTimes;

        for (i in burgerTimes)
        {
            var burger:Burger = new Burger(-141, Burger.offsetY, i);
            burgers.add(burger);
        }

        for (i in 0...3)
        {
            var thing:FlxSprite = new FlxSprite(25, 150 * i).loadGraphic('assets/images/burgIcons.png', true, 295, 332);
            thing.animation.add('idle', [0], 0, false);
            thing.animation.add('lose', [1], 0, false);
            thing.animation.play('idle');
            thing.setGraphicSize(0, 150);
            thing.updateHitbox();
            add(thing);
            missCounter.push(thing);
        }

        Conductor.changeBPM(_song.bpm);

        super.create();
    }
    
    override function update(elapsed:Float)
    {
        Conductor.songPosition = FlxG.sound.music.time;

        burgers.forEachAlive(function(burger:Burger){
            burger.x = (Burger.offsetX + (Conductor.songPosition - burger.flipTime) * (0.45 * FlxMath.roundDecimal(_song.speed, 2)));

            if (burger.x > 1280) missBurg(burger);

            if (FlxG.keys.justPressed.SPACE && !paused) {
                kade.animation.play('flip', true);
                kade.offset.set(89, 67);
                if (burger.canBeFlipped && !burger.tooLate)
                    flipBurger(burger);
            }
        });

        for (burg in burgsFlipped)
        {
            burg.x += #if web 6 #else 3 #end;
            if (burg.x > 1280) {
                burgsFlipped.remove(burg);
                burg.kill();
            }
        }

        for (thing in missCounter)
        {
            thing.animation.play(missCounter.indexOf(thing) < missed ? 'lose' : 'idle');
        }

        if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset // we are NOT going to talk about how this is sto- I mean uhh """borrowed""" from FNF.
			|| Conductor.songPosition < lastStep + Conductor.safeZoneOffset)
		{
			if (Conductor.songPosition > lastStep + Conductor.stepCrochet)
				stepHit();
		}

        curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
        curBeat = Math.round(curStep / 4);

        FlxG.watch.addQuick('songPos', Conductor.songPosition);
        FlxG.watch.addQuick('beat', curBeat);
        FlxG.watch.addQuick('shutUPevan', Conductor.stepCrochet);
        FlxG.watch.addQuick('savezone', Conductor.safeZoneOffset);

        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER && !paused)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState());
		}
    }

    override function openSubState(SubState:FlxSubState)
    {
        if (paused && FlxG.sound.music != null)
			FlxG.sound.music.pause();

        super.openSubState(SubState);
    }

    override function closeSubState()
    {
        if (paused && FlxG.sound.music != null) {
			FlxG.sound.music.play();
            paused = false;
        }

        super.closeSubState();
    }

    public static function loadSong(song:String):KadeDevsTunes
    {
        var rawJson = Assets.getText('assets/data/$song.json').trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

        return cast Json.parse(rawJson).song;
    }

    private function flipBurger(burger:Burger):Void
    {
        var flip:FlxSprite = new FlxSprite(kade.x + 75, kade.y + 75);
        flip.frames = FlxAtlasFrames.fromSparrow('assets/images/flipped_burger.png', 'assets/images/flipped_burger.xml');
        flip.animation.addByPrefix('idle', 'burgflip', 24, false);
        flip.animation.play('idle');
        flip.animation.finishCallback = function(s:String) burgsFlipped.push(flip);
        flipping_burgers.add(flip);
        burger.kill();
    }

    private function missBurg(burger:Burger):Void
    {
        burger.kill();
        missed++;
        if (missed > 3)
            loseGame();
    }

    private function loseGame():Void
    {
        persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		openSubState(new LoseSubState());
    }

    public function stepHit():Void
	{
		totalSteps += 1;
		lastStep += Conductor.stepCrochet;

		// If the song is at least 3 steps behind
		if (Conductor.songPosition > lastStep + (Conductor.stepCrochet * 3))
		{
			lastStep = Conductor.songPosition;
			totalSteps = Math.ceil(lastStep / Conductor.stepCrochet);
		}

		if (totalSteps % 4 == 0)
			beatHit();
	}

    public function beatHit():Void
	{
		lastBeat += Conductor.crochet;
		totalBeats += 1;

        if (kade.animation.curAnim.finished) {
            kade.animation.play('idle');
            kade.offset.set();
        }
	}
}

typedef KadeDevsTunes = {
    var burgTimes:Array<Float>;
    var speed:Float;
    var bpm:Int;
}