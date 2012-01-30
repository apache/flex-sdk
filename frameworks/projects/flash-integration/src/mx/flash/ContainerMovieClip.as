////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.flash
{

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.managers.ILayoutManagerClient;

use namespace mx_internal;

[DefaultProperty("content")]

/**
 *  Container components created in Adobe Flash Professional for use in Flex 
 *  are subclasses of the mx.flash.ContainerMovieClip class. 
 *  You can use a subclass of ContainerMovieClip 
 *  as a Flex container, it can hold children, 
 *  and it can respond to events, define view states and transitions, 
 *  and work with effects in the same way as can any Flex component.
 * 
 *  <p>A Flash container can only have a single Flex IUIComponent child. 
 *  However, this child can be a Flex container which allows 
 *  you to add additional children.</p>
 *
 *  <p>If your Flash container modifies the visual characteristics 
 *  of the Flex components contained in it, such as changing the <code>alpha</code> property, 
 *  you must embed the fonts used by the Flex components. 
 *  This is the same requirement that you have when using the Dissolve, Fade, 
 *  and Rotate effects with Flex components. </p>
 *
 *  <p>The following procedure describes the basic process for creating 
 *  a Flex component in Flash Professional:</p>
 *
 *  <ol>
 *    <li>Install the Adobe Flash Workflow Integration Kit.</li> 
 *    <li>Create symbols for your dynamic assets in the FLA file.</li>
 *    <li>Run Commands &gt; Make Flex Container to convert your symbol 
 *      to a subclass of the ContainerMovieClip class, to configure 
 *      the Flash Professional publishing settings for use with Flex, and 
 *      add a new symbol named FlexContentHolder to the Library. 
 *      This symbol defines the content area of the container in which 
 *      you can place child Flex components..</li> 
 *    <li>Publish your FLA file as a SWC file.</li> 
 *    <li>Reference the class name of your symbols in your Flex application 
 *      as you would any class.</li> 
 *    <li>Include the SWC file in your <code>library-path</code> when you compile 
 *      your Flex application.</li>
 *  </ol>
 *
 *  <p>For more information, see the documentation that ships with the 
 *  Flex/Flash Integration Kit at 
 *  <a href="http://www.adobe.com/go/flex3_cs3_swfkit">http://www.adobe.com/go/flex3_cs3_swfkit</a>.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public dynamic class ContainerMovieClip extends UIMovieClip implements IVisualElementContainer
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

   /**
    *  Constructor
    *  
    *  @langversion 3.0
    *  @playerversion Flash 9
    *  @playerversion AIR 1.1
    *  @productversion Flex 3
    */
    public function ContainerMovieClip()
    {
        super();
        
        addEventListener(Event.ADDED, addedHandler);
        addEventListener(Event.REMOVED, removedHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  bounds
    //----------------------------------

    /**
     *  @private
     *  Need to override here to set the scaleX and scaleY of the contentHolderObj.
     */
    override protected function get bounds():Rectangle
    {
        // not calling super.bounds but the functionality is copied here.
        
        // if we have a bounding box, use that.  With a bounding box, 
        // this bounds getter might get called frequently.
        if (boundingBoxName && boundingBoxName != "" 
            && boundingBoxName in this && this[boundingBoxName])
        {
            return this[boundingBoxName].getBounds(this);
        }
        
        // otherwise we need to change the scaleX and scaleY of the contentHolderObj so that we don't 
        // take the contentHolderObj into account at all
        if (contentHolderObj)
        {
            var oldScaleX:Number = contentHolderObj.$scaleX;
            var oldScaleY:Number = contentHolderObj.$scaleY;
            
            contentHolderObj.$scaleX = 0.001;
            contentHolderObj.$scaleY = 0.001;
        }
        
        var bounds:Rectangle = getBounds(this);
        
        if (contentHolderObj)
        {
            contentHolderObj.$scaleX = oldScaleX;
            contentHolderObj.$scaleY = oldScaleY;
        }
        
        return bounds;
    }
   
    //----------------------------------
    //  contentHolder
    //----------------------------------
    private var _contentHolder:*;
    
   /**
    *  @private
    */
    protected function get contentHolderObj():FlexContentHolder
    {
        if (_contentHolder === undefined)
        {
            for (var i:int = 0; i < numChildren; i++)
            {
                var child:FlexContentHolder = getChildAt(i) as FlexContentHolder;
                
                if (child)
                {
                    _contentHolder = child;
                    break;
                }
            }
        }
        
        return _contentHolder;
    }
        
    //----------------------------------
    //  content
    //----------------------------------
    
    private var _content:IUIComponent;
    
    /**
     *  The Flex content to display inside this container.
     *
     *  <p>Typically, to add a child to a container in ActionScript, 
     *  you use the <code>Container.addChild()</code> or <code>Container.addChildAt()</code> method. 
     *  However, to add a child to the <code>ContainerMovieClip.content</code> property 
     *  of a Flash container, you do not use the <code>addChild()</code> or <code>addChildAt()</code> method. 
     *  Instead, you assign the child directly to the content property.  </p>
     *
     *  @example
     *  The following example assigns a container to the <code>ContainerMovieClip.content</code> property.
     * <listing version="3.0">
     *  &lt;mx:Application xmlns:mx="http://www.adobe.com/2006/mxml"
     *     xmlns:myComps="~~"&gt;
     *     
     *     &lt;mx:Script&gt;
     *         &lt;![CDATA[
     *             import mx.containers.HBox;
     *             import mx.controls.Image;
     * 
     *             private function init():void {            
     *                 // Define the Image control.
     *                 var image1:Image = new Image();
     *                 image1.source = "../assets/logowithtext.jpg";
     *                 image1.percentWidth = 80;
     *                 image1.percentHeight = 80;
     * 
     *                 // Define the HBox container.
     *                 var hb1:HBox = new HBox();
     *                 hb1.percentWidth = 100;
     *                 hb1.percentHeight = 100;
     *                 hb1.setStyle('borderStyle', 'solid');
     *                 hb1.addChild(image1);
     * 
     *                 // Assign the HBox container to the 
     *                 // ContainerMovieClip.content property..
     *                 pFrame.content = hb1;
     *             }
     *         ]]&gt;
     *     &lt;/mx:Script&gt;    
     * 
     *     &lt;myComps:MyPictureFrameContainer id="pFrame" 
     *         initialize="init();"/&gt;
     * &lt;/mx:Application&gt;
     * </listing>
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get content():IUIComponent
    {
        return contentHolderObj ? contentHolderObj.content : _content;
    }
        
   /**
    *  @private
    */
    public function set content(value:IUIComponent):void
    {
        if (contentHolderObj)
        {
            contentHolderObj.content = value;
        }
        
        _content = value;
        
        invalidateParentSizeAndDisplayList();
    }
    
    //----------------------------------
    //  scaleContentWhenResized
    //----------------------------------
    
    private var _scaleContentWhenResized:Boolean = false;
    
    [Inspectable(category="General", enumeration="false,true", defaultValue="false")]
    /**
     *  Whether the scale of the container due to sizing 
     *  affects the scale of the flex content.
     * 
     *  <p>When Flash components are resized, they scale up or down to their new size.
     *  However, this means their children are also scaled up or down.  By setting this 
     *  flag to false, the children are inversely scaled when the container is resized.</p>
     * 
     *  <p>Note: When the container is scaled direclty (through scaleX or scaleY), the 
     *  content will also be scaled accordingly.  This only affects scaling of the 
     *  container due to sizing.</p>
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleContentWhenResized():Boolean
    {
        return _scaleContentWhenResized;
    }
        
   /**
    *  @private
    */
    public function set scaleContentWhenResized(value:Boolean):void
    {
        _scaleContentWhenResized = value;
        
        if (initialized)
            sizeContentHolder();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
   /**
    *  @private
    */
    override public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        super.setActualSize(newWidth, newHeight);
        
        sizeContentHolder();
    }
        
    /**
     *  @private
     * 
     *  Sizes the contentHolder and sets the scale of the contentHolder
     *  according to applyInverseScaleToContent.
     */
    protected function sizeContentHolder():void
    {
        if (contentHolderObj)
        {
            // width and height are what we actually want our content
            // to fill up, but it doesn't take in to account our secretScale.
            if (!scaleContentWhenResized)
            {
                // apply inverse of the scale
                contentHolderObj.scaleX = 1/scaleXDueToSizing;
                contentHolderObj.scaleY = 1/scaleYDueToSizing;
            }
            else
            {
                // apply the scale to the width/height
                contentHolderObj.scaleX = 1;
                contentHolderObj.scaleY = 1;
            }
            
            contentHolderObj.sizeFlexContent();
        }
    }

   /**
    *  @private
    */
    override protected function findFocusCandidates(obj:DisplayObjectContainer):void
    {
        // No-op. Container movie clips use Flex focus management only.
    }
    
   /**
    *  @private
    */
    override protected function focusInHandler(event:FocusEvent):void
    {
        // No-op. Flex focus management does all the work.
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods: IVisualElementContainer
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns 1 if there is a viewport, 0 otherwise.
     * 
     *  @return The number of visual elements in this visual container
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get numElements():int
    {
        return content ? 1 : 0;
    }
    
    /**
     *  Returns the viewport if there is a viewport and the 
     *  index passed in is 0.  Otherwise, it throws a RangeError.
     *
     *  @param index The index of the element to retrieve.
     *
     *  @return The element at the specified index.
     * 
     *  @throws RangeError If the index position does not exist in the child list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function getElementAt(index:int):IVisualElement
    {
        if (content && index == 0)
            return content as IVisualElement;
        else
            throw new RangeError("Index " + index + " is out of range.");
    }
    
    /**
     *  Returns the 0 if the element passed in is the viewport.  
     *  Otherwise, it throws an ArgumentError.
     *
     *  @param element The element to identify.
     *
     *  @return The index position of the element to identify.
     * 
     *  @throws ArgumentError If the element is not a child of this object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function getElementIndex(element:IVisualElement):int
    {
        if (element != null && element == content)
            return 0;
        else
            throw ArgumentError(element + " is not found in this container.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function addElementAt(element:IVisualElement, index:int):IVisualElement
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElement(element:IVisualElement):IVisualElement
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeElementAt(index:int):IVisualElement
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function removeAllElements():void
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function setElementIndex(element:IVisualElement, index:int):void
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElements(element1:IVisualElement, element2:IVisualElement):void
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    /**
     *  @inheritDoc
     * 
     *  <p>This operation is not supported in ContainerMovieClip.  ContainerMovieClip 
     *  only has one child.  Use the <code>content</code> property to manipulate 
     *  it.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function swapElementsAt(index1:int, index2:int):void
    {
        throw new ArgumentError("This operation is not supported.");
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
        
    /**
     *  Any time a display object gets added, let's see if this is a child 
     *  that belongs to use and needs to be initialized.  Also if it is 
     *  the contentHolder, let's stuff the content down into it.
     * 
     *  <p>We only need this method if the child gets added after 
     *  we've already been initialized.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    protected function addedHandler(event:Event):void 
    {
        // if we haven't initialized, we'll handle 
        // that stuff in there
        if (!initialized)
            return;
        
        // if it's not a direct descendent, don't 
        // worry about it
        if (event.target.parent != this)
            return;
        
        // if it's the FlexContentHolder, let's 
        // treat it as such.
        if (event.target is FlexContentHolder && !_contentHolder)
        {
            _contentHolder = event.target;
            if (_content)
                content = _content;
        }
        
        // Call initialize() on any IUIComponent children
        var child:IUIComponent = event.target as IUIComponent;
        
        if (child)
            child.initialize();
    }
    
    /**
     *  Any time a display object gets removed, let's see if this child
     *  is the contentHolder.  If it is, let's null out our reference to 
     *  _contentHolder.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    protected function removedHandler(event:Event):void 
    {
        if (event.target == _contentHolder)
        {
            _contentHolder = null;
        }
    }
}
}
