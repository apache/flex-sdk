////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package spark.components.calendarClasses
{
/**
 *  The DateSelectorMode class defines the valid constant values for the 
 *  <code>displayMode</code> property of the Spark DateSpinner control.
 *  
 *  <p>Use the constants in ActionsScript, as the following example shows: </p>
 *  <pre>
 *    myDateSpinner.mode = DateSelectorMode.DATE_AND_TIME;
 *  </pre>
 *
 *  <p>In MXML, use the String value of the constants, 
 *  as the following example shows:</p>
 *  <pre>
 *    &lt;s:DateSpinner id="mySpinner" 
 *        displayMode="dateAndTime"&gt; 
 *        ...
 *    &lt;/s:DateSpinner&gt; 
 *  </pre>
 * 
 *  @see spark.components.DateSpinner
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.6
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
     *  @productversion Flex 4.6
     */
    public static const DATE:String = "date";
    
    /**
     *  Show selection options for time.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const TIME:String = "time";
    
    /**
     *  Show selection options for both date and time.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const DATE_AND_TIME:String = "dateAndTime";    
}
}