////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
//
////////////////////////////////////////////////////////////////////////////////////////

package mx.charts.chartClasses
{
    /**
     * Defines the position of objects on a data canvas. This class has a data coordinate and an
     * optional offset that are used by the CartesianDataCanvas class to calculate pixel 
     * coordinates.
     * 
     * @see mx.charts.chartClasses.CartesianDataCanvas
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public class CartesianCanvasValue
    {
        include "../../core/Version.as";
        
        //-------------------------------------------------------
        //
        // Constructor
        //
        //-------------------------------------------------------
        /**
         * Constructor.
         * 
         * @param value The data coordinate of a point.
         * @param offset Offset of the data coordinate specified in <code>value</code>, in pixels.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 9
         *  @playerversion AIR 1.1
         *  @productversion Flex 3
         */
        public function CartesianCanvasValue(value:*, offset:Number = 0):void
        {
            this.value = value;
            this.offset = offset;
        }
        
        //---------------------------------
        // offset
        //---------------------------------
        
        /**
         * @private
         * Storage for value
         */
        private var _offset:Number;
         
        /**
         *  @private
         */
        public function get offset():Number
        {
            return _offset;
        }
        
        /**
         * @private
         */
        public function set offset(data:Number):void
        {
            _offset = data;
        }
        
        //---------------------------------
        // value
        //---------------------------------
        
        /**
         * @private
         * Storage for value
         */
        private var _value:*;
         
        /**
         *  @private
         */
        public function get value():*
        {
            return _value;
        }
        
        /**
         * @private
         */
        public function set value(data:*):void
        {
            _value = data;
        }  
        
        //-------------------------------------------------
        //
        //  Methods
        //
        //-------------------------------------------------
        
        /**
         * @private
         */
        public function clone():CartesianCanvasValue
        {
            return new CartesianCanvasValue(value,offset);
        }
    }
}