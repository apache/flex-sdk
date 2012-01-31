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

import mx.collections.IList;
import mx.components.Group;
import mx.core.mx_internal;
import mx.components.baseClasses.FxComponent;
import mx.components.baseClasses.FxContainerBase;
import mx.core.ContainerCreationPolicy;
import mx.core.IDeferredContentOwner;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.IUIComponent;
import mx.core.IViewport;
import mx.core.ScrollUnit;
import mx.events.FlexEvent;
import mx.events.ItemExistenceChangedEvent;
import mx.events.PropertyChangeEvent;
import mx.layout.BasicLayout;
import mx.layout.LayoutBase;
import mx.managers.IFocusManagerContainer;
import mx.utils.BitFlagUtil;


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

include "../styles/metadata/AdvancedCharacterFormatTextStyles.as"
include "../styles/metadata/AdvancedContainerFormatTextStyles.as"
include "../styles/metadata/AdvancedParagraphFormatTextStyles.as"
include "../styles/metadata/BasicCharacterFormatTextStyles.as"
include "../styles/metadata/BasicContainerFormatTextStyles.as"
include "../styles/metadata/BasicParagraphFormatTextStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy mx.components.baseClasses.GroupBase#alternatingItemColors
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#contentBackgroundColor
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#focusColor
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes")]

/**
 * @copy mx.components.baseClasses.GroupBase#rollOverColor
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  @copy mx.components.baseClasses.GroupBase#symbolColor
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes")]


[IconFile("FxContainer.png")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[DefaultProperty("mxmlContentFactory")]

/**
 *  The FxContainer class is the base class for all skinnable components that have 
 *  visual content.
 *
 *  @see FxDataContainer
 */
public class FxContainer extends FxContainerBase 
       implements IDeferredContentOwner, IViewport, IVisualElementContainer
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const CLIP_CONTENT_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    private static const LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    private static const VERTICAL_SCROLL_POSITION_PROPERTY_FLAG:uint = 1 << 3;

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
    
    [SkinPart(required="true")]
    
    /**
     *  A required skin part that defines the Group where the content 
     *  children get pushed into and laid out.
     */
    public var contentGroup:Group;
    
    /**
     *  @private
     *  Several properties are proxied to contentGroup.  However, when contentGroup
     *  is not around, we need to store values set on FxContainer.  This object 
     *  stores those values.  If contentGroup is around, the values are stored 
     *  on the contentGroup directly.  However, we need to know what values 
     *  have been set by the developer on the FxContainer (versus set on 
     *  the contentGroup or defaults of the contentGroup) as those are values 
     *  we want to carry around if the contentGroup changes (via a new skin). 
     *  In order to store this info effeciently, contentGroupProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this FxContainer.  When the 
     *  contentGroup is not around, contentGroupProperties is a typeless 
     *  object to store these proxied properties.  When contentGroup is around,
     *  contentGroupProperties stores booleans as to whether these properties 
     *  have been explicitely set or not.
     */
    private var contentGroupProperties:Object = {};
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    // Used to hold the content until the contentGroup is created. 
    private var _placeHolderGroup:Group;
    
    mx_internal function get currentContentGroup():Group
    {          
        createContentIfNeeded();
    
        if (!contentGroup)
        {
            if (!_placeHolderGroup)
            {
                _placeHolderGroup = new Group();
                 
                if (_mxmlContent)
                    _placeHolderGroup.mxmlContent = _mxmlContent;
                
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
    //  Properties proxied to contentGroup
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  clipContent
    //----------------------------------
    
    /**
     *  @inheritDoc
     */
    public function get clipContent():Boolean 
    {
        return (contentGroup) 
            ? contentGroup.clipContent 
            : contentGroupProperties.clipContent;
    }

    /**
     *  @private
     */
    public function set clipContent(value:Boolean):void 
    {       
        if (contentGroup)
        {
            contentGroup.clipContent = value;
            contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
                                                        CLIP_CONTENT_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties.clipContent = value;
    }
    
    //----------------------------------
    //  contentWidth
    //---------------------------------- 
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @inheritDoc
     */
    public function get contentWidth():Number 
    {
        return (contentGroup) ? contentGroup.contentWidth : 0;  
    }

    //----------------------------------
    //  contentHeight
    //---------------------------------- 
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @inheritDoc
     */
    public function get contentHeight():Number 
    {
        return (contentGroup) ? contentGroup.contentHeight : 0;
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    [Bindable("propertyChange")]

    /**
     *  @inheritDoc
     */
    public function get horizontalScrollPosition():Number 
    {
        return (contentGroup) 
            ? contentGroup.horizontalScrollPosition 
            : contentGroupProperties.horizontalScrollPosition;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        if (contentGroup)
        {
            contentGroup.horizontalScrollPosition = value;
            contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
                                                        HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties.horizontalScrollPosition = value;
    }
    
    //----------------------------------
    //  layout
    //----------------------------------
    
    /**
     *  @copy mx.components.baseClasses.GroupBase#layout
     */
    public function get layout():LayoutBase
    {
        return (contentGroup) 
            ? contentGroup.layout 
            : contentGroupProperties.layout;
    }
    
    /**
     * @private
     */
    public function set layout(value:LayoutBase):void
    {
        if (contentGroup)
        {
            contentGroup.layout = value;
            contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
                                                        LAYOUT_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties.layout = value;
        
    }
    
    //----------------------------------
    //  mxmlContent
    //----------------------------------    
    
    private var _mxmlContent:Array;
    
    /**
     *  @copy mx.components.Group#content
     */
    [ArrayElementType("mx.core.IVisualElement")]
    [Bindable]
    public function get mxmlContent():Array
    { 
        // Make sure deferred content is created, if needed
        createContentIfNeeded();
    
        if (contentGroup)
            return contentGroup.mxmlContent;
        else if (_placeHolderGroup)
            return _placeHolderGroup.mxmlContent;
        else
            return _mxmlContent; 
    }
    
    /**
     *  @private
     */
    public function set mxmlContent(value:Array):void
    {
        if (value == _mxmlContent)
            return;
            
        _mxmlContent = value;   

        if (contentGroup)
            contentGroup.mxmlContent = value;
        else if (_placeHolderGroup)
            _placeHolderGroup.mxmlContent = value;
    }
    
    
    //----------------------------------
    //  mxmlContentFactory
    //----------------------------------
    
    /** 
     *  @private
     *  Backing variable for the contentFactory property.
     */
    private var _mxmlContentFactory:IDeferredInstance;

    /**
     *  @private
     *  Flag that indicates whether or not the content has been created.
     */
    private var mxmlContentCreated:Boolean = false;
    
    /**
     *  A factory object that creates the initial value for the
     *  content property.
     */
    public function get mxmlContentFactory():IDeferredInstance
    {
        return _mxmlContentFactory;
    }   
    
    /**
     *  @private
     */
    public function set mxmlContentFactory(value:IDeferredInstance):void
    {
        if (value == _mxmlContentFactory)
            return;
        
        _mxmlContentFactory = value;
        mxmlContentCreated = false;
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------
    
    [Bindable("propertyChange")]
    
    /**
     *  @inheritDoc
     */
    public function get verticalScrollPosition():Number 
    {
        return (contentGroup) 
            ? contentGroup.verticalScrollPosition 
            : contentGroupProperties.verticalScrollPosition;
    }

    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void 
    {
        if (contentGroup)
        {
            contentGroup.verticalScrollPosition = value;
            contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
                                                        VERTICAL_SCROLL_POSITION_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties.verticalScrollPosition = value;
    }
         
    //--------------------------------------------------------------------------
    //
    //  Methods proxied to contentGroup
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     */
    public function get numElements():int
    {
        return mx_internal::currentContentGroup.numElements;
    }
    
    /**
     *  @inheritDoc
     */
    public function getElementAt(index:int):IVisualElement
    {
        return mx_internal::currentContentGroup.getElementAt(index);
    }
    
        
    /**
     *  @inheritDoc
     */
    public function getElementIndex(element:IVisualElement):int
    {
        return mx_internal::currentContentGroup.getElementIndex(element);
    }
    
    /**
     *  @inheritDoc
     */
    public function addElement(element:IVisualElement):IVisualElement
    {
        return mx_internal::currentContentGroup.addElement(element);
    }
    
    /**
     *  @inheritDoc
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        return mx_internal::currentContentGroup.addElementAt(element, index);
    }
    
    /**
     *  @inheritDoc
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        return mx_internal::currentContentGroup.removeElement(element);
    }
    
    /**
     *  @inheritDoc
     */
    public function removeElementAt(index:int):IVisualElement
    {
        return mx_internal::currentContentGroup.removeElementAt(index);
    }
    
    /**
     *  @inheritDoc
     */
    public function setElementIndex(element:IVisualElement, index:int):void
    {
        mx_internal::currentContentGroup.setElementIndex(element, index);
    }
    
    /**
     *  @inheritDoc
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        mx_internal::currentContentGroup.swapElements(element1, element2);
    }
    
    /**
     *  @inheritDoc
     */
    public function swapElementsAt(index1:int, index2:int):void
    {
        mx_internal::currentContentGroup.swapElementsAt(index1, index2);
    }
    
    //----------------------------------
    //  getHorizontal,VerticalScrollPositionDelta
    //----------------------------------

    /**
     *  @inheritDoc
     */
    public function getHorizontalScrollPositionDelta(unit:ScrollUnit):Number
    {
        return (contentGroup) ?
            contentGroup.getHorizontalScrollPositionDelta(unit) : 0;     
    }
    
    /**
     *  @inheritDoc
     */
    public function getVerticalScrollPositionDelta(unit:ScrollUnit):Number
    {
        return (contentGroup) ? 
            contentGroup.getVerticalScrollPositionDelta(unit) : 0;     
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
                var sourceContent:Array = _placeHolderGroup.mxmlContent;
                
                contentGroup.mxmlContent = sourceContent ? sourceContent.slice() : null;
                
                // Temporary workaround because copying content from one Group to another throws RTE
                for (var i:int = _placeHolderGroup.numElements; i > 0; i--)
                {
                    _placeHolderGroup.removeElementAt(0);  
                }
                
            }
            else if (_mxmlContent != null)
            {
                contentGroup.mxmlContent = _mxmlContent;
            }
            
            // copy proxied values from contentGroupProperties (if set) to contentGroup
            
            var newContentGroupProperties:uint = 0;
            
            if (contentGroupProperties.clipContent !== undefined)
            {
                contentGroup.clipContent = contentGroupProperties.clipContent;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                                                                 CLIP_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties.layout !== undefined)
            {
                contentGroup.layout = contentGroupProperties.layout;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                                                               LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties.horizontalScrollPosition !== undefined)
            {
                contentGroup.horizontalScrollPosition = contentGroupProperties.horizontalScrollPosition;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                                                               HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties.verticalScrollPosition !== undefined)
            {
                contentGroup.verticalScrollPosition = contentGroupProperties.verticalScrollPosition;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                                                               VERTICAL_SCROLL_POSITION_PROPERTY_FLAG, true);
            }
            
            contentGroupProperties = newContentGroupProperties;
            
            contentGroup.addEventListener(
                ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
            contentGroup.addEventListener(
                ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
            contentGroup.addEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, contentGroup_propertyChangeHandler);
            
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
            contentGroup.removeEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, contentGroup_propertyChangeHandler);
            
            // copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
            
            var newContentGroupProperties:Object = {};
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, CLIP_CONTENT_PROPERTY_FLAG))
                newContentGroupProperties.clipContent = contentGroup.clipContent;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
                newContentGroupProperties.layout = contentGroup.layout;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG))
                newContentGroupProperties.horizontalScrollPosition = contentGroup.horizontalScrollPosition;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, VERTICAL_SCROLL_POSITION_PROPERTY_FLAG))
                newContentGroupProperties.verticalScrollPosition = contentGroup.verticalScrollPosition;
                
            contentGroupProperties = newContentGroupProperties;
            
            if (contentGroup.mxmlContent)
            {
                _placeHolderGroup = new Group();
                     
                _placeHolderGroup.mxmlContent = contentGroup.mxmlContent;
                
                _placeHolderGroup.addEventListener(
                    ItemExistenceChangedEvent.ITEM_ADD, contentGroup_itemAddedHandler);
                _placeHolderGroup.addEventListener(
                    ItemExistenceChangedEvent.ITEM_REMOVE, contentGroup_itemRemovedHandler);
            }
            
            // TODO: Need to force the contentGroup to removeChild on its content children
            // before the any other Group adds the content children
            contentGroup.mxmlContent = null;
            contentGroup.validateProperties();
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
        if (!mxmlContentCreated)
        {
            mxmlContentCreated = true;
            
            if (mxmlContentFactory)
            {
                // TODO (rfrishbe): If we have compiler support for deferred content
                // to do autotype conversion (do I create a single object, 
                // an array, or an IList in the function)
                var deferredContent:Object = mxmlContentFactory.getInstance();
                if (deferredContent is Array)
                    mxmlContent = deferredContent as Array;
                else
                    mxmlContent = [deferredContent];
                dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
            }
        }
    }
    
    /**
     *  @private
     */
    private function createContentIfNeeded():void
    {
        if (!mxmlContentCreated && creationPolicy != ContainerCreationPolicy.NONE)
            createDeferredContent();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    private function contentGroup_itemAddedHandler(event:ItemExistenceChangedEvent):void
    {
        // TODO (rfrishbe): need to check for IUIComponent 
        // as well if checking for IVisualElement?
        if (event.relatedObject is IVisualElement ||
            event.relatedObject is IUIComponent)
        {
            event.relatedObject.owner = this;
        }
        
        // Re-dispatch the event
        dispatchEvent(event);
    }
    
    private function contentGroup_itemRemovedHandler(event:ItemExistenceChangedEvent):void
    {
        // TODO (rfrishbe): need to check for IUIComponent 
        // as well if checking for IVisualElement?
        if (event.relatedObject is IVisualElement ||
            event.relatedObject is IUIComponent)
        {
            event.relatedObject.owner = null;
        }
        
        // Re-dispatch the event
        dispatchEvent(event);
    }
    
   /**
    * @private
    */
    private function contentGroup_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        // Re-dispatch the event if it's one other people are binding too
        switch (event.property)
        {
            case 'contentWidth':
            case 'contentHeight':
            case 'horizontalScrollPosition':
            case 'verticalScrollPosition':
            {
                dispatchEvent(event);
            }
        }
    }
}

}
