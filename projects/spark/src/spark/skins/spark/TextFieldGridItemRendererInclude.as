////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

/*

The implementations of DefaultGridItemRenderer (nee UIFTETExtFieldGridItemRenderer) and UITextFieldGridItemRenderer
are identical, save the superclass and constructor names.  This file contains the bulk of the code.

*/
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getQualifiedSuperclassName;
    
    import mx.core.DesignLayer;
    import mx.core.IFlexDisplayObject;
    import mx.core.IFlexModuleFactory;
    import mx.core.ILayoutDirectionElement;
    import mx.core.IToolTip;
    import mx.core.LayoutDirection;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;
    import mx.events.ToolTipEvent;
    import mx.geom.TransformOffsets;
    import mx.managers.ISystemManager;
    import mx.managers.ToolTipManager;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.IStyleClient;
    import mx.styles.StyleProtoChain;
    
    import spark.components.Grid;
    import spark.components.gridClasses.GridColumn;
    
    use namespace mx_internal;

    /**
     *  @private
     *  Distance by which this textfield is inset from the edges of the cell.
     *  See setLayoutBoundsPosition() and setLayoutBoundsSize().
     */
    private static const LEFT_PADDING:Number = 5;        
    private static const RIGHT_PADDING:Number = 5;
    private static const TOP_PADDING:Number = 4;
    private static const BOTTOM_PADDING:Number = 3;
    
    /**
     *  @private
     *  The updatePreferredSize() method only updates preferredWidth,Height if 
     *  preferredSizeInvalid is true.
     */
    private var preferredSizeInvalid:Boolean = false;
    private var preferredWidth:Number;
    private var preferredHeight:Number;
    
    /**
     *  @private
     *  A workaround for the fact that UITextField automatically calls validateNow()
     *  when its text property is set.
     */
    private var enableValidateNow:Boolean = true;

    /**
     *  @private
     *  Used to prevent changes to width,height caused by calling setLayoutBoundsSize()
     *  from updating explicitWidth,Height.
     */
    private var inSetLayoutBoundsSize:Boolean = false;

    /**
     *  @private
     *  Temporarily stores the values of styles specified with setStyle() until 
     *  moduleFactory is set.
     */
    private var deferredSetStyles:Object = null;

    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    private function dispatchChangeEvent(type:String):void
    {
        if (hasEventListener(type))
            dispatchEvent(new Event(type));
    }
    
    //----------------------------------
    //  column
    //----------------------------------
    
    private var _column:GridColumn = null;
    
    [Bindable("columnChanged")]
    
    /**
     *  @inheritDoc
     * 
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get column():GridColumn
    {
        return _column;
    }
    
    /**
     *  @private
     */
    public function set column(value:GridColumn):void
    {
        if (_column == value)
            return;
        
        _column = value;
        dispatchChangeEvent("columnChanged");
    }

    //----------------------------------
    //  column
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get columnIndex():int
    {
        return (_column) ? _column.columnIndex : -1;
    }

    
    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object = null;
    
    [Bindable("dataChange")]  // compatible with FlexEvent.DATA_CHANGE
    
    /**
     *  The value of the data provider item for the entire row of the grid control.
     *  Item renderers often bind visual element attributes to properties of this object.  
     *  
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
        if (_data == value)
            return;
        
        _data = value;
        
        const eventType:String = "dataChange"; 
        if (hasEventListener(eventType))
            dispatchEvent(new FlexEvent(eventType));        
    }
    
    //----------------------------------
    //  down
    //----------------------------------
    
    private var _down:Boolean = false;
    
    [Bindable("downChanged")]    
    
    /**
     *  <p>The grid control's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>prepare()</code>.   </p>
     * 
     *  @inheritDoc
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function get down():Boolean
    {
        return _down;
    }
    
    /**
     *  @private
     */    
    public function set down(value:Boolean):void
    {
        if (_down == value)
            return;
        
        _down = value;
        dispatchChangeEvent("downChanged");        
    }

    //----------------------------------
    //  grid
    //----------------------------------
    
    /**
     *  The grid control associated with this item renderer.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get grid():Grid
    {
        return (_column) ? _column.grid : null;
    }   

    //----------------------------------
    //  hovered
    //----------------------------------
    
    private var _hovered:Boolean = false;
    
    [Bindable("hoveredChanged")]    
    
    /**
     *  Set to <code>true</code> when the mouse is hovered over the item renderer.
     *
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */    
    public function get hovered():Boolean
    {
        return _hovered;
    }
    
    /**
     *  @private
     */    
    public function set hovered(value:Boolean):void
    {
        if (_hovered == value)
            return;
        
        _hovered = value;
        dispatchChangeEvent("hoveredChanged");        
    }
    
    //----------------------------------
    //  rowIndex
    //----------------------------------
    
    private var _rowIndex:int = -1;
    
    [Bindable("rowIndexChanged")]
    
    /**
     *  <p>The grid control's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>prepare()</code>.</p>
     * 
     *  @inheritDoc
     * 
     *  @default -1
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */    
    public function get rowIndex():int
    {
        return _rowIndex;
    }
    
    /**
     *  @private
     */    
    public function set rowIndex(value:int):void
    {
        if (_rowIndex == value)
            return;
        
        _rowIndex = value;
        dispatchChangeEvent("rowIndexChanged");        
    }
    
    //----------------------------------
    //  showsCaret
    //----------------------------------
    
    private var _showsCaret:Boolean = false;
    
    [Bindable("showsCaretChanged")]    
    
    /**
     *  <p>The grid control's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>preprare()</code>.   </p>
     * 
     *  @inheritDoc
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */    
    public function get showsCaret():Boolean
    {
        return _showsCaret;
    }
    
    /**
     *  @private
     */    
    public function set showsCaret(value:Boolean):void
    {
        if (_showsCaret == value)
            return;
        
        _showsCaret = value;
        dispatchChangeEvent("labelDisplayChanged");           
    }
    
    //----------------------------------
    //  selected
    //----------------------------------
    
    private var _selected:Boolean = false;
    
    [Bindable("selectedChanged")]    
    
    /**
     *  <p>The grid control's <code>updateDisplayList()</code> method sets this property 
     *  before calling <code>prepare()</code>.</p>
     * 
     *  @inheritDoc
     * 
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (_selected == value)
            return;
        
        _selected = value;
        dispatchChangeEvent("selectedChanged");        
    }
    
    //----------------------------------
    //  dragging
    //----------------------------------
    
    private var _dragging:Boolean = false;
    
    [Bindable("draggingChanged")]        
    
    /**
     *  @inheritDoc
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get dragging():Boolean
    {
        return _dragging;
    }
    
    /**
     *  @private  
     */
    public function set dragging(value:Boolean):void
    {
        if (_dragging == value)
            return;
        
        _dragging = value;
        dispatchChangeEvent("draggingChanged");        
    }
    
    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String = "";
    
    [Bindable("labelChanged")]
    
    /**
     *  <p>The grid control sets this property to the value of the column's 
     *  <code>itemToLabel()</code> method, before calling <code>preprare()</code>.</p>
     *
     *  @inheritDoc
     *  
     *  @default ""  
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5 
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */ 
    public function set label(value:String):void
    {
        if (_label == value)
            return;
        
        _label = value;
        preferredSizeInvalid = true;
        // Defer setting the labelDisplay's text property to avoid extra computation, see updatePreferredSize()
        
        dispatchChangeEvent("labelChanged");
    }
    
    //----------------------------------
    //  moduleFactory
    //----------------------------------

    /**
     *  @private
     */
    override public function set moduleFactory(factory:IFlexModuleFactory):void
    {
        super.moduleFactory = factory;        
        
        // Now that the module has been set, set any deferred styles.
        if (deferredSetStyles)
        {
            for (var styleProp:String in deferredSetStyles)
                StyleProtoChain.setStyle(this, styleProp, deferredSetStyles[styleProp]);
            
            deferredSetStyles = null;
        }
    }

    //----------------------------------
    //  multiline
    //----------------------------------
    
    private var multilineSet:Boolean = false;  // true if explicitly set
    
    /**
     *  @private
     */
    override public function set multiline(value:Boolean):void
    {
        super.multiline = value;
        multilineSet = true;        
    }
    
    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  @private
     *  Inherited version of this method calls validateNow().  We do not, since GridLayout will.  We're 
     *  also assuming that this property will not be set directly, but only by our updatePreferredSize()
     *  method.
     */
    override public function set text(value:String):void
    {
        enableValidateNow = false;
        super.text = value;
        preferredSizeInvalid = true;
        enableValidateNow = true;
    }
 
    //----------------------------------
    //  wordWrap
    //----------------------------------

    private var wordWrapSet:Boolean = false;  // true if explicitly set

    /**
     *  @private
     *  If set, then set the wordWrapSet flag.  This is used to enable the updatePreferredSize()
     *  method to initialize the wordWrap based on the grid's varaibleRowHeight flag, if
     *  wordWrap wasn't explicitly set.
     */
    override public function set wordWrap(value:Boolean):void
    {
        super.wordWrap = value;
        wordWrapSet = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    [Bindable(style="true")]
    /**
     *  @private 
     */
    override public function getStyle(styleProp:String):*
    {
        // If a moduleFactory has not be set yet, first check for any deferred
        // styles. If there are no deferred styles or the styleProp is not in 
        // the deferred styles, the look in the proto chain.
        if (!moduleFactory)
        {
            if (deferredSetStyles && deferredSetStyles[styleProp] !== undefined)
                return deferredSetStyles[styleProp];
        }
        
        return super.getStyle(styleProp);
    }
    
    /**
     *  @private
     */
    override public function setStyle(styleProp:String, newValue:*):void
    {
        // If there is no module factory then defer the set
        // style until a module factory is set.
        if (moduleFactory)
        {
            StyleProtoChain.setStyle(this, styleProp, newValue);
        }
        else
        {
            if (!deferredSetStyles)
                deferredSetStyles = new Object();
            deferredSetStyles[styleProp] = newValue;
        }   
    }
        
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        preferredSizeInvalid = true;
    }
    
    /**
     *  @private
     *  The renderer's measuredWidth,Height are just padded versions of the labelDisplay's
     *  textWidth,Height or explicitWidth,Height properties.  This class assumes that its
     *  size/position will be set by GridLayout with setLayoutBoundsSize,Position() and that its
     *  preferred size will be queried by GridLayout with getPreferredBoundsWidth,Height().
     */
    private function updatePreferredSize():void
    {
        if (!preferredSizeInvalid)
            return;
        
        // If the wordWrap property hasn't been explicitly set, then it's value
        // is the same as the grid's variableRowHeight property.
        
        if (!wordWrapSet && column && column.grid)
            super.wordWrap = column.grid.variableRowHeight;
   
        // Only automatically set multiline="true" if lineBreak="explicit" and the
        // text actually contains a newline, since doing so is expensive.

        if (!multilineSet && (getStyle("lineBreak") == "explicit"))
            super.multiline = _label.indexOf("\n") != -1;
        
        text = _label;
        super.validateNow();
        
        // The LEFT,RIGHT,TOP,BOTTOM padding values added here will be subtracted
        // by setLayoutBoundsPosition,Size(), they don't exist as far as the text field
        // superclass is concerned.
        
        // Both UITextField and UIFTETExtField force explicitWidth to be >= 4,
        // so we do the same here.
        
        const paddedTextWidth:Number = isNaN(explicitWidth) ? 
            textWidth + LEFT_PADDING + RIGHT_PADDING + TEXT_WIDTH_PADDING : 
            Math.max(explicitWidth, 4, LEFT_PADDING + RIGHT_PADDING + TEXT_WIDTH_PADDING);
        
        const paddedTextHeight:Number = isNaN(explicitHeight) ? 
            textHeight + TOP_PADDING + BOTTOM_PADDING + TEXT_HEIGHT_PADDING : 
            Math.max(explicitHeight, TOP_PADDING + BOTTOM_PADDING + TEXT_HEIGHT_PADDING);
        
        if (!stage || embedFonts)
        {
            preferredWidth = paddedTextWidth;
            preferredHeight = paddedTextHeight;
        }
        else 
        {
            const m:Matrix = transform.concatenatedMatrix;      
            preferredWidth = Math.abs((paddedTextWidth * m.a / m.d));
            preferredHeight  = Math.abs((paddedTextHeight * m.a / m.d));
        }
        
        GridItemRenderer.initializeRendererToolTip(this);
        
        preferredSizeInvalid = false;

    }
    
    /**
     *  @private
     */
    override public function validateNow():void
    {
        if (!enableValidateNow || !parent)
            return;
        
        updatePreferredSize(); 
    }
    
    //--------------------------------------------------------------------------
    //
    //  IGridItemRenderer Methods
    //
    //--------------------------------------------------------------------------    
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function prepare(willBeRecycled:Boolean):void
    {
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function discard(hasBeenRecycled:Boolean):void
    {
        if (!multilineSet)
            super.multiline = false;
        if (!wordWrapSet)
            super.wordWrap = false;
    }    
    
    //--------------------------------------------------------------------------
    //
    //  IVisualElement Properties, Methods
    //
    //-------------------------------------------------------------------------- 
    
    //----------------------------------
    //  width
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set width(value:Number):void  
    {
        super.width = value;
        if (!inSetLayoutBoundsSize)
        {
            explicitWidth = value;
            preferredSizeInvalid = true;
        }
    }
    
    //----------------------------------
    //  height
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set height(value:Number):void  
    {
        super.height = value;
        if (!inSetLayoutBoundsSize)
        {
            explicitHeight = value;
            preferredSizeInvalid = true;
        }
    }      
    
    /**
     *  @private
     */
    public function get depth():Number
    {
        return 0;
    }
    
    /**
     *  @private
     */
    public function set depth(value:Number):void
    {
    }
    
    /**
     *  @private
     */
    public function get designLayer():DesignLayer
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set designLayer(value:DesignLayer):void
    {
    }
    
    /**
     *  @private
     */
    public function get postLayoutTransformOffsets():TransformOffsets
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set postLayoutTransformOffsets(value:TransformOffsets):void
    {
    }
    
    /**
     *  @private
     */
    public function get is3D():Boolean
    {
        return false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  ILayoutElement Methods
    //
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     */
    public function get left():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set left(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function get right():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set right(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function get top():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set top(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function get bottom():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set bottom(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function get horizontalCenter():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set horizontalCenter(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function get verticalCenter():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set verticalCenter(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function get baseline():Object
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function set baseline(value:Object):void
    {
    }
    
    /**
     *  @private
     */
    public function getPreferredBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        updatePreferredSize();
        return preferredWidth;
    }
    
    /**
     *  @private
     */
    public function getPreferredBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
        updatePreferredSize();
        return preferredHeight;
    }
    
    /**
     *  @private
     */
    public function getMinBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        return minWidth;
    }
    
    /**
     *  @private
     */
    public function getMinBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
        return minHeight;
    }
    
    /**
     *  @private
     */
    public function getMaxBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        return maxWidth;
    }
    
    /**
     *  @private
     */
    public function getMaxBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
        return maxHeight;
    }
    
    /**
     *  @private
     */
    public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        return x - LEFT_PADDING;
    }
    
    /**
     *  @private
     */
    public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number
    {
        return y - TOP_PADDING;
    }
    
    /**
     *  @private
     */
    public function getLayoutBoundsWidth(postLayoutTransform:Boolean=true):Number
    {
        return width + LEFT_PADDING + RIGHT_PADDING;
    }
    
    /**
     *  @private
     */
    public function getLayoutBoundsHeight(postLayoutTransform:Boolean=true):Number
    {
        return height + TOP_PADDING + BOTTOM_PADDING;
    }
    
    /**
     *  @private
     */
    public function getLayoutBoundsX(postLayoutTransform:Boolean=true):Number
    {
        return x - LEFT_PADDING;
    }
    
    /**
     *  @private
     */
    public function getLayoutBoundsY(postLayoutTransform:Boolean=true):Number
    {
        return y - TOP_PADDING;
    }
    
    /**
     *  @private
     */
    public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean=true):void
    {
        move(x + LEFT_PADDING, y + TOP_PADDING);
    }
    
    /**
     *  @private
     */
    public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean=true):void
    {
        inSetLayoutBoundsSize = true;  // UI[FTE]TextField/setActualSize() sets width,height
        
        setActualSize(width - (LEFT_PADDING + RIGHT_PADDING), height - (TOP_PADDING + BOTTOM_PADDING));
        preferredSizeInvalid = true;
        
        inSetLayoutBoundsSize = false;        
    }
    
    /**
     *  @private
     */
    public function getLayoutMatrix():Matrix
    {
        return null;
    }
    
    /**
     *  @private
     */
    public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void
    { 
    }  
    
    /**
     *  @private
     */
    public function get hasLayoutMatrix3D():Boolean
    {
        return false;
    }
    
    /**
     *  @private
     */
    public function getLayoutMatrix3D():Matrix3D
    {
        return null;       
    }
    
    /**
     *  @private
     */
    public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void
    {
    }
    
    /**
     *  @private
     */
    public function transformAround(transformCenter:Vector3D,
                                    scale:Vector3D = null,
                                    rotation:Vector3D = null,
                                    translation:Vector3D = null,
                                    postLayoutScale:Vector3D = null,
                                    postLayoutRotation:Vector3D = null,
                                    postLayoutTranslation:Vector3D = null,
                                    invalidateLayout:Boolean = true):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  ILayoutDirectionElement Methods
    //
    //--------------------------------------------------------------------------     
    
    /**
     *  @inheritDoc
     *  
     *  The renderer will inherit <code>layoutDirection</code> from its parent.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get layoutDirection():String
    {
        return getStyle("layoutDirection");        
    }
    
    /**
     * @private
     */
    public function set layoutDirection(value:String):void
    {
    }

    /**
     * @private 
     */
    public function invalidateLayoutDirection():void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  IStyleClient Methods and Properties
    //  (source code from mx.controls.dataGridClassses.DataGridItemRenderer.as)
    //-------------------------------------------------------------------------- 
    
    /**
     *  @private
     */
    public function getClassStyleDeclarations():Array
    {
        var className:String = getQualifiedClassName(this).replace("::", ".");
        const styleDeclarations:Array = [];
        
        while ((className != "mx.core.UIFTETextField") && (className != "mx.core.UITextField"))
        {
            var styleDeclaration:CSSStyleDeclaration = styleManager.getMergedStyleDeclaration(className);
            if (styleDeclaration)
                styleDeclarations.unshift(styleDeclaration);
            
            try
            {
                className = getQualifiedSuperclassName(getDefinitionByName(className)).replace("::", ".");
            }
            catch(e:ReferenceError)
            {
                break;
            }
        }   
        
        return styleDeclarations;
    }
    
    /**
     *  @private
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
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function clearStyle(styleProp:String):void
    {
        setStyle(styleProp, undefined);
    }
    
    /**
     *  @private
     */
    public function regenerateStyleCache(recursive:Boolean):void
    {
        initProtoChain();
    }
    
    /**
     *  @private
     */
    public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
    {    
    }
    
    /**
     *  @private
     */
    public function registerEffects(effects:Array /* of String */):void
    {
    }    
    
    //----------------------------------
    //  styleDeclaration
    //----------------------------------
    
    private var _styleDeclaration:CSSStyleDeclaration;
    
    /**
     *  @private
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
