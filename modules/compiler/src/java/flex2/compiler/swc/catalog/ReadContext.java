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

package flex2.compiler.swc.catalog;

import org.xml.sax.Attributes;

import java.util.Stack;

/**
 * Context that allows for retrieval of current element and parent
 * elements.
 *
 * @author Brian Deitte
 */
public class ReadContext
{
    private String currentName;
    private Attributes currentAttributes;
    private Stack<CatalogReadElement> parents = new Stack<CatalogReadElement>();
    private Stack<String> parentNames = new Stack<String>();

    public String getCurrentName()
    {
        return currentName;
    }

    public Attributes getCurrentAttributes()
    {
        return currentAttributes;
    }

    public CatalogReadElement getCurrentParent()
    {
        return parents.size() == 0 ? null : parents.peek();
    }

    public void setCurrent(String element, Attributes attributes)
    {
        currentName = element;
        currentAttributes = attributes;
    }

    public void setCurrentParent(CatalogReadElement currentParent, String element)
    {
        parents.push(currentParent);
        parentNames.push(element);
    }

    public void clearCurrentParent(String element)
    {
        String name = parentNames.size() == 0 ? null : parentNames.peek();
        if (element.equals(name))
        {
            parents.pop();
            parentNames.pop();
        }
    }

    public void clear()
    {
        currentName = null;
        currentAttributes = null;

        assert(parents.size() == 0);
        assert(parentNames.size() == 0);

        parents.clear();
        parentNames.clear();
    }
}
