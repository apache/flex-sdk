////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.rpc.xml
{

/**
 * An ActionScript type should implement this interface when it needs to
 * instruct an XML Schema based encoder (such as the WebService SOAP client)
 * which concrete type definition to use while encoding instances of the type.
 * 
 * <p>Note that anonymous ActionScript objects can also specify a qualified type
 * by wrapping an object in an instance of mx.utils.ObjectProxy 
 * and setting the <code>object_proxy::type</code> property with the appropriate
 * QName.</p>
 * 
 * @see mx.utils.ObjectProxy
 */
public interface IXMLSchemaInstance
{
    /**
     * When encoding ActionScript instances as XML the encoder may require
     * a type definition for the concrete implementation when the associated
     * XML Schema complexType is abstract. This property allows a typed
     * instance to specify the concrete implementation as a QName to represent
     * the <code>xsi:type</code>.
     * 
     * <p>
     * Note that <code>[Transient]</code> metadata can be applied to
     * implementations of this property to exclude it during object
     * serialization.
     * </p>
     */ 
    function get xsiType():QName;

    function set xsiType(value:QName):void;
}

}