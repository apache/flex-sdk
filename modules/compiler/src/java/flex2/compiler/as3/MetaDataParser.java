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

package flex2.compiler.as3;

import flex2.compiler.Source;
import flex2.compiler.as3.reflect.MetaData;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.parser.Parser;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;

/**
 * This utility class is used to parse metadata.
 *
 * @author Paul Reilly
 */
public class MetaDataParser
{
	/**
	 * @param file where the metadata string is located.
	 * @param md
	 */
	public static MetaData parse(ContextStatics perCompileData, Source file, final int beginLine, String md)
	{
		StringBuilder stringBuffer = new StringBuilder();

		stringBuffer.append("[");
		stringBuffer.append(md);
		stringBuffer.append("]");

		// C: Is it possible to find out the encoding of the string from the source?
		/*InputStream inputStream = null;
		try
		{
			inputStream = new ByteArrayInputStream(stringBuffer.toString().getBytes("UTF-8"));
		}
		catch (UnsupportedEncodingException ex)
		{
			// not possible...
		}*/

		Context context = new Context((ContextStatics) perCompileData);
		context.setPath(file.getParent());
		context.setScriptName(file.getName());
		context.setHandler(new flex2.compiler.as3.As3Compiler.CompilerHandler()
		{
			public void error2(String filename, int ln, int col, Object msg, String source)
			{
				ThreadLocalToolkit.log(new InvalidMetadataFormatError(), filename, beginLine);
			}

			public void warning2(String filename, int ln, int col, Object msg, String source)
			{
				ThreadLocalToolkit.log(new InvalidMetadataFormatWarning(), filename, beginLine);
			}

			public void error(String filename, int ln, int col, String msg, String source, int errorCode)
			{
				ThreadLocalToolkit.log(new InvalidMetadataFormatError(), filename, beginLine);				
			}
			
			public void error(String filename, int ln, int col, String msg, String source)
			{
				ThreadLocalToolkit.log(new InvalidMetadataFormatError(), filename, beginLine);
			}

			public void warning(String filename, int ln, int col, String msg, String source, int errorCode)
			{	
				ThreadLocalToolkit.log(new InvalidMetadataFormatWarning(), filename, beginLine);
			}

			public void warning(String filename, int ln, int col, String msg, String source)
			{
				ThreadLocalToolkit.log(new InvalidMetadataFormatWarning(), filename, beginLine);
			}

			public FileInclude findFileInclude(String parentPath, String filespec)
			{
				return null;
			}			
		});
		((ContextStatics) perCompileData).handler = context.getHandler();

		Parser parser = new Parser(context, stringBuffer.toString(), file.getName());
		MetaDataNode metaDataNode = parser.parseMetaData();
		macromedia.asc.parser.MetaDataEvaluator metaDataEvaluator = new macromedia.asc.parser.MetaDataEvaluator();
		metaDataNode.evaluate(context, metaDataEvaluator);

		return context.errorCount() > 0 ? null : new MetaData(metaDataNode);
	}

	// error messages

	public static class InvalidMetadataFormatError extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -6441349221772507527L;

        public InvalidMetadataFormatError()
		{
			super();
		}
	}

	public static class InvalidMetadataFormatWarning extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = -9004017223630883454L;

        public InvalidMetadataFormatWarning()
		{
			super();
		}
	}
}
