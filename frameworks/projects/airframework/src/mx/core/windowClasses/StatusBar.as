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
import flash.events.Event;
import mx.core.WindowedApplication;
import mx.core.IFlexDisplayObject;
import mx.core.IUITextField;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.styles.StyleManager;

use namespace mx_internal;

/**
 *  The default status bar for a WindowedApplication or a Window.
 * 
 *  @see mx.core.Window
 *  @see mx.core.WindowedApplication
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class StatusBar extends UIComponent
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
    public function StatusBar():void
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  A reference to the status bar's skin.
     */
    mx_internal var statusBarBackground:IFlexDisplayObject;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  status
    //----------------------------------

    /**
     *  @private
     *  Storage for the status property.
     */
    private var _status:String = "";
    
    /**
     *  @private
     */
    private var statusChanged:Boolean = false;
    
    /**
     *  The string that appears in the status bar, if it is visible.
     * 
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get status():String
    {
        return _status;
    }    

    /**
     *  @private
     */
    public function set status(value:String):void
    {
        _status = value;
        statusChanged = true;
        
        invalidateProperties();
        invalidateSize();
    }
    
    //----------------------------------
    //  statusTextField
    //----------------------------------

    /**
     *  A reference to the UITextField that displays the status bar's text.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var statusTextField:IUITextField;
    
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

        var statusBarBackgroundClass:Class =
            getStyle("statusBarBackgroundSkin");
        if (statusBarBackgroundClass) 
        {
            statusBarBackground = new statusBarBackgroundClass();
            var backgroundUIComponent:IStyleClient =
                statusBarBackground as IStyleClient;     
            if (backgroundUIComponent)
            {
                backgroundUIComponent.setStyle("backgroundImage",
                                               undefined);
            }
            var backgroundStyleable:ISimpleStyleClient =
                statusBarBackground as ISimpleStyleClient;
            if (backgroundStyleable)
                backgroundStyleable.styleName = this;
            addChild(DisplayObject(statusBarBackground));
        }
      
        if (!statusTextField)
        {
            statusTextField = IUITextField(createInFontContext(UITextField));
            statusTextField.text = _status;
            statusTextField.styleName = getStyle("statusTextStyleName");
            statusTextField.enabled = true;
            addChild(DisplayObject(statusTextField));
        }
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();

        if (statusChanged)
        {
            statusTextField.text = _status;
            statusChanged = false;
        }
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();

        statusTextField.validateNow();
        if (statusTextField.textHeight == 0)
        {
            statusTextField.text = " ";
            statusTextField.validateNow();
        }

        measuredHeight = statusTextField.textHeight +
                         UITextField.TEXT_HEIGHT_PADDING;
        measuredWidth = statusTextField.textWidth;
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        statusBarBackground.setActualSize(unscaledWidth, unscaledHeight);
        statusTextField.text = _status;
        statusTextField.width = unscaledWidth;
        statusTextField.truncateToFit("...");
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        invalidateDisplayList();
        
        var allStyles:Boolean = !styleProp || styleProp == "styleName";
        
        if (allStyles || styleProp == "statusBarBackgroundSkin")
        {
            var statusBarBackgroundClass:Class =
                getStyle("statusBarBackgroundSkin");
            if (statusBarBackgroundClass) 
            {
                if (statusBarBackground)
                {
                      removeChild(DisplayObject(statusBarBackground));
                      statusBarBackground = null;
                }
                statusBarBackground = new statusBarBackgroundClass();
                var backgroundUIComponent:IStyleClient =
                    statusBarBackground as IStyleClient;     
                if (backgroundUIComponent)
                {
                    backgroundUIComponent.setStyle("backgroundImage",
                                                   undefined);
                }
                var backgroundStyleable:ISimpleStyleClient =
                    statusBarBackground as ISimpleStyleClient;
                if (backgroundStyleable)
                    backgroundStyleable.styleName = this;
                addChildAt(DisplayObject(statusBarBackground), 0);
            }
        }

        if (allStyles || styleProp == "statusTextStyleName")
        {
            if (statusTextField)
                statusTextField.styleName = getStyle("statusTextStyleName");
        }
    }
}

}
