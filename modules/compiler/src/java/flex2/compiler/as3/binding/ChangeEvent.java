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
 * This value object is used by Watcher to store a change event's name
 * and whether it's committing as a pair.
 *
 * @author Paul Reilly
 * @see flex2.compiler.as3.binding.Watcher
 */
public class ChangeEvent
{
    private String name;
    private boolean committing;

    public ChangeEvent(String name, boolean committing)
    {
        this.name = name;
        this.committing = committing;
    }

    public boolean equals(Object object)
    {
        boolean result = false;

        if (object instanceof ChangeEvent)
        {
            ChangeEvent changeEvent = (ChangeEvent) object;

            if (name.equals(changeEvent.getName()) && (committing == changeEvent.getCommitting()))
            {
                result = true;
            }
        }

        return result;
    }

    public boolean getCommitting()
    {
        return committing;
    }

    public String getName()
    {
        return name;
    }

    public int hashCode()
    {
        return name.hashCode();
    }
}
