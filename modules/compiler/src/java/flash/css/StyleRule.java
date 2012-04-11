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

import org.w3c.css.sac.SelectorList;

/**
 * Represents a CSS style rule.
 *
 * @author Pete Farland
 */
public class StyleRule extends Rule
{
	public StyleRule(SelectorList selectorList, String path, int lineNumber)
    {
		super(STYLE_RULE, path, lineNumber);
        this.selectorList = selectorList;
	}

	public String getSelectorText()
	{
		return selector;
	}

	public void setSelectorText(String s)
	{
        selector = s;
	}

	public SelectorList getSelectorList()
	{
		return selectorList;
	}

	private String selector;
	private SelectorList selectorList;

	public String toString()
	{
	    if (selectorList != null)
	        return selectorList.toString();
	    else
	        return getSelectorText();
	}
}
