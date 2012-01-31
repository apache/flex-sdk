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

/**
 *  Specifies the alpha transparency value of the focus skin.
 *  
 *  The default value for the Halo theme is <code>0.4</code>.
 *  The default value for the Spark theme is <code>0.55</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="focusAlpha", type="Number", inherit="no")]

/**
 *  Specifies which corners of the focus rectangle should be rounded.
 *  This value is a space-separated String that can contain any
 *  combination of <code>"tl"</code>, <code>"tr"</code>, <code>"bl"</code>
 *  and <code>"br"</code>.
 *  For example, to specify that the right side corners should be rounded,
 *  but the left side corners should be square, use <code>"tr br"</code>.
 *  The <code>cornerRadius</code> style property specifies
 *  the radius of the rounded corners.
 *  The default value depends on the component class; if not overridden for
 *  the class, default value is <code>"tl tr bl br"</code>.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="focusRoundedCorners", type="String", inherit="no")]
