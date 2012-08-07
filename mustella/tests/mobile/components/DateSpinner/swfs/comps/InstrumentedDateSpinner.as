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
package comps
{
    import flash.events.Event;
    
    import mx.core.IVisualElement;
    import mx.events.DragEvent;
    
    import spark.components.DateSpinner;
    import spark.components.SpinnerList;
    
    /**
    * A simple subclass of DateSpinner that allows QE access
    * to otherwise protected methods to target individual
    * spinners within a DateSpinner for test automation.
    */
    public class InstrumentedDateSpinner extends DateSpinner
    {
        /** Gets the SpinnerList that holds the months */
        public function getMonthSpinner():spark.components.SpinnerList
        {
            return monthList;
        }
        
        /** Gets the SpinnerList that holds the days */
        public function getDateSpinner():spark.components.SpinnerList
        {
            return dateList;
        }
        
        /** Gets the SpinnerList that holds the years */
        public function getYearSpinner():spark.components.SpinnerList
        {
            return yearList;
        }
        
        /** Gets the SpinnerList that holds the hours */
        public function getHourSpinner():spark.components.SpinnerList
        {
            return hourList;
        }
        
        /** Gets the SpinnerList that holds the minutes */
        public function getMinuteSpinner():spark.components.SpinnerList
        {
            return minuteList;
        }
        
        /** Gets the SpinnerList that holds the meridian */
        public function getMeridianSpinner():spark.components.SpinnerList
        {
            return meridianList;
        }
        
        /**
         * Given a SpinnerList and an offset from the selectedIndex this method returns
         * the item renderer.
         * 
         * @param spinnerList - the spinner to click on (ex: month)
         * @param offset - the offset from the current selectedIndex (ex: 0)
         */
        private function getRendererTarget(spinnerList:spark.components.SpinnerList, offset:int):IVisualElement
        {
            // return null when a negative index is requested and not possible
            if (offset < 0 && spinnerList.wrapElements == false)
                return null;
            
            // return null when the offset is too large
            if (offset >= spinnerList.dataGroup.numElements)
                return null;
            
            // start at the offset of the current selected index
            offset += spinnerList.selectedIndex;
            
            // then adjust for wrapping
            offset %= spinnerList.dataGroup.numElements;
            if (offset < 0)
                offset += spinnerList.dataGroup.numElements;
            
            return spinnerList.dataGroup.getElementAt(offset);
        }
        
        /** Gets the item renderer of the month spinner  */
        public function getMonthRenderer(offset:int):IVisualElement
        {
            return getRendererTarget(getMonthSpinner(), offset);
        }

        /** Gets the item renderer of the date spinner  */
        public function getDateRenderer(offset:int):IVisualElement
        {
            return getRendererTarget(getDateSpinner(), offset);
        }
        
        /** Gets the item renderer of the year spinner  */
        public function getYearRenderer(offset:int):IVisualElement
        {
            return getRendererTarget(getYearSpinner(), offset);
        }
        
        /** Gets the item renderer of the hour spinner  */
        public function getHourRenderer(offset:int):IVisualElement
        {
            return getRendererTarget(getHourSpinner(), offset);
        }
        
        /** Gets the item renderer of the minute spinner  */
        public function getMinuteRenderer(offset:int):IVisualElement
        {
            return getRendererTarget(getMinuteSpinner(), offset);
        }
        
        /** Gets the item renderer of the meridian spinner  */
        public function getMeridianRenderer(offset:int):IVisualElement
        {
            return getRendererTarget(getMeridianSpinner(), offset);
        }
        
    }
}