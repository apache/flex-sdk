/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf;

import flash.swf.debug.DebugModule;
import flash.swf.debug.LineRecord;
import flash.swf.debug.RegisterRecord;
import flash.swf.types.FlashUUID;
import flash.util.FileUtils;
import flash.util.IntMap;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.File;
import java.util.ArrayList;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * The swd file format is as follows
 *
 * swd(header) (tag)*
 *
 * @author Edwin Smith
 */
public class DebugDecoder
{
	public static final int
		kDebugScript=0,
		kDebugOffset=1,
		kDebugBreakpoint=2,
		kDebugID=3,
		kDebugRegisters=5
	;

    /**
     * table of line numbers, indexed by offset in the SWF file
     */
    private SwfDecoder in;
    private IntMap modules = new IntMap();

    public DebugDecoder(byte[] b)
    {
        this(new ByteArrayInputStream(b));
    }

    public DebugDecoder(InputStream in)
    {
        this.in = new SwfDecoder(in, 0);
    }

    public void readSwd(DebugHandler h) throws IOException
    {
        readHeader(h);
        readTags(h);
    }

    void readHeader(DebugHandler handler) throws IOException
    {
        byte[] sig = new byte[4];

        in.readFully(sig);

        if (sig[0] != 'F' || sig[1] != 'W' || sig[2] != 'D' || sig[3] < 6)
        {
            throw new SwfFormatException("not a Flash 6 or later SWD file");
        }

		in.swfVersion = sig[3];

        handler.header(in.swfVersion);
    }

	public void setTagData(byte[] b) throws IOException
	{
		in = new SwfDecoder(b, 0);
	}

    public void readTags(DebugHandler handler) throws IOException
    {
    	// <Object> because it holds groups of {Integer, LineRecord, Integer}
		ArrayList<Object> lineRecords = new ArrayList<Object>();

		do
		{
			int tag = (int) in.readUI32();
			switch (tag)
			{
			case kDebugScript:
				DebugModule m = new DebugModule();
				int id = (int) in.readUI32();
				m.id = id;
				m.bitmap = (int) in.readUI32();
				m.name = in.readString();
				m.setText(in.readString());

				adjustModuleName(m);

				if (modules.contains(id))
				{
					DebugModule m2 = (DebugModule) modules.get(id);
					if (!m.equals(m2))
					{
						handler.error("Module '" + m2.name + "' has the same ID as Module '" + m.name + "'");
						handler.error("Let's check for kDebugOffset that came before Module '" + m2.name + "'");
						handler.error("Before: Number of accumulated line records: " + lineRecords.size());
						lineRecords = purgeLineRecords(lineRecords, id, handler);
						handler.error("After: Number of accumulated line records: " + lineRecords.size());
					}
				}
				modules.put(id, m);
				handler.module(m);
				break;
			case kDebugOffset:
				id = (int) in.readUI32();
				int lineno = (int) in.readUI32();
				DebugModule module = (DebugModule) modules.get(id);
				LineRecord lr = new LineRecord(lineno, module);
				int offset = (int) in.readUI32();

				if (module != null)
				{
					// not corrupted before we add the offset and offset add fails
					boolean wasCorrupt = module.corrupt;
					if (!module.addOffset(lr, offset) && !wasCorrupt)
						handler.error(module.name+":"+lineno+" does not exist for offset "+offset+", module marked for exclusion from debugging");
					handler.offset(offset, lr);
				}
				else
				{
					lineRecords.add(new Integer(id));
					lineRecords.add(lr);
					lineRecords.add(new Integer(offset));
				}
				break;
			case kDebugBreakpoint:
				handler.breakpoint((int) in.readUI32());
				break;
			case kDebugRegisters:
			{
				offset = (int)in.readUI32();
				int size = in.readUI8();
				RegisterRecord r = new RegisterRecord(offset, size);
				for(int i=0; i<size; i++)
				{
					int nbr = in.readUI8();
					String name = in.readString();
					r.addRegister(nbr, name);
				}
				handler.registers(offset, r);
				break;
			}

			case kDebugID:
                FlashUUID uuid = new FlashUUID();
                in.readFully(uuid.bytes);
                handler.uuid(uuid);
				break;
			case -1:
				break;
			default:
				throw new SwfFormatException("Unexpected tag id " + tag);
			}

			if (tag == -1)
			{
				break;
			}
		}
		while (true);

		int i = 0, size = lineRecords.size();
		while (i < size)
		{
			int id = ((Integer) lineRecords.get(i)).intValue();
			LineRecord lr = (LineRecord) lineRecords.get(i + 1);
			int offset = ((Integer) lineRecords.get(i + 2)).intValue();
			lr.module = (DebugModule) modules.get(id);

			if (lr.module != null)
			{
                //System.out.println("updated module "+id+" out of order");
				// not corrupted before we add the offset and offset add fails
				boolean wasCorrupt = lr.module.corrupt;
				if (!lr.module.addOffset(lr, offset) && !wasCorrupt)
					handler.error(lr.module.name+":"+lr.lineno+" does not exist for offset "+offset+", module marked for exclusion from debugging");

				handler.offset(offset, lr);
			}
			else
			{
				handler.error("Could not find debug module (id = " + id + ") for offset = " + offset);
			}

			i += 3;
		}
    }

    /**
     * process any dangling line records that belong to the given module
     * @param lineRecords
     * @param moduleId
     * @param handler
     * @return
     */
	private ArrayList<Object> purgeLineRecords(ArrayList<Object> lineRecords, final int moduleId, DebugHandler handler)
	{
		ArrayList<Object> newLineRecords = new ArrayList<Object>();
        DebugModule module = (DebugModule) modules.get(moduleId);
		int i = 0, size = lineRecords.size();
		while (i < size)
		{
			Integer id = (Integer) lineRecords.get(i);
			LineRecord lr = (LineRecord) lineRecords.get(i + 1);
			Integer offset = (Integer) lineRecords.get(i + 2);

			if (id.intValue() == moduleId)
			{
                lr.module = module;

				if (lr.module != null)
				{
					lr.module.addOffset(lr, offset.intValue());
					handler.offset(offset.intValue(), lr);
				}
				else
				{
					handler.error("Could not find kDebugScript with module ID = " + id);
				}
			}
			else
			{
				newLineRecords.add(id);
				newLineRecords.add(lr);
				newLineRecords.add(offset);
			}

			i += 3;
		}

		return newLineRecords;
	}

    public static void main(String[] args) throws IOException
    {
        for (int i=0; i<args.length; i++)
        {
            // does not need to be buffered because DebugDecoder turns it into a SwfDecoder, which is buffered
            InputStream in = new FileInputStream(args[i]);
            try
            {
                new DebugDecoder(in).readSwd(new DebugHandler()
                {
                    public void header(int version)
                    {
                        System.out.println("FWD"+version);
                    }

                    public void uuid(FlashUUID id)
                    {
                        System.out.println("DebugID "+id);
                    }

                    public void module(DebugModule dm)
                    {
                        System.out.println("DebugScript #" + dm.id + " " + dm.bitmap + " " + dm.name + " (nlines = " +(dm.offsets.length - 1) + ")");
                    }

                    public void offset(int offset, LineRecord lr)
                    {
                        System.out.println("DebugOffset #" + lr.module.id + ":" + lr.lineno + " " + offset);
                    }

                    public void breakpoint(int offset)
                    {
                        System.out.println("DebugBreakpoint " + offset);
                    }

                    public void registers(int offset, RegisterRecord r)
                    {
                        System.out.println("DebugRegisters " + r.toString());
                    }

					public void error(String msg)
					{
						System.err.println("***ERROR: "+msg);
					}
                });
                System.out.println();
            }
            finally
            {
                in.close();
            }
        }
    }

	/**
	 * Royale Enhancement Request: 53160...
	 *
	 * If a debug module represents an AS2 class, the module name should be in the form of classname: fileURL
	 * Matador uses classname: absolutePath (note: absolute, not cannonical)
	 *
	 * @param d
	 */
	protected static final void adjustModuleName(DebugModule d)
	{
		d.name = adjustModuleName(d.name);
	}

	public static final String adjustModuleName(String name)
	{
		if (name.startsWith("<") && name.endsWith(">"))
		{
			return name;
		}

		String token1, token2;

		// if the url is not malformed, return it
		try
		{
			@SuppressWarnings("unused")
			URL u = new URL(name);
			// good URL, return...
			return name;
		}
		catch (MalformedURLException ex)
		{
			// not an URL, continue...
		}

		File f;

		try
		{
			f = new File(name);
		}
		catch (java.lang.Error nf)
		{
			// the CLR will throw this when a java.io.File object is init'd in a location
			// that causes a .NET System.SecurityException - can't create File objects on
			// .NET as a way of testing whether they are valid files without catching the error
			f = null;
		}

		if (f == null || !f.isFile())
		{
			int colon = name.indexOf(':');
			if (colon != -1)
			{
				token1 = name.substring(0, colon).trim();
				token2 = name.substring(colon + 1).trim();
			}
			else
			{
				token1 = "";
				token2 = name;
			}
		}
		else
		{
			token1 = "";
			token2 = name;
		}

		try
		{
			f = new File(token2);
		}
		catch (java.lang.Error nf)
		{
			// the CLR will throw this when a java.io.File object is init'd in a location
			// that causes a .NET System.SecurityException - can't create File objects on
			// .NET as a way of testing whether they are valid files without catching the error
			f = null;
		}

		if (f != null && f.isFile())
		{
			try
			{
				if (token2.indexOf("..") != -1 || token2.indexOf(".") != -1)
				{
					f = FileUtils.getCanonicalFile(f);
				}
				token2 = FileUtils.toURL(f).toString();
			}
			catch (IOException ex)
			{
			}
		}

		if (token1.length() == 0)
		{
			name = token2;
		}
		else
		{
			name = token1.trim() + ": " + token2.trim();
		}

		return name;
	}
}



