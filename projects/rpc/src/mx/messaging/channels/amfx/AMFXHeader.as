/*************************************************************************
 * 
 * ADOBE CONFIDENTIAL
 * __________________
 * 
 *  [2002] - [2007] Adobe Systems Incorporated 
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 */
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