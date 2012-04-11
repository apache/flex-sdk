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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;


/**
 * Selectors are used to match style declarations to components.
 * Supported selectors include simple type selectors, conditional
 * (based on the identity, styleName (class) or state (pseudo-element)
 * of a component), or descendant (based on the position in the
 * display list).
 *
 * @author Pete Farland
 */
public class StyleSelector
{
    public StyleSelector getAncestor()
    {
        return ancestor;
    }

    public void setAncestor(StyleSelector ancestor)
    {
        this.ancestor = ancestor;
    }

    public List<StyleCondition> getConditions()
    {
        return conditions;
    }

    public void addCondition(StyleCondition condition)
    {
        if (conditions == null)
            conditions = new ArrayList<StyleCondition>(2);

        conditions.add(condition);
    }

    public String getValue()
    {
        return value;
    }

    public void setValue(String value)
    {
        this.value = value;
    }

    public String toString()
    {
        StringBuilder sb = new StringBuilder();

        if (ancestor != null)
            sb.append(ancestor.toString()).append(' ');

        if (value != null)
            sb.append(value);

        if (conditions != null)
        {
            Iterator<StyleCondition> iterator = conditions.iterator();
            while (iterator.hasNext())
            {
                sb.append(iterator.next().toString());
            }
        }

        return sb.toString(); 
    }

    private StyleSelector ancestor;
    private List<StyleCondition> conditions;
    private String value;

}
