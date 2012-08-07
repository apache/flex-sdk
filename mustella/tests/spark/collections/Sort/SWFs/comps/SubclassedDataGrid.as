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
package comps{
    
    import mx.controls.*;
    import mx.controls.dataGridClasses.*;
    import mx.controls.listClasses.*;   
    
    public class SubclassedDataGrid extends DataGrid{
    
        /**
        * This is used to allow us to tell what isItemEditable()
        * will return.  isItemEditable() is meant to be
        * overriden.
        **/
        private var _isItemEditableRetVal:Boolean = true;

        /**
        * Set this to true to use the override createColumnItemRenerer()
        * functionality below.
        **/
        private var _useCreateColumnItemRendererOverride:Boolean = false;
    
        public function SubclassedDataGrid():void{
            super();
        }
        
        public function doClearSeparators():void{
            this.clearSeparators();
        }

        public function doDrawSeparators():void{
            this.drawSeparators();
        }

        public function doPlaceSortArrow():void{
            this.placeSortArrow();
        }    

        public function set isItemEditableRetVal(b:Boolean):void{
            _isItemEditableRetVal = b;
        }

        override public function isItemEditable(data:Object):Boolean{
            return _isItemEditableRetVal;
        }
        
        public function set useCreateColumnItemRendererOverride(b:Boolean):void{
            _useCreateColumnItemRendererOverride = b;
        }

        override public function createColumnItemRenderer(c:DataGridColumn, forHeader:Boolean, data:Object):IListItemRenderer{
            if(!_useCreateColumnItemRendererOverride){
                ret = super.createColumnItemRenderer(c, forHeader, data);
            }
            else{

                var ret:IListItemRenderer;
                var controlType:String;
                var num:Number;
                var date:Date;

                if(forHeader){
                    ret = super.createColumnItemRenderer(c, forHeader, data);
                }else{
                    if(c.dataField == "controlType"){
                        ret = super.createColumnItemRenderer(c, forHeader, data);
                    }
                    else{                        
                        switch (data.controlType){
                            case "NumericStepper":
                                ret = new NumericStepper();
                                NumericStepper(ret).value = data.info;
                                break;
                            case "Image":
                                ret = new Image();
                                Image(ret).source = data.info;
                                break;
                            case "Button":
                                ret = new Button();
                                Button(ret).label = data.info;
                                break;
                            case "TextArea":
                                ret = new TextArea();
                                TextArea(ret).text = data.info;
                                break;
                            case "ComboBox":
                                ret = new ComboBox();
                                ComboBox(ret).dataProvider = (data.info).split(",");
                                break;
                            case "TextInput":
                                ret = new TextInput();
                                TextInput(ret).text = data.info;
                                break;
                            case "Label":
                                ret = new Label();
                                Label(ret).text = data.info;
                                break;
                            case "DateField":
                                ret = new DateField();
                                break;
                            default:
                                ret = super.createColumnItemRenderer(c, forHeader, data);
                        }
                    }
                }
            }
            
            return ret;        
        }


    }

}
