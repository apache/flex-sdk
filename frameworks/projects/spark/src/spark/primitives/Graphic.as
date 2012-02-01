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

package spark.primitives
{

import mx.events.PropertyChangeEvent;

import spark.components.Group;
import spark.components.ResizeMode;
import spark.layouts.BasicLayout;
import spark.layouts.supportClasses.LayoutBase;

//--------------------------------------
//  Events
//--------------------------------------

//--------------------------------------
//  Styles
//--------------------------------------

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="setFocus", kind="method")]

[Exclude(name="focusEnabled", kind="property")]
[Exclude(name="focusPane", kind="property")]
[Exclude(name="layout", kind="property")]
[Exclude(name="mouseFocusEnabled", kind="property")]
[Exclude(name="tabEnabled", kind="property")]

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusSkin", kind="style")]
[Exclude(name="focusThickness", kind="style")]

//--------------------------------------
//  Other metadata
//--------------------------------------

// [IconFile("Graphic.png")]

/**
 *  The Graphic control displays a set of graphic drawing commands.
 *
 *  <p>The Graphic class is the root tag for all graphic elements. 
 *  This tag is the root for any FXG document. It cannot appear anywhere else in an FXG 
 *  document.</p>
 *  
 *  <p>You add a series of 
 *  element tags such as &lt;Rect&gt;, &lt;Path&gt;, and &lt;Ellipse&gt; to the Graphic's
 *  elements Array to define the contents of the graphic.</p>
 *
 *  <p>Graphic controls do not have backgrounds or borders
 *  and cannot take focus.</p>
 *  
 *  <p>When placed in a container, a Graphic is positioned by the rules of the container. 
 *  However, the graphics in the Graphic control are always sized and positioned relative
 *  to the upper-left corner of the Graphics control.</p>
 *  
 *  <p>The Graphic element can optionally contain a &lt;Group&gt; element.</p>
 *  
 *  @see mx.graphics.Group
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:Graphic&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Graphic
 *    <b>Properties</b>
 *    version
 *    viewHeight
 *    viewWidth
 *    &nbsp;
 *  /&gt;
 *  </pre>
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Graphic extends Group 
{
    include "../core/Version.as";

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
    public function Graphic()
    {
        super();
        super.layout = new BasicLayout();

		// The default resize mode for a Graphic is scale
		resizeMode = ResizeMode.SCALE;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------   
    /**
     *    Specifies the FXG version this Graphic tag is targeting.  
     *
     *    @default 1.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var version:Number = 1.0;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  viewHeight
    //----------------------------------

    private var _viewHeight:Number;
    
    /**
     *  Defines the vertical space that the graphic uses in the layout. When you set this value, the content is not scaled. 
     *  Whereas, if you specify the value of the <code>height</code> property, the content is scaled. 
     *  
     *  <p>There are two cases where this can be useful:<br/>
     *  1) Specify a <code>viewHeight</code> larger than the natural size of the content. You might do this so that the graphic takes 
     *  up more space than its visual size. <br/><br/>
     *  2) Specify a <code>viewHeight</code> that is smaller than the natural size of the content. You might do this if your graphic has extra
     *  chrome or a border that extends past the edges of the graphic. In this scenario, be sure to disable clipping in your layout.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get viewHeight():Number
    {
        return _viewHeight;
    }
    
    /**
     *  @private 
     */
    public function set viewHeight(value:Number):void
    {
        if (value != _viewHeight)
        {
            _viewHeight = value;
            invalidateSize();
        }
    }
    
    //----------------------------------
    //  viewWidth
    //----------------------------------

    private var _viewWidth:Number;
    
    /**
     *  Defines the horizontal space that the graphic uses in the layout. When you set this value, the content is not scaled. 
     *  Whereas, if you specify the value of the <code>width</code> property, the content is scaled. 
     *  
     *  <p>There are two cases where this can be useful:<br/>
     *  1) Specify a <code>viewWidth</code> larger than the natural size of the content. You might do this so that the graphic takes 
     *  up more space than its visual size. <br/><br/>
     *  2) Specify a <code>viewWidth</code> that is smaller than the natural size of the content. You might do this if your graphic has extra
     *  chrome or a border that extends past the edges of the graphic. In this scenario, be sure to disable clipping in your layout.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get viewWidth():Number
    {
        return _viewWidth;
    }
    
    /**
     *  @private 
     */
    public function set viewWidth(value:Number):void
    {
        if (value != _viewWidth)
        {
            _viewWidth = value;
            invalidateSize();
        }
        
    }
    
    //----------------------------------
    //  layout
    //----------------------------------    
    
    /**
     *  @private
     */
    override public function set layout(value:LayoutBase):void
    {
        throw(new Error(resourceManager.getString("components", "layoutReadOnly")));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
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
    override protected function measure():void
    {
        super.measure();
        
        if (!isNaN(viewWidth))
            measuredMinWidth = measuredWidth = viewWidth;
        if (!isNaN(viewHeight))
            measuredMinHeight = measuredHeight = viewHeight;    
    }
}
}