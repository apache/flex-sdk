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
package{

	import mx.controls.TextArea;
	//import mx.core.UITextField;
	
	public class MyTextArea extends TextArea{
		
		public function getTextFieldDisplayAsPassword():Boolean{
			return this.textField.displayAsPassword;
		}
		
		public function getTextFieldCaretIndex():int{
			return this.textField.caretIndex;
		}

		public function getTextFieldNumLines():int{
			return this.textField.numLines;
		}

		public function getMaxChars():int{
			return this.textField.maxChars;
		}
	
		public function getRestrict():String{
			return this.textField.restrict;
		}

		public function getSelectionBeginIndex():int{
			return this.textField.selectionBeginIndex;		
		}

		public function getSelectionEndIndex():int{
			return this.textField.selectionEndIndex;
		}		
		
		public function getText():String{
			return this.textField.text;
		}

		public function getNumLines():int{
			return this.textField.numLines;
		}

	} // end class

} // end package