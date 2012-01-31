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

package spark.core
{
	
import flash.events.IEventDispatcher;
import spark.core.ContentRequest;

/**
 *  Provides custom image/content loader for BitmapImage instances.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public interface IContentLoader extends IEventDispatcher
{
    /**
     *  Initiates a content request for the resource identified
     *  by the key specified.
     *
     *  @param source Unique key used to represent the requested content resource. 
     *  This parameter is typically an URL or URLRequest.
     *
     *  @param contentLoaderGrouping - (Optional) grouping identifier for the loaded resource.
     *  ContentLoader instances supporting content groups generally allow for 
     *  resources within the same named grouping to be addressed as a whole. For 
     *  example the ContentCache's loader queue allows requests to be prioritized
     *  by contentLoaderGrouping.  
     *
     *  @return A ContentRequest instance representing the requested resource.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    function load(source:Object, contentLoaderGrouping:String=null):ContentRequest;       
}
}
