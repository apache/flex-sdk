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

package flex2.compiler.as3.reflect;

import flex2.compiler.abc.MetaData;
import macromedia.asc.semantics.*;
import macromedia.asc.util.Context;

import java.util.ArrayList;
import java.util.List;

/**
 * Base class for Variable & Method - just a facade, that wraps a macromedi.asc.semantics.Slot.
 * @author Erik Tierney (tierney@adobe.com)
 */
public class SlotReflect
{
    protected Slot slot;
    protected ObjectValue namespace;
    protected String name;

    public SlotReflect(Slot s, ObjectValue ns, String name)
    {
        this.slot = s;
        this.namespace = ns;
        this.name = name;
    }

    protected static String getTypeName(TypeInfo ti)
    {
        String typeName = null;
        if( ti != null )
        {
            TypeValue tv = ti.getTypeValue();
            typeName = tv.name.toString();
        }
        return typeName;
    }

    public List<flex2.compiler.abc.MetaData> getMetaData(String id)
    {
        ArrayList<macromedia.asc.semantics.MetaData> list = slot.getMetadata();

        List<MetaData> result = null;
        if( list != null )
        {
            for (int i = 0, length = list.size(); i < length; i++)
            {
                if (id.equals( (list.get(i)).id))
                {
                    if (result == null)
                    {
                        result = new ArrayList<MetaData>();
                    }
                    result.add(new flex2.compiler.as3.reflect.MetaData(list.get(i)));
                }
            }
        }
        return result;
    }

    protected static String getElementTypeName(TypeInfo ti)
    {
        String elementTypeName = null;
        if( ti != null )
        {
            TypeValue tv = ti.getTypeValue();
            if( tv.indexed_type != null )
            {
                elementTypeName = tv.indexed_type.name.toString();
            }
        }
        return elementTypeName;
    }

    public String getTypeName() {
        TypeInfo ti = slot.getType();

        String typeName = getTypeName(ti);

        return typeName;
    }

    public String getElementTypeName() {
        TypeInfo ti = slot.getType();
        return getElementTypeName(ti);
    }

    public boolean isConst() {
        return slot.isConst();
    }

    public boolean isStatic() {
        return slot.declaredBy instanceof TypeValue;
    }

    public boolean isPublic() {
        return namespace.getNamespaceKind() == Context.NS_PUBLIC;
    }
}
