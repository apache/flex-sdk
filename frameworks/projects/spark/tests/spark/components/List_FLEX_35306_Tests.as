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
    import flash.events.EventDispatcher;

    import mx.collections.ArrayCollection;
    import mx.collections.IList;
    import mx.core.mx_internal;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.async.Async;
    import org.flexunit.runners.Parameterized;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.skins.spark.ListSkin;

    use namespace mx_internal;

    [RunWith("org.flexunit.runners.Parameterized")]
    public class List_FLEX_35306_Tests
    {
        private static var foo:Parameterized;

        private static const NO_ENTER_FRAMES_TO_ALLOW:int = 4;
        private static var noEnterFramesRemaining:int = NaN;
        private static const _finishNotifier:EventDispatcher = new EventDispatcher();

        private static var _sut:_ListWithMXMLBinding;

        private static var _hqRedmond:_HeadquarterVO;
        private static var _hqSantaClara:_HeadquarterVO;
        private static var _hqBerlin:_HeadquarterVO;
        private static var _hqMunchen:_HeadquarterVO;
        private static var _hqNewYork:_HeadquarterVO;
        private static var _hqSantaMaria:_HeadquarterVO;
        private static var _hqSantaDolores:_HeadquarterVO;

        [Bindable]
        public var selectedCompany:_CompanyVO;
        [Bindable]
        public var potentialHeadquarters:IList;

        public static var models:Array;
        {
            models = [[createListOfCompaniesWithOnePotentialAddressEach()], [createListOfCompaniesWithMultiplePotentialAddresses()]];
        }

        [AfterClass]
        public static function tearDownStatic():void
        {
            models = null;
        }

        [Before]
        public function setUp():void
        {
            _sut = new _ListWithMXMLBinding();
            _sut.container = this;
            _sut.setStyle("skinClass", ListSkin);
            _sut.requireSelection = true;
        }

        [After]
        public function tearDown():void
        {
            UIImpersonator.removeAllChildren();
            _sut = null;
        }

        [Test(order=2, async, timeout=1000, dataProvider="models", description="this should run after the main test because it rewrites the model")]
        public function test_double_binding(companies:IList):void
        {
            //given
            const firstCompany:_CompanyVO = companies.getItemAt(0) as _CompanyVO;
            const secondCompany:_CompanyVO = companies.getItemAt(1) as _CompanyVO;
            const secondCompanyHQ:_HeadquarterVO = secondCompany.originalHeadquarter;
            selectedCompany = firstCompany;

            UIImpersonator.addElement(_sut);

            //when 1
            selectedCompany = secondCompany;
            potentialHeadquarters = secondCompany.potentialHeadquarters;

            //then 1 - wait some frames until there's a selection
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_check_binding_from_bindable_var_to_list, 400, {companies:companies, expectedHQ:secondCompanyHQ});
        }

        private function then_check_binding_from_bindable_var_to_list(event:Event, passThroughData:Object):void
        {
            //given
            const companies:IList = passThroughData.companies;
            const expectedHQ:_HeadquarterVO = passThroughData.expectedHQ as _HeadquarterVO;
            const thirdCompany:_CompanyVO = companies.getItemAt(2) as _CompanyVO;

            //then
            assertEquals("The list's selected item didn't change (correctly?) when we changed the associated bindable variable!", expectedHQ, _sut.selectedItem);

            //given 2
            var extraHQ:_HeadquarterVO = new _HeadquarterVO("hello", "address");

            //when 2
            thirdCompany.potentialHeadquarters.addItem(extraHQ);
            potentialHeadquarters = thirdCompany.potentialHeadquarters;
            selectedCompany = thirdCompany;
            _sut.selectedItem = extraHQ;

            //then 2 - wait some frames until there's a selection
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_check_binding_from_list_to_bindable_var, 400, {companies:companies, expectedHQ:extraHQ});
        }

        private function then_check_binding_from_list_to_bindable_var(event:Event, passThroughData:Object):void
        {
            //given
            const companies:IList = passThroughData.companies as IList;
            const expectedHQ:_HeadquarterVO = passThroughData.expectedHQ as _HeadquarterVO;

            //then 2
            assertEquals("The binding destination didn't change (correctly?) when we changed the list's selectedItem!", expectedHQ, selectedCompany.headquarter);

            //cleanup
            const thirdCompany:_CompanyVO = companies.getItemAt(2) as _CompanyVO;
            thirdCompany.potentialHeadquarters.removeItem(expectedHQ);
        }





        [Test(order=1, async, timeout=1000, dataProvider="models")]
        public function test_list_doesnt_rewrite_model(companies:IList):void
        {
            //given
            const secondCompany:_CompanyVO = companies.getItemAt(1) as _CompanyVO;

            //when
            selectedCompany = secondCompany;
            potentialHeadquarters = secondCompany.potentialHeadquarters;

            UIImpersonator.addElement(_sut);

            //then - wait some frames until there's a selection
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_change_dp_and_selected_item, 400, companies);
        }

        private function then_change_dp_and_selected_item(event:Event, passThroughData:Object):void
        {
            //given
            const model:IList = passThroughData as IList;
            const secondCompany:_CompanyVO = model.getItemAt(1) as _CompanyVO;
            const thirdCompany:_CompanyVO = model.getItemAt(2) as _CompanyVO;

            //then
            assertNotNull(secondCompany.headquarter); //HUH?
            assertEquals("The selection should be " + secondCompany.headquarter.name + "!", secondCompany.originalHeadquarter, _sut.selectedItem);

            //when
            selectedCompany = thirdCompany;
            potentialHeadquarters = thirdCompany.potentialHeadquarters;

            //then - wait some frames until the selection has changed
            noEnterFramesRemaining = NO_ENTER_FRAMES_TO_ALLOW;
            UIImpersonator.testDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            Async.handleEvent(this, _finishNotifier, Event.COMPLETE, then_check_if_model_has_been_rewritten, 400, model);
        }

        private static function then_check_if_model_has_been_rewritten(event:Event, passThroughData:Object):void
        {
            //given
            const model:IList = passThroughData as IList;
            const thirdCompany:_CompanyVO = model.getItemAt(2) as _CompanyVO;
            const expectedHQ:_HeadquarterVO = thirdCompany.originalHeadquarter;

            //then
            assertEquals("The selection should be " + expectedHQ.name + "!", expectedHQ, _sut.selectedItem);

            assertCompaniesHaveCorrectHQ(model);
            assertNoCompanyHQWasRewritten(model);
        }

        private static function assertCompaniesHaveCorrectHQ(companiesList:IList):void
        {
            for each(var company:_CompanyVO in companiesList)
            {
                assertEquals("The headquarter of " + company.name + " has been changed to an invalid value!", company.originalHeadquarter, company.headquarter);
            }
        }

        private static function assertNoCompanyHQWasRewritten(companiesList:IList):void
        {
            for each(var company:_CompanyVO in companiesList)
            {
                assertFalse("The headquarter of " + company.name + " has been rewritten, although with the correct value in the end", company.headquarterRewritten);
            }
        }

        private static function onEnterFrame(event:Event):void
        {
            if(!--noEnterFramesRemaining)
            {
                UIImpersonator.testDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _finishNotifier.dispatchEvent(new Event(Event.COMPLETE));
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Set up methods
        //
        //--------------------------------------------------------------------------

        private static function createListOfCompaniesWithMultiplePotentialAddresses():IList
        {
            createHeadquartersIfNeeded();

            var microsoft:_CompanyVO = new _CompanyVO("Microsoft", _hqRedmond, new ArrayCollection([_hqRedmond, _hqNewYork]));
            var intel:_CompanyVO = new _CompanyVO("Intel", _hqSantaClara, new ArrayCollection([_hqSantaClara, _hqSantaMaria, _hqSantaDolores]));
            var wv:_CompanyVO = new _CompanyVO("VW", _hqBerlin, new ArrayCollection([_hqBerlin, _hqMunchen]));

            return new ArrayCollection([microsoft, intel, wv]);
        }

        private static function createListOfCompaniesWithOnePotentialAddressEach():IList
        {
            createHeadquartersIfNeeded();

            var microsoft:_CompanyVO = new _CompanyVO("Microsoft", _hqRedmond, new ArrayCollection([_hqRedmond]));
            var intel:_CompanyVO = new _CompanyVO("Intel", _hqSantaClara, new ArrayCollection([_hqSantaClara]));
            var wv:_CompanyVO = new _CompanyVO("VW", _hqBerlin, new ArrayCollection([_hqBerlin]));

            return new ArrayCollection([microsoft, intel, wv]);
        }

        private static function createHeadquartersIfNeeded():void
        {
            if(_hqRedmond)
                return;

            _hqRedmond = new _HeadquarterVO("Redmond", "redmond address 123");
            _hqNewYork = new _HeadquarterVO("New York", "NY address 123");
            _hqSantaClara = new _HeadquarterVO("Santa Clara", "santa clara address 123");
            _hqSantaMaria = new _HeadquarterVO("Santa Maria", "santa maria address 123");
            _hqSantaDolores = new _HeadquarterVO("Santa Dolores", "santa dolores address 123");
            _hqBerlin = new _HeadquarterVO("Berlin", "berlin address 123");
            _hqMunchen = new _HeadquarterVO("Munchen", "munchen address 123");
        }
    }
}