////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core.windowClasses
{

import flash.display.DisplayObject;
import flash.display.NativeWindowDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.controls.Button;
import mx.core.IFlexDisplayObject;
import mx.core.IUITextField;
import mx.core.IWindow;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.Platform;

use namespace mx_internal;

/**
 *  The default title bar for a WindowedApplication or a Window.
 * 
 *  @see mx.core.Window
 *  @see mx.core.WindowedApplication
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class TitleBar extends UIComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  A reference to this Application's title bar skin.
     *  This is a child of the titleBar.
     */
    mx_internal var titleBarBackground:IFlexDisplayObject;
    
    /**
     *  @private
     *  This is the actual object created from the _titleIcon class
     */
    mx_internal var titleIconObject:Object;

    /**
     *  @private
     */
    private var minimizeButtonSkin:Class;

    /**
     *  @private
     */
    private var maximizeButtonSkin:Class;

    /**
     *  @private
     */
    private var restoreButtonSkin:Class;

    /**
     *  @private
     */
    private var closeButtonSkin:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  closeButton
    //----------------------------------

    /**
     *  The Button object that defines the close button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var closeButton:Button;

    //----------------------------------
    //  maximizeButton
    //----------------------------------

    /**
     *  The Button object that defines the maximize button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var maximizeButton:Button;

    //----------------------------------
    //  minimizeButton
    //----------------------------------

    /**
     *  The Button object that defines the minimize button.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var minimizeButton:Button;
    
    //----------------------------------
    //  title
    //----------------------------------

    /**
     *  Storage for the title property.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
    //  titleTextField
    //----------------------------------

    /**
     *  The UITextField in the title bar that displays the application title.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var titleTextField:IUITextField;

    //----------------------------------
    //  window
    //----------------------------------

    /**
     *  The IWindow that owns this TitleBar.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    private function get window():IWindow
    {
        return IWindow(parent);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        var titleBarBackgroundClass:Class =
            getStyle("titleBarBackgroundSkin");
        if (titleBarBackgroundClass)
        {
            if (!titleBarBackground)
            {
                titleBarBackground = new titleBarBackgroundClass();
                var titleBackgroundUIComponent:IStyleClient =
                    titleBarBackground as IStyleClient;
                if (titleBackgroundUIComponent)
                {
                    titleBackgroundUIComponent.setStyle(
                        "backgroundImage", undefined);
                }
                var titleBackgroundStyleable:ISimpleStyleClient =
                    titleBarBackground as ISimpleStyleClient;
                if (titleBackgroundStyleable)
                    titleBackgroundStyleable.styleName = this;
                addChild(DisplayObject(titleBarBackground));
            }
        }

        if (!titleTextField)
        {
            titleTextField = IUITextField(createInFontContext(UITextField));
            titleTextField.text = _title;
            titleTextField.styleName = getStyle("titleTextStyleName");
            titleTextField.enabled = true;
            addChild(DisplayObject(titleTextField));
        }

        if (!titleIconObject && _titleIcon)
        {
            titleIconObject = new _titleIcon();
            addChild(DisplayObject(titleIconObject));
        }

        if (!minimizeButton)
        {
            minimizeButton = new Button();
            minimizeButtonSkin = getStyle("minimizeButtonSkin");
            if (minimizeButtonSkin)
                 minimizeButton.setStyle("skin", minimizeButtonSkin);
            minimizeButton.focusEnabled = false;
            minimizeButton.enabled = window.minimizable;
            minimizeButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                            button_mouseDownHandler);
            minimizeButton.addEventListener(MouseEvent.CLICK,
                                            minimizeButton_clickHandler);
            addChild(minimizeButton);
        }

        if (!maximizeButton)
        {
            maximizeButton = new Button();
            maximizeButtonSkin = getStyle("maximizeButtonSkin");
            if (maximizeButtonSkin)
                maximizeButton.setStyle("skin", maximizeButtonSkin);
            maximizeButton.focusEnabled = false;
            maximizeButton.enabled = window.maximizable;
            maximizeButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                            button_mouseDownHandler);
            maximizeButton.addEventListener(MouseEvent.CLICK,
                                            maximizeButton_clickHandler);
            addChild(maximizeButton);

            restoreButtonSkin = Platform.isMac ? null : getStyle("restoreButtonSkin");
        }

        if (!closeButton)
        {
            closeButton = new Button();
            closeButtonSkin = getStyle("closeButtonSkin");
            if (closeButtonSkin)
                closeButton.setStyle("skin", closeButtonSkin);
            closeButton.focusEnabled = false;
            closeButton.addEventListener(MouseEvent.MOUSE_DOWN,
                                         button_mouseDownHandler);
            closeButton.addEventListener(MouseEvent.CLICK,
                                         closeButton_clickHandler);
            addChild(closeButton);
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
            titleTextField.text = _title;
            titleChanged = false;   
        }

        if (titleIconChanged)
        {
            if (titleIconObject)
            {
                removeChild(DisplayObject(titleIconObject));
                titleIconObject = null;
            }
            if (_titleIcon)
            {
                titleIconObject = new _titleIcon();
                addChild(DisplayObject(titleIconObject));
            }
            titleIconChanged = false;
        }
    }

    /**
     *  @private
     */             
    override protected function measure():void
    {
        super.measure();

        titleTextField.validateNow();
        if (titleTextField.textHeight == 0)
        {
            titleTextField.text = " ";
            titleTextField.validateNow();
        }

        measuredHeight = Math.max((titleTextField.textHeight +
                         UITextField.TEXT_HEIGHT_PADDING),
                         Math.max(maximizeButton.measuredHeight,
                         minimizeButton.measuredHeight,
                         closeButton.measuredHeight) + 12);
        measuredWidth = titleTextField.width +
                        maximizeButton.measuredWidth +
                        minimizeButton.measuredWidth +
                        closeButton.measuredWidth;
        
        if (titleIconObject)
        {
            measuredHeight = Math.max(measuredHeight,
                                      titleIconObject.height + 1);
            measuredWidth += titleIconObject.width;
        }
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // If window is closed, we need to exit.
        if (window.nativeWindow.closed)
            return;
            
        var leftOffset:Number = 0;
        var rightOffset:Number = 5;

        // Account for rounded corners.
        var cornerOffset:int = getStyle("cornerRadius") / 2;
        
        // Position the titleBarBackground within the titleBar.
        if (titleBarBackground)
        {
            titleBarBackground.move(0, 0);
            IFlexDisplayObject(titleBarBackground).setActualSize(
                unscaledWidth, unscaledHeight);
        }

        // Position the titleIconObject
        if (titleIconObject)
        {
            var h:int = titleIconObject.height;
            var offset:int = (height - h) / 2;
            titleIconObject.move(cornerOffset, offset);
            leftOffset += cornerOffset + titleIconObject.width +
                          getStyle("buttonPadding");
        }

        // If we're on Windows, check to see if we're maximized or not.
        if (!Platform.isMac)
        {
            if (window.nativeWindow.displayState ==
                NativeWindowDisplayState.MAXIMIZED)
            {
                if (restoreButtonSkin)
                    maximizeButton.setStyle("skin", restoreButtonSkin);
            }
            else
            {
                maximizeButton.setStyle("skin", maximizeButtonSkin);
            }
        }

        var buttonAlign:String = getStyle("buttonAlignment");
        if (buttonAlign == "right")
        {
            placeButtons(buttonAlign, width, height,
                         leftOffset, rightOffset, cornerOffset);
        }
        else if (buttonAlign == "left")
        {
            placeButtons(buttonAlign,width,
                         height, leftOffset, rightOffset, cornerOffset);
        }
        else
        {
            if (Platform.isMac)
            {
                buttonAlign = "left";
                placeButtons("left", width, height,
                             leftOffset, rightOffset, cornerOffset);
            }
            else
            {
                placeButtons("right", width, height,
                             leftOffset, rightOffset, cornerOffset);
            }
        }

        var titleAlign:String =
            String(getStyle("titleAlignment"));
        if (titleAlign == "center" || titleAlign == "left")
            placeTitle(titleAlign, leftOffset, rightOffset, buttonAlign);
        else if (Platform.isMac)
            placeTitle("center",  leftOffset, rightOffset, buttonAlign);
        else
            placeTitle("left",  leftOffset, rightOffset, buttonAlign);
    }

    /**
     *  Called by the StyleManager when a style changes.
     *
     *  @param styleProp the name of the style that's changed.
     *  In some cases, it can be null, usually when changing
     *  the global style or styleName.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        invalidateDisplayList();
        
        var allStyles:Boolean = !styleProp || styleProp == "styleName";

        if (allStyles || styleProp == "titleBarBackgroundSkin")
        {
            var titleBarBackgroundClass:Class =
                getStyle("titleBarBackgroundSkin");
    
            if (titleBarBackgroundClass)
            {
                // Remove existing background
                if (titleBarBackground)
                {
                    removeChild(DisplayObject(titleBarBackground));
                    titleBarBackground = null;
                }
                titleBarBackground = new titleBarBackgroundClass();
                var titleBackgroundUIComponent:IStyleClient =
                    titleBarBackground as IStyleClient;
                if (titleBackgroundUIComponent)
                {
                    titleBackgroundUIComponent.setStyle(
                        "backgroundImage", undefined);
                }
                var titleBackgroundStyleable:ISimpleStyleClient =
                    titleBarBackground as ISimpleStyleClient;
                if (titleBackgroundStyleable)
                    titleBackgroundStyleable.styleName = this;
                addChildAt(DisplayObject(titleBarBackground), 0);
            }
        }
        
        if (allStyles || styleProp == "titleTextStyleName")
        {
            if (titleTextField)
                titleTextField.styleName = getStyle("titleTextStyleName");
        }
        
        if (allStyles || styleProp == "closeButtonSkin")
        {
            closeButtonSkin = getStyle("closeButtonSkin");
            if (closeButtonSkin && closeButton)
                closeButton.setStyle("skin", closeButtonSkin);
        }

        if (allStyles || styleProp == "maximizeButtonSkin")
        {
            maximizeButtonSkin = getStyle("maximizeButtonSkin");
            if (maximizeButtonSkin && maximizeButton)
                maximizeButton.setStyle("skin", maximizeButtonSkin);
        }

        if (allStyles || styleProp == "minimizeButtonSkin")
        {
            minimizeButtonSkin = getStyle("minimizeButtonSkin");
            if (minimizeButtonSkin && minimizeButton)
                 minimizeButton.setStyle("skin", minimizeButtonSkin);
        }

        if (allStyles || styleProp == "restoreButtonSkin")
        {
            restoreButtonSkin = getStyle("restoreButtonSkin");
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Determines the placement of the buttons in the title bar.
     *
     *  @param align button alignment
     *
     *  @param unscaledWidth width of the title bar
     *
     *  @param unscaledHeight height of the title bar
     *
     *  @param leftOffset how much space to allow on left for corners, etc.
     *
     *  @param rightOffset how much space to allow on right for corners, etc.
     *
     *  @param cornerOffset how much to indent things to take into account
     *  corner radius
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function placeButtons(align:String,
                                    unscaledWidth:Number, unscaledHeight:Number,
                                    leftOffset:Number, rightOffset:Number,
                                    cornerOffset:Number):void
    {
        var pad:Number = getStyle("buttonPadding");
        var edgePad:Number = getStyle("titleBarButtonPadding");

        minimizeButton.setActualSize(minimizeButton.measuredWidth,
                                     minimizeButton.measuredHeight);
        maximizeButton.setActualSize(maximizeButton.measuredWidth,
                                     maximizeButton.measuredHeight);
        closeButton.setActualSize(closeButton.measuredWidth,
                                  closeButton.measuredHeight);

        if (align == "right")
        {
            minimizeButton.move(
                unscaledWidth - (minimizeButton.measuredWidth +
                maximizeButton.measuredWidth + closeButton.measuredWidth +
                (2 * pad)) - cornerOffset - edgePad,
                (unscaledHeight - minimizeButton.measuredHeight) / 2);

            maximizeButton.move(
                unscaledWidth - (maximizeButton.measuredWidth +
                closeButton.measuredWidth + pad) - cornerOffset - edgePad,
                (unscaledHeight - maximizeButton.measuredHeight) / 2);

            closeButton.move(
                unscaledWidth - closeButton.measuredWidth -
                cornerOffset - edgePad,
                (unscaledHeight - closeButton.measuredHeight) / 2);
        }
        else
        {
            edgePad = Math.max(edgePad, leftOffset);

            closeButton.move(
                edgePad,
                (unscaledHeight - closeButton.measuredHeight) / 2);

            minimizeButton.move(
                pad + edgePad + closeButton.measuredWidth,
                (unscaledHeight - minimizeButton.measuredHeight) / 2);

            maximizeButton.move(
                edgePad + (pad * 2) +
                closeButton.measuredWidth + minimizeButton.measuredWidth,
                (unscaledHeight - maximizeButton.measuredHeight) / 2);
        }
    }

    /**
     *  Determines the alignment of the title in the title bar.
     *
     *  @param titleAlign how to align the title.
     *
     *  @param leftOffset how much space to allow on left for corners, etc.
     *
     *  @param rightOffset how much space to allow on right for corners, etc.
     *
     *  @param buttonAlign the way the buttons are aligned
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function placeTitle(titleAlign:String,
                                  leftOffset:Number, rightOffset:Number,
                                  buttonAlign:String):void
    {
        titleTextField.text = _title;
        titleTextField.validateNow();

        var buttonsX:Number; // x point between buttons and title text
        
        if( buttonAlign == "left" )
        {
            buttonsX = Math.max((closeButton.x + closeButton.measuredWidth),
                        (minimizeButton.x + minimizeButton.measuredWidth),
                        (maximizeButton.x + maximizeButton.measuredWidth));
        }
        else
        {
            buttonsX = Math.min(closeButton.x, minimizeButton.x, maximizeButton.x);
        }

        if (titleAlign == "left")
        {
            if (buttonAlign == "left")
            {
                titleTextField.setActualSize(
                    width - rightOffset - 2 - buttonsX,
                    measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING);

                titleTextField.move(
                    buttonsX,
                    (height - (measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING))/2);

                titleTextField.truncateToFit();
            }
            else
            {
                titleTextField.setActualSize(
                    Math.max(0, buttonsX) - 2,
                    measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING);

                titleTextField.move(
                    leftOffset,
                    (height - (measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING))/2);

                titleTextField.truncateToFit();
            }
        }
        else // titleAlign is center
        {
            var tf:TextFormat = new TextFormat();
            tf.align = TextFormatAlign.LEFT;
            titleTextField.setTextFormat(tf);

            var titleX:Number;
            var textWidth:Number = titleTextField.getLineMetrics( 0 ).width;
            titleTextField.truncateToFit();
            
            if (buttonAlign == "left")
            {
                titleTextField.setActualSize(
                    width - rightOffset - buttonsX - 2,
                    measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING);

                titleX = Math.max(buttonsX, (width - leftOffset - rightOffset - textWidth)/2);
                
                titleTextField.move(titleX,
                    (height - (measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING))/2);
            }
            else
            {
                titleTextField.setActualSize(
                    width - leftOffset - rightOffset -
                    (width - buttonsX) - 2,
                    measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING);

                titleX = Math.max(0, Math.min(buttonsX - textWidth - 2, (width - leftOffset - rightOffset - textWidth)/2));
                
                titleTextField.move(
                    titleX,
                    (height - (measureChromeText(titleTextField).height +
                    UITextField.TEXT_HEIGHT_PADDING))/2);
            }
        }
    }

    /**
     *  @private
     */
    private function measureChromeText(textField:IUITextField):Rectangle
    {
        var textWidth:Number = 20;
        var textHeight:Number = 14;

        if (textField && textField.text)
        {
            textField.validateNow();
            textWidth = textField.textWidth;
            textHeight = textField.textHeight;
        }

        return new Rectangle(0, 0, textWidth, textHeight);
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
     *  @private
     *  Handles a <code>doubleClick</code> event in a platform-appropriate manner.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function doubleClickHandler(event:MouseEvent):void
    {
        if (Platform.isMac)
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
