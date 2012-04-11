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
 * for a runtime Repeater component watcher.
 *
 * @author Paul Reilly
 */
public class RepeaterComponentWatcher extends PropertyWatcher
{
    private int repeaterLevel;

    public RepeaterComponentWatcher(int id, String property, int repeaterLevel)
    {
        super(id, property);
        this.repeaterLevel = repeaterLevel;
    }

    public int getRepeaterLevel()
    {
        return repeaterLevel;
    }
}
