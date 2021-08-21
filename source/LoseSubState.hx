package;

import flixel.addons.ui.FlxUISubState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;

class LoseSubState extends FlxUISubState
{
    var veloper:FlxSprite;

    var canShrinkKade:Bool = false;

    override function create()
    {
        add(new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK));
        
        var red:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.RED);
        add(red);

        veloper = new FlxSprite().loadGraphic('assets/images/pissyKade.png');
        veloper.screenCenter();
        veloper.scale.set(0, 0);
        add(veloper);

        var loseTxt:FlxSprite = new FlxSprite().loadGraphic('assets/images/youLose.png');
        loseTxt.screenCenter();
        loseTxt.setGraphicSize(696);
        loseTxt.alpha = 0;
        add(loseTxt);

        FlxG.sound.play('assets/sounds/death.${TitleState.ext}');

        FlxTween.tween(red, {alpha: 0.15}, 1, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
            FlxG.sound.play('assets/sounds/lose.${TitleState.ext}');
            FlxTween.tween(veloper, {"scale.x": 0.65, "scale.y": 0.65}, 0.35, {ease: FlxEase.quadIn, startDelay: 0.25, onComplete: function(twn:FlxTween) {
                FlxTween.tween(veloper, {"scale.x": 0.55, "scale.y": 0.55}, 0.45, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween) {
                    FlxG.sound.playMusic('assets/music/loser.${TitleState.ext}', 0);
				    FlxG.sound.music.fadeIn(1, 0, 0.4);
                    canShrinkKade = true;
                    FlxTween.tween(loseTxt, {alpha: 1}, 1.45, {ease: FlxEase.circOut});
                }});
            }});
        }});

        super.create();

        FlxG.mouse.visible = false;
    }

    override function update(t:Float)
    {
        if (canShrinkKade) {
            veloper.scale.x -= 0.0001 #if web * 2 #end;
            veloper.scale.y -= 0.0001 #if web * 2 #end;

            if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
                FlxG.resetState();

            if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
                FlxG.switchState(new TitleState());
        }

        super.update(t);
    }
}