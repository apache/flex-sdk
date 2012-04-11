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

import java.lang.reflect.Method;
import java.lang.reflect.Field;

import flex2.compiler.util.CompilerMessage;

/**
 * The base class used for get*Info() methods.  It allows
 * configuration objects to provide information about a configuration
 * option.  For example, whether it's hidden, deprecated, advanced,
 * etc.  Subclasses should override ConfigurationInfo's methods to
 * change the defaults.
 *
 * @author Roger Gonzalez
 */
public class ConfigurationInfo
{
    /**
     * This ctor is used when everything can be introspected off the setter method, or else
     * when the names/types are provided by method overrides rather than ctor arguments
     */
    public ConfigurationInfo()
    {
        this.argcount = -2;
        this.argnames = null;
    }
    /**
     * Simple ctor for restricting the number of arguments.
     * @param argcount number of args, -1 for an infinite list
     */
    public ConfigurationInfo( int argcount )
    {
        this.argcount = argcount;
        this.argnames = null;
    }
    /**
     * Simple ctor for naming the arguments.
     * @param argnames list of argnames, argcount will default to # of elements
     */
    public ConfigurationInfo( String argnames[] )
    {
        this.argcount = argnames.length;
        this.argnames = argnames;
    }
    /**
     * Use this ctor when you want to set a single list of some number of identically named args
     * @param argcount number of arguments (-1 for infinite)
     * @param argname name of each argument
     */
    public ConfigurationInfo( int argcount, String argname )
    {
        this.argcount = argcount;
        this.argnames = new String[]{ argname };
    }
    /**
     * More unusual ctor, this would let you have the first few args named one thing, the rest named something else.
     * It is far more likely that you want a constrained list of names or else an arbitrary list of identical names.
     * @param argcount number of arguments
     * @param argnames array of argument names
     */
    public ConfigurationInfo( int argcount, String argnames[] )
    {
        this.argcount = argcount;
        this.argnames = argnames;
    }
    public final int getArgCount()
    {
        return argcount;
    }
    private int argcount = -2;

    private static String classToArgName( Class c )
    {
        // we only support builtin classnames!

        String className = c.getName();
        if (className.startsWith( "java.lang." ))
            className = className.substring( "java.lang.".length() );

        return className.toLowerCase();
    }

    /**
     * Return the name of each parameter.  The default implementation is usually
     * sufficient for simple cases, but one could do wacky things here like support
     * an infinite list of alternating arg names.
     * @param argnum
     * @return name of argument
     */
    public String getArgName( int argnum )
    {
        if ((argnames == null) || (argnames.length == 0))
        {
            return classToArgName( getArgType( argnum ) );
        }
        else if (argnum >= argnames.length)
        {
            return argnames[argnames.length-1];
        }
        else
        {
            return argnames[argnum];
        }
    }
    /**
     * Return the type of each parameter.  This is computed based on your setter,
     * and cannot be overridden
     * @param argnum
     */
    public final Class getArgType( int argnum )
    {
        if (argnum >= argtypes.length)
        {
            return argtypes[argtypes.length-1];
        }
        else
        {
            return argtypes[argnum];
        }
    }
    private String[] argnames;

    private Class[] argtypes;

    /**
     * Return variable names that should be set before this one.
     * The buffer is always set such that it tries to set all variables
     * at a given level before setting child values, but you could override
     * by using this.  Its probably a bad idea to depend on children, though.
     * It is unnecessary to set parent vars as prerequisites, since they are
     * implicitly set first
     */
    public String[] getPrerequisites()
    {
        return null;
    }

	/**
	 * Prerequisites which should be set before this one if they exist
	 */
	public String[] getSoftPrerequisites()
	{
		return null;
	}

	/**
     * Variables are generally only allowed to be set once in a given file/cmdline.
     * It is sometimes useful to allow the same set multiple times in order to
     * aggregate values.
     * @return true if the setter can be called multiple times
     */
    public boolean allowMultiple()
    {
        return false;
    }

    /**
     * Return an array of other names for this variable.
     */
    public String[] getAliases()
    {
        return null;
    }

    /**
     * Override to make a variable hidden by default (i.e. you need -advanced on the cmdline)
     */
    public boolean isAdvanced()
    {
        return false;
    }

	/**
	 * Override to make a variable completely hidden
	 */
	public boolean isHidden()
	{
	    return false;
	}

    /**
     * Override to prevent printing when dumping configuration
     */
    public boolean isDisplayed()
    {
        return true;
    }

    /**
     * If a variable -must- be set, override this
     */
    public boolean isRequired()
    {
        return false;
    }

    /**
     * Magic used by the command line configurator only at the moment to decide whether this
     * variable should eat all subsequent arguments.  Useful for -help... 
     */
    public boolean isGreedy()
    {
        return false;
    }

    public boolean isPath()
    {
        return false;
    }
    
    public boolean doChecksum()
    {
    	return true;
    }

    public CompilerMessage.CompilerWarning getDeprecatedMessage()
    {
    	return null;
    }
    
    public boolean isDeprecated()
    {
    	return false;
    }
    
    public String getDeprecatedReplacement()
    {
    	return null;
    }
    
    public String getDeprecatedSince()
    {
    	return null;
    }
    
    protected final void setSetterMethod( Method setter )
    {
        Class[] pt = setter.getParameterTypes();

        assert ( pt.length >= 2 ) : ( "coding error: config setter must take at least 2 args!" );

        this.setter = setter;

        if (pt.length == 2)
        {
            Class c = pt[1];

            if (ConfigurationBuffer.isSupportedListType( c ))
            {
                if (argcount == -2)
                    argcount = -1;      // infinite list

                argtypes = new Class[] {String.class};
                return;
            }
            else if (ConfigurationBuffer.isSupportedValueType( c ))
            {
                assert ( argcount == -2 ) : ( "coding error: value object setter cannot override argcount" );
                assert ( argnames == null) : ( "coding error: value object setter cannot override argnames" );

                Field[] fields = c.getFields();

                argcount = fields.length;

                assert ( argcount > 0 ) : ( "coding error: " + setter + " value object " + c.getName() + " must contain at least one public field" );

                argnames = new String[fields.length];
                argtypes = new Class[fields.length];

                for (int f = 0; f < fields.length; ++f)
                {
                    argnames[f] = ConfigurationBuffer.c2h( fields[f].getName() );
                    argtypes[f] = fields[f].getType();
                }
                return;
            }
        }

        assert ( (argcount == -2) || (argcount == pt.length - 1) ) : ( "coding error: the argument count must match the number of setter arguments" );
        // We've taken care of lists and value objects, from here on out, it must match the parameter list.

        argcount = pt.length - 1;

        argtypes = new Class[pt.length - 1];
        for (int i = 1; i < pt.length; ++i)
        {
            assert ( ConfigurationBuffer.isSupportedSimpleType( pt[i] ) ) :
                                  ( "coding error: " + setter.getClass().getName() + "." + setter.getName() + " parameter " + i + " is not a supported type!" );
            argtypes[i-1] = pt[i];
        }
    }

    protected final Method getSetterMethod()
    {
        return setter;
    }

    private Method setter;
	private Method getter;

	protected final void setGetterMethod( Method getter )
	{
		this.getter = getter;
	}

	protected final Method getGetterMethod()
	{
	    return getter;
	}
}

