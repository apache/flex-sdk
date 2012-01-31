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
 *  This class specifies the allowed values for the
 *  <code>selectionHighlighting</code> property
 *  of the RichEditableText control, and controls that use
 *  RichEditableText as a subcomponent (Spark TextInput and Spark TextArea).
 *  
 *  @see spark.components.RichEditableText
 *  @see spark.components.TextArea
 *  @see spark.components.TextInput
 *
 *  @includeExample TraceSelectionRanges
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class TextSelectionHighlighting
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  Always show the text selection, even if the component
     *  doesn't have the keyboard focus or if the component's window
     *  isn't the active window.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const ALWAYS:String = "always";

    /**
     *  Show the text selection whenever the component's window is active,
     *  even if the component doesn't have the keyboard focus.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const WHEN_ACTIVE:String = "whenActive";

    /**
     *  Show the text selection only when the component has keyboard focus.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const WHEN_FOCUSED:String = "whenFocused";
}

}
