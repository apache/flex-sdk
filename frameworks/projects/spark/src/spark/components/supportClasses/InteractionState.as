////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
    
    /**
     *  Values for the <code>state</code> property
     *  of the InteractionStateDetector class.
     *
     *  @see spark.components.supportClasses.InteractionStateDetector
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public final class InteractionState
    {
        
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  The component should be in the up state.
         *  
         *  <p>No interaction is occurring on this component.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const UP:String = "up";
        
        /**
         *  The component should be in the down state.
         *  
         *  <p>The user is currently pressing down on this component.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const DOWN:String = "down";
        
        /**
         *  The component should be in the over state.
         *  
         *  <p>The user is currently hovering over this component.</p>
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const OVER:String = "over";
    }
    
}
