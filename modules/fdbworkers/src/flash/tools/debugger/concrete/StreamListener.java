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

package flash.tools.debugger.concrete;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;

/**
 * Reads a stream, and sends the contents somewhere.
 * @author mmoreart
 */
public class StreamListener extends Thread {
	Reader fIn;
	Writer fOut;

	/**
	 * Creates a StreamListener which will copy everything from
	 * 'in' to 'out'.
	 * @param in the stream to read
	 * @param out the stream to write to, or 'null' to discard input
	 */
	public StreamListener(Reader in, Writer out)
	{
		super("DJAPI StreamListener"); //$NON-NLS-1$
		setDaemon(true);
		fIn = in;
		fOut = out;
	}

	@Override
	public void run()
	{
		char[] buf = new char[4096];
		int count;

		try {
			for (;;) {
				count = fIn.read(buf);
				if (count == -1)
					return; // thread is done
				if (fOut != null)
				{
					try {
						fOut.write(buf, 0, count);
					} catch (IOException e) {
						// the write failed (unlikely), but we still
						// want to keep reading
					}
				}
			}
		} catch (IOException e) {
			// do nothing -- we're done
		}
	}
}
