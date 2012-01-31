////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls
{

import flash.geom.Matrix;
import flash.ui.Keyboard;

import mx.controls.scrollClasses.ScrollBar;
import mx.controls.scrollClasses.ScrollBarDirection;
import mx.core.LayoutDirection;
import mx.core.mx_internal;
import mx.events.ScrollEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the ScrollBar control scrolls through
 *  user initiated action or programmatically. 
 *
 *  @eventType mx.events.ScrollEvent.SCROLL
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="scroll", type="mx.events.ScrollEvent")]

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Number of milliseconds to wait after the first <code>buttonDown</code>
 *  event before repeating <code>buttonDown</code> events at the
 *  <code>repeatInterval</code>.
 *  The default value is 500.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="repeatDelay", type="Number", format="Time", inherit="no")]

/**
 *  Number of milliseconds between <code>buttonDown</code> events
 *  if the user presses and holds the mouse on a button.
 *  The default value is 35.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="repeatInterval", type="Number", format="Time", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="direction", kind="property")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultBindingProperty(source="scrollPosition", destination="scrollPosition")]

[DefaultTriggerEvent("scroll")]

[IconFile("HScrollBar.png")]

[Alternative(replacement="spark.components.HScrollBar", since="4.0")]

/**
 *  The HScrollBar (horizontal ScrollBar) control lets you control
 *  the portion of data that is displayed when there is too much data
 *  to fit in a display area.
 * 
 *  This control extends the base ScrollBar control. 
 *  
 *  <p>Although you can use the HScrollBar control as a stand-alone control,
 *  you usually combine it as part of another group of components to
 *  provide scrolling functionality.</p>
 * 
 *  <p>A ScrollBar control consist of four parts: two arrow buttons,
 *  a track, and a thumb. 
 *  The position of the thumb and the display of the buttons
 *  depend on the current state of the control.
 *  The ScrollBar control uses four parameters to calculate its 
 *  display state:</p>
 *
 *  <ul>
 *    <li>Minimum range value.</li>
 *    <li>Maximum range value.</li>
 *    <li>Current position - must be within the
 *    minimum and maximum range values.</li>
 *    <li>Viewport size - represents the number of items
 *    in the range that you can display at one time. The
 *    number of items must be less than or equal to the 
 *    range, where the range is the set of values between
 *    the minimum range value and the maximum range value.</li>
 *  </ul>
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;mx:HScrollBar&gt;</code> tag inherits all of the
 *  tag attributes of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:HScrollBar
 *    <strong>Styles</strong>
 *    repeatDelay="500"
 *    repeatInterval="35"
 * 
 *    <strong>Events</strong>
 *    scroll="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @includeExample examples/HScrollBarExample.mxml
 *
 *  @see mx.controls.scrollClasses.ScrollBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class HScrollBar extends ScrollBar
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function HScrollBar()
    {
        super();

        // ScrollBar variables.
        super.direction = ScrollBarDirection.HORIZONTAL;

        // Scroll bar does some tricky things based on its orientation.
        // Most components won't need to do this.
        scaleX = -1.0;
        rotation = -90;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  direction
    //----------------------------------
    
    [Inspectable(environment="none")]   

    /**
     *  @private
     *  Don't allow user to change the direction.
     */
    override public function set direction(value:String):void
    {
    }

    //----------------------------------
    //  minWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function get minWidth():Number
    {
        return _minHeight;
    }

    //----------------------------------
    //  minHeight
    //----------------------------------

    /**
     *  @private
     */
    override public function get minHeight():Number
    {
        return _minWidth;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  virtualHeight
    //----------------------------------

    /**
     *  @private
     *  For internal use only.
     */
    override mx_internal function get virtualHeight():Number
    {
        return unscaledWidth;
    }
    
    //----------------------------------
    //  virtualWidth
    //----------------------------------

    /**
     *  @private
     *  For internal use only.
     */
    override mx_internal function get virtualWidth():Number
    {
        return unscaledHeight;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();

        measuredWidth = _minHeight;
        measuredHeight = _minWidth;
    }
	
	/**
	 *  @private
	 * 	Since HScrollbar cheats with its own rotation,
	 *	rotate the other way here so that the layout
	 *	bounds calculations are correct in the most
	 *	common cases - SDK-22012.
	 */
	override protected function nonDeltaLayoutMatrix():Matrix
	{
		var m:Matrix = new Matrix(0, 1, 1, 0);
		var m1:Matrix = super.nonDeltaLayoutMatrix();
		if (m1)
			m.concat(m1);
		return m;
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: ScrollBar
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  map keys to scroll events
     */
    override mx_internal function isScrollBarKey(key:uint):Boolean
    {
        var direction:int;
        
        if (key == Keyboard.LEFT)
        {
            direction = LayoutDirection.LTR ? -1 : 1;
            lineScroll(direction);
            return true;
        }
        
        else if (key == Keyboard.RIGHT)
        {
            direction = LayoutDirection.LTR ? 1 : -1;
            lineScroll(direction);
            return true;
        }
        
        return super.isScrollBarKey(key);
    }
}

}
