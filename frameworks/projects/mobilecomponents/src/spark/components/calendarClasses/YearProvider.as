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
 *  Helper class for creating a dynamic year range. Using this class instead of
 *  generating all the years statically avoids the cost of applying DateTimeFormatterEx.format()
 *  to every date.
 *   
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class YearProvider extends OnDemandDataProvider
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Construct a year range for DateSpinner from the start to end dates, inclusive.
     *  Locale is used to generate the appropriate labels.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function YearProvider(locale:String, start:int = 1601, end:int = 9999,
                                 today:Date = null)
    {
        super();
        
        startYear = start;
        endYear = end;
        
        formatter = new DateTimeFormatterEx();
        if (locale)
            formatter.setStyle("locale", locale);
        else
            formatter.clearStyle("locale");
        formatter.dateTimePattern = formatter.getYearPattern();
        
        todayDate = today;
    }

    //----------------------------------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------------------------------
    
    // start of the date range
    private var startYear:int;
    
    // end of the date range
    private var endYear:int;
    
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
    /**
     *  @inherit 
     */ 
    override public function get length():int
    {
        return (endYear - startYear) + 1;
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
        var year:int = index + startYear;
        var d:Date = new Date(year, 0, 1);
        var enabledFlag:Boolean = year >= startYear && year <= endYear;
        
        // generate the appropriate object
        var item:Object = {label:formatter.format(d), data:year, enabled:enabledFlag };
        
        if (todayDate)
        {
            if (year == todayDate.fullYear)
                item["_emphasized_"] = true;
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
            var year:Number = item.data;
            
            if (!isNaN(year)){
                if (year >= startYear && year <= endYear)
                    return Math.floor(year - startYear);
            }            
        }
        catch (e:Error) // in case object is in an incorrect format
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