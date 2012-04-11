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

import java.util.Iterator;

/**
 * Defines the API for library information. 
 * 
 * @author Clement Wong
 * @version 3.0
 */
public interface LibraryInfo
{
	/**
	 * 
	 * @param namespaceURI
	 * @param name
	 * @return
	 */
	Component getComponent(String namespaceURI, String name);

	/**
	 * 
	 * @param definition
	 * @return
	 */
	Component getComponent(String definition);
	
	/**
	 * 
	 * @return
	 */
	Iterator getComponents();
	
	/**
	 * 
	 * @param definition
	 * @return
	 */
	Script getScript(String definition);
	
	/**
	 * 
	 * @return
	 */
	Iterator getScripts();
	
	/**
	 * 
	 * @return
	 */
	String[] getDefinitionNames();
	
	/**
	 * 
	 * @return
	 */
	Iterator getFiles();
}
