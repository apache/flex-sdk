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
 *  The ContentBackgroundAppearance class defines the constants for the
 *  allowed values of the <code>contentBackgroundAppearance</code> style of 
 *  Callout.
 * 
 *  @see spark.components.Callout#style:contentBackgroundAppearance
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public final class ContentBackgroundAppearance
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Applies a shadow and mask to the contentGroup.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const INSET:String = "inset";
    
    /**
     *  Applies mask to the contentGroup.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const FLAT:String = "flat";
    
    /**
     *  Disables both the <code>contentBackgroundColor</code> style and
     *  contentGroup masking. Use this value when Callout's contents should
     *  appear directly on top of the <code>backgroundColor</code> or when
     *  contents provide their own masking. 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public static const NONE:String = "none";
}
}