
package mx.core
{

/**
 *  The IStateClient interface defines the interface that 
 *  components must implement to support view states.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IStateClient
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  currentState
    //----------------------------------

    /**
     *  The current view state.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get currentState():String;
    
    /**
     *  @private
     */
    function set currentState(value:String):void;
}

}
