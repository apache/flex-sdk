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

package flex2.compiler.config;

import flash.localization.LocalizationManager;
import flex2.compiler.ILocalizableMessage;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * A common base class for configuration related exceptions.
 *
 * @author Roger Gonzalez
 */
public class ConfigurationException extends Exception implements ILocalizableMessage
{
    private static final long serialVersionUID = -2435642161291588713L;

    public ConfigurationException( String msg )
    {
        super( msg );
    }

    public ConfigurationException( String var, String source, int line )
    {
        this.var = var;
        this.source = source;
        this.line = line;
    }

    public String getLevel()
    {
        return ERROR;
    }

    public String getPath()
    {
        return source;
    }

    public void setPath(String path)
    {
        source = path;
    }

    public int getLine()
    {
        return line;
    }

    public void setLine(int line)
    {
        this.line = line;
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
		return null;
	}

	public boolean isPathAvailable()
	{
		return true;
	}
	
    public static class UnknownVariable extends ConfigurationException
    {
        private static final long serialVersionUID = 8571582080586301558L;

        public UnknownVariable( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class IllegalMultipleSet extends ConfigurationException
    {
        private static final long serialVersionUID = 7419980739937494086L;

        public IllegalMultipleSet( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class UnexpectedDefaults extends ConfigurationException
    {
        private static final long serialVersionUID = 3830239641111918142L;

        public UnexpectedDefaults( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class InterspersedDefaults extends ConfigurationException
    {
        private static final long serialVersionUID = 4604939375999662998L;

        public InterspersedDefaults( String var, String source, int line )
        {
            super( var, source, line );
        }
    }



    public String var = null;
    public String source = null;
    public int line = -1;

    public static class AmbiguousParse extends ConfigurationException
    {
        private static final long serialVersionUID = -8207848984128407945L;
        
        public AmbiguousParse( String defaultvar, String var, String source, int line )
        {
            super( var, source, line );
            this.defaultvar = defaultvar;
        }
        public String defaultvar;
    }


    public static class Token extends ConfigurationException
    {
        private static final long serialVersionUID = 9018726365196176871L;
        
        public static final String MISSING_DELIMITER = "MissingDelimiter";
        public static final String MULTIPLE_VALUES = "MultipleValues";
        public static final String UNKNOWN_TOKEN = "UnknownToken";
        public static final String RECURSION_LIMIT = "RecursionLimit";
        public static final String INSUFFICIENT_ARGS = "InsufficientArgs";
        public Token( String id, String token, String var, String source, int line )
        {
            super( var, source, line );
            this.token = token;
            this.id = id;
        }
        public String id;
        public String token;
    }
    public static class IncorrectArgumentCount extends ConfigurationException
    {
        private static final long serialVersionUID = 7926363942942750268L;
        
        public IncorrectArgumentCount( int expected, int passed, String var, String source, int line )
        {
            super( var, source, line );
            this.expected = expected;
            this.passed = passed;
        }
        public int expected;
        public int passed;
    }

    public static class VariableMissingRequirement extends ConfigurationException
    {
        private static final long serialVersionUID = -9165402878493963589L;
        
        public VariableMissingRequirement( String required, String var, String source, int line )
        {
            super( var, source, line );
            this.required = required;
        }
        public String required;
    }

    public static class MissingRequirement extends ConfigurationException
    {
        private static final long serialVersionUID = -5579697104441150933L;
        
        public MissingRequirement( String required, String var, String source, int line )
        {
            super( null, source, line );
            this.required = required;
        }
        public String required;
    }

    public static class OtherThrowable extends ConfigurationException
    {
        private static final long serialVersionUID = -6369637486598549167L;
        
        public OtherThrowable( Throwable t, String var, String source, int line )
        {
            super( var, source, line );
            this.throwable = t;
        }
        public Throwable throwable;
    }

    public static class BadValue extends ConfigurationException
    {
        private static final long serialVersionUID = 6359203893459990766L;
        
        public BadValue( String value, String var, String source, int line )
        {
            super( var, source, line );
            this.value = value;
        }
        public String value;
    }

    public static class TypeMismatch extends BadValue
    {
        private static final long serialVersionUID = 4440833762090886016L;
        
        public static final String BOOLEAN = "Boolean";
        public static final String INTEGER = "Integer";
        public static final String LONG = "Long";
        public TypeMismatch( String type, String value, String var, String source, int line )
        {
            super( value, var, source, line );
            this.id = type;
        }
        public String id;   // named id in order to act as a subkey for L10N mgr
    }

    public static class ConfigurationIOError extends ConfigurationException
    {
        private static final long serialVersionUID = 4447234734754165407L;
        
        public ConfigurationIOError( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }
    public static class IOError extends ConfigurationIOError
    {
        private static final long serialVersionUID = -8336197665007633417L;

        public IOError( String path )
        {
            super( path, null, null, -1 );
        }
    }
    public static class NotDirectory extends ConfigurationException
    {
        private static final long serialVersionUID = -348688657801200826L;
        
        public NotDirectory( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }


    public static class NotAFile extends ConfigurationException
    {
        private static final long serialVersionUID = -6104353214119208388L;
        
        public NotAFile( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }
    public static class NotADirectory extends ConfigurationException
    {
        private static final long serialVersionUID = 3299637904535594472L;
        
        public NotADirectory( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }



    public static class UnexpectedElement extends ConfigurationException
    {
        private static final long serialVersionUID = 7361308977824266323L;
        
        public UnexpectedElement( String found, String source, int line )
        {
            super( null, source, line );
            this.found = found;
        }
        public String found;
    }
    public static class IncorrectElement extends ConfigurationException
    {
        private static final long serialVersionUID = -2038447202094268310L;
        
        public IncorrectElement( String expected, String found, String source, int line )
        {
            super( null, source, line );
            this.expected = expected;
            this.found = found;
        }
        public String expected;
        public String found;
    }




    public static class UnexpectedCDATA extends ConfigurationException
    {
        private static final long serialVersionUID = 7860440395272751620L;

        public UnexpectedCDATA( String source, int line )
        {
            super( null, source, line );
        }
    }

    // "I came here for an argument!"
    // "No you didn't."
    public static class MissingArgument extends ConfigurationException
    {
        private static final long serialVersionUID = -5463734098797737741L;
        
        public MissingArgument( String argument, String var, String source, int line )
        {
            super( var, source, line );
            this.argument = argument;
        }
        public String argument;
    }

    public static class UnexpectedArgument extends ConfigurationException
    {
        private static final long serialVersionUID = -8845402586579325956L;
        
        public UnexpectedArgument( String expected, String argument, String var, String source, int line )
        {
            super( var, source, line );
            this.expected = expected;
            this.argument = argument;
        }
        public String argument;
        public String expected;
    }
    public static class BadAppendValue extends ConfigurationException
    {
        private static final long serialVersionUID = 1552561566382094415L;

        public BadAppendValue( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    
    public static class BadVersion extends ConfigurationException
    {
        private static final long serialVersionUID = 5226991469529337229L;

        public BadVersion( String version, String var)
        {
            super( var, null, -1);
            this.version = version;
        }
        
        public String version;
    }

    
    public static class FileTooBig extends ConfigurationException
    {
        private static final long serialVersionUID = -786476651372253779L;
        
        public FileTooBig( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }
    
    public static class BadDefinition extends ConfigurationException
    {
        private static final long serialVersionUID = -325852269490101058L;
        
        public BadDefinition( String argument, String var, String source, int line )
        {
            super( var, source, line );
            this.argument = argument;
        }
        public String argument;
    }
    
	public static class BadFrameParameters extends ConfigurationException
    {
        private static final long serialVersionUID = -2323511087396160382L;
    
        public BadFrameParameters( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class GreaterThanZero extends ConfigurationException
    {
        private static final long serialVersionUID = 3912071331977316395L;
    
        public GreaterThanZero( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class MustSpecifyTarget extends ConfigurationException
    {
        private static final long serialVersionUID = 9112152606473481404L;
    
        public MustSpecifyTarget( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class NoSwcInputs extends ConfigurationException
    {
        private static final long serialVersionUID = 3980913434019979144L;
    
        public NoSwcInputs( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class OnlyOneSource extends ConfigurationException
    {
        private static final long serialVersionUID = 1234968103239361023L;
    
        public OnlyOneSource( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class CouldNotCreateConfig extends ConfigurationException
    {
        private static final long serialVersionUID = -6969824220592565605L;
    
        public CouldNotCreateConfig( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class BadMetadataCombo extends ConfigurationException
    {
        private static final long serialVersionUID = 3406393415937431348L;
    
        public BadMetadataCombo( String var, String source, int line )
        {
            super( var, source, line );
        }
    }
    public static class IllegalDimensions extends ConfigurationException
    {
        private static final long serialVersionUID = -7259122437168158126L;
        public IllegalDimensions( int width, int height, String var, String source, int line )
        {
            super( var, source, line );
            this.width = width;
            this.height = height;
        }
        public int width;
        public int height;
    }
    public static class CannotOpen extends ConfigurationException
    {
        private static final long serialVersionUID = -7773063809601129906L;
        public CannotOpen( String path, String var, String source, int line )
        {
            super(var, source, line );
            this.path = path;
        }
        public String path;
    }
    public static class UnknownNamespace extends ConfigurationException
    {
        private static final long serialVersionUID = -5393732592631516166L;
        public UnknownNamespace( String ns, String var, String source, int line )
        {
            super( var, source, line );
            this.namespace = ns;
        }
        public String namespace;
    }
    public static class DirectoryNotEmpty extends ConfigurationException
    {
        private static final long serialVersionUID = 359443368875780282L;
        public DirectoryNotEmpty( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }
    public static class RedundantFile extends ConfigurationException
    {
        private static final long serialVersionUID = -6206003786362484586L;
        public RedundantFile( String path, String var, String source, int line )
        {
            super( var, source, line );
            this.path = path;
        }
        public String path;
    }
    public static class ObsoleteVariable extends ConfigurationException
    {
        private static final long serialVersionUID = 3622916477413320447L;
        public ObsoleteVariable( String replacement, String var, String source, int line )
        {
            super( var, source, line );
            this.replacement = replacement;
        }
        public String replacement;
    }
    public static class NoASDocInputs extends ConfigurationException
    {
        private static final long serialVersionUID = 2151330864688948051L;
    
        public NoASDocInputs()
        {
            super( null, null, -1 );
        }
    }
    public static class BadExcludeDependencies extends ConfigurationException
    {
        private static final long serialVersionUID = -8463049402307139110L;
    
        public BadExcludeDependencies()
        {
            super( null, null, -1 );
        }
    }

    public static class NamespaceMissingManifest extends ConfigurationException
    {
        private static final long serialVersionUID = 1840362182782082436L;

        public NamespaceMissingManifest(String var, String source, int line)
        {
            super(var, source, line);
        }
    }

    public static class ToolsLocaleNotAvailable extends ConfigurationException
    {
        private static final long serialVersionUID = 1840362182782082437L;

        public ToolsLocaleNotAvailable(String var, String source, int line)
        {
            super(var, source, line);
        }
    }

    /**
     *  Error for when -include-inheritance-dependencies-only is true but -include-classes does
     *  not specify any classes. 
     *
     */
    public static class MissingIncludeClasses extends ConfigurationException
    {
        private static final long serialVersionUID = 1631608860338388417L;

        public MissingIncludeClasses()
        {
            super( null, null, -1);
        }
    }

    /**
     *  The user was trying to modify an RSL option associated with a SWC but the SWC had
     *  no RSL data. 
     *
     */
    public static class SwcDoesNotHaveRslData extends ConfigurationException
    {
        private static final long serialVersionUID = 8048448308683132926L;

        public SwcDoesNotHaveRslData(String swcPath, String var, String source, int line)
        {
            super(var, source, line);
            this.swcPath = swcPath;
        }
        
        public String swcPath;
    }

    /**
     *  The application domain specified did not match one of the possible values.
     *
     */
    public static class BadApplicationDomainValue extends ConfigurationException
    {
        private static final long serialVersionUID = -3575875352932278137L;

        public BadApplicationDomainValue(String swcPath, String argument, String var, String source, int line)
        {
            super(var, source, line);
            this.swcPath = swcPath;
            this.argument = argument;
        }
        
        public String swcPath;
        public String argument;
    }

    public String getMessage()
	{
		String msg = super.getMessage();
		if (msg != null && msg.length() > 0)
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
}
