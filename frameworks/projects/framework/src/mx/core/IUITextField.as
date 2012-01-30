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

import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.text.StyleSheet;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;
import mx.automation.IAutomationObject;
import mx.managers.IToolTipManagerClient;
import mx.styles.ISimpleStyleClient;

/**
 *  The IUITextField interface defines the basic set of APIs
 *  for UITextField instances.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IUITextField extends IIMESupport,
                         IFlexModule,
                         IInvalidating, ISimpleStyleClient,
                         IToolTipManagerClient, IUIComponent
{

	include "ITextFieldInterface.as"
	include "IInteractiveObjectInterface.as"

    /**
     *  @copy mx.core.UITextField#ignorePadding
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get ignorePadding():Boolean;
    function set ignorePadding(value:Boolean):void;

    /**
     *  @copy mx.core.UITextField#inheritingStyles
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get inheritingStyles():Object;
    function set inheritingStyles(value:Object):void;

    /**
     *  @copy mx.core.UITextField#nestLevel
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get nestLevel():int;
    function set nestLevel(value:int):void;

    /**
     *  @copy mx.core.UITextField#nonInheritingStyles
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get nonInheritingStyles():Object;
    function set nonInheritingStyles(value:Object):void;

    /**
     *  @copy mx.core.UITextField#nonZeroTextHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get nonZeroTextHeight():Number;

    /**
     *  @copy mx.core.UITextField#getStyle()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getStyle(styleProp:String):*;

    /**
     *  @copy mx.core.UITextField#getUITextFormat()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getUITextFormat():UITextFormat

    /**
     *  @copy mx.core.UITextField#setColor()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function setColor(color:uint):void;

    /**
     *  @copy mx.core.UITextField#setFocus()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function setFocus():void;

    /**
     *  @copy mx.core.UITextField#truncateToFit()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function truncateToFit(truncationIndicator:String = null):Boolean;

}

}
