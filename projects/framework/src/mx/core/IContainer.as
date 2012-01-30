////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

import mx.managers.IFocusManager;

/**
 *  IContainer is a interface that indicates a component
 *  extends or mimics mx.core.Container
 *
 *  @see mx.core.Container
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IContainer extends IUIComponent
{

include "ISpriteInterface.as"
include "IDisplayObjectContainerInterface.as"
include "IInteractiveObjectInterface.as"

    /**
     *  @copy mx.core.Container#defaultButton
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get defaultButton():IFlexDisplayObject;
    function set defaultButton(value:IFlexDisplayObject):void;

    /**
     *  @copy mx.core.Container#creatingContentPane
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get creatingContentPane():Boolean;
    function set creatingContentPane(value:Boolean):void;

    /**
     *  @copy mx.core.Container#viewMetrics
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get viewMetrics():EdgeMetrics;

    /**
     *  @copy mx.core.Container#horizontalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get horizontalScrollPosition():Number;
    function set horizontalScrollPosition(value:Number):void;

    /**
     *  @copy mx.core.Container#verticalScrollPosition
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get verticalScrollPosition():Number;
    function set verticalScrollPosition(value:Number):void;

    /**
     *  @copy mx.core.UIComponent#focusManager
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get focusManager():IFocusManager;
}

}
