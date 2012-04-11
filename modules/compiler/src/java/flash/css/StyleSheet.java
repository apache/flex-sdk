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

import java.io.Reader;
import java.io.InputStream;
import java.util.List;

import org.w3c.dom.Node;
import org.w3c.dom.stylesheets.MediaList;
import flash.fonts.FontManager;
import flex2.compiler.Logger;

/**
 * Represents a CSS stylesheet.  Consumers will typically call one of
 * the parse() methods and then getCssRules().
 *
 * @author Paul Reilly
 */
public class StyleSheet
{
    private List<Rule> rules;
    private boolean disabled;
    private boolean errorsExist;
    private boolean checkDeprecation;

    public StyleSheet()
    {
    }
    
    public void checkDeprecation(boolean checkDeprecation)
    {
    	this.checkDeprecation = checkDeprecation;
    }

	/**
	 * If using an internal stylesheet, and the path to the MXML
	 * document is known, then provide it to the parser using this
	 * method so that relative paths such as font file locations can
	 * be resolved.
	 *
	 * @param mxmlPath - full path to enclosing MXML document
	 * @param mxmlLineNumber
	 * @param reader
	 * @param handler
	 * @param fontManager
	 * @return a StyleSheet
	 */
	public StyleSheet parse(String mxmlPath, int mxmlLineNumber, Reader reader,
                            Logger handler, FontManager fontManager)
	{
        assert (mxmlPath != null);
		StyleParser styleParser = new StyleParser(mxmlPath, mxmlLineNumber, reader,
                                                  handler, fontManager, checkDeprecation);
		rules = styleParser.getRules();

        errorsExist = styleParser.errorsExist();

        if (!errorsExist)
        {
            return this;
        }
        else
        {
            return null;
        }
	}

	/**
	 * If using an internal stylesheet, and the path to the CSS
	 * document is known, then provide it to the parser using this
	 * method so that relative paths such as font file locations can
	 * be resolved.
	 *
	 * @param cssPath - full path to external css file.
	 * @param reader
	 * @param handler
	 * @return a StyleSheet
	 */
	public StyleSheet parse(String cssPath, Reader reader, Logger handler,
                            FontManager fontManager)
	{
        assert (cssPath != null);
		StyleParser styleParser = new StyleParser(cssPath, reader, handler, fontManager, checkDeprecation);
		rules = styleParser.getRules();

        errorsExist = styleParser.errorsExist();

        if (!errorsExist)
        {
            return this;
        }
        else
        {
            return null;
        }
	}

	/**
     * This method is used to parse the global style sheet.
     *
	 * @param name - either a remote URL or local relative path to an MXML document
	 * @param handler
	 */
	public StyleSheet parse(String name, InputStream cssIn, Logger handler, FontManager fontManager)
	{
        assert (name != null);
		StyleParser styleParser = new StyleParser(name, cssIn, handler, fontManager, checkDeprecation);
		rules = styleParser.getRules();

        errorsExist = styleParser.errorsExist();

        if (!errorsExist)
        {
            return this;
        }
        else
        {
            return null;
        }
	}

    public boolean errorsExist()
    {
        return errorsExist;
    }

    public void deleteRule(int index)
    {
        if (rules != null)
        {
            rules.remove(index);
        }
    }

    public List<Rule> getCssRules()
    {
        return rules;
    }

    public boolean getDisabled()
    {
        return disabled;
    }

    public String getHref()
    {
        return null;
    }

    public MediaList getMedia()
    {
        return null;
    }

    public Node getOwnerNode()
    {
        return null;
    }

    public Rule getOwnerRule()
    {
        return null;
    }

    public org.w3c.dom.stylesheets.StyleSheet getParentStyleSheet()
    {
        return null;
    }

    public String getTitle()
    {
        return null;
    }

    public String getType()
    {
        return null;
    }

    public void setDisabled(boolean disabled)
    {
        this.disabled = disabled;
    }
}
