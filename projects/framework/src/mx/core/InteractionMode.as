
package mx.core
{
    
    /**
     *  The InteractionMode class defines the alues for the 
     *  <code>interactionMode</code> property of the UIComponent class.
     *
     *  @see mx.core.Container
     *  @see mx.core.ScrollControlBase
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public final class InteractionMode
    {
        include "../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  The main interaction mode for this component is through 
         *  the mouse.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const MOUSE:String = "mouse";
        
        /**
         *  The main interaction mode for this component is through
         *  touch.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const TOUCH:String = "touch";
    }
    
}
