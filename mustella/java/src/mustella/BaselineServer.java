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

import java.net.*;
import java.util.Date;
import java.util.ArrayList;

/** 
 * BaselineServer
 *
 * Serve a given port, spawn BaselineWriters on whoever writes to it
 */
public class BaselineServer extends Thread { 


	int port = 9998;


	public BaselineServer (int port) { 
		this.port = port;
	}


	public String dir = null;


	/// this should be 1 above the swf
	public void setDir (String dir) {
		this.dir = dir.replaceAll("\\\\", "/");
	}


	public static ArrayList threads = new ArrayList();


	ServerSocket ss = null; 

	public void run () {

		System.out.println ("starting the baseline server: " + new Date());

		/// launch server, dispatch sockets on new inlines

		try  { 
	
			ss = new ServerSocket (port);

			while (running) { 

				try { 

				Socket s = ss.accept ();
				BaselineWriter bw = null;
				if (dir != null)
					bw = new BaselineWriter (s, dir);
				else
					bw = new BaselineWriter (s);
				threads.add (bw);
				bw.start();

				} catch (Exception e) { 
					// System.out.println ("broke out of the socket loop");
					return;
				}

			}

		} catch (Exception e) {

			e.printStackTrace ();

		}
	
	}


	boolean running = true;

	public void end() { 
		running = false;
		BaselineWriter bw = null;
		for (int i=0;i<threads.size();i++) { 
			bw = (BaselineWriter)threads.get(i);
			if (bw.isAlive())
				bw.clobbered = true;
			threads.remove (i);
		}

	} 

	public void destroy() { 
		try { 
			ss.close();
		} catch (Exception e) { 
	
		}

	}


	public static void main (String [] args) { 

		


	}

}
