
package mx.core
{

/**
 *  The IButton interface is a marker interface that indicates that a component
 *  acts as a button.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IButton extends IUIComponent
{
    /**
     *  @copy mx.controls.Button#emphasized
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get emphasized():Boolean;
    function set emphasized(value:Boolean):void;

    /**
     *  @copy mx.core.UIComponent#callLater()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function callLater(method:Function,
                              args:Array /* of Object */ = null):void
}

}
