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

package mx.core
{    
    /**
     *  The LayoutDirection class defines the constant values
     *  for the <code>layoutDirection</code> style of an IStyleClient and the 
     *  <code>layoutDirection</code> property of an ILayoutDirectionElement.
     *  
     *  Left-to-right layoutDirection is typically used with Latin-style 
     *  scripts. Right-to-left layoutDirection is used with scripts such as 
     *  Arabic or Hebrew.
     * 
     *  If an IStyleClient, set the layoutDirection style to undefined to
     *  inherit the layoutDirection from its ancestor.
     * 
     *  If an ILayoutDirectionElement, set the layoutDirection property to null to
     *  inherit the layoutDirection from its ancestor.
     * 
     *  @see mx.styles.IStyleClient
     *  @see mx.core.ILayoutDirectionElement
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.1
     */
    public final class LayoutDirection
    {
        include "Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class constants
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Specifies left-to-right layout direction for a style client or a
         *  visual element.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.1
         */
        public static const LTR:String = "ltr";
        
        /**
         *  Specifies right-to-left layout direction for a style client or a
         *  visual element.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 2.0
         *  @productversion Flex 4.1
         */
        public static const RTL:String = "rtl";
    }
}
