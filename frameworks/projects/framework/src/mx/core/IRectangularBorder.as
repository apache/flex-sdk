////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import flash.geom.Rectangle;

/**
 *  The IRectangularBorder interface defines the interface that all classes 
 *  used for rectangular border skins should implement.
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IRectangularBorder extends IBorder
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  backgroundImageBounds
    //----------------------------------

    /**
     *  @copy mx.skins.RectangularBorder#backgroundImageBounds
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get backgroundImageBounds():Rectangle;
    function set backgroundImageBounds(value:Rectangle):void;

    //----------------------------------
    //  hasBackgroundImage
    //----------------------------------

    /**
     *  @copy mx.skins.RectangularBorder#hasBackgroundImage
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get hasBackgroundImage():Boolean;

    //----------------------------------
    //  adjustBackgroundImage
    //----------------------------------

    /**
     *  @copy mx.skins.RectangularBorder#layoutBackgroundImage()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function layoutBackgroundImage():void;
}

}
