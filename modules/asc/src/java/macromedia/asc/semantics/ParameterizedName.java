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

import macromedia.asc.util.ObjectList;

/**
 * Created by IntelliJ IDEA.
 * User: tierney
 * Date: Mar 4, 2008
 * Time: 6:01:00 PM
 * To change this template use File | Settings | File Templates.
 */
public class ParameterizedName extends QName
{
    public ObjectList<QName> type_params;
    private String fullname;
    private String namepart;

    public ParameterizedName(ObjectValue ns, String name, ObjectList<TypeValue> type_params)
    {
        super(ns, name);
        this.type_params = new ObjectList<QName>(type_params.size());
        for( TypeValue t : type_params )
            this.type_params.add(t.name);
    }

    public ParameterizedName(ObjectList<QName> type_names, ObjectValue ns, String name)
    {
        super(ns, name);
        this.type_params = type_names;
    }

    public boolean equals(Object rhs)
    {
        if( rhs instanceof ParameterizedName )
        {
            if( super.equals(rhs) )
            {
                ParameterizedName rp = (ParameterizedName)rhs;
                if( rp.type_params.size() == type_params.size() )
                {
                    for( int i = 0, limit = type_params.size(); i < limit; ++i)
                    {
                        if( !type_params.at(i).equals(rp.type_params.at(1)) )
                            return false;
                    }
                    return true;
                }
            }
        }
        return false;
    }

    public int hashCode()
    {
        return ns.hashCode() + this.name.hashCode() + type_params.hashCode();
    }

    public String getNamePart()
    {
        if( namepart == null)
        {
            namepart = name;
            namepart += ".<";
            for( int i = 0, limit = type_params.size(); i < limit; ++i )
            {
                namepart += type_params.at(i).toString();
            }
            namepart += ">";
            namepart = namepart.intern();
        }

        return namepart;
    }
    public String toString()
    {
        if (fullname == null)
        {
            if (ns != null && ns.name.length() != 0) // public, just return the name
            {
                fullname = (ns.name + ":" + getNamePart()).intern();
            }
            else
            {
                fullname = getNamePart();
            }
        }
        return fullname;
    }
}
