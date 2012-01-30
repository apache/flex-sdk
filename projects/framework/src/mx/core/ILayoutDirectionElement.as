////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package mx.core
{
    
    /**
     *  The ILayoutDirectionElement interface defines the minimum properties and methods 
     *  required for an Object to support the layoutDirection property.
     *  
     *  @see mx.core.LayoutDirection
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.1
     */
    public interface ILayoutDirectionElement
    {
        
        /**
         *  Specifies the desired layout direction for an element: one of LayoutDirection.LTR 
         *  (left to right), LayoutDirection.RTL (right to left), or null (inherit).   
         * 
         *  This property is typically backed by an inheriting style.  If null,
         *  the layoutDirection style will be set to undefined.
         * 
         *  Classes like GraphicElement, which implement ILayoutDirectionElement but do not 
         *  support styles, must additionally support a null value for this property 
         *  which means the layoutDirection must be inherited from its parent. 
         *  
         *  @see mx.core.LayoutDirection
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.1
         */
        function get layoutDirection():String;
        
        /**
         *  @private
         */
        function set layoutDirection(value:String):void;
        
        /**
         *  Must be called when an element or its parent's layoutDirection changes.
         *  
         *  If they differ, the X axis is scaled by -1 and the x coordinate of the origin
         *  is translated by the element's width.  
         * 
         *  The net effect of this "mirror" transform is to reverse the direction 
         *  that the X axis increases without changing the element's 
         *  location relative to the parent's origin.
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.1
         */
        function invalidateLayoutDirection():void;
    }
}
