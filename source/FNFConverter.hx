package;

import haxe.Json;
import sys.io.File;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import PlayState.KadeDevsTunes;

using StringTools;

typedef FunkinSection = {
    var sectionNotes:Array<Array<Float>>;
}

typedef FunkinSong = {
    var notes:Array<FunkinSection>;
    var bpm:Float;
    var speed:Float;
}

class FNFConverter
{
    static var _song:KadeDevsTunes;
    static var pooping:Array<Float> = [];
    static var _file:FileReference;

    public static function convert(song:String, destination:String = '')
    {
        _song = {
            "burgTimes": [],
            "speed": 1,
            "bpm": 100
        }
        pooping = [];
        var rawJson = File.getContent('assets/data/$song.json').trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

        var song1:FunkinSong = cast Json.parse(rawJson).song;

        for (i in song1.notes)
        {
            for (ii in i.sectionNotes)
            {
                pooping.push(ii[0]);
            }
        }

        _song.burgTimes = pooping;
        _song.speed = song1.speed;
        _song.bpm = Std.int(song1.bpm);

        saveLevel();
    }

    static private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "lol.json");
		}
	}

	static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		// FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		// FlxG.log.error("Problem saving Level data");
	}
}