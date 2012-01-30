////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.windowClasses
{

import flash.display.DisplayObject;
import flash.display.NativeWindowDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.Capabilities;

import mx.core.IWindow;
import mx.core.mx_internal;

import spark.components.Button;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.TextBase;
import spark.primitives.BitmapImage;
import spark.skins.*;
import spark.skins.spark.windowChrome.MacTitleBarSkin;
import spark.skins.spark.windowChrome.TitleBarSkin;

use namespace mx_internal;

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *  The title bar is enabled and the application is maximized.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("normalAndMaximized")]

/**
 *  The title bar is disabled and the application is maximized.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabledAndMaximized")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusThickness", kind="style")]

/**
 *  The TitleBar class defines the default title bar for a 
 *  WindowedApplication or a Window container.
 * 
 *  @see mx.core.Window
 *  @see mx.core.WindowedApplication
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TitleBar extends SkinnableComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static function isMac():Boolean
    {
        return Capabilities.os.substring(0, 3) == "Mac";
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function TitleBar():void
    {
        super();

        doubleClickEnabled = true;
        
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This is the actual object created from the _titleIcon class
     */
    mx_internal var titleIconObject:Object;

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  closeButton
    //----------------------------------

    /**
     *  The skin part that defines the Button control that corresponds to the close button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="true")]
    public var closeButton:Button;

    //----------------------------------
    //  maximizeButton
    //----------------------------------

    /**
     *  The skin part that defines the Button control that corresponds to the maximize button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var maximizeButton:Button;

    //----------------------------------
    //  minimizeButton
    //----------------------------------

    /**
     *  The skin part that defines the Button control that corresponds to the minimize button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var minimizeButton:Button;
    
    //----------------------------------
    //  titleIconImage
    //----------------------------------

    /**
     *  The title icon in the TitleBar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var titleIconImage:BitmapImage;

    //----------------------------------
    //  titleTextField
    //----------------------------------

    /**
     *  The skin part that defines the UITextField control that displays the application title text.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    [SkinPart (required="false")]
    public var titleText:TextBase;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  title
    //----------------------------------

    /**
     *  Storage for the title property.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private var _title:String = "";

    /**
     *  @private
     */
    private var titleChanged:Boolean = false;

    /**
     *  The title that appears in the window title bar and
     *  the dock or taskbar.
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get title():String
    {
        return _title;
    }

    /**
     *  @private
     */
    public function set title(value:String):void
    {
        _title = value;
        titleChanged = true;

        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }

    //----------------------------------
    //  titleIcon
    //----------------------------------

    /**
     *  @private
     *  Storage for the titleIcon property.
     */
    private var _titleIcon:Class;

    /**
     *  @private
     */
    private var titleIconChanged:Boolean = false;

    /**
     *  The icon displayed in the title bar.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get titleIcon():Class
    {
        return _titleIcon;
    }

    /**
     *  @private
     */
    public function set titleIcon(value:Class):void
    {
        _titleIcon = value;
        titleIconChanged = true;

        invalidateProperties();
        invalidateSize();
    }

    //----------------------------------
    //  window
    //----------------------------------

    /**
     *  The IWindow that owns this TitleBar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    private function get window():IWindow
    {
        var p:DisplayObject = parent;
        
        while (p && !(p is IWindow))
            p = p.parent;
            
        return IWindow(p);
    }


    //--------------------------------------------------------------------------
    //
    //  Overridden methods: SkinnableComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     * 
     *  When we are running on the mac, switch to the mac skin and continue the load.
     * 
     */
    override protected function attachSkin():void
    {
       if (isMac() && getStyle("skinClass") == TitleBarSkin)
       {
            setStyle("skinClass", MacTitleBarSkin);  
       } 
       
       super.attachSkin();
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: SkinnableContainer
    //
    //--------------------------------------------------------------------------

    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == titleText)
        {
            titleText.text = title;
        }
        else if (instance == closeButton)
        {
            closeButton.focusEnabled = false;
            closeButton.addEventListener(MouseEvent.MOUSE_DOWN, button_mouseDownHandler);
            closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);
        }
        else if (instance == minimizeButton)
        {
            minimizeButton.focusEnabled = false;
            minimizeButton.enabled = window.minimizable;
            minimizeButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                            button_mouseDownHandler);
            minimizeButton.addEventListener(MouseEvent.CLICK,
                                            minimizeButton_clickHandler);
        }
        else if (instance == maximizeButton)
        {
            maximizeButton.focusEnabled = false;
            maximizeButton.enabled = window.maximizable;
            maximizeButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                            button_mouseDownHandler);
            maximizeButton.addEventListener(MouseEvent.CLICK,
                                            maximizeButton_clickHandler);
        }
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {       
        super.partRemoved(partName, instance);
        
        if (instance == closeButton)
        {
            closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
        }
        else if (instance == minimizeButton)
        {
            minimizeButton.removeEventListener(MouseEvent.MOUSE_DOWN,
                                            button_mouseDownHandler);
            minimizeButton.removeEventListener(MouseEvent.CLICK,
                                            minimizeButton_clickHandler);
        }
        else if (instance == maximizeButton)
        {
            maximizeButton.removeEventListener(MouseEvent.MOUSE_DOWN,
                                            button_mouseDownHandler);
            maximizeButton.removeEventListener(MouseEvent.CLICK,
                                            maximizeButton_clickHandler);
        }
        
    }

    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (titleChanged)
        {
            titleText.text = _title;
            titleChanged = false;   
        }

        if (titleIconChanged)
        {
            if (titleIconObject)
            {
                titleIconImage.source = null;
                titleIconObject = null;
            }
            
            if (_titleIcon && titleIconImage)
            {
                titleIconObject = new _titleIcon();
                titleIconImage.source = titleIconObject;
            }
            titleIconChanged = false;
        }
        
    }



    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    // Skin states support
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the name of the state to be applied to the skin. For example, a
     *  Button component could return the String "up", "down", "over", or "disabled" 
     *  to specify the state.
     * 
     *  <p>A subclass of SkinnableComponent must override this method to return a value.</p>
     * 
     *  @return A string specifying the name of the state to apply to the skin.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String 
    {
        if (window.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
            return enabled ? "normalAndMaximized" : "disabledAndMaximized";
            
        return enabled ? "normal" : "disabled";
    }    
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function mouseDownHandler(event:MouseEvent):void
    {
        window.nativeWindow.startMove();
        
        event.stopPropagation();
    }
    
    /**
     *  The method that handles a <code>doubleClick</code> event in a platform-appropriate manner.
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function doubleClickHandler(event:MouseEvent):void
    {
        if (isMac())
        {
            window.minimize();
        }
        else
        {
            if (window.nativeWindow.displayState ==
                NativeWindowDisplayState.MAXIMIZED)
            {
                window.restore();
            }
            else
            {
                window.maximize();
            }
        }
    }
    
    /**
     *  @private
     *  Used to swallow mousedown so bar is not draggable from buttons
     */
    private function button_mouseDownHandler(event:MouseEvent):void
    {
        event.stopPropagation();
    }

    /**
     *  @private
     */
    private function minimizeButton_clickHandler(event:Event):void
    {
        window.minimize();
    }
    
    /**
     *  @private
     */
    private function maximizeButton_clickHandler(event:Event):void
    {
        if (window.nativeWindow.displayState ==
            NativeWindowDisplayState.MAXIMIZED)
        {
            window.restore();
        }
        else
        {
            window.maximize();
        }
        
        // work around for bugs SDK-9547 & SDK-21190
        maximizeButton.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));

        invalidateSkinState();

    }
    
    /**
     *  @private
     */
    private function closeButton_clickHandler(event:Event):void
    {
        window.close();
    }
}

}
