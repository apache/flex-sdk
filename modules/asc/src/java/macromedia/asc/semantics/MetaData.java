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

import macromedia.asc.parser.MetaDataEvaluator;
import macromedia.asc.parser.MetaDataNode;

/**
 * Class to store metadata info, so that Slots don't have pointers back into the AST
 * @author Erik Tierney
 */
public class MetaData
{
    public String id;
    public Value[] values;

    public MetaData()
    {
        id = null;
        values = null;
    }

    public String getValue(String key)
    {
        for (int i = 0, length = count(); i < length; i++)
        {
            if (values[i] instanceof MetaDataEvaluator.KeyValuePair)
            {
                if (((MetaDataEvaluator.KeyValuePair) values[i]).key.equals(key))
                {
                    return ((MetaDataEvaluator.KeyValuePair) values[i]).obj;
                }
            }
        }
        return null;
    }

    public String getValue(int index)
    {
        if (index < 0 || index >= count())
        {
            throw new ArrayIndexOutOfBoundsException();
        }
        else if (values[index] instanceof MetaDataEvaluator.KeylessValue)
        {
            return ((MetaDataEvaluator.KeylessValue) values[index]).obj;
        }
        else if (values[index] instanceof MetaDataEvaluator.KeyValuePair)
        {
            return ((MetaDataEvaluator.KeyValuePair) values[index]).obj;
        }
        else
        {
            return null;
        }
    }

    public int count()
    {
        return values != null ? values.length : 0;
    }

}
