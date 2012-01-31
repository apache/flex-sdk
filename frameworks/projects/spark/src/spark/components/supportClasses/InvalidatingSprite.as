package mx.core
{
import flash.display.Sprite;
import mx.graphics.baseClasses.ISharedGraphicsDisplayObject;

/**
 *  <code>GraphicElement</code> creates shared <code>DsiplayObject</code> of type
 *  <code>InvalidatingSprite</code>.
 */
public class InvalidatingSprite extends Sprite implements ISharedGraphicsDisplayObject
{
    public function InvalidatingSprite()
    {
        super();
    }
    
    private var _redrawRequested:Boolean = false;

    /**
     *  @inheritDoc 
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