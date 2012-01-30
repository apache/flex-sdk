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

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.geom.Rectangle;

import mx.core.IUIComponent;
import mx.core.mx_internal;

[DefaultProperty("content")]

/**
 *  Container components created in Adobe Flash CS3 Professional for use in Flex 
 *  are subclasses of the mx.flash.ContainerMovieClip class. 
 *  You can use a subclass of ContainerMovieClip 
 *  as a Flex container, it can hold children, 
 *  and it can respond to events, define view states and transitions, 
 *  and work with effects in the same way as can any Flex component.
 * 
 *  <p>A Flash container can only have a single Flex child. 
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
 *  a Flex component in Flash CS3:</p>
 *
 *  <ol>
 *    <li>Install the Adobe Flash Workflow Integration Kit.</li> 
 *    <li>Create symbols for your dynamic assets in the FLA file.</li>
 *    <li>Run Commands &gt; Make Flex Container to convert your symbol 
 *      to a subclass of the ContainerMovieClip class, to configure 
 *      the Flash CS3 publishing settings for use with Flex, and 
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
 */
public dynamic class ContainerMovieClip extends UIMovieClip
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

   /**
    *  Constructor
    */
    public function ContainerMovieClip()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
   
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
        else
        {
            _content = value;
        }
    }
    
    //----------------------------------
    //  fillContentToSize
    //----------------------------------
    
    private var _fillContentToSize:Boolean = false;
    
    /**
     *  Whether the flex content is sized to be the same size as the flash 
     *  container.
     * 
     *  <p>There is no layout system for the Flash container.  By default the
     *  flex content is sized normally.  However, if you set this flag to true, 
     *  the flex content will be sized to 100% of the size of the flash
     *  container.</p>
     *
     *  @default false
     */
    public function get fillContentToSize():Boolean
    {
        return _fillContentToSize;
    }
        
   /**
    *  @private
    */
    public function set fillContentToSize(value:Boolean):void
    {
        _fillContentToSize = value;
        
        sizeContentHolder();
    }
    
    //----------------------------------
    //  scaleContent
    //----------------------------------
    
    private var _scaleContent:Boolean = false;
    
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
     */
    public function get scaleContent():Boolean
    {
        return _scaleContent;
    }
        
   /**
    *  @private
    */
    public function set scaleContent(value:Boolean):void
    {
        _scaleContent = value;
        
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
            // secretScale is the amount we scaled by to change the width and height
            var secretScaleX:Number = mx_internal::$scaleX/scaleX;
            var secretScaleY:Number = mx_internal::$scaleY/scaleY;
            
            // width and height are what we actually want our content
            // to fill up, but it doesn't take in to account our secretScale.
            if (!scaleContent)
            {
                // apply inverse of the scale and set the width/height normally
                contentHolderObj.scaleX = 1/secretScaleX;
                contentHolderObj.scaleY = 1/secretScaleY;
                
                contentHolderObj.setActualSize(width, height);
            }
            else
            {
                // apply the scale to the width/height
                contentHolderObj.scaleX = 1;
                contentHolderObj.scaleY = 1;
                
                contentHolderObj.setActualSize(width / secretScaleX, 
                                               height / secretScaleY);
            }
        }
    }
    
    override protected function get bounds():Rectangle
    {
        if (!trackSizeChanges)
            return super.bounds;
        
        // we don't want our bounds to include the bounds of our child
        // otherwise we can get into a scenario where we're telling our
        // child to be width, height from setActualSize above and they are 
        // actually a bit bigger due to drawing outside the lines.
        // then when we get bounds next time, we're also a tad bigger, 
        // and this goes on and on in this fashion until we're infinitely large
        var contentHolderIndex:int = -1;
        var myContentHolder:FlexContentHolder;
        
        if (contentHolderObj && contentHolderObj.parent == this)
        {
            myContentHolder = contentHolderObj;
            contentHolderIndex = getChildIndex(contentHolderObj);
            removeChild(contentHolderObj);
        }
        
       var myBounds:Rectangle = super.bounds;
        
        if (myContentHolder)
        {
            addChildAt(myContentHolder, contentHolderIndex);
        }
        
        return myBounds;
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
}
}
