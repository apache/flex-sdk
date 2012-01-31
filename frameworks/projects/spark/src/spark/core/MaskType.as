////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

/**
 *  Defines the mask types available for a GraphicElement.
 */
public final class MaskType
{
    include "../core/Version.as";

    /**
     *  The mask either displays the pixel or doesn't. Strokes and bitmap filters are not used. 
     */
    public static const CLIP:String = "clip";

    /**
     *  The mask respects opacity and uses the strokes and bitmap filters of the mask.
     */
    public static const ALPHA:String = "alpha";
}

}
