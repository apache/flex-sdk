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
        if (labelFunction != null)
            return labelFunction(item);

        if (item is XML)
        {
            try
            {
                if (item[labelField].length() != 0)
                    item = item[labelField];
                //by popular demand, this is a default XML labelField
                //else if (item.@label.length() != 0)
                //  item = item.@label;
            }
            catch(e:Error)
            {
            }
        }
        else if (item is Object)
        {
            try
            {
                if (item[labelField] != null)
                    item = item[labelField];
            }
            catch(e:Error)
            {
            }
        }

        if (item is String)
            return String(item);

        try
        {
            return item.toString();
        }
        catch(e:Error)
        {
        }

        return " ";
    }
}

}
