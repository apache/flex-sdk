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
import java.io.*;

import javax.xml.parsers.*;
import javax.xml.transform.*;
import org.w3c.dom.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;




/**

Utility for transforming a mustella test to apollo, by which is meant, 
changing the test_swf from Application to Window, and popping that window up 
from a WindowedApplication (provided as a template). 



*/
public class ApolloAppToWindow { 


	/**
	 * given the mxml arg, get the testSwf's className
	public static String getTestSwfName (String mxml) {

		return mxml;
	}
	 */



	/**
	 * return what will be the transformed name, given a test_swf filename
 	 * and a directory
	 */
	public static String getNewMxmlName (String dir, String mxml, String transform_prefix) { 

		if (mxml.indexOf ("\\apollo\\") != -1  || mxml.indexOf ("/apollo/") != -1)
			return mxml;

		// System.out.println ("This is the getNewMxmlName with mxml="+ mxml);

		String className = getSwfClassName(mxml);
		// System.out.println ("This is the getNewMxmlName className: " +className);

		// String subDir = getSwfSubDir(mxml);
		// System.out.println ("This is the getNewMxmlName swf subdir: " +subDir);

		String newName = transform_prefix + className + ".mxml";
		// System.out.println ("This is the getNewMxmlName returning: " +dir+ "/" + newName);
		return dir + "/" + newName;
		

	}


	/**
	 * The normal compile has a test_swf, and a bunch of args 
	 * The Air transform introduces a new test_swf, based on a template. 
	 * so we shift the args a bit: 
	 * we make the test_swf an include and add its source path
	 * dir is the same as targetDir below
	 */
	public static String adjustArgList (String args, String mxml, String dir, String prefix) {

		String className = getSwfClassName (mxml);

		args += " -source-path="+dir;
		args += " -includes="+prefix+className;
		
		return args;

	}

	public static final String app_string = "<mx:Application";
	public static final String app_string2 = "</mx:Application";
	public static final String replace_string = "<mx:Window";
	public static final String replace_string2 = "</mx:Window";

	/** 
	 * The main transformation is to take our test_swf and turn it into an AIR window
	 * write that into a new file.
	 */
	public static void transformTestSwfToWindow (String fileName, String dir, String prefix2) {

		String fileContents = readFileIntoString (fileName);

		String height = getAttribute (fileName, "mx:Application", "height");
		String width = getAttribute (fileName,  "mx:Application", "width");

		String addString = "";

		if (height == null || height.length()==0) 
			addString = addString+" height=\"375\"";
		if (width == null || width.length()==0) 
			addString = addString+" width=\"500\"";
		
		// System.out.println ("This is the applicaton decl w/h: " + height + " " + width);

		fileContents = fileContents.replaceAll (app_string,  replace_string + addString);
		fileContents = fileContents.replaceAll (app_string2,  replace_string2);


		String newFilename = getNewMxmlName (dir, fileName, prefix2);

		try { 
			writeStringToFile (fileContents, newFilename);
		} catch (java.io.FileNotFoundException  fnf) { 
			try { 
				new File (newFilename).delete();
				writeStringToFile (fileContents, newFilename);
			} catch (Exception  fnf2) { 
				fnf2.printStackTrace();
			}
		} catch (Exception ee) {
			ee.printStackTrace();
		}

	}

	/**
	 * in case we need stuff from the test_swf moved into the Main app 
	 * this is provided as a convenience. 
	 * one known item that needs to get written in the WindowedApplication is 
	 * the mx:Style block
	 */
	public static String getAttribute(String fileName, String element, String attr) {

		File file = null;
		StringBuffer sb = new StringBuffer();
		try { 

			file = new File(fileName);
  			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
  			DocumentBuilder db = dbf.newDocumentBuilder();
  			Document doc = db.parse(file);
 			// System.out.println("Root element " + doc.getDocumentElement().getNodeName());
  			NodeList nodeLst = doc.getElementsByTagName(element);

			// sort of a hack:
			Element el = (Element) nodeLst.item(0);

			return el.getAttribute (attr);


		} catch (Exception e) { 

			e.printStackTrace();


		}
		return sb.toString();
	}


	/**
	 * in case we need stuff from the test_swf moved into the Main app 
	 * this is provided as a convenience. 
	 * one known item that needs to get written in the WindowedApplication is 
	 * the mx:Style block
	 */
	public static String getBlockFromTestSwf(String fileName, String nodeName) {

		File file = null;
		StringBuffer sb = new StringBuffer();
		try { 

			file = new File(fileName);
  			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
  			DocumentBuilder db = dbf.newDocumentBuilder();
  			Document doc = db.parse(file);
  			doc.getDocumentElement().normalize();
 			// System.out.println("Root element " + doc.getDocumentElement().getNodeName());
  			NodeList nodeLst = doc.getElementsByTagName(nodeName);

		      	TransformerFactory transfac = TransformerFactory.newInstance();

      			Transformer trans = transfac.newTransformer();
      			trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
      			trans.setOutputProperty(OutputKeys.INDENT, "yes");

      			// Print the DOM node

      			StringWriter sw = new StringWriter();
      			StreamResult result = new StreamResult(sw);

			for (int s = 0; s < nodeLst.getLength(); s++) {

    				Node aNode = nodeLst.item(s);

      				DOMSource source = new DOMSource(aNode);
      				trans.transform(source, result);
      				String xmlString = sw.toString();

				// System.out.println ("adding styles: " + xmlString);
				sb.append (xmlString);

			}





		} catch (Exception e) { 

			e.printStackTrace();


		}

		return sb.toString();


	}

	public static String getSwfSubDir(String swfString) {

		String tmp = "";
		if (swfString.indexOf (File.separator)!= -1) {

			tmp = swfString.substring (0, swfString.lastIndexOf (File.separator));

		}
		return  tmp;

	}


	/// given an mxml
	public static String getSwfClassName(String swfString) {

		String tmp = null;
		if (swfString.indexOf (File.separator)!= -1) {

			tmp = swfString.substring (swfString.lastIndexOf (File.separator)+1, swfString.indexOf (".mxml"));

		}
		return  tmp;

	}


	public static final String stock_string = "CLASS_NAME";
	public static final String script_start = "<mx:Script";


	public static void transformDummyAndCopy (String prefix, String prefix2, String mxml, String templateFile, String swfDir, String insertBlock) {


		String className = getSwfClassName (mxml);

		String fileContents = readFileIntoString (templateFile);

		int insertPoint = -1;

		fileContents = fileContents.replaceAll (stock_string, prefix2+className);

		if (insertBlock.length() > 0) {
			insertPoint = fileContents.indexOf (script_start);

			StringBuffer sb = new StringBuffer(fileContents);
			sb.insert ( (insertPoint-1), insertBlock);

			fileContents = sb.toString();
		}

		try { 	
		writeStringToFile (fileContents, getNewMxmlName(swfDir, mxml, prefix));
		} catch (Exception e) { 
			e.printStackTrace();
		}
		
	}



	public static String doAll (String args, String prefix, String prefix2, String mxml, String templateFile, String targetDir) {


		if (mxml.indexOf ("\\apollo\\") != -1  || mxml.indexOf ("/apollo/") != -1)
			return args;


		// System.out.println ("here is the dir AApp got; " + targetDir);

		/// need more from the Test swf
		String insertBlock = getBlockFromTestSwf (mxml, "mx:Style");	

		/// do all, then return the adjusted Arg
		transformDummyAndCopy (prefix, prefix2, mxml, templateFile, targetDir, insertBlock);
	
		transformTestSwfToWindow (mxml, targetDir, prefix2);


		args += " -includes=WaitForWindow";
		return adjustArgList(args, mxml, targetDir, prefix2);
	}

	private static void writeStringToFile (String str, String fileName) throws Exception {

		BufferedOutputStream bos = new BufferedOutputStream (new FileOutputStream (fileName));

		bos.write (str.getBytes(), 0, str.length());
		bos.flush();
		bos.close();


    	}


	public static String readFileIntoString (String mxml) {

	
		try { 
		BufferedInputStream bis = new BufferedInputStream (new FileInputStream (mxml));

		ByteArrayOutputStream bos = new ByteArrayOutputStream();

		int av = 0;
		byte [] b = null;
		
		String contents = null;

		while ((av = bis.available()) > 0) { 
			b = new byte[av];
			bis.read (b, 0, av);
			bos.write (b, 0, av);

		}


		bis.close();

		return bos.toString();	


        } catch (Exception e) {
            e.printStackTrace();
        }

		return (String)null;

    	}





	public static void main (String [] args) { 


	}	



}
