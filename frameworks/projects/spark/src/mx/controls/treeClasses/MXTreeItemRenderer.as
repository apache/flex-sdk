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
 *  The MXItemRenderer class is the base class for Spark item renderers in 
 *  Halo (mx) classes
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:MXItemRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:MXItemRenderer
 *    <strong>Properties</strong>
 *  /&gt;
 *  </pre>
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
     *  ID of the component that will receive focus as the editor
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