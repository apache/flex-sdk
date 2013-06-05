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

package flex2.compiler.config;

import java.io.File;
import java.lang.reflect.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * Flex MXMLC compiler uses the result of the client configuration parser
 * to generate mixin initialization source code to be added to the SWF by
 * PreLink. It also requires a list of channel classes to be added as
 * dependencies.
 *
 * @exclude
 */
public class ServicesDependenciesWrapper
{
	private Object servicesDependenciesInstance;
	private Class servicesDependenciesClass;
	
    public ServicesDependenciesWrapper(String path, String parserClass, String contextRoot)
    {
    	try 
    	{
    		servicesDependenciesClass = Class.forName("flex.messaging.config.ServicesDependencies");
    	}
    	catch (ClassNotFoundException e)
    	{
    		return;
    	}
		Class partypes[] = new Class[3];
        partypes[0] = String.class;
        partypes[1] = String.class;
        partypes[2] = String.class;
        try
        {
            Constructor ct = servicesDependenciesClass.getConstructor(partypes);        	
            Object arglist[] = new Object[3];
            arglist[0] = path;
            arglist[1] = parserClass;
            arglist[2] = contextRoot;
            try 
            {
                servicesDependenciesInstance = ct.newInstance(arglist);            	
            }
            catch (Throwable e3)
            {
            	if (e3 instanceof InvocationTargetException)
            		System.err.println(((InvocationTargetException)e3).getCause());
            	else
            		System.err.println(e3);
            }
        }
        catch (NoSuchMethodException e2)
        {
        	
        }
    }

    public Set getLazyAssociations(String destination)
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getLazyAssociations", new Class[] {String.class});
    			Object arglist[] = new Object[1];
                arglist[0] = destination;
                return (Set)method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    	
    	return null;
    }

    public void addLazyAssociation(String destination, String associationProp)
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getLazyAssociations", new Class[] {String.class});
    			Object arglist[] = new Object[2];
                arglist[0] = destination;
                arglist[1] = associationProp;
                method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    }

    public String getServerConfigXmlInit()
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getServerConfigXmlInit", new Class[] {} );
    			Object arglist[] = new Object[0];
                return (String)method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    	
    	return null;
    }

    public String getImports()
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getImports", new Class[] {} );
    			Object arglist[] = new Object[0];
                return (String)method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    	
    	return null;
    }

    public String getReferences()
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getReferences", new Class[] {} );
    			Object arglist[] = new Object[0];
                return (String)method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    	
    	return null;
    }

    public List getChannelClasses()
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getChannelClasses", new Class[] {} );
    			Object arglist[] = new Object[0];
                return (List)method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    	
    	return null;
    }

    public void addChannelClass(String className)
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("addChannelClass", new Class[] {} );
    			Object arglist[] = new Object[0];
                method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    }

    public void addConfigPath(String path, long modified)
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("addConfigPath", new Class[] { String.class, Long.TYPE } );
    			Object arglist[] = new Object[2];
    			arglist[0] = path;
    			arglist[1] = modified;
                method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    }

    public Map getConfigPaths()
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getConfigPaths", new Class[] {} );
    			Object arglist[] = new Object[0];
                return (Map)method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    	
    	return null;
    }

    /*
    public static ClientConfiguration getClientConfiguration(String path, String parserClass)
    {
        ClientConfiguration config = new ClientConfiguration();

        ConfigurationParser parser = getConfigurationParser(parserClass);

        if (parser == null)
        {
            // "Unable to create a parser to load messaging configuration."
            LocalizedException lme = new LocalizedException();
            lme.setMessage(10138);
            throw lme;
        }

        LocalFileResolver local = new LocalFileResolver();
        parser.parse(path, local, config);

        config.addConfigPath(path, new File(path).lastModified());

        return config;
    }

    static ConfigurationParser getConfigurationParser(String className)
    {
        ConfigurationParser parser = null;
        Class parserClass = null;

        // Check for Custom Parser Specification
        if (className != null)
        {
            try
            {
                parserClass = Class.forName(className);
                parser = (ConfigurationParser)parserClass.newInstance();
            }
            catch (Throwable t)
            {
                if (traceConfig)
                {
                    System.out.println("Could not load services configuration parser as: " + className);
                }
            }
        }

        // Try Sun JRE 1.4 / Apache Xalan Based Implementation
        if (parser == null)
        {
            try
            {
                Class.forName("org.apache.xpath.CachedXPathAPI");
                className = "flex.messaging.config.ApacheXPathClientConfigurationParser";
                parserClass = Class.forName(className);
                parser = (ConfigurationParser)parserClass.newInstance();
            }
            catch (Throwable t)
            {
                if (traceConfig)
                {
                    System.out.println("Could not load configuration parser as: " + className);
                }
            }
        }

        // Try Sun JRE 1.5 Based Implementation
        if (parser == null)
        {
            try
            {
                className = "flex.messaging.config.XPathClientConfigurationParser";
                parserClass = Class.forName(className);
                // double-check, on some systems the above loads but the import classes don't
                Class.forName("javax.xml.xpath.XPathExpressionException");

                parser = (ConfigurationParser)parserClass.newInstance();
            }
            catch (Throwable t)
            {
                if (traceConfig)
                {
                    System.out.println("Could not load configuration parser as: " + className);
                }
            }
        }

        if (traceConfig && parser != null)
        {
            System.out.println("Services Configuration Parser: " + parser.getClass().getName());
        }

        return parser;
    }

    private static List listChannelClasses(ServicesConfiguration config)
    {
        List channelList = new ArrayList();
        Iterator it = config.getAllChannelSettings().values().iterator();
        while (it.hasNext())
        {
            ChannelSettings settings = (ChannelSettings)it.next();
            if (!settings.serverOnly)
            {
                String clientType = settings.getClientType();
                channelList.add(clientType);
            }
        }

        return channelList;
    }

	 */
    

    /**
     *
    public void codegenServiceAssociations(ConfigMap metadata, StringBuffer e4x, String destination, String relation)
    {
    	if (servicesDependenciesClass != null)
    	{
    		try
    		{
    			Method method = servicesDependenciesClass.getMethod("getConfigPaths", new Class[] { ConfigMap.class, StringBuffer.class, String.class, String.class } );
    			Object arglist[] = new Object[4];
    			arglist[0] = metadata;
    			arglist[1] = e4x;
    			arglist[2] = destination;
    			arglist[3] = relation;
                method.invoke(servicesDependenciesInstance, arglist);   			
    		}
    		catch (Throwable e)
    		{
    			
    		}
    	}
    }
     */

    /**
     * This method will return an import and variable reference for channels specified in the map.
     * @param map HashMap containing the client side channel type to be used, typically of the form
     * "mx.messaging.channels.XXXXChannel", where the key and value are equal.
     * @param imports StringBuffer of the imports needed for the given channel definitions
     * @param references StringBuffer of the required references so that these classes will be linked in.
    public static void codegenServiceImportsAndReferences(Map map, StringBuffer imports, StringBuffer references)
    {
        String channelSetImplType = (String)map.remove("ChannelSetImpl");
        String type;
        imports.append("import mx.messaging.config.ServerConfig;\n");
        references.append("   // static references for configured channels\n");
        for (Iterator chanIter = map.values().iterator(); chanIter.hasNext();)
        {
            type = (String)chanIter.next();
            imports.append("import ");
            imports.append(type);
            imports.append(";\n");
            references.append("   private static var ");
            references.append(type.replace('.', '_'));
            references.append("_ref:");
            references.append(type.substring(type.lastIndexOf(".") +1) +";\n");
        }
        if (channelSetImplType != null)
            imports.append("import mx.messaging.AdvancedChannelSet;\nimport mx.messaging.messages.ReliabilityMessage;\n");
    }
     */
}
