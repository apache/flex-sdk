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

package mx.controls.advancedDataGridClasses
{
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;

import mx.controls.AdvancedDataGrid;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.IDataRenderer;
import mx.core.IFlexDisplayObject;
import mx.core.IToolTip;
import mx.core.UIComponentGlobals;
import mx.core.UIFTETextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.InterManagerRequest;
import mx.events.ToolTipEvent;
import mx.managers.ILayoutManagerClient;
import mx.managers.ISystemManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleClient;
import mx.styles.StyleProtoChain;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the <code>data</code> property changes.
 *
 *  <p>When you use a component as an item renderer,
 *  the <code>data</code> property contains the data to display.
 *  You can listen for this event and update the component
 *  when the <code>data</code> property changes.</p>
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  The FTEAdvancedDataGridItemRenderer class defines the default item renderer for an
 *  AdvancedDataGrid control used with FTEText. 
 *  By default, the item renderer 
 *  draws the text associated with each item in the grid.
 *
 *  <p>You can override the default item renderer by creating a custom item renderer.</p>
 *
 *  @see mx.controls.AdvancedDataGrid
 *  @see mx.core.IDataRenderer
 *  @see mx.controls.listClasses.IDropInListItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class FTEAdvancedDataGridItemRenderer extends UIFTETextField
                                  implements IDataRenderer,
                                  IDropInListItemRenderer, ILayoutManagerClient,
                                  IListItemRenderer, IStyleClient
{
    include "../../../spark/core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function FTEAdvancedDataGridItemRenderer()
    {
        super();

        tabEnabled = false;
        mouseWheelEnabled = false;

        ignorePadding = false;

        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);
        
        inheritingStyles = nonInheritingStyles =
            StyleProtoChain.STYLE_UNINITIALIZED;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var invalidatePropertiesFlag:Boolean = false;
    
    /**
     *  @private
     */
    private var invalidateSizeFlag:Boolean = false;
	
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  nestLevel
    //----------------------------------

    /**
     *  @private
     */
    override public function set nestLevel(value:int):void
    {
        super.nestLevel = value;
    
        UIComponentGlobals.layoutManager.invalidateProperties(this);
        invalidatePropertiesFlag = true;
        
        UIComponentGlobals.layoutManager.invalidateSize(this);
        invalidateSizeFlag = true;
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
     */
    private var _data:Object;

    [Bindable("dataChange")]

    /**
     *  The implementation of the <code>data</code> property as 
     *  defined by the IDataRenderer interface.
     *  The value is ignored.  Only the <code>listData</code> property is used.
     *
     *  @see mx.core.IDataRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
		
        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }

    //----------------------------------
    //  listData
    //----------------------------------

    /**
     *  @private
     */
    private var _listData:AdvancedDataGridListData;

    [Bindable("dataChange")]
    
    /**
     *  The implementation of the <code>listData</code> property as 
     *  defined by the IDropInListItemRenderer interface.
     *  The text of the renderer is set to the <code>label</code>
     *  property of this property.
     *
     *  @see mx.controls.listClasses.IDropInListItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get listData():BaseListData
    {
        return _listData;
    }

    /**
     *  @private
     */
    public function set listData(value:BaseListData):void
    {
        _listData = AdvancedDataGridListData(value);
        if (nestLevel && !invalidatePropertiesFlag)
        {
            UIComponentGlobals.layoutManager.invalidateProperties(this);
            invalidatePropertiesFlag = true;
            UIComponentGlobals.layoutManager.invalidateSize(this);
            invalidateSizeFlag = true;
        }
    }

    //----------------------------------
    //  styleDeclaration
    //----------------------------------

    /**
     *  @private
     *  Storage for the styleDeclaration property.
     */
    private var _styleDeclaration:CSSStyleDeclaration;

    /**
     *  Storage for the inline inheriting styles on this object.
     *  This CSSStyleDeclaration is created the first time that 
     *  the <code>setStyle()</code> method 
     *  is called on this component to set an inheriting style.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get styleDeclaration():CSSStyleDeclaration
    {
        return _styleDeclaration;
    }

    /**
     *  @private
     */
    public function set styleDeclaration(value:CSSStyleDeclaration):void
    {
        _styleDeclaration = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UITextField
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function initialize():void
    {
        regenerateStyleCache(false)
    }

    /**
     *  @private
     */
    override public function validateNow():void
    {
        if (data && parent)
        {
			var adg:AdvancedDataGrid = AdvancedDataGrid(_listData.owner);
            var newColor:Number;

            if (adg.isItemHighlighted(_listData.uid))
            {
                newColor = getStyle("textRollOverColor");
            }
            else if (adg.isItemSelected(_listData.uid))
            {
                newColor = getStyle("textSelectedColor");
            }
            else
            {
                newColor = getStyle("color");
            }

            if (newColor != explicitColor)
            {
                styleChangedFlag = true;
                explicitColor = newColor;
                invalidateDisplayList();
            }
        }

        super.validateNow();
    }

    /**
     *  @copy mx.core.UIComponent#getStyle()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function getStyle(styleProp:String):*
    {
        return (styleManager.inheritingStyles[styleProp]) ?        
            inheritingStyles[styleProp] : nonInheritingStyles[styleProp];
    }

    /**
     *  @copy mx.core.UIComponent#setStyle()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function setStyle(styleProp:String, newValue:*):void
    {
        if (styleProp == "styleName")
        {
            // Let the setter handle this one, see UIComponent.
            styleName = newValue;

            // Short circuit, because styleName isn't really a style.
            return;
        }

        /*
        if (styleProp == "themeColor")
        {
            // setThemeColor handles the side effects.
            setThemeColor(newValue);

            // Do not short circuit, because themeColor is a style.
            // It just has side effects, too.
        }
        */

        // If this UIComponent didn't previously have any inline styles,
        // then regenerate the UIComponent's proto chain (and the proto chains
        // of this UIComponent's descendants).
        var isInheritingStyle:Boolean =
            styleManager.isInheritingStyle(styleProp);
        var isProtoChainInitialized:Boolean =
            inheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED;
        if (isInheritingStyle)
        {
            if (getStyle(styleProp) == newValue && isProtoChainInitialized)
                return;

            if (!styleDeclaration)
            {
                styleDeclaration = new CSSStyleDeclaration(null, styleManager);
                styleDeclaration.setLocalStyle(styleProp, newValue);

                // If inheritingStyles is undefined, then this object is being
                // initialized and we haven't yet generated the proto chain.  To
                // avoid redundant work, don't bother to create the proto chain here.
                if (isProtoChainInitialized)
                    regenerateStyleCache(true);
            }
            else
            {
                styleDeclaration.setLocalStyle(styleProp, newValue);
            }
        }
        else
        {
            if (getStyle(styleProp) == newValue && isProtoChainInitialized)
                return;

            if (!styleDeclaration)
            {
                styleDeclaration = new CSSStyleDeclaration(null, styleManager);
                styleDeclaration.setLocalStyle(styleProp, newValue);

                // If nonInheritingStyles is undefined, then this object is being
                // initialized and we haven't yet generated the proto chain.  To
                // avoid redundant work, don't bother to create the proto chain here.
                if (isProtoChainInitialized)
                    regenerateStyleCache(false);
            }
            else
            {
                styleDeclaration.setLocalStyle(styleProp, newValue);
            }
        }

        if (isProtoChainInitialized)
        {
            styleChanged(styleProp);
            notifyStyleChangeInChildren(styleProp, isInheritingStyle);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  If Flex calls the <code>LayoutManager.invalidateProperties()</code> 
     *  method on this ILayoutManagerClient,  
     *  this function is called when it's time to commit property values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function validateProperties():void
    {
        invalidatePropertiesFlag = false;
        if (_listData)
        {
            var dg:AdvancedDataGrid = AdvancedDataGrid(_listData.owner);

            var column:AdvancedDataGridColumn =
                dg.mx_internal::rawColumns[_listData.columnIndex];

            text = _listData.label;
            
            if (_data is AdvancedDataGridColumn)
                wordWrap = dg.columnHeaderWordWrap(column);
            else
                wordWrap = dg.columnWordWrap(column);
            
            if (dg.variableRowHeight)
                multiline = true;
            
            var dataTips:Boolean = dg.showDataTips;
            if (column.showDataTips == true)
                dataTips = true;
            if (column.showDataTips == false)
                dataTips = false;
            if (dataTips)
            {
                if (!(_data is AdvancedDataGridColumn) && (textWidth > width 
                    || column.dataTipFunction || column.dataTipField 
                    || dg.dataTipFunction || dg.dataTipField))
                {
                    toolTip = column.itemToDataTip(_data);
                }
                else
                {
                    toolTip = null;
                }
            }
            else
            {
                toolTip = null;
            }
        }
        else
        {
            text = " ";
            toolTip = null;
        }
    }

    /**
     *  If Flex calls the <code>LayoutManager.invalidateSize()</code>
     *  method on this ILayoutManagerClient,  
     *  this function is called when it's time to do measurements.
     *
     *  @param recursive If <code>true</code>, call this method
     *  on the object's children.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function validateSize(recursive:Boolean = false):void
    {
        invalidateSizeFlag = false;
        validateNow();
    }

    /**
     *  If Flex calls <code>LayoutManager.invalidateDisplayList()</code> 
     *  method on this ILayoutManagerClient instance,  
     *  this function is called when it's time to update the display list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function validateDisplayList():void
    {
        validateNow();
    }

    /**
     *  @copy mx.core.UIComponent#clearStyle()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function clearStyle(styleProp:String):void
    {
        setStyle(styleProp, undefined);
    }

    /**
     *  @copy mx.core.UIComponent#notifyStyleChangeInChildren()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function notifyStyleChangeInChildren(
                        styleProp:String, recursive:Boolean):void
    {    
    }

    /**
     *  Sets up the <code>inheritingStyles</code> 
     *  and <code>nonInheritingStyles</code> objects
     *  and their proto chains so that the <code>getStyle()</code> method can work.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function initProtoChain():void
    {
        styleChangedFlag = true;
        
        var classSelectors:Array = [];
        
        if (styleName)
        {
            if (styleName is CSSStyleDeclaration)
            {
                // Get the style sheet referenced by the styleName property
                classSelectors.push(CSSStyleDeclaration(styleName));
            }
            else if (styleName is IFlexDisplayObject)
            {
                // If the styleName property is a UIComponent, then there's a
                // special search path for that case.
                StyleProtoChain.initProtoChainForUIComponentStyleName(this);
                return;
            }
            else if (styleName is String)
            {
                // Get the style sheet referenced by the styleName property
                var styleNames:Array = styleName.split(/\s+/);
                for (var c:int=0; c < styleNames.length; c++)
                {
                    if (styleNames[c].length) {
                        classSelectors.push(styleManager.getMergedStyleDeclaration("." + 
                            styleNames[c]));
                    }
                }
            }
        }
        
        // To build the proto chain, we start at the end and work forward.
        // Referring to the list at the top of this function, we'll start by
        // getting the tail of the proto chain, which is:
        //  - for non-inheriting styles, the global style sheet
        //  - for inheriting styles, my parent's style object
        var nonInheritChain:Object = styleManager.stylesRoot;
        
        var p:IStyleClient = parent as IStyleClient;
        if (p)
        {
            var inheritChain:Object = p.inheritingStyles;
            if (inheritChain == StyleProtoChain.STYLE_UNINITIALIZED)
                inheritChain = nonInheritChain;
        }
        else
        {
            inheritChain = styleManager.stylesRoot;
        }
        
        // Working backwards up the list, the next element in the
        // search path is the type selector
        var typeSelectors:Array = getClassStyleDeclarations();
        var n:int = typeSelectors.length;
        for (var i:int = 0; i < n; i++)
        {
            var typeSelector:CSSStyleDeclaration = typeSelectors[i];
            inheritChain = typeSelector.addStyleToProtoChain(inheritChain, this);
            nonInheritChain = typeSelector.addStyleToProtoChain(nonInheritChain, this);
        }
        
        // Next are the class selectors
        for (i = 0; i < classSelectors.length; i++)
        {
            var classSelector:CSSStyleDeclaration = classSelectors[i];
            if (classSelector)
            {
                inheritChain = classSelector.addStyleToProtoChain(inheritChain, this);
                nonInheritChain = classSelector.addStyleToProtoChain(nonInheritChain, this);
            }
        }
        
        // Finally, we'll add the in-line styles
        // to the head of the proto chain.
        inheritingStyles = styleDeclaration ?
            styleDeclaration.addStyleToProtoChain(inheritChain, this) :
            inheritChain;
        
        nonInheritingStyles = styleDeclaration ?
            styleDeclaration.addStyleToProtoChain(nonInheritChain, this) :
            nonInheritChain;
    }

    /**
     *  @copy mx.core.UIComponent#regenerateStyleCache()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function regenerateStyleCache(recursive:Boolean):void
    {
        initProtoChain();
    }

    /**
     *  @copy mx.core.UIComponent#registerEffects()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function registerEffects(effects:Array /* of String */):void
    {
    }

    /**
     *  @copy mx.core.UIComponent#getClassStyleDeclarations()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getClassStyleDeclarations():Array
    {
        var className:String = getQualifiedClassName(this)
        className = className.replace("::", ".");

        var decls:Array = [];

        while (className != null &&
               className != "mx.core.UIComponent" &&
               className != "mx.core.UIFTETextField")
        {
            var s:CSSStyleDeclaration =
                styleManager.getMergedStyleDeclaration(className);
            
            if (s)
            {
                decls.unshift(s);
            }
            
            try
            {
                className = getQualifiedSuperclassName(getDefinitionByName(className));
                className = className.replace("::", ".");
            }
            catch(e:ReferenceError)
            {
                className = null;
            }
        }   

        return decls;
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  The event handler to position the tooltip.
     *
     *  @param event The event object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function toolTipShowHandler(event:ToolTipEvent):void
    {
        var toolTip:IToolTip = event.toolTip;
        
        // Calculate global position of label.
        var sm:ISystemManager = systemManager.topLevelSystemManager;
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        var screen:Rectangle;
        var pt:Point = new Point(0, 0);
        pt = localToGlobal(pt);
        pt = sbRoot.globalToLocal(pt);          
        
        toolTip.move(pt.x, pt.y + (height - toolTip.height) / 2);
        
        screen = sm.getVisibleApplicationRect(null, true);
        
        var screenRight:Number = screen.x + screen.width;
        pt.x = toolTip.x;
        pt.y = toolTip.y;
        pt = sbRoot.localToGlobal(pt);
        if (pt.x + toolTip.width > screenRight)
            toolTip.move(toolTip.x - (pt.x + toolTip.width - screenRight), toolTip.y);
    }
}

}