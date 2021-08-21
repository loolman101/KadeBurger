package;

import openfl.display.Sprite;
import flixel.FlxGame;
import openfl.display.FPS;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, PlayState, 1, 120, 120));

		addChild(new FPS());
	}
}
