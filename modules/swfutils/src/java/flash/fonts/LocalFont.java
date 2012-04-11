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

package flash.fonts;

import java.io.Serializable;


/**
 * Represents a font on the local disk.
 *
 * @author Brian Deitte
 */
public class LocalFont implements Serializable
{
	private static final long serialVersionUID = 2175878176353318644L;
    
    public String postscriptName;
	public String path;
	public int fsType;
	public String copyright;
	public String trademark;

	public LocalFont(String postscriptName, String path, int fsType, String copyright, String trademark)
	{
		this.postscriptName = postscriptName;
		this.path = path;
		this.fsType = fsType;
		this.copyright = copyright;
		this.trademark = trademark;
	}

	// we purposefully leave path out of equals()
	public boolean equals(Object o)
	{
		if (this == o)
		{
			return true;
		}
		if (o == null || getClass() != o.getClass())
		{
			return false;
		}

		final LocalFont localFont = (LocalFont)o;

		if (fsType != localFont.fsType)
		{
			return false;
		}
		if (copyright != null ? !copyright.equals(localFont.copyright) : localFont.copyright != null)
		{
			return false;
		}
		if (postscriptName != null ? !postscriptName.equals(localFont.postscriptName) : localFont.postscriptName != null)
		{
			return false;
		}
		if (trademark != null ? !trademark.equals(localFont.trademark) : localFont.trademark != null)
		{
			return false;
		}

		return true;
	}
}
