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
						{ Artist:'ArtistA', Album:'Album A', Price:11.99, Available: true },
						{ Artist:'ArtistA', Album:'Album B', Price:10.99, Available: false },
						{ Artist:'ArtistA', Album:'Album C', Price:12.99, Available: true },
						{ Artist:'ArtistA', Album:'Album D', Price:11.99, Available: true },
						{ Artist:'ArtistA', Album:'Album G', Price:11.99, Available: true },
						{ Artist:'Other', Album:'Other', Price:5.99, Available: false },
						{ Artist:'ArtistB', Album:'Album H', Price:6.99, Available: false },
						{ Artist:'ArtistC', Album:'Album J', Price:8.99, Available: true },
						{ Artist:'ArtistD', Album:'Album K', Price:16.99, Available: false },
                     ];
        }
    }
}