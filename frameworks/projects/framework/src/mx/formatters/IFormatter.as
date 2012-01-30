////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.formatters
{

/**
 *  This interface specifies the method that a formatter object must implement
 *  to allow it to be used as the formatter property for UI controls such as
 *  the <code>AdvancedDataGridColumn</code>.
 *
 *  @see mx.controls.advancedDataGridClasses#formatter
 *
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
*/
public interface IFormatter
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Formats a value and returns a <code>String</code>
     *  containing the new formatted value.
     *
     *  @param value Value to be formatted.
     *
     *  @return The formatted string.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    function format(value:Object):String;
}
}
