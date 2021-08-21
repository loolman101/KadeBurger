package;

import flixel.FlxSprite;
import funkin.Conductor;

class Burger extends FlxSprite
{
    public var flipTime:Float = 0;
    public var canBeFlipped:Bool = false;
    public var tooLate:Bool = false;

    public static var offsetX:Float = 700;
    public static var offsetY:Float = 560;

    public function new(x:Float = 0, y:Float = 0, flipTime:Float = 0)
    {
        super(x, y);
        this.flipTime = flipTime;

        loadGraphic('assets/images/burger.png');
        setGraphicSize(141);
        updateHitbox();
        antialiasing = true;
    }

    override function update(elapsed:Float)
    {
        canBeFlipped = (flipTime > Conductor.songPosition - Conductor.safeZoneOffset && flipTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5));

        if (flipTime < Conductor.songPosition - Conductor.safeZoneOffset)
            tooLate = true;
    }
}