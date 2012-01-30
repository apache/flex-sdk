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
 *  the AdvancedDataGridColumn.
 *
 *  @see mx.controls.advancedDataGridClasses#formatter
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
*/
public interface IFormatter
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  error
    //----------------------------------

    /**
     *  Description saved by the formatter when an error occurs.
     *  For the possible values of this property,
     *  see the description of each formatter.
     *  <p>Classes that implement this interface must set this value
     *  in the <code>format()</code> method.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    // TODO Do we need to include this in the interface?
    //public var error:String;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Formats a value and returns a String
     *  containing the new, formatted, value.
     *
     *  @param value Value to be formatted.
     *
     *  @return The formatted string.
     *
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4.5
     */
    function format(value:Object):String;
}
}
