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
/**
 *  The DateSelectorMode class defines the valid constant values for the 
 *  <code>mode</code> property of the Spark DateChooser and DateSpinner controls.
 *  
 *  <p>Use the constants in ActionsScript, as the following example shows: </p>
 *  <pre>
 *    myDateChooser.mode = DateSelectorMode.DATE_AND_TIME;
 *  </pre>
 *
 *  <p>In MXML, use the String value of the constants, 
 *  as the following example shows:</p>
 *  <pre>
 *    &lt;s:DataChooser id="myChooser" 
 *        mode="dateAndTime"&gt; 
 *        ...
 *    &lt;/s:DataChooser&gt; 
 *  </pre>
 * 
 *  @see spark.components.DateChooser#mode
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.5.2
 */
public final class DateSelectorDisplayMode
{
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3.0
     *  @productversion Flex 5.0
     */
    public function DateSelectorDisplayMode()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Show selection options for date.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public static const DATE:String = "date";
    
    /**
     *  Show selection options for time.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public static const TIME:String = "time";
    
    /**
     *  Show selection options for both date and time.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public static const DATE_AND_TIME:String = "dateAndTime";    
}
}