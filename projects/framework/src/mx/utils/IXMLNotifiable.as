////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

[ExcludeClass]

/**
 *  The IXMLNotifiable interface is for internal use only.
 */
public interface IXMLNotifiable
{
    /**
    *  @private
    */
    function xmlNotification(currentTarget:Object,
                             type:String,
                             target:Object,
                             value:Object,
                             detail:Object):void;
}

}