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
package 
{
    
import flash.display.DisplayObject;
import mx.controls.MenuBar;
import mx.core.IFlexDisplayObject; 
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.ISimpleStyleClient;
import mx.controls.CheckBox;
import mx.controls.menuClasses.IMenuBarItemRenderer;

public class MyMenuBarItemRenderer extends UIComponent implements IMenuBarItemRenderer
    {
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var leftMargin:int = 100;
    
    private var newCheckBox:CheckBox;
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor
     */
    public function MyMenuBarItemRenderer()
    {
        super();
        mouseChildren = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  currentSkin
    //----------------------------------

    /**
     *  The skin defining the border and background for this MenuBarItemRenderer.
     */
    public var currentSkin:IFlexDisplayObject;
    
    //----------------------------------
    //  icon
    //----------------------------------

    /**
     *  The internal IFlexDisplayObject that displays the icon in this MenuBarItemRenderer.
     */
    protected var icon:IFlexDisplayObject;

    //----------------------------------
    //  label
    //----------------------------------

    /**
     *  The internal UITextField that displays the text in this MenuBarItemRenderer.
     */
    protected var label:UITextField;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @private
     */
    private var enabledChanged:Boolean = false;

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        if (super.enabled == value)
            return;
            
        super.enabled = value;
        enabledChanged = true;

        invalidateProperties();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @private
     *  Storage for the data property.
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>data</code> property
     *  as defined by the IDataRenderer interface.
     *  When set, it stores the value and invalidates the component 
     *  to trigger a relayout of the component.
     *
     *  @see mx.core.IDataRenderer
     */
    public function get data():Object
    {
        return _data;
    }

    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        _data = value;
        invalidateProperties();
        
        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    //----------------------------------
    //  menuBar
    //----------------------------------

    /**
     *  @private
     *  Storage for the menuBar property. 
     */
    private var _menuBar:MenuBar;

    /**
     *  The implementation of the <code>menuBar</code> property
     *  as defined by the IMenuBarItemRenderer interface.  
     * 
     *  @see mx.controls.menuClasses.IMenuBarItemRenderer@menuBar
     */
    public function get menuBar():MenuBar
    {
        return _menuBar;
    }

    /**
     *  @private
     */
    public function set menuBar(value:MenuBar):void
    {
        _menuBar = value;
    }   
        
    //----------------------------------
    //  menuBarItemIndex
    //----------------------------------

    /**
     *  @private
     *  Storage for the menuBarItemIndex property. 
     */
    private var _menuBarItemIndex:int = -1;

     /**
     *  The implementation of the <code>menuBarItemIndex</code> property
     *  as defined by the IMenuBarItemRenderer interface.  
     * 
     *  @see mx.controls.menuClasses.IMenuBarItemRenderer@menuBarItemIndex
     */
    public function get menuBarItemIndex():int
    {
        return _menuBarItemIndex;
    }

    /**
     *  @private
     */
    public function set menuBarItemIndex(value:int):void
    {
        _menuBarItemIndex = value;
    }   
    
    //----------------------------------
    //  menuBarItemState
    //----------------------------------

    /**
     *  @private
     *  Storage for the menuBarItemState property. 
     */
    private var _menuBarItemState:String;

    /**
     *  The implementation of the <code>menuBarItemState</code> property
     *  as defined by the IMenuBarItemRenderer interface.  
     * 
     *  @see mx.controls.menuClasses.IMenuBarItemRenderer@menuBarItemState
     */
    public function get menuBarItemState():String
    {
        return _menuBarItemState;
    }

    /**
     *  @private
     */
    public function set menuBarItemState(value:String):void
    {
        _menuBarItemState = value;
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
        
        var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
        styleDeclaration.factory = function():void
        {
            this.borderStyle = "none"
        };

        if (!label)
        {
            label = new UITextField();
            label.styleName = this;
            label.selectable = false;
            addChild(label);
        }
        
        newCheckBox = new CheckBox();
        newCheckBox.label = "";
        addChild (newCheckBox);

        menuBarItemState = "itemUpSkin";
    }
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        var iconClass:Class;
        
        if (enabledChanged)
        {
            enabledChanged = false;
            if (label)
                label.enabled = enabled;

            if (!enabled)
                menuBarItemState = "itemUpSkin";
        }
        
        //Remove any existing icons. 
        //These will be recreated below if needed.
        if (icon)
        {
            removeChild(DisplayObject(icon));
            icon = null;
        }
        
        if (_data)
        {
            iconClass = menuBar.itemToIcon(data);
            if (iconClass)
            {
                icon = new iconClass();
                addChild(DisplayObject(icon));
            }
            
            label.visible = true;
            var labelText:String;
            if (menuBar.labelFunction != null)
                labelText = menuBar.labelFunction(_data);
            if (labelText == null)
                labelText = menuBar.itemToLabel(_data);
            label.text = labelText;
            label.enabled = enabled;
            label.setStyle("color", 0xFF0000);
        }
        else
        {
            label.text = " ";
        }
        
        // Invalidate layout here to ensure icons are positioned correctly.
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        if (icon && leftMargin < icon.measuredWidth)
        {
            leftMargin = icon.measuredWidth;
        }
        measuredWidth = label.getExplicitOrMeasuredWidth() + leftMargin;
        measuredHeight = label.getExplicitOrMeasuredHeight();
        
        if (icon && icon.measuredHeight > measuredHeight)
            measuredHeight = icon.measuredHeight + 2;
    }   
        
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        if (icon)
        {
            icon.x = (leftMargin - icon.measuredWidth) / 2;
            icon.setActualSize(icon.measuredWidth, icon.measuredHeight);
            label.x = leftMargin;
        }
        else
            label.x = leftMargin / 2;
            
        label.setActualSize(unscaledWidth - leftMargin, 
            label.getExplicitOrMeasuredHeight());
            
        label.y = (unscaledHeight - label.height) / 2;
        
        newCheckBox.y = label.y + 7;
    }    
         
}
}