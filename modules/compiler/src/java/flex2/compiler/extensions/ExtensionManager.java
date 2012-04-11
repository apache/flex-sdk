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

package flex2.compiler.extensions;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.jar.JarFile;
import java.util.jar.Manifest;

import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage.CompilerError;

/**
 * This class manages external extensions, which can be used to add
 * additional functionality to the compiler.
 *
 * @author Andrew Westberg
 */
public class ExtensionManager
{

    public static enum ExtensionType
    {
        PRELINK( "extensions-prelink" ), MXMLC( "extensions-mxmlc" ), COMPC( "extensions-compc" ), APPLICATION(
            "extensions-application" ), LIBRARY( "extensions-library" ), PRE_COMPILE( "extensions-pre-compile" );

        private String extensionTag;

        private ExtensionType( String extensionTag )
        {
            this.extensionTag = extensionTag;
        }

        String getExtensionTag()
        {
            return extensionTag;
        }
    }

    public static Set<IPreLinkExtension> getPreLinkExtensions( Map<String, List<String>> extensions )
    {
        return getExtension( ExtensionType.PRELINK, extensions, IPreLinkExtension.class );
    }

    public static Set<IMxmlcExtension> getMxmlcExtensions( Map<String, List<String>> extensions )
    {
        return getExtension( ExtensionType.MXMLC, extensions, IMxmlcExtension.class );
    }

    public static Set<ICompcExtension> getCompcExtensions( Map<String, List<String>> extensions )
    {
        return getExtension( ExtensionType.COMPC, extensions, ICompcExtension.class );
    }

    public static Set<ILibraryExtension> getLibraryExtensions( Map<String, List<String>> extensions )
    {
        return getExtension( ExtensionType.LIBRARY, extensions, ILibraryExtension.class );
    }

    public static Set<IApplicationExtension> getApplicationExtensions( Map<String, List<String>> extensions )
    {
        return getExtension( ExtensionType.APPLICATION, extensions, IApplicationExtension.class );
    }

    public static Set<IPreCompileExtension> getPreCompileExtensions( Map<String, List<String>> extensions )
    {
        return getExtension( ExtensionType.PRE_COMPILE, extensions, IPreCompileExtension.class );
    }

    @SuppressWarnings( "deprecation" )
    private static <E> Set<E> getExtension( ExtensionType extensionType, Map<String, List<String>> availableExtensions,
                                            Class<E> clazz )
    {
        if ( availableExtensions == null )
        {
            return Collections.emptySet();
        }

        Set<String> files = availableExtensions.keySet();

        Set<E> extensions = new LinkedHashSet<E>();

        for ( String extensionPath : files )
        {
            List<String> parameters = availableExtensions.get( extensionPath );

            File extensionFile = new File( extensionPath );
            if ( !extensionFile.exists() )
            {
                ThreadLocalToolkit.getLogger().log(new InvalidExtensionFileError(new FileNotFoundException().getLocalizedMessage() ) );
                continue;
            }

            try
            {
                URLClassLoader loader;
                Manifest mf;
                try
                {
                    loader = new URLClassLoader( new URL[] { extensionFile.toURL() },
                                                 Thread.currentThread().getContextClassLoader() );
                    JarFile jar = new JarFile( extensionFile );
                    mf = jar.getManifest();
                }
                catch ( IOException e )
                {
                    ThreadLocalToolkit.getLogger().log( new InvalidExtensionFileError( e.getLocalizedMessage() ) );
                    continue;
                }
                extensions.addAll( getClasses( mf, extensionType, loader, parameters, clazz ) );
            }
            catch ( CompilerError e )
            {
                ThreadLocalToolkit.getLogger().log( e );
                continue;
            }
        }

        return extensions;
    }

    @SuppressWarnings( "unchecked" )
    private static <E> Set<E> getClasses( Manifest mf, ExtensionType extensionType, URLClassLoader loader,
                                          List<String> parameters, Class<E> clazz )
        throws CompilerError
    {
        String extensionsStr = mf.getMainAttributes().getValue( extensionType.getExtensionTag() );

        if ( extensionsStr == null )
        {
            return Collections.emptySet();
        }

        String[] extNames = extensionsStr.split( ":" );

        Set<E> extensions = new LinkedHashSet<E>();

        for ( int j = 0; j < extNames.length; j++ )
        {
            String extName = extNames[j];
            Class<?> extClass;

            try
            {
                extClass = loader.loadClass( extName );
            }
            catch ( ClassNotFoundException e )
            {
                throw new UnexistentExtensionError( extName );
            }

            if ( clazz.isAssignableFrom( extClass ) )
            {
                E extInstance;
                try
                {
                    extInstance = (E) extClass.newInstance();
                }
                catch ( Exception e )
                {
                    throw new FailToInstanciateError( e.getMessage() );
                }

                if ( extInstance instanceof IConfigurableExtension )
                {
                    IConfigurableExtension configExtension = (IConfigurableExtension) extInstance;
                    configExtension.configure( parameters );
                }
                extensions.add( extInstance );
            }
            else
            {
                throw new InvalidExtensionKindError( extClass, clazz );

            }
        }

        return extensions;
    }

    public static class InvalidExtensionFileError
        extends CompilerError
    {
        private static final long serialVersionUID = -1466423208365841681L;

        public String errorMessage;

        public InvalidExtensionFileError( String errorMessage )
        {
            this.errorMessage = errorMessage;
        }
    }

    public static class FailToInstanciateError
        extends CompilerError
    {
        private static final long serialVersionUID = -4329041275278609962L;

        public String errorMessage;

        public FailToInstanciateError( String errorMessage )
        {
            this.errorMessage = errorMessage;
        }
    }

    public static class UnexistentExtensionError
        extends CompilerError
    {
        private static final long serialVersionUID = 7778107370187386124L;

        public String extensionClassName;

        public UnexistentExtensionError( String extName )
        {
            this.extensionClassName = extName;
        }
    }

    public static class InvalidExtensionKindError
        extends CompilerError
    {
        private static final long serialVersionUID = -3190757647243331631L;

        public Class<?> extensionClass;

        public Class<?> parentClass;

        public InvalidExtensionKindError( Class<?> extClass, Class<?> clazz )
        {
            this.extensionClass = extClass;
            this.parentClass = clazz;
        }
    }
}
