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

import org.apache.flex.forks.batik.css.parser.CSSLexicalUnit;
import org.apache.flex.forks.batik.css.parser.DefaultConditionalSelector;
import org.apache.flex.forks.batik.css.parser.DefaultDescendantSelector;
import org.apache.flex.forks.batik.css.parser.DefaultElementSelector;
import org.w3c.css.sac.*;

/**
 * An implementation of DocumentHandler, which creates rules, hands
 * them off to the StyleParser, and populates them with descriptors.
 *
 * @author Paul Reilly
 */
public class StyleDocumentHandler implements DocumentHandler
{
    private StyleParser styleParser;
    private MediaRule currentMediaRule;
    private Rule currentRule;

    public StyleDocumentHandler(StyleParser styleParser)
    {
        this.styleParser = styleParser;
    }

    public void comment(String text)
    {
    }

    public void endDocument(InputSource source)
    {
    }

    public void endFontFace()
    {
		if ( currentRule != null )
        {
			if (currentRule instanceof FontFaceRule)
			{
				//Verify and collate information; prepare font for import
        		((FontFaceRule)currentRule).initialize(styleParser);
			}

			currentRule = currentRule.getParentRule();
        }
    }

    public void endMedia(SACMediaList media)
    {
        currentMediaRule = null;

        if (currentRule != null)
        {
            currentRule = currentRule.getParentRule();
        }
    }

    public void endPage(String name, String pseudo_page)
    {
    }

    public void endSelector(SelectorList selectors)
    {
        if ( currentRule != null )
        {
            currentRule = currentRule.getParentRule();
        }
    }

    public void ignorableAtRule(String atRule)
    {
    }

    public void importStyle(String uri, SACMediaList media, String defaultNamespaceURI)
    {
    }

    public void namespaceDeclaration(String prefix, String uri)
    {
    }

    /** one css rule declaration property, consisting of a name and a value. */
    public void property(String name, LexicalUnit value, boolean important)
    {
        currentRule.getStyleDeclaration().setDescriptor(name, value, important ? "important" : null);
        
        if ("flashType".equals(name) || "flash-type".equals(name))
        {
        	int lineNumber = (value instanceof CSSLexicalUnit) ? ((CSSLexicalUnit) value).getLineNumber() : styleParser.getLineNumber();
        	styleParser.warnDeprecation(name, "flashType".equals(name) ? "advancedAntiAliasing" : "advanced-anti-aliasing", lineNumber);
        }
    }

    public void startDocument(InputSource source)
    {
    }

    public void startFontFace()
    {
        // preilly: org.apache.flex.forks.batik.css.parser.Parser does not call nextIgnoreSpaces()
        // before calling startFontFace(), so the line number below should be ok.
		FontFaceRule rule = new FontFaceRule(styleParser.getPath(), styleParser.getLineNumber());

		if (currentRule == null)
		{
			currentRule = rule;
		}
		else
		{
			rule.setParentRule(currentRule);
			currentRule = rule;
		}

		styleParser.addRule(currentRule);
    }

    public void startMedia(SACMediaList media)
    {
        MediaList mediaList = new MediaList();
        for (int i = 0; i < media.getLength(); i++)
        {
            String m = media.item(i);
            mediaList.addQuery(m);
        }

        MediaRule rule = new MediaRule(mediaList, styleParser.getPath(), styleParser.getLineNumber());
        currentMediaRule = rule;

        if (currentRule == null)
        {
            currentRule = rule;
        }
        else
        {
            rule.setParentRule(currentRule);
            currentRule = rule;
        }

        // At-rules are invalid inside of @media rules, so we assume
        // they are top level
        styleParser.addRule(currentRule);
    }

    public void startPage(String name, String pseudo_page)
    {
    }

    public void startSelector(SelectorList selectors)
    {
        // preilly: By the time we get here, org.apache.flex.forks.batik.css.parser.Parser has called
        // nextIgnoreSpaces(), so the following line number could be off.  If the first
        // selector is an instance of DefaultElementSelector, grab the line number out of
        // it.  We have modified Parser to store the line number in
        // DefaultElementSelector's before calling nextIgnoreSpaces(), so it should be
        // dead nuts on.
        int lineNumber = styleParser.getLineNumber();
        Selector selector = selectors.item(0);

        if (selector instanceof DefaultConditionalSelector)
        {
            lineNumber = ((DefaultConditionalSelector)selector).getLineNumber();
        }
        else if (selector instanceof DefaultElementSelector)
        {
            lineNumber = ((DefaultElementSelector)selector).getLineNumber();
        }
        else if (selector instanceof DefaultDescendantSelector)
        {
            lineNumber = ((DefaultDescendantSelector)selector).getLineNumber();
        }

        StyleRule rule = new StyleRule(selectors, styleParser.getPath(), lineNumber);
        if ( currentRule == null )
        {
            currentRule = rule;
        }
        else
        {
            rule.setParentRule(currentRule);
            currentRule = rule;
        }

        if (currentMediaRule != null)
            currentMediaRule.addRule(currentRule);
        else
            styleParser.addRule(currentRule);
    }
}
