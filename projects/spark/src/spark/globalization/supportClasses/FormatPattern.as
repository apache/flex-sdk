////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
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
        this.locales = new Object();
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
