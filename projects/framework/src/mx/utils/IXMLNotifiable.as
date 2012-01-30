
package mx.utils
{

/**
 *  The IXMLNotifiable interface.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IXMLNotifiable
{
    /**
    *  @private
    */
    function xmlNotification(currentTarget:Object,
                             type:String,
                             target:Object,
                             value:Object,
                             detail:Object):void;
}

}