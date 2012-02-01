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

package flex.utils
{

import flash.utils.describeType;

import text.model.ICharacterAttributes;
import text.model.IContainerAttributes;
import text.model.IParagraphAttributes;
import text.model.LeafElement;
import text.model.Paragraph;
import text.model.TextFlow;

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
     *  An Array of the names of all text attributes, in no particular order.
     */
    public static var ALL_ATTRIBUTE_NAMES:Array = [];

    /**
     *  @private
     *  Maps the name of a text attribute to what kind of attribute it is.
     *  For example,
     *  paddingLeft -> container
     *  marginLeft -> paragraph
     *  fontSize -> character
     */
    public static var ATTRIBUTE_MAP:Object = {};
    
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
     *  Initializes the ATTRIBUTE_MAP by using describeType()
     *  to enumerate the properties of the IContainerAttribues,
     *  IParagraphAttributes, and ICharacterAttributes interfaces.
     */
    private static function initClass():void
    {
        var type:XML;
        var name:String;

        type = describeType(IContainerAttributes);
        for each (name in type.factory.accessor.@name)
        {
            ALL_ATTRIBUTE_NAMES.push(name);
            ATTRIBUTE_MAP[name] = CONTAINER;
        }
        
        type = describeType(IParagraphAttributes);
        for each (name in type.factory.accessor.@name)
        {
            ALL_ATTRIBUTE_NAMES.push(name);
            ATTRIBUTE_MAP[name] = PARAGRAPH;
        }
       
        type = describeType(ICharacterAttributes);
        for each (name in type.factory.accessor.@name)
        {
            ALL_ATTRIBUTE_NAMES.push(name);
            ATTRIBUTE_MAP[name] = CHARACTER;
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
        
        var leaf:LeafElement = textFlow.getFirstLeaf();
        while (leaf)
        {
            var p:Paragraph = leaf.getParagraph();
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
}

}
