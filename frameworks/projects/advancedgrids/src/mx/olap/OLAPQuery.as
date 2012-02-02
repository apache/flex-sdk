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

package mx.olap
{

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("axes")]

/**
 *  The OLAPQuery interface represents an OLAP query that is executed on an IOLAPCube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPQuery&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPQuery
 *    <b>Properties</b>
 *       axis=""
 *  /&gt;
 *
 *  @see mx.olap.IOLAPQuery
 *  @see mx.olap.IOLAPQueryAxis
 *  @see mx.olap.OLAPQueryAxis
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPQuery implements IOLAPQuery
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Specifies a column axis.
     *  Use this property as a value of the <code>axisOrdinal</code> argument
     *  to the <code>getAxis()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static var COLUMN_AXIS:int = 0;
    
    /**
     *  Specifies a row axis.
     *  Use this property as a value of the <code>axisOrdinal</code> argument
     *  to the <code>getAxis()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static var ROW_AXIS:int = 1;
    
    /**
     *  Specifies a slicer axis.
     *  Use this property as a value of the <code>axisOrdinal</code> argument
     *  to the <code>getAxis()</code> method.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static var SLICER_AXIS:int = 2;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // axes
    //----------------------------------
    
    private var _axes:Array = [new OLAPQueryAxis(0),  // col axis
                                new OLAPQueryAxis(1),  // row axis
                                new OLAPQueryAxis(2)]; // slicer axis
    
    /**
     *  The axis of the Query as an Array of OLAPQueryAxis instances. 
     *  A query can have three axes: column, row, and slicer.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function set axes(value:Array):void
    {
        _axes = value;
    }
    
    /**
     *  @private
     */
    public function get axes():Array
    {
        return _axes;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getAxis(axisOrdinal:int):IOLAPQueryAxis
    {
        switch(axisOrdinal)
        {
            case COLUMN_AXIS:
            case ROW_AXIS:
            case SLICER_AXIS:
                return axes[axisOrdinal];
        }
        return null;    
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setAxis(axisOrdinal:int, axis:IOLAPQueryAxis):void
    {
        switch(axisOrdinal)
        {
            case COLUMN_AXIS:
            case ROW_AXIS:
            case SLICER_AXIS:
                axes[axisOrdinal] = axis;
                break;
        }
    }

}

}