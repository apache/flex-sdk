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

import flashx.textLayout.compose.ISWFContext;
import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.managers.ISystemManager;
import mx.styles.IStyleClient;

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


    //--------------------------------------------------------------------------
    //
    //  Methods - Font Baseline
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Used in getEmbeddedFontContext().
     */
    private static var staticTextFormat:TextFormat;
        
    //----------------------------------
    //  embeddedFontRegistry
    //----------------------------------

    private static var noEmbeddedFonts:Boolean;

    /**
     *  @private
     *  Storage for the _embeddedFontRegistry property.
     *  Note: This gets initialized on first access,
     *  not when this class is initialized, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _embeddedFontRegistry:IEmbeddedFontRegistry;

    /**
     *  @private
     *  A reference to the embedded font registry.
     *  Single registry in the system.
     *  Used to look up the moduleFactory of a font.
     */
    private static function get embeddedFontRegistry():IEmbeddedFontRegistry
    {
        if (!_embeddedFontRegistry && !noEmbeddedFonts)
        {
            try
            {
                _embeddedFontRegistry = IEmbeddedFontRegistry(
                    Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
            }
            catch (e:Error)
            {
                noEmbeddedFonts = true;
            }
        }

        return _embeddedFontRegistry;
    }

    /**
     *  Method to measure baseline position
     *  
     *  @param client The IStyleClient to use to calculate the baseline.
     *  @param height Height of client.  Used only for degenerate cases.
     *  @param moduleFactory The default moduleFactory to use for the font.
     */
    public static function calculateFontBaseline(client:IStyleClient, height:Number, moduleFactory:IFlexModuleFactory):Number
    {
        var fontDescription:FontDescription = new FontDescription();
        var embeddedFontContext:IFlexModuleFactory;
        
        var s:String;

        s = client.getStyle("cffHinting");
        if (s != null)
            fontDescription.cffHinting = s;
        
        s = client.getStyle("fontFamily");
        if (s != null)
            fontDescription.fontName = s;
        
        s = client.getStyle("fontLookup");
        if (s != null)
        {
            // FTE understands only "device" and "embeddedCFF"
            // for fontLookup. But Flex allows this style to be
            // set to "auto", in which case we automatically
            // determine it based on whether the CSS styles
            // specify an embedded font.
            if (s == "auto")
            {
                embeddedFontContext = getEmbeddedFontContext(client, moduleFactory);
                s = (embeddedFontContext) ? 
                    FontLookup.EMBEDDED_CFF :
                    FontLookup.DEVICE;
            }
            fontDescription.fontLookup = s;
        }
         
        s = client.getStyle("fontStyle");
        if (s != null)
            fontDescription.fontPosture = s;
        
        s = client.getStyle("fontWeight");
        if (s != null)
            fontDescription.fontWeight = s;
        
        var elementFormat:ElementFormat = new ElementFormat();
        elementFormat.fontDescription = fontDescription;
        elementFormat.fontSize = client.getStyle("fontSize");
        
        var textElement:TextElement = new TextElement();
        textElement.elementFormat = elementFormat;
        textElement.text = "Wj";
        
        var textBlock:TextBlock = new TextBlock();
        textBlock.content = textElement;
        
        var textLine:TextLine;
        if (embeddedFontContext)
        {
            var swfContext:ISWFContext = ISWFContext(embeddedFontContext);
            textLine = swfContext.callInContext(
						textBlock.createTextLine, textBlock,
						[ null, 1000]);
        }
        else
            textLine = textBlock.createTextLine(null, 1000);
        
        if (height < 2 + textLine.ascent + 2)
            return int(height + (textLine.ascent - height) / 2);

        return 2 + textLine.ascent;
    }

	/**
	 *  @private
	 *  Uses the component's CSS styles to determine the module factory
	 *  that should creates its TextLines.
	 */
    private static function getEmbeddedFontContext(client:IStyleClient, moduleFactory:IFlexModuleFactory):IFlexModuleFactory
	{
		var fontContext:IFlexModuleFactory;
		
		var fontLookup:String = client.getStyle("fontLookup");
		if (fontLookup != FontLookup.DEVICE)
        {
			var font:String = client.getStyle("fontFamily");
			var bold:Boolean = client.getStyle("fontWeight") == "bold";
			var italic:Boolean = client.getStyle("fontStyle") == "italic";
			
            fontContext = embeddedFontRegistry.getAssociatedModuleFactory(
            	font, bold, italic,
                client, moduleFactory);

            // If we found the font, then it is embedded. 
            // But some fonts are not listed in info()
            // and are therefore not in the above registry.
            // So we call isFontFaceEmbedded() which gets the list
            // of embedded fonts from the player.
            if (!fontContext) 
            {
                var sm:ISystemManager;
                if (moduleFactory != null && moduleFactory is ISystemManager)
                	sm = ISystemManager(moduleFactory);
                else if (client is IUIComponent)
                {
                    var uic:IUIComponent = IUIComponent(client);
                    if (uic.parent is IUIComponent)
                	    sm = IUIComponent(uic.parent).systemManager;
                }

                if (!staticTextFormat)
                    staticTextFormat = new TextFormat();

                staticTextFormat.font = font;
                staticTextFormat.bold = bold;
                staticTextFormat.italic = italic;
                
                if (sm != null && sm.isFontFaceEmbedded(staticTextFormat))
                    fontContext = sm;
            }
        }

        if (!fontContext && fontLookup == FontLookup.EMBEDDED_CFF)
        {
            // if we couldn't find the font and somebody insists it is
            // embedded, try the default fontContext
            fontContext = moduleFactory;
        }
        
        return fontContext;
	}

}

}
