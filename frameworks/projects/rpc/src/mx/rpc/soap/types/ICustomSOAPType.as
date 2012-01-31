
package mx.rpc.soap.types
{

import mx.rpc.soap.SOAPDecoder;
import mx.rpc.soap.SOAPEncoder;

[ExcludeClass]

/**
 * Implementations handle encoding and decoding between custom SOAP types and 
 * ActionScript.
 * 
 * @private
 */
public interface ICustomSOAPType
{
    function encode(encoder:SOAPEncoder, parent:XML, name:QName, value:*, restriction:XML = null):void;

    function decode(decoder:SOAPDecoder, parent:*, name:*, value:*, restriction:XML = null):void;
}

}