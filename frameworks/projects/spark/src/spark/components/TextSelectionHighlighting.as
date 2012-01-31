////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
