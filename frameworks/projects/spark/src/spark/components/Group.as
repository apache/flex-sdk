////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components 
{

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import mx.core.IFontContextComponent;
import mx.core.IUIComponent;
import mx.core.IUITextField;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.styles.StyleProtoChain;

import spark.components.supportClasses.GroupBase;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.core.ISharedDisplayObject;
import spark.events.ElementExistenceEvent;
import spark.components.supportClasses.TextBase;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when a visual element is added to the content holder.
 *  <code>event.element</code> is the visual element that was added.
 *
 *  @eventType spark.events.ElementExistenceEvent.ELEMENT_ADD
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="elementAdd", type="spark.events.ElementExistenceEvent")]

/**
 *  Dispatched when a visual element is removed to the content holder.
 *  <code>event.element</code> is the visual element that's being removed.
 *
 *  @eventType spark.events.ElementExistenceEvent.ELEMENT_REMOVE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="elementRemove", type="spark.events.ElementExistenceEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="addChild", kind="method")]
[Exclude(name="addChildAt", kind="method")]
[Exclude(name="removeChild", kind="method")]
[Exclude(name="removeChildAt", kind="method")]
[Exclude(name="setChildIndex", kind="method")]
[Exclude(name="swapChildren", kind="method")]
[Exclude(name="swapChildrenAt", kind="method")]
[Exclude(name="numChildren", kind="property")]
[Exclude(name="getChildAt", kind="method")]
[Exclude(name="getChildIndex", kind="method")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("components")]

[DefaultProperty("mxmlContent")] 

[IconFile("Group.png")]

/**
 *  The Group class is the base container class for visual elements.
 *  The Group container take as children any components that implement 
 *  the IUIComponent interface, and any components that implement 
 *  the IGraphicElement interface. 
 *  Use this container when you want to manage visual children, 
 *  both visual components and graphical components. 
 *
 *  <p>To improve performance and minimize application size, 
 *  the Group container cannot be skinned. 
 *  If you want to apply a skin, use the SkinnableContainer instead.</p>
 * 
 *  <p>Note: scale grid may not function correctly when there 
 *  are DisplayObject children inside of the Group, such as a component 
 *  or another Group.  If the children are GraphicElements and 
 *  they all share the Group's DisplayObject, then scale grid will work 
 *  properly.</p> 
 * 
 *  <p>Setting any of the following properties on a GraphicElement child
 *  will require that GraphicElement to create its own DisplayObject,
 *  thus negating the scale grid properties on the Group.</p>  
 * 
 *  <pre>
 *  alpha
 *  blendMode other than BlendMode.NORMAL
 *  colorTransform
 *  filters
 *  mask
 *  matrix
 *  rotation
 *  scaling
 *  3D properties
 *  bounds outside the extent of the Group
 *  </pre>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Group&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Group
 *    <strong>Properties</strong>
 *    blendMode="auto"
 *    mxmlContent="null"
 *    scaleGridBottom="null"
 *    scaleGridLeft="null"
 *    scaleGridRight="null"
 *    scaleGridTop="null"
 *  
 *    <strong>Events</strong>
 *    elementAdd="<i>No default</i>"
 *    elementRemove="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.DataGroup
 *  @see spark.components.SkinnableContainer
 *
 *  @includeExample examples/GroupExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Group extends GroupBase implements IVisualElementContainer, ISharedDisplayObject
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Group():void
    {
        super();    
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var needsDisplayObjectAssignment:Boolean = false;
    private var layeringMode:uint = ITEM_ORDERED_LAYERING;
    private var numGraphicElements:uint = 0;
    
    private static const ITEM_ORDERED_LAYERING:uint = 0;
    private static const SPARSE_LAYERING:uint = 1;    

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function set resizeMode(value:String):void
    {
        if (isValidScaleGrid())
        {
            // Force the resize mode to be scale if we 
            // have set scaleGrid properties
            value = ResizeMode.SCALE;
        }
         
        super.resizeMode = value;
    }
    
    /**
     *  @private
     */
    override public function set scrollRect(value:Rectangle):void
    {
        // Work-around for Flash Player bug: if GraphicElements share
        // the Group's Display Object and cacheAsBitmap is true, the
        // scrollRect won't function correctly. 
        var previous:Boolean = canShareDisplayObject;
        super.scrollRect = value;
        if (numGraphicElements > 0 && previous != canShareDisplayObject)
            invalidateDisplayObjectOrdering();            
    }

    /**
     * @private
     */  
    override mx_internal function set hasMouseListeners(value:Boolean):void
    {
        if (mouseEnabledWhereTransparent)
            redrawRequested = true;
        super.hasMouseListeners = value;
    }  

    /**
     *  @private
     */
    override public function set width(value:Number):void
    {
        if (_width != value)
        {
            if (mouseEnabledWhereTransparent && hasMouseListeners)
            {        
                // Re-render our mouse event fill if necessary.
                redrawRequested = true;
                super.$invalidateDisplayList();
            }
        }
        super.width = value;
    }
    
    /**
     *  @private
     */
    override public function set height(value:Number):void
    {
        if (_height != value)
        {
            if (mouseEnabledWhereTransparent && hasMouseListeners)
            {        
                // Re-render our mouse event fill if necessary.
                redrawRequested = true;
                super.$invalidateDisplayList();
            }
        }
        super.height = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  alpha
    //----------------------------------

    [Inspectable(defaultValue="1.0", category="General", verbose="1")]

    /**
     *  @private
     */
    override public function set alpha(value:Number):void
    {
        if (super.alpha == value)
            return;
        
        if (value > 0 && value < 1 && !blendModeExplicitlySet && _blendMode == "auto")
        {
            _blendMode = BlendMode.LAYER;
            blendModeChanged = true;
            invalidateDisplayObjectOrdering();
            invalidateProperties();
        }
        else if ((value == 1 || value == 0) && !blendModeExplicitlySet && _blendMode == "auto")
        {
            _blendMode = BlendMode.NORMAL;
            blendModeChanged = true;
            invalidateDisplayObjectOrdering();
            invalidateProperties();
        }
        
        super.alpha = value;
    }
    
    //----------------------------------
    //  blendMode
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the blendMode property.
     */
    private var _blendMode:String = "auto";  
    private var blendModeChanged:Boolean;
    private var blendModeExplicitlySet:Boolean;

    [Inspectable(category="General", enumeration="auto,add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay,colordodge,colorburn,exclusion,softlight,hue,saturation,color,luminosity", defaultValue="auto")]

    /**
     *  A value from the BlendMode class that specifies which blend mode to use. 
     *  A bitmap can be drawn internally in two ways. 
     *  If you have a blend mode enabled or an external clipping mask, the bitmap is drawn 
     *  by adding a bitmap-filled square shape to the vector render. 
     *  If you attempt to set this property to an invalid value, 
     *  Flash Player or Adobe AIR sets the value to <code>BlendMode.NORMAL</code>. 
     *
     *  @default "auto"
     *
     *  @see flash.display.DisplayObject#blendMode
     *  @see flash.display.BlendMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get blendMode():String
    {
        return _blendMode; 
    }
    
    /**
     *  @private
     */
    override public function set blendMode(value:String):void
    {
        if (blendModeExplicitlySet && value == _blendMode)
            return;
        
    	// FIXME (dsubrama): Temporarily exit when blendMode is set
    	// to one of the AIM blendModes; support for this will come
    	// shortly. 
        if (value == "colordodge" || 
        	value =="colorburn" || value =="exclusion" || 
        	value =="softlight" || value =="hue" || 
        	value =="saturation" || value =="color" 
        	|| value =="luminosity")
            return;
        
        //The default blendMode in FXG is 'auto'. There are only
        //certain cases where this results in a rendering difference,
        //one being when the alpha of the Group is > 0 and < 1. In that
        //case we set the blendMode to layer to avoid the performance
        //overhead that comes with a non-normal blendMode. 
        
        if (alpha > 0 && alpha < 1 && !blendModeExplicitlySet && value == "auto")
        {
            if (_blendMode != BlendMode.LAYER)
            {
                _blendMode = BlendMode.LAYER;
                blendModeChanged = true;
                invalidateDisplayObjectOrdering();
                invalidateProperties();
            }
        }
        else if ((alpha == 1 || alpha == 0) && !blendModeExplicitlySet && value == "auto")
        {
            if (_blendMode != BlendMode.NORMAL)
            {
                _blendMode = BlendMode.NORMAL;
                blendModeChanged = true;
                invalidateDisplayObjectOrdering();
                invalidateProperties();
            }
        }

        else 
        {
            var oldValue:String = _blendMode;
            _blendMode = value;
            blendModeExplicitlySet = true;
            blendModeChanged = true;
        
            // Only need to re-do display object assignment if blendmode was normal
            // and is changing to something else, or the blend mode was something else 
            // and is going back to normal.  This is because display object sharing
            // only happens when blendMode is normal.
            if ((oldValue == BlendMode.NORMAL || value == BlendMode.NORMAL) && 
                !(oldValue == BlendMode.NORMAL && value == BlendMode.NORMAL))
            {
                invalidateDisplayObjectOrdering();
            }
        
            invalidateProperties();
        }
    }

    //----------------------------------
    //  mxmlContent
    //----------------------------------

    private var mxmlContentChanged:Boolean = false;
    private var _mxmlContent:Array;

    [ArrayElementType("mx.core.IVisualElement")]

    /**
     *  The visual content children for this Group.
     * 
     *  This method is used internally by Flex and is not intended for direct
     *  use by developers.
     *
     *  <p>The content items should only be IVisualElement objects.  
     *  An <code>mxmlContent</code> Array should not be shared between multiple
     *  Group containers because visual elements can only live in one container 
     *  at a time.</p>
     * 
     *  <p>If the content is an Array, do not modify the Array 
     *  directly. Use the methods defined by the Group class instead.</p>
     *
     *  @default null
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set mxmlContent(value:Array):void
    {
        if (createChildrenCalled)
        {
            setMXMLContent(value);
        }
        else
        {
            mxmlContentChanged = true;
            _mxmlContent = value;
            // we will validate this in createChildren();
        }
    }
    
    /**
     *  @private
     */
    mx_internal function getMXMLContent():Array
    {
        if (_mxmlContent)
            return _mxmlContent.concat();
        else
            return null;
    }
    
   /**
     *  @private
     *  Adds the elements in <code>mxmlContent</code> to the Group.
     *  Flex calls this method automatically; you do not call it directly.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    private function setMXMLContent(value:Array):void
    {
        var i:int;
        
        // if there's old content and it's different than what 
        // we're trying to set it to, then let's remove all the old 
        // elements first.
        if (_mxmlContent != null && _mxmlContent != value)
        {
            for (i = _mxmlContent.length - 1; i >= 0; i--)
            {
                elementRemoved(_mxmlContent[i], i);
            }
        }
        
        _mxmlContent = (value) ? value.concat() : null;  // defensive copy
        
        if (_mxmlContent != null)
        {
            var n:int = _mxmlContent.length;
            for (i = 0; i < n; i++)
            {   
                var elt:IVisualElement = _mxmlContent[i];

                // A common mistake is to bind the viewport property of an Scroller
                // to a group that was defined in the MXML file with a different parent    
                if (elt.parent && (elt.parent != this))
                    throw new Error(resourceManager.getString("components", "mxmlElementNoMultipleParents", [elt]));

                elementAdded(elt, i);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: ScaleGrid
    //
    //--------------------------------------------------------------------------

    private var scaleGridChanged:Boolean = false;
    
    // store the scaleGrid into a rectangle to save space (top, left, bottom, right);
    private var scaleGridStorageVariable:Rectangle;

    //----------------------------------
    //  scale9Grid
    //----------------------------------
    
    /**
     *  @private
     */
    override public function set scale9Grid(value:Rectangle):void
    {
        if (value != null)
        {
            scaleGridTop = value.top;
            scaleGridBottom = value.bottom;
            scaleGridLeft = value.left;
            scaleGridRight = value.right;
        }
        else
        {
            scaleGridTop = NaN;
            scaleGridBottom = NaN;
            scaleGridLeft = NaN;
            scaleGridRight = NaN;
        }
    }

    //----------------------------------
    //  scaleGridBottom
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     *  Specifies the bottom coordinate of the scale grid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleGridBottom():Number
    {
        if (scaleGridStorageVariable)
            return scaleGridStorageVariable.height;
        
        return NaN;
    }
    
    public function set scaleGridBottom(value:Number):void
    {
        if (!scaleGridStorageVariable)
            scaleGridStorageVariable = new Rectangle(NaN, NaN, NaN, NaN);
        
        if (value != scaleGridStorageVariable.height)
        {
            scaleGridStorageVariable.height = value;
            scaleGridChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  scaleGridLeft
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specifies the left coordinate of the scale grid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleGridLeft():Number
    {
        if (scaleGridStorageVariable)
            return scaleGridStorageVariable.x;
        
        return NaN;
    }
    
    public function set scaleGridLeft(value:Number):void
    {
        if (!scaleGridStorageVariable)
            scaleGridStorageVariable = new Rectangle(NaN, NaN, NaN, NaN);
        
        if (value != scaleGridStorageVariable.x)
        {
            scaleGridStorageVariable.x = value;
            scaleGridChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }

    }

    //----------------------------------
    //  scaleGridRight
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specifies the right coordinate of the scale grid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleGridRight():Number
    {
        if (scaleGridStorageVariable)
            return scaleGridStorageVariable.width;
        
        return NaN;
    }
    
    public function set scaleGridRight(value:Number):void
    {
        if (!scaleGridStorageVariable)
            scaleGridStorageVariable = new Rectangle(NaN, NaN, NaN, NaN);
        
        if (value != scaleGridStorageVariable.width)
        {
            scaleGridStorageVariable.width = value;
            scaleGridChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }

    }

    //----------------------------------
    //  scaleGridTop
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specifies the top coordinate of the scale grid.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleGridTop():Number
    {
        if (scaleGridStorageVariable)
            return scaleGridStorageVariable.y;
        
        return NaN;
    }
    
    public function set scaleGridTop(value:Number):void
    {
        if (!scaleGridStorageVariable)
            scaleGridStorageVariable = new Rectangle(NaN, NaN, NaN, NaN);
        
        if (value != scaleGridStorageVariable.y)
        {
            scaleGridStorageVariable.y = value;
            scaleGridChanged = true;
            invalidateProperties();
            invalidateDisplayList();
        }
    } 
    
    private function isValidScaleGrid():Boolean
    {
        return !isNaN(scaleGridLeft) &&
               !isNaN(scaleGridTop) &&
               !isNaN(scaleGridRight) &&
               !isNaN(scaleGridBottom);
    }
      
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Whether createChildren() has been called or not.
     *  We use this in the setter for mxmlContent to know 
     *  whether to validate the value immediately, or just 
     *  wait to let createChildren() do it.
     */
    private var createChildrenCalled:Boolean = false;
    
    /**
     *  @private
     */ 
    override protected function createChildren():void
    {
        super.createChildren();
        
        createChildrenCalled = true;
        
        if (mxmlContentChanged)
        {
            mxmlContentChanged = false;
            setMXMLContent(_mxmlContent);
        }
    }
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (blendModeChanged)
        {
            blendModeChanged = false;
            if (_blendMode == "auto" && alpha < 1 && alpha > 0)
                super.blendMode = BlendMode.LAYER;
            else if (_blendMode == "auto" && alpha == 1 || alpha == 0)
                super.blendMode = BlendMode.NORMAL;
            else 
                super.blendMode = _blendMode; 
        }
        
        if (needsDisplayObjectAssignment)
        {
            needsDisplayObjectAssignment = false;
            assignDisplayObjects();
        }
        
        if (scaleGridChanged)
        {
            // Don't reset scaleGridChanged since we also check it in updateDisplayList
            if (isValidScaleGrid())
                resizeMode = ResizeMode.SCALE; // Force the resizeMode to scale 
        }
        
        // FIXME (egeorgie): we need to optimize this, iterating through all the elements is slow.
        // Validate element properties
        if (numGraphicElements > 0)
        {
            var length:int = numElements;
            for (var i:int = 0; i < length; i++)
            {
                var element:IGraphicElement = getElementAt(i) as IGraphicElement;
                if (element)
                    element.validateProperties();
            }
        }
    }
    
    /**
     *  @private
     */
    override public function validateSize(recursive:Boolean = false):void
    {
        // Since IGraphicElement is not ILayoutManagerClient, we need to make sure we
        // validate sizes of the elements, even in cases where recursive==false.
        
        // FIXME (egeorgie): we need to optimize this, iterating through all the elements is slow.
        // Validate element size
        if (numGraphicElements > 0)
        {
            var length:int = numElements;
            for (var i:int = 0; i < length; i++)
            {
                var element:IGraphicElement = getElementAt(i) as IGraphicElement;
                if (element)
                    element.validateSize();
            }
        }

        super.validateSize(recursive);
    }   
    
    /**
     *  @private
     */  
    override public function setActualSize(w:Number, h:Number):void
    {
        if (_width != w || _height != h)
        {
            if (mouseEnabledWhereTransparent && hasMouseListeners)
            {        
                // Re-render our mouse event fill if necessary.
                redrawRequested = true;
                super.$invalidateDisplayList();
            }
        }

        super.setActualSize(w, h);
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {       
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // If the DisplayObject assignment is still not completed, then postpone validation
        // of the GraphicElements
        if (needsDisplayObjectAssignment && invalidatePropertiesFlag)
            return;
        
        // Clear the group's graphic because graphic elements might be drawing to it
        // This isn't needed for DataGroup because there's no DisplayObject sharing
        var sharedDisplayObject:ISharedDisplayObject = this;
        if (sharedDisplayObject.redrawRequested)
        {
            graphics.clear();
            renderFillForMouseOpaque();
            
            // If a scaleGrid is set, make sure the extent of the groups bounds are filled so
            // the player will scale our contents as expected. 
            if (isValidScaleGrid() && resizeMode == ResizeMode.SCALE)
            {
                graphics.lineStyle();
                graphics.beginFill(0, 0);
                graphics.drawRect(0, 0, 1, 1);
                graphics.drawRect(measuredWidth - 1, measuredHeight - 1, 1, 1);
                graphics.endFill();
            }
        }
                
        // Iterate through the graphic elements. If an element has a displayObject that has been 
        // invalidated, then validate all graphic elements that draw to this displayObject. 
        // The algorithm assumes that all of the elements that share a displayObject are in between
        // the element with the shared displayObject and the next element that has a displayObject.
        if (numGraphicElements > 0)
        {
            var length:int = numElements;
            for (var i:int = 0; i < length; i++)
            {
                var element:IGraphicElement = getElementAt(i) as IGraphicElement;
                if (!element)
                   continue;

                // Do a special check for layer, we may stumble upon an element with layer != 0
                // before we're done with the current shared sequence and we don't want to mark
                // the sequence as valid, until we reach the next sequence.   
                if (element.depth == 0)
                {
                    // Is this the start of a new shared sequence?          
                    if (element.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT)
                    {
                        // We have finished redrawing the previous sequence
                        if (sharedDisplayObject)
                            sharedDisplayObject.redrawRequested = false;
                        
                        // Start the new sequence
                        sharedDisplayObject = element.displayObject as ISharedDisplayObject;
                    }
                    
                    if (!sharedDisplayObject || sharedDisplayObject.redrawRequested) 
                        element.validateDisplayList();
                }
                else
                {
                    // If we have layering, we don't share the display objects.
                    // Don't update the current sharedDisplayObject 
                    var elementDisplayObject:ISharedDisplayObject = element.displayObject as ISharedDisplayObject;
                    if (!elementDisplayObject || elementDisplayObject.redrawRequested)
                    {
                       element.validateDisplayList();

                       if (elementDisplayObject)
                           elementDisplayObject.redrawRequested = false;
                    }
                }
            }
        }
            
        // Mark the last shared displayObject valid
        if (sharedDisplayObject)
            sharedDisplayObject.redrawRequested = false;
        
        if (scaleGridChanged)
        {
            scaleGridChanged = false;
        
            if (isValidScaleGrid())
            {
                if (numChildren > 0)
                    throw new Error(resourceManager.getString("components", "scaleGridGroupError"));

                super.scale9Grid = new Rectangle(scaleGridLeft, 
                                           scaleGridTop,    
                                           scaleGridRight - scaleGridLeft, 
                                           scaleGridBottom - scaleGridTop);
            } 
            else
            {
                super.scale9Grid = null;
            }                              
        }
    }

    /**
     *  @private
     *  TODO (rfrishbe): Most of this code is a duplicate of UIComponent::notifyStyleChangeInChildren,
     *  refactor as appropriate to avoid code duplication once we have a common
     *  child iterator between UIComponent and Group.
     */ 
    override public function notifyStyleChangeInChildren(
                        styleProp:String, recursive:Boolean):void
    {
        if (mxmlContentChanged || !recursive) 
            return;
            
        var n:int = numElements;
        for (var i:int = 0; i < n; i++)
        {
            var child:ISimpleStyleClient = getElementAt(i) as ISimpleStyleClient;
            if (child)
            {
                child.styleChanged(styleProp);
                
                if (child is IStyleClient)
                    IStyleClient(child).notifyStyleChangeInChildren(styleProp, recursive);
            }
        }
    }
    
    /**
     *  @private
     *  TODO (rfrishbe): Most of this code is a duplicate of UIComponent::regenerateStyleCache,
     *  refactor as appropriate to avoid code duplication once we have a common
     *  child iterator between UIComponent and Group.
     */ 
    override public function regenerateStyleCache(recursive:Boolean):void
    {
        // Regenerate the proto chain for this object
        initProtoChain();

        // Recursively call this method on each child.
        var n:int = numElements;
        for (var i:int = 0; i < n; i++)
        {
            var child:IVisualElement = getElementAt(i);

            if (child is IStyleClient)
            {
                // Does this object already have a proto chain?
                // If not, there's no need to regenerate a new one.
                if (IStyleClient(child).inheritingStyles !=
                    StyleProtoChain.STYLE_UNINITIALIZED)
                {
                    IStyleClient(child).regenerateStyleCache(recursive);
                }
            }
            else if (child is IUITextField)
            {
                // Does this object already have a proto chain?
                // If not, there's no need to regenerate a new one.
                if (IUITextField(child).inheritingStyles)
                    StyleProtoChain.initTextField(IUITextField(child));
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Content management
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function get numElements():int
    {
        if (_mxmlContent == null)
            return 0;

        return _mxmlContent.length;
    }
    
    /**
     *  @private
     */ 
    override public function getElementAt(index:int):IVisualElement
    {
        // check for RangeError:
        checkForRangeError(index);
        
        return _mxmlContent[index];
    }
    
    /**
     *  @private 
     *  Checks the range of index to make sure it's valid
     */ 
    private function checkForRangeError(index:int, addingElement:Boolean = false):void
    {
        // figure out the maximum allowable index
        var maxIndex:int = (_mxmlContent == null ? -1 : _mxmlContent.length - 1);
        
        // if adding an element, we allow an extra index at the end
        if (addingElement)
            maxIndex++;
            
        if (index < 0 || index > maxIndex)
            throw new RangeError(resourceManager.getString("components", "indexOutOfRange", [index]));
    }
 
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElement(element:IVisualElement):IVisualElement
    {
        var index:int = numElements;
        
        // This handles the case where we call addElement on something
        // that already is in the list.  Let's just handle it silently
        // and not throw up any errors.
        if (element.parent == this)
            index = numElements-1;
        
        return addElementAt(element, index);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        if (element == this)
            throw new ArgumentError(resourceManager.getString("components", "cannotAddYourselfAsYourChild"));
            
        // check for RangeError:
        checkForRangeError(index, true);
        
        var host:DisplayObject = element.parent; 
        
        // This handles the case where we call addElement on something
        // that already is in the list.  Let's just handle it silently
        // and not throw up any errors.
        if (host == this)
        {
            setElementIndex(element, index);
            return element;
        }
        else if (host is IVisualElementContainer)
        {
            // Remove the item from the group if that group isn't this group
            IVisualElementContainer(host).removeElement(element);
        }
        
        // If we don't have any content yet, initialize it to an empty array
        if (_mxmlContent == null)
            _mxmlContent = [];
        
        _mxmlContent.splice(index, 0, element);
        
        if (!mxmlContentChanged)
            elementAdded(element, index);
        
        scaleGridChanged = true;
                
        return element;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        return removeElementAt(getElementIndex(element));
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElementAt(index:int):IVisualElement
    {
        // check RangeError
        checkForRangeError(index);
        
        var element:IVisualElement = _mxmlContent[index];
        
        // Need to call elementRemoved before removing the item so anyone listening
        // for the event can access the item.
        
        if (!mxmlContentChanged)
            elementRemoved(element, index);
        
        _mxmlContent.splice(index, 1);
        
        return element;
    }
        
    /**
     *  @inheritDoc
     */
    public function removeAllElements():void
    {
        for (var i:int = numElements - 1; i >= 0; i--)
        {
            removeElementAt(i);
        }
    }
    
    /**
     *  @private
     */ 
    override public function getElementIndex(element:IVisualElement):int
    {
        var index:int = _mxmlContent ? _mxmlContent.indexOf(element) : -1;
        
        if (index == -1)
            throw ArgumentError(resourceManager.getString("components", "elementNotFoundInGroup", [element]));
        else
            return index;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setElementIndex(element:IVisualElement, index:int):void
    {
        // check for RangeError...this is done in addItemAt
        // but we want to do it before removing the element
        checkForRangeError(index);
        
        removeElement(element);
        addElementAt(element, index);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        swapElementsAt(getElementIndex(element1), getElementIndex(element2));
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElementsAt(index1:int, index2:int):void
    {
        checkForRangeError(index1);
        checkForRangeError(index2);

        // Make sure that index1 is the smaller index so that addElementAt 
        // doesn't RTE
        if (index1 > index2)
        {
            var temp:int = index2;
            index2 = index1;
            index1 = temp; 
        }
        else if (index1 == index2)
            return;

        var element1:IVisualElement = _mxmlContent[index1];
        var element2:IVisualElement = _mxmlContent[index2];

        // Make sure we do the proper invalidations, but don't dispatch events
        if (!mxmlContentChanged)
        {
            elementRemoved(element1, index1, false /*notifyListeners*/);
            elementRemoved(element2, index2, false /*notifyListeners*/);
        }
        
        // Step 1: remove
        // Make sure we remove the bigger index first
        _mxmlContent.splice(index2, 1);
        _mxmlContent.splice(index1, 1);

        // Step 2: swap
        // Add them in reverse order 
        _mxmlContent.splice(index1, 0, element2);
        _mxmlContent.splice(index2, 0, element1);

        // Make sure we do the proper invalidations, but don't dispatch events
        if (!mxmlContentChanged)
        {
            elementAdded(element2, index1, false /*notifyListeners*/);
            elementAdded(element1, index2, false /*notifyListeners*/);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Content management (internal)
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function invalidateLayering():void
    {
        if (layeringMode == ITEM_ORDERED_LAYERING)
            layeringMode = SPARSE_LAYERING;
        invalidateDisplayObjectOrdering();
    }

    /**
     *  Adds an item to this Group.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param item The item that was added.
     *
     *  @param index The index where the item was added.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function elementAdded(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
    {
        if (layout)
            layout.elementAdded(index);        
                
        if (element.depth != 0)
            invalidateLayering();

        // Set the font context in non-UIComponent children.
        // UIComponent children use moduleFactory.
        if (element is IFontContextComponent && !(element is UIComponent) &&
            IFontContextComponent(element).fontContext == null)
        {  
            IFontContextComponent(element).fontContext = moduleFactory;
        }

        if (element is IGraphicElement) 
        {
            numGraphicElements++;
            addingGraphicElementChild(element as IGraphicElement);
            invalidateDisplayObjectOrdering();
        }   
        else
        {
            // item must be a DisplayObject
            
            // if the display object ordering is invalidated (because we have graphic elements 
            // that aren't actually in the display list), then lets just add our item to the end.  
            // If the ordering isn't invalidated, then let's just try to add it to the proper index.
            if (invalidateDisplayObjectOrdering())
            {
                // This always adds the child to the end of the display list. Any 
                // ordering discrepancies will be fixed up in assignDisplayObjects().
                addDisplayObjectToDisplayList(DisplayObject(element));
            }
            else
            {
                addDisplayObjectToDisplayList(DisplayObject(element), index);
            }
        }
        
        if (notifyListeners)
        {
            dispatchEvent(new ElementExistenceEvent(
                          ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
            
            if (element is IUIComponent)
                element.dispatchEvent(new FlexEvent(FlexEvent.ADD));
        }
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Removes an item from this Group.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param index The index of the item that is being removed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function elementRemoved(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
    {
        var childDO:DisplayObject = element as DisplayObject;   

        if (notifyListeners)
        {        
            dispatchEvent(new ElementExistenceEvent(
                          ElementExistenceEvent.ELEMENT_REMOVE, false, false, element, index));
            
            if (element is IUIComponent)
                element.dispatchEvent(new FlexEvent(FlexEvent.REMOVE));
        }
        
        if (element && (element is IGraphicElement))
        {
            numGraphicElements--;
            removingGraphicElementChild(element as IGraphicElement);
        }
        else if (childDO && childDO.parent == this)
        {
            super.removeChild(childDO);
        }
        
        invalidateDisplayObjectOrdering();
        invalidateSize();
        invalidateDisplayList();

        if (layout)
            layout.elementRemoved(index);     
    }
    
    /**
     *  @private
     */
    mx_internal function addingGraphicElementChild(child:IGraphicElement):void
    {
        // Special case (defensive coding) - if the element was previously
        // a child of this Group, and it didn't release its previously assigned
        // DisplayObject when its parent changed, and there's the possibility that
        // the Group may assign it the same DisplayObject and the same sharing mode,
        // we still need to invalidate and redraw as the displayObject likely has
        // been redrawn while the element was not a child of this Group.
        if (child.displayObject && child.displayObjectSharingMode == DisplayObjectSharingMode.USES_SHARED_OBJECT)
            invalidateGraphicElementDisplayList(child);
        
        child.parentChanged(this);

        // Sets up the inheritingStyles and nonInheritingStyles objects
        // and their proto chains so that getStyle() works.
        // If this object already has some children,
        // then reinitialize the children's proto chains.
        if (child is IStyleClient)
            IStyleClient(child).regenerateStyleCache(true);
        
        if (child is ISimpleStyleClient)
            ISimpleStyleClient(child).styleChanged(null);

        if (child is IStyleClient)
            IStyleClient(child).notifyStyleChangeInChildren(null, true);
    }
    
    /**
     *  @private
     */
    mx_internal function removingGraphicElementChild(child:IGraphicElement):void
    {
        // First discard the displayObject, as child may decide to destroy it
        // when parent changes.
        discardDisplayObject(child);        
        child.parentChanged(null);
    }

    /**
     *  Removes the element's <code>DisplayObject</code> from this <code>Group's</code>
     *  display list.
     *
     *  The <code>Group</code> also ensures any elements that share the
     *  <code>DisplayObject</code> will be redrawn.
     * 
     *  <p>This method doesn't necessarily trigger new <code>DisplayObject</code>
     *  reassignment for the passed in <code>element</code>.
     *  To request new display object reassignment, call the
     *  <code>graphicElementLayerChanged</code> method.</p> 
     *
     *  @param element The graphic element whose display object will be discarded.
     *  @see #graphicElementLayerChanged
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function discardDisplayObject(element:IGraphicElement):void
    {
        var oldDisplayObject:DisplayObject = element.displayObject;
        if (!oldDisplayObject)
            return;

        // If the element created the display object
        if (element.displayObjectSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT &&
            oldDisplayObject.parent == this)
        {
            super.removeChild(oldDisplayObject);

            // Redo the shared sequences. 
            invalidateDisplayObjectOrdering();
        }
        else if (oldDisplayObject is ISharedDisplayObject)
        {
            // Redraw the shared sequence
            ISharedDisplayObject(oldDisplayObject).redrawRequested = true;

            // Make sure we do a pass through the graphic elements and redraw
            // the invalid ones.  We should only redraw, no need to redo the layout.
            super.$invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     *  
     *  Returns true if the Group's display object can be shared with graphic elements
     *  inside the group
     */
    private function get canShareDisplayObject():Boolean
    {
        // Work-around for Flash Player bug: if GraphicElements share
        // the Group's Display Object and cacheAsBitmap is true, the
        // scrollRect won't function correctly.
        // We can't even check the cacheAsBitmap property since that will
        // cause a back buffer allocation, which is another FP bug.
        if (scrollRect)
            return false;
 
        // we can't share ourselves if we're in blendMode != normal, or we have 
        // to deal with any layering.  The reason is because we handle layer = 0 first
        // in our implementation, and we don't want those to use our display object to 
        // draw into because there could be something further down the line that has 
        // layer < 0
        return (_blendMode == "normal" || _blendMode == "auto") && (layeringMode == ITEM_ORDERED_LAYERING);
    }
    
    /**
     *  @private
     *  
     *  Invalidates the display object ordering and will run assignDisplayObjects()
     *  if necessary.
     * 
     *  @return true if the display object ordering needed to be invalidated; 
     *          false otherwise.
     */
    private function invalidateDisplayObjectOrdering():Boolean
    {
        if (layeringMode == SPARSE_LAYERING || numGraphicElements > 0)
        {
            needsDisplayObjectAssignment = true;
            invalidateProperties();
            return true;
        }
        
        return false;
    }

    /**
     *  @private
     *  
     *  Called to assign display objects to graphic elements
     */
    private function assignDisplayObjects():void
    {
        var topLayerItems:Vector.<IVisualElement>;
        var bottomLayerItems:Vector.<IVisualElement>;        
        var keepLayeringEnabled:Boolean = false;
        var insertIndex:int = 0;
        
        // Keep track of the previous IVisualElement.  This is used when
        // assigning DisplayObjects to the IGraphicElements.
        // If the Group can share its DisplayObject with the IGraphicElements
        // then initialize the prevItem with this Group object.
        var prevItem:IVisualElement;
        if (canShareDisplayObject)
            prevItem = this;
            
        // Iterate through all of the items
        var len:int = numElements; 
        for (var i:int = 0; i < len; i++)
        {  
            var item:IVisualElement = getElementAt(i);
            
            if (layeringMode != ITEM_ORDERED_LAYERING)
            {
                var layer:Number = item.depth;
                if (layer != 0)
                {               
                    if (layer > 0)
                    {
                        if (topLayerItems == null) topLayerItems = new Vector.<IVisualElement>();
                        topLayerItems.push(item);
                        continue;                   
                    }
                    else
                    {
                        if (bottomLayerItems == null) bottomLayerItems = new Vector.<IVisualElement>();
                        bottomLayerItems.push(item);
                        continue;                   
                    }
                }
            }
            
            // this should only get called if layer == 0, or we don't care
            // about layering (layeringMode == ITEM_ORDERED_LAYERING)
            insertIndex = assignDisplayObjectTo(item, prevItem, insertIndex);
            prevItem = item;
        }
        
        // we've done all layer == 0 items. 
        // now let's put the higher z-index ones on next
        // then we'll handle the ones on bottom, but we'll
        // insert them in the very beginning (index = 0)
        
        if (topLayerItems != null)
        {
            keepLayeringEnabled = true;
            //topLayerItems.sortOn("layer",Array.NUMERIC);
            GroupBase.sortOnLayer(topLayerItems);
            len = topLayerItems.length;
            for (i=0;i<len;i++)
            {
                // For layer != 0, we never share display objects
                insertIndex = assignDisplayObjectTo(topLayerItems[i], null /*prevElement*/, insertIndex);
            }
        }
        
        if (bottomLayerItems != null)
        {
            keepLayeringEnabled = true;
            insertIndex = 0;

            //bottomLayerItems.sortOn("layer",Array.NUMERIC);
            GroupBase.sortOnLayer(bottomLayerItems);
            len = bottomLayerItems.length;

            for (i=0;i<len;i++)
            {
                // For layer != 0, we never share dsiplay objects
                insertIndex = assignDisplayObjectTo(bottomLayerItems[i], null /*prevElement*/, insertIndex);
            }
        }
        
        // If we tried to layer these visual elements and found that we 
        // don't actually need to because layer=0 for all of them, 
        // then lets optimize this next time and just skip the layering step.
        // If an element gets added that has layer set to something non-zero, then 
        // layeringMode will get set to SPARSE_LAYERING.
        // If the layer property changes on a current element, invalidateLayering()
        // will be called and layeringMode will get set to SPARSE_LAYERING.
        if (keepLayeringEnabled == false)
            layeringMode = ITEM_ORDERED_LAYERING;
            
        // Make sure we do a pass through the graphic elements and redraw
        // the invalid ones.  We should only redraw, no need to redo the layout.
        super.$invalidateDisplayList();
    }
    
    /**
     *  @private
     *  Assigns a DisplayObject to the curElement and ensures the DisplayObject
     *  is at insertIndex in the display object list.
     * 
     *  If <code>curElement</code> implements IGraphicElement, then both its
     *  DisplayObject and displayObjectSharingMode will be updated.
     * 
     *  @curElement The current element to assign DisplayObject to
     *  @prevEelement The previous element in the list of elements or null.
     *  @return Returns the display list index after the current element's
     *  DisplayObject.
     */
    private function assignDisplayObjectTo(curElement:IVisualElement,
                                           prevElement:IVisualElement,
                                           insertIndex:int):int
    {
        if (curElement is DisplayObject)
        {
            super.setChildIndex(curElement as DisplayObject, insertIndex++);
        }
        else if (curElement is IGraphicElement)
        {
            var current:IGraphicElement = IGraphicElement(curElement);
            var previous:IGraphicElement = prevElement as IGraphicElement;

            var oldDisplayObject:DisplayObject = current.displayObject;
            var oldSharingMode:String = current.displayObjectSharingMode;

            if (previous && previous.canShareWithNext(current) && current.canShareWithPrevious(previous) &&
                current.setSharedDisplayObject(previous.displayObject))
            {
                // If we are the second element in the shared sequence,
                // make sure that the first element has the correct displayObjectSharingMode
                if (previous.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
                    previous.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_SHARED_OBJECT;

                current.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
            }
            else if (prevElement == this && current.setSharedDisplayObject(this))
            {
                current.displayObjectSharingMode = DisplayObjectSharingMode.USES_SHARED_OBJECT;
            }
            else
            {
                // We don't want to create new DisplayObjects for elements that
                // already have created their own their display objects.
                var ownsDisplayObject:Boolean = oldSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT;

                // If the element doesn't have a DisplayObject or it doesn't own
                // the DisplayObject it currently has, then create a new one
                var displayObject:DisplayObject = oldDisplayObject;
                if (!ownsDisplayObject || !displayObject)
                    displayObject = current.createDisplayObject();

                // Make sure the DisplayObject is at the correct position.
                // Check displayObject for null, some graphic elements
                // may choose not to create a DisplayObject during this pass.
                if (displayObject)
                    addDisplayObjectToDisplayList(displayObject, insertIndex++);

                current.displayObjectSharingMode = DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT;
            }
            invalidateAfterAssignment(current, oldSharingMode, oldDisplayObject);
        }
        return insertIndex;
    }

    /**
     *  @private
     *  Performs invalidation of the old and new shared sequenences.
     *  If necesary, removes the old display object from the list.
     */
    private function invalidateAfterAssignment(element:IGraphicElement,
                                               oldSharingMode:String,
                                               oldDisplayObject:DisplayObject):void
    {
        // Make sure we remove or mark for redraw the old displayObject
        var displayObject:DisplayObject = element.displayObject;
        var sharingMode:String = element.displayObjectSharingMode;

        if (oldDisplayObject == displayObject && sharingMode == oldSharingMode)
            return;

        // Make sure we redraw the display object        
        if (displayObject is ISharedDisplayObject)
            ISharedDisplayObject(displayObject).redrawRequested = true;

        // Old display object also needs to be redrawn, in case any other GE still uses it.
        if (oldDisplayObject is ISharedDisplayObject)
            ISharedDisplayObject(oldDisplayObject).redrawRequested = true;

        // Make sure we remove the old display object, if needed
        if (oldDisplayObject && oldDisplayObject.parent == this &&
            oldDisplayObject != displayObject && oldSharingMode != DisplayObjectSharingMode.USES_SHARED_OBJECT)
            super.removeChild(oldDisplayObject);
    }

    /**
     *  @private
     *
     *  If the displayObject is not a child of this Group, then insert it at the
     *  specified index (or at the end of the list, when index is -1).
     *  Else, if the displayObject is already a child of the Group, then simply
     *  adjust its child index.  
     */ 
    private function addDisplayObjectToDisplayList(child:DisplayObject, index:int = -1):void
    {
        if (child.parent == this)
            super.setChildIndex(child, index != -1 ? index : super.numChildren - 1);
        else
            super.addChildAt(child, index != -1 ? index : super.numChildren);
    }

    /**
     *  Notify the host component that an element has changed and needs to be redrawn.
     *  Group calls the <code>validateDisplayList()</code> method on the IGraphicElement
     *  to give it a chance to redraw.
     *
     *  @param element The element that has changed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateGraphicElementDisplayList(element:IGraphicElement):void
    {
        if (element.displayObject is ISharedDisplayObject)
            ISharedDisplayObject(element.displayObject).redrawRequested = true;

        // Invalidate display list only, no need to run the layout.
        super.$invalidateDisplayList();
    }
    
    /**
     *  Notify the host component that an element changed and needs to validate properties.
     *  Group calls the <code>validateProperties()</code> method on the IGraphicElement
     *  to give it a chance to commit its properties.
     *
     *  @param element The element that has changed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateGraphicElementProperties(element:IGraphicElement):void
    {
        invalidateProperties();        
    }

    /**
     *  Notify the host component that an element size has changed.
     *  Group calls the <code>validateSize()</code> method on the IGraphicElement
     *  to give it a chance to validate its size.
     * 
     *  @param element The element that has changed size.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateGraphicElementSize(element:IGraphicElement):void
    {
        // Invalidate the size only, no need to run the layout. 
        // Later on, if the size changes, then a layout pass will be triggered.
        super.$invalidateSize();
    }
    
    /**
     *  Notify the host that an element layer has changed.
     *  Group will re-evaluate the sequences of elements with shared DisplayObjects
     *  and may re-assign the DisplayObjects and redraw the sequences as a result. 
     * 
     *  @param element The element that has changed size.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function invalidateGraphicElementSharing(element:IGraphicElement):void
    {
        // One of our children have told us they might need a displayObject     
        invalidateDisplayObjectOrdering();
    }
    
    /**
     *  @private
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "addChildError")));
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "addChildAtError")));
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "removeChildError")));
    }
    
    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error(resourceManager.getString("components", "removeChildAtError")));
    }
    
    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error(resourceManager.getString("components", "setChildIndexError")));
    }
    
    /**
     *  @private
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error(resourceManager.getString("components", "swapChildrenError")));
    }
    
    /**
     *  @private
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error(resourceManager.getString("components", "swapChildrenAtError")));
    }
    
    /**
     *  @private
     *  Override to ensure we set redrawRequested when appropriate.
     */
    override public function set mouseEnabledWhereTransparent(value:Boolean):void
    {
        if (value == mouseEnabledWhereTransparent)
            return;
        
        super.mouseEnabledWhereTransparent = value;
        redrawRequested = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  ISharedDisplayObject
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var _redrawRequested:Boolean = false;

    /**
     *  @private
     *  Contains <code>true</code> when any of the <code>IGraphicElement</code> objects that share
     *  this <code>DisplayObject</code> object needs to redraw.  
     *  This is used internally
     *  by the <code>Group</code> class and developers don't typically use this. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get redrawRequested():Boolean
    {
        return _redrawRequested;
    }

    /**
     *  @private
     */
    public function set redrawRequested(value:Boolean):void
    {
        _redrawRequested = value;
    }
}
}
