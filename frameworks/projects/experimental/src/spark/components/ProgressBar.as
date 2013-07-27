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
package spark.components {
    import flash.utils.getQualifiedClassName;

    import mx.core.IFlexModuleFactory;
    import mx.core.IVisualElement;
    import mx.events.PropertyChangeEvent;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.IStyleManager2;
    import mx.styles.StyleManager;

    import spark.skins.ProgressBarSkin;

    import spark.components.supportClasses.SkinnableComponent;
    import spark.core.IDisplayText;

    /**
     * Plain and simple progress bar
     *
     * @author Bogdan Dinu (http://www.badu.ro)
     */
    public class ProgressBar extends SkinnableComponent {
        [SkinPart(required="false")]
        public var progressGroup:IVisualElement;

        [SkinPart(required="false")]
        public var percentDisplay:IDisplayText;

        public function ProgressBar() {
            super();
        }

        /**
         *
         **/
        [Inspectable(enumeration="left,right", defaultValue="right")]
        protected var _direction:String;

        public function get direction():String {
            return _direction;
        }

        [Bindable(event="propertyChange")]
        public function set direction(value:String):void {
            if (_direction !== value) {
                var oldValue:String = _direction;
                _direction = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "direction", oldValue, value));
                }
            }
        }

        /**
         * totalProgress
         **/
        private var _totalProgressUpdated:Boolean = false;
        protected var _totalProgress:Number;

        public function get totalProgress():Number {
            return _totalProgress;
        }

        [Bindable(event="propertyChange")]
        public function set totalProgress(value:Number):void {
            if (_totalProgress !== value) {
                var oldValue:Number = _totalProgress;
                _totalProgress = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "totalProgress", oldValue, value));
                }
                _totalProgressUpdated = true;
                invalidateProperties();
            }
        }

        /**
         *  currentProgress property
         **/
        private var _currentProgressUpdated:Boolean;
        protected var _currentProgress:Number;

        public function get currentProgress():Number {
            return _currentProgress;
        }

        [Bindable(event="propertyChange")]
        public function set currentProgress(value:Number):void {
            if (_currentProgress !== value) {
                var oldValue:Number = _currentProgress;
                _currentProgress = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "currentProgress", oldValue, value));
                }
                _currentProgressUpdated = true;
                invalidateProperties();
            }
        }

        /**
         * if you don't want percents, set this to false
         **/
        protected var _displayPercents:Boolean = true;

        public function get displayPercents():Boolean {
            return _displayPercents;
        }

        [Bindable(event="propertyChange")]
        public function set displayPercents(value:Boolean):void {
            if (_displayPercents !== value) {
                var oldValue:Boolean = _displayPercents;
                _displayPercents = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "displayPercents", oldValue, value));
                }
            }
        }

        /**
         * Suffix that is added, in case you don't use percents
         * Example : "bytes" , will display "33 / 100000 bytes"
         **/
        protected var _suffix:String = "";

        public function get suffix():String {
            return _suffix;
        }

        [Bindable(event="propertyChange")]
        public function set suffix(value:String):void {
            if (_suffix !== value) {
                var oldValue:String = _suffix;
                _suffix = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "suffix", oldValue, value));
                }
            }
        }

        /**
         * In case you want to use your own label function
         * which will override any suffix or display percents properties
         **/
        protected var _labelFunction:Function;

        public function get labelFunction():Function {
            return _labelFunction;
        }

        [Bindable(event="propertyChange")]
        public function set labelFunction(value:Function):void {
            if (_labelFunction !== value) {
                var oldValue:Function = _labelFunction;
                _labelFunction = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "labelFunction", oldValue, value));
                }
            }
        }

        /**
         //--------------------------------------------------------------------------
         //  Methods
         //--------------------------------------------------------------------------
         **/
        protected function updateProgressBox():void {
            if (progressGroup) {
                progressGroup.percentWidth = (_currentProgress / _totalProgress) * 100;
            }

            if (_labelFunction != null) {
                _labelFunction();
            } else {
                if (percentDisplay) {
                    if (_displayPercents) {
                        percentDisplay.text = Math.floor((_currentProgress / _totalProgress) * 100).toString() + "%";
                    } else {
                        percentDisplay.text = _currentProgress.toFixed(0) + " / " + _totalProgress.toFixed(0) + _suffix;
                    }
                }
            }
        }

        /**
         //--------------------------------------------------------------------------
         //  Overriden methods
         //--------------------------------------------------------------------------
         */
        override protected function commitProperties():void {
            super.commitProperties();
            if (_currentProgressUpdated || _totalProgressUpdated) {
                updateProgressBox();
                _currentProgressUpdated = false;
                _totalProgressUpdated = false;
            }
        }

        override protected function partAdded(partName:String, instance:Object):void {
            super.partAdded(partName, instance);
            if (instance == progressGroup || instance == percentDisplay) {
                updateProgressBox();
            }
        }

        override protected function partRemoved(partName:String, instance:Object):void {
            super.partRemoved(partName, instance);
        }
    }
}
