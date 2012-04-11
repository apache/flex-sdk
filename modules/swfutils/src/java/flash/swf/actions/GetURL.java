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

import flash.swf.ActionHandler;
import flash.swf.ActionConstants;

/**
 * Represents an AS2 "get URL" byte code.
 *
 * @author Clement Wong
 */
public class GetURL extends flash.swf.Action
{
	public GetURL()
	{
		super(ActionConstants.sactionGetURL);
	}

    public void visit(ActionHandler h)
	{
		h.getURL(this);
	}

    /**
	 * the URL can be of any type, including an HTML file, an image, or another SWF movie.
	 */
	public String url;

	/**
	 * If this movie is playing in a browser, the url will be displayed in the
	 * browser frame given by this target string.  The special target names
	 * "_level0" and "_level1" are used to load another SWF movie into levels 0
	 * and 1 respectively.
	 */
	public String target;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof GetURL))
        {
            GetURL getURL = (GetURL) object;

            if ( equals(getURL.url, this.url) &&
                 equals(getURL.target, this.target))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
