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

package mx.controls.treeClasses
{
import flash.events.MouseEvent;

import mx.controls.listClasses.MXItemRenderer;
import mx.controls.Tree;
import mx.core.mx_internal;
import mx.events.TreeEvent;
import spark.components.Group;

use namespace mx_internal; 

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="listData", kind="property")]

/**
 *  The MXTreeItemRenderer class defines the Spark item renderer class 
 *  for use with the MX Tree control.
 *  This class lets you use the Spark item renderer architecture with the 
 *  MX Tree control. 
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:MXTreeItemRenderer &gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:MXItemRenderer
 *    <strong>Properties</strong>
 *  /&gt;
 *  </pre>
 *  
 *  @see mx.controls.Tree
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class MXTreeItemRenderer extends MXItemRenderer
{    
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
    public function MXTreeItemRenderer()
    {
        super();
    }
    
    //----------------------------------
    //  disclosureGroup
    //----------------------------------

    /**
     *  storage for disclosureGroup
     */
    private var _disclosureGroup:Group;

    /**
     *  If supplied, the component that will be used as the Tree's
     *  disclosure control.  
     *  Clicking on this control dispatches 
     *  the tree events, such as <code>itemClose</code> and <code>itemOpen</code>, 
     *  and the <code>click</code> event is not propagated
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get disclosureGroup():Group
    {
        return _disclosureGroup;
    }

    /**
     *  @private
     */
    public function set disclosureGroup(value:Group):void
    {
        if (value != _disclosureGroup)
        {
            if (_disclosureGroup)
            {
                _disclosureGroup.removeEventListener(MouseEvent.MOUSE_DOWN,
                        disclosureGroup_mouseDownHandler);
                _disclosureGroup.removeEventListener(MouseEvent.CLICK,
                        disclosureGroup_clickHandler);
            }
            _disclosureGroup = value;
            if (_disclosureGroup)
            {
                _disclosureGroup.addEventListener(MouseEvent.MOUSE_DOWN,
                        disclosureGroup_mouseDownHandler);
                _disclosureGroup.addEventListener(MouseEvent.CLICK,
                        disclosureGroup_clickHandler);
            }
        }
    }

    //----------------------------------
    //  treeListData
    //----------------------------------

    [Bindable("dataChange")]
    
    /**
     *  The implementation of the <code>listData</code> property
     *  as defined by the IDropInListItemRenderer interface.
     *  Use this property to access information about the 
     *  data item displayed by the item renderer.     
     *
     *  @see mx.controls.listClasses.IDropInListItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get treeListData():TreeListData
    {
        return listData as TreeListData;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Handle special behavior when clicking on the disclosure icon
     */
    protected function disclosureGroup_mouseDownHandler(event:MouseEvent):void
    {
        event.stopPropagation();
        
        if (Tree(listData.owner).isOpening || !listData.owner.enabled)
            return;

        treeListData.open = !treeListData.open;
        
        Tree(listData.owner).dispatchTreeEvent(TreeEvent.ITEM_OPENING,
                                data,      //item
                                this,      //renderer
                                event,     //trigger
                                treeListData.open,      //opening
                                true,      //animate
                                true)      //dispatch
    }
    
    /**
     *  @private
     *  Handle special behavior when clicking on the disclosure icon
     */
    protected function disclosureGroup_clickHandler(event:MouseEvent):void
    {
        // stop this event from bubbling up because the click is 
        // for item selection and clicking on the disclosureIcon doesn't
        // select the items (only expands/closes them).
        event.stopPropagation();
    }

}
}