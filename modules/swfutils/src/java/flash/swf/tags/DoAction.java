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

import flash.swf.Tag;
import flash.swf.TagHandler;
import flash.swf.types.ActionList;

/**
 * Represents a DefineAction SWF tag.  This is used by AS2.
 *
 * @author Clement Wong
 */
public class DoAction extends Tag
{
	public DoAction()
	{
		super(stagDoAction);
	}

    public DoAction(ActionList actions)
    {
        super(stagDoAction);
        this.actionList = actions;
    }

    public void visit(TagHandler h)
	{
		h.doAction(this);
    }

    public ActionList actionList;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DoAction))
        {
            DoAction doAction = (DoAction) object;

            if ( equals(doAction.actionList, this.actionList) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode() {
      int hashCode = super.hashCode();
      hashCode += DefineTag.PRIME * actionList.size();
      return hashCode;
    }

}
