/* this file based on Batik's ImageTranscoder class, which is ... */

/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */

package flash.svg;

import org.apache.flex.forks.batik.transcoder.XMLAbstractTranscoder;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscodingHints;
import org.apache.flex.forks.batik.transcoder.image.resources.Messages;
import org.apache.flex.forks.batik.transcoder.keys.BooleanKey;
import org.apache.flex.forks.batik.transcoder.keys.StringKey;
import org.apache.flex.forks.batik.transcoder.keys.FloatKey;
import org.apache.flex.forks.batik.transcoder.keys.PaintKey;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.util.XMLResourceDescriptor;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.svg.SAXSVGDocumentFactory;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.dom.util.DocumentFactory;
import org.apache.flex.forks.batik.bridge.*;
import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.svg.SVGAElement;
import org.w3c.dom.svg.SVGDocument;

import java.awt.Dimension;
import java.awt.Cursor;
import java.awt.Point;
import java.awt.geom.Dimension2D;
import java.awt.geom.AffineTransform;
import java.util.Set;
import java.util.HashSet;
import java.util.Vector;
import java.util.Iterator;
import java.util.StringTokenizer;

import flash.swf.types.TagList;
import flash.swf.types.Rect;
import flash.graphics.g2d.SpriteGraphics2D;

/**
 * A transcoder for converting SVG into SWF tags.  This class was a
 * <tt>JPEGTranscoder</tt> that produced a JPEG image.  It was
 * modified to produce SWF tags instead.  Batik's GVT module already
 * renders to any Graphics2D.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @author Edwin Smith
 * @author Peter Farland
 */
public class SpriteTranscoder extends XMLAbstractTranscoder
{
	public SpriteTranscoder()
	{
		hints.put(KEY_DOCUMENT_ELEMENT_NAMESPACE_URI, SVGConstants.SVG_NAMESPACE_URI);
		hints.put(KEY_DOCUMENT_ELEMENT, SVGConstants.SVG_SVG_TAG);
		hints.put(KEY_DOM_IMPLEMENTATION, SVGDOMImplementation.getDOMImplementation());
		hints.put(KEY_MEDIA, "screen");
		hints.put(KEY_EXECUTE_ONLOAD, Boolean.FALSE);
		hints.put(KEY_ALLOWED_SCRIPT_TYPES, DEFAULT_ALLOWED_SCRIPT_TYPES);
	}

    /**
     * Transcodes the specified Document as an image in the specified output.
     *
     * @param document the document to transcode
     * @param uri the uri of the document or null if any
     * @param output the ouput where to transcode
     * @exception org.apache.flex.forks.batik.transcoder.TranscoderException if an error occurred while transcoding
     */
    protected void transcode(Document document,
                             String uri,
                             TranscoderOutput output)
            throws TranscoderException
    {

        if (!(document instanceof SVGOMDocument))
        {
            throw new TranscoderException(
                    Messages.formatMessage("notsvg", null));
        }

        BridgeContext ctx = new BridgeContext(userAgent);
        SVGOMDocument svgDoc = (SVGOMDocument) document;

        // build the GVT tree
        GraphicsNode gvtRoot = buildGVT(ctx, svgDoc);

        // get the 'width' and 'height' attributes of the SVG document
        width = (int) (ctx.getDocumentSize().getWidth() + 0.5);
        height = (int) (ctx.getDocumentSize().getHeight() + 0.5);

        SpriteGraphics2D swf2d = new SpriteGraphics2D(width, height);
		gvtRoot.paint(swf2d);
		tags = swf2d.getTags();

		//Override width and height based on the SWF-specific bounds of the sprite contents
		//However we have to correct co-ordinates back to pixels... TODO: Remove all TWIPS references!
		Rect bounds = swf2d.getBounds();
		width = (int)Math.rint((bounds.xMax - bounds.xMin)/20.0);
		height = (int)Math.rint((bounds.yMax - bounds.yMin)/20.0);
    }

	public TagList getTags()
	{
		return tags;
	}

	public int getHeight()
	{
		return height;
	}

	public int getWidth()
	{
		return width;
	}

    protected GraphicsNode buildGVT(BridgeContext ctx, SVGOMDocument svgDoc) throws TranscoderException
    {
        GVTBuilder builder = new GVTBuilder();
        GraphicsNode gvtRoot;
        try
        {
            gvtRoot = builder.build(ctx, svgDoc);
            // dispatch an 'onload' event if needed
            if (ctx.isDynamic())
            {
                BaseScriptingEnvironment se = new BaseScriptingEnvironment(ctx);
                se.loadScripts();
                se.dispatchSVGLoadEvent();
            }
        }
        catch (BridgeException ex)
        {
            throw new TranscoderException(ex);
        }
        return gvtRoot;
    }

    /**
     * Creates a <tt>DocumentFactory</tt> that is used to create an SVG DOM
     * tree. The specified DOM Implementation is ignored and the Batik
     * SVG DOM Implementation is automatically used.
     *
     * @param domImpl the DOM Implementation (not used)
     * @param parserClassname the XML parser classname
     */
    protected DocumentFactory createDocumentFactory(DOMImplementation domImpl,
                                                    String parserClassname)
    {
        return new SAXSVGDocumentFactory(parserClassname);
    }


	/** A list of DefineTags, useful to construct a SWF DefineSprite */
	private TagList tags;
	private int width;
	private int height;


	/** The user agent dedicated to an <tt>SpriteTranscoder</tt>. */
	protected final UserAgent userAgent = new SpriteTranscoder.SwfTranscoderUserAgent();


	/**
	 * A user agent implementation for <tt>SwfTranscoder</tt>.
	 */
	final class SwfTranscoderUserAgent implements UserAgent
	{
		/**
		 * Vector containing the allowed script types
		 */
		Vector<String> scripts;

		/**
		 * Returns the default size of this user agent (400x400).
		 */
		public final Dimension2D getViewportSize()
		{
			return new Dimension(400, 400);
		}

		/**
		 * Displays the specified error using the <tt>ErrorHandler</tt>.
		 */
		public final void displayError(Exception e)
		{
			try
			{
				SpriteTranscoder.this.handler.error
						(new TranscoderException(e));
			}
			catch (TranscoderException ex)
			{
				throw new RuntimeException();
			}
		}

		/**
		 * Displays the specified message using the <tt>ErrorHandler</tt>.
		 */
		public final void displayMessage(String message)
		{
			try
			{
				SpriteTranscoder.this.handler.warning
						(new TranscoderException(message));
			}
			catch (TranscoderException ex)
			{
				throw new RuntimeException();
			}
		}

		/**
		 * Shows an alert dialog box.
		 */
		public final void showAlert(String message)
		{
		}

		public final void deselectAll()
		{
		}
		
		/**
		 * Shows a prompt dialog box.
		 */
		public final String showPrompt(String message)
		{
			return null;
		}

		/**
		 * Shows a prompt dialog box.
		 */
		public final String showPrompt(String message, String defaultValue)
		{
			return null;
		}

		/**
		 * Shows a confirm dialog box.
		 */
		public final boolean showConfirm(String message)
		{
			return false;
		}

		/**
		 * Returns the pixel to millimeter conversion factor specified in the
		 * <tt>TranscodingHints</tt> or 0.3528 if any.
		 */
		public final float getPixelToMM()
		{
			if (SpriteTranscoder.this.hints.containsKey(KEY_PIXEL_TO_MM))
			{
				return ((Float) SpriteTranscoder.this.hints.get(KEY_PIXEL_TO_MM)).floatValue();
			}
			else
			{
				//return 0.3528f; // 72 dpi
				return 0.26458333333333333333333333333333f; // 96dpi
			}
		}

		/**
		 * Returns the user language specified in the
		 * <tt>TranscodingHints</tt> or "en" (english) if any.
		 */
		public final String getLanguages()
		{
			if (SpriteTranscoder.this.hints.containsKey(KEY_LANGUAGE))
			{
				return (String) SpriteTranscoder.this.hints.get(KEY_LANGUAGE);
			}
			else
			{
				return "en";
			}
		}



		/**
		 * Returns the user stylesheet specified in the
		 * <tt>TranscodingHints</tt> or null if any.
		 */
		public final String getUserStyleSheetURI()
		{
			return (String) SpriteTranscoder.this.hints.get(KEY_USER_STYLESHEET_URI);
		}

		/**
		 * Returns the XML parser to use from the TranscodingGetHints().
		 */
		public final String getXMLParserClassName()
		{
			if (SpriteTranscoder.this.hints.containsKey(KEY_XML_PARSER_CLASSNAME))
			{
				return (String) SpriteTranscoder.this.hints.get(KEY_XML_PARSER_CLASSNAME);
			}
			else
			{
				return XMLResourceDescriptor.getXMLParserClassName();
			}
		}

		/**
		 * Returns true if the XML parser must be in validation mode, false
		 * otherwise.
		 */
		public final boolean isXMLParserValidating()
		{
			return ((Boolean) SpriteTranscoder.this.hints.get
					(KEY_XML_PARSER_VALIDATING)).booleanValue();
		}

		/**
		 * Returns this user agent's CSS media.
		 */
		public final String getMedia()
		{
			return (String) hints.get(KEY_MEDIA);
		}

		/**
		 * Returns this user agent's alternate style-sheet title.
		 */
		public final String getAlternateStyleSheet()
		{
			return (String) hints.get(KEY_ALTERNATE_STYLESHEET);
		}

		/**
		 * Unsupported operation.
		 */
		public final EventDispatcher getEventDispatcher()
		{
			return null;
		}

		/**
		 * Unsupported operation.
		 */
		public final void openLink(SVGAElement elt)
		{
		}

		/**
		 * Unsupported operation.
		 */
		public final void setSVGCursor(Cursor cursor)
		{
		}

		/**
		 * Unsupported operation.
		 */
		public final AffineTransform getTransform()
		{
			return null;
		}

		/**
		 * Unsupported operation.
		 */
		public final Point getClientAreaLocationOnScreen()
		{
			return new Point();
		}

		/**
		 * Tells whether the given feature is supported by this
		 * user agent.
		 */
		public final boolean hasFeature(String s)
		{
			return FEATURES.contains(s);
		}

		final Set<String> extensions = new HashSet<String>();

		/**
		 * Tells whether the given extension is supported by this
		 * user agent.
		 */
		public final boolean supportExtension(String s)
		{
			return extensions.contains(s);
		}

		/**
		 * Lets the bridge tell the user agent that the following
		 * extension is supported by the bridge.
		 */
        public final void registerExtension(BridgeExtension ext)
		{
            // getImplementedExtensions() returns a String iterator according to Apache docs
            @SuppressWarnings("unchecked")
			Iterator<String> i = ext.getImplementedExtensions();
			while (i.hasNext())
				extensions.add(i.next());
		}


		/**
		 * Notifies the UserAgent that the input element
		 * has been found in the document. This is sometimes
		 * called, for example, to handle &lt;a&gt; or
		 * &lt;title&gt; elements in a UserAgent-dependant
		 * way.
		 */
		public final void handleElement(Element elt, Object data)
		{
		}

		public float getPixelUnitToMillimeter()
		{
			if (SpriteTranscoder.this.hints.containsKey(KEY_PIXEL_TO_MM))
			{
				return ((Float) SpriteTranscoder.this.hints.get(KEY_PIXEL_TO_MM)).floatValue();
			}
			else
			{
				//return 0.3528f; // 72 dpi
				return 0.26458333333333333333333333333333f; // 96dpi
			}
		}

		public float getMediumFontSize()
		{
			return 14.0f;
		}

		public float getLighterFontWeight(float v)
		{
			return 100f;
		}

		public float getBolderFontWeight(float v)
		{
			return 700f;
		}

		public String getDefaultFontFamily()
		{
			return "Arial";
		}

		public void setTransform(AffineTransform affineTransform)
		{
		}

		public void setTextSelection(Mark mark, Mark mark1)
		{
		}

		public void checkLoadScript(String s, ParsedURL parsedURL, ParsedURL parsedURL1) throws SecurityException
		{
		}

		public ExternalResourceSecurity getExternalResourceSecurity(ParsedURL parsedURL, ParsedURL parsedURL1)
		{
			return null;
		}

		public void checkLoadExternalResource(ParsedURL parsedURL, ParsedURL parsedURL1) throws SecurityException
		{
		}

		/**
		 * Returns the security settings for the given script
		 * type, script url and document url
		 *
		 * @param scriptType type of script, as found in the
		 *        type attribute of the &lt;script&gt; element.
		 * @param scriptURL url for the script, as defined in
		 *        the script's xlink:href attribute. If that
		 *        attribute was empty, then this parameter should
		 *        be null
		 * @param docURL url for the document into which the
		 *        script was found.
		 */
		public ScriptSecurity getScriptSecurity(String scriptType, ParsedURL scriptURL, ParsedURL docURL)
		{
			if (scripts == null)
			{
				computeAllowedScripts();
			}

			if (!scripts.contains(scriptType))
			{
				return new NoLoadScriptSecurity(scriptType);
			}


			boolean constrainOrigin = true;

			if (SpriteTranscoder.this.hints.containsKey(KEY_CONSTRAIN_SCRIPT_ORIGIN))
			{
				constrainOrigin =
						((Boolean) SpriteTranscoder.this.hints.get
						(KEY_CONSTRAIN_SCRIPT_ORIGIN)).booleanValue();
			}

			if (constrainOrigin)
			{
				return new DefaultScriptSecurity(scriptType, scriptURL, docURL);
			}
			else
			{
				return new RelaxedScriptSecurity(scriptType,  scriptURL,  docURL);
			}
		}

		/**
		 * Helper method. Builds a Vector containing the allowed
		 * values for the &lt;script&gt; element's type attribute.
		 */
		final void computeAllowedScripts()
		{
			scripts = new Vector<String>();
			if (!SpriteTranscoder.this.hints.containsKey(KEY_ALLOWED_SCRIPT_TYPES))
			{
				return;
			}

			String allowedScripts
					= (String) SpriteTranscoder.this.hints.get(KEY_ALLOWED_SCRIPT_TYPES);

			StringTokenizer st = new StringTokenizer(allowedScripts, ",");
			while (st.hasMoreTokens())
			{
				scripts.addElement(st.nextToken());
			}
		}
		
		public SVGDocument getBrokenLinkDocument(Element e, String url, String message)
		{
			return null;
		}

	}

	// --------------------------------------------------------------------
	// Keys definition
	// --------------------------------------------------------------------


	protected final static Set<String> FEATURES = new HashSet<String>();

	static
	{
		FEATURES.add(SVGConstants.SVG_ORG_W3C_SVG_FEATURE);
		//FEATURES.add(SVGConstants.SVG_ORG_W3C_SVG_LANG_FEATURE);
		FEATURES.add(SVGConstants.SVG_ORG_W3C_SVG_STATIC_FEATURE);
	}

	// --------------------------------------------------------------------
	// Keys definition
	// --------------------------------------------------------------------

	/**
	 * The 'onload' execution key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_EXECUTE_ONLOAD</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">Boolean</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">false</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify if scripts added on the 'onload' event
	 * attribute must be invoked.</TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_EXECUTE_ONLOAD
			= new BooleanKey();

	/**
	 * The language key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_LANGUAGE</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">String</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">"en"</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify the preferred language of the document.
	 * </TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_LANGUAGE
			= new StringKey();

	/**
	 * The media key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_MEDIA</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">String</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">"screen"</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify the media to use with CSS.
	 * </TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_MEDIA
			= new StringKey();

	/**
	 * The alternate stylesheet key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_ALTERNATE_STYLESHEET</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">String</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">null</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify the alternate style sheet title.
	 * </TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_ALTERNATE_STYLESHEET
			= new StringKey();

	/**
	 * The user stylesheet URI key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_USER_STYLESHEET_URI</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">String</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">null</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify the user style sheet.</TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_USER_STYLESHEET_URI
			= new StringKey();

	/**
	 * The pixel to millimeter conversion factor key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_PIXEL_TO_MM</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">Float</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">0.33</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify the pixel to millimeter conversion factor.
	 * </TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_PIXEL_TO_MM
			= new FloatKey();

	/**
	 * The image background paint key.
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_BACKGROUND_COLOR</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">Paint</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">null</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specify the background color to use.
	 * The color is required by opaque image formats and is used by
	 * image formats that support alpha channel.</TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_BACKGROUND_COLOR
			= new PaintKey();

	/**
	 * The forceTransparentWhite key.
	 *
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_FORCE_TRANSPARENT_WHITE</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">Boolean</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">false</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>

	 * <TD VALIGN="TOP">It controls whether the encoder should force
	 * the image's fully transparent pixels to be fully transparent
	 * white instead of fully transparent black.  This is usefull when
	 * the encoded file is displayed in a browser which does not
	 * support transparency correctly and lets the image display with
	 * a white background instead of a black background. <br />
	 *
	 * However, note that the modified image will display differently
	 * over a white background in a viewer that supports
	 * transparency.<br/>
	 *
	 * Not all Transcoders use this key (in particular some formats
	 * can't preserve the alpha channel at all in which case this
	 * is not used.
	 * </TD></TR>
	 * </TABLE>
	 */
	public static final TranscodingHints.Key KEY_FORCE_TRANSPARENT_WHITE
			= new BooleanKey();

	/**
	 * The set of supported script languages (i.e., the set of possible
	 * values for the &lt;script&gt; tag's type attribute).
	 *
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_ALLOWED_SCRIPT_TYPES</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">String (Comma separated values)</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">text/ecmascript, application/java-archive</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">Specifies the allowed values for the type attribute
	 * in the &lt;script&gt; element. This is a comma separated list. The
	 * special value '*' means that all script types are allowed.
	 * </TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_ALLOWED_SCRIPT_TYPES
			= new StringKey();

	/**
	 * Default value for the KEY_ALLOWED_SCRIPT_TYPES key
	 */
	protected static final String DEFAULT_ALLOWED_SCRIPT_TYPES
			= SVGConstants.SVG_SCRIPT_TYPE_ECMASCRIPT + ", "
			+ SVGConstants.SVG_SCRIPT_TYPE_JAVA;

	/**
	 * Controls whether or not scripts can only be loaded from the
	 * same location as the document which references them.
	 *
	 * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
	 * <TD VALIGN="TOP">KEY_CONSTRAIN_SCRIPT_ORIGIN</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
	 * <TD VALIGN="TOP">boolean</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
	 * <TD VALIGN="TOP">true</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
	 * <TD VALIGN="TOP">No</TD></TR>
	 * <TR>
	 * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
	 * <TD VALIGN="TOP">When set to true, script elements referencing
	 * files from a different origin (server) than the document containing
	 * the script element will not be loaded. When set to true, script elements
	 * may reference script files from any origin.
	 * </TD></TR>
	 * </TABLE>
	 */
	protected static final TranscodingHints.Key KEY_CONSTRAIN_SCRIPT_ORIGIN
			= new BooleanKey();

}
