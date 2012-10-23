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
package org.apache.flex.forks.batik.util.gui.xmleditor;

import java.awt.Color;
import java.awt.Font;
import java.util.Map;
import java.util.HashMap;

import javax.swing.text.StyleContext;

/**
 * A pool of styles and their associated resources
 *
 * @author <a href="mailto:tonny@kiyut.com">Tonny Kohar</a>
 * @version $Id$
 */
public class XMLContext extends StyleContext {

    //public static String DEFAULT_SYNTAX          = "DEFAULT_SYNTAX";
    public static final String XML_DECLARATION_STYLE  = "xml_declaration";
    public static final String DOCTYPE_STYLE          = "doctype";
    public static final String COMMENT_STYLE          = "comment";
    public static final String ELEMENT_STYLE          = "element";
    public static final String CHARACTER_DATA_STYLE   = "character_data";
    public static final String ATTRIBUTE_NAME_STYLE   = "attribute_name";
    public static final String ATTRIBUTE_VALUE_STYLE  = "attribute_value";
    public static final String CDATA_STYLE            = "cdata";
    
    /** Map<String, Color> */
    protected Map syntaxForegroundMap = null;
    
    /** Map<String, Font> */
    protected Map syntaxFontMap = null;
    
    
    public XMLContext() {
        // initialize the default syntax highlight
        // could be integrated with Application Preferences
        
        String syntaxName;
        Font font;
        Color fontForeground;
        syntaxFontMap = new HashMap();
        syntaxForegroundMap = new HashMap();        

        Font defaultFont = new Font("Monospaced", Font.PLAIN, 12);
        
        syntaxName = XMLContext.DEFAULT_STYLE;
        font = defaultFont;
        fontForeground = Color.black;
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);
        
        syntaxName = XMLContext.XML_DECLARATION_STYLE;
        font = defaultFont.deriveFont(Font.BOLD);
        fontForeground = new Color(0, 0, 124);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);

        syntaxName = XMLContext.DOCTYPE_STYLE;
        font = defaultFont.deriveFont(Font.BOLD);
        fontForeground = new Color(0, 0, 124);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);
        
        syntaxName = XMLContext.COMMENT_STYLE;
        font = defaultFont;
        fontForeground = new Color(128, 128, 128);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);
        
        syntaxName = XMLContext.ELEMENT_STYLE;
        font = defaultFont;
        fontForeground = new Color(0, 0, 255);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);

        syntaxName = XMLContext.CHARACTER_DATA_STYLE;
        font = defaultFont;
        fontForeground = Color.black;
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);

        syntaxName = XMLContext.ATTRIBUTE_NAME_STYLE;
        font = defaultFont;
        fontForeground = new Color(0, 124, 0);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);

        syntaxName = XMLContext.ATTRIBUTE_VALUE_STYLE;
        font = defaultFont;
        fontForeground = new Color(153, 0, 107);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);

        syntaxName = XMLContext.CDATA_STYLE;
        font = defaultFont;
        fontForeground = new Color(124, 98, 0);
        syntaxFontMap.put(syntaxName, font);
        syntaxForegroundMap.put(syntaxName, fontForeground);
    }
    
    public XMLContext(Map syntaxFontMap, Map syntaxForegroundMap) {
        setSyntaxFont(syntaxFontMap);
        setSyntaxForeground(syntaxForegroundMap);
    }
    
    public void setSyntaxForeground(Map syntaxForegroundMap) {
        if (syntaxForegroundMap == null) {
            throw new IllegalArgumentException("syntaxForegroundMap can not be null");
        }
        this.syntaxForegroundMap = syntaxForegroundMap;
    }
    
    public void setSyntaxFont(Map syntaxFontMap) {
        if (syntaxFontMap == null) {
            throw new IllegalArgumentException("syntaxFontMap can not be null");
        }
        this.syntaxFontMap = syntaxFontMap;
    }
    
    public Color getSyntaxForeground(int ctx) {
        String name = getSyntaxName(ctx);
        return getSyntaxForeground(name);
    }
    
    public Color getSyntaxForeground(String name) {
        return (Color)syntaxForegroundMap.get(name);
    }
    
    public Font getSyntaxFont(int ctx) {
        String name = getSyntaxName(ctx);
        return getSyntaxFont(name);
    }
    
    public Font getSyntaxFont(String name) {
        return (Font)syntaxFontMap.get(name);
    }
    
    public String getSyntaxName(int ctx) {
        String name = CHARACTER_DATA_STYLE;
        switch (ctx) {
            case XMLScanner.XML_DECLARATION_CONTEXT:
                name = XML_DECLARATION_STYLE;
                break;
            case XMLScanner.DOCTYPE_CONTEXT:
                name = DOCTYPE_STYLE;
                break;
            case XMLScanner.COMMENT_CONTEXT:
                name = COMMENT_STYLE;
                break;
            case XMLScanner.ELEMENT_CONTEXT:
                name = ELEMENT_STYLE;
                break;
            case XMLScanner.ATTRIBUTE_NAME_CONTEXT:
                name = ATTRIBUTE_NAME_STYLE;
                break;
            case XMLScanner.ATTRIBUTE_VALUE_CONTEXT:
                name = ATTRIBUTE_VALUE_STYLE;
                break;
            case XMLScanner.CDATA_CONTEXT:
                name = CDATA_STYLE;
                break;
            default:
                // should not go here, just incase
                name = DEFAULT_STYLE;
                break;
        }
        return name;
    }
}
