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

import java.awt.image.*;
import java.io.*;
import java.lang.reflect.*;
import java.net.*;
import java.util.*;
import java.text.SimpleDateFormat;

import javax.imageio.*;
//import javax.mail.*;
//import javax.mail.internet.*;

import utils.MobileUtil;
import utils.FileUtils;
//import utils.HtmlNotify;
import utils.StringUtils;
import utils.P12Reader;
import com.adobe.air.apk.APKPackager;
import com.adobe.air.Listener;
import com.adobe.air.Message;
import com.adobe.air.SDK;

public class MobileConfigWriter {

	private static final String MOBILE_DIR = "mustella/tests/mobile";
	private static final String AS_CLASS = "MobileConfig";
	private static int adl_extras_XscreenDPI = -1;
	private static String[] adl_extras = null;

	static {
		try {
			adl_extras = System.getProperty( "adl_extras" ).split( " " );
			
			for( int i = 0; i < adl_extras.length; ++i ){
				if( adl_extras[ i ].compareToIgnoreCase( "-XscreenDPI" ) == 0 ){
					adl_extras_XscreenDPI = new Integer( adl_extras[ i + 1 ] ).intValue();
				}
			}
			
		} catch (Exception e) {
			adl_extras_XscreenDPI = -1;
			e.printStackTrace();
		}
		
		//System.out.println("adl_extras_XscreenDPI: " + adl_extras_XscreenDPI);
	}

	public MobileConfigWriter(){
	}


	static public String write( String device_name, String target_os, String os_version, String frameworksDir, int run_id, String exclude_filename ){
		File theFile = null;
		File theDir = null;
		File excludeFile = null;
		File[] files = null;
		String theClassString = null;
		String theFileString = null;
		String theDirString = null;
		Calendar cal = null;
		FileWriter fw = null;
		String classContents = null;
		String ret = null;
		int i = 0;

		try {
			theClassString = AS_CLASS;
			theFileString = theClassString + ".as";
			theDirString = frameworksDir;

			theFile = new File( theDirString + File.separator + theFileString);
			theDir = new File( theDirString );

			// Delete any old ones.
			MobileConfigWriterFilter filter = new MobileConfigWriterFilter();
			filter.fileToKeep = theFileString;
			files = theDir.listFiles( filter );

			if( files != null ){
				for( i = 0; i < Array.getLength( files ); ++i ){
					// System.out.println("deleting " + files[i].getCanonicalPath());
					files[ i ].delete();
				}
			}

			try{
				excludeFile = new File( exclude_filename );
			}catch(Exception e){
				e.printStackTrace();
			}

			// Put the contents of the class to create in a string.
			classContents = constructClass( device_name, target_os, os_version, theClassString, excludeFile, run_id );

			// Write it.
			fw = new FileWriter ( theFile );
			fw.write ( classContents, 0, classContents.length());
			fw.flush();
			fw.close();
			System.out.println ( "created " + theFile.toString() );

			ret = theClassString;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return ret;
	}


	/**
	 * Returns a string which contains the text which will be written to the class.
	 **/
	static private String constructClass( String device_name, String target_os, String os_version, String className, File excludeFile, int run_id ){
		int i = 0;

		String ret = "package {\n";
				ret += "import flash.display.DisplayObject;\n";
				ret += "import flash.system.Capabilities;\n";

				if( target_os.compareToIgnoreCase( MobileUtil.IOS ) == 0 ||
					target_os.compareToIgnoreCase( MobileUtil.QNX ) == 0) {
					ret += "import flash.filesystem.*;\n";
				}

				ret += "[Mixin]\n";
				ret += "/**\n";
				ret += "* By including this mixin via CompileMustellaSwfs, we\n";
				ret += "* can set up some variables for UnitTester to use for\n";
				ret += "* an Android run.\n";
				ret += "*/\n";
				ret += "public class " + className + "\n";
				ret += "{\n";
				ret += "	public static function init(root:DisplayObject):void\n";
				ret += "	{\n";

				// ConditionalValue stuff
				ret += "		if( UnitTester.cv == null ){\n";
				ret += "			UnitTester.cv = new ConditionalValue();\n";
				ret += "		}\n";
				ret += "		UnitTester.cv.device = \"" + device_name + "\";\n";
				ret += "		UnitTester.cv.os = \"" + target_os + "\";\n";
				ret += "		UnitTester.cv.targetOS = \"" + target_os + "\";\n";
				ret += "		UnitTester.cv.osVersion = \"" + os_version + "\";\n";
				
				// If device, get the proper dpi bucket (160/240/320/480) for the device.
				if( (target_os.compareToIgnoreCase(MobileUtil.MAC) == 0) || (target_os.compareToIgnoreCase(MobileUtil.WIN) == 0) ){
					if( adl_extras_XscreenDPI == -1 ){
						ret += "		UnitTester.cv.deviceDensity = flash.system.Capabilities.screenDPI;\n";
					}else{
						ret += "		UnitTester.cv.deviceDensity = Util.roundDeviceDensity( flash.system.Capabilities.screenDPI );\n";
					}
				}
				// if the target OS is android or iOS, the device_name might not be a real device but mac or win, indicating a desktop
				// emulator. If that's the case, treat this the same as above. 
				else if((target_os.compareToIgnoreCase(MobileUtil.ANDROID) == 0) || (target_os.compareToIgnoreCase(MobileUtil.IOS) == 0)) {
					if( (device_name.compareToIgnoreCase(MobileUtil.MAC) == 0 ) || (device_name.compareToIgnoreCase(MobileUtil.WIN) == 0) ) {
						if( adl_extras_XscreenDPI == -1 ){
							ret += "		UnitTester.cv.deviceDensity = flash.system.Capabilities.screenDPI;\n";
						}else{
							ret += "		UnitTester.cv.deviceDensity = Util.roundDeviceDensity( flash.system.Capabilities.screenDPI );\n";
						}
					} else {
						ret += "		UnitTester.cv.deviceDensity = " + Integer.toString(MobileUtil.getDeviceDensity(device_name)) + ";\n";
					}
				}
				else{
					ret += "		UnitTester.cv.deviceDensity = " + Integer.toString(MobileUtil.getDeviceDensity(device_name)) + ";\n";
				}

				// Don't get this confused with the above.  Maybe the above needs to be changed.  The variable below always
				// uses Capabilities.screenDPI.
				ret += "		UnitTester.cv.screenDPI = flash.system.Capabilities.screenDPI;\n";

				ret += "		//UnitTester.cv.deviceWidth = set by MultiResult;\n";
				ret += "		//UnitTester.cv.deviceHeight = set by MultiResult;\n";
				ret += "		//UnitTester.cv.color = this is not defined yet, but there are rumours it might be.\n";

				// Other stuff
				ret += "		UnitTester.run_id = \"" + run_id + "\";\n";
				ret += "		UnitTester.excludeFile = \"" + excludeFile.getName() + "\";\n";

				for( i = 0; i < Array.getLength( MobileUtil.DEVICES_USING_SDCARD ); ++i){
					if( device_name.compareToIgnoreCase( MobileUtil.DEVICES_USING_SDCARD[ i ] ) == 0 ){
						ret += "		UnitTester.mustellaWriteLocation = \"" + MobileUtil.SDCARD_DIR + "\";\n";
						ret += "		UnitTester.writeBaselinesToDisk = true;\n";
					}
				}

				if( target_os.compareToIgnoreCase( MobileUtil.IOS ) == 0 ){
					ret += "		UnitTester.mustellaWriteLocation = File.documentsDirectory.nativePath;\n";
					ret += "		UnitTester.writeBaselinesToDisk = true;\n";
				}

				if( target_os.compareToIgnoreCase( MobileUtil.QNX ) == 0 ){
					ret += "		UnitTester.mustellaWriteLocation = File.applicationStorageDirectory.nativePath;\n";
					ret += "		UnitTester.writeBaselinesToDisk = true;\n";
				}

				ret += "	}\n";
				ret += "}\n";
				ret += "}\n";

		return ret;
	}


	/**
	 * This is a filter which deletes extra .as files which this class creates.
	 **/
	public static class MobileConfigWriterFilter implements FilenameFilter{

		/**
		 *	SWF to test
		 **/
		public String fileToKeep = "";

		/**
		 * constructor
		 **/
		public void MobileConfigWriterFilter(){}

		/**
		 * This is the one method to implement for the interface.
		 **/
		public boolean accept( File dir, String name ){

			File f = new File( dir, name );

			if( (name.indexOf( AS_CLASS ) > -1)	&&
			    (name.indexOf( ".as" ) > -1)	&&
			    (name.compareToIgnoreCase( fileToKeep ) != 0 ) ){
				return true;
			}else{
				return false;
			}
		}

	} // end APKPackagerFilenameFilter class

} // End MobileConfigWriter class

