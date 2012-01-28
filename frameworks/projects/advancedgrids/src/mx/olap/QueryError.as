
package mx.olap
{

/**
 *  @private 
 *  The QueryError class represents a query error message. 
 */
public class QueryError extends Error
{
	include "../core/Version.as";
	
	//--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *
     *  @param msg A string associated with the error object.
     *
     *  @param id A reference number to associate with the specific error message.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function QueryError(msg:String, id:int=0):void
    {
        super(msg, id);
    }
}

}