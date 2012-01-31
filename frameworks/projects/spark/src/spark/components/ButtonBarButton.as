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

package mx.components
{
import flash.events.MouseEvent;

import mx.components.FxButton;
import mx.core.IDataRenderer;
import mx.core.ISelectableRenderer;
import mx.core.mx_internal;

/**
 *  The <code>ButtonBarButton</code> implements <code>IDataRenderer</code>
 *  and proxies the <code>label</code> property with the <code>data</code>
 *  property. Used in the default skin for the <code>ButtonBar</code>.
 */
public class ButtonBarButton extends FxToggleButton implements IDataRenderer, ISelectableRenderer
{
    /**
     *  Constructor. 
     */    
    public function ButtonBarButton()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  allowDeselection
    //----------------------------------

    /**
     *  @private
     *  Storage for the allowDeselection property 
     */
    private var _allowDeselection:Boolean = true;

    /**
     *  @inheritDoc 
     */    
    public function get allowDeselection():Boolean
    {
        return _allowDeselection;
    }
    
    /**
     *  @private
     */    
    public function set allowDeselection(value:Boolean):void
    {
        _allowDeselection = value;
    }

    //----------------------------------
    //  showFocusIndicator
    //----------------------------------

    /**
     *  @private
     *  Storage for the showFocusIndicator property 
     */
    private var _showFocusIndicator:Boolean = false;

    /**
     *  @inheritDoc 
     */    
    public function get showFocusIndicator():Boolean
    {
        return _showFocusIndicator;
    }
    
    /**
     *  @private
     */    
    public function set showFocusIndicator(value:Boolean):void
    {
        if (value == _showFocusIndicator)
            return;

        _showFocusIndicator = value;
        mx_internal::drawFocusAnyway = true;
        drawFocus(value);
    }

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @inheritDoc 
     */
    public function get data():Object
    {
         return content;
    }

    /**
     *  @private 
     */
    public function set data(value:Object):void
    {
         content = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    override protected function clickHandler(event:MouseEvent):void
    {
        if (selected && !allowDeselection)
            return;
        super.clickHandler(event);
    }
}

}