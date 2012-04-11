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

package flash.swf.tags;

/**
 * This represents a EnableDebugger SWF tag.  This supports AS2 and
 * AS3.
 *
 * @author Clement Wong
 */
public class EnableDebugger extends flash.swf.Tag
{
	public EnableDebugger(int code)
	{
		super(code);
	}

    public EnableDebugger(String password)
    {
        super(stagEnableDebugger2);
        this.password = password;
    }

    public void visit(flash.swf.TagHandler h)
	{
        if (code == stagEnableDebugger)
    		h.enableDebugger(this);
        else
            h.enableDebugger2(this);
	}

    public String password;
	public int    reserved;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof EnableDebugger))
        {
            EnableDebugger enableDebugger = (EnableDebugger) object;

            if ( equals(enableDebugger.password, this.password) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
