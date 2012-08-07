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
package data {

    public class NameDataAS  {
    
        public var myData:Object;
        public function NameDataAS(): void
        {
            
            myData = [
                        { name: "Person A",
                            cdata: true,
                            phone: "999-555-6589",
                            image: "../../../Assets/products/putty.jpg"},
                        { name: "Person B",
                             cdata: false,
                             phone: "999-555-3353",
                             image: "../../../Assets/products/putty.jpg"},
                        { name: "Person C",
                             cdata: true,
                             phone: "999-555-2453",
                             image: "../../../Assets/products/putty.jpg"},
                        { name: "Person D",
                             cdata: false,
                             phone: "999-555-6549",
                             image: "../../../Assets/products/putty.jpg"}
                     ];
        }
    }
}