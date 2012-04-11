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

package macromedia.asc.parser;

import macromedia.asc.semantics.MetaData;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

/**
 * @author Clement Wong
 */
public class MetaDataNode extends Node
{
	public LiteralArrayNode data;

	public MetaDataNode(LiteralArrayNode data)
	{
		this.data = data;
		def = null;
	}

    private MetaData md;

	public DefinitionNode def;

	public Value evaluate(Context cx, Evaluator evaluator)
	{
		if (evaluator.checkFeature(cx, this))
		{
			return evaluator.evaluate(cx, this);
		}
		else
		{
			return null;
		}
	}

    public void setMetadata(MetaData md)
    {
        this.md = md;
    }

	public String getValue(String key)
	{
        return md != null ? md.getValue(key) : null;
	}

	public String getValue(int index)
	{
        return md != null ? md.getValue(index) : null;
	}

	public int count()
	{
		return getValues() != null ? getValues().length : 0;
	}

	public String toString()
	{
		return "MetaData";
	}

    public String getId()
    {
        return md != null ? md.id : null;
    }

    public void setId(String id)
    {
        if( this.md == null )
            this.md = new MetaData();
        this.md.id = id;
    }

    public Value[] getValues()
    {
        return md != null ? md.values : null;
    }

    public void setValues(Value[] values)
    {
        if( this.md == null )
            this.md = new MetaData();
        this.md.values = values;
    }

    public MetaData getMetadata()
    {
        return md;
    }
}
