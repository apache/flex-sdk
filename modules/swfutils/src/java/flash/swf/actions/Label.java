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

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.types.ActionList;

/**
 * Represents an AS2 "label" byte code.
 *
 * @author Edwin Smith
 */
public class Label extends Action
{
    public Label()
    {
        super(ActionList.sactionLabel);
    }

    public void visit(ActionHandler h)
    {
        h.label(this);
    }

    public boolean equals(Object object)
    {
        // labels should always be unique unless they really are the same object
        return this == object;
    }

    public int hashCode()
    {
        // Action.hashCode() allways returns the code, but we want a real hashcode
        // since every instance of Label needs to be unique
        return super.objectHashCode();
    }
}
