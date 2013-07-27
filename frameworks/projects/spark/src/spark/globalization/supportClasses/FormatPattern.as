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

package spark.globalization.supportClasses
{
[ExcludeClass]

/**
 *  <code>FormatPattern</code> class is used by
 *  <code>DateTimeFormatterEx</code> class for its internal processing.
 *
 *  <p>This class should not be used outside of this package.</p>
 *  <p>This class is used as a data strucuture to keep a format pattern
 *  string with a set of applicable locales.</p>
 *
 *  @see utils.DateTimeFormatterEx
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
internal final class FormatPattern
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructs a new <code>FormatPattern</code> object.
     *
     *  <p>Note that the locales are supposed to be given as an
     *  <code>Array</code> as the constructor argument but they will be
     *  kept as a <code>Vector</code> in the class instance.</p>
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function FormatPattern(pattern:String, locales:Array)
    {
        super();
        this.pattern = pattern;
        this.locales = {};
        for (var i:int = 0; i < locales.length; i++)
            this.locales[locales[i]] = true;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  pattern
    //----------------------------------
    
    /**
     *  The format pattern for the correponding set of locales.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var pattern:String;
    
    //----------------------------------
    //  locales
    //----------------------------------
    
    /**
     *  The set of locales for the corresponding format pattern.
     *
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var locales:Object;
}
}
