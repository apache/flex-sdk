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

package mx.containers
{

import mx.core.mx_internal;
use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="direction", kind="property")]

[Exclude(name="focusIn", kind="event")]
[Exclude(name="focusOut", kind="event")]

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusSkin", kind="style")]
[Exclude(name="focusThickness", kind="style")]

[Exclude(name="focusInEffect", kind="effect")]
[Exclude(name="focusOutEffect", kind="effect")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("HBox.png")]

[Alternative(replacement="spark.components.HGroup", since="4.0")]

/**
 *  The Halo HBox container lays out its children in a single horizontal row.
 *  You use the <code>&lt;mx:HBox&gt;</code> tag instead of the
 *  <code>&lt;mx:Box&gt;</code> tag as a shortcut to avoid having to
 *  set the <code>direction</code> property to
 *  <code>"horizontal"</code>.
 * 
 *  <p><b>Note:</b> Adobe recommends that, when possible, you use the Spark containers 
 *  with HorizontalLayout instead of the Halo HBox container.</p>
 *
 *  <p>An HBox container has the following default sizing characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>The width is large enough to hold all its children at the default or explicit width of the children, 
 *               plus any horizontal gap between the children, plus the left and right padding of the container. 
 *               The height is the default or explicit height of the tallest child, 
 *               plus the top and bottom padding for the container.
 *           </td>
 *        </tr>
 *        <tr>
 *           <td>Default padding</td>
 *           <td>0 pixels for the top, bottom, left, and right values.</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:HBox&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass, except <code>direction</code>, and adds 
 *  no new tag attributes.</p>
 *
 *  @includeExample examples/HBoxExample.mxml
 *
 *  @see mx.components.Container
 *  @see mx.containers.Box
 *  @see mx.containers.VBox
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class HBox extends Box
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
    public function HBox()
    {
        super();
        
        layoutObject.direction = BoxDirection.HORIZONTAL;
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
     *  Don't allow user to change the direction
     */
    override public function set direction(value:String):void
    {
    }

}

}
