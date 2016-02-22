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

package mx.binding.utils {
    import mx.events.PropertyChangeEvent;
    import mx.events.PropertyChangeEventKind;
    import mx.utils.ObjectUtil;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertTrue;

    public class BindingUtils_Tests
    {
        private static var noTimesStreetBindingTriggered:int;
        private static var noTimesStreetNumberBindingTriggered:int;
        private static var address:AddressVO;
        private static var addressWatcher:ChangeWatcher;
        private static var addressNumberWatcher:ChangeWatcher;
        private static var PROPERTY_CHANGE_EVENT:PropertyChangeEvent;
        private static var PROPERTY_CHANGE_EVENT_UPDATE:PropertyChangeEvent;
        private static var PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE:PropertyChangeEvent;

        private static const STREET_INITIAL:String = "La Rambla";
        private static const STREET_OTHER:String = "Champs-Elysées";
        private static const STREET_NO_INITIAL:int = 23;
        private static const STREET_NO_OTHER:int = 54;

        [Before]
        public function setUp():void
        {
            noTimesStreetBindingTriggered = 0;
            noTimesStreetNumberBindingTriggered = 0;

            PROPERTY_CHANGE_EVENT = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
            PROPERTY_CHANGE_EVENT_UPDATE = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE);
            PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE = PropertyChangeEvent.createUpdateEvent(null, null, null, null);

            address = new AddressVO(STREET_INITIAL, STREET_NO_INITIAL);

            addressWatcher = BindingUtils.bindSetter(setStreet, address, "street", false, false);
            addressNumberWatcher = BindingUtils.bindSetter(setStreetNumber, address, "number", false, false);
        }

        [After]
        public function tearDown():void
        {
            addressWatcher.unwatch();
            addressNumberWatcher.unwatch();

            PROPERTY_CHANGE_EVENT = null;
            PROPERTY_CHANGE_EVENT_UPDATE = null;
            PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE = null;
        }

        [Test]
        public function test_binding_triggered_at_binding_definition():void
        {
            //then
            assertTrue(1, noTimesStreetBindingTriggered);
            assertTrue(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_triggered_at_manual_property_change():void
        {
            //when
            address.street = STREET_OTHER;
            address.number = STREET_NO_OTHER;

            //then
            assertTrue(2, noTimesStreetBindingTriggered);
            assertTrue(2, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_not_triggered_at_generic_PropertyChangeEvent_dispatch():void
        {
            //when
            address.dispatchEvent(PROPERTY_CHANGE_EVENT);

            //then
            assertEquals(1, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_PropertyChangeEvents_equivalent():void
        {
            //when
            var eventComparison:int = ObjectUtil.compare(PROPERTY_CHANGE_EVENT_UPDATE, PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE);

            //then
            assertEquals(0, eventComparison);
        }

        [Test]
        public function test_binding_not_triggered_at_PropertyChangeEvent_UPDATE_dispatch():void
        {
            //when
            address.dispatchEvent(PROPERTY_CHANGE_EVENT_UPDATE);

            //then
            assertEquals(1, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_not_triggered_at_PropertyChangeEvent_UPDATE_dispatch_created_with_nulls_in_convenience_method():void
        {
            //when
            address.dispatchEvent(PROPERTY_CHANGE_EVENT_UPDATE_CONVENIENCE);

            //then
            assertEquals(1, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_triggered_at_PropertyChangeEvent_UPDATE_dispatch_created_with_expected_values_in_convenience_method():void
        {
            //when
            address.dispatchEvent(PropertyChangeEvent.createUpdateEvent(address, "street", address.street, STREET_OTHER));

            //then
            assertEquals(2, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_triggered_at_PropertyChangeEvent_UPDATE_dispatch_created_with_expected_values_except_source():void
        {
            //when
            address.dispatchEvent(PropertyChangeEvent.createUpdateEvent(null, "street", address.street, STREET_OTHER));

            //then
            assertEquals(2, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_triggered_at_PropertyChangeEvent_UPDATE_dispatch_created_only_with_property_name():void
        {
            //when
            address.dispatchEvent(PropertyChangeEvent.createUpdateEvent(null, "street", null, null));

            //then
            assertEquals(2, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        [Test]
        public function test_binding_triggered_at_PropertyChangeEvent_UPDATE_dispatch_created_with_expected_values():void
        {
            //when
            address.dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, "street", address.street, STREET_OTHER, address));

            //then
            assertEquals(2, noTimesStreetBindingTriggered);
            assertEquals(1, noTimesStreetNumberBindingTriggered);
        }

        private static function setStreet(newStreet:String):void
        {
            noTimesStreetBindingTriggered++;
        }

        private static function setStreetNumber(newStreetNumber:int):void
        {
            noTimesStreetNumberBindingTriggered++;
        }
    }
}

[Bindable]
class AddressVO
{
    public var street:String;
    public var number:int;

    public function AddressVO(street:String, number:int)
    {
        this.street = street;
        this.number = number;
    }
}