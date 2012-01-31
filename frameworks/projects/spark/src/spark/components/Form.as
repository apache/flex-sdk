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
     *  - Should we support developer overriding the layout defined value in columnWidths? 
     *  If so, we need a seperate property or function like columnWidthsOverride
     * 
     */ 
    
    /**
     *  SkinnableContainer with IFormItem children. It has a columnWidths property 
     *  which is an array of numbers that correspond to the maximum width for 
     *  each form column. Typically this is set by the FormLayout. 
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
        
        // 
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
