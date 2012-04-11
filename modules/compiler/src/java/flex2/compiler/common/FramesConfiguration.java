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

package flex2.compiler.common;

import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.util.NameFormatter;

import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;

/**
 * This class defines the frame related configuration options.
 * <PRE>
 * <frames>
 *   <frame>
 *     <label>ick</label>
 *     <className>foo</className>
 *     <className>bar</className>
 *   </frame>
 *   <frame>
 *     <label>asd</label>
 *     <classname>moo</classname>
 *   </frame>
 * </frames>
 * </PRE>
 *
 * @author Roger Gonzalez
 */
public class FramesConfiguration
{
    /**
     * This value object represents a frame's name and classes.
     */
    public static class FrameInfo
    {
        public String label = null;
        public List<String> frameClasses = new LinkedList<String>();
    }
    
    //
    // 'frames.frame' option
    //
    
    private List<FrameInfo> frameList = new LinkedList<FrameInfo>();

    public List<FrameInfo> getFrameList()
    {
        return frameList;
    }

    public void cfgFrame( ConfigurationValue cv, List args ) throws ConfigurationException
    {
        FrameInfo info = new FrameInfo();

        if (args.size() < 2)
            throw new ConfigurationException.BadFrameParameters( cv.getVar(), cv.getSource(), cv.getLine() );

        for (Iterator it = args.iterator(); it.hasNext();)
        {
            if (info.label == null)
            {
                info.label = (String) it.next();
            }
            else
            {
	            String clsName = (String)it.next();
                info.frameClasses.add( NameFormatter.toColon(clsName) );
            }
        }

        frameList.add( info );
    }

    public static ConfigurationInfo getFrameInfo()
    {
        return new ConfigurationInfo( -1, new String[] {"label", "classname"} )
        {
            public boolean isAdvanced()
            {
                return true;
            }

            public boolean allowMultiple()
            {
                return true;
            }
        };
    }
}
