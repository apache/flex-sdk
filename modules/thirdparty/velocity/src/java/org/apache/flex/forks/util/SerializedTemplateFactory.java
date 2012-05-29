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

package org.apache.flex.forks.util;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.NotSerializableException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStreamWriter;

import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;
import org.apache.flex.forks.velocity.app.Velocity;
import org.apache.flex.forks.velocity.runtime.RuntimeInstance;
import org.apache.flex.forks.velocity.runtime.RuntimeServices;
import org.apache.flex.forks.velocity.runtime.parser.node.SimpleNode;

public class SerializedTemplateFactory 
{
	public static Template load(String resourcePath) throws IOException, ClassNotFoundException
	{
		// assumption, this class and templates are found from same classloader, should be cool for now
		InputStream is = SerializedTemplateFactory.class.getClassLoader().getResourceAsStream(resourcePath);
		Object data = new ObjectInputStream(new BufferedInputStream(is)).readObject();		
		is.close();
		Template t = new Template();
		t.setData(data);
		return t;
	}
	
	/**
	 * Usage: template.vm 
	 * writes template.ser (canned velocity parse tree)
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception
	{
		Velocity.init();
		
		for(int i=0,j=args.length; i<j; i++)
		{
			String serName = args[i] + "s";
	        Template template = Velocity.getTemplate(args[i]);
	
	        try {
		        FileOutputStream fos = new FileOutputStream(serName);
		        ObjectOutputStream ooo = new ObjectOutputStream(fos);
		        Object data = template.getData();
		        ooo.writeObject(data);
		        ooo.close();
		        fos.close();
	        } catch(NotSerializableException nse) {
	        	System.err.println("Make sure you are using the special velocity in flex/sdk/lib.");
	        	throw nse;
	        }
		}
	}
}
