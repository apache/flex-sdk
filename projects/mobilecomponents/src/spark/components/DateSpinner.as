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
package spark.components
{
import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.collections.ISort;
import mx.core.IFactory;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.collections.Sort;
import spark.collections.SortField;
import spark.components.calendarClasses.DateAndTimeProvider;
import spark.components.calendarClasses.DateSelectorDisplayMode;
import spark.components.calendarClasses.YearProvider;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.IndexChangeEvent;
import spark.formatters.DateTimeFormatter;
import spark.formatters.NumberFormatter;
import spark.globalization.supportClasses.CalendarDate;
import spark.globalization.supportClasses.DateTimeFormatterEx;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------
/**
 *  Dispatched after the selected date has been changed by the user
 *
 *  @eventType flash.events.Event.CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Event(name="change", type="flash.events.Event")]

/**
 *  Dispatched after the selected date has been changed, either
 *  by the user (i.e. interactively) or programmatically.
 *
 *  @eventType mx.events.FlexEvent.VALUE_COMMIT
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Event(name="valueCommit", type="mx.events.FlexEvent")]

//--------------------------------------
//  Styles
//--------------------------------------
/**
 *  The locale of the component. Controls how dates are formatted, e.g. in what order the fields
 *  are listed and what additional date-related characters are shown if any. Uses standard locale
 *  identifiers as described in Unicode Technical Standard #35. For example "en", "en_US" and "en-US"
 *  are all English, "ja" is Japanese.
 *
 *  <p>The default value is undefined. This property inherits its value from an ancestor; if still
 *  undefined, it inherits from the global <code>locale</code> style.</p>
 *
 *  <p>When using the Spark formatters and globalization classes, you can set this style on the root
 *  application to the value of the <code>LocaleID.DEFAULT</code> constant.
 *  Those classes will then use the client operating system's international preferences.</p>
 *
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Style(name="locale", type="String", inherit="yes")]

/**
 *  Color applied for the date items that match today's date.
 *  For example, if this is set to "0x0000FF" and today's date is 1/1/2011, then the month
 *  "January", the date "1", and the year "2011" will be in blue text on the spinners. This color
 *  is not applied to time items.
 * 
 *  @default #0058A8
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Style(name="accentColor", type="uint", format="Color", inherit="yes")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("DateSpinner.png")]

/**
 *  The DateSpinner component presents an interface for picking a particular point
 *  in time. The interface is made up of a series of SpinnerList controls that show the
 *  user the currently selected date and, through touch or mouse interaction, allow the user
 *  to adjust the selected date.
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */

public class DateSpinner extends SkinnableComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constant for specifying to createDateItemList() that the list is for showing
     *  years.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected static const YEAR_ITEM:String = "yearItem";

    /**
     *  Constant for specifying to createDateItemList() that the list is for showing
     *  months.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected static const MONTH_ITEM:String = "monthItem";

    /**
     *  Constant for specifying to createDateItemList() that the list is for showing
     *  dates of the month or year.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected static const DATE_ITEM:String = "dateItem";
    
    /**
     *  Constant for specifying to createDateItemList() that the list is for showing
     *  hours.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected static const HOUR_ITEM:String = "hourItem";
    
    /**
     *  Constant for specifying to createDateItemList() that the list is for showing
     *  minutes.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected static const MINUTE_ITEM:String = "minuteItem";
    
    /**
     *  Constant for specifying to createDateItemList() that the list is for showing
     *  meridian options.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected static const MERIDIAN_ITEM:String = "meridianItem";
    
    // number of years to show by default in DATE mode
    private static const DEFAULT_YEAR_RANGE:int = 200;
    
    // number of days to show by default in DATE_AND_TIME mode
    private static const DEFAULT_DATE_RANGE:int = 730;
    
    private static const MS_IN_DAY:Number = 1000 * 60 * 60 * 24;
    
    // choosing January 1980 to guarantee 31 days in the month
    private static const JAN1980_IN_MS:Number = 315561660000;
    
    // meridian
    private static const AM:String = "am";
    private static const PM:String = "pm";
    
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function DateSpinner()
    {
        super();
        
        displayMode = DateSelectorDisplayMode.DATE;
        
        // TODO: the DateTimeFormatter should use the same styles as this DateSpinner
        // dateTimeFormatter.styleParent = this;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var populateYearDataProvider:Boolean = true;
    private var populateMonthDataProvider:Boolean = true;
    private var populateDateDataProvider:Boolean = true;
    private var populateHourDataProvider:Boolean = true;
    private var populateMinuteDataProvider:Boolean = true;
    private var populateMeridianDataProvider:Boolean = true;
    
    private var refreshDateTimeFormatter:Boolean = true;
    
    // the internal DateTimeFormatter that provides a set of extended functionalities
    private var dateTimeFormatterEx:DateTimeFormatterEx = new DateTimeFormatterEx();
    
    private var dateTimeFormatter:DateTimeFormatter = new DateTimeFormatter();
    
    // the DateTimeFormatterEx that uses MMMEEEd skeleton pattern to identify
    // the longest dateList item in DATE_AND_TIME mode
    private var dayMonthDateFormatter:DateTimeFormatterEx;
    
    // the NumberFormatter to identify the longest yearList item in DATE mode
    private var numberFormatter:NumberFormatter;
    
    private var dateObj:Date = new Date();
    private var use24HourTime:Boolean;
    
    // stores the longest dateList item and updates only when locale changes
    private var longestDateItem:Object;
    private var longestYearItem:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    [SkinPart]
    /**
     *  The default factory for creating SpinnerList interfaces for all fields.
     *  This is used by createDateItemList().
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var dateItemList:IFactory;
    
    [SkinPart] 
    /**
     *  The container for the date part lists
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var listContainer:IVisualElementContainer;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  The SpinnerList showing the year field of the date.
     *  shown and manipulated
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2 
     */ 
    protected var yearList:SpinnerList;

    /**
     *  The SpinnerList showing the month field of the date.
     *  shown and manipulated
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2 
     */ 
    protected var monthList:SpinnerList;
    
    /**
     *  The SpinnerList showing the date field of the date.
     *  shown and manipulated
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2 
     */ 
    protected var dateList:SpinnerList;
    
    /**
     *  The SpinnerList showing the hour field of the date.
     *  shown and manipulated
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2 
     */ 
    protected var hourList:SpinnerList;
    
    /**
     *  The SpinnerList showing the minutes field of the date.
     *  shown and manipulated
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2 
     */ 
    protected var minuteList:SpinnerList;
    
    /**
     *  The SpinnerList showing the meridian field of the date.
     *  shown and manipulated
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2 
     */ 
    protected var meridianList:SpinnerList;
    
    //----------------------------------
    //  displayMode
    //----------------------------------
    
    private var _displayMode:String;
    
    private var displayModeChanged:Boolean;
    
    [Inspectable(category="General", enumeration="date,time,dateAndTime", defaultValue="date")]
    
    /**
     *  Mode the DateSpinner is currently using for display. See 
     *  <code>DateSelectorDisplayMode</code>
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */     
    public function get displayMode():String
    {
        return _displayMode;
    }
    
    public function set displayMode(value:String):void
    {
        if (_displayMode == value)
            return;
        
        _displayMode = value;
        displayModeChanged = true;
        
        if (value == DateSelectorDisplayMode.TIME)
        {
            populateHourDataProvider = true;
            populateMinuteDataProvider = true;
            populateMeridianDataProvider = true;
        }
        else if (value == DateSelectorDisplayMode.DATE_AND_TIME)
        {
            populateYearDataProvider = true;
            populateMonthDataProvider = true;
            populateDateDataProvider = true;
            populateHourDataProvider = true;
            populateMinuteDataProvider = true;
            populateMeridianDataProvider = true;
            
            // set default min/max dates
            _minDateDefault = new Date(selectedDate.time);
            _minDateDefault.date -= Math.floor(DEFAULT_DATE_RANGE / 2);
            _maxDateDefault = new Date(selectedDate.time);
            _maxDateDefault.date += Math.floor(DEFAULT_DATE_RANGE / 2);
        }
        else // default mode is DATE
        {
            populateYearDataProvider = true;
            populateMonthDataProvider = true;
            populateDateDataProvider = true;
            
            // set default min/max dates
            _minDateDefault = new Date(selectedDate.time);
            _minDateDefault.fullYear -= Math.floor(DEFAULT_YEAR_RANGE / 2);
            _maxDateDefault = new Date(selectedDate.time);
            _maxDateDefault.fullYear += Math.floor(DEFAULT_YEAR_RANGE / 2);
        }
        
        syncSelectedDate = true; // force lists to spin to current selected date
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  maxDate
    //----------------------------------
    
    private var _maxDate:Date;
    
    private var _maxDateDefault:Date;
    private var maxDateChanged:Boolean = false;
    
    /**
     *  Maximum selectable date; only dates before this date are selectable.
     * 
     *  @default If maxDate is null, the value defaults to 100 years after
     *           the currently selected date in DATE mode, and 100 days 
     *           after the currently selected date in DATE_AND_TIME mode.
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get maxDate():Date
    {
        return _maxDate != null ? _maxDate : _maxDateDefault;
    }
    
    public function set maxDate(value:Date):void
    {
        if ((_maxDate && value && _maxDate.time == value.time)
            || (_maxDate == null && value == null))
            return;

        _maxDate = value;
        populateYearDataProvider = true;
        populateDateDataProvider = true;
        maxDateChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  minDate
    //----------------------------------
    
    private var _minDate:Date;
    
    private var _minDateDefault:Date;
    private var minDateChanged:Boolean = false;
    
    /**
     *  Minimum selectable date; only dates after this date are selectable.
     * 
     *  @default If minDate is null, the value defaults to 100 years prior to
     *           the currently selected date in DATE mode, and 100 days prior
     *           to the currently selected date in DATE_AND_TIME mode.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get minDate():Date
    {
        return _minDate != null ? _minDate : _minDateDefault;
    }
    
    public function set minDate(value:Date):void
    {
        if ((_minDate && value && _minDate.time == value.time)
            || (_minDate == null && value == null))
            return;
        
        _minDate = value;
        populateYearDataProvider = true;
        populateDateDataProvider = true;
        minDateChanged = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  minuteStepSize
    //----------------------------------
    private var _minuteStepSize:int = 1;
    
    private var minuteStepSizeChanged:Boolean = false;
    
    /**
     *  Minute interval to be used when displaying minutes. Only
     *  applicable in TIME and DATEANDTIME modes. Valid values must
     *  be evenly divisible into 60; invalid values will revert to
     *  the default interval of 1. For example, a value of "15" will show
     *  the values 0, 15, 30, 45.
     *  
     *  @default 1
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */     
    public function get minuteStepSize():int
    {
        return _minuteStepSize;
    }
    
    public function set minuteStepSize(value:int):void
    {
        if (value == _minuteStepSize)
            return;
        
        _minuteStepSize = value;
        minuteStepSizeChanged = true;
        populateMinuteDataProvider = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  selectedDate
    //----------------------------------
    private var _selectedDate:Date = todayDate;
    
    // set to true initially so that lists will be set to right values on creation
    private var syncSelectedDate:Boolean = true;
    
    [Bindable(event="valueCommit")]
    /**
     *  Date that the DateSpinner is currently selected
     *
     *  @default current date when DateSpinner was instantiated
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     * 
     */
    public function get selectedDate():Date
    {
        return _selectedDate;
    }
    
    private var selectedDateModifiedByUser:Boolean;
    
    /**
     *  @private
     */
    public function set selectedDate(value:Date):void
    {
        // short-circuit if no change
        if ((_selectedDate && value && value.time == _selectedDate.time)
            || (_selectedDate == null && value == null))
            return;
        
        _selectedDate = value;
        syncSelectedDate = true;
        
        invalidateProperties();
    }
    
    //----------------------------------
    //  todayDate
    //----------------------------------

    mx_internal static var _todayDate:Date = null;

    /**
     *  @private
     *  Function to retrieve the current Date. Provided so that
     *  testing can override by setting the _todayDate variable.
     */
    private static function get todayDate():Date
    {
        if (_todayDate != null)
            return _todayDate;
        
        return new Date();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        var listsNewlyCreated:Boolean = false;
        
        // TODO: CHECK ON THIS ASSUMPTION
        // TODO: Jason says this is wrong; just use styleName = DateSpinner to link styles
        //       but having trouble getting that to work
        var localeStr:String = getStyle("locale");
        if (refreshDateTimeFormatter)
        {
            if (localeStr)
            {
                dateTimeFormatterEx.setStyle("locale", localeStr);
                dateTimeFormatter.setStyle("locale", localeStr);
            }
            else
            {
                dateTimeFormatterEx.clearStyle("locale");
                dateTimeFormatter.clearStyle("locale");
            }
            
            use24HourTime = dateTimeFormatterEx.getUse24HourFlag();
            refreshDateTimeFormatter = false;
        }
        
        // ==================================================
        // switch out lists if the display mode changed
        
        if (displayModeChanged)
        {
            setupDateItemLists();
            
            displayModeChanged = false;
            listsNewlyCreated = true;
            syncSelectedDate = true;
        }

        // ==================================================
        // populate the lists with the appropriate data providers
        
        populateDateItemLists(localeStr);
        
        // ==================================================
        
        // correct any integrity violations
        if (minDateChanged || maxDateChanged || syncSelectedDate || listsNewlyCreated || minuteStepSizeChanged)
        {        
            // check min <= max
            if (minDate.time > maxDate.time)
            {
                // note assumption here that we're not using the defaults since they
                // should always maintain minDate < maxDate integrity
                
                // correct min/max dates, one day apart
                if (!maxDateChanged)
                    _minDate.time = _maxDate.time - MS_IN_DAY; // min date was changed past max
                else
                    _maxDate.time = _minDate.time + MS_IN_DAY; // max date was changed past min
            }
            
            // check minDate <= selectedDate <= maxDate
            if (!selectedDate || selectedDate.time < minDate.time)
            {
                _selectedDate = minDate;
            }
            else if (selectedDate.time > maxDate.time)
            {
                _selectedDate = maxDate;
            }
            
            minDateChanged = false;
            maxDateChanged = false;
            
            if (minuteStepSizeChanged)
            {
                // verify minutes are a multiple of minuteStepSize
                if (minuteList && ((selectedDate.minutes % minuteStepSize) != 0))
                {
                    _selectedDate.minutes -= (selectedDate.minutes % minuteStepSize);
                    
                    // last adjustment to make sure we didn't accidentally go below minDate
                    if (selectedDate.time < minDate.time)
                        _selectedDate.minutes += minuteStepSize;
                }
                
                minuteStepSizeChanged = false;
            }

            disableInvalidSpinnerValues(selectedDate);
            
            syncSelectedDate = true;
        }
        
        // ==================================================
        // update selections on the lists if necessary
        if (syncSelectedDate)
        {
            updateListsToSelectedDate(listsNewlyCreated);
            syncSelectedDate = false;
        }
        
        if (selectedDateModifiedByUser)
        {
            selectedDateModifiedByUser = false;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        // if locale changed, all date item formats need to be regenerated
        if (styleProp == "locale")
        {
            displayModeChanged = true; // order of lists may be different with new locale
            
            populateYearDataProvider = true;
            populateMonthDataProvider = true;
            populateDateDataProvider = true;
            populateHourDataProvider = true;
            populateMinuteDataProvider = true;
            populateMeridianDataProvider = true;
            
            refreshDateTimeFormatter = true;
            
            syncSelectedDate = true;
            
            longestDateItem = null;
            longestYearItem = null;
            
            invalidateProperties();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Create a list object for the specified date part.
     * 
     *  @param datePart use date part constants, e.g. YEAR_ITEM
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     * 
     */
    protected function createDateItemList(datePart:String, itemIndex:int, itemCount:int):SpinnerList
    {
        // itemIndex and itemCount not used yet; will be used when localization support
        // is put in place, e.g.
        // if itemIndex == 0, align as first column,
        // if itemIndex == itemCount - 1, align as last column
        
        var s:SpinnerList = SpinnerList(createDynamicPartInstance("dateItemList"));
//        s.addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_START, dateItemList_touchEventHandler);
//        s.addEventListener(TouchInteractionEvent.TOUCH_INTERACTION_END, dateItemList_touchEventHandler);
        //      TODO: s.itemRenderer = // ...; for first column (or equivalent)
        return s;
    }
    
    /**
     *  Sets up the date item lists based on the current mode. Clears pre-existing lists.
     * 
     */    
    private function setupDateItemLists():void
    {
        // an array of the list and position objects that will be sorted by position
        var fieldPositionObjArray:ArrayCollection = new ArrayCollection();
        var listSort:ISort = new Sort();
        listSort.fields = [new SortField("position")];
        fieldPositionObjArray.sort = listSort;
        
        // clean out the container and all existing lists
        // they may be in different positions, which will affect how they
        // need to be (re)created
        cleanContainer();
        
        var fieldPosition:int = 0;
        var listItem:Object;
        var tempList:SpinnerList;
        var numItems:int;
        
        // configure the correct lists to use
        if (displayMode == DateSelectorDisplayMode.TIME ||
            displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
        {
            fieldPositionObjArray.addItem(generateFieldPositionObject(HOUR_ITEM, dateTimeFormatterEx.getHourPosition()));
            fieldPositionObjArray.addItem(generateFieldPositionObject(MINUTE_ITEM, dateTimeFormatterEx.getMinutePosition()));
            
            if (displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
                fieldPositionObjArray.addItem(generateFieldPositionObject(DATE_ITEM, dateTimeFormatterEx.getMonthPosition()));
            
            if (!use24HourTime)
                fieldPositionObjArray.addItem(generateFieldPositionObject(MERIDIAN_ITEM, dateTimeFormatterEx.getAmPmPosition()));
            
            // sort fieldPosition objects by position               
            fieldPositionObjArray.refresh();
            
            numItems = fieldPositionObjArray.length;
            
            for each (listItem in fieldPositionObjArray)
            {
                switch(listItem.dateItem)
                {
                    case HOUR_ITEM:
                    {
                        hourList = createDateItemList(HOUR_ITEM, fieldPosition++, numItems);
                        tempList = hourList;
                        break;
                    }
                    case MINUTE_ITEM:
                    {
                        minuteList = createDateItemList(MINUTE_ITEM, fieldPosition++, numItems);
                        tempList = minuteList;
                        break;
                    }
                    case MERIDIAN_ITEM:
                    {
                        meridianList = createDateItemList(MERIDIAN_ITEM, fieldPosition++, numItems);
                        tempList = meridianList;
                        break;
                    }   
                    case DATE_ITEM:
                    {
                        dateList = createDateItemList(DATE_ITEM, fieldPosition++, numItems);
                        dateList.wrapElements = false;
                        tempList = dateList;
                        break;
                    }
                }
                if (tempList && listContainer)
                {
                    tempList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                    listContainer.addElement(tempList);
                }
            }
        }
        else // default case: DATE mode
        {
            fieldPositionObjArray.addItem(generateFieldPositionObject(MONTH_ITEM, dateTimeFormatterEx.getMonthPosition()));
            fieldPositionObjArray.addItem(generateFieldPositionObject(DATE_ITEM, dateTimeFormatterEx.getDayOfMonthPosition()));
            fieldPositionObjArray.addItem(generateFieldPositionObject(YEAR_ITEM, dateTimeFormatterEx.getYearPosition()));
            
            // sort fieldPosition objects by position 
            fieldPositionObjArray.refresh();
            
            numItems = fieldPositionObjArray.length;
            
            for each (listItem in fieldPositionObjArray)
            {
                switch(listItem.dateItem)
                {
                    case MONTH_ITEM:
                    {
                        monthList = createDateItemList(MONTH_ITEM, fieldPosition++, numItems);
                        tempList = monthList;
                        break;
                    }
                    case DATE_ITEM:
                    {
                        dateList = createDateItemList(DATE_ITEM, fieldPosition++, numItems);
                        tempList = dateList;
                        break;
                    }
                    case YEAR_ITEM:
                    {
                        yearList = createDateItemList(YEAR_ITEM, fieldPosition++, numItems);
                        yearList.wrapElements = false;
                        tempList = yearList;
                        break;
                    }   
                }
                if (tempList && listContainer)
                {
                    tempList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                    listContainer.addElement(tempList);                    
                }
            }
        }
    }
    
    /**
     *  Populate the currently existing date item lists with correct data providers using the
     *  provided locale to format the 
     */    
    private function populateDateItemLists(localeStr:String):void
    {
        var today:Date = todayDate;
        
        // populate lists that are being shown
        if (yearList && populateYearDataProvider)
        {
            yearList.dataProvider = new YearProvider(localeStr, minDate.fullYear,
                maxDate.fullYear, today, getStyle("accentColor"));
            
            // set size to longest string
            if (!longestYearItem)
                longestYearItem = findLongestYearItem();
            
            yearList.typicalItem = longestYearItem;
        }
        if (monthList && populateMonthDataProvider)
        {
            monthList.dataProvider = generateMonths(today);
            
            // set size
            monthList.typicalItem = getLongestLabel(monthList.dataProvider);
        }
        if (dateList && populateDateDataProvider)
        {
            if (displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
            {
                dateList.dataProvider = new DateAndTimeProvider(localeStr, minDate, maxDate,
                    today, getStyle("accentColor"));
                
                // set size to longest string
                if (!longestDateItem)
                    longestDateItem = findLongestDateItem();
                
                dateList.typicalItem = longestDateItem;
            }
            else
            {
                dateList.dataProvider = generateMonthOfDates(today);
                
                // set size to width of longest visible value
                dateList.typicalItem = getLongestLabel(dateList.dataProvider);
            }
        }
        if (hourList && populateHourDataProvider)
        {
            hourList.dataProvider = generateHours(use24HourTime);
            hourList.typicalItem = getLongestLabel(hourList.dataProvider);
        }
        if (minuteList && populateMinuteDataProvider)
        {
            minuteList.dataProvider = generateMinutes();
            minuteList.typicalItem = getLongestLabel(minuteList.dataProvider);
        }
        if (meridianList && populateMeridianDataProvider)
        {
            var amObject:Object = generateAmPm(AM);
            var pmObject:Object = generateAmPm(PM);
            meridianList.dataProvider = new ArrayCollection([amObject, pmObject]);
            meridianList.typicalItem = getLongestLabel(meridianList.dataProvider);
        }

        // reset all flags
        populateYearDataProvider = false;
        populateMonthDataProvider = false;
        populateDateDataProvider = false;
        populateHourDataProvider = false;
        populateMinuteDataProvider = false;
        populateMeridianDataProvider = false;
    }
    
    // set the selected index on the SpinnerList. use animation only if the lists
    // were not newly created
    private function goToIndex(list:SpinnerList, newIndex:int, listsCreated:Boolean):void
    {
        listsCreated ? list.selectedIndex = newIndex
            : list.animateToSelectedIndex(newIndex);
    }
    
    // generate objects to populate a SpinnerList with months
    private function generateMonths(today:Date):IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        var todayMonth:int = today.getMonth();
        
        var monthNames:Vector.<String> = dateTimeFormatterEx.getMonthNames();
        
        for (var i:Number = 0; i < 12; i++)
        {
            var item:Object = generateDateItemObject(monthNames[i], i);
            
            if (i == todayMonth)
                item["accentColor"] = getStyle("accentColor");
                
            ac.addItem(item);
        }
        
        return ac;
    }
    
    // generate objects to populate a SpinnerList with dates, e.g. "1, 2, 3, ... 31"
    private function generateMonthOfDates(today:Date):IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        var todayDate:int = today.getDate();
        
        dateTimeFormatter.dateTimePattern = dateTimeFormatterEx.getDayOfMonthPattern();
        
        // guarantee 31 days in the month
        dateObj.time = JAN1980_IN_MS;
        
        for (var i:int = 1; i <= 31; i++)
        {
            dateObj.date = i;
            var item:Object = generateDateItemObject(dateTimeFormatter.format(dateObj), i);

            if (i == todayDate)
                item["accentColor"] = getStyle("accentColor");
        
            ac.addItem(item);
        }
        
        return ac;
    }
    
    // generate hour objects for a SpinnerList
    private function generateHours(use24HourTime:Boolean):IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        
        var minHour:int = use24HourTime ? 0 : 1;
        var maxHour:int = use24HourTime ? 23 : 12;
        
        dateTimeFormatter.dateTimePattern = dateTimeFormatterEx.getHourPattern();
        
        for (var i:int = minHour; i <= maxHour; i++)
        {
            dateObj.hours = i;
            ac.addItem( generateDateItemObject(dateTimeFormatter.format(dateObj), i) );
        }
        
        return ac;
    }
    
    private function generateMinutes():IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        
        dateTimeFormatter.dateTimePattern = dateTimeFormatterEx.getMinutePattern();
        
        for (var i:int = 0; i <= 59; i += minuteStepSize)
        {
            dateObj.minutes = i;
            ac.addItem( generateDateItemObject(dateTimeFormatter.format(dateObj), i) );
        }
        
        return ac;
    }
    
    private function generateAmPm(value:String):Object
    {
        dateTimeFormatter.dateTimePattern = dateTimeFormatterEx.getAmPmPattern();
        
        dateObj.hours = (value == AM)? 1 : 13;
        
        return generateDateItemObject(dateTimeFormatter.format(dateObj), value);
    }

    // TODO: possibly optimize usages and remove this function
    private function findDateItemIndexInDataProvider(item:Number, dataProvider:IList):int
    {
        for (var i:int = 0; i < dataProvider.length; i++)
        {
            if (dataProvider.getItemAt(i).data == item)
                return i;
        }
        return -1;
    }
    
    private function getLongestLabel(list:IList):Object
    {
        var idx:int = -1;
        var maxWidth:int = 0;
        var labelWidth:Number;
        for (var i:int = 0; i < list.length; i++)
        {
            labelWidth = measureText(list[i].label).width;
            if (labelWidth > maxWidth)
            {
                maxWidth = labelWidth;
                idx = i;
            }
        }
        if (idx != -1)
            return list.getItemAt(idx);
        
        return null;
    }
    
    private function updateListsToSelectedDate(listsNewlyCreated:Boolean):void
    {
        var newIndex:int;
        if (yearList)
        {
            dateTimeFormatter.dateTimePattern = dateTimeFormatterEx.getYearPattern();
            newIndex = yearList.dataProvider.getItemIndex( generateDateItemObject(dateTimeFormatter.format(selectedDate), selectedDate.fullYear) );
            goToIndex(yearList, newIndex, listsNewlyCreated);
        }
        
        if (monthList)
            goToIndex(monthList, selectedDate.month, listsNewlyCreated);
        
        if (dateList)
        {
            if (displayMode == DateSelectorDisplayMode.DATE)
            {
                goToIndex(dateList, selectedDate.date - 1, listsNewlyCreated);
            }
            else // DATE_AND_TIME mode
            {
                newIndex = dateList.dataProvider.getItemIndex( generateDateItemObject(dayMonthDateFormatter.format(selectedDate), selectedDate.time) );
                goToIndex(dateList, newIndex, listsNewlyCreated);
            }
        }
        if (hourList)
        {
            // TODO: double-check the math
            newIndex = use24HourTime ? selectedDate.hours : (selectedDate.hours + 11) % 12;
            goToIndex(hourList, newIndex, listsNewlyCreated);
        }
        if (minuteList)
        {
            // TODO: calculate instead of iterate?
            newIndex = findDateItemIndexInDataProvider(selectedDate.minutes, minuteList.dataProvider);
            goToIndex(minuteList, newIndex, listsNewlyCreated);
        }
        if (!use24HourTime && meridianList)
        {
            newIndex = selectedDate.hours < 12 ? 0 : 1;
            goToIndex(meridianList, newIndex, listsNewlyCreated);
        }
        
        dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
    }
    
    // modify existing date item spinner list data providers to mark
    // as disabled any combinations that could result by moving one spinner
    // where the resulting new date would be invalid, either by definition
    // (e.g. Apr 31 is not a valid date) or by limitation (e.g. outside of the
    // range defined by minDate and maxDate)
    private function disableInvalidSpinnerValues(thisDate:Date):void
    {
        var tempDate:Date;
        
        // disable dates in spinners that are invalid (e.g. Apr 31) or fall outside
        // of the min/max date range
        if (dateList)
        {
            if (displayMode == DateSelectorDisplayMode.DATE)
            {
                var listData:IList = dateList.dataProvider;
                tempDate = new Date(thisDate.time);
                
                // run through the entire list of dates and set enabled flags as necessary
                var cd:CalendarDate = new CalendarDate(thisDate);
                var numDaysInMonth:int = cd.numDaysInMonth;
                var listLength:int = listData.length;
                
                var minMonthMatch:Boolean = (tempDate.fullYear == minDate.fullYear
                    && tempDate.month == minDate.month);
                var maxMonthMatch:Boolean = (tempDate.fullYear == maxDate.fullYear
                    && tempDate.month == maxDate.month);
                
                for (var i:int = 0; i < listLength; i++)
                {
                    var curObj:Object = listData[i];
                    
                    // is the date invalid for this month?
                    var newEnabledValue:Boolean = i < numDaysInMonth;
                    
                    if (newEnabledValue && (minMonthMatch || maxMonthMatch)) 
                    {
                        // test for outside min/max range
                        tempDate.date = curObj.data;
                        
                        if (tempDate.time < minDate.time ||
                            tempDate.time > maxDate.time)
                            newEnabledValue = false;
                    }
                    
                    // note this is where future support for more complex unselectable dates could be added
                    
                    if (curObj[SpinnerList.ENABLED_PROPERTY_NAME] != newEnabledValue)
                    {
                        var o:Object = generateDateItemObject(curObj.label, curObj.data, newEnabledValue);
                        o["accentColor"] = curObj["accentColor"];
                        listData[i] = o;
                    }
                }
            }
        }
        
        // disable months that fall outside of the min/max dates
        if (monthList && displayMode == DateSelectorDisplayMode.DATE)
        {
            tempDate = new Date(thisDate.time);
            
            listData = monthList.dataProvider;
            for (i = 0; i < 12; i++)
            {
                newEnabledValue = true;
                
                tempDate.month = i;
                if ((tempDate.fullYear == minDate.fullYear
                    && tempDate.month < minDate.month) ||
                    (tempDate.fullYear == maxDate.fullYear
                        && tempDate.month > maxDate.month))
                    newEnabledValue = false;
                
                curObj = listData[i];
                if (curObj[SpinnerList.ENABLED_PROPERTY_NAME] != newEnabledValue)
                {
                    o = generateDateItemObject(curObj.label, curObj.data, newEnabledValue);
                    o["accentColor"] = curObj["accentColor"];
                    listData[i] = o;
                }
            }
        }
        
        // TODO: if we're using YearRangeList, recreate that to match new dates
    }
    
    // clean out the container: remove all elements, detach event listeners, null out references
    private function cleanContainer():void
    {
        if (listContainer)
            listContainer.removeAllElements();
        
        if (yearList)
        {
            yearList.removeEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
            yearList = null;
        }
        if (monthList)
        {
            monthList.removeEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
            monthList = null;
        }
        if (dateList)
        {
            dateList.removeEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
            dateList = null;
        }
        if (hourList)
        {
            hourList.removeEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
            hourList = null;
        }
        if (minuteList)
        {
            minuteList.removeEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
            minuteList = null;
        }
        if (meridianList)
        {
            meridianList.removeEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
            meridianList = null;
        }
    }
    
    // convenience method to generate the standard object format for data in the list dataproviders
    private function generateDateItemObject(label:String, data:*, enabled:Boolean = true):Object
    {
        var obj:Object = { label:label, data:data };
        obj[SpinnerList.ENABLED_PROPERTY_NAME] = enabled;
        return obj;
    }

    // generate the fieldPosition object that contains the date part name and position based on locale
    private function generateFieldPositionObject(datePart:String, position:int):Object
    {
        var obj:Object = { dateItem:datePart, position:position };
        return obj;
    }
    
    // returns true if any of the lists are currently animating
    private function get spinnersAnimating():Boolean
    {
        if (!listContainer)
            return false;
        
        var len:int = listContainer.numElements;
        for (var i:int = 0; i < len; i++)
        {
            var list:SpinnerList = listContainer.getElementAt(i) as SpinnerList;
            // return true as soon as we have one list still in touch interaction
            if (list && list.scroller && list.scroller.inTouchInteraction)
                return true;
        }
        return false;
    }
    
    // identify the dateList item that has the longest width in DATE_AND_TIME mode    
    private function findLongestDateItem():Object
    {
        updateDayMonthDateFormatter();
        
        dateTimeFormatter.dateTimePattern =  dayMonthDateFormatter.getMonthPattern();
        
        var longestDateItemObj:Object = dateList.dataProvider.getItemAt(0);
        var longestMonth:int = 0;
        var labelWidth:Number = -1;
        var maxWidth:int = 0;
        var dateStr:String;
        dateObj.date = 1;
        
        // find the longest month
        for (var month:int = 0; month < 12; month++)
        {
            dateObj.month = month;
            labelWidth = measureText(dateTimeFormatter.format(dateObj)).width;
            if (labelWidth > maxWidth)
            {
                maxWidth = labelWidth;
                longestMonth = month;
            }
        }
        
        dateObj.month = longestMonth;
        maxWidth = 0;
        
        // find the longest dateList item
        for (var date:int = 1; date <= 31; date++)
        {
            dateObj.date = date;
            dateStr = dayMonthDateFormatter.format(dateObj);
            labelWidth = measureText(dateStr).width;
            if (labelWidth > maxWidth)
            {
                maxWidth = labelWidth;
                // TODO: dateObj.time for second argument?
                longestDateItemObj = generateDateItemObject(dateStr, dateObj.time);
            }
        }
        
        return longestDateItemObj;
    }
    
    // TODO: rename variable names and relocate the function.
    // identify the yearList item that has the longest width in DATE mode 
    // the range of year should be from 1601 to 9999
    private function findLongestYearItem():Object
    {
        // TODO: create functions e.g. getLongestDigit(6) returns the longest digit among 6, 7, 8, 9
        var longestDigitIncludingZero:int;
        var longestDigitExcludingZero:int;
        var longestDigitOf6789:int;
        var longestDigitOf789:int;
        
        var maxWidthForlongestDigitIncludingZero:Number = 0;
        var maxWidthForlongestDigitExcludingZero:Number = 0;
        var maxWidthForlongestDigitOf6789:Number = 0;
        var maxWidthForlongestDigitOf789:Number = 0;
        
        var labelWidth:Number;
        
        // instantiate the number formatter and update its locale
        updateNumberFormatter();
        
        // find the four types of the longest digit 
        for (var i:int = 0; i < 10; i++) 
        {
            labelWidth = measureText(numberFormatter.format(i)).width;
            
            if (labelWidth > maxWidthForlongestDigitIncludingZero)
            {
                maxWidthForlongestDigitIncludingZero = labelWidth;
                longestDigitIncludingZero = i;
            }
            
            if (i >= 1 && labelWidth > maxWidthForlongestDigitExcludingZero)
            {
                maxWidthForlongestDigitExcludingZero = labelWidth;
                longestDigitExcludingZero = i;
            }
            
            if (i >= 6 && labelWidth > maxWidthForlongestDigitOf6789)
            {
                maxWidthForlongestDigitOf6789 = labelWidth;
                longestDigitOf6789 = i;
            }
            
            if (i >= 7 && labelWidth > maxWidthForlongestDigitOf789)
            {
                maxWidthForlongestDigitOf789 = labelWidth;
                longestDigitOf789 = i;
            }
        }
        
        // generate the longest width year
        var longestYear:int = longestDigitExcludingZero * 1000;
        
        if (longestDigitExcludingZero > 1)
            longestYear += longestDigitIncludingZero * 111;
        else // longestDigitExcludingZero == 1
            longestYear += ((longestDigitIncludingZero == 0)? longestDigitOf789 : longestDigitOf6789) * 100 +
                longestDigitIncludingZero * 10 + longestDigitIncludingZero;

        dateObj.fullYear = longestYear;
        dateTimeFormatter.dateTimePattern = dateTimeFormatterEx.getYearPattern();
        return generateDateItemObject(dateTimeFormatter.format(dateObj), longestYear);
    }
    
    // instantiate the number formatter and update its locale property
    private function updateNumberFormatter():void
    {
        if(!numberFormatter)
            numberFormatter = new NumberFormatter();
        
        var localeStr:String = getStyle("locale");
        if (localeStr)
            numberFormatter.setStyle("locale", localeStr);
        else
            numberFormatter.clearStyle("locale");
    }
    
    // instantiate the dayMonthDateFormatter and update its locale property
    private function updateDayMonthDateFormatter():void
    {
        if (!dayMonthDateFormatter)
        {
            dayMonthDateFormatter = new DateTimeFormatterEx();
            dayMonthDateFormatter.dateTimeSkeletonPattern = DateTimeFormatterEx.DATESTYLE_MMMEEEd;
        }
        
        var localeStr:String = getStyle("locale");
        if (localeStr)
            dayMonthDateFormatter.setStyle("locale", localeStr);
        else
            dayMonthDateFormatter.clearStyle("locale");
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //----------------------------------------------------------------------------------------------
    /**
     *  Handles changes in the underlying SpinnerLists; applies them to the selectedDate
     * @param event
     * 
     */ 
    private function dateItemList_changeHandler(event:IndexChangeEvent):void
    {
        if (spinnersAnimating)
        {
            // don't commit any changes until all spinners have come to a stop
            return;
        }
        
        // start with the previous selectedDate
        var newDate:Date = new Date(selectedDate.time);

        var tempDate:Date;
        var cd:CalendarDate;
        
        selectedDateModifiedByUser = true;
        
        var numLists:int = listContainer.numElements;
        var currentList:SpinnerList;
        
        // loop through all lists in the container and adjust selectedDate to their values
        for (var i:int = 0; i < numLists; i++)
        {
            currentList = listContainer.getElementAt(i) as SpinnerList;
            var newValue:* = currentList.selectedItem;
            
            switch (currentList)
            {
                case monthList:
                    // rollback date if past end of month
                    if (dateList)
                    {
                        tempDate = new Date(selectedDate.fullYear, newValue.data, 1);
                        cd = new CalendarDate(tempDate);
                        if (dateList.selectedItem.data > cd.numDaysInMonth)
                            newDate.date = cd.numDaysInMonth;
                    }
                    newDate.month = newValue.data;
                    break;
                case dateList:
                    // for DATE_AND_TIME mode data is a Date.time value
                    if (displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
                    {
                        var spinnerDate:Date = new Date(newValue.data);
                        newDate.fullYear = spinnerDate.fullYear;
                        newDate.month = spinnerDate.month;
                        newDate.date = spinnerDate.date;
                    }
                    else
                    {
                        newDate.date = newValue.data;
                    }
                    break;
                case yearList:
                    // rollback date if past end of month
                    if (dateList)
                    {
                        tempDate = new Date(newValue.data, selectedDate.month, 1);
                        cd = new CalendarDate(tempDate);
                        if (dateList.selectedItem.data > cd.numDaysInMonth)
                            newDate.date = cd.numDaysInMonth;
                    }
                    newDate.fullYear = newValue.data;
                    break;
                case hourList:
                    if (use24HourTime)
                    {
                        newDate.hours = newValue.data;
                    }
                    else
                    {
                        // a little trickier; need to convert to 24-hour time
                        // assumption is that if !use24HourTime, meridianList exists
                        newDate.hours = ((newValue.data + 12) % 12) + (meridianList.selectedItem.data == "pm" ? 12 : 0); 
                    }
                    break;
                case minuteList:
                    newDate.minutes = newValue.data;
                    break;
                case meridianList:
                    if (newValue.data == "am" && newDate.hours > 11)
                        newDate.hours -= 12;
                    else if (newValue.data == "pm" && newDate.hours < 12)
                        newDate.hours += 12;
                    break;
                default:
                    // unknown list; don't know how to handle
                    selectedDateModifiedByUser = false;
                    break;
            }
        }

        selectedDate = newDate;
    }
}
}