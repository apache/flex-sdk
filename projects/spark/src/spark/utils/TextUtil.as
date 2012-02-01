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

package mx.utils
{

import flash.utils.describeType;

import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.ICharacterFormat;
import flashx.textLayout.formats.IContainerFormat;
import flashx.textLayout.formats.IParagraphFormat;

[ExcludeClass]

/**
 *  @private
 */
public class TextUtil
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  An Array of the names of all text formats, in no particular order.
     */
    public static var ALL_FORMAT_NAMES:Array = [];

    /**
     *  @private
     *  Maps the name of a text attribute to what kind of attribute it is.
     *  For example,
     *  paddingLeft -> container
     *  marginLeft -> paragraph
     *  fontSize -> character
     */
    public static var FORMAT_MAP:Object = {};
    
    /**
     *  @private
     */
    public static const CONTAINER:String = "container";
    
    /**
     *  @private
     */
    public static const PARAGRAPH:String = "paragraph";

    /**
     *  @private
     */
    public static const CHARACTER:String = "character";

    //--------------------------------------------------------------------------
    //
    //  Class initialization
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Initializes the FORMAT_MAP by using describeType()
     *  to enumerate the properties of the IContainerFormat,
     *  IParagraphFormat, and ICharacterFormat interfaces.
     */
    private static function initClass():void
    {
        var type:XML;
        var name:String;

        type = describeType(IContainerFormat);
        for each (name in type.factory.accessor.@name)
        {
            ALL_FORMAT_NAMES.push(name);
            FORMAT_MAP[name] = CONTAINER;
        }
        
        type = describeType(IParagraphFormat);
        for each (name in type.factory.accessor.@name)
        {
            ALL_FORMAT_NAMES.push(name);
            FORMAT_MAP[name] = PARAGRAPH;
        }
       
        type = describeType(ICharacterFormat);
        for each (name in type.factory.accessor.@name)
        {
            ALL_FORMAT_NAMES.push(name);
            FORMAT_MAP[name] = CHARACTER;
        }
    }

    initClass();

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
}

}
