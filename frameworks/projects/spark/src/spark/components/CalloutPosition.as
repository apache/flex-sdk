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

package spark.components
{

/**
 *  The CalloutPosition calss defines the enumeration of 
 *  horizontal and vertical positions of the Callout component
 *  relative to the owner.
 * 
 *  @see spark.components.Callout
 *  @see spark.components.Callout#horizontalPosition
 *  @see spark.components.Callout#verticalPosition
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public final class CalloutPosition
{
    
    /**
     *  Position the trailing edge of the callout before the leading edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const BEFORE:String = "before";
    
    /**
     *  Position the leading edge of the callout at the leading edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const START:String = "start";
    
    /**
     *  Position the horizontalCenter of the callout to the horizontalCenter of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const MIDDLE:String = "middle";
    
    /**
     *  Position the trailing edge of the callout at the trailing edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const END:String = "end";
    
    /**
     *  Position the leading edge of the callout after the trailing edge of the owner.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const AFTER:String = "after";
    
    /**
     *  Position the callout on the exterior of the owner where the callout 
     *  requires the least amount of resizing to fit.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const AUTO:String = "auto";
    
}

}