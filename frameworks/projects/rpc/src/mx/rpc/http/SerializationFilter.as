package mx.rpc.http 
{

import mx.core.mx_internal;

use namespace mx_internal;

/**
 * An instance of this class can manage formatting HTTP request responses and
 * converting their parameters.  HTTPMultiService and HTTPService will expose a
 * serializationFilter property, or you can define one of these statically and register it
 * for a custom resultFormat.  In that case, the resultFormat can be used to choose the
 * SerializationFilter automatically. 
 */
public class SerializationFilter
{
    // replaces/returns previous with that name or null
    static mx_internal var filterForResultFormatTable:Object = new Object();
    public static function registerFilterForResultFormat(resultFormat:String, filter:SerializationFilter):SerializationFilter
    {
        var old:SerializationFilter = filterForResultFormatTable[resultFormat];
        filterForResultFormatTable[resultFormat] = filter;
        return old;
    }


    /**
     * This method takes the result from the HTTP request in a raw format.  It 
     * can convert it to an ActionScript object.  It can use the resultType or 
     * resultElementType properties of the Operation.  It also can store additional
     * properties on the operation's properties object.
     */
    public function deserializeResult(operation:AbstractOperation, result:Object):Object
    {
        return result;
    }

    /**
     * This is a hook to override the request's content type for a specific serializer.
     * It is given the parameter object and the content type configured on the operation.
     * The default behavior is to return the supplied content type.
     */
    public function getRequestContentType(operation:AbstractOperation, obj:Object, contentType:String):String
    {
        return contentType;
    }

    /**
     * This method is used when you use the "send" method to the mx.rpc.http.Operation.
     * That method takes an array of parameters without names.  The role of this method
     * is to convert this to a single object which is used as the data for the HTTP request
     * body.  The default implementation produces an object where the keys are the values
     * in the Operation's argumentNames array and the values are the values of the parameters.
     * When using the default implementation, you must set argumentNames to have the same number
     * of elements as the parameters array.
     * 
     * <p>Note that this method is not used if you invoke the HTTP operation using the sendBody
     * method which just takes a single object.  In that case, this step is skipped and only
     * the serializeBody method is called.</p>
     */
    public function serializeParameters(operation:AbstractOperation, params:Array):Object
    {
        var argNames:Array = operation.argumentNames;

        if (params == null || params.length == 0)
            return params;

        if (argNames == null || params.length != argNames.length)
            throw new ArgumentError("HTTPMultiService operation called with " + (argNames == null ? 0 : argNames.length) + " argumentNames and " + params.length + " number of parameters.  When argumentNames is specified, it must match the number of arguments passed to the invocation");

        var obj:Object = new Object();
        var argumentNames:Array = operation.argumentNames;
        for (var i:int = 0; i < argumentNames.length; i++)
            obj[argumentNames[i]] = params[i];

        return obj;
    }

    /**
     * This method is called for all invocations of the HTTP service.  It is able to convert
     * the supplied object into a form suitable for placing directly in the HTTP's request
     * body.
     */
    public function serializeBody(operation:AbstractOperation, obj:Object):Object
    {
        return obj;
    }

    /**
     * This method is used if you need to take data from the request body object and encode
     * it into the URL string.   It is given the incoming URL.  By default, the incoming
     * URL is returned directly.
     */
    public function serializeURL(operation:AbstractOperation, obj:Object, url:String):String
    {
        return url;
    }
}

}
