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
package mx.utils {
    public class VectorUtil {
        /**
         *  Given a Vector, returns the value of the first item,
         *  or -1 if there are no items in the Vector;
         */
        public static function getFirstItem(v:Vector.<int>):int
        {
            return v && v.length ? v[0] : -1;
        }

        public static function toArrayInt(v:Vector.<int>):Array
        {
            return v ? VectorToArray(v) : [];
        }

        public static function toArrayObject(v:Vector.<Object>):Array
        {
            return v ? VectorToArray(v) : [];
        }

        private static function VectorToArray(v:Object):Array
        {
            //this function assumes that v is a Vector!
            var result:Array = [];
            for (var i:int = 0; i < v.length; i++)
            {
                result.push(v[i]);
            }

            return result;
        }
    }
}
