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

package flex2.compiler.as3.binding;

/**
 * This class represents the information needed to construct the code
 * for a runtime property watcher.
 *
 * @author Paul Reilly
 */
public class PropertyWatcher extends Watcher
{
    private String property;
	private boolean suppressed;
    private boolean staticProperty;

    public PropertyWatcher(int id, String property)
    {
        super(id);
        this.property = property;
		suppressed = false;
	}

	public boolean shouldWriteSelf()
	{
        boolean result = !suppressed;

        // Fixes SDK-18764 by making sure we write out Watchers, when
        // they have unsuppressed children, even if the Watcher is
        // suppressed.
        if (suppressed)
        {
            for (Watcher watcher : childWatchers.values())
            {
                // ArrayElementWatcher.shouldWriteSelf() calls
                // parent.shouldWriteSelf(), so skip them to avoid
                // infinite recursion.
                if (!(watcher instanceof ArrayElementWatcher) && watcher.shouldWriteSelf())
                {
                    result = true;
                    break;
                }
            }
        }

		return result;
	}

    public String getPathToProperty()
    {
        String result;

        Watcher parent = getParent();
        if (parent instanceof PropertyWatcher)
        {
            PropertyWatcher parentPropertyWatcher = (PropertyWatcher) parent;

            result = parentPropertyWatcher.getPathToProperty() + "." + property;
        }
        else
        {
            result = property;
        }

        return result;
    }

    public String getProperty()
    {
        return property;
    }

    public boolean getStaticProperty()
    {
        return staticProperty;
    }

    public void setStaticProperty(boolean staticProperty)
    {
        this.staticProperty = staticProperty;
    }

	public void suppress()
	{
		suppressed = true;
	}
}
