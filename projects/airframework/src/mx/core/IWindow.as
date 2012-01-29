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

import flash.display.NativeWindow;

/**
 *  The IWindow interface defines the API for components that serve as top-level
 *  containers in Flex-based AIR applications (containers that represent operating
 *  system windows).
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IWindow
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  maximizable
    //----------------------------------

    /**
     *  Specifies whether the window can be maximized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get maximizable():Boolean;
    
    //----------------------------------
    //  minimizable
    //----------------------------------

    /**
     *  Specifies whether the window can be minimized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get minimizable():Boolean;
    
    //----------------------------------
    //  nativeWindow
    //----------------------------------

    /**
     *  The underlying NativeWindow that the Window component uses.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get nativeWindow():NativeWindow

    //----------------------------------
    //  resizable
    //----------------------------------

    /**
     *  Specifies whether the window can be resized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get resizable():Boolean;
    
    //----------------------------------
    //  status
    //----------------------------------

    /**
     *  The string that appears in the status bar, if it is visible.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get status():String;
    
    /**
     *  @private
     */
    function set status(value:String):void;
    
    //----------------------------------
    //  systemChrome
    //----------------------------------

    /**
     *  Specifies the type of system chrome (if any) the window has.
     *  The set of possible values is defined by the constants
     *  in the NativeWindowSystemChrome class.
     *
     *  @see flash.display.NativeWindowSystemChrome
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get systemChrome():String;
    
    //----------------------------------
    //  title
    //----------------------------------

    /**
     *  The title text that appears in the window title bar and
     *  the taskbar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get title():String;
    
    /**
     *  @private
     */
    function set title(value:String):void;
    
    //----------------------------------
    //  titleIcon
    //----------------------------------

    /**
     *  The Class (usually an image) used to draw the title bar icon.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get titleIcon():Class;
    
    /**
     *  @private
     */
    function set titleIcon(value:Class):void;
    
    //----------------------------------
    //  transparent
    //----------------------------------

    /**
     *  Specifies whether the window is transparent.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get transparent():Boolean;
    
    //----------------------------------
    //  type
    //----------------------------------

    /**
     *  Specifies the type of NativeWindow that this component
     *  represents. The set of possible values is defined by the constants
     *  in the NativeWindowType class.
     *
     *  @see flash.display.NativeWindowType
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get type():String;
    
    //----------------------------------
    //  visible
    //----------------------------------

    /**
     *  Controls the window's visibility.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get visible():Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Closes the window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function close():void;
    
    /**
     *  Maximizes the window, or does nothing if it's already maximized.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function maximize():void
    
    /**
     *  Minimizes the window.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function minimize():void;
    
    /**
     *  Restores the window (unmaximizes it if it's maximized, or
     *  unminimizes it if it's minimized).
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function restore():void;
}

}
