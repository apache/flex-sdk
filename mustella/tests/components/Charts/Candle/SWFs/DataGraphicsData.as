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


// ugly to keep this in the file
package  { 


	import mx.collections.ArrayCollection;


	public class DataGraphicsData  { 

		public function DataGraphicsData() { 

		}

	[Bindable] public var adbeX:XML = 
<quotes>
<quote>
<date>Mon Jul 31 12:00:00 GMT-0800 2006</date>
<open>27.53</open>
<high>28.56</high>
<low>27.23</low>
<close>28.51</close>
<volume>5824400</volume>
</quote>
<quote>
<date>Tue Aug 01 12:00:00 GMT-0800 2006</date>
<open>28.4</open>
<high>28.97</high>
<low>28</low>
<close>28.34</close>
<volume>6898600</volume>
</quote>
<quote>
<date>Wed Aug 02 12:00:00 GMT-0800 2006</date>
<open>30</open>
<high>32.58</high>
<low>29.99</low>
<close>32.28</close>
<volume>12151100</volume>
</quote>
<quote>
<date>Thu Aug 03 12:00:00 GMT-0800 2006</date>
<open>31.55</open>
<high>32.65</high>
<low>31.3</low>
<close>32.53</close>
<volume>6407800</volume>
</quote>
<quote>
<date>Fri Aug 04 12:00:00 GMT-0800 2006</date>
<open>32.6</open>
<high>32.74</high>
<low>31.5</low>
<close>31.72</close>
<volume>5481600</volume>
</quote>
<quote>
<date>Mon Aug 07 12:00:00 GMT-0800 2006</date>
<open>31.63</open>
<high>32</high>
<low>31.13</low>
<close>31.79</close>
<volume>3815900</volume>
</quote>
</quotes>;


	[Bindable] public var adbeXNegativeData:XML = 
<quotes>
<quote>
<date>Mon Jul 31 12:00:00 GMT-0800 2006</date>
<open>27.53</open>
<high>28.56</high>
<low>27.23</low>
<close>-28.51</close>
<volume>5824400</volume>
</quote>
<quote>
<date>Tue Aug 01 12:00:00 GMT-0800 2006</date>
<open>28.4</open>
<high>28.97</high>
<low>28</low>
<close>28.34</close>
<volume>6898600</volume>
</quote>
<quote>
<date>Wed Aug 02 12:00:00 GMT-0800 2006</date>
<open>30</open>
<high>32.58</high>
<low>29.99</low>
<close>32.28</close>
<volume>12151100</volume>
</quote>
<quote>
<date>Thu Aug 03 12:00:00 GMT-0800 2006</date>
<open>31.55</open>
<high>32.65</high>
<low>31.3</low>
<close>32.53</close>
<volume>6407800</volume>
</quote>
<quote>
<date>Fri Aug 04 12:00:00 GMT-0800 2006</date>
<open>32.6</open>
<high>32.74</high>
<low>31.5</low>
<close>-31.72</close>
<volume>5481600</volume>
</quote>
<quote>
<date>Mon Aug 07 12:00:00 GMT-0800 2006</date>
<open>31.63</open>
<high>32</high>
<low>31.13</low>
<close>31.79</close>
<volume>3815900</volume>
</quote>
</quotes>;	
		

		public function getDataAsXMLList():XMLList { 
			return adbeX.elements("quote");
		}

		public function getNegativeDataAsXMLList():XMLList { 
			return adbeXNegativeData.elements("quote");
		}

		
	}

}
