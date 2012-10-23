/*

   Copyright 2000-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
 
/**
 *  Added by Adobe Flex.
 */

package org.apache.flex.forks.batik.css.parser;

import org.w3c.css.sac.LexicalUnit;

public final class CSSSACMediaExpression {
	private final String mediaFeature;
	private final LexicalUnit expr;
	
	CSSSACMediaExpression(String mediaFeature, LexicalUnit expr)
	{
		this.mediaFeature = mediaFeature;
		this.expr = expr;
	}
	
	public String getMediaFeature()
	{
		return mediaFeature;
	}
	
	public LexicalUnit getExpr()
	{
		return expr;
	}

	public void appendToStringBuffer(StringBuffer target)
	{
		target.append('(');
		target.append(mediaFeature);
		if (expr != null)
		{
			target.append(':');
			((CSSLexicalUnit)expr).appendToStringBuffer(target);
		}
		target.append(')');
	}
	
	public String toString()
	{
		StringBuffer buf = new StringBuffer();
		appendToStringBuffer(buf);
		return buf.toString();
	}
	
	
	
}
