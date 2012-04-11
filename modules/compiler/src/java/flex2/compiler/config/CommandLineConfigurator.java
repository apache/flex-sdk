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

import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;
import java.util.TreeSet;
import java.util.Set;
import java.util.Iterator;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.io.File;

/**
 * A utility class, which is used to parse an array of command line
 * args and populate a ConfigurationBuffer.  It also contains some
 * associated methods like brief() and usage().  A counterpart of
 * FileConfigurator and SystemPropertyConfigurator.
 *
 * @author Roger Gonzalez
 */
public class CommandLineConfigurator
{
	public static final String SOURCE_COMMAND_LINE = "command line";
	
    /**
     * parse - buffer up configuration vals from the command line
     *
     * @param buffer        the configuration buffer to hold the results
     * @param defaultvar    the variable name where the trailing loose args go
     * @param args          the command line
     * @throws ConfigurationException
     */
    public static void parse( final ConfigurationBuffer buffer,
                              final String defaultvar,
                              final String[] args)
            throws ConfigurationException
    {
        assert defaultvar == null || buffer.isValidVar( defaultvar ) : "coding error: config must provide default var " + defaultvar;

        Map<String, String> aliases = getAliases( buffer );
        final int START = 1;
        final int ARGS = 2;
        final int EXEC = 3;
        final int DONE = 4;


        int i = 0, iStart = 0, iEnd = 0;
        String var = null;
        int varArgCount = -2;
        List<String> argList = new LinkedList<String>();
        Set<String> vars = new HashSet<String>();
        boolean append = false;
        boolean dash = true;

        int mode = START;

        while (mode != DONE)
        {
            switch (mode)
            {
                case START:
                {
                	iStart = i;
                	
                    if (args.length == i)
                    {
                        mode = DONE;
                        break;
                    }
                    // expect -var, --, or the beginning of default args

                    mode = ARGS;
                    varArgCount = -2;

                    if (args[i].equals("--"))
                    {
                        dash = false;
                        if (defaultvar != null)
                            var = defaultvar;
                        else
                            mode = START;
                        ++i;
                    }
                    else if (dash && args[i].startsWith("+"))
                    {
                        String token = null;
                        int c = (args[i].length() > 1 && args[i].charAt( 1 ) == '+')? 2 : 1;    // gnu-style?

                        int equals = args[i].indexOf( '=' );
                        String rest = null;
                        if (equals != -1)
                        {
                            rest = args[i].substring( equals + 1 );
                            token = args[i++].substring( c, equals );
                        }
                        else
                        {
                            token = args[i++].substring( c );
                        }
                        if (equals != -1)
                        {
                        	iEnd = i;
                            buffer.setToken( token, rest );
                            buffer.addPosition(token, iStart, iEnd);
                        }
                        else
                        {
                            if (i == args.length)
                            {
                                throw new ConfigurationException.Token( ConfigurationException.Token.INSUFFICIENT_ARGS,
                                                                        token, var, source, -1 );
                            }
                            rest = args[i++];
                            iEnd = i;
                            buffer.setToken( token, rest );
                            buffer.addPosition(token, iStart, iEnd);
                        }
                        mode = START;
                        break;
                    }
                    else if (dash && isAnArgument(args[i]))
                    {
                        int c = (args[i].length() > 1 && args[i].charAt( 1 ) == '-')? 2 : 1;    // gnu-style?

                        int plusequals = args[i].indexOf( "+=" );
                        int equals = args[i].indexOf( '=' );
                        String rest = null;
                        if (plusequals != -1)
                        {
                            rest = args[i].substring( plusequals + 2 );
                            var = args[i++].substring( c, plusequals );
                            append = true;
                        }
                        else if (equals != -1)
                        {
                            rest = args[i].substring( equals + 1 );
                            var = args[i++].substring( c, equals );
                        }
                        else
                        {
                            var = args[i++].substring( c );
                        }

                        if (aliases.containsKey( var ))
                            var = aliases.get( var );

                        if (!buffer.isValidVar( var ))
                        {
                            throw new ConfigurationException.UnknownVariable( var, source, -1 );
                        }

                        if (equals != -1)
                        {
                            if ((rest == null) || (rest.length() == 0))
                            {
                            	iEnd = i;
                                buffer.clearVar( var, source, -1 );
                                buffer.addPosition(var, iStart, iEnd);
                                mode = START;
                            }
                            else
                            {
                                String seps = null;
                                if (buffer.getInfo(var).isPath())
                                {
                                    seps = "[," + File.pathSeparatorChar + "]";
                                }
                                else {
                                	seps = ",";
                                }
                                
                                String[] tokens = rest.split(seps);
                                argList.addAll(Arrays.asList(tokens));
                                varArgCount = buffer.getVarArgCount( var );
                                mode = EXEC;
                            }
                        }

                    }
                    else
                    {
                        // asdoc sets default var as no-default-arg - it has no default vars
                        if (defaultvar != null  && !defaultvar.equals("no-default-arg"))
                        {
                            // don't increment i, let ARGS pick it up.
                            var = defaultvar;
                        }
                        else
                        {
                            throw new ConfigurationException.UnexpectedDefaults( null, null, -1 );
                        }
                    }
                    break;
                }
                case ARGS:
                {
                    if (varArgCount == -2)
                    {
                        if (isBoolean( buffer, var ))
                        {
                            varArgCount = 0;
                            mode = EXEC;
                            break;
                        }
                        else
                        {
                            varArgCount = buffer.getVarArgCount( var );
                        }
                    }
                    assert varArgCount >= -1;   // just in case the getVarArgCount author was insane.

                    if (args.length == i)
                    {
                        mode = EXEC;
                        break;
                    }

                    boolean greedy = buffer.getInfo( var ).isGreedy();

                    // accumulating non-command arguments...

                    
                    // check for a terminator on our accumulated parameter list
                    if (!greedy && dash && isAnArgument(args[i]))
                    {
                        if (varArgCount == -1)
                        {
                            // we were accumulating an unlimited set of args, a new var terminates that.
                            mode = EXEC;
                            break;
                        }
                        throw new ConfigurationException.IncorrectArgumentCount( varArgCount, argList.size(), var, source, -1 );
                    }

                    // this test is a little hairy:
                    //    "The key is that the parameter before the "default" parameter takes an
                    //     unlimited number of parameters: mxmlc -rsl 1.swf 2.swf test.mxml" -dloverin
                    if ((varArgCount == -1)
                            && !greedy
                            && (defaultvar != null)
                            && !defaultvar.equals(var)
                            && !vars.contains( defaultvar )
                            && ((args.length - i) > 1)
                            && buffer.getInfo( defaultvar ) != null)
                    {
                        // look for a terminating argument, if none,
                        // then the end of the list cannot be determined (it's ambiguous)
                        boolean ok = false;
                        for (int j = i + 1; j < args.length; ++j)
                        {
                            if (dash && isAnArgument(args[j]))
                            {
                                ok = true;
                                break;
                            }
                        }
                        if (!ok)
                        {
                            throw new ConfigurationException.AmbiguousParse( defaultvar, var, source, -1 );
                        }
                    }

                    argList.add( args[i++] );
                    if (argList.size() == varArgCount)
                    {
                        mode = EXEC;
                    }

                    break;
                }
                case EXEC:
                {
                    if ((varArgCount != -1) && (argList.size() != varArgCount))
                    {
                        throw new ConfigurationException.IncorrectArgumentCount( varArgCount, argList.size(), var, source, -1 );
                    }
                    if (varArgCount == 0)       // boolean flag fakery...
                        argList.add( "true" );

                    if (vars.contains( var ))
                    {
                        if ((defaultvar != null) && var.equals( defaultvar ))
                        {
                            // we could perhaps accumulate the defaults spread out through
                            // the rest of the flags, but for now we'll call this illegal.
                            throw new ConfigurationException.InterspersedDefaults( var, source, -1 );
                        }
                    }
                    iEnd = i;
                    buffer.setVar( var, new LinkedList<String>( argList ), source, -1, null, append );
                    buffer.addPosition(var, iStart, iEnd);
                    append = false;
                    vars.add( var );
                    argList.clear();
                    mode = START;
                    break;
                }
                case DONE:
                {
                    assert false;
                    break;
                }
            }
        }
    }
    
    /**
     * Given a string like "-foo" or "-5" or "-123.mxml", this determines whether
     * the string is an argument or... not an argument (e.g. numeral)
     */
    private static boolean isAnArgument(final String arg)
    {
        return (arg.startsWith("-") &&
                // if the first character after a dash is numeric, this is not
                // an argument, it is a parameter (and therefore non-terminating)
               (arg.length() > 1) && !Character.isDigit(arg.charAt(1)));
    }
    
    private static Map<String, String> getAliases( ConfigurationBuffer buffer )
    {
        Map<String, String> aliases = new HashMap<String, String>();
        aliases.putAll( buffer.getAliases() );
        for (Iterator it = buffer.getVarIterator(); it.hasNext(); )
        {
            String varname = (String) it.next();

            if (varname.indexOf( '.' ) == -1)
                continue;

            String leafname = varname.substring( varname.lastIndexOf( '.' ) + 1 );
            if (aliases.containsKey( leafname ))
                continue;
            aliases.put( leafname, varname );
        }

        return aliases;
    }

    private static boolean isBoolean( ConfigurationBuffer buffer, String var )
    {
        ConfigurationInfo info = buffer.getInfo( var );

        if (info.getArgCount() > 1)
            return false;

        Class c = info.getArgType( 0 );

        return ((c == boolean.class) || (c == Boolean.class));
    }

    public static String brief( String program, String defaultvar, LocalizationManager l10n, String l10nPrefix )
    {
        Map<String, String> params = new HashMap<String, String>();
        params.put( "defaultVar", defaultvar );
        params.put( "program", program );
        return l10n.getLocalizedTextString( l10nPrefix + ".Brief", params );
    }

    static public String usage( String program, String defaultVar, ConfigurationBuffer cfgbuf, Set<String> keywords, LocalizationManager lmgr, String l10nPrefix )
    {
        // FIXME (probably a FOL, unfortunately) - this is totally biased to western languages.

        Map<String, String> aliases = getAliases( cfgbuf );

        Map<String, String> sesaila = new HashMap<String, String>();
        for (Iterator<Map.Entry<String, String>> it = aliases.entrySet().iterator(); it.hasNext();)
        {
            Map.Entry<String, String> e = it.next();
            sesaila.put( e.getValue(), e.getKey() );
        }

        TreeSet<String> printSet = new TreeSet<String>();

        boolean all = false;
        boolean advanced = false;
        boolean details = false;
        boolean syntax = false;
        boolean printaliases = false;

        // figure out behavior..
        Set<String> newSet = new HashSet<String>();
        for (Iterator<String> kit = keywords.iterator(); kit.hasNext();)
        {
            String keyword = kit.next();

            if (keyword.equals( "list" ))
            {
                all = true;
                newSet.add( "*" );
            }
            else if (keyword.equals( "advanced" ))
            {
                advanced = true;
                if (keywords.size() == 1)
                {
                    all = true;
                    newSet.add( "*" );
                }
            }
            else if (keyword.equals( "details" ))
            {
                details = true;
            }
            else if (keyword.equals( "syntax" ))
            {
                syntax = true;
            }
            else if (keyword.equals( "aliases" ))
            {
                printaliases = true;
            }
            else
            {
                details = true;
                newSet.add( keyword );
            }
        }
        if (syntax)
        {
            List lines = ConfigurationBuffer.formatText( getSyntaxDescription( program, defaultVar, advanced, lmgr,  l10nPrefix ), 78 );
            StringBuilder text = new StringBuilder( 512 );
            for (Iterator it = lines.iterator(); it.hasNext();)
            {
                text.append( it.next() );
                text.append( "\n" );
            }
            return text.toString();
        }
        keywords = newSet;

        // accumulate set to print
        for (Iterator<String> kit = keywords.iterator(); kit.hasNext();)
        {
            String keyword = kit.next().toLowerCase();

            for (Iterator varit = cfgbuf.getVarIterator(); varit.hasNext(); )
            {
                String var = (String) varit.next();
                ConfigurationInfo info = cfgbuf.getInfo( var );

                String description = getDescription( cfgbuf, var, lmgr, l10nPrefix);

                if ((all
                        || (var.indexOf( keyword ) != -1)
                        || ((description != null) && (description.toLowerCase().indexOf( keyword ) != -1))
                        || (keyword.matches( var ) )
                        || ((sesaila.get( var ) != null) && (sesaila.get( var )).indexOf( keyword ) != -1))
                     && (!info.isHidden())
                     && (advanced || !info.isAdvanced()))
                {
                    if (printaliases && sesaila.containsKey( var ))
                        printSet.add( sesaila.get( var ));
                    else
                        printSet.add( var );
                }
                else
                {
                    /*
                    for (int i = 0; i < info.getAliases().length; ++i)
                    {
                        String alias = info.getAliases()[i];
                        if (alias.indexOf( keyword ) != -1)
                        {
                            printSet.add( var );
                        }
                    }
                    */
                }
            }
        }

        StringBuilder output = new StringBuilder( 1024 );

        if (printSet.size() == 0)
        {
            String nkm = lmgr.getLocalizedTextString( l10nPrefix + ".NoKeywordsMatched" );
            output.append( nkm );
            output.append( "\n" );
        }
        else for (Iterator<String> it = printSet.iterator(); it.hasNext();)
        {
            String avar = it.next();
            String var = avar;
            if (aliases.containsKey( avar ))
                var = aliases.get( avar );

            ConfigurationInfo info = cfgbuf.getInfo( var );
            assert info != null;

            output.append( "-" );
            output.append( avar );

            int count = cfgbuf.getVarArgCount( var );
            if ((count >= 1) && (!isBoolean( cfgbuf, var )))
            {
                for (int i = 0; i < count; ++i)
                {
                    output.append( " <" );
                    output.append( cfgbuf.getVarArgName( var, i ) );
                    output.append( ">" );
                }
            }
            else if (count == -1)
            {
                String last = "";
                for (int i = 0; i < 5; ++i)
                {
                    String argname = cfgbuf.getVarArgName( var, i );
                    if (!argname.equals( last ))
                    {
                        output.append( " [" );
                        output.append( argname );
                        output.append( "]" );
                        last = argname;
                    }
                    else
                    {
                        output.append( " [...]" );
                        break;
                    }
                }
            }

            output.append( "\n" );

            if (details)
            {
                StringBuilder description = new StringBuilder( 160 );
                if (printaliases)
                {
                    if (aliases.containsKey( avar ))
                    {
                        String fullname = lmgr.getLocalizedTextString( l10nPrefix + ".FullName" );
                        description.append( fullname );
                        description.append( " -" );
                        description.append( aliases.get( avar ));
                        description.append( "\n" );
                    }
                }
                else if (sesaila.containsKey( var ))
                {
                    String alias = lmgr.getLocalizedTextString( l10nPrefix + ".Alias" );
                    description.append( alias );
                    description.append( " -" );
                    description.append( sesaila.get( var ));
                    description.append( "\n" );
                }

                String d = getDescription(cfgbuf, var, lmgr, l10nPrefix);
                if (var.equals( "help" ) && (printSet.size() > 2))
                {
                    String helpKeywords = lmgr.getLocalizedTextString( l10nPrefix + ".HelpKeywords" );
                    description.append( helpKeywords );
                }
                else if (d != null)
                    description.append( d );

                String flags = "";
                if (info.isAdvanced())
                {
                    String advancedString = lmgr.getLocalizedTextString( l10nPrefix + ".Advanced" );
                    flags += (((flags.length() == 0)? " (" : ", ") + advancedString );
                }
                if (info.allowMultiple())
                {
                    String repeatableString = lmgr.getLocalizedTextString( l10nPrefix + ".Repeatable" );
                    flags += (((flags.length() == 0)? " (" : ", ") + repeatableString );
                }
                if ((defaultVar != null) && var.equals( defaultVar ))
                {
                    String defaultString = lmgr.getLocalizedTextString( l10nPrefix + ".Default" );
                    flags += (((flags.length() == 0)? " (" : ", ") + defaultString );
                }
                if (flags.length() != 0)
                {
                    flags += ")";
                }
                description.append( flags );


                List descriptionLines = ConfigurationBuffer.formatText( description.toString(), 70 );

                for (Iterator descit = descriptionLines.iterator(); descit.hasNext();)
                {
                    output.append( "    " );
                    output.append( (String) descit.next() );
                    output.append( "\n" );
                }
            }
        }
        return output.toString();
    }

    public static String getDescription( ConfigurationBuffer buffer, String var, LocalizationManager l10n, String l10nPrefix )
    {
        String key = (l10nPrefix == null)? var : (l10nPrefix + "." + var);
        String description = l10n.getLocalizedTextString( key, null );

        return description;
    }

    public static String getSyntaxDescription( String program, String defaultVar, boolean advanced, LocalizationManager l10n, String l10nPrefix )
    {
        Map<String, String> params = new HashMap<String, String>();
        params.put("defaultVar", defaultVar);
        params.put("program", program);

        String key = l10nPrefix + "." + (advanced? "AdvancedSyntax" : "Syntax");
        String text = l10n.getLocalizedTextString( key, params );

        if (text == null)
        {
            text = "No syntax help available, try '-help list' to list available configuration variables.";
            assert false : "Localized text for syntax description not found!";
        }
        return text;
    }

    public static final String source = SOURCE_COMMAND_LINE;
}
