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

package flash.tools.debugger.threadsafe;

import java.io.File;

import flash.tools.debugger.Browser;
import flash.tools.debugger.Player;

/**
 * Thread-safe wrapper for flash.tools.debugger.Player
 * @author Mike Morearty
 */
public class ThreadSafePlayer extends ThreadSafeDebuggerObject implements Player {

	private Player fPlayer;
	
	private ThreadSafePlayer(Object syncObj, Player player) {
		super(syncObj);
		fPlayer = player;
	}

	/**
	 * Wraps a Player inside a ThreadSafePlayer.  If the passed-in Player
	 * is null, then this function returns null.
	 */
	public static Player wrap(Object syncObj, Player player) {
		if (player != null)
			return new ThreadSafePlayer(syncObj, player);
		else
			return null;
	}

	/*
	 * @see flash.tools.debugger.Player#getType()
	 */
	public int getType() {
		synchronized (getSyncObject()) {
			return fPlayer.getType();
		}
	}

	/*
	 * @see flash.tools.debugger.Player#getPath()
	 */
	public File getPath() {
		synchronized (getSyncObject()) {
			return fPlayer.getPath();
		}
	}

	public Browser getBrowser() {
		synchronized (getSyncObject()) {
			return fPlayer.getBrowser();
		}
	}

}
