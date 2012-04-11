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

package flex2.compiler.asdoc;

import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;

import java.util.List;
import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;

/**
 * This class is stores the package info classes for all packages in the source paths.
 * @author Brian Deitte
 */
public class PackagesConfiguration
{
	//
	// 'packages.package' option
	//
	
	private List<PackageInfo> packages = new ArrayList<PackageInfo>();
	private Set<String> packageNames = new HashSet<String>();

	/**
	 * returns a list of all the packageInfo objects. 
	 * @return
	 */
	public List<PackageInfo> getPackages()
	{
		return packages;
	}

	public Set<String> getPackageNames()
	{
		return packageNames;
	}
	
	/** 
	 * Assigns description to a package
	 * @param cfgval
	 * @param name
	 * @param desc
	 */
	public void cfgPackage(ConfigurationValue cfgval, String name, String desc)
	{
		packages.add(new PackageInfo(name, desc));
		packageNames.add(name);
	}

	public static ConfigurationInfo getPackageInfo()
	{
	    return new ConfigurationInfo( )
	    {
	        public boolean allowMultiple()
	        {
	            return true;
	        }
	    };
	}
}
