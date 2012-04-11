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

package flex2.compiler.as3.reflect;

import macromedia.asc.parser.MetaDataEvaluator.KeyValuePair;
import macromedia.asc.parser.MetaDataEvaluator.KeylessValue;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.Value;

import java.util.HashMap;
import java.util.Map;

/**
 * TypeTable implementation based on type information extracted from
 * ASC's MetaDataNode.
 *
 * @author Clement Wong
 */
public final class MetaData implements flex2.compiler.abc.MetaData
{
	public MetaData(MetaDataNode node)
	{
		this.id = node.getId();
		this.values = node.getValues();
	}

    public MetaData(macromedia.asc.semantics.MetaData node)
    {
        this.id = node.id;
        this.values = node.values;
    }

	private String id;
	private Value[] values;

	public String getID()
	{
		return id;
	}

	public String getKey(int index)
	{
		if (index < 0 || index >= count())
		{
			throw new ArrayIndexOutOfBoundsException();
		}
		else if (values[index] instanceof KeylessValue)
		{
			return null;
		}
		else if (values[index] instanceof KeyValuePair)
		{
			return ((KeyValuePair) values[index]).key;
		}
		else
		{
			return null;
		}
	}

	public String getValue(String key)
	{
		for (int i = 0, length = count(); i < length; i++)
		{
			if (values[i] instanceof KeyValuePair)
			{
				if (((KeyValuePair) values[i]).key.equals(key))
				{
					return ((KeyValuePair) values[i]).obj;
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
		else if (values[index] instanceof KeylessValue)
		{
			return ((KeylessValue) values[index]).obj;
		}
		else if (values[index] instanceof KeyValuePair)
		{
			return ((KeyValuePair) values[index]).obj;
		}
		else
		{
			return null;
		}
	}

	public Map<String, String> getValueMap()
	{
		Map<String, String> result = new HashMap<String, String>();

		for (int i = 0, length = count(); i < length; i++)
		{
			if (values[i] instanceof KeyValuePair)
			{
				KeyValuePair keyValuePair = (KeyValuePair) values[i];

				result.put(keyValuePair.key, keyValuePair.obj);
			}
		}

		return result;
	}

	public int count()
	{
		return values != null ? values.length : 0;
	}
}
