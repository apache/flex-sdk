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
    import mx.collections.ArrayCollection;

    [Bindable]
    public class _CompanyVO
    {
        private var _headquarter:_HeadquarterVO;
        private var _headquarterRewritten:Boolean = false;
        private var _originalHeadquarter:_HeadquarterVO;

        public var name:String;
        public var potentialHeadquarters:ArrayCollection;


        public function _CompanyVO(name:String, headquarter:_HeadquarterVO, potentialHeadquarters:ArrayCollection)
        {
            this.name = name;
            this._headquarter = headquarter;
            this._originalHeadquarter = headquarter;
            this.potentialHeadquarters = potentialHeadquarters;
        }

        public function get headquarter():_HeadquarterVO
        {
            return _headquarter;
        }

        public function set headquarter(value:_HeadquarterVO):void
        {
            _headquarterRewritten = true;
            _headquarter = value;
        }

        public function get headquarterRewritten():Boolean
        {
            return _headquarterRewritten;
        }

        public function get originalHeadquarter():_HeadquarterVO
        {
            return _originalHeadquarter;
        }

        public function toString():String
        {
            return "CompanyVO{name=" + String(name) + ", #hqs="+potentialHeadquarters.length+"}";
        }
    }
}
