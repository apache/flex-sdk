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
import mx.utils.ColorUtil;

/**
 *  The skin for the column drop indicator in an AdvancedDataGrid control 
 *  when the drop is not allowed.
 *
 *  @see mx.controls.AdvancedDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AdvancedDataGridColumnWrongDropIndicator extends ProgrammaticSkin
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
    public function AdvancedDataGridColumnWrongDropIndicator()
    {
        super();
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

        g.lineStyle(1, 0xFFE1B2);
        g.moveTo(0, 0);
        g.lineTo(0, h);

        g.lineStyle(1, ColorUtil.adjustBrightness(getStyle("themeColor"), -75));
        g.moveTo(1, 0);
        g.lineTo(1, h);

        g.lineStyle(1, 0xFFE1B2);
        g.moveTo(2, 0);
        g.lineTo(2, h);
    }
}

}