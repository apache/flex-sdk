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

/*
 *  The methods here would normally just be in IInteractiveObject,
 *  but for backward compatibility, their ancestor methods have to be included
 *  directly into IFlexDisplayObject, so these also have to be kept in 
 *  this separate include file so it can be used in ITextField
 */

    /**
     *  @copy flash.display.InteractiveObject#tabEnabled
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get tabEnabled():Boolean;
    function set tabEnabled(enabled:Boolean):void;
    
    /** 
     *  @copy flash.display.InteractiveObject#tabIndex
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get tabIndex():int;
    function set tabIndex(index:int):void;
    
    /** 
     *  @copy flash.display.InteractiveObject#focusRect
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get focusRect():Object; 
    function set focusRect(focusRect:Object):void;
    
    /** 
     *  @copy flash.display.InteractiveObject#mouseEnabled
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get mouseEnabled():Boolean;
    function set mouseEnabled(enabled:Boolean):void;
    
    /** 
     *  @copy flash.display.InteractiveObject#doubleClickEnabled
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get doubleClickEnabled():Boolean;
    function set doubleClickEnabled(enabled:Boolean):void;
    
    /** 
     *  @private
    function get accessibilityImplementation() : AccessibilityImplementation;
    function set accessibilityImplementation( value : AccessibilityImplementation ) : void;
     */
    
