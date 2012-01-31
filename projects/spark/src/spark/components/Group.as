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

package mx.components 
{

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import mx.components.baseClasses.GroupBase;
import mx.core.ILayoutElement;
import mx.core.IUITextField;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.InvalidatingSprite;
import mx.core.mx_internal;
import mx.events.ItemExistenceChangedEvent;
import mx.graphics.IGraphicElement;
import mx.graphics.graphicsClasses.TextGraphicElement;
import mx.layout.LayoutElementFactory;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.styles.StyleProtoChain;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when an item is added to the content holder.
 *  event.relatedObject is the visual item that was added.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_ADD
 */
[Event(name="itemAdd", type="mx.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the content holder.
 *  event.relatedObject is the visual item that was removed.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_REMOVE
 */
[Event(name="itemRemove", type="mx.events.ItemExistenceChangedEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("mxmlContent")] 

[IconFile("Group.png")]

/**
 *  The Group class is the base container class for visual elements.
 *
 *  @see mx.components.DataGroup
 *
 *  @includeExample examples/GroupExample.mxml
 *
 */
public class Group extends GroupBase implements IVisualElementContainer
{
    /**
     *  Constructor.
     */
    public function Group():void
    {
        super();      
    }
    
    private var needsDisplayObjectAssignment:Boolean = false;
    private var layeringMode:uint = ITEM_ORDERED_LAYERING;
    private var numGraphicElements:uint = 0;
    
    private static const ITEM_ORDERED_LAYERING:uint = 0;
    private static const SPARSE_LAYERING:uint = 1;
    
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
     *  @private
     */
    override public function set cacheAsBitmap(value:Boolean):void
    {
        // Work-around for Flash Player bug: if GraphicElements share
        // the Group's Display Object and cacheAsBitmap is true, the
        // scrollRect won't function correctly. 
        var previous:Boolean = canShareDisplayObject;
        super.cacheAsBitmap = value;
        if (numGraphicElements > 0 && previous != canShareDisplayObject)
            invalidateDisplayObjectOrdering();            
    }

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
        
        //The default blendMode in FXG is 'layer'. There are only
        //certain cases where this results in a rendering difference,
        //one being when the alpha of the Group is > 0 and < 1. In that
        //case we set the blendMode to layer to avoid the performance
        //overhead that comes with a non-normal blendMode. 
        
        if (value > 0 && value < 1 && !blendModeExplicitlySet)
        {
            if (_blendMode != BlendMode.LAYER)
            {
                _blendMode = BlendMode.LAYER;
                blendModeChanged = true;
                invalidateDisplayObjectOrdering();
                invalidateProperties();
            }
        }
        else if ((value == 1 || value == 0) && !blendModeExplicitlySet)
        {
            if (_blendMode != BlendMode.NORMAL)
            {
                _blendMode = BlendMode.NORMAL;
                blendModeChanged = true;
                invalidateDisplayObjectOrdering();
                invalidateProperties();
            }
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
    private var _blendMode:String = BlendMode.NORMAL;
    private var blendModeChanged:Boolean;
    private var blendModeExplicitlySet:Boolean;

    [Inspectable(category="General", enumeration="add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay", defaultValue="normal")]

    /**
     *  A value from the BlendMode class that specifies which blend mode to use. 
     *  A bitmap can be drawn internally in two ways. 
     *  If you have a blend mode enabled or an external clipping mask, the bitmap is drawn 
     *  by adding a bitmap-filled square shape to the vector render. 
     *  If you attempt to set this property to an invalid value, 
     *  Flash Player or Adobe AIR sets the value to <code>BlendMode.NORMAL</code>. 
     *
     *  @default BlendMode.NORMAL
     *
     *  @see flash.display.DisplayObject#blendMode
     *  @see flash.display.BlendMode
     */
    override public function get blendMode():String
    {
        if (blendModeExplicitlySet)
            return _blendMode;
        else return BlendMode.LAYER;
    }
    
    /**
     *  @private
     */
    override public function set blendMode(value:String):void
    {
        if (blendModeExplicitlySet && value == _blendMode)
            return;
            
        var oldValue:String = _blendMode;
        _blendMode = value;
            
        blendModeExplicitlySet = true;
        
        blendModeChanged = true;
        
        // Only need to re-do display object assignment if blendmode was normal
        // and is changing to someting else, or the blend mode was something else 
        // and is going back to normal.  This is because display object sharing
        // only happens when blendMode is normal.
        if ((oldValue == BlendMode.NORMAL || value == BlendMode.NORMAL) && 
            !(oldValue == BlendMode.NORMAL && value == BlendMode.NORMAL))
        {
            invalidateDisplayObjectOrdering();
        }
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  mxmlContent
    //----------------------------------
    
    private var mxmlContentChanged:Boolean = false;
    private var _mxmlContent:Array;
    private var _oldMxmlContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Content for this Group.  Do not modify this array directly.
     *
     *  <p>The content can be an Array or a single item.
     *  The content items should only be IVisualItems.  An 
     *  mxmlContent Array shouldn't be shared between multiple
     *  Groups as visual elements can only live in one Group at 
     *  a time.</p>
     * 
     *  <p>If the content is an Array, do not modify the array 
     *  directly. Use the methods defined on Group to do this.</p>
     *
     *  @default null
     */
    public function get mxmlContent():Array
    {
        return _mxmlContent;
    }
    
    /**
     *  @private
     */
    public function set mxmlContent(value:Array):void
    {
        if (!mxmlContentChanged)
            _oldMxmlContent = _mxmlContent;
        _mxmlContent = value;
        mxmlContentChanged = true;
        invalidateProperties();
    }

    /**
     *  Adds the elements in <code>mxmlContent</code> to the Group.
     *  Flex calls this method automatically; you do not call it directly.
     */ 
    protected function validateMxmlContent():void
    {
        mxmlContentChanged = false;
        var i:int;
        
        if (_oldMxmlContent != null)
        {
            for (i = _oldMxmlContent.length - 1; i >= 0; i--)
            {
                elementRemoved(_oldMxmlContent[i], i);
            }
        }
        
        _oldMxmlContent = null;
        
        if (_mxmlContent != null)
        {
            var n:int = _mxmlContent.length;
            for (i = 0; i < n; i++)
            {
                elementAdded(_mxmlContent[i], i);
            }
        }
    }
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (mxmlContentChanged)
            validateMxmlContent(); 
        
        if (blendModeChanged)
        {
            blendModeChanged = false;
            super.blendMode = _blendMode;
        }
        
        if (needsDisplayObjectAssignment)
        {
            needsDisplayObjectAssignment = false;
            assignDisplayObjects();
        }
        
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
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
        // Since GraphicElement is not ILayoutManagerClient, we need to make sure we
        // validate sizes of the elements, even in cases where recursive==false.
        
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
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
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {    	
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        graphics.clear(); // Clear the group's graphic because graphic elements might be drawing to it
        // This isn't needed for DataGroup because there's no DisplayObject sharing
        
        // Iterate through the graphic elements. If an element has a displayObject that has been 
        // invalidated, then validate all graphic elements that draw to this displayObject. 
        // The algorithm assumes that all of the elements that share a displayObject are in between
        // the element with the shared displayObject and the next element that has a displayObject.
        if (numGraphicElements > 0)
        {
	        var length:int = numElements;
	        var currentSharedSprite:InvalidatingSprite;
	        for (var i:int = 0; i < length; i++)
	        {
	            var element:IGraphicElement = getElementAt(i) as IGraphicElement;
	            if (element)
	            {
	            	var elementSprite:InvalidatingSprite = element.displayObject as InvalidatingSprite;
	            	
	            	// Each element must either have a displayObject or sharedDisplayObject property
	            	if (elementSprite)
	            	{
	            		if (currentSharedSprite)
	            		{
		            		// Reached a new display object, so mark the previous DisplayObject valid
		            		currentSharedSprite.invalid = false;
	            		}
	            		
	            		currentSharedSprite = elementSprite;
	            	}
	            	
	            	// currentSharedSprite is null if the Group is the sharedDisplayObject.            	
	            	if (currentSharedSprite == null || currentSharedSprite.invalid) 
	            	{
	            		element.validateDisplayList();
	            	} 
	
	            }
	        }
	        
	        // Mark the last shared displayObject valid
	        if (currentSharedSprite)
	        	currentSharedSprite.invalid = false;
        }
        
        if (scaleGridChanged)
        {
        	scaleGridChanged = false;
        	
        	scale9Grid = new Rectangle(scaleGridLeft, 
        							   scaleGridTop,	
        							   scaleGridRight - scaleGridLeft, 
        							   scaleGridBottom - scaleGridTop);
        }
    }

    /**
     *  @private
     *  TODO: Most of this code is a duplicate of UIComponent::notifyStyleChangeInChildren,
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
     *  TODO: Most of this code is a duplicate of UIComponent::regenerateStyleCache,
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

            if ( recursive && child is IStyleClient)
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
     *  @inheritDoc
     */
    public function get numElements():int
    {
        if (_mxmlContent == null)
            return 0;

        return _mxmlContent.length;
    }
    
    /**
     *  @inheritDoc
     */ 
    public function getElementAt(index:int):IVisualElement
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
            throw new RangeError("Index " + index + " is out of range");
    }
 
    /**
     *  @inheritDoc
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
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        if (element == this)
            throw new ArgumentError("Cannot add yourself as a child of yourself");
            
        // check for RangeError:
        checkForRangeError(index, true);
        
        // This handles the case where we call addElement on something
        // that already is in the list.  Let's just handle it silently
        // and not throw up any errors.
        if (element.parent == this)
        {
            setElementIndex(element, index);
            return element;
        }
        
        // If we don't have any content yet, initialize it to an empty array
        if (_mxmlContent == null)
            _mxmlContent = [];
        
        _mxmlContent.splice(index, 0, element);
        
        if (!mxmlContentChanged)
            elementAdded(element, index);
        
        return element;
    }
    
    /**
     *  @inheritDoc
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        return removeElementAt(getElementIndex(element));
    }
    
    /**
     *  @inheritDoc
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
    public function getElementIndex(element:IVisualElement):int
    {
        var index:int = _mxmlContent ? _mxmlContent.indexOf(element) : -1;
        
        if (index == -1)
            throw ArgumentError(element + " is not found in this Group");
        else
            return index;
    }
    
    /**
     *  @inheritDoc
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
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        swapElementsAt(getElementIndex(element1), getElementIndex(element2));
    }
    
    /**
     *  @inheritDoc
     */
    public function swapElementsAt(index1:int, index2:int):void
    {
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
        
        var element1:IVisualElement = getElementAt(index1);
        var element2:IVisualElement = getElementAt(index2);
        
        removeElement(element1);
        removeElement(element2);
        
        addElementAt(element2, index1);
        addElementAt(element1, index2);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Layout item iteration
    //
    //  Iterators used by Layout objects. For visual items, the layout item
    //  is the item itself. For data items, the layout item is the item renderer
    //  instance that is associated with the item.
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function get numLayoutElements():int
    {
        return numElements;
    }
    
    /**
     *  @inheritDoc
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     */ 
    override public function getLayoutElementAt(index:int):ILayoutElement
    {
        var element:IVisualElement = getElementAt(index);

        return LayoutElementFactory.getLayoutElementFor(element);
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
     */
    mx_internal function elementAdded(element:IVisualElement, index:int):void
    {
        var child:DisplayObject;
                
        if (element.layer != 0)
            invalidateLayering();

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
                child = addItemToDisplayList(DisplayObject(element), element);
            }
            else
            {
                child = addItemToDisplayList(DisplayObject(element), element, index);
            }
        }
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, element, index));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Removes an item from this Group.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param index The index of the item that is being removed.
     */
    mx_internal function elementRemoved(element:IVisualElement, index:int):void
    {
        var childDO:DisplayObject = element as DisplayObject;
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, element, index));
        
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
    }
    
    /**
     *  @private
     */
    mx_internal function addingGraphicElementChild(child:IGraphicElement):void
    {
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

        // Inform the component that it's style properties
        // have been fully initialized. Most components won't care,
        // but some need to react to even this early change.
        if (child is TextGraphicElement)
            TextGraphicElement(child).stylesInitialized();
    }
    
    /**
     *  @private
     */
    mx_internal function removingGraphicElementChild(child:IGraphicElement):void
    {
        child.parentChanged(null);
        child.sharedDisplayObject = null;
        
        if (child.displayObject)
            super.removeChild(child.destroyDisplayObject());
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
        if (cacheAsBitmap && scrollRect)
            return false;
 
        // we can't share ourselves if we're in blendMode != normal, or we have 
        // to deal with any layering.  The reason is because we handle layer = 0 first
        // in our implementation, and we don't want those to use our display object to 
        // draw into because there could be something further down the line that has 
        // layer < 0
        // Make sure we use _blendMode here, since _blendMode can be "normal", but
        // blendMode still report as "layer".
        return _blendMode == "normal" && (layeringMode == ITEM_ORDERED_LAYERING);
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
        
        mergeData.currentAssignableDO  = canShareDisplayObject ? this : null;
        mergeData.insertIndex = 0;

        // Iterate through all of the items
        var len:int = numElements; 
        for (var i:int = 0; i < len; i++)
        {  
            var item:IVisualElement = getElementAt(i);
            
            if (layeringMode != ITEM_ORDERED_LAYERING)
            {
                var layer:Number = item.layer;
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
            assignDisplayObjectTo(item,mergeData);
        }
        
        // we've done all layer == 0 items. 
        // now let's put the higher z-index ones on next
        // then we'll handle the ones on bottom, but we'll
        // insert them in the very beginning (index = 0)
        
        if (topLayerItems != null)
        {
            keepLayeringEnabled = true;
            //topLayerItems.sortOn("layer",Array.NUMERIC);
            GroupBase.mx_internal::sortOnLayer(topLayerItems);
            len = topLayerItems.length;
            for (i=0;i<len;i++)
            {
                assignDisplayObjectTo(topLayerItems[i],mergeData);
            }
        }
        
        if (bottomLayerItems != null)
        {
            keepLayeringEnabled = true;
            mergeData.currentAssignableDO  = null;
            mergeData.insertIndex = 0;

            //bottomLayerItems.sortOn("layer",Array.NUMERIC);
            GroupBase.mx_internal::sortOnLayer(bottomLayerItems);
            len = bottomLayerItems.length;

            for (i=0;i<len;i++)
            {
                assignDisplayObjectTo(bottomLayerItems[i],mergeData);
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
    }
    
 
    /**
     *  @private
     */
    private function assignDisplayObjectTo(element:IVisualElement,mergeData:GroupDisplayObjectMergeData):void
    {   
        if (element is DisplayObject)
        {
            super.setChildIndex(element as DisplayObject, mergeData.insertIndex);
            
            mergeData.insertIndex++;
            // Null this out so that we are forced to create one for the next item
            mergeData.currentAssignableDO = null; 
        }           
        else if (element is IGraphicElement)
        {
            var graphicElement:IGraphicElement = element as IGraphicElement;
            
            if (mergeData.currentAssignableDO == null || graphicElement.needsDisplayObject)
            {
                var newChild:DisplayObject = graphicElement.displayObject;
                
                if (newChild == null)
                    newChild = graphicElement.createDisplayObject();
                
                addItemToDisplayList(newChild, element, mergeData.insertIndex); 
                // If the element is transformed, the next item needs its own DO        
                mergeData.currentAssignableDO = graphicElement.nextSiblingNeedsDisplayObject ? null : newChild;
                mergeData.insertIndex++;
            }
            else
            {
                // Item should be assigned the currentAssignableDO
                // If it already has a DO, we need to remove it
                if (graphicElement.displayObject)
                    super.removeChild(graphicElement.destroyDisplayObject());
                
                graphicElement.sharedDisplayObject = mergeData.currentAssignableDO;
                if (graphicElement.nextSiblingNeedsDisplayObject)
                    mergeData.currentAssignableDO = null;
            }
        }
    } 
   
    /**
     *  Remove an item from another group or display list
     *  before adding it to this display list.
     * 
     *  @param child DisplayObject to add to the display list.
     *
     *  @param item Item associated with the display object to be added.  If 
     *  the item itself is a display object, it will be the same as the child parameter.
     *
     *  @param index Index position where the display object is added.
     * 
     *  @return DisplayObject that was added.
     */ 
    protected function addItemToDisplayList(child:DisplayObject, element:IVisualElement, index:int = -1):DisplayObject
    { 
        var host:DisplayObject = element.parent; 
        
        // Remove the item from the group if that group isn't this group
        if (host && host is IVisualElementContainer && host != this)
            IVisualElementContainer(host).removeElement(element);
        
        // Calling removeElement should have already removed the child. This
        // should handle the case when we don't call removeItem
        if (child.parent)
        {
            if (child.parent == this)
            {
                var insertIndex:int;
                if (index == -1)
                    insertIndex = super.numChildren - 1;
                else if (index == 0)
                    insertIndex = 0;
                else
                    insertIndex = index;
                    
                super.setChildIndex(child, insertIndex);
                return child;
            }
            else        
                child.parent.removeChild(child);
        }
            
        return super.addChildAt(child, index != -1 ? index : super.numChildren);
    }
    
    /**
     *  @private
     */
    override mx_internal function graphicElementLayerChanged(e:IGraphicElement):void
    {
        super.graphicElementLayerChanged(e);
        
        // One of our children have told us they might need a displayObject     
        invalidateDisplayObjectOrdering();
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
    //  scaleGridBottom
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specfies the bottom coordinate of the scale grid.
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
            invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  scaleGridLeft
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specfies the left coordinate of the scale grid.
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
            invalidateDisplayList();
        }

    }

    //----------------------------------
    //  scaleGridRight
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specfies the right coordinate of the scale grid.
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
            invalidateDisplayList();
        }

    }

    //----------------------------------
    //  scaleGridTop
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     * Specfies the top coordinate of the scale grid.
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
            invalidateDisplayList();
        }

    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects, 
     *  and you should not call <code>addChild()</code> directly.  Instead, use 
     *  <code>addElement()</code>.
     * 
     *  @see mx.components.Group#addElement
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects, 
     *  and you should not call <code>addChildAt()</code> directly.  Instead, use 
     *  <code>addElementAt()</code>.
     * 
     *  @see mx.components.Group#addElementAt
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects,
     *  and you should not call <code>removeChild()</code> directly.  Instead, use 
     *  <code>removeElement()</code>.
     * 
     *  @see mx.components.Group#removeElement
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects,
     *  and you should not call <code>removeChildAt()</code> directly.  Instead, use 
     *  <code>removeElementAt()</code>.
     * 
     *  @see mx.components.Group#removeElementAt
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects,
     *  and you should not call <code>setChildIndex()</code> directly.  Instead, use 
     *  <code>setElementIndex()</code>.
     * 
     *  @see mx.components.Group#setElementIndex
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects,
     *  and you should not call <code>swapChildren()</code> directly.  Instead, use 
     *  <code>swapElements()</code>.
     * 
     *  @see mx.components.Group#swapElements
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
    /**
     *  @inheritDoc
     * 
     *  Group supports non-DisplayObject children (<code>IGraphicElement</code>s) as well 
     *  as DisplayObject children.  Group manages its own display objects,
     *  and you should not call <code>swapChildrenAt()</code> directly.  Instead, use 
     *  <code>swapElementsAt()</code>.
     * 
     *  @see mx.components.Group#swapElementsAt
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error("This method is not available in this class.  Please consult the documentation."));
    }
    
}
}


import flash.display.DisplayObject; 

class GroupDisplayObjectMergeData
{
    public var currentAssignableDO:DisplayObject;
    public var insertIndex:int;
}

const mergeData:GroupDisplayObjectMergeData = new GroupDisplayObjectMergeData();
