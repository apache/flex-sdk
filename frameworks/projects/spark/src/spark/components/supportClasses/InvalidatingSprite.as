
package spark.components.supportClasses
{
import flash.display.Sprite;
import spark.core.ISharedDisplayObject;

[ExcludeClass]

/**
 *  @private
 *  <code>GraphicElement</code> creates shared <code>DsiplayObject</code> of type
 *  <code>InvalidatingSprite</code>. This class does not support mouse interaction. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class InvalidatingSprite extends Sprite implements ISharedDisplayObject
{
    public function InvalidatingSprite()
    {
        super();
        mouseChildren = false;
        mouseEnabled = false;
    }
    
    private var _redrawRequested:Boolean = false;

    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get redrawRequested():Boolean
    {
        return _redrawRequested;
    }
    
    /**
     *  @private 
     */
    public function set redrawRequested(value:Boolean):void
    {
        _redrawRequested = value;
    }
}
}
