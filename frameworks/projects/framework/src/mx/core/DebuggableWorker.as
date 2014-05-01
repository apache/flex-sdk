/**
 * User: DoubleFx Date: 30/04/2014 Time: 17:34
 */
package mx.core {
import flash.display.Sprite;
import flash.system.Capabilities;
import flash.utils.setInterval;

/**
 *  DebuggableWorker should be used as a base class
 *  for workers instead of Sprite.
 *  it allows the debugging of those workers using FDB.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 3.4
 *  @productversion Flex 4
 */
public class DebuggableWorker extends Sprite {

    include "../core/Version.as";

    public function DebuggableWorker() {

        // Stick a timer here so that we will execute script every 1.5s
        // no matter what.
        // This is strictly for the debugger to be able to halt.
        // Note: isDebugger is true only with a Debugger Player.
        if (Capabilities.isDebugger == true) {
            setInterval(debugTickler, 1500);
        }
    }

    /**
     *  @private
     *  This is here so we get the this pointer set to Application.
     */
    private function debugTickler():void {
        // We need some bytes of code in order to have a place to break.
        var i:int = 0;
    }
}
}
