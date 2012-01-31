package spark.components
{

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
        
    /**
     *  TODO:
     * 
     * 
     * 
     *  ISSUES:
     *  - Support auto-generation of numberLabel values?
     * 
     * 
     */ 
    
    /**
     *  TBD
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5 
     */
    public class Form extends SkinnableContainer
    {
        
        public function Form()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  columnWidths
        //----------------------------------
        
        
        private var _columnWidths:Vector.<Number>;
        
        [Bindable("updateComplete")]
        
        /**
         *  An array of the maximum widths of the spaces allocated for each Form column
         * 
         *  <p>This property is set by the Form's layout. For all other purposes
         *  it should be considered read-only.</p>
         * 
         *  @default 
         * 
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4.5 
         */
        
        // TODO Should we support developer overriding the layout defined value? 
        // If so, we need a seperate property or function like columnWidthsOverride
        public function get columnWidths():Vector.<Number>
        {
            return _columnWidths;
        }
        
        /**
         *  @private
         */
        public function set columnWidths(value:Vector.<Number>):void
        {
            _columnWidths = value;
        
        }
        
        
    }
}
