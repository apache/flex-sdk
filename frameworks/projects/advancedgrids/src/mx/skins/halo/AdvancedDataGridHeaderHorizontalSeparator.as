////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.skins.halo
{

import flash.display.Graphics;
import mx.skins.ProgrammaticSkin;

/**
 *  The skin for the separator between column headers in an AdvancedDataGrid control.
 *
 *  @see mx.controls.AdvancedDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridHeaderHorizontalSeparator extends ProgrammaticSkin
{
    include "../../core/Version.as";

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
    public function AdvancedDataGridHeaderHorizontalSeparator()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     */
    override public function get measuredWidth():Number
    {
        return 10;
    }
    
    //----------------------------------
    //  measuredHeight
    //----------------------------------

    /**
     *  @private
     */
    override public function get measuredHeight():Number
    {
        return 2;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);
        var g:Graphics = graphics;
        
        g.clear();
        
        g.moveTo(0, 0);
        g.lineTo(w, 0);
        g.lineStyle(1, getStyle("borderColor")); 
        g.moveTo(0, 1);
        g.lineTo(w, 1);
    }
}

}