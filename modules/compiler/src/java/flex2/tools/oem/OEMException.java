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

package flex2.tools.oem;

import flex2.compiler.ILocalizableMessage;

public class OEMException extends Exception implements ILocalizableMessage
{
    private static final long serialVersionUID = -6282943339729427885L;
    public String path = null;  // normally nothing here
    public String level = ILocalizableMessage.ERROR;

    public Exception getExceptionDetail()
    {
        return null;
    }

    public boolean isPathAvailable()
    {
        return true;
    }

    public void setColumn(int column)
    {

    }

    public void setLine(int line)
    {

    }

    public void setPath(String path)
    {
        this.path = path;
    }

    public int getColumn()
    {
        return 0;
    }

    public String getLevel()
    {
        return level;
    }

    public int getLine()
    {
        return 0;
    }

    public String getPath()
    {
        return path;
    }

    /**
     *  The specified libraries form a circular dependency. 
     *
     */
    public static class CircularLibraryDependencyException extends OEMException
    {
        private static final long serialVersionUID = -1128789848162235759L;
        private String cause;
        private String circularDependency;
       
        public CircularLibraryDependencyException(String cause, String circularDependency)
        { 
            this.cause = cause;
            this.circularDependency = circularDependency;
        }

        @Override
        public String getMessage()
        {
            return cause;
        }

        public String getCircularDependency()
        {
            return circularDependency;
        }

        
    }
}
