////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.utils
{

import flash.text.TextFormat;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;
import flash.utils.describeType;

import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

[ExcludeClass]

[ResourceBundle("textLayout")]

/**
 *  @private
 */
public class TextUtil
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    public static function extractText(textFlow:TextFlow):String
    {
        var text:String = "";
        
        var leaf:FlowLeafElement = textFlow.getFirstLeaf();
        while (leaf)
        {
            var p:ParagraphElement = leaf.getParagraph();
            for (;;)
            {
                text += leaf.text;
                leaf = leaf.getNextLeaf(p);
                if (!leaf)
                    break;
            }
            leaf = p.getLastLeaf().getNextLeaf(null);
            if (leaf)
                text += "\n";
        }

        return text;
    }

    /**
     *  @private
     */
    public static function getNumberOrPercentOf(value:Object,
                                                n:Number):Number
    {
        // If 'value' is a Number like 10.5, return it.
        if (value is Number)
            return Number(value);

        // If 'value' is a percentage String like "10.5%",
        // return that percentage of 'n'.
        if (value is String)
        {
            var len:int = String(value).length;
            if (len >= 1 && value.charAt(len - 1) == "%")
            {
                var percent:Number = Number(value.substring(0, len - 1));
                return percent / 100 * n;
            }
        }

        // Otherwise, return NaN.
        return NaN;
    }

    /**
     *  @private
     */
    public static function obscureTextFlow(textFlow:TextFlow,
                                           obscurationChar:String):void
    {
        for (var leaf:FlowLeafElement = textFlow.getFirstLeaf();
             leaf;
             leaf = leaf.getNextLeaf())
        {
            if (leaf is SpanElement)
            {
                var leafText:String = SpanElement(leaf).text;
                if (leafText)
                {
                	SpanElement(leaf).text = StringUtil.repeat(
                		obscurationChar, leafText.length);
                }
            }
        }
    }

    /**
     *  @private
     */
    public static function unobscureTextFlow(textFlow:TextFlow,
                                             text:String):void
    {
        for (var leaf:FlowLeafElement = textFlow.getFirstLeaf();
             leaf;
             leaf = leaf.getNextLeaf())
        {
            if (leaf is SpanElement)
            {
                var span:SpanElement = leaf as SpanElement;
                
                // leaf.textLength may have paragraph terminator in length so
                // use length of text in the span
                var t:String = text.substr(leaf.getAbsoluteStart(), 
                                          span.text.length);
                span.text = t;
            }
        }
    }

    /**
     *  @private
     */
	public static function getResourceString(resourceName:String,
											 args:Array = null):String
	{
		var resourceManager:IResourceManager = ResourceManager.getInstance();
		return resourceManager.getString("textLayout", resourceName, args);
	}


}

}
