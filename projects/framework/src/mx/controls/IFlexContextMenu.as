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

package mx.controls
{

/**
 *  The IFlexContextMenu interface defines the interface for a 
 *  Flex context menus.  
 *
 *  @see mx.core.UIComponent#flexContextMenu
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IFlexContextMenu
{
    import flash.display.InteractiveObject;

    /**
     *  Sets the context menu of an InteractiveObject.  This will do 
     *  all the necessary steps to add the InteractiveObject as the context 
     *  menu for this InteractiveObject, such as adding listeners, etc..
     * 
     *  @param component InteractiveObject to set context menu on
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function setContextMenu(component:InteractiveObject):void;
    
    /**
     *  Unsets the context menu of a InteractiveObject.  This will do 
     *  all the necessary steps to remove the InteractiveObject as the context 
     *  menu for this InteractiveObject, such as removing listeners, etc..
     * 
     *  @param component InteractiveObject to unset context menu on
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function unsetContextMenu(component:InteractiveObject):void;

}

}
