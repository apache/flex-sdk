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
package utils;

import java.io.*;
import java.lang.reflect.Array;
import java.net.*;
import java.util.*;
import javax.imageio.*;
//import javax.mail.*;
//import javax.mail.internet.*;
//import utils.HtmlNotify;

public class MobileUtil {

	// OSs
	public static final String ANDROID_OS = "android";
	public static final String IOS = "ios";	// "iPhone OS" is what the iPod Touch 4G returns, anyway.
	public static final String QNX = "qnx";
	public static final String MAC = "mac";
	public static final String WIN = "win";
	public static final String WINDOWS = "windows";

	// devices
	// Get rid of these two when we do device types (soon).
	public static final String ANDROID = "android";
	public static final String ANDROID2 = "Android";
	public static final String PLAYBOOK = "playbook";
	public static final String DESIRE = "desire";
	public static final String DROID = "droid";
	public static final String DROID_2 = "droid2";
	public static final String DROID_X = "droidX";
    public static final String DROID_PRO = "droidPro";
	public static final String NEXUS_ONE = "nexusOne";
	public static final String EVO = "evo";
	public static final String INCREDIBLE = "incredible";
	public static final String XOOM = "xoom";
	public static final String SDCARD_DIR = "/sdcard/mustella";
	public static final String IPAD = "iPad";
	public static final String IPAD2 = "iPad2";
	public static final String IPAD3 = "iPad3";
	public static final String IPAD4 = "iPad4";
	public static final String IPOD_TOUCH_3GS = "iPodTouch3GS";
	public static final String IPOD_TOUCH_4G = "iPodTouch4G";
	public static final String IPOD_TOUCH_5G = "iPodTouch5G";
	public static final String ANDROID_TABLET = "androidTablet"; // not used anywhere yet, not sure if this is a good name.


	// Useful collections
    public static final String[] DEVICES_USING_ANDROID = {ANDROID, ANDROID2, DESIRE, DROID, DROID_2, DROID_X, DROID_PRO, NEXUS_ONE, EVO, INCREDIBLE, ANDROID_TABLET, XOOM};
	public static final String[] DEVICES_USING_IOS = {IPAD, IPAD2, IPOD_TOUCH_3GS, IPOD_TOUCH_4G, IPOD_TOUCH_5G};
	public static final String[] DEVICES_USING_QNX = {PLAYBOOK};
    public static final String[] DEVICES_USING_SDCARD = {ANDROID, ANDROID2, DESIRE, DROID, DROID_2, DROID_X, DROID_PRO, NEXUS_ONE, EVO, INCREDIBLE, ANDROID_TABLET, XOOM};
    public static final String[] DEVICES_AROUND_160PPI = {WIN, DROID_PRO, ANDROID_TABLET, XOOM, IPOD_TOUCH_3GS, IPAD, IPAD2, PLAYBOOK};
	public static final String[] DEVICES_AROUND_240PPI = {ANDROID, ANDROID2, DESIRE, DROID, DROID_2, DROID_X, NEXUS_ONE, EVO, INCREDIBLE};
	public static final String[] DEVICES_AROUND_320PPI = {WIN, IPOD_TOUCH_4G, IPOD_TOUCH_5G, IPAD3, IPAD4};
	public static final String[] DEVICES_AROUND_480PPI = {};

	// Other
	public static final String MOBILE_FRAMEWORK_DIR = "MobileConfig";
	public static final String IOS_PRODUCTNAME = "ProductName:";
	public static final String IOS_PRODUCTVERSION = "ProductVersion:";
	public static final String IOS_PROCESSOR = "Processor type:";
	public static final String IOS_MEMORYAVAILABLE = "Primary memory available:";

	/**
	 * getOSForDevice
	 * Given a device type, return the OS.  e.g. Input "nexus_one", get back "android".
	 **/
	public static String getOSForDevice(String device_name){
		int i = 0;
		String ret = null;

		for( i = 0; i < Array.getLength( DEVICES_USING_ANDROID ); ++i){
			if( device_name.compareToIgnoreCase( DEVICES_USING_ANDROID[ i ] ) == 0 ){
				ret = ANDROID_OS;
			}
		}

		if( ret == null ){
			for( i = 0; i < Array.getLength( DEVICES_USING_IOS ); ++i){
				if( device_name.compareToIgnoreCase( DEVICES_USING_IOS[ i ] ) == 0 ){
					ret = IOS;
				}
			}
		}

		if( ret == null ){
			for( i = 0; i < Array.getLength( DEVICES_USING_QNX ); ++i){
				if( device_name.compareToIgnoreCase( DEVICES_USING_QNX[ i ] ) == 0 ){
					ret = QNX;
				}
			}
		}

		// When we run mobile tests on the desktop...
		if( ret == null ){
			if( device_name.compareToIgnoreCase( MobileUtil.MAC ) == 0 )
				return MobileUtil.MAC;
			else if( device_name.compareToIgnoreCase( MobileUtil.WIN ) == 0 )
				return MobileUtil.WIN;
			else if( device_name.compareToIgnoreCase( MobileUtil.WINDOWS ) == 0 )
				return MobileUtil.WIN;
		}

		return ret;
	}

	/**
	 * getDeviceIds
	 * Fetches the serial numbers of all devices available if they are in allowedIds.
	 */
	public static ArrayList getAndroidDeviceIds(String adb, int run_id, String[] allowedIds){
		String line = null;
		String body = null;
		Process p = null;
		ArrayList ret = new ArrayList();
		int numOfflineDevices = 0;
		int numReadyDevices = 0;
		int i = 0;
		InetAddress ia = null;

		/**
		if(allowedIds != null){
			System.out.println("allowedIds=" + allowedIds);
			for(i = 0; i < allowedIds.length; ++i){
				System.out.println("\t" + allowedIds[i]);
			}
		}
		**/

		try{
			if( new File(adb).exists() ){
				String[] listDevices = { adb, "devices" };
				p = Runtime.getRuntime().exec( listDevices );

				BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

				// Collect all of the device serial numbers.  Note that these serial numbers aren't the
				// same as the serial numbers found on the back of a device.
				while ( true ){
					line = br.readLine();

					if( (line == null) || (line.trim().compareToIgnoreCase("") == 0) ){
						break;
					}

					if( line.indexOf( "List of devices" ) == -1 ){
						if( line.indexOf( "device" ) > -1  ){
							++numReadyDevices;
							line = line.substring( 0, line.indexOf( "device" ) );
							line = line.trim();

							//System.out.println("getAndroidDeviceIds: line=" + line);

							// Make sure we're allowed to use this device.
							if( allowedIds != null ){
								for( i = 0; i < allowedIds.length; ++i ){
									if( line.compareToIgnoreCase( allowedIds[i].trim() ) == 0 ){
										System.out.println("Adding device: '" + line + "'");
										ret.add( line );
									}else{
										//System.out.println("Found device '" + line + "', but that does not match " + allowedIds[i].trim());
									}
								}
							}else{
								// If no restricted list of IDs was given, return all of them.
								ret.add( line );
							}

						} else if( line.indexOf( "offline" ) > -1  ) {
							++numOfflineDevices;
							line = line.substring( 0, line.indexOf( "offline" ) );
							line = line.trim();
							System.out.println("Found offline device: '" + line + "'");
						}
					}
				}

				if( ( numReadyDevices == 0 || numOfflineDevices > 0 ) && run_id > -1 ){
					try {
						System.out.println("There are no devices reporting at all.");

						/*
						ia = InetAddress.getLocalHost();
						String hostname = ia.getHostName();

						body = "(The following message is automatically generated by the Mustella framework.)  Device trouble is ocurring on " + hostname + ".  ";

						if( numOfflineDevices > 0 ){
							body = body + "We have " + Integer.toString(numOfflineDevices) + " offline device(s).  ";
						}

						if( numReadyDevices + numOfflineDevices == 0 ){
							body = body + "There are no devices reporting at all.  ";
						}

						if( numReadyDevices > 0 ){
							body = body + "On the bright side, at least we have " + Integer.toString(numReadyDevices) + " device(s) still able to respond, so all is not lost.  ";
						}

						body = body + "Can you please help?  Thanks!  ";

						InternetAddress[] to = new InternetAddress[1];
						to[0] = new InternetAddress("MustellaMobileResults@adobe.com");
						HtmlNotify hn = new HtmlNotify();
						hn.sendMessage("inner-relay-1.corp.adobe.com",
									   "rvollmar@adobe.com",
									   to,
									   hostname + " mustella device offline",
									   body);
						*/

					}
					catch(Exception e){
						e.printStackTrace();
					}
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * getAndroidOsVersion
	 * Asks a device for its OS version.
	 **/
	public static String getAndroidOsVersion( String adb, String deviceId ){
		String line = null;
		String ret = null;
		Process p = null;

		try{
			String[] getstats = { adb, "-s", deviceId, "shell", "getprop", "ro.build.version.release" };
			p = Runtime.getRuntime().exec( getstats );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			while ( true ){
				line = br.readLine();

				if( line == null ){
					break;
				} else {
					ret = line;
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		// Remove the period (replace() works OK if there isn't one).
		ret = ret.replace(".", "");

		return MobileUtil.ANDROID_OS + ret;
	}

	/**
	 * getDeviceDensity
	 * Returns a number to use for the PPI.
	 * system.Capabilities gives an exact number, like 254.  We don't want that.
	 * The device itself returns a general number, like "240", today, but who knows about later.
	 * So we're just going to hard code the sorting of devices into groups to reduce uncertainty.
	 **/
	//public static int getDeviceDensity( String adb, String deviceId ){
	public static int getDeviceDensity( String deviceId ){

		int i = 0;
		int ret = 0;

		for( i = 0; i < Array.getLength( DEVICES_AROUND_160PPI ); ++i ){
			if( deviceId.compareToIgnoreCase( DEVICES_AROUND_160PPI[ i ] ) == 0 )
				ret = 160;
		}

		for( i = 0; i < Array.getLength( DEVICES_AROUND_240PPI ); ++i ){
			if( deviceId.compareToIgnoreCase( DEVICES_AROUND_240PPI[ i ] ) == 0 )
				ret = 240;
		}

		for( i = 0; i < Array.getLength( DEVICES_AROUND_320PPI ); ++i ){
			if( deviceId.compareToIgnoreCase( DEVICES_AROUND_320PPI[ i ] ) == 0 )
				ret = 320;
		}
		
		for( i = 0; i < Array.getLength( DEVICES_AROUND_480PPI ); ++i ){
			if( deviceId.compareToIgnoreCase( DEVICES_AROUND_480PPI[ i ] ) == 0 )
				ret = 480;
		}

		return ret;
		/**
		String line = null;
		String ret = null;
		Process p = null;

		try{
			String[] getstats = { adb, "-s", deviceId, "shell", "getprop", "ro.sf.lcd_density" };
			p = Runtime.getRuntime().exec( getstats );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			while ( true ){
				line = br.readLine();

				if( line == null ){
					break;
				} else {
					ret = line;
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		return ret;
		**/
	}

	/**
	 * getAndroidModel
	 * Asks a device for its model.  It returns, for example, "Nexus One".
	 * We don't use this yet, but it might be handy.
	 **/
	public static String getAndroidModel( String adb, String deviceId ){
		String line = null;
		String ret = null;
		Process p = null;

		try{
			String[] getstats = { adb, "-s", deviceId, "shell", "getprop", "ro.product.model" };
			p = Runtime.getRuntime().exec( getstats );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			while ( true ){
				line = br.readLine();

				if( line == null ){
					break;
				} else {
					ret = line;
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * pingIOSDevice
	 * Checks to see if the device we're ssh'ing to is an "iPhone".
	 * sw_vers returns:
	 *   ProductName:    iPhone OS
	 *   ProductVersion: 4.1
	 *   BuildVersion:   8B118
	 **/
	public static boolean pingIOSDevice(){
		String line = null;
		boolean ret = false;
		Process p = null;

		try{
			String[] sw_vers = { "ssh", "-p", "2222", "root@localhost", "sw_vers" };
			p = Runtime.getRuntime().exec( sw_vers );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			System.out.println("Gathering device details");

			while ( true ){
				line = br.readLine();

				if( line == null )
					break;

				System.out.println("\t" + line);

				if( line.indexOf( IOS_PRODUCTNAME ) > -1 ){
					line = line.substring( IOS_PRODUCTNAME.length() ).trim();

					if( line.toLowerCase().indexOf( IOS ) > -1 ){
						ret = true;
					}
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * getIOSVersion
	 * Asks a device for its OS version.
	 * sw_vers returns:
	 *   ProductName:    iPhone OS
	 *   ProductVersion: 4.1
	 *   BuildVersion:   8B118
	 **/
	public static String getIOSVersion(){
		String line = null;
		String ret = null;
		Process p = null;

		try{
			String[] sw_vers = { "ssh", "-p", "2222", "root@localhost", "sw_vers" };
			p = Runtime.getRuntime().exec( sw_vers );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			while ( true ){
				line = br.readLine();

				if( line == null )
					break;

				if( line.indexOf( IOS_PRODUCTVERSION ) > -1 ){
					ret = line.substring( IOS_PRODUCTVERSION.length() ).trim();
					System.out.println("getIOSVersion found "  + ret);
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}


		return ret;
	}

	/**
	 * getIOSProcessor
	 * Asks a device for its architecture
	 * hostinfo returns:
	 *   Mach kernel version:
	 *   Darwin Kernel Version 10.3.1: Wed Aug  4 22:35:51 PDT 2010; root:xnu-1504.55.33~10/RELEASE_ARM_S5L8930X
	 *   Kernel configured for a single processor only.
	 *   1 processor is physically available.
	 *   1 processor is logically available.
	 *   Processor type: armv7 (arm v7)
	 *   Processor active: 0
	 *   Primary memory available: 247.00 megabytes
	 *   Default processor set: 27 tasks, 195 threads, 1 processors
	 *   Load average: 0.05, Mach factor: 0.94
	 **/
	public static String getIOSProcessor(){
		String line = null;
		String ret = null;
		Process p = null;

		try{
			String[] hostinfo = { "ssh", "-p", "2222", "root@localhost", "hostinfo" };
			p = Runtime.getRuntime().exec( hostinfo );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			while ( true ){
				line = br.readLine();

				if( line == null )
					break;

				if( line.indexOf( IOS_PROCESSOR ) > -1 ){
					ret = line.substring( IOS_PROCESSOR.length() ).trim(); // Now we have "armv7 (arm v7)"

					if( ret.indexOf( " " ) > -1 ){
						ret = ret.substring( 0, ret.indexOf( " " ) ).trim();
					}

					System.out.println("getIOSProcessor found "  + ret);
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * getIOSMemoryAvailable
	 * Asks a device for its available memory
	 * hostinfo returns:
	 *   Mach kernel version:
	 *   Darwin Kernel Version 10.3.1: Wed Aug  4 22:35:51 PDT 2010; root:xnu-1504.55.33~10/RELEASE_ARM_S5L8930X
	 *   Kernel configured for a single processor only.
	 *   1 processor is physically available.
	 *   1 processor is logically available.
	 *   Processor type: armv7 (arm v7)
	 *   Processor active: 0
	 *   Primary memory available: 247.00 megabytes
	 *   Default processor set: 27 tasks, 195 threads, 1 processors
	 *   Load average: 0.05, Mach factor: 0.94
	 **/
	public static String getIOSMemoryAvailable(){
		String line = null;
		String ret = null;
		Process p = null;

		try{
			String[] hostinfo = { "ssh", "-p", "2222", "root@localhost", "hostinfo" };
			p = Runtime.getRuntime().exec( hostinfo );

			BufferedReader br = new BufferedReader( new InputStreamReader( p.getInputStream() ) );

			while ( true ){
				line = br.readLine();

				if( line == null )
					break;

				if( line.indexOf( IOS_MEMORYAVAILABLE ) > -1 ){
					ret = line.substring( IOS_MEMORYAVAILABLE.length() ).trim();

					System.out.println("getIOSMemoryAvailable found "  + ret);
				}
			}
		}catch( IOException e ){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * Restarts the springboard.  Hopefully someday we can bypass the swipe!
	 **/
	public static boolean restartSpringboard( String message ){
		int inputData = -1;
		BufferedReader keyboardInput = null;
		Process p = null;
		boolean ret = false;

		try{
			String[] cmd = { "ssh", "-p", "2222", "root@localhost", "launchctl", "stop", "com.apple.SpringBoard" };
			p = Runtime.getRuntime().exec( cmd );
			p.waitFor();

			System.out.println(message);
			keyboardInput = new BufferedReader( new InputStreamReader( System.in ) );
			inputData = keyboardInput.read();
			System.out.println("got it, thanks");

			ret = true;
		}catch(Exception e){
			e.printStackTrace();
			ret = false;
		}

		return ret;
	}

	/**
	 * rebootIOSDevice
	 * Reboots, then waits for the device to become responsive to ssh commands.
	 **/
	public static void rebootIOSDevice(){
		boolean ready = false;
		Process p = null;

		try{
			String[] reboot = { "ssh", "-p", "2222", "root@localhost", "reboot" };
			p = Runtime.getRuntime().exec( reboot );

			while( !ready ){
				System.out.println("Waiting for device to reboot...");
				Thread.sleep( 1000 );
				ready = pingIOSDevice();
			}

		}catch( Exception e ){
			e.printStackTrace();
		}

		return;
	}

	/**
	 * Calls uicache on the device.  This refreshes the Springboard's list of apps
	 * so we don't have to swipe.  There are reports that it can sometimes take  a
	 * while to take effect, so we have some "wait" parameters, just in case.
	 **/
	public static void refreshIOSUICache(){
		refreshIOSUICache( 0, 0 );
	}

	public static void refreshIOSUICache( int attempts, int waitMillis ){
		Process p = null;
		int ret = -1;
		int i = 0;

		try{
			for( i = 0; i < attempts; ++i ){
				System.out.println( "Calling uicache" );
				String[] cmdRefresh = { "ssh", "-p", "2222", "root@localhost", "/usr/bin/uicache" };
				p = Runtime.getRuntime().exec( cmdRefresh );
				p.waitFor();
				//System.out.println( "Giving iOS " + waitMillis + " ms to catch up" );
				Thread.sleep( waitMillis );
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	/**
	 * Copies a file or directory to the device.  Returns true if to is present afterward.
	 **/
	public static void copyToIOS( String from, String to ){
		Process p = null;
		File fromFile = new File( from );
		String[] dirs = null;
		String curDir = null;
		String finalDir = null;

		try{
			if( !fromFile.exists() ){
				System.out.println("source " + from + " not found.");
			}

			if( to.trim().compareTo("") == 0 ){
				System.out.println("dest " + to + " is not valid.");
			}

			// ISSUE: sometimes we pass in a dir and want the dir, sometimes we want the CONTENTS of the dir.
			// Need to call this consistently and handle consistently.
			// Maybe if it ends in *, copy contents, otherwise copy the dir itself.
			// This should be more elegant, but I'm checking it in as is b/c people are blocked.

			// If it's a file, be sure the parent directory exists.
			if( new File( from ).isFile() ){
				curDir = to.substring( 0, to.lastIndexOf( "/" ) );
				String[] cmdMkdir = { "ssh", "-p", "2222", "root@localhost", "mkdir", "-p", curDir };
				p = Runtime.getRuntime().exec( cmdMkdir );
				p.waitFor();
			}

			//System.out.println("copying to iOS: " + from);
			String[] cmdCopy = { "scp", "-P", "2222", "-r", from, "root@localhost:" + to };
			p = Runtime.getRuntime().exec( cmdCopy );
			p.waitFor();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	/**
	 * Copies a file or directory from the device. Returns true if to is present afterward.
	 * Note that true will be returned if the copy failed and the file existed already.
	 * It's up to the caller to delete to first if desired.
	 **/
	public static boolean copyFromIOS( String from, String to ){
		Process p = null;
		boolean ret = false;

		try{
			if( findIOSFile( from ) == null ){
				System.out.println("MobileUtil.copyFromIOS: Source file " + from + " not found.");
				return ret;
			}

			if( to.trim().compareTo("") == 0 ){
				System.out.println("MobileUtil.copyFromIOS: Dest " + to + " is not valid.");
				return ret;
			}

			//System.out.println("Copying from " + from + " to " + to);
			String[] cmdCopy = { "scp", "-P", "2222", "-r", "root@localhost:" + from, to };
			p = Runtime.getRuntime().exec( cmdCopy );
			p.waitFor();

			if( new File( to ).exists() ){
				ret = true;
			}

		}catch(Exception e){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * Launches the given app.  If wait is true, waits for it to start and returns the process ID.
	 *
	 **/
	public static int launchIOSApp( String appName, boolean wait, long launchTimeout ){
		Process p = null;
		int ret = -1;

		try{
			String[] cmdOpenUrl = { "ssh", "-p", "2222", "root@localhost", "openURL", appName + ".app:/" };
			p = Runtime.getRuntime().exec( cmdOpenUrl );
			p.waitFor();

			if( wait ){
				ret = MobileUtil.getIOSProcessId( appName, true, launchTimeout );
			}
		}catch(Exception e){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * Kills a process which contains the given string in its name.
	 **/
	public static void killIOSApp( String appString ){
		Process p = null;
		int processId = -1;

		try{
			processId = MobileUtil.getIOSProcessId( appString, false );
			killIOSApp( new Integer( processId ).intValue() );
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	/**
	 * Kills a proces with a given process ID number.
	 **/
	public static void killIOSApp( int processId ){
		Process p = null;

		try{
			String[] cmdStop = { "ssh", "-p", "2222", "root@localhost", "kill", Integer.toString( processId ) };
			p = Runtime.getRuntime().exec( cmdStop );
			p.waitFor();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	/**
	 * Removes an app.
	 **/
	public static void removeIOSApp( String appName ){
		Process p = null;

		try{
			//System.out.println("Removing /User/Applications/" + appName + " if present");
			String[] cmdRemoveApp = { "ssh", "-p", "2222", "root@localhost", "rm", "-r", "/User/Applications/" + appName };
			p = Runtime.getRuntime().exec( cmdRemoveApp );
			p.waitFor();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	/**
	 * Removes all apps in /var/mobile/Applications.
	 **/
	public static void removeAllIOSApps(){
		Process p = null;

		try{
			String[] cmdRemoveApps = { "ssh", "-p", "2222", "root@localhost", "rm", "-r", "/User/Applications/*" };
			p = Runtime.getRuntime().exec( cmdRemoveApps );
			p.waitFor();
		}catch(Exception e){
			e.printStackTrace();
		}
	}

	/**
	 * Get the process id of the app on the device.
	 * If wait = true, it will check every 500 ms until the process appears.  Be aware.
	 * If wait = false, it will just check once.
	 **/
	public static int getIOSProcessId( String appName, boolean wait ){
		return MobileUtil.getIOSProcessId( appName, wait, -1 );
	}

	public static int getIOSProcessId( String appName, boolean wait, long timeout ){
		Process p = null;
		boolean launchProcess = true;
		boolean foundIt = false;
		int ret = -1;
		String line = "";
		int i = 0;
		long startTime = Calendar.getInstance().getTimeInMillis();
		long curTime = 0;

		try{

			while( launchProcess ){
				curTime = Calendar.getInstance().getTimeInMillis();

				String[] cmdPS = { "ssh", "-p", "2222", "root@localhost", "ps", "-A" };
				p = Runtime.getRuntime().exec( cmdPS );
				line = MobileUtil.monitorProcessOutput( p, appName );
				foundIt = (line != null);

				if( !wait || foundIt ){
					launchProcess = false;
				}else if ( wait && (timeout > -1) && (curTime - startTime >= timeout) ){
					launchProcess = false;
				}else{
					Thread.sleep(500);
				}

				// If we got a line, it will look like "   448 ??         0:33.90 /var/mobile/Applications/iconButtonTester/iconButtonTester.app/iconButtonTester"
				// The first token which is a number is the process ID.
				if( foundIt ){
					if( line.trim().compareTo( "" ) != 0 ){
						String[] chunks = line.split( " " );

						for(i = 0; i < chunks.length; ++i){
							try{
								ret = new Integer( chunks[i] ).intValue();
								break;
							}catch(Exception e){
							}
						}
					}
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		return ret;
	}

	/**
	 * Call ls via ssh.
	 * Returns a string with information about the file, or null if not found.
	 **/
	public static String findIOSFile( String filename ){
		Process p = null;
		String ret = null;

		try{
			String[] cmdLS = { "ssh", "-p", "2222", "root@localhost", "ls", "-l", "--time-style=full-iso", filename };
			p = Runtime.getRuntime().exec( cmdLS );
			ret = MobileUtil.monitorProcessOutput( p, filename );
		}catch(Exception e){
			e.printStackTrace();
		}

		return ret;
	}

	/**
	 * Looks for the given string in the given file.
	 * Returns true if found, false if not.
	 **/
	public static boolean searchIOSFile( String findMe, String filename ){
		Process p = null;
		boolean ret = false;

		try{
			String[] cmdCat = { "ssh", "-p", "2222", "root@localhost", "cat", filename };
			p = Runtime.getRuntime().exec( cmdCat );
			ret = ( MobileUtil.monitorProcessOutput( p, findMe ) != null );
		}catch(Exception e){
			e.printStackTrace();
			ret = false;
		}

		return ret;
	}

	/**
	 * Given a process and a string, monitors the output of the
	 * process for the string.  Returns the line in which
	 * the string is found, or null if not found.
	 * It will continue until the process exits.
	 **/
	public static String monitorProcessOutput( Process p, String theString ){
		boolean keepReadingLines = true;
		boolean endOfLine = false;
		boolean foundIt = false;
		boolean appRunning = true;
		String ret = null;
		int readInt = -1;
		InputStream is = null;
		BufferedReader br = null;
		String line = "";

		try{
			//System.out.println("monitorProcessOutput: theString=" + theString);

			is = p.getInputStream();
			br = new BufferedReader( new InputStreamReader( is ) );

			while( keepReadingLines ){
				//System.out.println("monitorProcessOutput: reading lines");

				endOfLine = false;
				line = "";

				while( !endOfLine ){
					//System.out.println("monitorProcessOutput: reading a line");

					if( br.ready() && (is.available() > 0) ){
						readInt = is.read();

						// We get 13 & 10 as end of line.
						if( readInt == 13 || readInt == 10 ){
							endOfLine = true;
						}else{
							line += (char)readInt;
						}
					}else{
						Thread.sleep(100);
						if( !processRunning(p) && (!br.ready()) && (is.available() <= 0) ){
							// There's nothing else to do.  Bail.
							endOfLine = true;
							keepReadingLines = false;
						}else{
							//System.out.println("monitorProcessOutput: not bailing yet");
						}
					}
				}
				//System.out.println("monitorProcessOutput: line=" + line);

				// At this point, we might have a line.
				//System.out.println("\t\t" + line);
				if( line.indexOf( theString ) > -1 ){
					//System.out.println("monitorProcessOutput: found our line");
					ret = line;
					foundIt = true;
					keepReadingLines = false;
				}
			}
			//System.out.println("monitorProcessOutput: done reading lines");
		}catch(Exception e){
			e.printStackTrace();
		}

		//System.out.println("monitorProcessOutput: returning " + ret);
		return ret;
	}

	/**
	 * Returns whether a process is running.
	 * exitValue() throws an exception if the process
	 * is still running.
	 **/
	public static boolean processRunning(Process p){
		try{
			int exitVal = p.exitValue();
			return false;
		}catch(IllegalThreadStateException e){
			return true;
		}
	}

	/**
	 * Removes a file or directory from the device.
	 **/
	public static void removeIOSFile( String target ){
		Process p = null;
		File file = null;

		if( findIOSFile( target ) != null ){
			try{
				System.out.println("Removing " + target);
				String[] cmdRemove = { "ssh", "-p", "2222", "root@localhost", "rm", "-r", target };
				p = Runtime.getRuntime().exec( cmdRemove );
				p.waitFor();

				if( findIOSFile( target ) != null ){
					System.out.println("Removal of " + target + " failed.  Maybe it wasn't present.");
				}
			}catch(Exception e){
				e.printStackTrace();
			}
		}
	}

	/**
	 * getSizeFromLsLine() receives a line like:
	 *		-rw-r--r-- 1 mobile mobile 16326 2011-01-06 14:08:27.000000000 -0800 /User/Applications/iconButtonTester/Documents/MustellaResults.txt
	 * and returns the size.  So far, I don't see how to make the ls command return just the size.
	 * To get seconds, ls is used like this: ls -l --time-style=full-iso
	 **/
	public static long getSizeFromLsLine( String line ){
		String[] tokens = line.split( " " );
		int i = 0;
		long ret = -1L;

		try{
			for( i = 0; i < tokens.length; ++i ){
				if( i == 4 ){
					ret = new Long( tokens[ i ] ).longValue();
				}
			}
		}catch( Exception e ){
			e.printStackTrace();
		}

		return ret;
	}


	/**
	 * getTimeFromLsLine() receives a line like:
	 *		-rw-r--r-- 1 mobile mobile 16326 2011-01-06 14:08:27.000000000 -0800 /User/Applications/iconButtonTester/Documents/MustellaResults.txt
	 * and returns the time (milliseconds).  So far, I don't see how to make the ls command return just the time.
	 * To get seconds, ls is used like this: ls -l --time-style=full-iso
	 **/
	public static long getTimeFromLsLine( String line ){
		long ret = -1L;
		GregorianCalendar cal = null;
		String dateBlock = null;
		String timeBlock = null;
		String[] tokens = line.split( " " );
		int year = -1;
		int month = -1;
		int date = -1;
		int hours = -1;
		int minutes = -1;
		int seconds = -1;
		int i = 0;
		int j = 0;

		for( i = 0; i < tokens.length; ++i ){
			if( tokens[ i ].indexOf( "-" ) > -1 ){

				// It's one of the fields with dashes. See if it looks like a date.
				String[] dateTokens = tokens[ i ].split( "-" );

				if( dateTokens.length == 3 ){

					for( j = 0; j < dateTokens.length; ++j ){
						try{
							if( j == 0 ){
								year = new Integer( dateTokens[ j ] ).intValue();
							}else if( j == 1 ){
								month = new Integer( dateTokens[ j ] ).intValue();
							}else{
								date = new Integer( dateTokens[ j ] ).intValue();
							}
						}catch( Exception e ){
							//System.out.println(dateTokens[j] + " is not a date");
						}
					}
				}
			}

			// It didn't contain dashes, so let's look for a time.
			if( tokens[ i ].indexOf( ":" ) > -1 ){
				String[] timeTokens = tokens[ i ].split( ":" );

				if( timeTokens.length == 3 ){

					for( j = 0; j < timeTokens.length; ++j ){
						try{
							if( j == 0 ){
								hours = new Integer( timeTokens[ j ] ).intValue();
							}else if( j == 1 ){
								minutes = new Integer( timeTokens[ j ] ).intValue();
							}else if( j == 2 ){
								String secondsToken = timeTokens[j].substring( 0, timeTokens[j].indexOf(".") );
								seconds = new Integer( secondsToken ).intValue();
							}
						}catch( Exception e ){
							//System.out.println(timeTokens[j] + " is not a time");
						}
					}
				}
			}
		}

		if( year > -1 && month > -1 && date > -1 && hours > -1 && minutes > -1 && seconds > -1 ){
			//System.out.println("getTimeFromLsLine(): We think we have a date and time for the log. year=" + year + ", month=" + month + ", date=" + date + ", hours=" + hours + ", minutes=" + minutes + ", seconds=" + seconds);

			cal = new GregorianCalendar( year, month, date, hours, minutes, seconds );
			ret = cal.getTimeInMillis();

			//System.out.println("getTimeFromLsLine(): getTimeInMillis() returned " + ret);
		}

		return ret;
	}

	/**
	 * Remove temporary packaging files from the dir given (at the swfs level).
	 * e.g.:
	 *	- AOTBuildOutput1086061381018907696.tmp (dir)
	 *	- MobileButtonMain2_ipa (dir)
	 *	- air48611378876425949.tmp (file)
	 *	- non-aot496151823287214585.tmp (file)
	 *	- apk647202451803245042.tmp (file)
	 *	- All .ipa files
	 *	- All .apk files
	 * Don't call this until all packaging is done, since many threads can package at once.
	 **/
	public static void removeTempPackagingFiles( String cleanDir ){
		File subFile = null;
		File dir = new File( cleanDir );

		try{
			if( dir.exists() && dir.isDirectory() ){
				File[] arrFiles = dir.listFiles();

				for(int i = 0; i < arrFiles.length; ++i){
					subFile = arrFiles[i];

					if( subFile.isDirectory() ){
						if  ( subFile.getName().indexOf( "AOTBuildOutput" ) == 0 ||
							( subFile.getName().endsWith( "_ipa" ) ) ){
								System.out.println("Deleting packaging temp file directory " + subFile.getCanonicalPath());
								FileUtils.recursivelyDelete( subFile.getCanonicalPath() );
						}
					}else{
						// airXXXXXXX.tmp
						if( (subFile.getName().indexOf( "air" ) == 0) &&
							(subFile.getName().endsWith( ".tmp" ) ) ){
								System.out.println("Deleting packaging temp file " + subFile.getCanonicalPath());
								subFile.delete();
						}

						// non-aotXXXXX.tmp
						if( (subFile.getName().indexOf( "non-aot" ) == 0) &&
						    (subFile.getName().endsWith( ".tmp" ) ) ){
							System.out.println("Deleting packaging temp file " + subFile.getCanonicalPath());
							subFile.delete();
						}

						// apkXXXXX.tmp
						if( (subFile.getName().indexOf( "apk" ) == 0) &&
						    (subFile.getName().endsWith( ".tmp" ) ) ){
							System.out.println("Deleting packaging temp file " + subFile.getCanonicalPath());
							subFile.delete();
						}

						// all .ipa, .apk, .bar
						if( ( subFile.getName().endsWith( ".ipa" ) ) ||
							( subFile.getName().endsWith( ".bar" ) ) ||
 						    ( subFile.getName().endsWith( ".apk" ) ) ){
								System.out.println("Deleting packaging temp file " + subFile.getCanonicalPath());
								subFile.delete();
						}

						// BARXXXXXXXX.tmp
						if ( ( subFile.getName().indexOf( "BAR" ) == 0 ) &&
							 ( subFile.getName().endsWith( "tmp" ) ) ) {
							System.out.println("Deleting packaging temp file " + subFile.getCanonicalPath());
							subFile.delete();
						}
					}
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}


} // End class

