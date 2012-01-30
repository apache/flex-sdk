////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
    /**
     *  The ViewNavigatorAction class defines the constant values
     *  for the <code>action</code> property of ViewNavigatorEvent class.
     *
     *  @see spark.events.ViewNavigatorEvent
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public final class ViewNavigatorAction
    {
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constant indicating that no action was performed by the navigator.
         *  
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const NONE:String = "none";
        
        /**
         *  Constant describing a navigation action where a new view is added
         *  to a navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const PUSH:String = "push";
        
        /**
         *  Constant describing a navigation action where the top most view is
         *  removed from the navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const POP:String = "pop";
        
        /**
         *  Constant describing a navigation action where all views
         *  were removed from the navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const POP_ALL:String = "popAll";
        
        /** 
         *  Constant describing a navigation action where all but the
         *  first view are removed from the navigator.
         * 
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const POP_TO_FIRST:String = "popToFirst";
        
        /**
         *  Constant describing a navigation action where the active view
         *  is replaced with another.
         *  
         *  @langversion 3.0
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static const REPLACE:String = "replace";
    }
}