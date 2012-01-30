package spark.events
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

public class TouchScrollEvent extends Event
{
    
    public static const TOUCH_SCROLL_STARTING:String = "touchScrollStarting";
    public static const TOUCH_SCROLL_START:String = "touchScrollStart";
    public static const TOUCH_SCROLL_DRAG:String = "touchScrollDrag";
    public static const TOUCH_SCROLL_THROW:String = "touchScrollThrow";
    public static const TOUCH_SCROLL_THROW_ANIMATION_END:String = "touchScrollThrowAnimationEnd";
    public static const TOUCH_SCROLL_END:String = "touchScrollEnd";
    
    public function TouchScrollEvent(type:String, bubbles:Boolean = false,
                              cancelable:Boolean = false)
    {
        super(type, bubbles, cancelable);
    }
    
    public var dragX:Number;
    public var dragY:Number;
    public var throwVelocity:Point;
    public var scrollingObject:DisplayObject;
    
    /**
     *  @private
     */
    override public function clone():Event
    {
        var clonedEvent:TouchScrollEvent = new TouchScrollEvent(type, bubbles, cancelable);
        
        clonedEvent.dragX = dragX;
        clonedEvent.dragY = dragY;
        clonedEvent.throwVelocity = throwVelocity;
        clonedEvent.scrollingObject = scrollingObject;
        
        return clonedEvent;
    }
}
}