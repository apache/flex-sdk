
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
