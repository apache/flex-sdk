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

package macromedia.asc.embedding;

import macromedia.asc.util.ObjectList;

import java.io.*;
import java.util.*;
import java.lang.reflect.Method;
import java.lang.reflect.Field;

/**
 * @author Clement Wong
 */
public class Shell
{
	public static void main(String[] args) throws IOException
	{
		exit = false;
		counter = 1;
		targets = new HashMap();
		processes = new HashMap();

		String s;
		BufferedReader r = new BufferedReader(new InputStreamReader(System.in));

		intro();
		prompt();
		while ((s = r.readLine()) != null)
		{
			try
			{
				process(s);
			}
			catch (Throwable t)
			{
				t.printStackTrace();
			}

			if (exit)
			{
				break;
			}
			else
			{
				prompt();
			}
		}
	}

	private static int counter;
	private static boolean exit;
	private static Map targets;
	private static Map processes;

	private static void process(String s)
	{
		if (s.startsWith("asc"))
		{
			StringTokenizer t = new StringTokenizer(s.substring("asc".length()).trim(), " ");
			String[] args = new String[t.countTokens()];
			for (int i = 0; t.hasMoreTokens(); i++)
			{
				args[i] = t.nextToken();
			}

			if (args.length == 1)
			{
				try
				{
					int id = Integer.parseInt(args[0]);
					Target target = (Target) targets.get("" + id);
					if (target == null)
					{
						System.out.println("ash: Target " + id + " not found");
					}
					else
					{
						asc(target.args, id);
					}
				}
				catch (NumberFormatException ex)
				{
					System.out.println("ash: Assigned " + counter + " as the compile target id");
					asc(args, counter++);
				}
			}
			else
			{
				System.out.println("ash: Assigned " + counter + " as the compile target id");
				asc(args, counter++);
			}
		}
		else if (s.startsWith("run"))
		{
			String id = s.substring("run".length()).trim();
			if (targets.containsKey(id))
			{
				run(id);
			}
			else
			{
				System.out.println("ash: Target " + id + " not found");
			}
		}
		else if (s.startsWith("trace"))
		{
			String mode = s.substring("trace".length()).trim();
			if ("on".equalsIgnoreCase(mode))
			{
				trace(true);
			}
			else if ("off".equalsIgnoreCase(mode))
			{
				trace(false);
			}
		}
		else if (s.equals("mm.cfg"))
		{
			mmcfg();
		}
		else if (s.startsWith("clear"))
		{
			String id = s.substring("clear".length()).trim();
			if (id.length() == 0)
			{
				HashSet<String> keys = new HashSet<String>(targets.keySet());
				for (Iterator i = keys.iterator(); i.hasNext();)
				{
					clear((String) i.next());
				}
			}
			else if (targets.containsKey(id))
			{
				clear(id);
			}
			else
			{
				System.out.println("ash: Target " + id + " not found");
			}
		}
		else if (s.startsWith("info"))
		{
			String id = s.substring("info".length()).trim();
			if (id.length() == 0)
			{
				HashSet<String> keys = new HashSet<String>(targets.keySet());
				for (Iterator i = keys.iterator(); i.hasNext();)
				{
					info((String) i.next());
				}
			}
			else if (targets.containsKey(id))
			{
				info(id);
			}
			else
			{
				System.out.println("ash: Target " + id + " not found");
			}
		}
		else if (s.startsWith("touch"))
		{
			String args = s.substring("touch".length()).trim();

			StringTokenizer stok = new StringTokenizer(args);
			while (stok.hasMoreTokens())
			{
				String f = stok.nextToken();

				if (!new File(f).canWrite())
				{
					System.out.println("touch: cannot write " + f);
				}
				else
				{
					System.out.println("touched file: " + f);
					new File(f).setLastModified(System.currentTimeMillis());
				}
			}
		}
		else if (s.equals("quit"))
		{
			Set<String> names = new HashSet<String>(targets.keySet());
			for (Iterator i = names.iterator(); i.hasNext();)
			{
				process("clear " + (String) i.next());
			}

			exit = true;
		}
		else if (s.equals("memory"))
		{
			peakMemoryUsage();
		}
		else if (s.equals("gc"))
		{
			System.gc();
		}
		else
		{
			cmdList();
		}
	}

	private static MemoryUsage getMemoryUsageInBytes()
	{
		long heapUsed = 0, nonHeapUsed = 0;

	    try
	    {
	        Class mfCls = Class.forName("java.lang.management.ManagementFactory");
	        Class mpCls = Class.forName("java.lang.management.MemoryPoolMXBean");
	        Class memCls = Class.forName("java.lang.management.MemoryUsage");
		    Class typeCls = Class.forName("java.lang.management.MemoryType");

	        Class[] emptyCls = new Class[] {};
	        Object[] emptyObj = new Object[] {};
	        Method getMemPoolMeth = mfCls.getMethod("getMemoryPoolMXBeans", emptyCls);
	        Method getPeakUsageMeth = mpCls.getMethod("getPeakUsage", emptyCls);
		    Method getTypeMeth = mpCls.getMethod("getType", emptyCls);
		    Field heapField = typeCls.getField("HEAP");
		    Method resetPeakUsageMeth = mpCls.getMethod("resetPeakUsage", emptyCls);
	        Method getUsedMeth = memCls.getMethod("getUsed", emptyCls);

	        List list = (List)getMemPoolMeth.invoke(null, emptyObj);
	        for (Iterator iterator = list.iterator(); iterator.hasNext();)
	        {
	            Object memPoolObj = iterator.next();
	            Object memUsageObj = getPeakUsageMeth.invoke(memPoolObj, emptyObj);
		        Object memTypeObj = getTypeMeth.invoke(memPoolObj, emptyObj);
		        Long used = (Long)getUsedMeth.invoke(memUsageObj, emptyObj);
		        if (heapField.get(typeCls) == memTypeObj)
		        {
		            heapUsed += used.longValue();
		        }
		        else
		        {
			        nonHeapUsed += used.longValue();
		        }
		        resetPeakUsageMeth.invoke(memPoolObj, emptyObj);
	        }

		    return new MemoryUsage(heapUsed, nonHeapUsed);
	    }
	    catch(Exception e)
	    {
	        // ignore, assume not using jdk 1.5
	    }

		return new MemoryUsage(heapUsed, nonHeapUsed);
	}

	public static class MemoryUsage
	{
		public MemoryUsage(long heap, long nonHeap)
		{
			super();
			this.heap = heap;
			this.nonHeap = nonHeap;
			this.total = heap + nonHeap;
		}

		public long heap, nonHeap, total;

		public void add(MemoryUsage mem)
		{
			this.heap += mem.heap;
			this.nonHeap += mem.nonHeap;
			this.total += mem.total;
		}

		public void subtract(MemoryUsage mem)
		{
			this.heap -= mem.heap;
			this.nonHeap -= mem.nonHeap;
			this.total -= mem.total;
		}

		public String toString()
		{
			return "Peak Memory Usage: " + total + " Mb (Heap: " + heap + " Mb, Non-Heap: " + nonHeap + " Mb)";
		}
	}

	public static long peakMemoryUsage()
	{
	    return peakMemoryUsage(true);
	}

	public static long peakMemoryUsage(boolean display)
	{
		MemoryUsage mem = getMemoryUsageInBytes();
		long mbHeapUsed = (mem.heap / 1048576);
		long mbNonHeapUsed = (mem.nonHeap / 1048576);

		if (display && mem.heap != 0 && mem.nonHeap != 0)
		{
			System.out.println(new MemoryUsage(mbHeapUsed, mbNonHeapUsed));
		}

		return mbHeapUsed + mbNonHeapUsed;
	}

	private static void clear(String target)
	{
		Process p = (Process) processes.remove(target);

		if (p != null)
		{
			p.destroy();
		}

		Target s = (Target) targets.remove(target);
	}

	private static void info(String target)
	{
		Target s = (Target) targets.get(target);
		System.out.println("id: " + s.id);
		StringBuilder b = new StringBuilder();
		for (int i = 0, size = s.args.length; i < size; i++)
		{
			b.append(s.args[i]);
			b.append(' ');
		}
		System.out.println("asc: " + b);
	}

	private static void run(String target)
	{
		Process p = (Process) processes.get(target);
		Target t = (Target) targets.get(target);

		List l = new ArrayList();
		for (int i = 0; i < t.args.length; i++)
		{
			String arg = t.args[i];
			if (!arg.startsWith("-") && !arg.equalsIgnoreCase("global.abc") &&
				(arg.endsWith(".as") || arg.endsWith(".abc")))
			{
				if (arg.endsWith(".as"))
				{
					arg = arg.substring(0, arg.length() - 3) + ".abc";
				}

				l.add(arg);
			}
		}

		String[] cmdArray = new String[l.size() + 1];

		BufferedInputStream stdout = null;
		BufferedInputStream stderr = null;

		try
		{
			File player = new File(new File(System.getProperty("application.home"), "bin"), "avmplus.exe");
			if (p != null)
			{
				p.destroy();
			}
			cmdArray[0] = player.getAbsolutePath();
			for (int j = 0; j < l.size(); j++)
			{
				cmdArray[j + 1] = (String) l.get(j);
			}

			System.out.print("Using ");
			for (int j = 0; j < cmdArray.length; j++)
			{
				System.out.print(cmdArray[j] + " ");
			}
			System.out.println();

			p = Runtime.getRuntime().exec(cmdArray);
			processes.put(target, p);

			stdout = new BufferedInputStream(p.getInputStream());
			stderr = new BufferedInputStream(p.getErrorStream());

			streamOutput(stdout, System.out);
			streamOutput(stdout, System.err);

			p.waitFor();
		}
		catch (Throwable ex)
		{
			if (p != null)
			{
				p.destroy();
			}
			if (stdout != null)
			{
				try { stdout.close(); } catch (Exception e1) {}
			}
			if (stderr != null)
			{
				try { stderr.close(); } catch (Exception e2) {}
			}
			System.err.println(ex.getMessage());
			ex.printStackTrace();
		}
	}

	public static void streamOutput(InputStream in, OutputStream out)
	        throws IOException
	{
	    int len = 8192;
	    byte[] bytes = new byte[len];
	    while ((len = in.read(bytes, 0, len)) != -1)
	    {
	        out.write(bytes, 0, len);
	    }
	    out.flush();
	}

	private static void asc(String[] args, int id)
	{
		Target s = new Target();
		s.id = id;
		s.args = args;
		targets.put("" + id, s);

		try
		{
			macromedia.asc.embedding.Main.show_parsetrees = false;
			macromedia.asc.embedding.Main.show_instructions = false;
			macromedia.asc.embedding.Main.show_linenums = false;
			macromedia.asc.embedding.Main.show_bytes = false;
			macromedia.asc.embedding.Main.show_machinecode = false;
			macromedia.asc.embedding.Main.show_flow = false;
			macromedia.asc.embedding.Main.emit_debug_info = false;
			macromedia.asc.embedding.Main.emit_doc_info = false;
			macromedia.asc.embedding.Main.do_test = false;
			macromedia.asc.embedding.Main.do_help = false;
			macromedia.asc.embedding.Main.filespecFound = false; // only default param
			macromedia.asc.embedding.Main.make_movieclip = false;
			macromedia.asc.embedding.Main.lint_mode = false;
			macromedia.asc.embedding.Main.use_static_semantics = false;
			macromedia.asc.embedding.Main.sanity_mode = false;

			macromedia.asc.embedding.Main.emit_metadata = false;
			macromedia.asc.embedding.Main.log = false;
			// C: don't enable this line...
			// macromedia.asc.embedding.Main.stderr = System.err;

			macromedia.asc.embedding.Main.earliest_dialect = 7;
			macromedia.asc.embedding.Main.latest_dialect = 10;
			macromedia.asc.embedding.Main.default_dialect = 9;
			macromedia.asc.embedding.Main.dialect = macromedia.asc.embedding.Main.default_dialect;

		    macromedia.asc.embedding.Main.optimize = false;
		    macromedia.asc.embedding.Main.optimizer_configs = null;

            macromedia.asc.embedding.Main.include_filespecs = new ObjectList<String>();
			macromedia.asc.embedding.Main.import_filespecs = new ObjectList<String>();
			macromedia.asc.embedding.Main.use_namespaces = new ObjectList<String>();
			macromedia.asc.embedding.Main.swf_options = "";
			macromedia.asc.embedding.Main.language = "EN";

			macromedia.asc.embedding.Main.main(args);
			System.setErr(macromedia.asc.embedding.Main.stderr);
		}
		catch (Exception ex)
		{
			ex.printStackTrace();
		}
	}

	private static void trace(boolean on)
	{
		modifyPlayerConfiguration("TraceOutputFileEnable=", on);
	}

	public static String readFile(File f)
	{
		BufferedReader file = null;
		StringBuilder buffer = new StringBuilder((int) f.length());
		String lineSep = System.getProperty("line.separator");

		try
		{
			file = new BufferedReader(new InputStreamReader(new FileInputStream(f)));
			String s = null;
			while ((s = file.readLine()) != null)
			{
				buffer.append(s);
				buffer.append(lineSep);
			}
			return buffer.toString();
		}
		catch (FileNotFoundException ex)
		{
			return null;
		}
		catch (IOException ex)
		{
			return null;
		}
		finally
		{
			if (file != null)
			{
				try
				{
					file.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}

	public static void writeFile(String fileName, String output) throws FileNotFoundException, IOException
	{
		File file = new File(fileName);
		if (file == null)
		{
			throw new FileNotFoundException(fileName);
		}

		Writer out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF8"));
		try
		{
			out.write(output);
			out.flush();
		}
		finally
		{
			out.close();
		}
	}

	private static void modifyPlayerConfiguration(String key, boolean on)
	{
		File parent = new File(System.getProperty("user.home"));

		File f = new File(parent, "mm.cfg");
		if (f != null && f.exists())
		{
			String mmcfg = readFile(f);
			int index = mmcfg.indexOf(key);
			if (index != -1)
			{
				mmcfg = mmcfg.substring(0, index + key.length()) + (on ? "1" : "0") + mmcfg.substring(index + key.length() + 1);
				try
				{
					writeFile(f.getAbsolutePath(), mmcfg);
				}
				catch (IOException ex)
				{
					ex.printStackTrace();
				}
				mmcfg();
			}
		}
	}

	private static void mmcfg()
	{
		File parent = new File(System.getProperty("user.home"));
		System.out.println("ash: Trying to open mm.cfg in " + parent);

		File f = new File(parent, "mm.cfg");
		if (f != null && f.exists())
		{
			System.out.println(readFile(f).trim());
		}
	}

	private static void intro()
	{
		System.out.println("Actionscript compiler SHell (ash)");
		System.out.println("Copyright 2012 The Apache Software Foundation");
		System.out.println("");
	}

	private static void prompt()
	{
		System.out.print("(ash) ");
	}

	private static void cmdList()
	{
		System.out.println("List of ash commands:");
		System.out.println("asc arg1 arg2 ...        compile; return a target id");
		System.out.println("run id                   run avmplus");
		System.out.println("clear [id]               clear target(s)");
		System.out.println("info [id]                display compile target info");
		System.out.println("gc                       run garbage collection");
		System.out.println("memory                   display current memory usage");
		System.out.println("mm.cfg                   display mm.cfg information");
		System.out.println("trace on|off             set tracing in mm.cfg");
        System.out.println("touch file1 file2...     modifies file timestamp");
		System.out.println("quit                     quit");
	}

	static class Target
	{
		public int id;
		public String[] args;
	}
}


