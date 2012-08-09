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

import utils.*;

/**

Writes application descriptor files for AIR


*/
public class ApolloAdjuster {


	static String swffile = null;
	static String xmlfile = null;
	static String xmlfile2 = null;
	static String delete_file = null;
	static String deviceName = "";

	/// the template file.
	static String template_location = "/templates/air/descriptor-template.xml";
	static String model_file = System.getProperty ("apollo_location") +  template_location;


	static String xmlnsVal = "http://ns.adobe.com/air/application/1.0";

	static {

		try {
			if (System.getProperty ("air_xmlns") != null)
				xmlnsVal = System.getProperty ("air_xmlns");
		} catch (Exception e) {

			/// leave it

		}


		try {
			deviceName = System.getProperty( "device_name" );
		} catch (Exception e) {
			e.printStackTrace();
		}
		
	}


	/**
	 * use the template that's part of the distribution to create the
	 * application descriptor file.
	 * See code comments for details.
	 */
	public static String xmlTransformFromTemplate ( boolean includeSwfParent ) throws Exception {

		DocumentBuilder docb = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		Document doc = docb.parse (new File(model_file));

		NodeList nl = null;

		String justSwf = getSwfName ( swffile, false );
		String appid = justSwf.substring( 0, justSwf.indexOf( ".swf" ) ).replace( "_", "" );
		String content = getSwfName ( swffile, includeSwfParent );

		/// modify the pieces we need to: content:
		nl = doc.getElementsByTagName("content");

		if ( nl.item(0).getFirstChild() == null)  {
			Text t = doc.createTextNode (content);
			nl.item(0).appendChild(t);
		} else
			nl.item(0).getFirstChild().setNodeValue(content);

		/// modify the pieces we need to: filename
		//  Note: The adt tool doesn't like filename to be exactly the same as the name of the swf.
		nl = doc.getElementsByTagName("filename");

		if ( nl.item(0).getFirstChild() == null)  {
			Text ft = doc.createTextNode (appid);
			nl.item(0).appendChild (ft);
		} else {
			nl.item(0).getFirstChild().setNodeValue(appid);
		}


		/// modify the pieces we need to: id
		nl = doc.getElementsByTagName("id");
		if ( nl.item(0).getFirstChild() == null)  {
			Text it = doc.createTextNode (appid);
			nl.item(0).appendChild (it);
		} else
			nl.item(0).getFirstChild().setNodeValue(appid);

		nl = doc.getElementsByTagName("versionNumber");
		if ( nl != null && nl.item(0) != null )  {
			if (nl.item(0).getFirstChild() == null)  {
				Text vit = doc.createTextNode ("1.0.0");
				nl.item(0).appendChild (vit);
			} else { 
				nl.item(0).getFirstChild().setNodeValue("1.0.0");
			}
		}

		/// modify the pieces we need to: android
		if( deviceName != null ){
			if( MobileUtil.getOSForDevice( deviceName ).compareToIgnoreCase( MobileUtil.ANDROID_OS ) == 0 ){
				nl = doc.getElementsByTagName("application");
				Element el = doc.createElement("android");
				
				Node el2 = el.appendChild( doc.createElement("manifestAdditions") );
				el2.appendChild( doc.createCDATASection("\n\t<manifest>" +
														"\n\t\t<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.INTERNET\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.WAKE_LOCK\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.DISABLE_KEYGUARD\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.ACCESS_FINE_LOCATION\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.READ_PHONE_STATE\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.CAMERA\" />" +
														"\n\t\t<uses-permission android:name=\"android.permission.RECORD_AUDIO\" />" +
														"\n\t</manifest>\n"));
				nl.item(0).appendChild(el);
				
				// For namespace 3.1 and after, use 16 bit color for Android due to performance issues.
				Element colorDepth = doc.createElement("colorDepth");
				Text colorDepthVal = doc.createTextNode ("16bit");
				colorDepth.appendChild(colorDepthVal);
				el.appendChild(colorDepth);
				
				// Set the softKeyboardBehavior in initialWindow.  This is only supported in Android right now, and
				// this code can just be moved if it ends up being supported for other devices.
				Element softKeyboardBehavior = doc.createElement("softKeyboardBehavior");
				Text softKeyboardBehaviorVal = doc.createTextNode ("none");
				softKeyboardBehavior.appendChild(softKeyboardBehaviorVal);
				nl = doc.getElementsByTagName ("initialWindow");
				nl.item(0).appendChild (softKeyboardBehavior);
			}
		}

		/// modify the pieces we need to: iOS
		if( deviceName != null ){
			if( MobileUtil.getOSForDevice( deviceName ).compareToIgnoreCase( MobileUtil.IOS ) == 0 ){

				// Add fullScreen, autoOrients, aspectRatio, and renderMode to initialWindow.  I'm not sure which of these
				// are absolutely needed, but I do know that the file which works contains these items in addition to the above.
				Element fullScreen = doc.createElement("fullScreen");
				Text fullScreenVal = doc.createTextNode ("true");
				fullScreen.appendChild (fullScreenVal);

				Element autoOrients = doc.createElement("autoOrients");
				Text autoOrientsVal = doc.createTextNode ("true");
				autoOrients.appendChild (autoOrientsVal);

				Element aspectRatio = doc.createElement("aspectRatio");
				Text aspectRatioVal = doc.createTextNode ("portrait");
				aspectRatio.appendChild (aspectRatioVal);

				Element renderMode = doc.createElement("renderMode");
				Text renderModeVal = doc.createTextNode ("cpu");
				renderMode.appendChild (renderModeVal);
				
				nl = doc.getElementsByTagName ("initialWindow");
				nl.item(0).appendChild(fullScreen);
				nl.item(0).appendChild(autoOrients);
				nl.item(0).appendChild(aspectRatio);
				nl.item(0).appendChild(renderMode);
				
				// Run iOS tests in high resolution mode.  Add these to the application node.
				nl = doc.getElementsByTagName("application");
				Element el = doc.createElement("iPhone");
				Node el2 = el.appendChild( doc.createElement("InfoAdditions") );
				el2.appendChild( doc.createCDATASection("\n\t<key>UIDeviceFamily</key>" +
														"\n\t\t<array>" +
														"\n\t\t\t<string>1</string>" +
														"\n\t\t\t<string>2</string>" +
														"\n\t\t</array>" +
														"\n\t\t<key>UIStatusBarStyle</key>" +
														"\n\t\t<string>UIStatusBarStyleBlackOpaque</string>" +
														"\n\t\t<key>UIRequiresPersistentWiFi</key>" +
														"\n\t\t<string>YES</string>"));
				nl.item(0).appendChild(el);
				
				nl = doc.getElementsByTagName("iPhone");
				Element reqDisplayRes = doc.createElement("requestedDisplayResolution");
				Text reqDisplayResVal = doc.createTextNode ("high");
				reqDisplayRes.appendChild(reqDisplayResVal);
				nl.item(0).appendChild(reqDisplayRes);				
			}
		}

		// modify the pieces we need to: name.  Be sure it's no more than 25 characters (QNX restriction).
		if( deviceName != null ){
			if( MobileUtil.getOSForDevice( deviceName ).compareToIgnoreCase( MobileUtil.QNX ) == 0 ){
				
				String appName = appid;
				if( appName.length() > 25 ){
					appName = appName.substring( 0, 25 );
				}
				
				nl = doc.getElementsByTagName( "name" );
				if ( nl.item(0).getFirstChild() == null )  {
					Text nameNode = doc.createTextNode ( appName );
					nl.item(0).appendChild ( nameNode );
				} else
					nl.item(0).getFirstChild().setNodeValue( appName );
			}
		}
				
		/// modify the pieces we need to: systemChrome (we like 'none')
		/// this is commented out in the template, so we just add it
		Element sysChrome = doc.createElement("systemChrome");
		Text chrome = doc.createTextNode ("none");
		sysChrome.appendChild (chrome);

		/// modify the pieces we need to: transparent (we like 'true')
		/// this is commented out in the template, so we just add it
		Element trans = doc.createElement("transparent");
		Text transt = doc.createTextNode ("true");
		trans.appendChild (transt);

		/// modify the pieces we need to: visible (we like 'true')
		/// this is commented out in the template, so we just add it
		Element viz = doc.createElement("visible");
		Text transv = doc.createTextNode ("true");
		viz.appendChild (transv);

		/// put them in the InitialWindow section
		nl = doc.getElementsByTagName ("initialWindow");
		nl.item(0).appendChild(sysChrome);
		nl.item(0).appendChild(trans);
		nl.item(0).appendChild(viz);

		/// output the result
		Transformer transformer = TransformerFactory.newInstance().newTransformer();
		transformer.setOutputProperty(OutputKeys.INDENT, "yes");
		//initialize StreamResult with File object to save to file
		StreamResult result = new StreamResult(new StringWriter());
		DOMSource source = new DOMSource(doc);
		transformer.transform(source, result);
		String xmlString = result.getWriter().toString();

		return xmlString;
	}


	public static String xmlWriter (String file) {
		return xmlWriter (file, true);

	}
	public static String xmlWriter (String file, boolean deleteIt) {
		return xmlWriter (file, deleteIt, false);
	}

	public static String xmlWriter (String file, boolean deleteIt, boolean includeSwfParent) {

		System.out.println ("apollo adj with : " + file);

		if (file.indexOf (".swf") != -1) {

			System.out.println ("apollo adj thinks it's a swf");
			swffile = file;
			// builder's generated name
			xmlfile = file.substring (0, file.indexOf (".swf")) + ".xml";
			if (deleteIt)
				delete_file = file.substring (0, file.indexOf (".swf")) + ".delete";
			else
				delete_file = null;

		} else if (file.indexOf (".xml") != -1) {

			xmlfile = file;
			swffile = file.substring (0, file.indexOf (".xml")) + ".swf";
			if (deleteIt)
				delete_file = file.substring (0, file.indexOf (".xml")) + ".delete";
			else
				delete_file = null;
		}

		/// check if it exists.

		if (new File(xmlfile).exists() && (delete_file == null || !new File(delete_file).exists()))   {
			System.out.println ("not writing Apollo file");
			return xmlfile;
		} else  {
			System.out.println ("writing Apollo file!");
			createFile( includeSwfParent );
		}

		return xmlfile;
	}


	public static boolean didWrite () {
		try {
			return new File(delete_file).exists();
		} catch (Exception e) {
			return false;
		}
	}


	public static void delete () {

		System.out.println ("removing the xml app file");
		new File(delete_file).delete();
		new File(xmlfile).delete();

	}

	public static String getSwfName (String file, boolean includeSwfParent) {
		String ret = null;
		String left = null;
		String right = null;

		if (includeSwfParent){
			right = file.substring( file.lastIndexOf( File.separator ) + 1 );	// ButtonMain.swf
			right = "/" + right;												// /ButtonMain.swf, must be a /, cannot be a \.
			left = file.substring( 0, file.lastIndexOf( File.separator ) );		// blah/blah/Button/swfs
			left = left.substring( left.lastIndexOf( File.separator ) +1 );		// swfs
			ret = left + right;													// swfs/ButtonMain.swf
		}else{
			if (file.indexOf("/") != -1) {
				ret = file.substring (file.lastIndexOf("/")+1);
			} else if (file.indexOf(File.separator) != -1) {
				ret = file.substring (file.lastIndexOf(File.separator)+1);
			} else {
				ret = file;
			}
		}

		return ret;
	}

	public static void createFile ( boolean includeSwfParent ) {

		System.out.println ("full swf is " + swffile);

		FileOutputStream bos = null;
		FileOutputStream bos2 = null;

		try {
			/// get the contents we'll write:
			String xmlString = xmlTransformFromTemplate( includeSwfParent );

			/// write a marker to delete the file we'll write
			if (delete_file != null) {
				bos2 = new FileOutputStream (delete_file);
				bos2.write ("0".getBytes(), 0, 1);
				bos2.flush();
				bos2.close();
			}

			/// write the xml file
			bos = new FileOutputStream (xmlfile);

			bos.write (xmlString.getBytes(), 0, xmlString.length());

			bos.flush();
			bos.close();

		} catch (Exception e) {
			e.printStackTrace();
			try {
			bos.close();
			bos2.close();
			} catch (Exception e2) {
			}
		}
	}



	public static void main (String [] args) throws Exception {

		xmlWriter (args[0]);



	}


}
