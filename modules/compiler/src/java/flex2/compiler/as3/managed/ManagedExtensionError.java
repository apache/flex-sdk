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

package flex2.compiler.as3.managed;

import java.util.Iterator;

import flash.localization.LocalizationManager;
import flex2.compiler.CompilationUnit;
import flex2.compiler.as3.Extension;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.util.Context;

/**
 * A compiler extension used to report an error when Managed metadata
 * is used on a MXML component.
 *
 * @author Jason Williams
 */
public class ManagedExtensionError implements Extension {

	public void parse1(CompilationUnit unit, TypeTable typeTable) {
		Context cx = unit.getContext().getAscContext();
		for (Iterator iter = unit.metadata.iterator(); iter.hasNext(); )
		{
			MetaDataNode metaDataNode = (MetaDataNode)iter.next();
			if (StandardDefs.MD_MANAGED.equals(metaDataNode.getId()))
			{
				LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
				cx.localizedError2(metaDataNode.pos(), new ManagedOnMXMLComponentError());
			}
		}
	}
	
    public void parse2(CompilationUnit unit, TypeTable typeTable)
    {
    }

	public void analyze1(CompilationUnit unit, TypeTable typeTable) {
	}

	public void analyze2(CompilationUnit unit, TypeTable typeTable) {
	}

	public void analyze3(CompilationUnit unit, TypeTable typeTable) {
	}

	public void analyze4(CompilationUnit unit, TypeTable typeTable) {
	}

	public void generate(CompilationUnit unit, TypeTable typeTable) {
	}

	/**
	 * Compiler Error Messages
	 */
	public static class ManagedOnMXMLComponentError extends CompilerMessage.CompilerError {

        private static final long serialVersionUID = -7761658321292961424L;}

}
