package mx.components 
{
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.layout.ILayoutItem;
import mx.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.graphics.Graphic;
import mx.graphics.IGraphicElement;
import mx.graphics.graphicsClasses.GraphicElement;
import mx.components.baseClasses.GroupBase;
import mx.controls.Label;
import mx.core.IFactory;
import mx.core.IVisualItem;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.styles.IStyleClient;

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
[Event(name="itemAdd", type="flex.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the content holder.
 *  event.relatedObject is the visual item that was removed.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_REMOVE
 */
[Event(name="itemRemove", type="flex.events.ItemExistenceChangedEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")] 

/**
 *  The Group class is the base container class for visual elements.
 *
 *  @see mx.components.DataGroup
 */
public class Group extends GroupBase 
{
    /**
     *  Constructor.
     */
    public function Group():void
    {
        super();      
    }
    
    private var contentChanged:Boolean = false;
    private var needsDisplayObjectAssignment:Boolean = false;
    
    private var _content:Object;
    private var _contentType:int;
    private var layeringMode:uint = ITEM_ORDERED_LAYERING;
    
    private static const ITEM_ORDERED_LAYERING:uint = 0;
    private static const SPARSE_LAYERING:uint = 1;
    
    private static const CONTENT_TYPE_UNKNOWN:int = 0;
    private static const CONTENT_TYPE_ARRAY:int = 1;
    
    //----------------------------------
    //  alpha
    //----------------------------------

    [Inspectable(defaultValue="1.0", category="General", verbose="1")]

    /**
     *  @private
     */
    override public function set alpha(value:Number):void
    {
        //The default blendMode in FXG is 'layer'. There are only
        //certain cases where this results in a rendering difference,
        //one being when the alpha of the Group is > 0 and < 1. In that
        //case we set the blendMode to layer to avoid the performance
        //overhead that comes with a non-normal blendMode. 
        
        if (value > 0 && value < 1 && !blendModeExplicitlySet)
        {
            _blendMode = BlendMode.LAYER;
            blendModeChanged = true;
        }
        else if ((value == 1 || value == 0) && !blendModeExplicitlySet)
        {
            _blendMode = BlendMode.NORMAL;
            blendModeChanged = true;
        }
            
        super.alpha = value;
        
        if (blendModeChanged) 
            needsDisplayObjectAssignment = true;
        invalidateProperties();
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

    [Bindable("propertyChange")]
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
        dispatchPropertyChangeEvent("blendMode", oldValue, value);
            
        blendModeExplicitlySet = true;
        
        blendModeChanged = true;
        needsDisplayObjectAssignment = true;
        invalidateProperties();
    }
    
    /**
     *  Content for this Group.
     *
     *  <p>The content can be an Array or a single item.
     *  The content items can be any type.</p>
     * 
     *  <p>If the content is an Array, do not modify the array 
     *  directly. Use the methods defined on Group to do this.</p>
     *
     *  @default null
     */
    public function get content():Object
    {
        return _content;
    }
    
    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        _content = value;
        
        if (_content is Array)
            _contentType = CONTENT_TYPE_ARRAY;
        else
            _contentType = CONTENT_TYPE_UNKNOWN;
            
        contentChanged = true;
        invalidateProperties();
    }

    /**
     *  Adds the elements in <code>content</code> to the Group.
     *  Flex calls this method automatically; you do not call it directly.
     */ 
    protected function initializeChildrenArray():void
    {   
        // Get rid of existing display object children.
        // !!!!! This should probably be done through change notification
        // TODO!! This should be removing the last child b/c we want to 
        // send an event for each content child. This logic will send
        // remove event for the 0th content child x times. 
        for (var idx:int = numChildren; idx > 0; idx--)
            //itemRemoved(0);
            super.removeChildAt(0);
        
        if (_content !== null)
        {
            for (var i:int = 0; i < numItems; i++)
            {
                itemAdded(getItemAt(i), i);
            }
        }
        
        assignDisplayObjects();
        needsDisplayObjectAssignment = false;
        
        /* if (maskElements)
        {
            for (var k:Object in maskElements)
            {
                var maskElement:DisplayObject = k as DisplayObject;
                if (maskElement && (!maskElement.parent || maskElement.parent !== this))
                {
                    super.addChild(maskElement);
                    var maskComp:UIComponent = maskElement as UIComponent;
                    if (maskComp)
                    {
                        maskComp.validateNow();
                        maskComp.setActualSize(maskComp.getExplicitOrMeasuredWidth(), 
                                               maskComp.getExplicitOrMeasuredHeight());
                    }
                    
                    var maskTarget:IGraphicElement = maskElements[k] as IGraphicElement;
                    if (maskTarget)
                    {
                        maskTarget.applyMask();
                    }
                }
            }
        } */
    }
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (contentChanged)
        {
            contentChanged = false;
            initializeChildrenArray();
            
            // maskChanged = true; TODO (rfrishbe): need this maskChanged?
        }
        
        if (blendModeChanged)
        {
            blendModeChanged = true;
            super.blendMode = _blendMode;
            needsDisplayObjectAssignment = true;
        }
        
        if (needsDisplayObjectAssignment)
        {
            needsDisplayObjectAssignment = false;
            assignDisplayObjects();
        }
        
        // Check whether we manage the elements, or are they managed by an ItemRenderer
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Validate element properties
        var length:int = numItems;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = getItemAt(i) as GraphicElement;
            if (element)
                element.validateProperties();
        }
    }
    
    /**
     *  @private
     */
    override public function validateSize(recursive:Boolean = false):void
    {
        // Since GraphicElement is not ILayoutManagerClient, we need to make sure we
        // validate sizes of the elements, even in cases where recursive==false.
        
        // Check whether we manage the elements, or are they managed by an ItemRenderer
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Validate element size
        var length:int = numItems;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = getItemAt(i) as GraphicElement;
            if (element)
                element.validateSize();
        }

        super.validateSize(recursive);
    }   
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Iterate through the graphic elements, clear their graphics and draw them

        graphics.clear(); // Clear the group's graphic because graphic elements might be drawing to it
        // This isn't needed for DataGroup because there's not much DisplayObject sharing
        
        // TODO EGeorgie: we need to optimize this, iterating through all the elements is slow.
        // Iterate through the graphic elements, clear their graphics and draw them
        var length:int = numItems;
        for (var i:int = 0; i < length; i++)
        {
            var element:GraphicElement = getItemAt(i) as GraphicElement;
            if (element)
                element.validateDisplayList();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Content management
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The number of items in this group.
     *
     */
    public function get numItems():int
    {
        if (_content === null)
            return 0;
            
        if (_contentType == CONTENT_TYPE_ARRAY)
            return _content.length;
        
        return 1;
    }
    
    /**
     *  Returns the item that exists at the specified index.
     *
     *  @param index The index of the item to retrieve.
     *
     *  @return The item at the specified index.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     */ 
    public function getItemAt(index:int):Object
    {
        // check for RangeError:
        checkForRangeError(index);
        
        if (_content === null)
            return null;
        
        if (_contentType == CONTENT_TYPE_ARRAY)
            return _content[index];
        
        return _content;
    }
    
    /**
     *  @private 
     *  Checks the range of index to make sure it's valid
     */ 
    private function checkForRangeError(index:int, addingItem:Boolean = false):void
    {
        // figure out the maximum allowable index
        var maxIndex:int = -1;
        
        if (_content === null)
            maxIndex = -1;
        else if (_contentType == CONTENT_TYPE_UNKNOWN)
            maxIndex = 0;
        else if (_contentType == CONTENT_TYPE_ARRAY)
            maxIndex = content.length - 1;
        
        // if adding an item, we allow an extra index at the end
        if (addingItem)
            maxIndex++;
            
        if (index > maxIndex)
            throw new RangeError("Index " + index + " is out of range");
    }
 
    /**
     *  Adds an item to this Group. The item is added after all other
     *  items and on top of all other items.  (To add an item to a specific 
     *  index position, use the <code>addChildAt()</code> method.)
     * 
     * <p>If you add an item object that already has a different
     * container as a parent, the object is removed from the child 
     * list of the other container.</p>  
     *
     *  @param item The item to add as a child of this Group instance.
     *
     *  @return The item that was added to the Group.
     * 
     *  @event itemAdded ItemExistenceChangedEvent Dispatched when the item is added to the child list.
     * 
     *  @throws ArgumentError If the child is the same as the parent.
     */   
    public function addItem(item:Object):Object
    {
        return addItemAt(item, numItems);
    }
    
    /**
     *  Adds an item to this Group. The item is added at the index
     *  position specified.  An index of 0 represents the first item
     *  and the back (bottom) of the display list.
     *
     *  @param item The item to add as a child of this Group instance.
     * 
     *  @param index The index position to which the item is added. If 
     *  you specify a currently occupied index position, the child object 
     *  that exists at that position and all higher positions are moved 
     *  up one position in the child list.
     *
     *  @return The item that was added to the Group.
     * 
     *  @event itemAdded Dispatched when the item is added to the child list
     * 
     *  @throws ArgumentError If the child is the same as the parent.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     */
    public function addItemAt(item:Object, index:int):Object
    {
        if (item == this)
            throw new ArgumentError("Cannot add yourself as a child of yourself");
            
        // check for RangeError:
        checkForRangeError(index, true);
        
        // If we don't have any content yet, initialize it to an empty array
        if (_content === null)
        {
            content = [];
            contentChanged = false;
        }
        
        // If we have unknown content (ie a single item), convert to an Array
        if (_contentType == CONTENT_TYPE_UNKNOWN)
        {
            _contentType = CONTENT_TYPE_ARRAY;
            _content = [_content];
        }
        
        if (_contentType == CONTENT_TYPE_ARRAY)
            _content.splice(index, 0, item);
        
        itemAdded(item, index);
        
        needsDisplayObjectAssignment = true;
        invalidateProperties();
        
        return item;
    }
    
    /**
     *  Removes the specified item from the child list of this group.
     *  The index positions of any items above the item in the Group 
     *  are decreased by 1.
     *
     *  @param item The item to be removed from the Group.
     *
     *  @return The item removed from the Group.
     * 
     *  @throws ArgumentError If the item parameter is not a child of this object.
     */
    public function removeItem(item:Object):Object
    {
        return removeItemAt(getItemIndex(item));
    }
    
    /**
     *  Removes an item from the specified index position in the Group.
     *
     *  @param index The index of the item to remove.
     *
     *  @return The item removed from the Group.
     * 
     *  @throws RangeError If the index does not exist in the child list.
     */
    public function removeItemAt(index:int):Object
    {
        // check RangeError
        checkForRangeError(index);
        
        var item:Object;
        
        if (_content === null)
            return null;
        
        // Need to call itemRemoved before removing the item so anyone listening
        // for the event can access the item.
        
        itemRemoved(index);
        
        switch (_contentType)
        {
            case CONTENT_TYPE_ARRAY:
            {
                var removed:Array = _content.splice(index, 1);
                if (removed && removed.length > 0)
                    item = removed[0];
                break;  
            }
                
            case CONTENT_TYPE_UNKNOWN:
            {
                item = _content;
                _content = null;
                break;
            }    
        }
            
        needsDisplayObjectAssignment = true;
        invalidateProperties();
        
        return item;
    }
    
    /**
     *  Returns the index position of an item.
     *
     *  @param item The item to identify.
     *
     *  @return The index position of the item to identify.
     * 
     *  @throws ArgumentError If the item is not a child of this object.
     */ 
    public function getItemIndex(item:Object):int
    {
        var index:int = -1;
        
        switch (_contentType)
        {
            case CONTENT_TYPE_UNKNOWN:
            {
                if (_content == item)
                    index = 0;
                break;
            }
            
            case CONTENT_TYPE_ARRAY:
            {
                index = _content.indexOf(item);
                break;
            }
        }
        
        if (index == -1)
            throw ArgumentError(item + " is not found in this Group");
        else
            return index;
    }
    
    /**
     *  Changes the position of an existing child in the Group.
     * 
     *  <p>When you call the <code>setItemIndex()</code> method and specify an 
     *  index position that is already occupied, the only positions 
     *  that change are those in between the item's former and new position.
     *  All others will stay the same.</p>
     *
     *  <p>If an item is moved to an index 
     *  lower than its current index, the index of all items in between increases
     *  by 1.  If an item is moved to an index
     *  higher than its current index, the index of all items in between 
     *  decreases by 1.</p>
     *
     *  @param item The item for which you want to change the index number.
     * 
     *  @param index The resulting index number for the item.
     * 
     *  @throws RangeError - If the index does not exist in the child list.
     *
     *  @throws ArgumentError - If the item parameter is not a child 
     *  of this object.
     */
    public function setItemIndex(item:Object, index:int):void
    {
        // check for RangeError...this is done in addItemAt
        // but we want to do it before removing the item
        checkForRangeError(index);
        
        removeItem(item);
        addItemAt(item, index);
    }
    
    /**
     *  Swaps the index of the two specified items. All other items
     *  remain in the same index position.
     *
     *  @param item1 The first item.
     * 
     *  @param item2 The second item.
     * 
     *  @throws ArgumentError If either item is not a child of this object.
     */
    public function swapItems(item1:Object, item2:Object):void
    {
        swapItemsAt(getItemIndex(item1), getItemIndex(item2));
    }
    
    /**
     *  Swaps the items at the two specified index positions in 
     *  the Group.  All other items remain in the same index position.
     *
     *  @param index1 The index of the first item.
     * 
     *  @param index2 The index of the second item.
     * 
     *  @throws RangeError If either index does not exist in the child list.
     */
    public function swapItemsAt(index1:int, index2:int):void
    {
        // Make sure that index1 is the smaller index so that addItemAt 
        // doesn't RTE
        if (index1 > index2)
        {
            var temp:int = index2;
            index2 = index1;
            index1 = temp; 
        }
        else if (index1 == index2)
            return;
        
        var item1:Object = getItemAt(index1);
        var item2:Object = getItemAt(index2);
        
        removeItem(item1);
        removeItem(item2);
        
        addItemAt(item2, index1);
        addItemAt(item1, index2);
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
    override public function get numLayoutItems():int
    {
        return numItems;
    }
    
    /**
     *  @inheritDoc
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     */ 
    override public function getLayoutItemAt(index:int):ILayoutItem
    {
        var item:Object = getItemAt(index);

        return LayoutItemFactory.getLayoutItemFor(item);
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
        if (needsDisplayObjectAssignment == true)
            return;
        needsDisplayObjectAssignment = true;
        invalidateProperties();
    }

    /**
     *  Adds an item to this Group.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param item The item that was added.
     *
     *  @param index The index where the item was added.
     */
    protected function itemAdded(item:Object, index:int):void
    {
        var child:DisplayObject;
                
        if (item is IVisualItem && (item as IVisualItem).layer != 0)
            invalidateLayering();

        if (item is GraphicElement) 
        {
            item.elementHost = this;
        
            // If a styleable GraphicElement is being added,
            // build its protochain for use by getStyle().
            if (item is IStyleClient)
                IStyleClient(item).regenerateStyleCache(true);
        }   
        else
        {
            // item must be a DisplayObject
            
            // This always adds the child to the end of the display list. Any 
            // ordering discrepancies will be fixed up in assignDisplayObjects().
            child = addItemToDisplayList(DisplayObject(item), item);
        }
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, item));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  Removes an item from this Group.
     *  Flex calls this method automatically; you do not call it directly.
     *
     *  @param index The index of the item that is being removed.
     */
    protected function itemRemoved(index:int):void
    {       
        var item:Object = getItemAt(index);
        var childDO:DisplayObject = item as DisplayObject;
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, item));        
        if (item && (item is GraphicElement))
        {
            item.elementHost = null;
            item.sharedDisplayObject = null;
            childDO = GraphicElement(item).displayObject;
        }
                
        if (childDO && childDO.parent && childDO.parent == this)
            super.removeChild(childDO);
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     *  
     *  Returns true if the Group's display object can be shared with graphic elements
     *  inside the group
     */
    private function get canShareDisplayObject():Boolean
    {
        return blendMode == "normal" && (layeringMode == ITEM_ORDERED_LAYERING);
    }
    
    /**
     *  @private
     *  
     *  Called to assign display objects to graphic elements
     */
    private function assignDisplayObjects():void
    {
        var topLayerItems:Vector.<IVisualItem>;
        var bottomLayerItems:Vector.<IVisualItem>;        
        var keepLayeringEnabled:Boolean = false;
        
        mergeData.currentAssignableDO  = canShareDisplayObject ? this : null;
        mergeData.lastDisplayObject = this;
        mergeData.insertIndex = 0;

        // Iterate through all of the items
        var len:int = numItems; 
        for (var i:int = 0; i < len; i++)
        {  
            var item:Object = getItemAt(i);
            
            if (layeringMode != ITEM_ORDERED_LAYERING)
            {
                var layer:Number = 0;
                if (item is IVisualItem)
                    layer = (item as IVisualItem).layer;
                if (layer != 0)
                {               
                    if (layer > 0)
                    {
                        if (topLayerItems == null) topLayerItems = new Vector.<IVisualItem>();
                        topLayerItems.push(item);
                        continue;                   
                    }
                    else
                    {
                        if (bottomLayerItems == null) bottomLayerItems = new Vector.<IVisualItem>();
                        bottomLayerItems.push(item);
                        continue;                   
                    }
                }
            }
            assignDisplayObjectTo(item,mergeData);
        }
        if (topLayerItems != null)
        {
            keepLayeringEnabled = true;
            //topLayerItems.sortOn("layer",Array.NUMERIC);
            sortOnLayer(topLayerItems);
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
            mergeData.lastDisplayObject = this;
            mergeData.insertIndex = 0;

            //bottomLayerItems.sortOn("layer",Array.NUMERIC);
            sortOnLayer(bottomLayerItems);
            len = bottomLayerItems.length;

            for (i=0;i<len;i++)
            {
                assignDisplayObjectTo(bottomLayerItems[i],mergeData);
            }
        }
        
        if (keepLayeringEnabled == false)
            layeringMode = ITEM_ORDERED_LAYERING;        
    }
    
    /**
     *  @private
     * 
     *  A simple insertion sort.  This works well for small lists (under 12 or so), uses
     *  no aditional memory, and most importantly, is stable, meaning items with comparable
     *  values will stay in the same order relative to each other. For layering, we guarantee
     *  first the layer property, and then the item order, so a stable sort is important (and the 
     *  built in flash sort is not stable).
     */
    private static function sortOnLayer(a:Vector.<IVisualItem>):void
    {
        var len:Number = a.length;
        var tmp:IVisualItem;
        if (len<= 1)
            return;
        for (var i:int = 1;i<len;i++)
        {
            for (var j:int = i;j > 0;j--)
            {
                if ( a[j].layer < a[j-1].layer )
                {
                    tmp = a[j];
                    a[j] = a[j-1];
                    a[j-1] = tmp;
                }
                else
                    break;
            }
        }
    }

    /**
     *  @private
     */
    private function assignDisplayObjectTo(item:Object,mergeData:GroupDisplayObjectMergeData):void
    {
        if (mergeData.lastDisplayObject == this)
            mergeData.insertIndex = 0;
        else
            mergeData.insertIndex = super.getChildIndex(mergeData.lastDisplayObject) + 1;
            
        if (item is DisplayObject)
        {
            super.setChildIndex(item as DisplayObject, mergeData.insertIndex);
            
            mergeData.lastDisplayObject = item as DisplayObject;
            // Null this out so that we are forced to create one for the next item
            mergeData.currentAssignableDO = null; 
        }           
        else if (item is GraphicElement)
        {
            var element:GraphicElement = item as GraphicElement;
            
            if (mergeData.currentAssignableDO == null || element.needsDisplayObject)
            {
                var newChild:DisplayObject = element.displayObject;
                
                if (newChild == null)
                {
                    newChild = element.createDisplayObject();
                    element.displayObject = newChild; // TODO!! Handle this in createDisplayObject?                 
                }
                
                addItemToDisplayList(newChild, item, mergeData.insertIndex); 
                // If the element is transformed, the next item needs its own DO        
                mergeData.currentAssignableDO = element.nextSiblingNeedsDisplayObject ? null : newChild;
                mergeData.lastDisplayObject = newChild;
            }
            else
            {
                // Item should be assigned the currentAssignableDO
                // If it already has a DO, we need to remove it
                if (element.displayObject)
                {
                    if (element.displayObject.parent == this)
                        super.removeChild(element.displayObject);
                    element.destroyDisplayObject();
                }
                
                element.sharedDisplayObject = mergeData.currentAssignableDO;
                if (element.nextSiblingNeedsDisplayObject)
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
    protected function addItemToDisplayList(child:DisplayObject, item:Object, index:int = -1):DisplayObject
    { 
        var host:DisplayObject;
        
        if (item is GraphicElement)
            host = DisplayObject(GraphicElement(item).elementHost); 
        else if (item is DisplayObject)
            host = DisplayObject(item).parent;
        
        // Remove the item from the group if that group isn't this group
        if (host && host is Group && host != this)
            Group(host).removeItem(item);
        else if (host && host is DataGroup && host != this)
        {
            var dp:IList = DataGroup(host).dataProvider;
            var index:int = dp.getItemIndex(item);
            dp.removeItemAt(index);
        }
        
        // Calling removeItem should have already removed the child. This
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
    override public function elementLayerChanged(e:IGraphicElement):void
    {
        super.elementLayerChanged(e);
        
        // One of our children have told us they might need a displayObject     
        needsDisplayObjectAssignment = true;
        invalidateProperties();
    }
    
    /**
     *  Dictionary to keep track of mask elements.  Because mask elements can be applied 
     *  to GraphicElements, which may not be DisplayObjects, the Group needs to know this
     *  to map GraphicElements to DisplayObjects later on since masking takes place
     *  at the Flash Player level.
     */ 
    protected var maskElements:Dictionary;
    
    /**
     *  @private
     */
    override public function addMaskElement(mask:DisplayObject, target:IGraphicElement):void
    {
        if (!maskElements)
            maskElements = new Dictionary();
            
        maskElements[mask] = target;
        contentChanged = true;
        // TODO!! Remove this once GraphicElements use the LayoutManager. Currently the
        // callLater is necessary because addMaskElement gets called inside of commitProperties
        callLater(invalidateProperties); 
            
    }
    
    /**
     *  @private
     */
    override public function removeMaskElement(mask:DisplayObject, target:IGraphicElement):void
    {
        if (maskElements && mask in maskElements)
        {
            delete maskElements[mask];
            contentChanged = true;
             // TODO!! Remove this once GraphicElements use the LayoutManager. Currently the
            // callLater is necessary because removeMaskElement gets called inside of commitProperties
            callLater(invalidateProperties);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties: ScaleGrid
    //
    //--------------------------------------------------------------------------

    private var scaleGridChanged:Boolean = false;

    //----------------------------------
    //  scaleGridBottom
    //----------------------------------

    private var _scaleGridBottom:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     * Specfies the bottom coordinate of the scale grid.
     */
    public function get scaleGridBottom():Number
    {
        return _scaleGridBottom;
    }
    
    public function set scaleGridBottom(value:Number):void
    {
        var oldValue:Number = _scaleGridBottom;
        
        if (value != oldValue)
        {
            _scaleGridBottom = value;
            scaleGridChanged = true;
            invalidateDisplayList();
            dispatchPropertyChangeEvent("scaleGridBottom", oldValue, value);
        }
    }
    
    //----------------------------------
    //  scaleGridLeft
    //----------------------------------

    private var _scaleGridLeft:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     * Specfies the left coordinate of the scale grid.
     */
    public function get scaleGridLeft():Number
    {
        return _scaleGridLeft;
    }
    
    public function set scaleGridLeft(value:Number):void
    {
        var oldValue:Number = _scaleGridLeft;
        
        if (value != oldValue)
        {
            _scaleGridLeft = value;
            scaleGridChanged = true;
            invalidateDisplayList();
            dispatchPropertyChangeEvent("scaleGridLeft", oldValue, value);
        }
    }

    //----------------------------------
    //  scaleGridRight
    //----------------------------------

    private var _scaleGridRight:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     * Specfies the right coordinate of the scale grid.
     */
    public function get scaleGridRight():Number
    {
        return _scaleGridRight;
    }
    
    public function set scaleGridRight(value:Number):void
    {
        var oldValue:Number = _scaleGridRight;
        
        if (value != oldValue)
        {
            _scaleGridRight = value;
            scaleGridChanged = true;
            invalidateDisplayList();
            dispatchPropertyChangeEvent("scaleGridRight", oldValue, value);
        }
    }

    //----------------------------------
    //  scaleGridTop
    //----------------------------------

    private var _scaleGridTop:Number;
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]
    
    /**
     * Specfies the top coordinate of the scale grid.
     */
    public function get scaleGridTop():Number
    {
        return _scaleGridTop;
    }
    
    public function set scaleGridTop(value:Number):void
    {
        var oldValue:Number = _scaleGridTop;
        
        if (value != oldValue)
        {
            _scaleGridTop = value;
            scaleGridChanged = true;
            invalidateDisplayList();
            dispatchPropertyChangeEvent("scaleGridTop", oldValue, value);
        }
    }
    
    /**
     *  @private
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("addChild is not available in Group. Use addItem instead."));
    }
    
    /**
     *  @private
     */
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("addChildAt is not available in Group. Use addItemAt instead."));
    }
    
    /**
     *  @private
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("removeChild is not available in Group. Use removeItem instead."));
    }
    
    /**
     *  @private
     */
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("removeChildAt is not available in Group. Use removeItemAt instead."));
    }
    
    /**
     *  @private
     */
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("setChildIndex is not available in Group. Use setItemIndex instead."));
    }
    
    /**
     *  @private
     */
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("swapChildren is not available in Group. Use swapItems instead."));
    }
    
    /**
     *  @private
     */
    override public function swapChildrenAt(index1:int, index2:int):void
    {
        throw(new Error("swapChildrenAt is not available in Group. Use swapItemsAt instead."));
    }
    
}
}


import flash.display.DisplayObject; 

class GroupDisplayObjectMergeData
{
    public var currentAssignableDO:DisplayObject;
    public var lastDisplayObject:DisplayObject;
    public var insertIndex:int;
}

const mergeData:GroupDisplayObjectMergeData = new GroupDisplayObjectMergeData();
