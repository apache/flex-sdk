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
package spark.core
{
    [ExcludeClass]
    
    /**
     *  @private
     *  Interface to plumb soft-keyboard hints to soft-keyboard-aware 
     *  implementation components.
     */
    public interface ISoftKeyboardHintClient
    {
        //--------------------------------------------------------------------------
        //
        //  Properties
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  autoCapitalize
        //----------------------------------
        
        /**
         *  Hint indicating what captialization behavior soft keyboards should use.
         *
         *  <p>Supported values are defined in flash.text.AutoCapitalize:
         *  <ul>
         * 
         *      <li><code>"none"</code> - no automatic capitalization</li>
         * 
         *      <li><code>"word"</code> - capitalize the first letter following any space or 
         *      punctuation</li>
         * 
         *      <li><code>"sentence"</code> - captitalize the first letter following any period</li>
         * 
         *   <li><code>"all"</code> - capitalize every letter</li>
         * 
         * </ul>
         * </p>
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.6
         */
        function set autoCapitalize(value:String):void;
        function get autoCapitalize():String;
        
        //----------------------------------
        //  autoCorrect
        //----------------------------------
        
        /**
         *  Hint indicating whether a soft keyboard should use its auto-correct
         *  behavior, if supported.
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.6
         */
        function get autoCorrect():Boolean;
        function set autoCorrect(value:Boolean):void;
        
        //----------------------------------
        //  returnKeyLabel
        //----------------------------------
        
        /**
         *  Hint indicating what label should be displayed for the return key on
         *  soft keyboards.
         *
         *  <p>Supported values are defined in flash.text.ReturnKeyLabel:
         *  <ul>
         *      <li><code>"default"</code> - default icon or label text</li>
         * 
         *      <li><code>"done"</code> - icon or label text indicating completed text entry</li>
         * 
         *      <li><code>"go"</code> - icon or label text indicating that an action should 
         *      start</li>
         * 
         *      <li> <code>"next"</code> - icon or label text indicating a move to the next 
         *      field</li>
         * 
         *      <li><code>"search"</code> - icon or label text indicating that the entered text 
         *      should be searched for</li>
         *  </ul>
         *  </p>
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.6
         */
        function get returnKeyLabel():String;
        function set returnKeyLabel(value:String):void;
        
        //----------------------------------
        //  softKeyboardType
        //----------------------------------
        
        /**
         *  Hint indicating what kind of soft keyboard should be displayed for this
         *  component.
         *
         *  <p>Supported values are defined in flash.text.SoftKeyboardType:
         *  <ul>
         *      <li><code>"default"</code> - the default keyboard</li>
         * 
         *      <li><code>"punctuation"</code> - puts the keyboard into punctuation/symbol entry 
         *      mode</li>
         * 
         *      <li><code>"url"</code> - present soft keys appropriate for URL entry, such as a
         *      specialized key that inserts '.com'</li>
         * 
         *      <li><code>"number"</code> - puts the keyboard into numeric keypad mode</li>
         * 
         *      <li><code>"contact"</code> - puts the keyboard into a mode appropriate for entering
         *      contact information</li>
         * 
         *      <li><code>"email"</code> - puts the keyboard into e-mail addres entry mode, which 
         *      may make it easier to enter the at sign or '.com'</li>
         *  </ul>
         *  </p>
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.6
         */
        function get softKeyboardType():String;
        function set softKeyboardType(value:String):void;
    }
}