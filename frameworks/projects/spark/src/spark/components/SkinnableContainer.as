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

import mx.components.Group;
import mx.core.IDeferredContentOwner;
import mx.components.baseClasses.FxComponent;
import mx.components.baseClasses.FxContainerBase;
import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.layout.LayoutBase;

import mx.collections.IList;
import mx.core.ContainerCreationPolicy;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.managers.IFocusManagerContainer;

/**
 *  Dispatched after the content for this component has been created. With deferred 
 *  instantiation, the content for a component may be created long after the 
 *  component is created.
 *
 *  @eventType mx.events.FlexEvent.CONTENT_CREATION_COMPLETE
 */
[Event(name="contentCreationComplete", type="mx.events.FlexEvent")]

/**
 *  Dispatched when an item is added to the component.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_ADD
 */
[Event(name="itemAdd", type="mx.events.ItemExistenceChangedEvent")]

/**
 *  Dispatched when an item is removed from the component.
 *
 *  @eventType mx.events.ItemExistenceChangedEvent.ITEM_REMOVE
 */
[Event(name="itemRemove", type="mx.events.ItemExistenceChangedEvent")]

[DefaultProperty("contentFactory")]

/**
 *  The FxContainer class is the base class for all skinnable components that have 
 *  visual content. This class is not typically instantiated in MXML. It is primarily
 *  used as a base class, or to define a skin part.
 *
 *  @see FxDataContainer
 */
public class FxContainer extends FxContainerBase 
       implements IDeferredContentOwner
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxContainer()
    {
        super();
        
        tabChildren = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart]
    public var contentGroup:Group;
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    // Used to hold the content until the contentGroup is created. 
    private var _placeHolderGroup:Group;
    
    protected function get currentContentGroup():Group
    {          
        createContentIfNeeded();
    
        if (!contentGroup)
        {
            if (!_placeHolderGroup)
            {
                _placeHolderGroup = new Group();
                 
                if (_content)
                    _placeHolderGroup.content = _content;
                
                _placeHolderGroup.addEventListener(
                    ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
                _placeHolderGroup.addEventListener(
                    ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
            }
            return _placeHolderGroup;
        }
        else
        {
            return contentGroup;    
        }
    }
   
    //----------------------------------
    //  contentFactory
    //----------------------------------
    
    /** 
     *  @private
     *  Backing variable for the contentFactory property.
     */
    private var _contentFactory:IDeferredInstance;

    /**
     *  @private
     *  Flag that indicates whether or not the content has been created.
     */
    private var contentCreated:Boolean = false;
    
    /**
     *  A factory object that creates the initial value for the
     *  content property.
     */
    public function get contentFactory():IDeferredInstance
    {
        return _contentFactory;
    }   
    
    /**
     *  @private
     */
    public function set contentFactory(value:IDeferredInstance):void
    {
        if (value == _contentFactory)
            return;
        
        _contentFactory = value;
        contentCreated = false;
    }
    
    //----------------------------------
    //  creationPolicy
    //----------------------------------
    
    private var _creationPolicy:String = "auto";
    
    /**
     *  @inheritDoc
     */
    public function get creationPolicy():String
    {
        return _creationPolicy;
    }
    
    /**
     *  @private
     */
    public function set creationPolicy(value:String):void
    {
        if (value == _creationPolicy)
            return;
        
        _creationPolicy = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties proxied to contentHolder
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  content
    //----------------------------------    
    
    private var _content:Object;
    
    /**
     *  @copy mx.components.Group#content
     */
    [Bindable]
    public function get content():Object
    { 
        // Make sure deferred content is created, if needed
        createContentIfNeeded();
    
        if (contentGroup)
            return contentGroup.content;
        else if (_placeHolderGroup)
            return _placeHolderGroup.content;
        else
            return _content; 
    }
    
    /**
     *  @private
     */
    public function set content(value:Object):void
    {
        if (value == _content)
            return;
            
        _content = value;   

        if (contentGroup)
            contentGroup.content = value;
        else if (_placeHolderGroup)
            _placeHolderGroup.content = value;
    }
    
    //----------------------------------
    //  layout
    //----------------------------------
    
    private var _layout:LayoutBase = null;
    
    /**
     *  @copy mx.components.baseClasses.GroupBase#layout
     */
    public function get layout():LayoutBase
    {
        return (contentGroup) ? contentGroup.layout : _layout;
    }
    
    /**
     * @private
     */
    public function set layout(value:LayoutBase):void
    {
        _layout = value;  
        if (contentGroup)
            contentGroup.layout = _layout;
        
    }
         
    //--------------------------------------------------------------------------
    //
    //  Methods proxied to contentGroup
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy mx.components.Group#numItems
     */
    public function get numItems():int
    {
        return currentContentGroup.numItems;
    }
    
    /**
     *  @copy mx.components.Group#getItemAt()
     */
    public function getItemAt(index:int):Object
    {
        return currentContentGroup.getItemAt(index);
    }
    
    /**
     *  @copy mx.components.Group#addItem()
     */
    public function addItem(item:Object):Object
    {
        return currentContentGroup.addItem(item);
    }
    
    /**
     *  @copy mx.components.Group#addItemAt()
     */
    public function addItemAt(item:Object, index:int):Object
    {
        return currentContentGroup.addItemAt(item, index);
    }
    
    /**
     *  @copy mx.components.Group#removeItem()
     */
    public function removeItem(item:Object):Object
    {
        return currentContentGroup.removeItem(item);
    }
    
    /**
     *  @copy mx.components.Group#removeItemAt()
     */
    public function removeItemAt(index:int):Object
    {
        return currentContentGroup.removeItemAt(index);
    }
    
    /**
     *  @copy mx.components.Group#getItemIndex()
     */
    public function getItemIndex(item:Object):int
    {
        return currentContentGroup.getItemIndex(item);
    }
    
    /**
     *  @copy mx.components.Group#setItemIndex()
     */
    public function setItemIndex(item:Object, index:int):void
    {
        currentContentGroup.setItemIndex(item, index);
    }
    
    /**
     *  @copy mx.components.Group#swapItems()
     */
    public function swapItems(item1:Object, item2:Object):void
    {
        currentContentGroup.swapItems(item1, item2);
    }
    
    /**
     *  @copy mx.components.Group#swapItemsAt()
     */
    public function swapItemsAt(index1:int, index2:int):void
    {
        currentContentGroup.swapItemsAt(index1, index2);
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Create our content, if the creationPolicy is != "none".
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        // TODO: When navigator support is added, this is where we would 
        // determine if content should be created now, or wait until
        // later. For now, we always create content here unless
        // creationPolicy="none".
        createContentIfNeeded();
    }
   
    /**
     *  Called when a skin part has been added or assigned. 
     *  This method pushes the content, layout, itemRenderer, and
     *  itemRendererFunction properties down to the contentGroup
     *  skin part.
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == contentGroup)
        {
            if (_placeHolderGroup != null)
            {
                var sourceContent:Array = _placeHolderGroup.content as Array;
                
                if (sourceContent)
                    contentGroup.content = sourceContent.slice();
                else if (_placeHolderGroup.content is IList)
                    throw new Error("ContainerSkin can not currently handle content of type " + 
                            "IList when adding children dynamically.");
                else
                    contentGroup.content = _placeHolderGroup.content;
                
                // Temporary workaround because copying content from one Group to another throws RTE
                for (var i:int = _placeHolderGroup.numItems; i > 0; i--)
                {
                    _placeHolderGroup.removeItemAt(0);  
                }
                
            }
            else if (_content != null)
            {
                contentGroup.content = _content;
            }
            if (_layout != null)
                contentGroup.layout = _layout;
            
            contentGroup.addEventListener(
                ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
            contentGroup.addEventListener(
                ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
            
            if (_placeHolderGroup)
            {
                _placeHolderGroup.removeEventListener(
                    ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
                _placeHolderGroup.removeEventListener(
                    ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
                
                _placeHolderGroup = null;
            }
        }
    }

    /**
     *  Called when a skin part is removed.
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == contentGroup)
        {
            contentGroup.removeEventListener(
                ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
            contentGroup.removeEventListener(
                ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  IDeferredContentOwner methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Create the content for this component. When creationPolicy is "auto" or
     *  "all", this function is called automatically by the Flex framework.
     *  When creationPolicy="none", this method must be called to initialize
     *  the content property.
     */
    public function createDeferredContent():void
    {
        if (!contentCreated)
        {
            contentCreated = true;
            
            if (contentFactory)
            {
                content = contentFactory.getInstance();
                dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
            }
        }
    }
    
    /**
     *  @private
     */
    private function createContentIfNeeded():void
    {
        if (!contentCreated && creationPolicy != ContainerCreationPolicy.NONE)
            createDeferredContent();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    private function contentGroup_itemAddedHandler(event:ItemExistenceChangedEvent):void
    {
        // Re-dispatch the event
        dispatchEvent(event);
    }
    
    private function contentGroup_itemRemovedHandler(event:ItemExistenceChangedEvent):void
    {
        // Re-dispatch the event
        dispatchEvent(event);
    }
}

}
