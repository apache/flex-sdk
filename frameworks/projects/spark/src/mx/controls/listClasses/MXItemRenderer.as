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

package mx.controls.listClasses
{
import flash.events.Event;

import mx.controls.listClasses.ListBase;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.managers.IFocusManagerComponent;
import mx.styles.StyleManager;
import spark.components.supportClasses.ItemRenderer;

/**
 *  The MXItemRenderer class is the base class for Spark item renderers  
 *  and item editors used in MX list-based controls. 
 *  This class lets you use the Spark item renderer architecture with the 
 *  MX DataGrid, MX AdvancedDataGrid, and MX Tree controls. 
 *
 *  <p><b>Note: </b>Many MX controls support item renderers or item editors. 
 *  However, only the MX DataGrid, MX AdvancedDataGrid, and MX Tree controls 
 *  support the MXItemRenderer class. 
 *  Therefore, continue to use MX item renderers and item editors with 
 *  MX controls other than DataGrid, AdvancedDataGrid, and Tree.</p>
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
public class MXItemRenderer extends ItemRenderer implements IListItemRenderer, IDropInListItemRenderer
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
    public function MXItemRenderer()
    {
        super();
        focusEnabled = false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Flag to help us determine if we need to validate renderer state during
     *  commitProperties.
     */
    private var rendererStateChanged:Boolean;
    
    //----------------------------------
    //  listData
    //----------------------------------

    /**
     *  @private
     *  Storage for the listData property.
     */
    private var _listData:BaseListData;

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
    public function get listData():BaseListData
    {
        return _listData;
    }

    /**
     *  @private
     */
    public function set listData(value:BaseListData):void
    {
        _listData = value;

        invalidateProperties();
    }

    //----------------------------------
    //  editor
    //----------------------------------

    /**
     *  If supplied, the component that will receive focus as the editor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var editor:IFocusManagerComponent;

    //----------------------------------
    //  text
    //----------------------------------

    /**
     *  The <code>text</code> property of
     *  the component specified by <code>editorID</code>.
     *  This is a convenience property to
     *  let the item editor of the MX control, 
     *  specified by the <code>itemEditor</code> property, 
     *  pull the value from most item editors
     *  without having to propagate a property
     *  to the MXItemRenderer.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get text():String
    {
        if (editor && ("text" in editor))
            return editor["text"];

        return null;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    override public function invalidateDisplayList():void
    {
        if (listData)
        {
            // see if we need to change state.  This is the only invalidation method guaranteed to be
            // called. 
            var listBase:mx.controls.listClasses.ListBase = mx.controls.listClasses.ListBase(listData.owner);
            if (listBase)
            {
                if (showsCaret != listBase.isItemShowingCaret(data) ||
                    selected != listBase.isItemSelected(data) ||
                    super.hovered != listBase.isItemHighlighted(data))
                {
                    rendererStateChanged = true;
                    invalidateProperties();
                }
            }
        }

        super.invalidateDisplayList();
    }

    /**
     *  @private
     */ 
    override protected function set hovered(value:Boolean):void
    {
        if (listData)
        {
            // see if we need to change state.
            // in Halo list, you can rollout of the renderer and onto the padding area
            // and you should still be hovered, so we double check and override here.
            // then we get all the other state-related variables updated so the state
            // calculation will do the right thing.
            var listBase:mx.controls.listClasses.ListBase = mx.controls.listClasses.ListBase(listData.owner);
            if (listBase)
            {
                selected = listBase.isItemSelected(data);
                value = listBase.isItemHighlighted(data);
            }
        }
        super.hovered = value;
    }

    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        // make sure itemIndex is correct before the base class does any computation
        // based on it
        if (listData)
        {
            var listBase:mx.controls.listClasses.ListBase = mx.controls.listClasses.ListBase(listData.owner);
            itemIndex = listData.rowIndex + listBase.verticalScrollPosition;
        }
        
        // Validate renderer state prior to super.commitProperties.
        if (rendererStateChanged && listBase)
        {
            rendererStateChanged = false;
            showsCaret = listBase.isItemShowingCaret(data);
            selected = listBase.isItemSelected(data);
            super.hovered = listBase.isItemHighlighted(data);
        }
    
        super.commitProperties();
    }

    /**
     *  @private
     */ 
    override public function setFocus():void
    {
        if (editor)
        {
            editor.setFocus();
            return;
        }
        
        super.setFocus();
    }


}
}