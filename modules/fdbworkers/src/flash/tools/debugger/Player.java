/*
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
 */

package flash.tools.debugger;

import java.io.File;

/**
 * Describes a Flash player.
 * 
 * @author mmorearty
 */
public interface Player
{
	/**
	 * Indicates a standalone Flash player, e.g. FlashPlayer.exe.
	 * 
	 * @see #getType()
	 */
	public static final int STANDALONE = 1;

	/**
	 * Indicates a Netscape-plugin Flash player, e.g. NPSWF32.dll. Used on
	 * Windows by all Netscape-based browsers (e.g. Firefox etc.), and on Mac
	 * and Linux by all browsers.
	 * 
	 * @see #getType()
	 */
	public static final int NETSCAPE_PLUGIN = 2;

	/**
	 * Indicates an ActiveX-control Flash player, e.g. Flash.ocx.  Used on Windows
	 * by Internet Explorer.
	 * 
	 * @see #getType()
	 */
	public static final int ACTIVEX = 3;

	/**
	 * Indicates the Flash player inside AIR.
	 */
	public static final int AIR = 4;

	/**
	 * Returns what type of Player this is: <code>STANDALONE</code>, <code>NETSCAPE_PLUGIN</code>,
	 * <code>ACTIVEX</code>, or <code>AIR</code>.
	 */
	public int getType();

	/**
	 * Returns the path to the Flash player file -- e.g. the path to
	 * FlashPlayer.exe, NPSWF32.dll, Flash.ocx, or adl.exe -- or
	 * <code>null</code> if not known. (Filenames are obviously
	 * platform-specific.)
	 * 
	 * <p>
	 * Note that the file is not guaranteed to exist. You can use File.exists()
	 * to test that.
	 */
	public File getPath();

	/**
	 * Returns the web browser with which this player is associated,
	 * or <code>null</code> if this is the standalone player or AIR,
	 * or if we're not sure which browser will be run.
	 */
	public Browser getBrowser();
}
