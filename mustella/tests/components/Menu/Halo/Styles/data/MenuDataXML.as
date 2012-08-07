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
package data {

    public class MenuDataXML  {
    
        public var myData:XML;
        public function MenuDataXML(): void
        {
            myData =
			    <topnode>
					<node label="Europe" data="EUROPE">
						<nodeitem type="check" label="Italy" data="ITALY" />
						<nodeitem type="check" label="England" data="ENGLAND" toggled="true"/>
						<nodeitem type="check" label="Slovenia" data="SLOVENIA" />
					</node>
					<node label="Asia" enabled="true" data="ASIA">
					    <nodeitem type="radio" groupName="group1" label="Phillipines" data="PHILIPPINES"/>
					    <nodeitem type="radio" groupName="group1" label="Japan" data="JAPAN"/>
					    <nodeitem type="radio" groupName="group1" label="China" data="CHINA"/>
					</node>
					<node label="Africa" data="AFRICA">
						<nodeitem label="Uganda"  data="UGANDA" enabled="false"/>
						<nodeitem label="South Africa" data="SOUTH AFRICA" />
						<nodeitem label="Nigeria" data="NIGERIA"/>
					</node>
	             </topnode>;
        }
    }
}