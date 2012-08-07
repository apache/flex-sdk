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

    public class DaysDataAS  {
    
        public var myData:Object;
        public function DaysDataAS(): void
        {
            
            myData =  [
			   { Monday: 9, Tuesday: 3, Wednesday: 4, Thursday: 10 },
			   { Monday: 7, Tuesday: 9, Wednesday: 8, Thursday: 0 },
			   { Monday: 1, Tuesday: 10, Wednesday: 4, Thursday: 1 },
			   { Monday: 10, Tuesday: 3, Wednesday: 1, Thursday: 4 },
			   { Monday: 9, Tuesday: 8, Wednesday: 0, Thursday: 5 },
			   { Monday: 5, Tuesday: 10, Wednesday: 4, Thursday: 5 },
			   { Monday: 4, Tuesday: 3, Wednesday: 9, Thursday: 10 }
           ];
        }
    }
}