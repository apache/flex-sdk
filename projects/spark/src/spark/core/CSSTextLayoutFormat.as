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

package spark.core
{

import flash.text.engine.FontLookup;
import flash.text.engine.Kerning;
import flashx.textLayout.formats.ITextLayoutFormat;
import mx.core.mx_internal;
import mx.styles.IStyleClient;

[ExcludeClass]

/**
 *  @private
 *  This class is used by components such as RichText
 *  and RichEditableText which use TLF to display their text.
 *  The default formatting for their text is determined
 *  by the component's CSS styles.
 *  This class allows TLF to simply "pull" the format values
 *  from the CSS system using getStyle() calls.
 *  This takes less memory than using an instance of TextLayoutFormat
 *  because this class has only one var while TextLayoutFormat
 *  has one for every format.
 *
 *  The only extra functionality supported here, beyond what TLF has,
 *  is the ability for the fontLookup style to have the value "auto";
 *  in this case, the client object's embeddedFontContext is used
 *  to determine whether the the fontLookup format in TLF should be
 *  "embeddedCFF" or "device".
 */
public class CSSTextLayoutFormat implements ITextLayoutFormat
{
    include "../core/Version.as";
        
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 *  Constructor
	 */
	public function CSSTextLayoutFormat(client:IStyleClient)
	{
		super();
		
		this.client = client;
	}
	        
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 *  The component whose CSS styles are used to determine the TLF format.
	 */
	private var client:IStyleClient;
	
    //--------------------------------------------------------------------------
    //
    //  Properties: ITextLayoutFormat
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function get alignmentBaseline():*
	{
		return client.getStyle("alignmentBaseline");
	}
	
	/**
	 *  @private
	 */
	public function get backgroundAlpha():*
	{
		return client.getStyle("backgroundAlpha");
	}
	
	/**
	 *  @private
	 */
	public function get backgroundColor():*
	{
		return client.getStyle("backgroundColor");
	}
	
	/**
	 *  @private
	 */
	public function get baselineShift():*
	{
		return client.getStyle("baselineShift");
	}
	
	/**
	 *  @private
	 */
	public function get blockProgression():*
	{
		return client.getStyle("blockProgression");
	}
	
	/**
	 *  @private
	 */
	public function get breakOpportunity():*
	{
		return client.getStyle("breakOpportunity");
	}
	
	/**
	 *  @private
	 */
	public function get cffHinting():*
	{
		return client.getStyle("cffHinting");
	}
	
	/**
	 *  @private
	 */
	public function get color():*
	{
		return client.getStyle("color");
	}
	
	/**
	 *  @private
	 */
	public function get columnCount():*
	{
		return client.getStyle("columnCount");
	}
	
	/**
	 *  @private
	 */
	public function get columnGap():*
	{
		return client.getStyle("columnGap");
	}
	
	/**
	 *  @private
	 */
	public function get columnWidth():*
	{
		return client.getStyle("columnWidth");
	}
	
	/**
	 *  @private
	 */
	public function get digitCase():*
	{
		return client.getStyle("digitCase");
	}
	
	/**
	 *  @private
	 */
	public function get digitWidth():*
	{
		return client.getStyle("digitWidth");
	}
	
	/**
	 *  @private
	 */
	public function get direction():*
	{
		return client.getStyle("direction");
	}
	
	/**
	 *  @private
	 */
	public function get dominantBaseline():*
	{
		return client.getStyle("dominantBaseline");
	}
	
	/**
	 *  @private
	 */
	public function get firstBaselineOffset():*
	{
		return client.getStyle("firstBaselineOffset");
	}
	
	/**
	 *  @private
	 */
	public function get fontFamily():*
	{
		return client.getStyle("fontFamily");
	}
	
	/**
	 *  @private
	 */
	public function get fontLookup():*
	{
        var value:String = client.getStyle("fontLookup");
        
		// Special processing of the "auto" value is required,
		// because this value has meaning only in Flex, not in TLF.
		// It tells Flex to use its EmbeddedFontRegistry to determine
		// whether the font is embedded or not.
		if (value == "auto")
        {
            if (client.mx_internal::embeddedFontContext)
                value = FontLookup.EMBEDDED_CFF;
            else
                value = FontLookup.DEVICE;
        }

        return value;
	}
	
	/**
	 *  @private
	 */
	public function get fontSize():*
	{
		return client.getStyle("fontSize");
	}
	
	/**
	 *  @private
	 */
	public function get fontStyle():*
	{
		return client.getStyle("fontStyle");
	}
	
	/**
	 *  @private
	 */
	public function get fontWeight():*
	{
		return client.getStyle("fontWeight");
	}
	
	/**
	 *  @private
	 */
	public function get justificationRule():*
	{
		return client.getStyle("justificationRule");
	}
	
	/**
	 *  @private
	 */
	public function get justificationStyle():*
	{
		return client.getStyle("justificationStyle");
	}
	
	/**
	 *  @private
	 */
	public function get kerning():*
	{
		var kerning:Object = client.getStyle("kerning");

		// In Halo components based on TextField,
		// kerning is supposed to be true or false.
		// The default in TextField and Flex 3 is false
		// because kerning doesn't work for device fonts
		// and is slow for embedded fonts.
		// In Spark components based on TLF and FTE,
		// kerning is "auto", "on", or, "off".
		// The default in TLF and FTE is "auto"
		// (which means kern non-Asian characters)
		// because kerning works even on device fonts
		// and has miminal performance impact.
        // Since a CSS selector or parent container
		// can affect both Halo and Spark components,
		// we need to map true to "on" and false to "off"
		// here and in Label.
		// For Halo components, UITextField and UIFTETextField
		// do the opposite mapping
		// of "auto" and "on" to true and "off" to false.
		// We also support a value of "default"
		// (which we set in the global selector)
		// to mean "auto" for Spark and false for Halo
		// to get the recommended behavior in both sets of components.
		if (kerning === "default")
			kerning = Kerning.AUTO;
		else if (kerning === true)
			kerning = Kerning.ON;
		else if (kerning === false)
			kerning = Kerning.OFF;

		return kerning;
	}
	
	/**
	 *  @private
	 */
	public function get leadingModel():*
	{
		return client.getStyle("leadingModel");
	}
	
	/**
	 *  @private
	 */
	public function get ligatureLevel():*
	{
		return client.getStyle("ligatureLevel");
	}
	
	/**
	 *  @private
	 */
	public function get lineBreak():*
	{
		return client.getStyle("lineBreak");
	}
	
	/**
	 *  @private
	 */
	public function get lineHeight():*
	{
		return client.getStyle("lineHeight");
	}
	
	/**
	 *  @private
	 */
	public function get lineThrough():*
	{
		return client.getStyle("lineThrough");
	}
	
	/**
	 *  @private
	 */
	public function get locale():*
	{
		return client.getStyle("locale");
	}
	
	/**
	 *  @private
	 */
	public function get marginBottom():*
	{
		return client.getStyle("marginBottom");
	}
	
	/**
	 *  @private
	 */
	public function get marginLeft():*
	{
		return client.getStyle("marginLeft");
	}
	
	/**
	 *  @private
	 */
	public function get marginRight():*
	{
		return client.getStyle("marginRight");
	}
	
	/**
	 *  @private
	 */
	public function get marginTop():*
	{
		return client.getStyle("marginTop");
	}
	
	/**
	 *  @private
	 */
	public function get paddingBottom():*
	{
		return client.getStyle("paddingBottom");
	}
	
	/**
	 *  @private
	 */
	public function get paddingLeft():*
	{
		return client.getStyle("paddingLeft");
	}
	
	/**
	 *  @private
	 */
	public function get paddingRight():*
	{
		return client.getStyle("paddingRight");
	}
	
	/**
	 *  @private
	 */
	public function get paddingTop():*
	{
		return client.getStyle("paddingTop");
	}
	
	/**
	 *  @private
	 */
	public function get paragraphEndIndent():*
	{
		return client.getStyle("paragraphEndIndent");
	}
	
	/**
	 *  @private
	 */
	public function get paragraphSpaceAfter():*
	{
		return client.getStyle("paragraphSpaceAfter");
	}
	
	/**
	 *  @private
	 */
	public function get paragraphSpaceBefore():*
	{
		return client.getStyle("paragraphSpaceBefore");
	}
	
	/**
	 *  @private
	 */
	public function get paragraphStartIndent():*
	{
		return client.getStyle("paragraphStartIndent");
	}
	
	/**
	 *  @private
	 */
	public function get renderingMode():*
	{
		return client.getStyle("renderingMode");
	}
	
	/**
	 *  @private
	 */
	public function get tabStops():*
	{
		return client.getStyle("tabStops");
	}
	
	/**
	 *  @private
	 */
	public function get textAlign():*
	{
		return client.getStyle("textAlign");
	}
	
	/**
	 *  @private
	 */
	public function get textAlignLast():*
	{
		return client.getStyle("textAlignLast");
	}
	
	/**
	 *  @private
	 */
	public function get textAlpha():*
	{
		return client.getStyle("textAlpha");
	}
	
	/**
	 *  @private
	 */
	public function get textDecoration():*
	{
		return client.getStyle("textDecoration");
	}
	
	/**
	 *  @private
	 */
	public function get textIndent():*
	{
		return client.getStyle("textIndent");
	}
	
	/**
	 *  @private
	 */
	public function get textJustify():*
	{
		return client.getStyle("textJustify");
	}
	
	/**
	 *  @private
	 */
	public function get textRotation():*
	{
		return client.getStyle("textRotation");
	}
	
	/**
	 *  @private
	 */
	public function get trackingLeft():*
	{
		return client.getStyle("trackingLeft");
	}
	
	/**
	 *  @private
	 */
	public function get trackingRight():*
	{
		return client.getStyle("trackingRight");
	}
	
	/**
	 *  @private
	 */
	public function get typographicCase():*
	{
		return client.getStyle("typographicCase");
	}
	
	/**
	 *  @private
	 */
	public function get verticalAlign():*
	{
		return client.getStyle("verticalAlign");
	}
	
	/**
	 *  @private
	 */
	public function get whiteSpaceCollapse():*
	{
		return client.getStyle("whiteSpaceCollapse");
	}
}

}

