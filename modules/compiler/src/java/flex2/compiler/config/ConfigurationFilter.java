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

/**
 * Defines the API for configuration filters, which can be used to
 * restrict the valid configuration options.
 *  
 * @author dloverin
 */
public interface ConfigurationFilter
{
	/**
	 * Decide if a given configuration option should be removed from the set
	 * of configuration options.  
	 * 
	 * @param name full name of the configuration option
	 * @return true if the option should be in the configuration,
	 * 		   false if the option is excluded.
	 */
	boolean select(String name);
}
