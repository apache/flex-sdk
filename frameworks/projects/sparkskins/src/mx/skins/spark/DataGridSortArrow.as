
////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.skins.spark
{
    
    import flash.display.Graphics;
    import mx.skins.ProgrammaticSkin;
    
    /**
     *  The skin for the sort arrow in a column header in an MX DataGrid.
     *  
     *  @see mx.controls.DataGrid
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class DataGridSortArrow extends ProgrammaticSkin
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
         *  @playerversion Flash 9
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function DataGridSortArrow()
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
            return 6;
        }
        
        //----------------------------------
        //  measuredHeight
        //----------------------------------
        
        /**
         *  @private
         */
        override public function get measuredHeight():Number
        {
            return 6;
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
            var alpha:Number = name == "sortArrowDisabled" ? 0.5 : 1;
            
            g.clear();
            g.beginFill(getStyle("symbolColor"), alpha);
            g.moveTo(0,0);
            g.lineTo(w, 0);
            g.lineTo(w / 2, h);
            g.lineTo(0,0);
            g.endFill();
        }
    }
    
}
