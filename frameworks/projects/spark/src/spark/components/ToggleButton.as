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

import spark.components.supportClasses.ToggleButtonBase;


[IconFile("ToggleButton.png")]

/**
 *  The ToggleButton component defines a toggle button. 
 *  Clicking the button toggles it between the up and an down states.
 *  If you click the button while it is in the up state, 
 *  it toggles to the down state. You must click the button again 
 *  to toggle it back to the up state.
 * 
 *  <p>You can get or set this state programmatically
 *  by using the <code>selected</code> property.</p>
 *
 *  <p>The ToggleButton control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>Wide enough to display the text label of the control</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>21 pixels wide and 21 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin class</td>
 *           <td>spark.skins.spark.ToggleButtonSkin</td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:ToggleButton&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no tag attributes:</p>
 * 
 *  <pre>
 *  &lt;s:ToggleButton/&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.ToggleButtonSkin
 *  @includeExample examples/ToggleButtonExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ToggleButton extends ToggleButtonBase
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
    public function ToggleButton()
    {
        super();
    }
}
}
