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

package spark.utils
{
	
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.ITextExporter;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextFilter;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.FormatValue;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.tlf_internal;

import mx.core.mx_internal;

use namespace mx_internal;
use namespace tlf_internal;

/**
 *  TextFlowUtil is a utility class which provides methods
 *  for importing a TextFlow from, and exporting a TextFlow to,
 *  the markup language used by the Text Layout Framework.
 */
public class TextFlowUtil
{
    include "../core/Version.as";
    
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 */
	private static const TEXT_LAYOUT_NAMESPACE:String =
		"http://ns.adobe.com/textLayout/2008";
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	private static var initialized:Boolean = false;
	
	/**
	 *  @private
	 */
	private static var collapsingTextLayoutImporter:ITextImporter;
	
	/**
	 *  @private
	 */
	private static var preservingTextLayoutImporter:ITextImporter;
	
	/**
	 *  @private
	 */
	private static var textLayoutExporter:ITextExporter;
	
	/**
	 *  @private
	 */
	private static var configInheritingFormats:Vector.<String>;
	
		//--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 *  This method initializes the static vars of this class.
	 *  Rather than calling it at static initialization time,
	 *  we call it from every public method.
	 *  (It does an immediate return if it has already run.)
	 *  By doing so, we avoid any static initialization issues
	 *  related to whether this class or the TLF classes
	 *  that it uses are initialized first.
	 */
	private static function initClass():void
	{
		if (initialized)
			return;
		
		var format:TextLayoutFormat;
		var config:Configuration;
				
		// Create an importer for TEXT_LAYOUT_FORMAT
		// that collapses whitespace.
		format = new TextLayoutFormat();
		format.whiteSpaceCollapse = "collapse";
		config = new Configuration();
		config.textFlowInitialFormat = format;
		collapsingTextLayoutImporter = TextFilter.getImporter(
			TextFilter.TEXT_LAYOUT_FORMAT, config);
		collapsingTextLayoutImporter.throwOnError = true;
		
		// Create an importer for TEXT_LAYOUT_FORMAT
		// that preserves whitespace.
		format = new TextLayoutFormat();
		format.whiteSpaceCollapse = "preserve";
		config = new Configuration();
		config.textFlowInitialFormat = format;
		preservingTextLayoutImporter = TextFilter.getImporter(
			TextFilter.TEXT_LAYOUT_FORMAT, config);
		preservingTextLayoutImporter.throwOnError = true;
			
		// Create an exporter for TEXT_LAYOUT_FORMAT.
		textLayoutExporter = TextFilter.getExporter(
			TextFilter.TEXT_LAYOUT_FORMAT);
			
		// Build a list of the formats which are marked "inherit"
		// a Configuration's textFlowInitialFormat.
		config = new Configuration();	
		configInheritingFormats = new Vector.<String>();
		var initialFormat:ITextLayoutFormat = config.textFlowInitialFormat;
		for (var p:String in TextLayoutFormat.description)
		{
			if (initialFormat[p] == FormatValue.INHERIT)
				configInheritingFormats.push(p);
		}
		
		initialized = true;
	}
	
    /**
     *  Creates a TextFlow by importing (i.e., parsing) a String
     *  containing the markup language used by the Text Layout Framework.
     *  
     *  <p>An example of a markup string is
     *  <pre>
     *  "<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>
     *  <p><span>Hello, </span><span fontWeight='bold'>World!</span></p></TextFlow>"
     *  </pre>
     *  </p>
     *
     *  <p>However, you can use terser markup such as
     *  <pre>"Hello, <span fontWeight='bold'>World!</span>"</pre>.
     *  It will get wrapped with a TextFlow tag in the proper namespace,
     *  and span and paragraph tags will get automatically inserted
     *  where needed to comply with the structure of a TextFlow.</p>
     *  If you specify the TextFlow tag yourself,
     *  it must be in the correct XML namespace
	 *  for runtime Text Layout Framework markup, which is
     *  <code>"http://ns.adobe.com/textLayout/2008"</code>.</p>
     *
     *  <p>Incorrect markup will cause this method to throw
     *  various exceptions.
     *  The error message will contain information
     *  about why it could not be parsed.</p>
     * 
     *  @param markup The markup String to be imported.
     * 
     *  @param whiteSpaceCollapse A String indicating whether
     *  the whitespace in the markup should be collapsed or preserved.
     *  The possible values are
     *  <code>WhiteSpaceCollapse.COLLAPSE</code> and
     *  <code>WhiteSpaceCollapse.PRESERVE</code> in the
     *  flashx.textLayout.formats.WhiteSpaceCollapse class.
     *  The default value is <code>WhiteSpaceCollapse.COLLAPSE</code>.
     *
     *  @return A new TextFlow instance created from the markup.
     */
    public static function importFromString(
    	markup:String, whiteSpaceCollapse:String = "collapse"):TextFlow
    {
    	initClass();
    	
    	var markupToImport:Object = markup;
    	
        // If the markup string doesn't contain "TextFlow",
        // it needs to be wrapped in a <TextFlow> tag
        // in order for the TEXT_LAYOUT_FORMAT importer
        // to be able to parse it.
        // If it does contain "TextFlow", convert it to XML
        // and check whether the outer tag is <TextFlow>.
        // If so, don't wrap it and pass the XML to the importer;
        // if not, wrap it and pass the String to the importer.
        var wrap:Boolean = true;
        if (markup.indexOf("TextFlow") != -1)
        {
            try
            {
                var xml:XML = XML(markup);
                if (xml.localName() == "TextFlow")
                {
					markupToImport = xml;
					wrap = false;
                } 
            }
            catch(e:Error)
            {
            }
        }

        if (wrap)
        {
            markupToImport =  "<TextFlow xmlns=\"" + TEXT_LAYOUT_NAMESPACE + "\">" +
                      		  markupToImport +
                      		  "</TextFlow>";
        }
                
		var importer:ITextImporter = whiteSpaceCollapse == "collapse" ?
				   					 collapsingTextLayoutImporter :
				   					 preservingTextLayoutImporter;
		
		return importer.importToFlow(markupToImport);
    }

	/**
	 *  Creates a TextFlow by importing (i.e., parsing) XML
	 *  containing the markup language used by the Text Layout Framework.
	 *  
	 *  <p>An example of markup XML is
	 *  <pre>
	 *  <TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>
	 *    <p><span>Hello, </span><span fontWeight='bold'>World!</span></p>
	 *  </TextFlow>
	 *  </pre>
	 *  </p>
	 *
     *  <p>However, you can use terser markup such as
     *  <pre>"Hello, <span fontWeight='bold'>World!</span>"</pre>.
     *  It will get wrapped with a TextFlow tag in the proper namespace,
     *  and span and paragraph tags will get automatically inserted
     *  where needed to comply with the structure of a TextFlow.</p>
     *  If you specify the TextFlow tag yourself,
     *  it must be in the correct XML namespace
	 *  for runtime Text Layout Framework markup, which is
     *  <code>"http://ns.adobe.com/textLayout/2008"</code>.</p>
     *
     *  <p>Incorrect markup will cause this method to throw
     *  various exceptions.
     *  The error message will contain information
     *  about why it could not be parsed.</p>
	 * 
	 *  @param markup The markup XML to be imported.
	 * 
	 *  @param whiteSpaceCollapse A String indicating whether
	 *  the whitespace in the markup should be collapsed or preserved.
	 *  The possible values are
	 *  <code>WhiteSpaceCollapse.COLLAPSE</code> and
	 *  <code>WhiteSpaceCollapse.PRESERVE</code> in the
	 *  flashx.textLayout.formats.WhiteSpaceCollapse class.
	 *  The default value is <code>WhiteSpaceCollapse.COLLAPSE</code>.
	 *
	 *  @return A new TextFlow instance created from the markup.
	 */
	    public static function importFromXML(
    	markup:XML, whiteSpaceCollapse:String = "collapse"):TextFlow
    {
    	initClass();
    	
		// If the root tag of the markup isn't a TextFlow tag,
		// wrap the markup with one, in the proper namespace.
		if (markup.localName() != "TextFlow")
        {
            // Create a root <TextFlow> element.
            var root:XML = <TextFlow/>;
            var ns:Namespace = new Namespace(TEXT_LAYOUT_NAMESPACE);
            root.setNamespace(ns);            
            
            // Add the markup as a child tag.
            root.setChildren(markup);  
                                    
            // The namespace of the root node is not inherited by
            // the children so it needs to be explicitly set on
            // every element, at every level.  If this is not done
            // the import will fail with an "Unexpected namespace"
            // error.
            for each (var element:XML in root..*::*)
            {
               element.setNamespace(ns);
            }
            
            markup = root;
        }
        
        trace(markup);

		var importer:ITextImporter = whiteSpaceCollapse == "collapse" ?
			collapsingTextLayoutImporter :
			preservingTextLayoutImporter;
		
		return importer.importToFlow(markup);
    }
    
    /**
     *  Exports a TextFlow into the markup language
     *  used by the Text Layout Framework, in the form of XML.
     *
     *  <p>The root tag of the exported XML will be
     *  <pre>
     *  <TextFlow xmlns="http://ns.adobe.com/textLayout/2008" ...>
     *  </pre>
     *  </p>
     * 
     *  @param textFlow The TextFlow to be exported
     *  in Text Layout Framework markup language.
     * 
     *  @return XML containing Text Layout Framework
     *  markup language.
     */
    public static function export(textFlow:TextFlow):XML
    {
		initClass();
		
		// Call the exporter for TEXT_LAYOUT_FORMAT to produce
        // XML markup which is more or less an exact match
        // for TLF's text object model.
        var xml:XML = textLayoutExporter.export(
        	textFlow, ConversionType.XML_TYPE) as XML;
        	
 		var p:String;
		
		// The default configuration deliberately specifies "inherit"
		// for the value of non-inheriting formats,
		// which causes the importers to set the corresponding
		// formats on the new TextFlow to "inherit"
		// if they weren't specified in the markup.
		// Without this, the TextFlow would use default values
		// for these non-inheriting formats rather than getting
		// them from the hostFormat determined by the CSS styles
		// of the Flex component.
		// But the result at export time is unexpected attributes
		// such as verticalAlign="inherit" on the TextFlow tag
		// which don't come from the original markup.
		// Therefore, we remove them here.

        // If the TextFlow tag has attributes for non-inheriting formats
        // with the value "inherit", remove them.
        var n:int = configInheritingFormats.length;
        for (var i:int = 0; i < n; i++)
        {
        	p = configInheritingFormats[i];
        	if (xml.@[p] == FormatValue.INHERIT)
        		delete xml.@[p];
        }
        	
        // Also remove the annoying whiteSpaceCollapse attribute
        // which is irrelevant after the flow has been imported.
        //delete xml.@["whiteSpaceCollapse"];
        
        return xml;
    }
}

}
