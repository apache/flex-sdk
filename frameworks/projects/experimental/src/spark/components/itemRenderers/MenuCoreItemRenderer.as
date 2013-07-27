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
package spark.components.itemRenderers {
    import flash.events.MouseEvent;

    import mx.collections.XMLListCollection;
    import mx.core.DeferredInstanceFromFunction;
    import mx.events.FlexMouseEvent;
    import mx.events.PropertyChangeEvent;
    import mx.states.AddItems;
    import mx.states.State;

    import spark.components.Menu;
    import spark.components.listClasses.IListItemRenderer;
    import spark.events.MenuEvent;

    import spark.components.List;
    import spark.components.PopUpAnchor;
    import spark.components.supportClasses.ItemRenderer;
    import spark.layouts.HorizontalLayout;
    import spark.layouts.VerticalLayout;

    /**
     *
     */
    [States("normal", "hovered", "selected")]
    /**
     * @author Bogdan Dinu (http://www.badu.ro)
     */ public class MenuCoreItemRenderer extends ItemRenderer implements IListItemRenderer {
        /**
         * getter of the subMenu, used in keyboard navigation
         */
        protected var _subMenu:Menu;

        public function get subMenu():Menu {
            return _subMenu;
        }

        /**
         * getter of the popup anchor, used in keyboard navigation
         */
        protected var _popup:PopUpAnchor;

        public function get popup():PopUpAnchor {
            return _popup;
        }

        /**
         * isSeparator property (bindable) - used by subclasses
         */
        protected var _isSeparator:Boolean;

        public function get isSeparator():Boolean {
            return _isSeparator;
        }

        [Bindable(event="propertyChange")]
        public function set isSeparator(value:Boolean):void {
            if (_isSeparator !== value) {
                var oldValue:Boolean = _isSeparator;
                _isSeparator = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "isSeparator", oldValue, value));
                }
            }
        }

        /**
         * hasIcon property (bindable) - used by subclasses
         **/
        protected var _hasIcon:Boolean;

        public function get hasIcon():Boolean {
            return _hasIcon;
        }

        [Bindable(event="propertyChange")]
        public function set hasIcon(value:Boolean):void {
            if (_hasIcon !== value) {
                var oldValue:Boolean = _hasIcon;
                _hasIcon = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "hasIcon", oldValue, value));
                }
            }
        }

        /**
         * iconSource property (bindable) - used by subclasses
         **/
        protected var _iconSource:String;

        public function get iconSource():String {
            return _iconSource;
        }

        [Bindable(event="propertyChange")]
        public function set iconSource(value:String):void {
            if (_iconSource !== value) {
                var oldValue:String = _iconSource;
                _iconSource = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "iconSource", oldValue, value));
                }
            }
        }

        /**
         * isChecked property (bindable) - used by subclasses
         **/
        protected var _isChecked:Boolean;

        public function get isChecked():Boolean {
            return _isChecked;
        }

        [Bindable(event="propertyChange")]
        public function set isChecked(value:Boolean):void {
            if (_isChecked !== value) {
                var oldValue:Boolean = _isChecked;
                _isChecked = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "isChecked", oldValue, value));
                }
            }
        }

        /**
         * isCheckable property  (bindable) - used by subclasses
         **/
        protected var _isCheckable:Boolean;

        public function get isCheckable():Boolean {
            return _isCheckable;
        }

        [Bindable(event="propertyChange")]
        public function set isCheckable(value:Boolean):void {
            if (_isCheckable !== value) {
                var oldValue:Boolean = _isCheckable;
                _isCheckable = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "isCheckable", oldValue, value));
                }
            }
        }

        /**
         * dataProvider property (bindable) - used by subclasses
         **/
        protected var _dataProvider:XMLListCollection;

        public function get dataProvider():XMLListCollection {
            return _dataProvider;
        }

        [Bindable(event="propertyChange")]
        public function set dataProvider(value:XMLListCollection):void {
            if (_dataProvider !== value) {
                var oldValue:XMLListCollection = _dataProvider;
                _dataProvider = value;
                if (hasEventListener("propertyChange")) {
                    dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "dataProvider", oldValue, value));
                }
            }
        }

        /**
         * Holds the instance of the parent List (which is Menu or MenuBar)
         * if this instance is isSubMenuRenderer, and dataProvider has elements
         * we have to create popup anchor in order to display it when
         * the item is hovered
         **/
        protected var _ownerMenu:List;

        public function get listOwner():List {
            return _ownerMenu;
        }

        public function set listOwner(value:List):void {
            _ownerMenu = value;
            //optimisation : we are creating popup and menu only if dataProvider has what to show
            if (isSubMenuRenderer && dataProvider.length > 0) {
                createPopupAnchor();
                //_subMenu.id = _ownerMenu.id+"_"+itemIndex; //commented, used for debugging
                _subMenu.parentMenu = _ownerMenu;//this is mandatory for keyboard navigation
                _subMenu.labelField = _ownerMenu.labelField;
                _subMenu.dataProvider = dataProvider;
            }
        }

        /**
         * this gets overriden and set to true when is a submenu item renderer
         */
        public function get isSubMenuRenderer():Boolean {
            return false;
        }

        /**
         * Sets data : checks if it's a separator, if it's checkable, it's default checked
         */
        override public function set data(value:Object):void {
            super.data = XML(value);
            dataProvider = new XMLListCollection(super.data.children());
            isSeparator = super.data.@separator.toString() == 'true';
            hasIcon = super.data.@icon.toString().length > 0;
            if (hasIcon) {
                iconSource = super.data.@icon.toString();
            }
            isCheckable = super.data.@isCheckable.toString() == 'true';
            enabled = super.data.@enabled != 'false';
            if (_isCheckable) {
                isChecked = super.data.@isChecked.toString() == 'true';
            }
        }

        /**
         * since hovered is protected, we have to expose it somehow - it's accessed by keyboard navigation
         */
        public function setHovered(value:Boolean):void {
            hovered = value;
        }

        /**
         * Handles hovering. If is a sub-menu item renderer, the popup should become
         * visible, thus displaying the sub-sub-menu
         */
        override protected function set hovered(value:Boolean):void {
            if (super.hovered === value) {
                return;
            }
            super.hovered = value;
            if (_isCheckable) {
                return;
            }
            if (isSubMenuRenderer && _popup) {
                if (value && dataProvider.length > 0) {
                    //only when set to true and it's a submenu item renderer and dataprovider has something, we display popup
                    _popup.displayPopUp = true;
                } else {
                    _popup.displayPopUp = false;
                }
            } else {
                if (value) {
                    if (_ownerMenu.selectedIndex != -1) {
                        _ownerMenu.selectedIndex = _ownerMenu.dataProvider.getItemIndex(data);
                    }
                }
            }
        }

        override public function set selected(value:Boolean):void {
            super.selected = value;
            if (value && isSubMenuRenderer) {
                callLater(setFocus);
            }
        }

        /**
         * Constructor
         */
        public function MenuCoreItemRenderer() {
            super();
            createAndSetStates();
        }

        /**
         * setup for states of this component
         */
        protected function createAndSetStates():void {
            currentState = "normal";
            if (!isSubMenuRenderer) {
                //there is nothing fancy here, but what the compiler would do by itself, but much more simplified
                var overridesArray:Array = [
                    new AddItems().initializeFromObject({
                                                            destructionPolicy: "auto",
                                                            itemsFactory: new DeferredInstanceFromFunction(createPopupAnchor, destroyPopupAnchor),
                                                            destination: null,
                                                            propertyName: "mxmlContent",
                                                            position: "after",
                                                            relativeTo: ["labelDisplay"]
                                                        })
                ];
                states = [
                    new State({ name: "normal"}), new State({ name: "hovered"}), new State({name: "selected", overrides: overridesArray})
                ];
            } else {
                states = [
                    new State({ name: "normal"}), new State({ name: "hovered"}), new State({name: "selected"})
                ];
            }
        }

        /**
         * Destroys the popup anchor
         */
        protected function destroyPopupAnchor():void {
            _popup = null;
        }

        /**
         * Creates the popup anchor which will hold the submenu
         */
        protected function createPopupAnchor():PopUpAnchor {
            _popup = new PopUpAnchor();
            _popup.left = 0;
            _popup.right = 0;
            _popup.top = 0;
            _popup.bottom = 0;
            _popup.popUpWidthMatchesAnchorWidth = false;
            _popup.popUp = createMenu();
            if (_ownerMenu && _ownerMenu.layout is VerticalLayout) {
                _popup.popUpPosition = "right";
            }
            if (_ownerMenu && _ownerMenu.layout is HorizontalLayout) {
                _popup.popUpPosition = "below";
            }
            if (!_popup.popUpPosition) {
                _popup.popUpPosition = "right";
            }
            if (!isSubMenuRenderer) {
                if (_dataProvider.length > 0) {
                    _popup.displayPopUp = true;
                }
            }
            if (!_popup.document) {
                _popup.document = this;
            }
            if (isSubMenuRenderer) {
                addElement(_popup);
            }
            return _popup;
        }

        /**
         * Creates the sub-menu
         */
        protected function createMenu():Menu {
            _subMenu = new Menu();
            _subMenu.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseDownOutside);
            _subMenu.addEventListener(MenuEvent.SELECTED, onMenuChange);
            _subMenu.addEventListener(MenuEvent.CHECKED, onMenuChange);
            _subMenu.addEventListener(MouseEvent.ROLL_OUT, onMenuRollOut);
            _subMenu.addEventListener(MouseEvent.ROLL_OVER, onMenuRollOver);
            if (!isSubMenuRenderer) {
                //_subMenu.id = _ownerMenu.id+"_"+itemIndex;					//commented, used for debugging
                _subMenu.dataProvider = dataProvider;
                _subMenu.labelField = _ownerMenu.labelField;
                _subMenu.parentMenu = _ownerMenu;//this is mandatory for keyboard navigation
                _subMenu.setFocus();
                _subMenu.selectedIndex = 0;
            }
            if (!_subMenu.document) {
                _subMenu.document = this;
            }
            return _subMenu;
        }

        /**
         * Handler for sub-menu mouse event
         **/
        protected function onMouseDownOutside(e:FlexMouseEvent):void {
            if (isSubMenuRenderer) {
                if (selected) {
                    hovered = true;
                    return;
                }
            }
            _ownerMenu.selectedIndex = -1;
            hovered = false;
            _ownerMenu.dispatchEvent(e);
        }

        /**
         * Handler for sub-menu mouse event
         **/
        protected function onMenuChange(e:MenuEvent):void {
            if (e.type == MenuEvent.SELECTED) {
                _ownerMenu.selectedIndex = -1;
                hovered = false;
            }
            _ownerMenu.dispatchEvent(e);

        }

        /**
         *when the parent is rolled out, we trigger that we are not hovered
         **/
        protected function onMenuRollOut(e:MouseEvent):void {
            if (e.relatedObject == null || owner.contains(e.relatedObject)) {
                hovered = false;
            }
        }

        /**
         * when the parent is rolled over, if isSubMenuRenderer true
         * we have to trigger hovered
         **/
        protected function onMenuRollOver(e:MouseEvent):void {
            if (isSubMenuRenderer) {
                hovered = true;
            }
        }
    }
}
