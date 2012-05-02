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
 * User: bolaghlin, 
 */
public class ParseMxmlHeader extends Thread {

    public String height = "395";
    public String width = "501";


    public void setWidthAndHeight(String mxmlFile) {

    	try {

		String line = null;
                BufferedReader br = new BufferedReader (new FileReader (mxmlFile));
                /// we will not go far into a file to get this
                int count = 0 ;

                int loc = -1;
                int loc_end = -1;

		boolean begun =  false;

		boolean setH = false;
		boolean setW = false;

                while ( (line=br.readLine()) != null) {
                	if ( (loc = line.indexOf("Application")) != -1) 
				begun= true;

						
		
			if (begun) { 
				if (line.indexOf ("height=")!=-1) {
					height = line.substring (line.indexOf ("height=")+8);
					System.out.println ("inter h: " + height);
					height = height.substring (0, height.indexOf ("\""));
					setH = true;
		
				}
				
				if (line.indexOf ("width=")!=-1) {
					width = line.substring (line.indexOf ("width=")+7);
					System.out.println ("inter w: " + width);
					if (width.indexOf ("\"") != -1)
						width = width.substring (0, width.indexOf ("\""));
					setW = true;
				}
                        }

			if (setH && setW) { 
				br.close();
				break;
			}

                	if ( begun && (loc_end = line.indexOf(">")) != -1)  { 
				br.close();

				if (!setH)
					height=SwfLoaderTestAdapter.standard_height;
				if (!setW)
					width=SwfLoaderTestAdapter.standard_width;	
				break;
			}
		}

                } catch (Exception e) {
                        e.printStackTrace();
                }


    }


    public static void main (String[] args) { 

		ParseMxmlHeader p = new ParseMxmlHeader();
		p.setWidthAndHeight(args[0]);

		System.out.println ("width="+p.width + " height=" + p.height);
	}


}
