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

import org.apache.tools.ant.Task;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.BuildException;
import java.io.*;
import java.lang.reflect.*;
import java.net.InetAddress;
import java.util.ArrayList;
import utils.MobileUtil;

public class GetDeviceSpecsTask extends Task {

	private static String adb = null;	// Android adb utility
	private String androidSdk = null;
	private int runId = -1;
	private ArrayList deviceIds = null;	// The devices
	private String os = null;			// We may do this someday based on what we get in that version string.
	private String osVersion = null;	// e.g. 2.2
	private String arch = null;			// Chip architecture, not used.  Set to "unknown".
	private String deviceName = null;
	private String mustellaDir = null;

	public void setRunId( String val ) {
		try{
			this.runId = new Integer( val ).intValue();
		}catch( Exception e ){
			this.runId = -1;
		}
	}

	public String getRunId() {
		try{
			return Integer.toString( this.runId );
		}catch( Exception e ){
			e.printStackTrace();
		}

		return "-1";
	}

	public void setMustellaDir( String val ) {
		this.mustellaDir = val;
	}

	public String getMustellaDir() {
		return this.mustellaDir;
	}

	public void setDeviceName( String val ) {
		this.deviceName = val;
	}

	public String getDeviceName() {
		return this.deviceName;
	}

	public void setOsVersion( String val ) {
		this.osVersion = val;
	}

	public String getOsVersion() {
		return this.osVersion;
	}

	public void setOs( String val ) {
		this.os = val;
	}

	public String getOs() {
		return this.os;
	}

	public void setAndroidSdk( String val ) {
		this.androidSdk = val;
	}

	public String getAndroidSdk() {
		return this.androidSdk;
	}


	// Query just one device.  A test run can have one os/version.
	public void execute() {

		try{
			Project project = getProject();
			int i = 0;

			// Get the os.
			os = MobileUtil.getOSForDevice( deviceName );
			
			if( os == null ){
				System.out.println("null os for device '" + deviceName + "', so the Mustella framework will set it at run time.  If you want to run on a device, set your device_name to one of the following:");

				for( i = 0; i < Array.getLength( MobileUtil.DEVICES_USING_ANDROID ); ++i){
					System.out.println("	" + MobileUtil.DEVICES_USING_ANDROID[ i ]);
				}

				for( i = 0; i < Array.getLength( MobileUtil.DEVICES_USING_IOS ); ++i){
					System.out.println("	" + MobileUtil.DEVICES_USING_IOS[ i ]);
				}

			   return;
				
			}else if( os.compareToIgnoreCase( MobileUtil.ANDROID_OS ) == 0 ){

				if( androidSdk == null ){
					System.out.println("GetAndroidSpecsTask: No android sdk!");
					return;
				}else{

					// If you use Google's zip file
					adb = androidSdk + File.separator + "tools" + File.separator + "adb";

					String os = System.getProperties().getProperty("os.name");
					os = os.toLowerCase();
					if( os.indexOf( "win" ) > -1 ){
						adb += ".exe";
					}

					// If you use Google's installer
					if(!new File(adb).exists()){
						adb = androidSdk + File.separator + "platform-tools" + File.separator + "adb";
						if( os.indexOf( "win" ) > -1 ){
							adb += ".exe";
						}
					}

				}

				deviceIds = MobileUtil.getAndroidDeviceIds(adb, runId, null);

				if( deviceIds.size() == 0 ){
					System.out.println( "GetAndroidSpecsTask: Found no devices responding." );
					project.setProperty("get_mobile_data_fail", "true");
					return;
				}

				// Get the os version for a device.
				osVersion = MobileUtil.getAndroidOsVersion( adb, (String) deviceIds.get( 0 ) );
				if( osVersion == null ){
					System.out.println( "GetAndroidSpecsTask: Could not get the os version." );
					project.setProperty("get_mobile_data_fail", "true");
					return;
				}

				project.setProperty( "use_android_runner", "true" );
				project.setProperty( "target_os_name", os );
				project.setProperty( "os", os );
				project.setProperty( "os_version", osVersion );
				project.setProperty( "arch", "unknown" );
				project.setProperty( "exclude_filename", mustellaDir + File.separator + "tests" + File.separator + "ExcludeList" + os + ".txt");
			}else if( os.compareToIgnoreCase( MobileUtil.IOS ) == 0 ){
				
				osVersion = MobileUtil.getIOSVersion();
				arch = MobileUtil.getIOSProcessor();

				project.setProperty( "use_ios_runner", "true" );
				project.setProperty( "target_os_name", os );
				project.setProperty( "os", os );
				
				if( osVersion != null ){
					project.setProperty( "os_version", osVersion );
				}

				if( arch != null ){
					project.setProperty( "arch", arch );
				}
				
				project.setProperty( "exclude_filename", mustellaDir + File.separator + "tests" + File.separator + "ExcludeList" + os + ".txt");				
			}else if( os.compareToIgnoreCase( MobileUtil.QNX ) == 0 ){

				if (project.getProperty( "qnx_device_ip" ) == null)
				{
					InetAddress [] addresses = InetAddress.getAllByName(InetAddress.getLocalHost().getCanonicalHostName());
					for (int ipIndex = 0; ipIndex < addresses.length; ipIndex++)
					{
						InetAddress curAddress = addresses[ipIndex];
						String strCurAddress = curAddress.getHostAddress();
						if (strCurAddress.indexOf("169.254") > -1)
						{
							String lastQuadrant = strCurAddress.substring(strCurAddress.lastIndexOf(".") + 1);
							int lastQuadrantNumber = Integer.parseInt(lastQuadrant);
							lastQuadrantNumber--;
							String remainingPart = strCurAddress.substring(0, strCurAddress.lastIndexOf("."));
							String deviceIP = remainingPart + "." + Integer.toString(lastQuadrantNumber);
							project.setProperty("qnx_device_ip", deviceIP);
							break;
						}
					}
				}				
				project.setProperty( "use_qnx_runner", "true" );
				project.setProperty( "target_os_name", os );
				project.setProperty( "os", os );
				project.setProperty( "exclude_filename", mustellaDir + File.separator + "tests" + File.separator + "ExcludeList" + os + ".txt");				
			}else{
				String targetOS = project.getProperty("target_os_name");
				if( targetOS != null ) {
					System.out.println("Skipping mobile device setup; "+deviceName+" is not a mobile device, maybe emulating target OS "+targetOS+" on desktop.");
				} else {
					System.out.println("Skipping mobile device setup; " + deviceName + " is not a supported mobile device.  Maybe this is a 'mobile on desktop' run or a new device.");
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}

	}


} // end GetAndroidSpecsTask
