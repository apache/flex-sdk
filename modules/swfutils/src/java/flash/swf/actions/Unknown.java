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

package flash.swf.actions;

import java.util.Arrays;

import flash.swf.Action;
import flash.swf.ActionHandler;

/**
 * Represents an AS2 "unknown" byte code.
 *
 * @author Clement Wong
 */
public class Unknown extends Action
{
    public Unknown(int code)
    {
        super(code);
    }

    public void visit(ActionHandler handler)
	{
		handler.unknown(this);
	}

    public byte[] data;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof Unknown))
        {
            Unknown unknown = (Unknown) object;

            if ( Arrays.equals(unknown.data, this.data) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
