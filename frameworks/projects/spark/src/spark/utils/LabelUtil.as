////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

/**
 *  This class typically aids components in determining the correct
 *  text to display for their renderers or sub-parts. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class LabelUtil
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  A function typically used by renderer-aware controls to determine
     *  the correct text a renderer should display for a particular data item, 
     *  given the item, a labelField and a labelFunction. 
     * 
     *  @param item
     *  @param labelField
     *  @param labelFunction
     */
    public static function itemToLabel(item:Object, labelField:String=null, 
    	labelFunction:Function=null):String
    {
    	if (!item)
    		return "";
        else if (labelFunction != null)
    		return labelFunction(item);
    	else if (labelField != null)
    		return item[labelField];
    	else
    		return item.toString();
    }
}

}
