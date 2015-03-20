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
package spark.components {
    import flash.events.Event;
    import flash.events.TextEvent;

    import flashx.textLayout.edit.EditManager;

    import flashx.textLayout.edit.SelectionState;
    import flashx.textLayout.operations.CompositeOperation;
    import flashx.textLayout.operations.CopyOperation;
    import flashx.textLayout.operations.DeleteTextOperation;
    import flashx.textLayout.operations.InsertTextOperation;
    import flashx.textLayout.tlf_internal;

    import mx.utils.StringUtil;

    import spark.components.RichEditableText;
    import spark.components.TextInput;
    import spark.events.TextOperationEvent;

    use namespace tlf_internal;

    /**
     * Masked Text Input Component
     *
     * A TextInput extension with a mask text and a string pattern of separators that constraints the text
     * introduced by the user to the available characters dictated by the pattern and inserts or deletes
     * separator characters guided by the mask text pattern.
     *
     * This control is widely used in applications to insert different kind of data like dates,
     * bank accounts, plates or phone numbers...
     *
     * Template rules:
     *
     *      # - numeric-only,
     *      @ - alphabetic-only,
     *      ? - any
     *
     * configuration properties:
     *
     *      maskText            : The mask base string for the component logic
     *                            defaults to ""
     *      separators          : The characters specified to act as separators that must be present in the maskText
     *                            defaults to "- +/|()[]{}."
     *      textMaskPrompt      : User defined prompt to override default behaviour.
     *                            defaults to ""
     *      placeHolder         : A character to show instead internal mask template characters (#, @ and ?)
     *                            defaults to "_"
     *      usePlaceHolder      : If true, show placeHolder instead #, @ or ?, if false show real characters
     *                            defaults to true
     *      hideSeparatorInText : If true, separator is hidden in text but shown in mask, viceversa if false.
     *                            defaults to true
     *      showMaskWhileWrite  : If true the remaining mask is shown while user write as a helper. false
     *                            hide mask as soon as the user interact with the control
     *                            defaults to true
     *
     * Some sample mask patterns:
     *
     * Date:  ##/##/####
     * Phone: (###)###.##.##.##
     * IBAN:  ES##-####-####-##-##########
     * CCC:   ####-####-##-##########
     */
    public class MaskedTextInput extends TextInput {
        public function MaskedTextInput() {
            super();

            addEventListener(TextOperationEvent.CHANGING, verifyInsertedText);
            addEventListener(TextOperationEvent.CHANGE, formatAsYouType);
            addEventListener(TextEvent.TEXT_INPUT, overrideText);
        }

        //----------------------------------
        //  PUBLIC
        //----------------------------------

        //----------------------------------
        //  text
        //----------------------------------
        private var textChanged:Boolean = false;

        /**
         * get text formated with separators
         */
        public function get fullText():String {
            return super.text;
        }

        /**
         * get the raw text removing separators
         */
        override public function get text():String {
            return cleanText(fullText);
        }

        /**
         * remove not allowed separators
         * @param value
         * @return
         */
        private function cleanText(value:String):String {
            var rawText:String = "";
            for (var index:int = 0; index < value.length; index++) {
                var aChar:String = value.charAt(index);
                for (var sepIndex:int = 0; sepIndex < separators.length; sepIndex++) {
                    var sepChar:String = separators.charAt(sepIndex);
                    var found:Boolean = false;
                    if (aChar == sepChar) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    rawText += aChar;
                }
            }
            return rawText;
        }


        private var storean:int = 0;
        private var storeac:int = 0;

        /**
         * program a format of the entered text based on mask text and separators
         * @param value
         */
        [Bindable("change")]
        [Bindable("textChanged")]
        // Compiler will strip leading and trailing whitespace from text string.
        [CollapseWhiteSpace]
        override public function set text(value:String):void {
            if (super.text !== value) {
                storean = selectionAnchorPosition;
                storeac = selectionActivePosition;
                super.text = value;
                textChanged = true;
                invalidateProperties();
            }
        }

        //----------------------------------
        //  mask text
        //----------------------------------
        private var _maskText:String = "";
        private var maskedTextChanged:Boolean = true;

        [Bindable]
        public function get maskText():String {
            return _maskText;
        }

        public function set maskText(value:String):void {
            if (maskText !== value) {
                _maskText = value;
                maskedTextChanged = true;
                invalidateProperties();
            }
        }

        //----------------------------------
        //  separators
        //----------------------------------
        private var _separators:String = "- +/|()[]{}.";
        private var separatorsChanged:Boolean = true;

        [Bindable]
        public function get separators():String {
            return _separators;
        }

        public function set separators(value:String):void {
            if (separators !== value) {
                separatorsChanged = true;
                _separators = value;
                invalidateProperties();
            }
        }

        /**
         * user defined text prompt. For example for date mask ("##/##/####") you could use textMaskPrompt "dd/mm/yyyy"
         */
        public var textMaskPrompt:String = "";

        /**
         * the character to represent a input character location
         */
        [Bindable]
        public var placeHolder:String = "_";

        /**
         * substitute the prompt with the selected place holder for all special characters (#,@ and ?)
         */
        [Bindable]
        public var usePlaceHolder:Boolean = true;

        /**
         * use blank character instead of separator character
         */
        [Bindable]
        public var hideSeparatorInText:Boolean = true;

        /**
         * show the mask text while user writes, removing characters as user types
         */
        private var _showMaskWhileWrite:Boolean = true;

        [Bindable]
        public function get showMaskWhileWrite():Boolean {
            return _showMaskWhileWrite;
        }

        public function set showMaskWhileWrite(value:Boolean):void {
            _showMaskWhileWrite = value;
            invalidateSkinState();
        }

        //----------------------------------
        //  PRIVATE
        //----------------------------------

        /**
         * internal character to represent blank space in text
         */
        private static const BLANK_SEPARATOR:String = " ";

        /**
         * an internal array to maintain the insertion point of separators. This array is filled based on the
         * mask text pattern and the separators available
         */
        private var separatorLocations:Array = null;

        //----------------------------------
        //  COMPONENT LIFE CYCLE
        //----------------------------------

        /**
         * getCurrentSkinState
         * @return the new state
         */
        override protected function getCurrentSkinState():String {
            if (showMaskWhileWrite) {
                if (enabled && skin && skin.hasState("normalWithPrompt"))
                    return "normalWithPrompt";
                if (!enabled && skin && skin.hasState("disabledWithPrompt"))
                    return "disabledWithPrompt";
            }

            return super.getCurrentSkinState();
        }

        /**
         * commit properties
         */
        override protected function commitProperties():void {
            super.commitProperties();

            if (maskedTextChanged) {
                typicalText = maskText;
                maxChars = maskText.length;
            }

            if (separatorsChanged || maskedTextChanged) {
                // create the array of separator locations based on mask text and available separators
                separatorLocations = [];
                for (var maskIndex:int = 0; maskIndex < maskText.length; maskIndex++) {
                    var maskChar:String = getMaskCharAt(maskIndex);
                    for (var sepIndex:int = 0; sepIndex < separators.length; sepIndex++) {
                        var sepChar:String = separators.charAt(sepIndex);
                        if (maskChar == sepChar) {
                            separatorLocations.push(maskIndex);
                        }
                    }
                }
            }

            if (textChanged) {
                selectAll();
                insertText(formatTextWithMask(text));
                selectRange(storean, storeac);
            }

            separatorsChanged = maskedTextChanged = textChanged = false;

            updatePrompt();
        }

        //----------------------------------
        //  PROTECTED
        //----------------------------------

        /**
         * format programmatic text (not introduced by user) in textDisplay control with the mask
         * (i.e.: assigned string to text property, trigger, binding, ...)
         */
        protected function formatTextWithMask(value:String):String {
            var stack:Array = value.split("");
            var outputText:String = "";

            for (var i:int = 0; i < maskText.length; i++) {
                if (stack.length == 0) {
                    break;
                }
                if (isSeparator(i)) {//if is separator location add separator
                    outputText += getMaskCharAt(i);
                } else { // if not add the expected value char
                    outputText += restrictToMaskPattern(stack.shift(), i);
                }
            }

            return outputText;
        }

        /**
         * verify insertion to avoid characters not allowed in mask
         * @param event the TextOperationEvent event
         */
        protected function verifyInsertedText(event:TextOperationEvent):void {
            // filter now allowed characters
            var an:int = selectionAnchorPosition;
            var insertTextOp:InsertTextOperation = null;
            if (event.operation is InsertTextOperation && an != maxChars) {
                insertTextOp = event.operation as InsertTextOperation;
                if (restrictToMaskPattern(insertTextOp.text, an) == ""
                        || (restrictToMaskPattern(insertTextOp.text, an + 1) == "" && isMaskSeparatorLocation(an))) {
                    event.preventDefault();
                }
            }
        }

        /**
         * add or remove separator character as we type in the text input.
         * Note that override text when all characters are in place
         * is not supported (see overrideText method)
         * @param event the TextOperationEvent event
         */
        protected function formatAsYouType(event:TextOperationEvent):void {
            var stack:Array = text.split("");
            var outputText:String = "";
            var an:int = selectionAnchorPosition;
            var ac:int = selectionAnchorPosition;
            var offset:int = 0;//caret advances one position by default (on insert and deletion)

            //copy/paste
            if (event.operation is CompositeOperation) {
                var operations:Array = (event.operation as CompositeOperation).operations;

                if (operations[1] is InsertTextOperation) {
                    var copyedText:String = cleanText((operations[1] as InsertTextOperation).text);
                    outputText = formatTextWithMask(copyedText);
                    an = ac = outputText.length;
                }
            }
            //insert
            else if (event.operation is InsertTextOperation) {
                var insertOp:InsertTextOperation = event.operation as InsertTextOperation;
                if (insertOp.deleteSelectionState != null && !insertOp.deleteSelectionState.tlf_internal::selectionManagerOperationState) {
                    //OVERRIDING INSERT
                    if (EditManager.overwriteMode) {
                        //windows insert mode on (note that Flash Player does not track insertion mode state before running a SWF)
                        if (isSeparator(ac - 1)) {
                            outputText = super.text.substring(0, insertOp.originalSelectionState.anchorPosition + 1) + super.text.substring(insertOp.originalSelectionState.anchorPosition + 2);
                        } else {
                            outputText = super.text;
                        }
                        an -= 1;
                        ac -= 1;
                    }
                    else if (isSeparator(ac)) {
                        outputText = super.text.substring(0, insertOp.originalSelectionState.anchorPosition + 1) + insertOp.text + super.text.substring(insertOp.originalSelectionState.activePosition + 1);
                    } else {
                        outputText = super.text.substring(0, insertOp.originalSelectionState.anchorPosition) + insertOp.text + super.text.substring(insertOp.originalSelectionState.activePosition);
                    }

                    outputText = formatTextWithMask(cleanText(outputText));

                    if (isSeparator(ac)) {
                        an = an + 2;
                        ac = ac + 2;
                    }
                    else {
                        an = an + 1;
                        ac = ac + 1;
                    }
                } else {
                    //INSERT (TEXT NOT COMPLETE)
                    for (var i:int = 0; i < maskText.length; i++) {
                        if (stack.length == 0) {
                            break;
                        }
                        if (isMaskSeparatorLocation(i)) {
                            outputText += getMaskCharAt(i);
                            offset += 1;
                        } else {
                            outputText += restrictToMaskPattern(stack.shift(), i);
                        }
                    }

                    //on override caret does not advance
                    if (super.text.length > an) {
                        //override on separator
                        if (isSeparator(an - 1)) {
                            offset = getDeletePosition(an) + 1;
                        }
                        else if (isSeparator(an)) {
                            offset = 1;
                        }
                        else {
                            offset = 0;
                        }
                    }

                    an = ac = selectionAnchorPosition + offset;
                }
            }
            //delete
            else if (event.operation is DeleteTextOperation) {
                if (isSeparator(an - 1)) {
                    offset = consecutiveSeparators(an - 1);
                }
                else if (isSeparator(an)) {
                    stack.splice(an - getDeletePosition(an) - 1, 1);
                    offset = 1;
                }

                for (i = 0; i < maskText.length; i++) {
                    if (stack.length == 0) {
                        break;
                    }
                    if (isMaskSeparatorLocation(i)) {
                        outputText += getMaskCharAt(i);
                    } else {
                        outputText += restrictToMaskPattern(stack.shift(), i);
                    }
                }

                an = ac = selectionActivePosition - offset;
            }
            //copy
            else if (event.operation is CopyOperation) {
                return; // avoid to remove all text on copy operation
            }


            selectAll();
            insertText(outputText);
            selectRange(an, ac);

            updatePrompt();

            dispatchEvent(new Event("textChanged"));
        }

        /**
         * used when text exist and is as long as maxChars and cursor is not at
         * the end of the text.
         * overrides the actual text as we type (replacing text as we type)
         * @param event the TextEvent
         */
        protected function overrideText(event:TextEvent):void {
            //windows insert mode on (note that Flash Player does not track insertion mode state before running a SWF)
            if (EditManager.overwriteMode) {
                return;
            }

            var an:int = selectionAnchorPosition;
            var ac:int = selectionActivePosition;

            // text is full, overwrite characters
            if (super.text.length == maxChars) {
                // filter now allowed characters
                if (restrictToMaskPattern(event.text, an) == ""
                        || (restrictToMaskPattern(event.text, an + 1) == "" && isMaskSeparatorLocation(an))) {
                    return;
                }

                var operationState:SelectionState = new SelectionState(RichEditableText(textDisplay).textFlow, an, ac + 1);
                var operation:InsertTextOperation = new InsertTextOperation(operationState, event.text, operationState);
                var changeEvent:TextOperationEvent = new TextOperationEvent(TextOperationEvent.CHANGE, false, true, operation);
                dispatchEvent(changeEvent);
            }
        }

        //----------------------------------
        //  PRIVATE
        //----------------------------------

        /**
         * update prompt
         */
        private function updatePrompt():void {
            var _prompt:String = "";
            var textLength:int = super.text.length;
            for (var i:int = 0; i < textLength; i++) {
                if (isSeparator(i)) {//if is separator location add separator
                    _prompt += hideSeparatorInText ? getMaskCharAt(i) : BLANK_SEPARATOR;
                } else { // if not add the expected value char
                    _prompt += BLANK_SEPARATOR;
                }
            }
            _prompt += textMaskPrompt == "" ? maskText.substring(textLength) : textMaskPrompt.substring(textLength);

            if (usePlaceHolder && textMaskPrompt == "") {
                _prompt = _prompt.replace(/#/g, placeHolder);
                _prompt = _prompt.replace(/@/g, placeHolder);
                _prompt = _prompt.replace(/?/g, placeHolder);
            }

            prompt = _prompt;
        }

        /**
         * Manage template rules:
         *      # - numeric-only,
         *      @ - alphabetic-only,
         *      ? - any
         * @param inputChar
         * @param position
         * @return the restricted character or the mask character
         */
        private function restrictToMaskPattern(inputChar:String, position:int):String {
            var maskChar:String = getMaskCharAt(position);
            switch (maskChar) {
                case "#":
                    return StringUtil.restrict(inputChar, "0-9");
                case "@":
                    return StringUtil.restrict(inputChar, "a-zA-Z");
                case "?":
                    return inputChar;
            }
            return maskChar;
        }


        //----------------------------------
        //  PRIVATE AUTOMATA'S LOGIC
        //----------------------------------

        /**
         * get the mask char at index location
         * @param index
         * @return
         */
        private function getMaskCharAt(index:int):String {
            return maskText.charAt(index);
        }

        /**
         *
         * @param index
         * @return true if location in maskText is separator, false if is placeHolder location
         */
        private function isMaskSeparatorLocation(index:int):Boolean {
            for (var sepIndex:int = 0; sepIndex < separators.length; sepIndex++) {
                var sepChar:String = separators.charAt(sepIndex);
                if (getMaskCharAt(index) == sepChar) {
                    return true;
                }
            }
            return false;
        }

        /**
         * @param index
         * @return true if there is separator at index, false otherwise
         */
        private function isSeparator(index:int):Boolean {
            for (var i:int = 0; i < separatorLocations.length; i++) {
                if (index == separatorLocations[i]) {
                    return true;
                }
            }
            return false;
        }

        /**
         * @param index
         * @return return value to rest from anchor to splice chars when remove, 0 otherwise.
         */
        private function getDeletePosition(index:int):int {
            for (var i:int = 0; i < separatorLocations.length; i++) {
                if (index == separatorLocations[i]) {
                    return i;
                }
            }
            return 0;
        }

        /**
         * @param index
         * @return return value to rest from anchor to splice chars when remove, 0 otherwise.
         */
        private function consecutiveSeparators(index:int):int {
            if (isSeparator(index - 1)) {
                return 1 + consecutiveSeparators(index - 1);
            } else {
                return 1;
            }
            return 0;
        }
    }
}
