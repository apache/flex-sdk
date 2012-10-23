/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.css;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import flash.fonts.FontManager;
import flash.localization.LocalizationManager;
import flash.util.FileUtils;
import flash.util.Trace;
import flex2.compiler.Logger;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;

import org.apache.flex.forks.batik.css.parser.Parser;
import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.CSSParseException;
import org.w3c.css.sac.ErrorHandler;
import org.w3c.css.sac.InputSource;

/**
 * The class is a wrapper around the Batik CSS Parser.  It uses a
 * StyleDocumentHandler to handle the Batik CSS Parser's callbacks.
 * The Rule instances that StyleDocumentHandler creates and populates
 * are handed back to this class and stored in the <code>rules</code>.
 * Batik CSS Parser errors and warnings are reported via the passed in
 * Logger.
 *
 * @author Paul Reilly
 */
public class StyleParser
{
    private int ruleIndex = 0;
    private List<Rule> rules = new ArrayList<Rule>();
	private String cssPath;
    private boolean errorsExist = false;
	private String mxmlPath;
	private int mxmlLineNumberOffset;
    private Logger messageHandler;
	private FontManager fontManager;
    private Parser parser;
    private boolean checkDeprecation;

    public StyleParser(String cssPath, InputStream inputStream,
                       final Logger handler, FontManager fontManager,
                       boolean checkDeprecation)
    {
        this.cssPath = cssPath;
        this.fontManager = fontManager;
        this.checkDeprecation = checkDeprecation;

        try
        {
            BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream);
            String charsetName = null;
            
            try
            {
                charsetName = StyleParser.readCSSCharset(bufferedInputStream);
            }
            catch (StyleSheetInvalidCharset e)
            {
                // add filename to exception and log warning.
                LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
                String message = l10n.getLocalizedTextString(
                            new StyleSheetInvalidCharset(cssPath, e.charsetName));
                handler.logError(message);
                return;
            }

            FileUtils.consumeBOM(bufferedInputStream, charsetName);
            init(new InputStreamReader(bufferedInputStream, charsetName), handler);
        }
        catch (IOException ioException)
        {
            handler.logError(cssPath, -1, ioException.getLocalizedMessage());
            if (Trace.css || Trace.error)
            {
                ioException.printStackTrace();
            }            
        }
    }

	public StyleParser(String mxmlPath, int mxmlLineNumber, Reader reader,
                       final Logger handler, FontManager fontManager, boolean checkDeprecation)
	{
        this.mxmlPath = mxmlPath;
        // preilly: We subtract one here, because if we have the following:
        //
        // 1 <mx:Application>
        // 2   <mx:Style>
        // 3     Application { backgroundColor: red }
        // 4   </mx:Style>
        // 5 </mx:Application>
        //
        // the mxmlLineNumber passed in will be 2 and the "Application" Selector's line
        // number will be 2 as far as the CSS Parser is concerned, so if we want to report
        // the "Application" Selector's line number in the mxml file, we need to subtract
        // 1 after adding the two line numbers, ie 2 + 2 - 1 = 3.
        this.mxmlLineNumberOffset = mxmlLineNumber - 1;
		this.fontManager = fontManager;
        this.checkDeprecation = checkDeprecation;
		init(reader, handler);
	}

	public StyleParser(String cssPath, Reader reader, final Logger handler,
                       FontManager fontManager, boolean checkDeprecation)
	{
		this.cssPath = cssPath;
		this.fontManager = fontManager;
        this.checkDeprecation = checkDeprecation;
		init(reader, handler);
	}

	private void init(Reader reader, final Logger handler)
	{
		try
		{
			messageHandler = handler; //PJF: Batik SAC needs a better error interface for DocumentHandlers!

			ErrorHandler errorHandler = new ErrorHandler() {
				public void error(CSSParseException exception) throws CSSException
				{
                    if (mxmlPath != null)
                    {
                        handler.logError(mxmlPath, exception.getLineNumber(),
                                      StyleParserErrorTranslator.getUserFriendlyErrror(exception.getMessage()));
                        errorsExist = true;
                    }
                    else
                    {
                        handler.logError(cssPath, exception.getLineNumber(), StyleParserErrorTranslator.getUserFriendlyErrror(exception.getMessage()));
                        errorsExist = true;
                    }
				}

				public void fatalError(CSSParseException exception) throws CSSException
				{
                    if (mxmlPath != null)
                    {
                        handler.logError(mxmlPath, exception.getLineNumber(),
                                      StyleParserErrorTranslator.getUserFriendlyErrror(exception.getMessage()));
                        errorsExist = true;
                    }
                    else
                    {
                        handler.logError(cssPath, exception.getLineNumber(), StyleParserErrorTranslator.getUserFriendlyErrror(exception.getMessage()));
                        errorsExist = true;
                    }
				}

				public void warning(CSSParseException exception) throws CSSException
				{
                    if (mxmlPath != null)
                    {
                        handler.logWarning(mxmlPath, exception.getLineNumber(),
                                        StyleParserErrorTranslator.getUserFriendlyErrror(exception.getMessage()));
                    }
                    else
                    {
                        handler.logWarning(cssPath, exception.getLineNumber(), StyleParserErrorTranslator.getUserFriendlyErrror(exception.getMessage()));
                    }
				}
			};

            parser = new Parser();
            parser.setLineNumberOffset(mxmlLineNumberOffset);
			parser.setDocumentHandler( new StyleDocumentHandler(this) );
			parser.setErrorHandler(errorHandler);
			parser.parseStyleSheet(new InputSource(reader));
		}
		catch (Exception exception)
		{
            String path;
            if (mxmlPath != null)
            {
                path = mxmlPath;
            }
            else
            {
                path = cssPath;
            }

            handler.logError(path, -1, StyleParserErrorTranslator.getUserFriendlyErrror(exception.getLocalizedMessage()));
            if (Trace.css || Trace.error)
            {
                exception.printStackTrace();
            }
		}
	}

    public boolean errorsExist()
    {
        return errorsExist;
    }

    // preilly: Be careful using this method, because in some cases,
    // org.apache.flex.forks.batik.css.parser.Parser calls nextIgnoreSpaces() before calling handler
    // functions, so the line number could have been advanced one or more times.  We store
    // line numbers in CSSLexicalUnit's and DefaultElementSelector's when they are
    // created, so if possible get the line number from there instead of here.
    public int getLineNumber()
    {
        return parser.getLineNumber();
    }

    int getMxmlLineNumber()
    {
        return mxmlLineNumberOffset;
    }

	public String getPath()
	{
        String path = mxmlPath;

        if (path == null)
        {
            path = cssPath;
        }

        return path;
	}

    public void addRule(Rule rule)
    {
        rules.add(rule);
    }

    public List<Rule> getRules()
    {
        return rules;
    }

    public Rule parseRule()
    {
        return rules.get(ruleIndex++);
    }

	public FontManager getFontManager()
	{
		return fontManager;
	}

	public void warnDeprecation(String deprecated, String replacement, int lineNumber)
	{
        if (checkDeprecation)
        {
            LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
            String message = l10n.getLocalizedTextString(new DeprecatedWarning(deprecated, replacement, "3.0"));

            if (mxmlPath != null)
            {
                messageHandler.logWarning(mxmlPath, lineNumber, message);
            }
            else
            {
                messageHandler.logWarning(cssPath, lineNumber, message);
            }
        }
	}
	
	public void warning(CSSException cssException)
	{
        if ((Trace.css || Trace.error) && cssException.getException() != null)
        {
            cssException.getException().printStackTrace();
        }

        if (mxmlPath != null)
        {
            int lineNumber = parser.getLineNumber();
            messageHandler.logWarning(mxmlPath, lineNumber,
                    StyleParserErrorTranslator.getUserFriendlyErrror(cssException.getMessage()));
        }
        else
        {
            int lineNumber = parser.getLineNumber();
            messageHandler.logWarning(cssPath, lineNumber,
                    StyleParserErrorTranslator.getUserFriendlyErrror(cssException.getMessage()));
        }
	}

	public void error(CSSException cssException)
	{
        if ((Trace.css || Trace.error) && cssException.getException() != null)
        {
            cssException.getException().printStackTrace();
        }

        if (mxmlPath != null)
        {
            int lineNumber = parser.getLineNumber();
            messageHandler.logError(mxmlPath, lineNumber,
                    StyleParserErrorTranslator.getUserFriendlyErrror(cssException.getMessage()));
        }
        else
        {
            int lineNumber = parser.getLineNumber();
            messageHandler.logError(cssPath, lineNumber,
                    StyleParserErrorTranslator.getUserFriendlyErrror(cssException.getMessage()));
        }
	}
	
    /**
     * Discover the file encoding of a CSS file by reading the first few bytes of the file.
     * If a charset rule or a BOM is not present then assume the file is UTF-8.
     * 
     * see http://www.w3.org/TR/CSS21/syndata.html#charset.
     * 
     * Limitations: UTF-16 encoding is only detect by the presence of a BOM.
     *              Charset rule not read if a UTF-16 BOM is found. 
     *        
     * 
     * @param in - must be positioned at the beginning of the file.
     * @return charset encoding of the file
     * @throws IOException
     * @throws StyleSheetInvalidCharset - if the encoding specified in the charset rule
     *         is invalid or not supported.
     * 
     */
    public static String readCSSCharset(BufferedInputStream in) throws IOException, StyleSheetInvalidCharset
    {
        // The leading bytes of the file can tell us the BOM and if a @charset rule 
        // is present.
        byte[][] leadingBytes = { {(byte) 0xEF, (byte) 0xBB, (byte) 0xBF, // utf-8 bom, as specified
                                0x40, 0x63, 0x68, 0x61, 0x72, 0x73, 0x65,
                                0x74, 0x20, 0x22},
                                {(byte) 0xEF, (byte) 0xBB, (byte) 0xBF},   // utf-8
                                {0x40, 0x63, 0x68, 0x61, 0x72, 0x73, 0x65, // ascii, as specified
                                 0x74, 0x20, 0x22},
                                {(byte) 0xFE, (byte) 0xFF},                // UTF-16BE
                                {(byte) 0xFF, (byte) 0xFE}                 // UTF-16LE
        };
        
        // matching array of charsets for leadingBytes array. 
        // "specified" means an @charset rule was found as we need to read the charset 
        // encoding.
        // NOTE: We don't attempt to read charset rules for UTF-16 formats. This is a 
        // extra work and we know the charset must be UTF-16 if we were able
        // to read the @charset rule. Does not seem worth the effort since if we read 
        // it we could only throw out the css file if the encoding was not valid.
        String[] charsetTable = { "specified", "UTF-8", "specified", 
                                  "UTF-16BE", "UTF-16LE"}; 
        String charset = "UTF-8";                // default return value
        int maxCharsetName = 40;
        int maxBytesToRead = 2 + ((12 + maxCharsetName));   // calculated for 8 bit and 16 bit cases only 
        in.mark(maxBytesToRead + 1);
        
        int found = -1;     // index into leadingBytes if there is a match
        byte[] buffer = new byte[maxBytesToRead];
    
        
        // read bytes
        int results = in.read(buffer); // max number of bytes read to determine charset
        if (results == -1) {
            return charset;
        }
        
        // find a match
        for (int i = 0; i < leadingBytes.length; i++) {
            byte[] bytes = leadingBytes[i];
            found = i;
            for (int j = 0; j < bytes.length; j++) {
                if (bytes[j] != buffer[j]) {
                    found = -1;
                    break;
                }
            }
            
            if (found != -1) {
                break;
            }
        }
    
        // if found a match, then look more closely
        if (found != -1)
        {
            if ("specified".equals(charsetTable[found]))
            {
    
                // read specified charset followed by the bytes 22 (quote), 3B
                // (semicolon)
                int charsetIndex = leadingBytes[found].length;
                int charsetLength = 0;
                int quotePosition = -1;
                for (int i = leadingBytes[found].length; i < buffer.length; i++)
                {
                    if (buffer[i] == 0x22)
                    { // end quotes of
                        quotePosition = i;
                        break;
                    }
                    charsetLength++;
                }
    
                // if found a quote followed by a semicolon
                if (quotePosition > 0 && (quotePosition + 1) < buffer.length
                        && buffer[quotePosition + 1] == 0x3B)
                {
    
                    // get specified name and test it.
                    String testCharset = new String(buffer, charsetIndex,
                                                    charsetLength, "US-ASCII");
                    try
                    {
                        // must be able to read in @charset rule using encoding
                        in.reset();
                        InputStreamReader reader = new InputStreamReader(in,
                                                                        testCharset);
                        char[] chBuf = new char[2 + 12 + charsetLength]; // bom + @charset ""; + charset
                        reader.read(chBuf);
    
                        String specifiedCharaset = new String(chBuf);
                        if (specifiedCharaset.indexOf(testCharset) == -1)
                        {
                            in.reset();
                            throw new StyleSheetInvalidCharset("", testCharset);
                        } else
                        {
                            charset = testCharset; // found valid charset
                        }
                    } catch (UnsupportedEncodingException e)
                    {
                        in.reset();
                        throw new StyleSheetInvalidCharset("", testCharset);
                    }
                }
            } else
            {
                charset = charsetTable[found];
            }
        }
        
        in.reset();
        
        return charset;
    }

    public static class DeprecatedWarning extends CompilerMessage.CompilerWarning
    {
    	private static final long serialVersionUID = 3832979911761729776L;

        public DeprecatedWarning(String var, String replacement, String since)
    	{
    		this.var = var;
    		this.replacement = replacement;
    		this.since = since;
    	}
    	
    	public final String var, replacement, since;
    }

    public static class StyleSheetInvalidCharset extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -4363998590309962624L;
        public StyleSheetInvalidCharset(String stylePath, String charsetName)
        {
            super();
            this.stylePath = stylePath;
            this.charsetName = charsetName;
        }
    
        public final String stylePath;
        public final String charsetName;
    }
}
