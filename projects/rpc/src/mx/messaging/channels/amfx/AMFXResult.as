
package mx.messaging.channels.amfx
{

[ExcludeClass]

/**
 * A simple context to hold the result of an AMFX request.
 * @private
 */
public class AMFXResult
{
    public var version:uint;
    public var headers:Array;
    public var result:Object;

    public function AMFXResult()
    {
        super();
    }
}

}
