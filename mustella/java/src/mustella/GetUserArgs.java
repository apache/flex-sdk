/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package mustella; 
import utils.*;
import utils.FileUtils;

import java.io.File;
import java.util.regex.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.util.*;

/**
 * User: bolaghlin
 */
public class GetUserArgs {

    private static final String compile_arg_ending = ".compile";

    public String checkAndAddUserArgs (String mxml, String args) { 

	String comp_mxml = transformName(mxml, compile_arg_ending);

	Map.Entry me = null;

	if (new File(comp_mxml).exists()) { 
		System.out.println ("Saw the .compile file");

		Properties p = new Properties();
		try { 
			// Since we may get duplicate compile key directives, we
			// have to combine them.
			// can't really use load

			String line = null;
			String key = null;
			String val = null;
			String tmp = null;
			BufferedReader be = new BufferedReader (new FileReader (comp_mxml));

			/// Simplified version: just throw the arg on there, as is
			while ( (line=be.readLine()) != null) { 
				if (!line.startsWith ("#"))
					args += " "+ doSubstitute(line);
			}

			be.close();


		} catch (Exception e) { 
			System.err.println ("Exception on trying to load user .compile file, maybe ok");
			// e.printStackTrace();


		}
	} 

	return args;


    }

    public static String transformName (String mxml, String addition) { 

	if (mxml.indexOf (".") != -1) {
		return mxml.substring (0, mxml.lastIndexOf (".")) + addition;

	}

	return mxml;
	
    }


    public static String transformName (String mxml) { 

	return transformName (mxml, "");

    }

    public String doSubstitute (String line) { 

	    	String sdk_dir=System.getProperty("sdk.dir");

	    	String fwk_dir=System.getProperty("framework.dir");

    		String mustella_dir = System.getProperty ("mustella.dir");

		if (sdk_dir != null && !sdk_dir.equals("")) { 

			if ( line.indexOf ("${sdk.dir}") != -1)  { 
				line = line.replaceAll ("\\$\\{sdk.dir\\}", FileUtils.normalizeDir(sdk_dir));
			}
		}

		
		if (mustella_dir != null && !mustella_dir.equals("")) { 
			if ( line.indexOf ("${mustella.dir}") != -1)  { 
				line = line.replaceAll ("\\$\\{mustella.dir\\}", FileUtils.normalizeDir(mustella_dir));
			}

		}

		if (fwk_dir != null && !fwk_dir.equals("")) { 
			if ( line.indexOf ("${framework.dir}") != -1)  { 
				line = line.replaceAll ("\\$\\{framework.dir\\}", FileUtils.normalizeDir(fwk_dir));
			}

		}


		return line;

    }
  

    public static void main (String[] args) { 


		GetUserArgs g = new GetUserArgs ();

		String s = g.checkAndAddUserArgs(args[0], "");

		System.out.println ("user args: " + s);
	}



}
