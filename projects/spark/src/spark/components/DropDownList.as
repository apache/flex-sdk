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

import mx.core.mx_internal;

import spark.components.supportClasses.TextBase;
import spark.utils.LabelUtil;    
    
use namespace mx_internal;

/**
 *  The DropDownList control contains a drop-down list
 *  from which the user can select a single value.
 *  Its functionality is very similar to that of the
 *  SELECT form element in HTML.
 *
 *  <p>The DropDownList control consists of the anchor button, 
 *  prompt area, and drop-down-list, 
 *  Use the anchor button to open and close the drop-down-list. 
 *  The prompt area displays a prompt String, or the selected item 
 *  in the drop-down-list.</p>
 *
 *  <p>When the drop-down list is open:</p>
 *  <ul>
 *    <li>Clicking the anchor button closes the drop-down list 
 *      and commits the currently selected data item.</li>
 *    <li>Clicking outside of the drop-down list closes the drop-down list 
 *      and commits the currently selected data item.</li>
 *    <li>Clicking on a data item selects that item and closes the drop-down list.</li>
 *    <li>If the <code>requireSelection</code> property is <code>false</code>, 
 *      clicking on a data item while pressing the Control key deselects 
 *      the item and closes the drop-down list.</li>
 *  </ul>
 *
 *  @mxml <p>The <code>&lt;s:DropDownList&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:DropDownList 
 *    <strong>Properties</strong>
 *    prompt=""
 * 
 *    <strong>Events</strong>
 *    closed="<i>No default</i>"
 *    open="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.DropDownListSkin
 *  @see spark.components.supportClasses.DropDownController
 *
 *  @includeExample examples/DropDownListExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DropDownList extends DropDownListBase
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
    public function DropDownList()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------    
    
    //----------------------------------
    //  labelDisplay
    //----------------------------------

    [SkinPart(required="false")]

    /**
     *  An optional skin part that holds the prompt or the text of the selected item. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelDisplay:TextBase;
       
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */
    private var labelChanged:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        if (labelDisplay)
            return getBaselinePositionForPart(labelDisplay);
        
        return super.baselinePosition;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  prompt
    //----------------------------------

    /**
     *  @private
     */
    private var _prompt:String = "";

    /**
     *  The prompt for the DropDownList control. 
     *  The prompt is a String that is displayed in the
     *  DropDownList when <code>selectedIndex</code> = -1.  
     *  It is usually a String such as "Select one...". 
     *  Selecting an item in the drop-down list replaces the 
     *  prompt with the text from the selected item.
     *  
     *  @default ""
     *       
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get prompt():String
    {
        return _prompt;
    }

    /**
     *  @private
     */
    public function set prompt(value:String):void
    {
        if (_prompt == value)
            return;
            
        _prompt = value;
        labelChanged = true;
        invalidateProperties();
    }

    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (labelChanged)
        {
            labelChanged = false;
            updateLabelDisplay();
        }
    }
    
    /**
     *  @private
     */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelDisplay)
        {
            labelChanged = true;
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     *  Called whenever we need to update the text passed to the labelDisplay skin part
     */
    // TODO (jszeto): Make this protected and make the name more generic (passing data to skin) 
    override mx_internal function updateLabelDisplay():void
    {
        if (labelDisplay)
        {
            if (selectedItem != null && selectedItem != undefined)
                labelDisplay.text = LabelUtil.itemToLabel(selectedItem, labelField, labelFunction);
            else
                labelDisplay.text = prompt;
        }   
    }
 
}

}
