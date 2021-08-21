package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class KadeDev extends FlxSprite
{
    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = FlxAtlasFrames.fromSparrow('assets/images/kade.png', 'assets/images/kade.xml');
        animation.addByIndices('idle', 'kade', [0, 1, 2, 3, 4, 5, 6, 7], "", 24, false);
        animation.addByIndices('flip', 'flip', [0, 1, 2, 3, 4, 5, 6, 7], "",  24, false);
        animation.play('idle');
    }
}