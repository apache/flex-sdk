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

package macromedia.asc.semantics;

import macromedia.asc.util.Context;

public class TypeInfo
{
    private boolean is_nullable;
    private boolean is_default;
    private boolean annotate_names = false;

    private TypeValue type;

    private ObjectValue prototype;

    private QName name;

    public TypeInfo(TypeValue type)
    {
        this.type = type;
        this.is_nullable = true;
    }

    public TypeInfo(TypeValue type, boolean nullable, boolean is_default)
    {
        this.type = type;
        this.is_nullable = nullable;
        this.is_default = is_default;
        if( type != null )
            this.prototype = type.prototype;
    }

    public void clearInstance()
    {
    	this.prototype = null;
        this.name = null;
    }
    
    public boolean isNullable()
    {
        return this.is_nullable;
    }

    public TypeValue getTypeValue()
    {
        return type;
    }

    public void setIsNullable(boolean nullable)
    {
        this.is_nullable = nullable;
    }

    public boolean isNumeric(Context cx) {
    	return ((type == cx.intType()) || (type == cx.uintType()) || (type == cx.doubleType()) ||
    			(type == cx.numberType()) || (cx.statics.es4_numerics && (type == cx.decimalType())));
    }

    public int getTypeId()
    {
        // TODO: should there be different type-id's for nullable/non-nullable?
        return type.getTypeId();
    }

    public boolean includes(Context cx, TypeInfo other_type)
    {
        boolean result = false;

        if( cx.statics.es4_nullability && !this.is_nullable && other_type.is_nullable )
            result = false;
        else
            result = this.type.includes(cx, other_type.type);

        return result;
    }

    public QName getName()
    {
        if( name == null )
        {
            name = type.name;
        }
        return name;
    }

    public QName getName(Context cx)
    {
        if( name == null )
        {
            name = type.name;
            if( cx.statics.es4_nullability && !is_default )
            {
                name = new QName(name.ns, name.name + (is_nullable ? "?" : "!") );
            }
        }
        return name;
    }
    
    public Builder getBuilder()
    {
        return type.builder;
    }

    public ObjectValue getPrototype()
    {
        if( this.prototype == null )
            this.prototype = type != null ? type.prototype : null;

        return this.prototype;
    }

    public boolean isInterface()
    {
        return type.isInterface();
    }

    public void setPrototype(ObjectValue proto)
    {
        this.prototype = proto;
    }
}

