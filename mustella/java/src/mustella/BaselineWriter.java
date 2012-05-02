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
import java.net.*;

/**
 *
 * BaselineWriter - Reads a POST from a given Socket instance, writes the filename 
 *                  designated in the post arguments. 
 *
 */

public class BaselineWriter extends Thread { 


	private String filename = null;
	private String filename_tmp = null;


	Socket sock = null;

	String dir = null;


	public boolean clobbered = false;
	

	private int length = -1;
	private int total = 0;

	public BaselineWriter (Socket sock) { 
		this.sock = sock;
	}

	public BaselineWriter (Socket sock, String dir) { 
		this.sock = sock;
		this.dir = dir;
	}


	int headerLength = 0;

	// The input stream we'll open on the socket.
	InputStream stuff = null;

	// stock reply
	static final String reply = "HTTP/1.1 200 OK\r\n\r\n";	


	public void run () { 

		parseHeaders ();

		if (scuttle)
			return;

		this.filename_tmp = filename + ".tmp";

		if (dir != null) {
			// this.filename_tmp = dir+ File.separator + this.filename_tmp;
			this.filename_tmp = dir+ "/" + this.filename_tmp;
			this.filename = dir+ "/" + this.filename;
		}

		// System.out.println ("BW result: " + this.filename_tmp);


		BufferedOutputStream fos = null;

		try { 


			/// delete the existing file(s)
			new File (filename_tmp).delete();
			new File (filename).delete();



			fos = new BufferedOutputStream(new FileOutputStream (filename_tmp));

		
			int avail = 0;	

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			// System.out.println ("Doing the write");

			int b;
			byte [] ba =null;

			// The content length we're getting from the client is 
			// the length of the PNG only.
			// We need to add the headers (and substract the header/content \r\n)
			// in theory, the -1 would tell us we were at the end of the stream.
			// never ever saw a -1, so I guess it don't.
			while (!clobbered && total < (length+(headerLength-2))) { 
				b = stuff.read();
				if (b == -1) { 
					System.out.println ("QUIT saw the end of the stream");
					break; 
				}
				
				fos.write(b); // stuff.read());
				total++;

			}



			fos.flush();
			fos.close();
			System.out.println ("Wrote file: " + filename + " length: "+  length);
			// System.out.println ("The content length was: " + length);
			// System.out.println ("header length was: " + headerLength);
			// System.out.println ("Wrote this: " + new String(baos.toByteArray()));

			new File(filename_tmp).renameTo (new File(filename));


			/// write back happiness.
			

			BufferedOutputStream bus = new BufferedOutputStream (sock.getOutputStream());

			bus.write (reply.getBytes(), 0, reply.length());
	
			bus.flush();

			bus.close();

			stuff.close();	


		} catch (Exception e) { 
			System.out.println ("Hosed on the image write");

			e.printStackTrace();

		}

		BaselineServer.threads.remove (this);

	}


	private boolean scuttle = false;


	public synchronized void parseHeaders() { 


		String line = null;	


		try {

			stuff = sock.getInputStream();
			

			while (true) { 
				line = readLine();

				headerLength+=line.length();

				// System.out.println ("HEADER: " + line);
			
				/**	
				 * GET: this would be something we don't handle:
				 */	
				if (line.indexOf ("GET ") != -1) {
					scuttle = true;
					System.out.println ("Scuttle, this was a GET");
					return;
				}

				// End of the header marker:
				if (line.length() == 2 || line.equals ("\r\n")) { 
					// System.out.println ("Would bust out here");
					break;
				}
				
				total += line.length();

				if (line.indexOf ("POST ") != -1) {
					// System.out.println ("SAW THE POST");

					line = line.substring (line.indexOf("filename=")+9, line.indexOf (" ",10));
					line = line.trim();
					this.filename =  URLDecoder.decode(line);

				}
				if (line.indexOf ("Content-Length") != -1 || line.indexOf ("Content-length") != -1) {

					// System.out.println ("SAW LENGTH");
					line = line.substring (line.indexOf (":")+1);		
					this.length = Integer.parseInt (line.trim());

				}


			}
				


		} catch (Exception e) { 

			e.printStackTrace();


		}


	}


	public String readLine() throws Exception {


		String line = null;


		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		int b;

		while (true) { 

			b = stuff.read();

			baos.write (b);

			if (b == '\n')
				break;
			
		}




		return  new String (baos.toByteArray());

			

	}

	


	/* 
	public BaselineWriter (String filename, int length) { 
		this.length = length;
		this.filename = filename;
		this.filename_tmp = filename + ".tmp";
	}
	*/


	/* 
	public synchronized void write (InputStream stuff) { 




	}
	*/




}
