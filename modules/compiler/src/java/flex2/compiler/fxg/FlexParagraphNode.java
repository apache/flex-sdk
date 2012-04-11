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

package flex2.compiler.fxg;

import com.adobe.internal.fxg.dom.text.ParagraphNode;

/**
 * A Flex specific override for ParagraphNode used catch attributes that need to
 * be renamed on a &lt;p&gt; tag.
 * 
 * @author Peter Farland
 * @since 1.0
 */
public class FlexParagraphNode extends ParagraphNode
{
    /**
     * Flex specific override to keep track of attributes that need to be
     * renamed.
     * 
     * @param name the attribute name
     * @param value the attribute value
     * @see ParagraphNode#setAttribute(String, String)
     * @see AbstractTextNode#setAttribute(String, String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        super.setAttribute(name, value);

        // Translate FXG attributes to equivalent Flex properties
        String newName = FlexTextGraphicNode.translateAttribute(name);
        if (!name.equals(newName))
        {
            if (textAttributes != null)
                textAttributes.remove(name);

            rememberAttribute(newName, value);
        }
    }
}
