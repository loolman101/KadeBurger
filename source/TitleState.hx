package;

import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;

class TitleState extends FlxUIState
{
    var kade:KadeDev;
    static var initialized:Bool = false;

    public static var ext:String = #if web 'mp3' #else 'ogg'#end ;

    override function create()
    {
        add(new FlxSprite().loadGraphic('assets/images/kitch.png'));

        var logo:FlxSprite = new FlxSprite().loadGraphic('assets/images/logo.png');
        logo.angle = -10;
        add(logo);

        var burger:FlxSprite = new FlxSprite(70, 275).loadGraphic('assets/images/3dBurger.png', true, 480, 480);
        burger.animation.add('spin', [for (i in 0...45) i], 24, true);
        burger.animation.play('spin');
        add(burger);

        kade = new KadeDev(330, -170);
        kade.setGraphicSize(1200);
        kade.updateHitbox();
        kade.antialiasing = true;
        add(kade);

        FlxG.mouse.visible = false;

        FlxG.sound.playMusic('assets/music/title.$ext');

        super.create();

        if (!initialized)
            init();
    }

    override function update(t:Float)
    {
        kade.animation.play('idle', false);

        if (FlxG.keys.justPressed.ENTER) {
            FlxG.sound.music.stop();
            FlxG.switchState(new PlayState());
        }
        super.update(t);
    }

    function init():Void
    {
		var diamond:FlxGraphic = FlxGraphic.fromAssetKey('assets/images/burger.png');
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 0), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.3, new FlxPoint(0, 0),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
    }
}