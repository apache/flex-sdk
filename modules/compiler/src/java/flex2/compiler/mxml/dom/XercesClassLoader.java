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
package flex2.compiler.mxml.dom;

import java.net.URLClassLoader;
import java.net.URL;
import java.util.Map;
import java.util.HashMap;

/**
 * The xerces classloader used by the MxmlScanner to load classes in
 * the order needed by Flex.  It makes sure that Flex jars are used as
 * needed.  This is a simplified version of
 * flex.webtier.util.J2EEUtil.BootstrapClassLoader, which was
 * originally based on a version from ColdFusion.
 *
 * @author Brian Deitte
 * @author Paul Reilly
 */
public class XercesClassLoader extends URLClassLoader
{
    private String[] exceptionList = new String[] {"org.apache.xerces"};
    private Map classCache = new HashMap();

    XercesClassLoader(URL[] classpath, ClassLoader parent)
    {
        super(classpath, parent);
        this.exceptionList = exceptionList;
    }

    /**
     * isStrInList Is the string 'name' in the list of strings.
     */
    private boolean isStrInList(String name, String[] list)
    {
        boolean retValue = false;
        if (list != null)
        {
            for (int i = 0; i < list.length; i++)
            {
                if (name.startsWith(list[i]))
                {
                    retValue = true;
                    break;
                }
            }
        }
        return retValue;
    }

    /**
     * delegateToSuper if the class name is in the list of includes but not in the
     * list of excludes.
     */
    private boolean delegateToSuper(String name)
    {
        return !isStrInList(name, exceptionList);
    }

    protected Class loadClass(String name, boolean resolve)
            throws ClassNotFoundException
    {
        // First, check if the class has already been loaded by this class loader
        Class c = findLoadedClass(name);
        if (c != null)
        {
            return c;
        }

        c = (Class) classCache.get(name);
        if (c == null)
        {
            synchronized (this)
            {
                c = (Class) classCache.get(name);
                if (c == null)
                {
                    // First Delegate class loading to the Application class loader and
                    // if not found try this class loader.
                    if (delegateToSuper(name))
                    {
                        try
                        {
                            c = super.loadClass(name, resolve);
                        }
                        catch (ClassNotFoundException cnfe)
                        {
                            //maybe the parent doesn't have this,
                            // in which case keep going and try to find it
                            // in our ClassLoader.
                            c = findClass(name);
                        }
                    }
                    // First try to load the class using this class loader and if not found
                    // delegate to the parent application class loader.
                    else
                    {
                        try
                        {
                            //find the class in our classpath first, if it exists, use it.
                            c = findClass(name);
                        }
                        catch (ClassNotFoundException e)
                        {
                            //else use the standard mechanism for loading classes.
                            c = super.loadClass(name, false);
                        }
                    }

                    if (c == null)
                    {
                        throw new ClassNotFoundException();
                    }
                }
                classCache.put(name, c);
            }
        }

        if (resolve)
        {
            resolveClass(c);
        }
        return c;
    }

    public URL getResource(String name)
    {
        URL url = null;
        if (url == null)
        {
            url = findResource(name);
        }
        if (url == null)
        {
            url = getParent().getResource(name);
        }
        return url;
    }
}
