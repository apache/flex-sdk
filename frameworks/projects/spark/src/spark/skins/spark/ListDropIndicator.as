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

package spark.skins.spark
{
import flash.display.Graphics;

import mx.skins.ProgrammaticSkin;

/**
 *  The default skin for the drop indicator of a List component in case 
 *  List doesn't have a <code>dropIndicator</code> part defined in its skin.
 *
 *  @see spark.components.List
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ListDropIndicator extends ProgrammaticSkin
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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ListDropIndicator()
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
        
        // If the gap is 0 or negative, the layout would size us as 0 width/height,
        // we need some minimum to ensure drawing.
        var width:Number = Math.max(2, w);
        var height:Number = Math.max(2, h);

        // Make the shorter side 2 pixels so that the drop indicator is always 
        // a 2 pixel thick line regardless of vertical/horizontal orientation.
        if (width < height)
            width = 2;
        else
            height = 2;         

        // Center the drawing within the bounds
        var x:Number = Math.round((w - width) / 2);
        var y:Number = Math.round((h - height) / 2);

        var g:Graphics = graphics;
        g.clear();
        g.beginFill(0x2B333C);
        g.drawRect(x, y, width, height);
        g.endFill();
    }
}
}
