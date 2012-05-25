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

public class CSSSACMediaQuery {
	protected boolean not;
	protected String mediaType;
	protected int numExpressions;
	protected CSSSACMediaExpression[] expressions = new CSSSACMediaExpression[1];
	
	CSSSACMediaQuery(boolean not, String mediaType)
	{
		this.not = not;
		this.mediaType = mediaType;
	}
	
	public boolean isNot()
	{
		return not;
	}
	
	public String getMediaType()
	{
		return mediaType;
	}
	
	public int getNumExpressions()
	{
		return numExpressions;
	}
	
	public void appendExpression(CSSSACMediaExpression expr)
	{
		if (expr == null)
			return;
        if (numExpressions == expressions.length) {
        	CSSSACMediaExpression[] tmp = expressions;
        	expressions = new CSSSACMediaExpression[Math.max(expressions.length * 3 / 2, expressions.length + 1)];
            for (int i = 0; i < tmp.length; i++) {
            	expressions[i] = tmp[i];
            }
        }
        expressions[numExpressions++] = expr;
	}
	
	public CSSSACMediaExpression getExpression(int index)
	{
		if (index < 0 || index >= numExpressions) {
            return null;
        }
        return expressions[index];
	}

	public String toString() {
		StringBuffer buf = new StringBuffer();
		if (mediaType != null) {
			if (not)
				buf.append("not ");
			buf.append(mediaType);	
			for (int i = 0; i < numExpressions; ++i)
			{
				buf.append(" and ");
				expressions[i].appendToStringBuffer(buf);
			}
		}
		else {
			if (numExpressions > 0) {
				for (int i = 0; i < (numExpressions - 1); ++i)
				{
					expressions[i].appendToStringBuffer(buf);
					buf.append(" and ");
				}
				expressions[numExpressions - 1].appendToStringBuffer(buf);
			}
		}

		return buf.toString();
	}
	
	
}
