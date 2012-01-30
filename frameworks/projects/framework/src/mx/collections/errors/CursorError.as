
package mx.collections.errors
{

/**
 *  This error is thrown by a collection Cursor.
 *  Errors of this class are thrown by classes
 *  that implement the IViewCursor interface.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class CursorError extends Error
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    // Constructor.
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param message A message providing information about the error cause.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function CursorError(message:String)
    {
        super(message);
    }
}

}
