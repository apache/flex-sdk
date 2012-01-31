package flex.core {
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import flex.events.FlexEvent;
import flex.events.ItemExistenceChangedEvent;
import flex.graphics.Graphic;
import flex.graphics.IGraphicElement;
import flex.graphics.graphicsClasses.GraphicElement;
import flex.intf.ILayoutItem;
import flex.layout.LayoutItemFactory;

import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.ListCollectionView;
import mx.controls.Label;
import mx.core.IDataRenderer;
import mx.core.IDeferredInstance;
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
 */
[Event(name="itemAdd", type="flex.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the content holder.
 *  event.relatedObject is the visual item that was removed.
 */
[Event(name="itemRemove", type="flex.events.ItemExistenceChangedEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")] 

/**
 *  The Group class.
 */
public class Group extends GroupBase 
{
    public function Group():void
    {
        super();      
    }
    
    private var contentChanged:Boolean = false;
    private var needsDisplayObjectAssignment:Boolean = false;
    
    private var _content:*;
    private var _contentType:int;
    private var contentCollection:ICollectionView;
    private var layeringMode:uint = ITEM_ORDERED_LAYERING;
    
    private static const ITEM_ORDERED_LAYERING:uint = 0;
    private static const SPARSE_LAYERING:uint = 1;
    
    private static const CONTENT_TYPE_UNKNOWN:int = 0;
    private static const CONTENT_TYPE_ARRAY:int = 1;
    private static const CONTENT_TYPE_ILIST:int = 2;
    
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
     *  Documentation is not currently available. 
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
     *  Documentation is not currently available. 
     */
    override public function get blendMode():String
    {
    	if (blendModeExplicitlySet)
        	return _blendMode;
		else return BlendMode.LAYER;
    }
    
    public function set content(value:*):void
    {
        if (contentCollection)
        {
            contentCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler);
            contentCollection = null;
        }
        
        _content = value;
        
        // Need to convert null to undefined here, since subsequent content checks test for undefined
        if (_content === null)
            _content = undefined;
            
        if (_content is IList)
        {
            _contentType = CONTENT_TYPE_ILIST;
            contentCollection = new ListCollectionView(IList(_content));
            contentCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, collectionChangeHandler, false, 0, true);
        }
        else if (_content is Array)
            _contentType = CONTENT_TYPE_ARRAY;
        else
            _contentType = CONTENT_TYPE_UNKNOWN;
            
        contentChanged = true;
        invalidateProperties();
    }
    
    public function get content():*
    {
        return _content;
    }

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
        
        if (_content !== undefined)
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
    
    public function get numItems():int
    {
        if (_content === undefined)
            return 0;
            
        switch (_contentType)
        {
            case CONTENT_TYPE_ARRAY:
            case CONTENT_TYPE_ILIST:
                return _content.length;
                break;
        }
        
        return 1;
    }
    
    public function getItemAt(index:int):*
    {
        if (_content === undefined)
            return null;
        
        switch (_contentType)
        {
            case CONTENT_TYPE_ARRAY:
                return _content[index];
                break;
            
            case CONTENT_TYPE_ILIST:
                return _content.length > index ? _content.getItemAt(index) : null;
                break;
        }
        
        return _content;
    }
    
    public function addItem(item:*):*
    {
        return addItemAt(item, numItems);
    }
    
    public function addItemAt(item:*, index:int):*
    {
        // If we don't have any content yet, initialize it to an empty array
        if (_content === undefined)
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
        
        switch (_contentType)
        {
            case CONTENT_TYPE_ARRAY:
                _content.splice(index, 0, item);
                break;
            
            case CONTENT_TYPE_ILIST:
                _content.addItemAt(item, index);
                break;
        }
        
        itemAdded(item, index);
        
        needsDisplayObjectAssignment = true;
        invalidateProperties();
        
        return item;
    }
    
    public function removeItem(item:*):*
    {
        return removeItemAt(getItemIndex(item));
    }
    
    public function removeItemAt(index:int):*
    {       
        var item:*;
        
        if (_content === undefined)
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
            
            case CONTENT_TYPE_ILIST:
                item = _content.removeItemAt(index);
                break;
                
            case CONTENT_TYPE_UNKNOWN:
            {
                item = _content;
                _content = undefined;
                break;
            }    
        }
            
        needsDisplayObjectAssignment = true;
        invalidateProperties();
        
        return item;
    }
    
    public function getItemIndex(item:*):int
    {
        if (_content === undefined)
            return -1;
        
        switch (_contentType)
        {
            case CONTENT_TYPE_ARRAY:
                return _content.indexOf(item);
                break;
            
            case CONTENT_TYPE_ILIST:
                return _content.getItemIndex(item);
                break;
        }
        
        return 0;
    }
    
    public function setItemIndex(item:*, index:int):void
    {
        removeItem(item);
        addItemAt(item, index);
    }
    
    public function swapItems(item1:*, item2:*):void
    {
        swapItemsAt(getItemIndex(item1), getItemIndex(item2));
    }
    
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
        
        var item1:* = getItemAt(index1);
        var item2:* = getItemAt(index2);
        
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
     *  The number of layout items in this Group. Typically this is the same
     *  as the number of items in the Group.
     */
    override public function get numLayoutItems():int
    {
        return numItems;
    }
    
    /**
     *  Gets the <i>n</i>th layout item in the Group. For visual items, the 
     *  layout item is the item itself. For data items, the layout item is the 
     *  item renderer instance that is associated with the item.
     *
     *  @param index The index of the item to retrieve.
     *
     *  @return The layout item at the specified index.
     */
    override public function getLayoutItemAt(index:int):ILayoutItem
    {
        var item:* = getItemAt(index);

        return LayoutItemFactory.getLayoutItemFor(item);
    }

    
    //--------------------------------------------------------------------------
    //
    //  Content management (internal)
    //
    //--------------------------------------------------------------------------
    
    
    override public function invalidateLayering():void
    {
    	if(layeringMode == ITEM_ORDERED_LAYERING)
    		layeringMode = SPARSE_LAYERING;
    	if(needsDisplayObjectAssignment == true)
    		return;
    	needsDisplayObjectAssignment = true;
    	invalidateProperties();
    }


    protected function itemAdded(item:*, index:int):void
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
            // This always adds the child to the end of the display list. Any 
            // ordering discrepancies will be fixed up in assignDisplayObjects().
            child = addItemToDisplayList(item, item);
        }
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_ADD, false, false, item));
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    protected function itemRemoved(index:int):void
    {       
        var item:* = getItemAt(index);
        var childDO:DisplayObject = item as DisplayObject;
        
        dispatchEvent(new ItemExistenceChangedEvent(
                      ItemExistenceChangedEvent.ITEM_REMOVE, false, false, item));        
        if (item && (item is GraphicElement))
        {
            item.elementHost = null;
            item.sharedDisplayObject = null;
            childDO = GraphicElement(item).displayObject;
        }
                
        if (childDO)
            super.removeChild(childDO);
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    protected function collectionChangeHandler(event:Event):void
    {
        if (event is CollectionEvent)
        {
            var ce:CollectionEvent = CollectionEvent(event);

            /* if (ce.kind == CollectionEventKind.ADD)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REPLACE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REMOVE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.MOVE)
            {
                
            }
            else if (ce.kind == CollectionEventKind.REFRESH)
            {
                
            }
            else if (ce.kind == CollectionEventKind.RESET)
            {
            }
            else if (ce.kind == CollectionEventKind.UPDATE)
            {
                
            } */
            
            // TODO!! Fow now, always reapply the content. This needs to
            // be optimized in the future            
           contentChanged = true;
           invalidateProperties();
        }
            
    }
    
    // Returns true if the Group's display object can be shared with graphic elements
    // inside the group
    private function get canShareDisplayObject():Boolean
    {
    	return blendMode == "normal" && (layeringMode == ITEM_ORDERED_LAYERING);
    }
    
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
            var item:* = getItemAt(i);
            
        	if(layeringMode != ITEM_ORDERED_LAYERING)
        	{
        		var layer:Number = 0;
        		if (item is IVisualItem)
        			layer = (item as IVisualItem).layer;
        		if(layer != 0)
        		{        		
            		if (layer > 0)
            		{
            			if(topLayerItems == null) topLayerItems = new Vector.<IVisualItem>();
            			topLayerItems.push(item);
            			continue;            		
            		}
            		else
            		{
            			if(bottomLayerItems == null) bottomLayerItems = new Vector.<IVisualItem>();
            			bottomLayerItems.push(item);
            			continue;            		
            		}
            	}
         	}
			assignDisplayObjectTo(item,mergeData);
        }
        if(topLayerItems != null)
        {
        	keepLayeringEnabled = true;
        	//topLayerItems.sortOn("layer",Array.NUMERIC);
        	sortOnLayer(topLayerItems);
        	len = topLayerItems.length;
        	for(i=0;i<len;i++)
        	{
        		assignDisplayObjectTo(topLayerItems[i],mergeData);
        	}
        }
        if(bottomLayerItems != null)
        {
        	keepLayeringEnabled = true;
	        mergeData.currentAssignableDO  = null;
	        mergeData.lastDisplayObject = this;
	        mergeData.insertIndex = 0;

        	//bottomLayerItems.sortOn("layer",Array.NUMERIC);
        	sortOnLayer(bottomLayerItems);
        	len = bottomLayerItems.length;

        	for(i=0;i<len;i++)
        	{
        		assignDisplayObjectTo(bottomLayerItems[i],mergeData);
        	}
        }
        if(keepLayeringEnabled == false)
        	layeringMode = ITEM_ORDERED_LAYERING;        
    }
    
    /**
    * @private
    * a simple insertion sort.  This works well for small lists (under 12 or so), uses
    * no aditional memory, and most importantly, is stable, meaning items with comparable
    * values will stay in the same order relative to each other. For layering, we guarantee
    * first the layer property, and then the item order, so a stable sort is important (and the 
    * built in flash sort is not stable).
    */
	private static function sortOnLayer(a:Vector.<IVisualItem>):void
	{
		var len:Number = a.length;
		var tmp:*;
		if(len<= 1)
			return;
		for(var i:int = 1;i<len;i++)
		{
			for (var j:int = i;j > 0;j--)
			{
				if( a[j].layer < a[j-1].layer )
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

    private function assignDisplayObjectTo(item:*,mergeData:GroupDisplayObjectMergeData):void
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
   
    
    // Helper function to remove child from other Group or display list before 
    // adding to the display list. 
    protected function addItemToDisplayList(child:DisplayObject, item:*, index:int = -1):DisplayObject
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
    
    override public function elementLayerChanged(e:IGraphicElement):void
    {
        super.elementLayerChanged(e);
        
        // One of our children have told us they might need a displayObject     
        needsDisplayObjectAssignment = true;
        invalidateProperties();
    }
    
    protected var maskElements:Dictionary;
    
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
    
    // TODO (rfrishbe): need to figure out if we must duplicate these 
    // RTEs across DataGroup and Group.
    override public function addChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("addChild is not available in Group. Use addItem instead."));
    }
    
    override public function addChildAt(child:DisplayObject, index:int):DisplayObject
    {
        throw(new Error("addChildAt is not available in Group. Use addItemAt instead."));
    }
    
    override public function removeChild(child:DisplayObject):DisplayObject
    {
        throw(new Error("removeChild is not available in Group. Use removeItem instead."));
    }
    
    override public function removeChildAt(index:int):DisplayObject
    {
        throw(new Error("removeChildAt is not available in Group. Use removeItemAt instead."));
    }
    
    override public function setChildIndex(child:DisplayObject, index:int):void
    {
        throw(new Error("setChildIndex is not available in Group. Use setItemIndex instead."));
    }
    
    override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
    {
        throw(new Error("swapChildren is not available in Group. Use swapItems instead."));
    }
    
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
