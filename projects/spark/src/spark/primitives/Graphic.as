////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flex.graphics
{

import mx.events.PropertyChangeEvent;
import flex.core.Group;

//--------------------------------------
//  Events
//--------------------------------------

//--------------------------------------
//  Styles
//--------------------------------------

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusEnabled", kind="property")]
[Exclude(name="focusPane", kind="property")]
[Exclude(name="mouseFocusEnabled", kind="property")]
[Exclude(name="tabEnabled", kind="property")]
[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusSkin", kind="style")]
[Exclude(name="focusThickness", kind="style")]
[Exclude(name="setFocus", kind="method")]

//--------------------------------------
//  Other metadata
//--------------------------------------

// [IconFile("Graphic.png")]

/**
 *  The Graphic control displays a set of graphic drawing commands.
 *
 *  <p>The Graphic class is the root tag for all graphic elements. You add a series of 
 *  element tags such as &lt;mx:Rect&gt;, &lt;mx:Path&gt;, and &lt;mx:Ellipse&gt; to the Graphic's
 *  elements Array to define the contents of the graphic.</p>
 *
 *  <p>Graphic controls do not have backgrounds or borders
 *  and cannot take focus.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Graphic&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:Graphic
 *    <b>Properties</b>
 *    version
 *    viewHeight
 *    viewWidth
 *    &nbsp;
 *  /&gt;
 *  </pre>
 *
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
     */
    public function Graphic()
    {
        super();
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
	
	public function get viewHeight():Number
	{
		return _viewHeight;
	}
	
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
	
	public function get viewWidth():Number
	{
		return _viewWidth;
	}
	
	public function set viewWidth(value:Number):void
	{
		if (value != _viewWidth)
		{
			_viewWidth = value;
			invalidateSize();
		}
		
	}
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @inheritDoc
	 */
	override protected function measure():void
	{
		super.measure();
		
		if (!isNaN(viewWidth))
			measuredMinWidth = measuredWidth = viewWidth;
		if (!isNaN(viewHeight))
			measuredMinHeight = measuredHeight = viewHeight;	
	}

    /** 
     *  @private
     *  Dispatch a propertyChange event.
     */
    private function dispatchPropertyChangeEvent(prop:String, oldValue:*, value:*):void
    {
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop, oldValue, value));
    }
}
}