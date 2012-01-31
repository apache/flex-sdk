
package mx.controls.videoClasses 
{

[ExcludeClass]

/**
 *  @private
 */ 
public class VideoPlayerQueuedCommand 
{
	include "../../core/Version.as";

    public static const PLAY:uint = 0;
    public static const LOAD:uint = 1;
    public static const PAUSE:uint = 2;
    public static const STOP:uint = 3;
    public static const SEEK:uint = 4;
    
    public var type:uint;
    public var url:String;
    public var isLive:Boolean;
    public var time:Number;
    public var cuePoints:Array;
    
    public function VideoPlayerQueuedCommand(type:uint, url:String = null, isLive:Boolean = false,
                            time:Number = 0, cuePoints:Array = null) 
    {
		super();

        this.type = type;
        this.url = url;
        this.isLive = isLive;
        this.time = time;
        this.cuePoints = cuePoints;
    }
} // class QueuedCommand

}
