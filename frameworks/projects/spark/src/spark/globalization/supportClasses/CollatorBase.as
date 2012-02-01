////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.globalization.supportClasses
{
    
    import flash.globalization.Collator;
    import flash.globalization.CollatorMode;
    
    import mx.core.mx_internal;
    import mx.utils.ObjectUtil;
    
    import spark.globalization.LastOperationStatus;
    import spark.globalization.supportClasses.GlobalizationBase;
    
    use namespace mx_internal;
    
    /**
     * <code>CollatorBase</code> is a base class for the
     * SortingCollator and MatchingCollator classes.
     *
     * <p>This class is a wrapper class around the
     * <code>flash.globalization.Collator</code> class.
     * Therefore the locale-specific string comparison is provided by the
     * <code>flash.globalization.Collator</code> class.
     * However by using this class as a base class, the <code>SortingCollator</code>
     * and <code>MatchingCollator</code> classes can be used in MXML declartions.
     * In these classes, the <code>locale</code> style is used for the 
     * requested Locale ID name and has methods and properties that are bindable.
     * </p>
     *
     * <p>The flash.globalization.Collator class uses the underlying operating
     * system for the formatting functionality and to supply locale
     * specific data.
     * On some operating systems, the flash.globalization classes are
     * unsupported. On these systems the wrapper class provides fallback
     * functionality for string comparison.</p>
     *
     * @see flash.globalization.Collator
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public class CollatorBase extends GlobalizationBase
    {
        include "../../core/Version.as";
        
        //--------------------------------------------------------------------------
        //
        //  Class Constants
        //
        //--------------------------------------------------------------------------
        
        // Names of common basic properties of
        // spark.utils.CollatorBase and flash.globalization.Collator
        private static const IGNORE_CASE:String = "ignoreCase";
        private static const IGNORE_CHARACTER_WIDTH:String = "ignoreCharacterWidth";
        private static const IGNORE_DIACRITICS:String = "ignoreDiacritics";
        private static const IGNORE_KANA_TYPE:String = "ignoreKanaType";
        private static const IGNORE_SYMBOLS:String = "ignoreSymbols";
        private static const NUMERIC_COMPARISON:String = "numericComparison";
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructs a new CollatorBase object to provide string comparisons
         *  according to the conventions of a specified locale.
         *
         *  <p>The <code>initialMode</code> parameter sets the initial collation
         *  options for two use cases: sorting and matching.
         *  It can be set to one of the two following values:</p>
         *
         *  <ul>
         *   <li><code>CollatorMode.SORTING</code>: sets the collation options for
         *       general linguistic sorting uses such as sorting a list of
         *       text strings that are displayed to an end user.
         *       In this mode, differences in uppercase and lowercase letters,
         *       accented characters, and other differences specific to the
         *       locale are considered when doing string comparisons.</li>
         *   <li><code>CollatorMode.MATCHING</code>: sets collation options for
         *       uses such as determining if two strings are equivalent.
         *       In this mode, differences in uppercase and lower case letters,
         *       accented characters, and so on are ignored when doing string
         *       comparisons.</li>
         *  </ul>
         *
         *  <p>For more details and examples of using these two modes, please
         *  see the documentation for the
         *  <code>flash.globalization.Collator</code> class.</p>
         *
         *  <p>The locale for this class is supplied by the <code>locale</code>
         *  style. The <code>locale</code> style can be set in several ways:</p>
         *
         *  <ul>
         *      <li>Inheriting the style from a <code>UIComponent</code> by calling
         *          the UIComponent's <code>addStyleClient</code> method with
         *          an instance of this object as the parameter.</li>
         *      <li>By using the class in an MXML declaration and inheriting the
         *          <code>locale</code> style from the document that contains the
         *          declaration.
         *  <pre>
         *  &lt;fx:Declarations&gt;
         *         &lt;s:SortingCollator id="collator" /&gt;
         *  &lt;/fx:Declarations&gt;
         *  </pre>
         *  </li>
         *      <li>By using an MXML declaration and specifying the
         *          <code>locale</code> value in the list of assignments.
         *  <pre>
         *  &lt;fx:Declarations&gt;
         *      &lt;s:SortingCollator id="collator_german" locale="de-DE" /&gt;
         *  &lt;/fx:Declarations&gt;
         *  </pre>
         *  </li>
         *      <li>Calling the setStyle method, e.g.
         *              <code>collator.setStyle("locale", "de-DE")</code></li>
         *  </ul>
         *
         *  <p>If the <code>locale</code> style is not set by one of the above
         *  techniques, the
         *  methods of this class that depend on the <code>locale</code> set the 
         *  lastOperationStatus property to 
         *  <code>spark.globalization.LastOperationStatus.LOCALE_UNDEFINED_ERROR</code>.</p>
         *
         *  @param initialMode Sets the initial collation options for two use
         *  cases: sorting and matching.
         *
         *  @see flash.globalization.Collator
         *  @see spark.globalization.LastOperationStatus
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function CollatorBase(initialMode:String)
        {
            super();
            
            this.initialMode = initialMode;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        
        // Actual instance of the working flash.globalization.Collator instance.
        private var _g11nWorkingInstance:flash.globalization.Collator;
        
        /**
         *  @private
         *  If the g11nWorkingInstance has not been defined. Call
         *  ensureStyleSource to ensure that there is a styleParent. If there is
         *  not a style parent, then this instance will be added as a style client
         *  to the topLevelApplication. As a side effect of this, the styleChanged
         *  method will be called and if there is a locale style defined for the
         *  topLevelApplication, the createWorkingInstance method will be
         *  executed creating a g11nWorkingInstance.
         */
        private function get g11nWorkingInstance ():
            flash.globalization.Collator
        {
            if (!_g11nWorkingInstance)
                ensureStyleSource();
            
            return _g11nWorkingInstance;
        }
        
        private function set g11nWorkingInstance 
            (flashCollator:flash.globalization.Collator): void 
        {
            _g11nWorkingInstance = flashCollator;
        }
        
        // Cache for the given initialMode through the constructor.
        private var initialMode:String = null;
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  actualLocaleIDName
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  @inheritDoc
         *
         *  @see flash.globalization.Collator.actualLocaleIDName
         *  @see #CollatorBase()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override public function get actualLocaleIDName():String
        {
            if (g11nWorkingInstance)
                return g11nWorkingInstance.actualLocaleIDName;
            
            if ((localeStyle === undefined) || (localeStyle === null))
            {
                fallbackLastOperationStatus
                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
                return undefined;
            }
            
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
            
            return "en-US";
        }
        
        //----------------------------------
        //  lastOperationStatus
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  @inheritDoc
         *
         *  @see spark.globalization.LastOperationStatus
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        override public function get lastOperationStatus():String
        {
            return g11nWorkingInstance ?
                g11nWorkingInstance.lastOperationStatus :
                fallbackLastOperationStatus;
        }
        
        //----------------------------------
        //  useFallback
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  @private
         */
        override mx_internal function get useFallback():Boolean
        {
            return g11nWorkingInstance == null;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  ignoreCase
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  When this property is set to true, identical strings and strings that
         *  differ only in the case of the letters are evaluated as equal.
         *
         *  <p>The default value is <code>true</code> when the 
         *  <code>CollatorBase() </code> constructor's <code>initialMode</code>
         *  parameter is set to  <code>Collator.MATCHING</code>. <code>false</code> 
         *  when the <code>CollatorBase()</code>  constructor's 
         *  <code>initialMode</code> parameter is set to 
         *  <code>Collator.SORTING</code>.</p>
         *
         *  @see #compare()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get ignoreCase():Boolean
        {
            return getBasicProperty(properties, IGNORE_CASE);
        }
        
        public function set ignoreCase(value:Boolean):void
        {
            setBasicProperty(properties, IGNORE_CASE, value);
        }
        
        //----------------------------------
        //  ignoreCharacterWidth
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  When this property is true, full-width and half-width forms of some
         *  Chinese and Japanese characters are evaluated as equal.
         *
         *  <p>For compatibility with existing standards for Chinese and Japanese
         *  character sets, Unicode provides character codes for both full-width
         *  and half width-forms of some characters.
         *  For example, when the <code>ignoreCharacterWidth</code> property is
         *  set to <code>true</code>,
         *  <code>compare("&#65313;&#65393;", "A&#12450;")</code>
         *  returns <code>true</code>.</p>
         *
         *  <p>If the <code>ignoreCharacterWidth</code> property is set to
         *  <code>false</code>, then full-width and half-width forms are not
         *  equal to one another.</p>
         *
         *  <p>The default value is <code>true</code> when the 
         *  <code>CollatorBase()</code> constructor's <code>initialMode</code> 
         *  parameter is set to <code>Collator.MATCHING</code>.
         *  <code>false</code> when the <code>CollatorBase()</code>
         *  constructor's <code>initialMode</code> parameter is set to
         *  <code>Collator.SORTING</code>.</p>
         *
         *  @see #compare()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get ignoreCharacterWidth():Boolean
        {
            return getBasicProperty(properties, IGNORE_CHARACTER_WIDTH);
        }
        
        public function set ignoreCharacterWidth(value:Boolean):void
        {
            setBasicProperty(properties, IGNORE_CHARACTER_WIDTH, value);
        }
        
        //----------------------------------
        //  ignoreDiacritics
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  When this property is set to true, strings that use the same base
         *  characters but different accents or other diacritic marks are
         *  evaluated as equal.
         *
         *  For example <code>compare("cot&#233;", "c&#244;te")</code> returns
         *  <code>true</code> when the <code>ignoreDiacritics</code> property is
         *  set to <code>true</code>.
         *
         *  <p>When the <code>ignoreDiacritics</code> is set to
         *  <code>false</code> then base characters with diacritic marks or
         *  accents are not considered equal to one another.</p>
         *
         *
         *  <p>The default value is <code>true</code> when the 
         *  <code>CollatorBase()</code> constructor's <code>initialMode</code> 
         *  parameter is set to <code>Collator.MATCHING</code>.
         *  <code>false</code> when the <code>CollatorBase()</code>
         *  constructor's <code>initialMode</code> parameter is set to
         *  <code>Collator.SORTING</code>.</p>
         *
         *  @see #compare()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get ignoreDiacritics():Boolean
        {
            return getBasicProperty(properties, IGNORE_DIACRITICS);
        }
        
        public function set ignoreDiacritics(value:Boolean):void
        {
            setBasicProperty(properties, IGNORE_DIACRITICS, value);
        }
        
        //----------------------------------
        //  ignoreKanaType
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  When this property is set to true, strings that differ only by the
         *  type of kana character being used are treated as equal.
         *
         *  For example,
         *  <code>compare("&#12459;&#12490;", "&#12363;&#12394;")</code>
         *  returns <code>true</code> when the <code>ignoreKanaType</code>
         *  property is set to <code>true</code>.
         *
         *  <p>If the <code>ignoreKanaType</code> is set to <code>false</code>
         *  then hiragana and katakana characters that refer to the same syllable
         *  are not equal to one another.</p>
         *
         *  <p>The default value is <code>true</code> when the 
         *  <code>CollatorBase()</code> constructor's <code>initialMode</code> 
         *  parameter is set to <code>Collator.MATCHING</code>.
         *  <code>false</code> when the <code>CollatorBase()</code>
         *  constructor's <code>initialMode</code> parameter is set to
         *  <code>Collator.SORTING</code>.</p>
         *
         *  @see #compare()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get ignoreKanaType():Boolean
        {
            return getBasicProperty(properties, IGNORE_KANA_TYPE);
        }
        
        public function set ignoreKanaType(value:Boolean):void
        {
            setBasicProperty(properties, IGNORE_KANA_TYPE, value);
        }
        
        //----------------------------------
        //  ignoreSymbols
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  When this property is set to is true, symbol characters such as
         *  spaces, currency symbols, math symbols, and other types of symbols
         *  are ignored when sorting or matching.
         *
         *  For example the strings "OBrian", "O'Brian", and "O Brian" would all
         *  be treated as equal when the <code>ignoreSymbols</code> property is
         *  set to <code>true</code>.
         *
         *  <p>The default value is <code>true</code> when the 
         *  <code>CollatorBase()</code> constructor's <code>initialMode</code>
         *  parameter is set to <code>Collator.MATCHING</code>.
         *  <code>false</code> when the <code>CollatorBase()</code>
         *  constructor's <code>initialMode</code> parameter is set to
         *  <code>Collator.SORTING</code>.</p>
         *
         *  @see #compare()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get ignoreSymbols():Boolean
        {
            return getBasicProperty(properties, IGNORE_SYMBOLS);
        }
        
        public function set ignoreSymbols(value:Boolean):void
        {
            setBasicProperty(properties, IGNORE_SYMBOLS, value);
        }
        
        //----------------------------------
        //  numericComparison
        //----------------------------------
        
        [Bindable("change")]
        
        /**
         *  Controls how numeric values embedded in strings are handled during
         *  string comparison.
         *
         *  <p>When the <code>numericComparison</code> property is set to
         *  <code>true</code>, the compare method converts numbers that appear in
         *  strings to numerical values for comparison.</p>
         *
         *  <p>When this property is set to <code>false</code>, the comparison
         *  treats numbers as character codes and sort them according to the
         *  rules for sorting characters in the specified <code>locale</code>.</p>
         *
         *  <p>For example, when this property is true for the locale ID "en-US",
         *  then the strings "version1", "version10", and "version2" are sorted
         *  into the following order: version1 &#60; version2 &#60; version10.</p>
         *
         *  <p>When this property is false for "en-US", those same strings
         *  are sorted into the following order: version1 &#60; version10 &#60;
         *  version2.</p>
         *
         *  @default <code>false</code>
         *
         *  @see #compare()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function get numericComparison():Boolean
        {
            return getBasicProperty(properties, NUMERIC_COMPARISON);
        }
        
        public function set numericComparison(value:Boolean):void
        {
            setBasicProperty(properties, NUMERIC_COMPARISON, value);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         */
        override mx_internal function createWorkingInstance():void
        {
            if ((localeStyle === undefined) || (localeStyle === null))
            {
                fallbackLastOperationStatus
                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
                g11nWorkingInstance = null;
                properties = null;
                return;
            }
            
            if (enforceFallback)
            {
                fallbackInstantiate();
                g11nWorkingInstance = null;
                return;
            }
            
            g11nWorkingInstance =
                new flash.globalization.Collator(localeStyle, initialMode);
            if (g11nWorkingInstance
                && (g11nWorkingInstance.lastOperationStatus
                    != LastOperationStatus.UNSUPPORTED_ERROR))
            {
                properties = g11nWorkingInstance;
                propagateBasicProperties(g11nWorkingInstance);
                return;
            }
            
            fallbackInstantiate();
            g11nWorkingInstance = null;
            
            if (fallbackLastOperationStatus == LastOperationStatus.NO_ERROR)
            {
                fallbackLastOperationStatus
                = LastOperationStatus.USING_FALLBACK_WARNING;
            }
        }
        
        //--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
        
        [Bindable("change")]
        
        /**
         *  Compares two strings and returns an integer value indicating whether
         *  the first string is less than, equal to, or greater than the second
         *  string.
         *
         *  The comparison uses the sort order rules for the <code>locale</code> sytle that is
         *  in effect when the compare method is called.
         *
         *  @param string1 First comparison string.
         *  @param string2 Second comparison string.
         *  @return An integer value indicating whether the first string is less
         *         than, equal to, or greater than the second string.
         *         <ul>
         *             <li>If the return value is negative, <code>string1</code>
         *                  is less than <code>string2</code> or <code>string2</code> is <code>null</code>.</li>
         *             <li>If the return value is zero, <code>string1</code> is
         *                  equal to <code>string2</code>.</li>
         *             <li>If the return value is positive, <code>string1</code>
         *                  is larger than <code>string2</code> or <code>string1</code> is <code>null</code>.</li>
         *         </ul>
         *
         *  @see #CollatorBase()
         *  @see #equals()
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function compare(string1:String, string2:String):int
        {
            if (g11nWorkingInstance)
            {
                // The compare function below will throw an Argument error if either string1 or 
                // string2 is null so handle those cases here.
                if (string1 === null && string2 === null)
                    return 0;
                
                if (string1 === null)
                    return 1;
                
                if (string2 === null)
                    return -1;
                
                return g11nWorkingInstance.compare(string1, string2);
            }
            
            if ((localeStyle === undefined) || (localeStyle === null))
            {
                fallbackLastOperationStatus
                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
                return undefined;
            }
            
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
            
            return ObjectUtil.stringCompare(
                string1, string2, properties.ignoreCase);
        }
        
        [Bindable("change")]
        
        /**
         *  Compares two strings and returns a Boolean value indicating whether
         *  the strings are equal.
         *
         *  The comparison uses the sort order rules for the locale ID that was
         *  specified in the <code>CollatorBase()</code> constructor.
         *
         *  @param string1 First comparison string.
         *  @param string2 Second comparison string.
         *  @return A Boolean value indicating whether the strings are equal
         *         (<code>true</code>) or unequal (<code>false</code>).
         *
         *  @see #CollatorBase()
         *  @see #compare
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public function equals(string1:String, string2:String):Boolean
        {
            if (g11nWorkingInstance)
            {
                // The equals function below will throw an Argument error if either string1 or 
                // string2 is null so handle those cases here.
                if (string1 === null && string2 === null)
                    return true;
                
                if (string1 === null || string2 === null)
                    return false;
                
                return g11nWorkingInstance.equals(string1, string2);
            }
            
            if ((localeStyle === undefined) || (localeStyle === null))
            {
                fallbackLastOperationStatus
                = LastOperationStatus.LOCALE_UNDEFINED_ERROR;
                return undefined;
            }
            
            fallbackLastOperationStatus = LastOperationStatus.NO_ERROR;
            
            return ObjectUtil.stringCompare(
                string1, string2, properties.ignoreCase) == 0;
        }
        
        /**
         *  Lists all of the locale ID names supported by this class.
         *
         *  @return A vector of strings containing all of the locale ID names
         *         supported by this class and operating system.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10.1
         *  @playerversion AIR 2.5
         *  @productversion Flex 4.5
         */
        public static function getAvailableLocaleIDNames():Vector.<String>
        {
            const locales:Vector.<String>
            = flash.globalization.Collator.getAvailableLocaleIDNames();
            
            return locales ? locales : new Vector.<String>["en-US"];
        }
        
        //--------------------------------------------------------------------------
        //
        //  Private Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  Imaginary constructor of FallbackCollator.
         *
         *  All it does is to check if the given parameters are correct and do
         *  nothing.
         */
        private function fallbackInstantiate():void
        {
            const validInitialMode:Boolean =
                (initialMode == CollatorMode.MATCHING)
                || (initialMode == CollatorMode.SORTING);
            
            fallbackLastOperationStatus = validInitialMode ?
                LastOperationStatus.NO_ERROR :
                LastOperationStatus.INVALID_ATTR_VALUE;
            
            properties =
                {
                    ignoreCase: (initialMode == CollatorMode.MATCHING),
                    ignoreCharacterWidth: false,
                    ignoreDiacritics: false,
                    ignoreKanaType: false,
                    ignoreSymbols: false,
                    numericComparison: false
                };
            
            propagateBasicProperties(properties);
        }
    }
}
