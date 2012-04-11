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

import macromedia.asc.semantics.*;
import macromedia.asc.util.ObjectList;

/**
 * TypeTable implementation based on type information extracted from
 * ASC's FunctionDefinitionNode.
 *
 * @author Clement Wong
 */
public final class Method extends SlotReflect implements flex2.compiler.abc.Method
{
    public Method(Slot s, ObjectValue ns, String name)
    {
        super(s, ns, name);
    }

    public flex2.compiler.util.QName getQName()
    {
        return new flex2.compiler.util.QName(namespace.name, name);
    }

    public String getReturnTypeName()
    {
        return getTypeName();
    }

    public String getReturnElementTypeName()
    {
        return getElementTypeName();
    }

    // only used for setters
    public String[] getParameterTypeNames()
    {
        String[] type_names = null;
        ObjectList<TypeInfo> types = slot.getTypes();
        if ( types != null )
        {
            type_names = new String[types.size()];
            for( int i = 0, l = types.size(); i < l; ++i )
            {
                type_names[i] = getTypeName(types.get(i));
            }
        } 
        return type_names;
    }

    // only used for setters
    public String[] getParameterElementTypeNames()
    {
        String[] type_names = null;
        ObjectList<TypeInfo> types = slot.getTypes();
        if ( types != null )
        {
            type_names = new String[types.size()];
            for( int i = 0, l = types.size(); i < l; ++i )
            {
                type_names[i] = getElementTypeName(types.get(i));
            }
        }
        return type_names;
    }

}
