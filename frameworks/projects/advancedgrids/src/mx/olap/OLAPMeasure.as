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

import mx.olap.aggregators.SumAggregator;
import mx.olap.aggregators.AverageAggregator;
import mx.olap.aggregators.MaxAggregator;
import mx.olap.aggregators.MinAggregator;
import mx.olap.aggregators.CountAggregator;
import mx.resources.ResourceManager;

[ResourceBundle("olap")]

/**
 *  The OLAPMeasure class represents a member of the measure dimension of an OLAP cube.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPMeasure extends OLAPMember
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param name The name of the OLAP element that includes the OLAP schema hierarchy of the element. 
     *  For example, "Time_Year", where "Year" is a level of the "Time" dimension in an OLAP schema.
     *
     *  @param displayName The name of the measure, as a String, which can be used for display.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OLAPMeasure(name:String=null, displayName:String=null)
    {
        super(name, displayName);
    }


    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // isMeasure
    //----------------------------------
    
    /**
     * @private
     */
    override public function get isMeasure():Boolean
    {
        return true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    // aggregator
    //----------------------------------
    
    /**
     * @private
     *
     * By default we use the sum as aggregator.
     */
    private var _aggregator:Object = new SumAggregator;
    
    /**
     *  The aggregation to be performed for this measure.
     *  You can use one of the following values for the property: 
     *  <code>"SUM"</code>, <code>"AVG"</code>, <code>"MIN"</code>, 
     *  <code>"MAX"</code>, or <code>"COUNT"</code>.
     *
     *  <p>You can also use a custom aggregator by implementing 
     *  the IOLAPCustomAggregator interface, then setting the <code>aggregator</code> property to 
     *  that custom aggregator, as the following example shows:</p>
     *
     * <pre>aggregator={new CustomAgg()}</pre>
     *
     *  @see mx.olap.IOLAPCustomAggregator
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get aggregator():Object
    {
        return _aggregator;
    }
    
    /**
     * @private
     */
    public function set aggregator(value:Object):void
    {
        _aggregator = value;
        if (value is String)
        {
            switch(String(value).toLowerCase())
            {
                case "sum":
                    _aggregator = new SumAggregator;
                    break;
                case "count":
                    _aggregator = new CountAggregator;
                    break;
                case "avg":
                    _aggregator = new AverageAggregator;
                    break;
                case "max":
                    _aggregator = new MaxAggregator;
                    break;
                case "min":
                    _aggregator = new MinAggregator;
                    break;
                default:
                    {
                        _aggregator = null;
                        var message:String = ResourceManager.getInstance().getString(
                                "olap", "invalidAggregator", [value]);
                        throw Error(message);
                    }
                    break;
            }
        }
    } 
}

}
