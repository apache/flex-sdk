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
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.resources.Locale;

import spark.components.supportClasses.SkinnableComponent;
import spark.events.IndexChangeEvent;
import spark.formatters.DateTimeFormatter;

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
[Event(name="change", type="flex.events.Event")]

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
 *  undefined, it inherits from the global <code>locale</code> style.
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
    private static const DEFAULT_DATE_RANGE:int = 200;
    
    private static const MS_IN_DAY:Number = 1000 * 60 * 60 * 24;
    
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
    private var dateTimeFormatter:DateTimeFormatter = new DateTimeFormatter();
    
    private var use24HourTime:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="true")]
    /**
     *  The default factory for creating SpinnerList interfaces for all fields.
     *  This is used by createDateItemList().
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var dateItemList:IFactory;
    
    [SkinPart(required="true")] // TODO: ask Glenn if can use required=true 
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
    
    // default value is DATE
    private var _displayMode:String;
    
    // set to true initially so lists will be created
    private var displayModeChanged:Boolean = true;
    
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
        
        syncSelectedDate = true; // force lists to spin to selected date
        
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
     * Minute interval to be used when displaying minutes. Only
     * applicable in TIME and DATEANDTIME modes. Valid values must
     * be evenly divisible into 60; invalid values will revert to
     * the default interval of 1. For example, a value of "15" will show
     * the values 0, 15, 30, 45.
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
    private var _selectedDate:Date = new Date();
    
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
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        use24HourTime = false; // TODO: determine 24-hour time here from Masa's libraries
        
        var listsCreated:Boolean = false;
        
        // ==================================================
        // switch out lists if the display mode changed
        if (displayModeChanged)
        {
            // clean out the container and all existing lists
            // they may be in different positions, which will affect how they
            // need to be (re)created
            cleanContainer();
            
            // configure the correct lists to use
            if (displayMode == DateSelectorDisplayMode.TIME ||
                displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
            {
                // number of items shown depends on 24 hour time, e.g. meridian list
                var numItems:int = use24HourTime ? 2 : 3;
                var fieldPosition:int = 0;
                
                if (displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
                {
                    // add date field first; increases the number of lists to show
                    numItems = use24HourTime ? 3 : 4;
                    
                    dateList = createDateItemList(DATE_ITEM, fieldPosition++, numItems);
                    dateList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                    dateList.wrapElements = false;
                    listContainer.addElement(dateList);
                }
                
                // create components for hours and minutes
                hourList = createDateItemList(HOUR_ITEM, fieldPosition++, numItems); // TODO: ordinal from locale?
                hourList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                listContainer.addElement(hourList);
                
                minuteList = createDateItemList(MINUTE_ITEM, fieldPosition++, numItems); // TODO: ordinal from locale?
                minuteList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                listContainer.addElement(minuteList);
                
                if (!use24HourTime)
                {
                    meridianList = createDateItemList(MERIDIAN_ITEM, fieldPosition++, numItems); // TODO: ordinal from locale?
                    meridianList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                    listContainer.addElement(meridianList);
                }
            }
            else // default case: DATE mode
            {
                // create components
                monthList = createDateItemList(MONTH_ITEM, 0, 3); // TODO: ordinal from locale
                dateList = createDateItemList(DATE_ITEM, 1, 3); // TODO: ordinal from locale
                yearList = createDateItemList(YEAR_ITEM, 2, 3); // TODO: ordinal from locale
                
                // set item renderers prototype
                //                yearList.itemRenderer = new ClassFactory(DefaultDateSpinnnerItemRendererThingy);
                
                // add listeners
                monthList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                dateList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                yearList.addEventListener(IndexChangeEvent.CHANGE, dateItemList_changeHandler);
                
                // TODO: determine order from locale -- use addElementAt(...)
                listContainer.addElement(monthList);
                listContainer.addElement(dateList);
                listContainer.addElement(yearList);
            }
            
            displayModeChanged = false;
            listsCreated = true;
        }
        
        // ==============================
        
        // TODO: CHECK ON THIS ASSUMPTION
        // TODO: Jason says this is wrong; just use styleName = DateSpinner to link styles
        //       but having trouble getting that to work
        var localeStr:String = getStyle("locale");
        if (refreshDateTimeFormatter)
        {
            if (localeStr)
                dateTimeFormatter.setStyle("locale", localeStr);
            else
                dateTimeFormatter.clearStyle("locale");
            
            refreshDateTimeFormatter = false;
        }
      
		// ==================================================
        // populate lists that are being shown
        if (yearList && populateYearDataProvider)
        {
            yearList.dataProvider = generateYears();
            //			yearList.dataProvider = new YearRangeList(localeStr, minDate.fullYear, maxDate.fullYear);
            populateYearDataProvider = false;
            
            yearList.typicalItem = getLongestLabel(yearList.dataProvider);
        }
        if (monthList && populateMonthDataProvider)
        {
            monthList.dataProvider = generateMonths();
            populateMonthDataProvider = false;
            
            // set size
            monthList.typicalItem = getLongestLabel(monthList.dataProvider);
        }
        if (dateList && populateDateDataProvider)
        {
            if (displayMode == DateSelectorDisplayMode.DATE_AND_TIME)
            {
                dateList.dataProvider = new DateAndTimeRangeList(minDate, maxDate,
                    localeStr, new Date(), getStyle("accentColor"));
                
                // set size to longest string
                dateList.typicalItem = {label:"Wed May 31"}; // TODO: localize? better way to do this? add a dot? ask Masa
            }
            else
            {
                dateList.dataProvider = generateMonthOfDates();
                
                // set size to width of longest visible value
                dateList.typicalItem = getLongestLabel(dateList.dataProvider);
            }
            
            populateDateDataProvider = false;
        }
        if (hourList && populateHourDataProvider)
        {
            hourList.dataProvider = generateHours(use24HourTime);
            hourList.typicalItem = getLongestLabel(hourList.dataProvider);
            populateHourDataProvider = false;
        }
        if (minuteList && populateMinuteDataProvider)
        {
            minuteList.dataProvider = generateMinutes();
            minuteList.typicalItem = getLongestLabel(minuteList.dataProvider);
            populateMinuteDataProvider = false;
        }
        if (meridianList && populateMeridianDataProvider)
        {
            // TODO: replace with localized version, probably break out into function
            var amObject:Object = generateDateItemObject("AM", "am");
            var pmObject:Object = generateDateItemObject("PM", "pm");
            meridianList.dataProvider = new ArrayCollection([amObject, pmObject]);
            meridianList.typicalItem = getLongestLabel(meridianList.dataProvider);
            populateMeridianDataProvider = false;
        }
        
        // ==================================================
        
        // correct any integrity violations
        if (minDateChanged || maxDateChanged || syncSelectedDate || listsCreated || minuteStepSizeChanged)
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
                selectedDate = minDate;
            else if (selectedDate.time > maxDate.time)
                selectedDate = maxDate;
            
            minDateChanged = false;
            maxDateChanged = false;
            
            // verify minutes are a multiple of minuteStepSize
            if (minuteList && selectedDate.minutes % minuteStepSize != 0)
            {
                selectedDate.minutes -= selectedDate.minutes % minuteStepSize;
                
                // last adjustment to make sure we didn't accidentally go below minDate
                if (selectedDate.time < minDate.time)
                    selectedDate.minutes += minuteStepSize;
            }
            
            disableInvalidSpinnerValues(selectedDate);
        }
        
        // ==================================================
        // update selections on the lists if necessary
        if (syncSelectedDate)
        {
            var newIndex:int;
            if (yearList)
            {
                // TODO: use math for the year instead of iterating through each one; remove that function
                newIndex = findDateItemIndexInDataProvider(selectedDate.fullYear, yearList.dataProvider);
                goToIndex(yearList, newIndex, listsCreated);
            }

            if (monthList)
                goToIndex(monthList, selectedDate.month, listsCreated);
            
            if (dateList)
            {
                if (displayMode == DateSelectorDisplayMode.DATE)
                {
                    goToIndex(dateList, selectedDate.date - 1, listsCreated);
                }
                else // DATE_AND_TIME mode
                {
                    newIndex = findDateIndex(selectedDate, dateList.dataProvider);
                    goToIndex(dateList, newIndex, listsCreated);
                }
            }
            if (hourList)
            {
                // TODO: double-check the math
                newIndex = use24HourTime ? selectedDate.hours : (selectedDate.hours + 11) % 12;
                goToIndex(hourList, newIndex, listsCreated);
            }
            if (minuteList)
            {
                // TODO: calculate instead of iterate?
                newIndex = findDateItemIndexInDataProvider(selectedDate.minutes, minuteList.dataProvider);
                goToIndex(minuteList, newIndex, listsCreated);
            }
            if (!use24HourTime && meridianList)
            {
                newIndex = selectedDate.hours < 12 ? 0 : 1;
                goToIndex(meridianList, newIndex, listsCreated);
            }
            
            dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
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
        var s:SpinnerList = SpinnerList(createDynamicPartInstance("dateItemList"));
        return s;
    }
    
    // set the selected index on the SpinnerList. use animation only if the lists
    // were not newly created
    private function goToIndex(list:SpinnerList, newIndex:int, listsCreated:Boolean):void
    {
        listsCreated ? list.selectedIndex = newIndex
            : list.animateToSelectedIndex(newIndex);
    }
    
    // generate objects to populate a SpinnerList with years
    private function generateYears():IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        
        var dtf:DateTimeFormatter = dateTimeFormatter;
        dtf.dateTimePattern = "yyyy"; // TODO: this will need to be localized
        var d:Date = new Date(0);
		var today:Date = new Date();
		
        for (var i:Number = minDate.fullYear; i <= maxDate.fullYear; i++)
        {
            d.fullYear = i;
            var item:Object = generateDateItemObject(dtf.format(d), i);
			
			if(i == today.getFullYear())
				item["accentColor"] = getStyle("accentColor");
			
            ac.addItem(item);
        }
        
        return ac;
    }
    
    // generate objects to populate a SpinnerList with months
    private function generateMonths():IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        
        var dtf:DateTimeFormatter = dateTimeFormatter;
        dtf.dateTimePattern = "MMMM";
        
        var d:Date = new Date(1980, 0, 1, 0, 1);
		var today:Date = new Date();
		 
        for (var i:Number = 0; i < 12; i++)
        {
            d.month = i;
            var item:Object = generateDateItemObject(dtf.format(d), i);
			
			if(i == today.getMonth())
				item["accentColor"] = getStyle("accentColor");
				
            ac.addItem(item);
        }
        
        return ac;
    }
    
    // generate objects to populate a SpinnerList with dates, e.g. "1, 2, 3, ... 31"
    private function generateMonthOfDates():IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        
        var dtf:DateTimeFormatter = dateTimeFormatter;
        dtf.dateTimePattern = "d";
        
        // choosing January 1980 to guarantee 31 days in the month
        var d:Date = new Date(1980, 0, 1, 0, 1, 0, 0);
		var today:Date = new Date();
		 
        for (var i:int = 1; i <= 31; i++)
        {
            d.date = i;
            var item:Object = generateDateItemObject(dtf.format(d), i);
			
			if(i == today.getDate())
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
        
        for (var i:int = minHour; i <= maxHour; i++)
        {
            // TODO: localize?
            ac.addItem( generateDateItemObject(String(i), i) );
        }
        
        return ac;
    }
    
    private function generateMinutes():IList
    {
        var ac:ArrayCollection = new ArrayCollection();
        
        for (var i:int = 0; i <= 59; i += minuteStepSize)
        {
            // TODO: localize?
            ac.addItem( generateDateItemObject(i < 10 ? "0" + i : String(i), i));
        }
        
        return ac;
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
                    
                    if (curObj.enabled != newEnabledValue)
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
            for (i = 0; i < 11; i++)
            {
                newEnabledValue = true;
                
                tempDate.month = i;
                if ((tempDate.fullYear == minDate.fullYear
                    && tempDate.month < minDate.month) ||
                    (tempDate.fullYear == maxDate.fullYear
                        && tempDate.month > maxDate.month))
                    newEnabledValue = false;
                
                curObj = listData[i];
                if (curObj.enabled != newEnabledValue)
                {
                    o = {data:curObj.data, label:curObj.label, enabled:newEnabledValue};
					o["accentColor"] = curObj["accentColor"];
                    listData[i] = o;
                }
            }
        }
        
        // TODO: if we're using YearRangeList, recreate that to match new dates
    }
    
    private function findDateIndex(selectedDate:Date, dateList:IList):int
    {
        // index is how many days between the selected date and the first date
        var firstDate:Date = new Date(dateList.getItemAt(0).data);
        
        // set firstDate's hour/min/second to the same values
        firstDate.hours = selectedDate.hours;
        firstDate.minutes = selectedDate.minutes;
        firstDate.seconds = selectedDate.seconds;
        firstDate.milliseconds = selectedDate.milliseconds;
        
        var diff:Number = selectedDate.time - firstDate.time;
        var days:int = diff / MS_IN_DAY;
        
        return days;
    }
    
    // clean out the container: remove all elements detach event listeners, null out
    private function cleanContainer():void
    {
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
    
    private function generateDateItemObject(label:String, data:*, enabled:Boolean = true):Object
    {
        var obj:Object = { label:label, data:data, enabled:enabled };
        return obj;
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
        var newDate:Date = new Date(selectedDate.time);
        
        var newValue:* = SpinnerList(event.target).selectedItem;
        
        var tempDate:Date;
        var cd:CalendarDate;
        
        selectedDateModifiedByUser = true;
        
        switch (event.target)
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
        selectedDate = newDate;
    }
    
}
}