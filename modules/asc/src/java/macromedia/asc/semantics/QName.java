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

/**
 *
 * @author Erik Tierney
 */
public class QName
{
    public ObjectValue ns;
    public String name;
	private String fullname;

    public QName(ObjectValue ns, String name)
    {
        this.ns = ns;
        this.name = name;
    }

    public boolean equals(Object rhs)
    {
        if( rhs instanceof QName )
        {
            if( ns.equals(((QName)rhs).ns) && this.name.equals(((QName)rhs).name) )
            {
                return true;
            }
        }
        return false;
    }

    public int hashCode()
    {
        return ns.hashCode() + this.name.hashCode();
    }

	public String toString()
	{
		if (fullname == null)
		{
			if (ns != null && ns.name.length() != 0) // public, just return the name
			{
				fullname = (ns.name + ":" + name).intern();
			}
			else
			{
				fullname = name;
			}
		}
		return fullname;
	}
}
