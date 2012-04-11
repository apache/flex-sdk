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
import flash.swf.TagValues;

/**
 * This represents a ScriptLimits SWF tag.  It is used to change the
 * player's default scripting limits.  This tag applies until the next
 * ScriptLimits is encountered at runtime.  It can occur anywhere and
 * any number of times.
 *
 * @since SWF7
 *
 * @author Paul Reilly
 */

public class ScriptLimits extends Tag
{
    public ScriptLimits(int scriptRecursionLimit, int scriptTimeLimit)
    {
        super(TagValues.stagScriptLimits);

        this.scriptRecursionLimit = scriptRecursionLimit;
        this.scriptTimeLimit = scriptTimeLimit;
    }

    public void visit(TagHandler tagHandler)
	{
        tagHandler.scriptLimits(this);
	}

	public int scriptRecursionLimit;
    public int scriptTimeLimit;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof ScriptLimits))
        {
            ScriptLimits scriptLimits = (ScriptLimits) object;

            if ( (scriptLimits.scriptRecursionLimit == this.scriptRecursionLimit) &&
                 (scriptLimits.scriptTimeLimit == this.scriptTimeLimit) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
