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

package flex.tools.debugger.cli;

import java.io.PrintWriter;
import java.text.ParseException;
import java.util.HashMap;
import java.util.Map;

import flash.localization.LocalizationManager;
import flash.swf.tools.Disassembler;
import flash.swf.types.ActionList;
import flash.tools.ActionLocation;
import flash.tools.debugger.Bootstrap;
import flash.tools.debugger.InProgressException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SourceFile;
import flash.tools.debugger.SuspendReason;
import flash.tools.debugger.SuspendedException;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.Value;
import flash.tools.debugger.concrete.DMessage;
import flash.tools.debugger.concrete.DMessageCounter;
import flash.tools.debugger.concrete.DModule;
import flash.tools.debugger.concrete.DSuspendInfo;
import flash.tools.debugger.concrete.DSwfInfo;
import flash.tools.debugger.concrete.PlayerSession;
import flash.tools.debugger.concrete.PlayerSessionManager;
import flash.util.FieldFormat;

/**
 * Extensions class is a singleton that contains
 * every cli method that does not conform to the 
 * API.  Thus we can easily remove these features
 * from the cli if the implementation does not
 * support these calls.
 */
public class Extensions
{
	public final static String m_newline = System.getProperty("line.separator"); //$NON-NLS-1$

	public static void doShowStats(DebugCLI cli) throws IllegalStateException
	{
		/* we do some magic casting */
		Session session = cli.getSession();
		StringBuilder sb = new StringBuilder();
		try
		{
			PlayerSession p = (PlayerSession)session;
			DMessageCounter cnt = p.getMessageCounter();

			sb.append(getLocalizationManager().getLocalizedTextString("key16")); //$NON-NLS-1$
			sb.append(m_newline);
			for(int i=0; i<=DMessage.InSIZE; i++)
			{
				long amt = cnt.getInCount(i);
				if (amt > 0)
				{
					sb.append('\n');
					sb.append(DMessage.inTypeName(i));
					sb.append(" = "); //$NON-NLS-1$
					sb.append(amt);
				}
			}

			sb.append("\n\n"); //$NON-NLS-1$
			sb.append(getLocalizationManager().getLocalizedTextString("key17")); //$NON-NLS-1$
			sb.append("\n"); //$NON-NLS-1$
			for(int i=0; i<=DMessage.OutSIZE; i++)
			{
				long amt = cnt.getOutCount(i);
				if (amt > 0)
				{
					sb.append('\n');
					sb.append(DMessage.outTypeName(i));
					sb.append(" = "); //$NON-NLS-1$
					sb.append(amt);
				}
			}

			sb.append('\n');
			cli.out( sb.toString() );
		}
		catch(NullPointerException e)
		{
			throw new IllegalStateException();
		}
	}

	public static void doShowFuncs(DebugCLI cli)
	{
		StringBuilder sb = new StringBuilder();

		String arg = null;
		FileInfoCache fileInfo = cli.getFileCache();

		// we take an optional single arg which specifies a module
		try
		{
			// let's wait a bit for the background load to complete
			cli.waitForMetaData();

			if (cli.hasMoreTokens())
			{
				arg = cli.nextToken();
				int id = arg.equals(".") ? cli.propertyGet(DebugCLI.LIST_MODULE) : cli.parseFileArg(-1, arg); //$NON-NLS-1$

				DModule m = (DModule)fileInfo.getFile(id);
                m.lineMapping(sb);
			}
			else
			{
				SourceFile[] ar = fileInfo.getFileList();
				if (ar == null)
					cli.err(getLocalizationManager().getLocalizedTextString("key18")); //$NON-NLS-1$
				else
                {
                    for (int i = 0; ar != null && i < ar.length; i++)
                    {
                        DModule m = (DModule)ar[i];
                        m.lineMapping(sb);
                    }
                }
			}

			cli.out(sb.toString());
		}
		catch(NullPointerException npe)
		{
			cli.err(getLocalizationManager().getLocalizedTextString("key19")); //$NON-NLS-1$
		}
		catch(ParseException pe)
		{
			cli.err(pe.getMessage());
		}
		catch(AmbiguousException ae)
		{
			cli.err(ae.getMessage());
		}
		catch(NoMatchException nme)
		{
			cli.err(nme.getMessage());
		}
		catch(InProgressException ipe)
		{
		    cli.err(getLocalizationManager().getLocalizedTextString("key20")); //$NON-NLS-1$
		}
	}

	/**
	 * Dump the content of internal variables
	 */
	public static void doShowProperties(DebugCLI cli)
	{
		StringBuilder sb = new StringBuilder();

		Session session = cli.getSession();
		for (String key: cli.propertyKeys())
		{
			int value = cli.propertyGet(key);
			sb.append(key);
			sb.append(" = "); //$NON-NLS-1$
			sb.append(value);
			sb.append('\n');
		}

		// session manager
		{
			PlayerSessionManager mgr = (PlayerSessionManager)Bootstrap.sessionManager();
			sb.append(getLocalizationManager().getLocalizedTextString("key21")); //$NON-NLS-1$
			sb.append('\n');
			for (String key: mgr.keySet())
			{
				Object value = mgr.getPreferenceAsObject(key);
				sb.append(key);
				sb.append(" = "); //$NON-NLS-1$
				sb.append(value);
				sb.append('\n');
			}
		}

		if (session != null)
		{
			PlayerSession psession = (PlayerSession)session;
			sb.append(getLocalizationManager().getLocalizedTextString("key22")); //$NON-NLS-1$
			sb.append('\n');
			for (String key: psession.keySet())
			{
				Object value = psession.getPreferenceAsObject(key);
				sb.append(key);
				sb.append(" = "); //$NON-NLS-1$
				sb.append(value);
				sb.append('\n');
			}
		}

		cli.out( sb.toString() );
	}

	/**
	 * Dump the break reason and offset
	 */
	public static void doShowBreak(DebugCLI cli) throws NotConnectedException
	{
		cli.waitTilHalted();
		try
		{
			Session session = cli.getSession();
			StringBuilder sb = new StringBuilder();
			if (session.isSuspended())
			{
				sb.append(getLocalizationManager().getLocalizedTextString("stopped")); //$NON-NLS-1$
				sb.append(' ');
				appendBreakInfo(cli, sb, true);
			}
			else
				sb.append(getLocalizationManager().getLocalizedTextString("key24")); //$NON-NLS-1$

			cli.out( sb.toString() );
		}
		catch(NullPointerException npe)
		{
			cli.err(getLocalizationManager().getLocalizedTextString("key25")); //$NON-NLS-1$
		}
	}

	// Extended low level break information
	public static void appendBreakInfo(DebugCLI cli, StringBuilder sb, boolean includeFault) throws NotConnectedException
	{
		Session session = cli.getSession();
		FileInfoCache fileInfo = cli.getFileCache();

		int reason = session.suspendReason();
		int offset = ((PlayerSession)session).getSuspendOffset();
		int index = ((PlayerSession)session).getSuspendActionIndex();

		SwfInfo info = null;
		try { info = fileInfo.getSwfs()[index]; } catch(ArrayIndexOutOfBoundsException oobe) {}
		if (info != null)
		{
			Map<String, String> args = new HashMap<String, String>();
			args.put("swfName", FileInfoCache.nameOfSwf(info) ); //$NON-NLS-1$
			sb.append(getLocalizationManager().getLocalizedTextString("key35", args)); //$NON-NLS-1$
			sb.append(' ');
		}

		Map<String, String> args = new HashMap<String, String>();
		args.put("address", "0x" + FieldFormat.formatLongToHex(new StringBuilder(), offset, 8) + " (" + offset + ")"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
		sb.append(getLocalizationManager().getLocalizedTextString("atAddress", args)); //$NON-NLS-1$

		if (includeFault)
		{
			args = new HashMap<String, String>();
			StringBuilder reasonBuffer = new StringBuilder();
			cli.appendReason(reasonBuffer, reason);
			args.put("fault", reasonBuffer.toString() ); //$NON-NLS-1$
			sb.append(' ');
			sb.append(getLocalizationManager().getLocalizedTextString("haltedDueToFault", args)); //$NON-NLS-1$
		}
	}

	// Raw direct call to Player
	public static void doShowVariable(DebugCLI cli) throws PlayerDebugException
	{
		cli.waitTilHalted();
		try
		{
			// an integer followed by a variable name
			Session session = cli.getSession();
			long id = cli.nextLongToken();
			String name = (cli.hasMoreTokens()) ? cli.nextToken() : null;

			StringBuilder sb = new StringBuilder();
			sb.append(name);
			sb.append(" = "); //$NON-NLS-1$
			Value v = ((PlayerSession)session).getValue(id, name);
			ExpressionCache.appendVariableValue(sb, v);
			cli.out( sb.toString() );
		}
		catch(NullPointerException npe)
		{
			cli.err(getLocalizationManager().getLocalizedTextString("key26")); //$NON-NLS-1$
		}
	}

 	public static void doDisassemble(DebugCLI cli) throws PlayerDebugException
 	{
		/* currentXXX may NOT be invalid! */
		int currentModule = cli.propertyGet(DebugCLI.LIST_MODULE);
		int currentLine = cli.propertyGet(DebugCLI.LIST_LINE);
 
		String arg1 = null;
		int module1 = currentModule;
		int line1 = currentLine;
 
		String arg2 = null;
		int line2 = currentLine;
 
 		boolean functionNamed = false;
		int numLines = 0;
 		try
 		{
			FileInfoCache fileInfo = cli.getFileCache();
			Session session = cli.getSession();
			if (cli.hasMoreTokens())
 			{
				arg1 = cli.nextToken();
				if (arg1.equals("-")) //$NON-NLS-1$
				{
 					// move back one line
					line1 = line2 = line1 - 1;
				}
				else
				{
					int[] result = cli.parseLocationArg(currentModule, currentLine, arg1);
					module1 = result[0];
					line2 = line1 = result[1];
 					functionNamed = (result[2] == 0) ? false : true;
 
					if (cli.hasMoreTokens())
					{
						arg2 = cli.nextToken();
						line2 = cli.parseLineArg(module1, arg2);
					}
				}
 			}
 			else
 			{
 				// since no parms test for valid location if none use players concept of where we stopped
 				if( fileInfo.getFile(currentModule) == null)
 				{
 					//here we simply use the players concept of suspsend
 					DSuspendInfo info = ((PlayerSession)session).getSuspendInfo();
 					int at = info.getOffset();
 					int which = info.getActionIndex();
 					int until = info.getNextOffset();
 					if (info.getReason() == SuspendReason.Unknown)
 						throw new SuspendedException();
 
 					SwfInfo swf = fileInfo.getSwfs()[which];
 					outputAssembly(cli, (DSwfInfo)swf, at, until);
 					throw new AmbiguousException(getLocalizationManager().getLocalizedTextString("key27")); //$NON-NLS-1$
 				}
 			}			
 
 			/**
 			 * Check for a few error conditions, otherwise we'll write a listing!
 			 */
 			if (cli.hasMoreTokens())
 			{
 				cli.err(getLocalizationManager().getLocalizedTextString("key28")); //$NON-NLS-1$
 			}
 			else
 			{
 				SourceFile file = fileInfo.getFile(module1);
 				numLines = file.getLineCount();
 
 				// pressing return is ok, otherwise throw the exception
 				if (line1 > numLines && arg1 != null)
 					throw new IndexOutOfBoundsException();
 
 				/* if no arg2 then user list a single line */
 				if (arg2 == null)
 					line2 = line1;
 
 				/* adjust our range of lines to ensure we conform */
 				if (line1 < 1)
 				{
 					/* shrink line 1, grow line2 */
 					line2 += -(line1 - 1);
 					line1 = 1;
 				}
 
 				if (line2 > numLines)
 					line2 = numLines;
 
				//			    System.out.println("1="+module1+":"+line1+",2="+module2+":"+line2+",num="+numLines+",half="+half);
 
 				/* nothing to display */
 				if (line1 > line2)
 					throw new IndexOutOfBoundsException();
 
 				/* now dump the mixed source / assembly */
 				// now lets find which swf this in 
 				DSwfInfo swf = (DSwfInfo)fileInfo.swfForFile(file);
 				ActionLocation lStart = null;
 				ActionLocation lEnd = null;
 
 				if (swf == null)
				{
					Map<String, String> args = new HashMap<String, String>();
					args.put("arg3", file.getName()); //$NON-NLS-1$
 					cli.err(getLocalizationManager().getLocalizedTextString("key29", args)); //$NON-NLS-1$
				}
 				else if (functionNamed)
 				{
 					// if we name a function just dump the whole thing without source.
 					int offset = file.getOffsetForLine(line1);
 					lStart = swf.locate(offset);
 					if (lStart.function == null)
 						cli.err(getLocalizationManager().getLocalizedTextString("key30")); //$NON-NLS-1$
 					else
 					{
 						// create a psudeo action list from which to disasemble the function
 						ActionList al = new ActionList(true);
 						al.setActionOffset(0, lStart.function);
 						lStart.actions = al;
 						lStart.at = 0;
 						lEnd = new ActionLocation();
 						lEnd.actions = al;
 						lEnd.at = 0;
 						outputAssembly(cli, swf, lStart, lEnd);
 					}
 				}
 				else
 				{
 					ActionLocation lastEnd = null;
 					for(int i=line1; i<=line2; i++)
 					{
 						int offset = file.getOffsetForLine(i);
 
 						// locate the action list associated with this of the swf
 						if (offset != 0)
 						{
 							// get the starting point and try to locate a nice ending
 							lStart = swf.locate(offset);
 							lEnd = swf.locateSourceLineEnd(lStart);
 
 							// now see if we skipped some assembly between source lines
 							if (lastEnd != null)
 							{
 								lastEnd.at++;  // point our pseudo start to the next action
 
 								// new actions list so attempt to find the end of source in the old actions list
 								if (lastEnd.actions != lStart.actions && lastEnd.actions.size() != lastEnd.at)
 								{
 									String atString = Integer.toHexString(lastEnd.actions.getOffset(lastEnd.at));
									Map<String, String> args = new HashMap<String, String>();
									args.put("arg4", atString); //$NON-NLS-1$
 									cli.out(getLocalizationManager().getLocalizedTextString("key31", args)); //$NON-NLS-1$
 
  									// we are missing some of the dissassembly, so back up a bit and dump it out
 									ActionLocation gapEnd = swf.locateSourceLineEnd(lastEnd);
 									outputAssembly(cli, swf, lastEnd, gapEnd);
 								}
 								else if (lastEnd.at < lStart.at)
 								{
 									// same action list but we skipped some instructions 
 									ActionLocation gapEnd = new ActionLocation(lStart);
 									gapEnd.at--;
 									outputAssembly(cli, swf, lastEnd, gapEnd);
 								}
 							}
 							lastEnd = lEnd;
 						}
 
 						// dump source
 						cli.outputSource(module1, i, file.getLine(i));
 						
 						// obtain the offset, locate it in the swf
 						if (offset != 0)
 							outputAssembly(cli, swf, lStart, lEnd);
 					}
 
 					/* save away valid context */
 					cli.propertyPut(DebugCLI.LIST_MODULE, module1);
 					cli.propertyPut(DebugCLI.LIST_LINE, line2 + 1);  // add one
 					cli.m_repeatLine = "disassemble";   /* allow repeated listing by typing CR */ //$NON-NLS-1$
 				}
 			}
 		}
		catch(IndexOutOfBoundsException iob)
 		{
 			String name = "#"+module1; //$NON-NLS-1$
			Map<String, String> args = new HashMap<String, String>();
			args.put("arg5", Integer.toString(line1)); //$NON-NLS-1$
			args.put("arg6", name); //$NON-NLS-1$
			args.put("arg7", Integer.toString(numLines)); //$NON-NLS-1$
 			cli.err(getLocalizationManager().getLocalizedTextString("key32", args)); //$NON-NLS-1$
 		}
 		catch(AmbiguousException ae)
 		{
 			cli.err(ae.getMessage());
 		}
 		catch(NullPointerException npe)
 		{
 			cli.err(getLocalizationManager().getLocalizedTextString("key33")); //$NON-NLS-1$
 		}
 		catch(ParseException pe)
 		{
 			cli.err(pe.getMessage());
 		}
		catch(NoMatchException nme)
		{
			cli.err(nme.getMessage());
		}
 		catch(SuspendedException se)
 		{
			cli.err(getLocalizationManager().getLocalizedTextString("key34")); //$NON-NLS-1$
 		}
 	}
 
 	private static LocalizationManager getLocalizationManager()
	{
 		return DebugCLI.getLocalizationManager();
	}

	/**
 	 * Disassemble part of the swf to the output 
 	 */
 	public static ActionLocation outputAssembly(DebugCLI cli, DSwfInfo swf, int start, int end)
 	{
 		// first we need to locate the action list associated with this
 		// portion of the swf
 		ActionLocation lStart = swf.locate(start);
 		ActionLocation lEnd = (end > -1) ? swf.locate(end) : swf.locateSourceLineEnd(lStart);
 
 		return outputAssembly(cli, swf, lStart, lEnd);
 	}
 
 	public static ActionLocation outputAssembly(DebugCLI cli, SwfInfo info, ActionLocation lStart, ActionLocation lEnd)
 	{
 		// now make sure our actions lists are the same (i.e we haven't spanned past one tag)
 		if (lStart.actions != lEnd.actions)
 			lEnd.at = lStart.actions.size()-1;
 		
 		Disassembler.disassemble(lStart.actions, lStart.pool, lStart.at, lEnd.at, new PrintWriter(cli.getOut()));
 		return lEnd;
 	}
}
