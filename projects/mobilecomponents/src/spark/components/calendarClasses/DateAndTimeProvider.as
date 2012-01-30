////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
package spark.components.calendarClasses
{
import spark.collections.OnDemandDataProvider;
import spark.globalization.supportClasses.DateTimeFormatterEx;

[ExcludeClass]

/**
 *  Helper class for creating a dynamic date range for DateSpinner in DATE_AND_TIME
 *  mode. Using this class instead of generating all the dates statically avoids
 *  the cost of applying DateTimeFormatter.format() to every date.
 *   
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class DateAndTimeProvider extends OnDemandDataProvider
{
    //----------------------------------------------------------------------------------------------
    //
    //  Class constants
    //
    //----------------------------------------------------------------------------------------------
    
    // number of milliseconds in a day
    private static const MS_IN_DAY:Number = 1000 * 60 * 60 * 24;
    
    // default min/max date
    private static const MIN_DATE_DEFAULT:Date = new Date(DateTimeFormatterEx.MIN_YEAR, 0, 1);
    private static const MAX_DATE_DEFAULT:Date = new Date(9999, 11, 31, 23, 59, 59, 999);
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Construct a DATE_AND_TIME range for DateSpinner from the start to
     *  end dates, inclusive. Locale is used to generate the appropriate
     *  labels.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function DateAndTimeProvider(locale:String, start:Date, end:Date, 
                                        today:Date = null)
    {
        if (start == null)
            start = MIN_DATE_DEFAULT;
        
        if (end == null)
            end = MAX_DATE_DEFAULT;
        
        // we only count days; reset clocks so there are no rounding errors
        startDate = new Date(start.time);
        endDate = new Date(end.time);
        
        // note: set hours to 11 to avoid being near day boundaries that can
        // cause repeat days due to daylight savings time
        startDate.hours = 11;
        startDate.minutes = 0;
        startDate.seconds = 0;
        startDate.milliseconds = 0;
        endDate.hours = 11;
        endDate.minutes = 0;
        endDate.seconds = 0;
        endDate.milliseconds = 0;
        
        // calculate how many days there are between the two
        // +1 because we need to include both start and end dates
        _length = ((endDate.time - startDate.time) / MS_IN_DAY) + 1;
        
        formatter = new DateTimeFormatterEx();
        if (locale)
            formatter.setStyle("locale", locale);
        else
            formatter.clearStyle("locale");
        formatter.dateTimeSkeletonPattern = DateTimeFormatterEx.DATESTYLE_MMMEEEd;
        
        todayDate = today;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------------------------------
    
    // start of the date range
    private var startDate:Date;
    
    // end of the date range
    private var endDate:Date;
    
    private var todayDate:Date;
        
    // formatter to use in localizing the date labels
    private var formatter:DateTimeFormatterEx;
    
    //----------------------------------------------------------------------------------------------
    //
    //  Properties
    //
    //----------------------------------------------------------------------------------------------
    
    //----------------------------------
    //  length
    //----------------------------------
    
    private var _length:int;
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override public function get length():int
    {
        return _length;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //----------------------------------------------------------------------------------------------

    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override public function getItemAt(index:int, prefetch:int=0):Object
    {
        // calc date you want from index
        var d:Date = new Date(startDate.time + index * MS_IN_DAY);

        // generate the appropriate object
        var item:Object = { label:formatter.format(d), data:d.time };
        
        if (todayDate)
        {
            if (d.getFullYear() == todayDate.getFullYear() && 
                d.getMonth() == todayDate.getMonth() &&
                d.getDate() == todayDate.getDate())
            {
                item["_emphasized_"] = true;
            }
        }
        
        return item;
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override public function getItemIndex(item:Object):int
    {
        try
        {
            if (!isNaN(item.data))
            {   
                // set firstDate's hour/min/second to the same values
                var dateObj:Date = new Date(item.data);
                dateObj.hours = startDate.hours;
                dateObj.minutes = startDate.minutes;
                dateObj.seconds = startDate.seconds;
                dateObj.milliseconds = startDate.milliseconds;
                
                if (dateObj.time >= startDate.time && dateObj.time <= endDate.time)
                    return Math.round((dateObj.time - startDate.time) / MS_IN_DAY);
            }            
        } 
        catch(error:Error) 
        {
        }
        
        return -1;
    }
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override public function toArray():Array
    {
        var result:Array = [];
        var numItems:int = length;
        
        for (var i:int = 0; i < numItems; i++)
            result.push(getItemAt(i));
        
        return result;
    }
}
}