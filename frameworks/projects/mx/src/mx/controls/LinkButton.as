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

import flash.text.TextLineMetrics;
import mx.core.mx_internal;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Corner radius of the highlighted rectangle around a LinkButton.
 * 
 *  @default 4
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]

/**
 *  Color of a LinkButton as a user moves the mouse pointer over it.
 * 
 *  @default 0xEEFEE6
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  Background color of a LinkButton as a user presses it.
 * 
 *  @default 0xB7F39B
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]

/**
 *  Text color of a LinkButton as a user moves the mouse pointer over it.
 * 
 *  @default 0x2B333C
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="textRollOverColor", type="uint", format="Color", inherit="yes")]

/**
 *  Text color of a LinkButton as a user presses it.
 * 
 *  @default 0x2B333C
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="textSelectedColor", type="uint", format="Color", inherit="yes")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="emphasized", kind="property")]

[Exclude(name="baseColor", kind="style")]
[Exclude(name="borderColor", kind="style")]
[Exclude(name="fillAlphas", kind="style")]
[Exclude(name="fillColors", kind="style")]
[Exclude(name="highlightAlphas", kind="style")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[AccessibilityClass(implementation="mx.accessibility.LinkButtonAccImpl")]

[IconFile("LinkButton.png")]

/**
 *  The LinkButton control is a borderless Button control
 *  whose contents are highlighted when a user moves the mouse over it.
 *  These traits are often exhibited by HTML links
 *  contained within a browser page.
 *  In order for the LinkButton control to perform some action,
 *  you must specify a <code>click</code> event handler,  
 *  as you do with a Button control.
 *
 *  <p>The LinkButton control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>Width and height large enough for the text</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>0 pixels</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>Undefined</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:LinkButton&gt;</code> tag inherits all of the tag attributes 
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:LinkButton
 *    <b>Styles</b>
 *    cornerRadius="4""
 *    rollOverColor="0xEEFEE6"
 *    selectionColor="0xB7F39B"
 *    textRollOverColor="0x2B333C"
 *    textSelectedColor="0x2B333C"
 *  /&gt;
 *  </pre>
 *
 *  @includeExample examples/LinkButtonExample.mxml
 * 
 *  @see mx.controls.LinkBar
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class LinkButton extends Button
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class mixins
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Placeholder for mixin by LinkButtonAccImpl.
	 */
	mx_internal static var createAccessibilityImplementation:Function;

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
	public function LinkButton()
	{
		super();

		// Sprite variables.
		buttonMode = true; // enables the hand cursor
		
		// Old Padding logic variables
		extraSpacing = 4;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  emphasized
	//----------------------------------

	[Inspectable(environment="none")]

	/**
	 *  @private
	 *  A LinkButton doesn't have an emphasized state, so _emphasized
	 *  is set false in the constructor and can't be changed via this setter.
	 */
    override public function set emphasized(value:Boolean):void
    {
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        buttonMode = value;
    }

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Called by the initialize() method of UIComponent
	 *  to hook in the accessibility code.
	 */
	override protected function initializeAccessibility():void
	{
		if (createAccessibilityImplementation != null)
			createAccessibilityImplementation(this);
	}

}

}
