////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.utils
{

[ExcludeClass]

/**
 *  @private
 *
 *  The DirectoryEnumerationMode class defines the constant values
 *  for the <code>enumerationMode</code> property
 *  of the DirectoryEnumeration class.
 *
 *  @see mx.utils.DirectoryEnumeration#enumerationMode
 * 
 */
public final class DirectoryEnumerationMode
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  Specifies to show files but not directories.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const FILES_ONLY:String = "filesOnly";
    
    /**
     *  Specifies to show directories but not files.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const DIRECTORIES_ONLY:String = "directoriesOnly";
    
    /**
     *  Specifies to show files first, then directories.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const FILES_FIRST:String = "filesFirst";
    
    /**
     *  Specifies to show directories, then files.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const DIRECTORIES_FIRST:String = "directoriesFirst";
    
    /**
     *  Specifies to show both files and directories, mixed together.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
     public static const FILES_AND_DIRECTORIES:String = "filesAndDirectories";
}

}
