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
         *  Supported values are defined in flash.text.AutoCapitalize:
         *      "none" - no automatic capitalization
         *      "word" - capitalize the first letter following any space or
         *          punctuation
         *      "sentence" - captitalize the first letter following any period
         *      "all" - capitalize every letter
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.5.2
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
         *  @productversion Flex 4.5.2
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
         *  Supported values are defined in flash.text.ReturnKeyLabel:
         *      "default" - default icon or label text
         *      "done" - icon or label text indicating completed text entry
         *      "go" - icon or label text indicating that an action should start
         *      "next" - icon or label text indicating a move to the next field
         *      "search" - icon or label text indicating that the entered text
         *          should be searched for
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.5.2
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
         *  Supported values are defined in flash.text.SoftKeyboardType:
         *      "default" - the default keyboard
         *      "punctuation" - puts the keyboard into punctuation/symbol entry mode
         *      "url" - present soft keys appropriate for URL entry, such as a
         *          specialized key that inserts '.com'
         *      "number" - puts the keyboard into numeric keypad mode
         *      "contact" - puts the keyboard into a mode appropriate for entering
         *          contact information
         *      "email" - puts the keyboard into e-mail addres entry mode, which may
         *          make it easier to enter '@' or '.com'
         *  
         *  @langversion 3.0
         *  @playerversion AIR 3.0
         *  @productversion Flex 4.5.2
         */
        function get softKeyboardType():String;
        function set softKeyboardType(value:String):void;
    }
}