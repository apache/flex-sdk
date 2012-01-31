
package mx.messaging.channels.amfx
{

[ExcludeClass]

/**
 * An AMFX request or response packet can contain headers.
 *
 * A Header must have a name, can be marked with a mustUnderstand
 * boolean flag (the default is false), and the content can be any
 * Object.
 * @private
 */
public class AMFXHeader
{
    public var name:String;
    public var mustUnderstand:Boolean;
    public var content:Object;

    public function AMFXHeader()
    {
        super();
    }
}

}
