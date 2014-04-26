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

package flex.tools.debugger.cli;

/**
 * ExtensionsDisabled class is a singleton that contains
 * every cli method that does not conform to the 
 * API.  There are two implementations of this singleton
 * In Extensions the full code is provided in this class
 * ExtensionsDisabled emtpy stubs are provided that allow
 * for DebugCLI to be fully compliant with the API 
 */
public class ExtensionsDisabled
{
	public static void doShowStats(DebugCLI cli) { cli.out("Command not supported."); } //$NON-NLS-1$
	public static void doShowFuncs(DebugCLI cli) { cli.out("Command not supported."); } //$NON-NLS-1$
	public static void doShowProperties(DebugCLI cli) { cli.out("Command not supported."); } //$NON-NLS-1$
	public static void doShowBreak(DebugCLI cli) { cli.out("Command not supported."); } //$NON-NLS-1$
	public static void appendBreakInfo(DebugCLI cli, StringBuilder sb, boolean includeFault) { cli.out("Command not supported."); } //$NON-NLS-1$
	public static void doShowVariable(DebugCLI cli) { cli.out("Command not supported."); } //$NON-NLS-1$
 	public static void doDisassemble(DebugCLI cli) { cli.out("Command not supported."); } //$NON-NLS-1$
}
