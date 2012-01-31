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
/**
 *  The DisplayObjectSharingMode class defines the possible values for the 
 *  <code>displayObjectSharingMode</code> property of the IGraphicElement class.
 * 
 *  @see IGraphicElement#displayObjectSharingMode
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class DisplayObjectSharingMode
{   
    /**
     *  IGraphicElement owns a DisplayObject exclusively.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OWNS_UNSHARED_OBJECT:String = "ownsUnsharedObject";
    
    /**
     *  IGraphicElement owns a DisplayObject that is also
     *  assigned to some other IGraphicElement by the parent
     *  Group container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const OWNS_SHARED_OBJECT:String = "ownsSharedObject";
    
    /**
     *  IGraphicElement is assigned a DisplayObject by
     *  its parent Group container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const USES_SHARED_OBJECT:String = "usesSharedObject";
}
}
