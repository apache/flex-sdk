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
import flash.display.MovieClip;
import flash.events.FocusEvent;

import mx.core.IUIComponent;

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

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

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
