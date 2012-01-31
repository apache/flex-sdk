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

import mx.collections.IList;
import spark.components.Group;
import mx.core.mx_internal;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.SkinnableContainerBase;
import mx.core.ContainerCreationPolicy;
import spark.core.IDeferredContentOwner;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.IUIComponent;
import spark.core.IViewport;
import mx.events.FlexEvent;
import spark.events.ElementExistenceEvent;
import mx.events.PropertyChangeEvent;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;
import mx.managers.IFocusManagerContainer;
import mx.utils.BitFlagUtil;

/**
 *  Dispatched after the content for this component has been created. With deferred 
 *  instantiation, the content for a component may be created long after the 
 *  component is created.
 *
 *  @eventType mx.events.FlexEvent.CONTENT_CREATION_COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="contentCreationComplete", type="mx.events.FlexEvent")]

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

include "../styles/metadata/AdvancedTextLayoutFormatStyles.as"
include "../styles/metadata/BasicTextLayoutFormatStyles.as"
include "../styles/metadata/SelectionFormatTextStyles.as"

/**
 *  @copy spark.components.supportClasses.GroupBase#style:alternatingItemColors
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:contentBackgroundColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="contentBackgroundColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:focusColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 * @copy spark.components.supportClasses.GroupBase#style:rollOverColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]

/**
 *  @copy spark.components.supportClasses.GroupBase#style:symbolColor
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]


[IconFile("SkinnableContainer.png")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[DefaultProperty("mxmlContentFactory")]

/**
 *  The SkinnableContainer class is the base class for skinnable containers that have 
 *  visual content.
 *  The SkinnableContainer container take as children any components that implement 
 *  the IVisualElement interface. 
 *  All Spark and Halo components implement the IVisualElement interface, as does
 *  the GraphicElement class. 
 *  That means the container can use the graphics classes, such as Rect and Ellipse, as children.
 *
 *  <p>To improve performance and minimize application size, 
 *  you can use the Group container. The Group container cannot be skinned.</p>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;SkinnableContainer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;SkinnableContainer
 *    <strong>Properties</strong>
 *    autoLayout="true"
 *    clipAndEnableScrolling="false"
 *    creationPolicy="auto"
 *    horizontalScrollPosition="null"
 *    layout="VerticalLayout"
 *    verticalScrollPosition="null"
 *  
 *    <strong>Events</strong>
 *    elementAdd="<i>No default</i>"
 *    elementRemove="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see SkinnableDataContainer
 *  @see Group
 *  @see spark.skins.default.SkinnableContainerSkin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SkinnableContainer extends SkinnableContainerBase 
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
    private static const CLIP_AND_ENABLE_SCROLLING_PROPERTY_FLAG:uint = 1 << 0;
    
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
    
    /**
     *  @private
     */
    private static const AUTO_LAYOUT_PROPERTY_FLAG:uint = 1 << 4;

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
    public function SkinnableContainer()
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var contentGroup:Group;
    
    /**
     *  @private
     *  Several properties are proxied to contentGroup.  However, when contentGroup
     *  is not around, we need to store values set on SkinnableContainer.  This object 
     *  stores those values.  If contentGroup is around, the values are stored 
     *  on the contentGroup directly.  However, we need to know what values 
     *  have been set by the developer on the SkinnableContainer (versus set on 
     *  the contentGroup or defaults of the contentGroup) as those are values 
     *  we want to carry around if the contentGroup changes (via a new skin). 
     *  In order to store this info effeciently, contentGroupProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this SkinnableContainer.  When the 
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
                {
                    _placeHolderGroup.mxmlContent = _mxmlContent;
                    _mxmlContent = null;
                }
                
                _placeHolderGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
                _placeHolderGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
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
     *
     *  @default auto
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    //  autoLayout
    //----------------------------------

    [Inspectable(defaultValue="true")]

    /**
     *  @copy spark.components.supportClasses.GroupBase#autoLayout
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoLayout():Boolean
    {
        if (contentGroup)
            return contentGroup.autoLayout;
        else
        {
            // want the default to be true
            var v:* = contentGroupProperties.autoLayout;
            return (v === undefined) ? true : v;
        }
    }

    /**
     *  @private
     */
    public function set autoLayout(value:Boolean):void
    {
        if (contentGroup)
        {
            contentGroup.autoLayout = value;
            contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
                                                        AUTO_LAYOUT_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties.autoLayout = value;
    }
    
    //----------------------------------
    //  clipAndEnableScrolling
    //----------------------------------
    
    /**
     *  @inheritDoc
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get clipAndEnableScrolling():Boolean 
    {
        return (contentGroup) 
            ? contentGroup.clipAndEnableScrolling 
            : contentGroupProperties.clipAndEnableScrolling;
    }

    /**
     *  @private
     */
    public function set clipAndEnableScrolling(value:Boolean):void 
    {       
        if (contentGroup)
        {
            contentGroup.clipAndEnableScrolling = value;
            contentGroupProperties = BitFlagUtil.update(contentGroupProperties as uint, 
                                                        CLIP_AND_ENABLE_SCROLLING_PROPERTY_FLAG, true);
        }
        else
            contentGroupProperties.clipAndEnableScrolling = value;
    }
    
    //----------------------------------
    //  contentWidth
    //---------------------------------- 
    
    [Bindable("propertyChange")]
    [Inspectable(category="General")]    

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  @copy spark.components.supportClasses.GroupBase#layout
     *
     *  @default VerticalLayout
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
    
    [ArrayElementType("mx.core.IVisualElement")]
    
    /**
     *  @copy spark.components.Group#mxmlContent
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function set mxmlContent(value:Array):void
    {
        if (contentGroup)
            contentGroup.mxmlContent = value;
        else if (_placeHolderGroup)
            _placeHolderGroup.mxmlContent = value;
        else
            _mxmlContent = value;
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
    
    [InstanceType("Array")]
    [ArrayElementType("mx.core.IVisualElement")]

    /**
     *  A factory object that creates the initial value for the
     *  content property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get numElements():int
    {
        return mx_internal::currentContentGroup.numElements;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getElementAt(index:int):IVisualElement
    {
        return mx_internal::currentContentGroup.getElementAt(index);
    }
    
        
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getElementIndex(element:IVisualElement):int
    {
        return mx_internal::currentContentGroup.getElementIndex(element);
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
        return mx_internal::currentContentGroup.addElement(element);
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
        return mx_internal::currentContentGroup.addElementAt(element, index);
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
        return mx_internal::currentContentGroup.removeElement(element);
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
        return mx_internal::currentContentGroup.removeElementAt(index);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeAllElements():void
    {
        mx_internal::currentContentGroup.removeAllElements();
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        mx_internal::currentContentGroup.swapElements(element1, element2);
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
        mx_internal::currentContentGroup.swapElementsAt(index1, index2);
    }
    
    //----------------------------------
    //  getHorizontal,VerticalScrollPositionDelta
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getHorizontalScrollPositionDelta(scrollUnit:uint):Number
    {
        return (contentGroup) ?
            contentGroup.getHorizontalScrollPositionDelta(scrollUnit) : 0;     
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function getVerticalScrollPositionDelta(scrollUnit:uint):Number
    {
        return (contentGroup) ? 
            contentGroup.getVerticalScrollPositionDelta(scrollUnit) : 0;     
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Create content children, if the <code>creationPolicy</code> property 
     *  is not equal to <code>none</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == contentGroup)
        {
            if (_placeHolderGroup != null)
            {
                var sourceContent:Array = _placeHolderGroup.mxmlContent;
                
                contentGroup.mxmlContent = sourceContent ? sourceContent.slice() : null;
                
                // TODO (rfrishbe): investigate why we need this, especially if these elements shouldn't 
                // be added to the place holder Group's display list
                
                // TODO (rfrishbe): Also look at why we need a defensive copy for mxmlContent in Group, 
                // especially if we make it mx_internal.
                
                // Temporary workaround because copying content from one Group to another throws RTE
                for (var i:int = _placeHolderGroup.numElements; i > 0; i--)
                {
                    _placeHolderGroup.removeElementAt(0);  
                }
                
            }
            else if (_mxmlContent != null)
            {
                contentGroup.mxmlContent = _mxmlContent;
                _mxmlContent = null;
            }
            
            // copy proxied values from contentGroupProperties (if set) to contentGroup
            
            var newContentGroupProperties:uint = 0;
            
            if (contentGroupProperties.autoLayout !== undefined)
            {
                contentGroup.autoLayout = contentGroupProperties.autoLayout;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                                                               AUTO_LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (contentGroupProperties.clipAndEnableScrolling !== undefined)
            {
                contentGroup.clipAndEnableScrolling = contentGroupProperties.clipAndEnableScrolling;
                newContentGroupProperties = BitFlagUtil.update(newContentGroupProperties, 
                                                               CLIP_AND_ENABLE_SCROLLING_PROPERTY_FLAG, true);
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
                ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
            contentGroup.addEventListener(
                ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                // the only reason we have this listener is to re-dispatch events.  So only add it here
                // if someone's listening on us.
                contentGroup.addEventListener(
                    PropertyChangeEvent.PROPERTY_CHANGE, contentGroup_propertyChangeHandler);
            }
            
            if (_placeHolderGroup)
            {
                _placeHolderGroup.removeEventListener(
                    ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
                _placeHolderGroup.removeEventListener(
                    ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
                
                _placeHolderGroup = null;
            }
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == contentGroup)
        {
            contentGroup.removeEventListener(
                ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
            contentGroup.removeEventListener(
                ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            contentGroup.removeEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, contentGroup_propertyChangeHandler);
            
            // copy proxied values from contentGroup (if explicitely set) to contentGroupProperties
            
            var newContentGroupProperties:Object = {};
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, AUTO_LAYOUT_PROPERTY_FLAG))
                newContentGroupProperties.autoLayout = contentGroup.autoLayout;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, CLIP_AND_ENABLE_SCROLLING_PROPERTY_FLAG))
                newContentGroupProperties.clipAndEnableScrolling = contentGroup.clipAndEnableScrolling;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, LAYOUT_PROPERTY_FLAG))
                newContentGroupProperties.layout = contentGroup.layout;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, HORIZONTAL_SCROLL_POSITION_PROPERTY_FLAG))
                newContentGroupProperties.horizontalScrollPosition = contentGroup.horizontalScrollPosition;
            
            if (BitFlagUtil.isSet(contentGroupProperties as uint, VERTICAL_SCROLL_POSITION_PROPERTY_FLAG))
                newContentGroupProperties.verticalScrollPosition = contentGroup.verticalScrollPosition;
                
            contentGroupProperties = newContentGroupProperties;
            
            var myMxmlContent:Array = contentGroup.mxmlContent;
            
            if (myMxmlContent)
            {
                _placeHolderGroup = new Group();
                     
                _placeHolderGroup.mxmlContent = myMxmlContent;
                
                _placeHolderGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
                _placeHolderGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            }
            
            contentGroup.mxmlContent = null;
            contentGroup.layout = null;
        }
    }
    
    /**
     *  @private
     * 
     *  This method is overridden so we can figure out when someone starts listening
     *  for property change events.  If no one's listening for them, then we don't 
     *  listen for them on our contentGroup.
     */
    override public function addEventListener(
        type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) : void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        
        // if it's a different type of event or the contentGroup doesn't
        // exist, don't worry about it.  When the contentGroup, 
        // gets created up, we'll check to see whether we need to add this 
        // event listener to the contentGroup.
        if (type == PropertyChangeEvent.PROPERTY_CHANGE && contentGroup)
        {
            contentGroup.addEventListener(
                PropertyChangeEvent.PROPERTY_CHANGE, contentGroup_propertyChangeHandler);
        }
    }
    
    /**
     *  @private
     * 
     *  This method is overridden so we can figure out when someone stops listening
     *  for property change events.  If no one's listening for them, then we don't 
     *  listen for them on our contentGroup.
     */
    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false) : void
    {
        super.removeEventListener(type, listener, useCapture);
        
        // if no one's listening to us for this event any more, let's 
        // remove our underlying event listener from the contentGroup.
        if (type == PropertyChangeEvent.PROPERTY_CHANGE && contentGroup)
        {
            if (!hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                contentGroup.removeEventListener(
                    PropertyChangeEvent.PROPERTY_CHANGE, contentGroup_propertyChangeHandler);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  IDeferredContentOwner methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Create the content for this component. 
     *  When the <code>creationPolicy</code> property is <code>auto</code> or
     *  <code>all</code>, this function is called automatically by the Flex framework.
     *  When <code>creationPolicy</code> is <code>none</code>, you call this method to initialize
     *  the content.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function createDeferredContent():void
    {
        if (!mxmlContentCreated)
        {
            mxmlContentCreated = true;
            
            if (_mxmlContentFactory)
            {
                // TODO (rfrishbe): If we have compiler support for deferred content
                // to do autotype conversion (do I create a single object, 
                // an array, or an IList in the function)
                var deferredContent:Object = _mxmlContentFactory.getInstance();
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
    
    private function contentGroup_elementAddedHandler(event:ElementExistenceEvent):void
    {
        event.element.owner = this
        
        // Re-dispatch the event
        dispatchEvent(event);
    }
    
    private function contentGroup_elementRemovedHandler(event:ElementExistenceEvent):void
    {
        event.element.owner = null;
        
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
