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

    public class AlbumDataAS  {
    
        public var myData:Object;
        public function AlbumDataAS(): void
        {
            
            myData = [
						{ Artist:'Pavement', Album:'Slanted and Enchanted', Price:11.99, Available: true },
						{ Artist:'Pavement', Album:'Crooked Rain, Crooked Rain', Price:10.99, Available: false },
						{ Artist:'Pavement', Album:'Wowee Zowee', Price:12.99, Available: true },
						{ Artist:'Pavement', Album:'Brighten the Corners', Price:11.99, Available: true },
						{ Artist:'Pavement', Album:'Terror Twilight', Price:11.99, Available: true },
						{ Artist:'Other', Album:'Other', Price:5.99, Available: false },
						{ Artist:'Britney Spears', Album:'Britney', Price:6.99, Available: false },
						{ Artist:'Faith Hill', Album:'Cry', Price:8.99, Available: true },
						{ Artist:'ColdPlay', Album:'Parachuttes', Price:16.99, Available: false },
                     ];
        }
    }
}