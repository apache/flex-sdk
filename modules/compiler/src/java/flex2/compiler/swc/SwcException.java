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

package flex2.compiler.swc;

import flash.localization.LocalizationManager;
import flex2.compiler.ILocalizableMessage;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * General exception for SWC problems.
 *
 * @author Brian Deitte
 */
public class SwcException extends RuntimeException implements ILocalizableMessage
{
	private static final long serialVersionUID = -8494333073832014661L;
    Exception detailEx;

	public String getLevel()
	{
	    return ERROR;
	}

	public String getPath()
	{
	    return null;
	}

    public void setPath(String path)
    {
    }

	public int getLine()
	{
	    return -1;
	}

    public void setLine(int line)
    {
    }

	public int getColumn()
	{
	    return -1;
	}

    public void setColumn(int column)
    {
    }

	public Exception getExceptionDetail()
	{
		return detailEx;
	}

	public boolean isPathAvailable()
	{
		return true;
	}

	public String getMessage()
	{
		String msg = super.getMessage();
		if (msg != null)
		{
			return msg;
		}
		else
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			if (l10n == null)
			{
				return null;
			}
			else
			{
				return l10n.getLocalizedTextString(this);
			}
		}
	}
	
	public String toString()
	{
		return getMessage();
	}

	/**
	* Start of SwcExceptions, the main message classes for swc exceptions.  Only SwcException classes
	* should be logged and thrown out of the SWC package.
	**/

	public static class SwcNotLoaded extends SwcException
	{
		private static final long serialVersionUID = -2554776022462133598L;
        public SwcNotLoaded(String location, Exception exception)
		{
			this.location = location;
			this.detailEx = exception;
		}
		public String location;
	}

	public static class SwcNotExported extends SwcException
	{
		private static final long serialVersionUID = 3467058758218868806L;
        public SwcNotExported(String location, Exception exception)
		{
			this.location = location;
			this.detailEx = exception;
		}
		public String location;
	}

	public static class CouldNotFindSource extends SwcException
	{
		private static final long serialVersionUID = 1560595276060532770L;
        public CouldNotFindSource(String className)
		{
			this.className = className;
		}
		public String className;
	}

	public static class CouldNotFindFileSource extends SwcException
	{
		private static final long serialVersionUID = 2801395325513327168L;
        public CouldNotFindFileSource(String className)
		{
			this.className = className;
		}
		public String className;
	}

	public static class NoResourceBundleSource extends SwcException
	{
	    private static final long serialVersionUID = 4614290447127279268L;
        public NoResourceBundleSource( String className )
	    {
	        this.className = className;
	    }
	    public String className;
	}

	public static class NoSourceForClass extends SwcException
	{
	    private static final long serialVersionUID = -2979710207329828285L;
        public NoSourceForClass( String className, String nsTarget )
	    {
	        this.className = className;
		    this.nsTarget = nsTarget;
	    }
	    public String className;
		public String nsTarget;
	}

	public static class MissingIconFile extends SwcException
    {
        private static final long serialVersionUID = -4352255326395065440L;
        public MissingIconFile( String icon, String source )
        {
            this.icon = icon;
            this.source = source;
        }
        public String icon;
        public String source;
    }
	
	public static class MissingFile extends SwcException
	{
		private static final long serialVersionUID = 5684202543884980582L;
        public MissingFile(String file)
		{
			this.file = file;
		}
		public String file;
	}

	public static class NullCatalogStream extends SwcException
	{

        private static final long serialVersionUID = -998293635787865589L;
	}

	public static class UseClassName extends SwcException
	{

        private static final long serialVersionUID = 9041507300608050252L;
	}

	public static class DuplicateDefinition extends SwcException
	{
		private static final long serialVersionUID = 1516531038464434547L;
        public DuplicateDefinition(String definition, String script, String source)
		{
			this.definition = definition;
			this.script = script;
			this.source = source;
		}

		public String definition;
		public String script;
		public String source;
	}

	public static class SwcNotFound extends SwcException
	{
		private static final long serialVersionUID = 7224142779917797604L;
        public SwcNotFound(String location)
		{
			this.location = location;
		}
		public String location;
	}

	public static class NotASwcDirectory extends SwcException
	{
		private static final long serialVersionUID = 3680364244079842127L;
        public NotASwcDirectory(String directory)
		{
			this.directory = directory;
		}
		public String directory;
	}

	public static class SwcLocation extends SwcException
	{
		private static final long serialVersionUID = -4103907341840876695L;

        public SwcLocation(String location)
		{
			this.location = location;
		}

		public String location;
	}

	public static class FileNotWritten extends SwcException
	{
		private static final long serialVersionUID = -6044223715981449297L;
        public FileNotWritten(String file, String message)
		{
			this.file = file;
			this.message = message;
		}
		public String file;
		public String message;
	}

	public static class FilesNotRead extends SwcException
	{
		private static final long serialVersionUID = -7482575224824123700L;
        public FilesNotRead(String message)
		{
			this.message = message;
		}
		public String message;
	}

	public static class NotADirectory extends SwcException
	{
		private static final long serialVersionUID = -3324810541160061753L;
        public NotADirectory(String directory)
		{
			this.directory = directory;
		}
		public String directory;
	}

	public static class DirectoryNotCreated extends SwcException
	{
		private static final long serialVersionUID = 8570936566842347533L;
        public DirectoryNotCreated(String directory)
		{
			this.directory = directory;
		}
		public String directory;
	}

	public static class SwcNotRenamed extends SwcException
	{
		private static final long serialVersionUID = -2890913997385310503L;
        public SwcNotRenamed(String oldName, String newName)
		{
			this.oldName = oldName;
			this.newName = newName;
		}
		public String oldName;
		public String newName;
	}

	public static class CatalogNotFound extends SwcException
	{

        private static final long serialVersionUID = 108663682135244079L;
	}

	public static class UnsupportedOperation extends SwcException
	{
		private static final long serialVersionUID = 7507668150266635174L;
        public UnsupportedOperation(String operation, String className)
		{
			this.operation = operation;
			this.className = className;
		}
		public String operation;
		public String className;
	}

	public static class EmptyNamespace extends SwcException
	{
		private static final long serialVersionUID = -5461119352251578340L;
        public EmptyNamespace(String name)
		{
			this.name = name;
		}
		public String name;
	}

	public static class ComponentDefinedTwice extends SwcException
	{
		private static final long serialVersionUID = -6880538200104744439L;
        public ComponentDefinedTwice(String name, String className1, String className2)
		{
			this.name = name;
			this.className1 = className1;
			this.className2 = className2;
		}
		public String name;
		public String className1;
		public String className2;
	}

	public static class UnknownElementInCatalog extends SwcException
	{
		private static final long serialVersionUID = -1709365264970456008L;
        public UnknownElementInCatalog(String element, String section)
		{
			this.element = element;
			this.section = section;
		}
		public String element;
		public String section;
	}

	public static class UnsupportedFeature extends SwcException
	{
		private static final long serialVersionUID = 2318520473798835842L;
        public UnsupportedFeature(String name)
		{
			this.name = name;
		}
		public String name;
	}

	public static class NoElementValue extends SwcException
	{
		private static final long serialVersionUID = -5700047399416802509L;
        public NoElementValue(String name)
		{
			this.name = name;
		}
		public String name;
	}

	public static class ScriptUsedMultipleTimes extends SwcException
	{
		private static final long serialVersionUID = -185332682720245755L;
        public ScriptUsedMultipleTimes(String scriptName)
		{
			this.scriptName = scriptName;
		}
		public String scriptName;
	}

	public static class NoElementValueFound extends SwcException
	{
		private static final long serialVersionUID = 390935817896002861L;
        public NoElementValueFound(String name, String className)
		{
			this.name = name;
			this.className = className;
		}
		public String name;
		public String className;
	}

	public static class BadCRC extends SwcException
	{
		private static final long serialVersionUID = -2938866033550966368L;
        public BadCRC(String givenChecksum, String realChecksum)
		{
			this.givenChecksum = givenChecksum;
			this.realChecksum = realChecksum;
		}
		public String givenChecksum;
		public String realChecksum;
	}

	public static class UnknownZipFormat extends SwcException
	{
		private static final long serialVersionUID = -7447740969926776234L;
        public UnknownZipFormat(String start)
		{
			this.start = start;
		}
		public String start;
	}

	public static class NotAResource extends SwcException
	{
		private static final long serialVersionUID = -5897483545874573295L;
        public NotAResource(String className)
		{
			this.className = className;
		}
		public String className;
	}

	public static class CouldNotSetZipSize extends SwcException
	{
		private static final long serialVersionUID = -309332180325061103L;
        public CouldNotSetZipSize(String entry, String message)
		{
			this.entry = entry;
			this.message = message;
		}
		public String entry;
		public String message;
	}

	public static class UnsupportedZipCompression extends SwcException
	{
		private static final long serialVersionUID = 324265408589862036L;
        public UnsupportedZipCompression(String method)
		{
			this.method = method;
		}
		public String method;
	}

	public static class BadZipSize extends SwcException
	{
		private static final long serialVersionUID = 1320298387837461369L;
        public BadZipSize(String entry, String expected, String found)
		{
			this.entry = entry;
			this.expected = expected;
			this.found = found;
		}
		public String entry;
		public String expected;
		public String found;
	}
	
	public static class NotASwcFile extends SwcException
	{
		private static final long serialVersionUID = 2547089548876219296L;
        public NotASwcFile(String location)
		{
			this.location = location;
		}
		public String location;
	}


    public static class ArchiveFileException extends SwcException
    {
        public String message;

        public ArchiveFileException(String message)
        {
            this.message = message;
        }
    }

	public static class MetadataNotWritten extends CompilerMessage.CompilerWarning
	{
	    private static final long serialVersionUID = 5146935251331331679L;

        public MetadataNotWritten()
	    {
	    }
	}


	public static class DigestsNotWritten extends CompilerMessage.CompilerWarning
	{
	    private static final long serialVersionUID = 4407668372093287396L;

        public DigestsNotWritten()
	    {
	    }
	}
}
