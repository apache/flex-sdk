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

/**
 * This class represents an individual rule in a CSS ruleset.
 *
 * @author Paul Reilly
 */
public abstract class Rule
{
	public final static short UNKNOWN_RULE = 0;
	public final static short STYLE_RULE = 1;
	public final static short CHARSET_RULE = 2;
	public final static short IMPORT_RULE = 3;
	public final static short MEDIA_RULE = 4;
	public final static short FONT_FACE_RULE = 5;
	public final static short PAGE_RULE = 6;

	private String cssText;
    private Rule parentRule;
    private short type;
    private StyleSheet parentStyleSheet;
    int uniqueID;
	protected StyleDeclaration declaration;

	protected Rule(short type, String path, int lineNumber)
	{
		this.type = type;
		this.declaration = new StyleDeclaration(path, lineNumber);
	}

	public StyleDeclaration getStyleDeclaration()
	{
		return declaration;
	}

    public String getCssText()
    {
        return cssText;
    }

    public Rule getParentRule()
    {
        return parentRule;
    }

    public StyleSheet getParentStyleSheet()
    {
        return parentStyleSheet;
    }

    public short getType()
    {
        return type;
    }

    public int getUniqueID()
    {
        return uniqueID;
    }

    public void setCssText(String cssText)
    {
        this.cssText = cssText;
    }

    public void setParentRule(Rule parentRule)
    {
        this.parentRule = parentRule;
    }

    public void setParentStyleSheet(StyleSheet parentStyleSheet)
    {
        this.parentStyleSheet = parentStyleSheet;
    }

    public void setUniqueID(int uniqueID)
    {
        this.uniqueID = uniqueID;
    }

    // (Paul) This is busted.
    public String unparse()
    {
        return "";
    }
}
