package;

import openfl.display.Sprite;
import flixel.FlxGame;
import openfl.display.FPS;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, TitleState, 1, #if web 60, 60 #else 120, 120 #end));

		addChild(new FPS(10, 3));
	}
}
