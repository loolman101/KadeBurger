package;

import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import funkin.Conductor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PlayState extends FlxUIState
{
    private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

    private var kade:KadeDev;

    private var burgerTimes:Array<Float> = [
        9600, 10800, 12000, 13200, 
        14400, 15600, 16800, 18000,
        19200, 20400, 21600, 22800,
        24000, 25200, 26400, 27600,
        28800, 30000, 31200, 32400,
        33600, 34800, 36000, 37200,
        38400, 39000, 39600, 40800, 41400, 42000,
        43200, 43800, 44400, 45600, 46200, 46800,
        48000, 48300, 48600, 48900, 49800,
        50400, 50700, 51000, 51300, 52200,
        52800, 53400, 54000, 54600, 55200, 55800, 56400, 57000,
        57600
    ];
    private var burgers:FlxTypedGroup<Burger>;

    private var flipping_burgers:FlxTypedGroup<FlxSprite>;

    override function create()
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

        FlxG.sound.playMusic('assets/music/song.ogg');

        burgers = new FlxTypedGroup<Burger>();
        add(burgers);

        for (i in burgerTimes)
        {
            var burger:Burger = new Burger(-141, Burger.offsetY, i);
            burgers.add(burger);
        }

        FlxG.mouse.visible = false;

        super.create();
    }
    
    override function update(elapsed:Float)
    {
        Conductor.songPosition = FlxG.sound.music.time;

        burgers.forEachAlive(function(burger:Burger){
            burger.x = (Burger.offsetX + (Conductor.songPosition - burger.flipTime) * 0.45);

            if (FlxG.keys.justPressed.SPACE) {
                kade.animation.play('flip', true);
                kade.offset.set(89, 67);
                if (burger.canBeFlipped && !burger.tooLate)
                    flipBurger(burger);
            }
        });

        if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset
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
    }

    private function flipBurger(burger:Burger):Void
    {
        var flip:FlxSprite = new FlxSprite(kade.x + 75, kade.y + 75);
        flip.frames = FlxAtlasFrames.fromSparrow('assets/images/flipped_burger.png', 'assets/images/flipped_burger.xml');
        flip.animation.addByPrefix('idle', 'burgflip', 24, false);
        flip.animation.play('idle');
        flip.animation.finishCallback = function(s:String) FlxTween.tween(flip, {x: flip.x + 350}, 1.5, {onComplete: function(twn:FlxTween) flip.kill()});
        flipping_burgers.add(flip);
        burger.kill();
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