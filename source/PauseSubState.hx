package;

import flixel.addons.ui.FlxUISubState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;

class PauseSubState extends FlxUISubState
{
    var optionNames:Array<String> = ['RESUME', 'RESTART', 'QUIT'];

    var _options:Array<FlxText> = [];

    var curSelected:Int = 0;

    var tweeningKade:Bool = false;

    var dev:FlxSprite;

    var pauseMusic:FlxSound;

    override function create()
    {
        pauseMusic = new FlxSound().loadEmbedded('assets/music/pause.${TitleState.ext}', true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

        FlxG.sound.list.add(pauseMusic);

        var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        bg.alpha = 0.6;
        add(bg);

        dev = new FlxSprite(880, FlxG.height).loadGraphic('assets/images/dude1.png');
        dev.setGraphicSize(400);
        dev.updateHitbox();
        dev.flipX = true;
        add(dev);
        FlxTween.tween(dev, {y: 266}, 0.45, {ease: FlxEase.quintOut, startDelay: 0.15});

        for (i in optionNames)
        {
            var option:FlxText = new FlxText(-100, 200 + optionNames.indexOf(i) * 100, 0, i, 35);
            add(option);
            _options.push(option);
        }

        changeSelection(0);

        super.create();

        FlxG.mouse.visible = false;
    }

    override function update(t:Float)
    {
        if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * t;

        if (FlxG.keys.justPressed.UP)
            changeSelection(-1);

        if (FlxG.keys.justPressed.DOWN)
            changeSelection(1);

        if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE) {
            FlxTween.cancelTweensOf(dev);
            close();
        }

        if (!tweeningKade) {
            tweeningKade = true;
            FlxTween.tween(dev, {angle: FlxG.random.int(-10, 10)}, 1, {ease:FlxEase.circOut, onComplete: function (twn:FlxTween) tweeningKade = false});
        }

        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
        {
            FlxTween.cancelTweensOf(dev);
            
            switch (optionNames[curSelected])
            {
                case 'RESUME':
                    close();
                case 'RESTART':
                    FlxG.resetState();
                case 'QUIT':
                    FlxG.switchState(new TitleState());
            }
        }

        super.update(t);
    }

    override function destroy()
	{
        pauseMusic.destroy();

		dev.destroy();

		super.destroy();
	}

    function changeSelection(d:Int)
    {
        curSelected += d;

        if (curSelected >= _options.length)
            curSelected = 0;

        if (curSelected < 0)
            curSelected = _options.length - 1;

        for (i in _options)
        {
            FlxTween.cancelTweensOf(i);

            optionNames[curSelected] == i.text ?{
                i.alpha = 1;
                FlxTween.tween(i, {x: 150}, 0.25, {ease: FlxEase.circOut});
            } : {
                i.alpha = 0.5;
                FlxTween.tween(i, {x: 100}, 0.25, {ease: FlxEase.circOut});
            }
        }
    }
}