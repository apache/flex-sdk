package mx.utils
{
	import flash.display.DisplayObject;
	import flash.system.Capabilities;
	
	import mx.core.mx_internal;

	[Mixin]
	public class AndroidPlatformVersionOverride
	{
		public static function init(root:DisplayObject):void
		{
			var c:Class = Capabilities;
			//Set this override value on if we are 
			// a. on the AIR Simulator
			// b. simulating Android
			if(c.version.indexOf("AND") > -1 && c.manufacturer != "Android Linux")
			{
				Platform.mx_internal::androidVersionOverride =  "4.1.2";
			}
		}
	}
}