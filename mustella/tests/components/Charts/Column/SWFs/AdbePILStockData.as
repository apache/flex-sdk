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


	public class AdbePILStockData  { 

		public function AdbePILStockData() { 

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
<!--<quote>
<date>Tue Aug 08 12:00:00 GMT-0800 2006</date>
<open>32.01</open>
<high>32.7</high>
<low>31.71</low>
<close>31.95</close>
<volume>4080200</volume>
</quote>
<quote>
<date>Wed Aug 09 12:00:00 GMT-0800 2006</date>
<open>32.14</open>
<high>32.49</high>
<low>31.35</low>
<close>31.45</close>
<volume>3558800</volume>
</quote>
<quote>
<date>Thu Aug 10 12:00:00 GMT-0800 2006</date>
<open>31.53</open>
<high>32.37</high>
<low>31.44</low>
<close>32.2</close>
<volume>3010100</volume>
</quote>
<quote>
<date>Fri Aug 11 12:00:00 GMT-0800 2006</date>
<open>32.07</open>
<high>32.27</high>
<low>31.52</low>
<close>31.85</close>
<volume>3479800</volume>
</quote>
<quote>
<date>Mon Aug 14 12:00:00 GMT-0800 2006</date>
<open>32.19</open>
<high>32.89</high>
<low>31.9</low>
<close>32.51</close>
<volume>3625900</volume>
</quote>
<quote>
<date>Tue Aug 15 12:00:00 GMT-0800 2006</date>
<open>32.7</open>
<high>34</high>
<low>32.64</low>
<close>33.95</close>
<volume>6188500</volume>
</quote>
<quote>
<date>Wed Aug 16 12:00:00 GMT-0800 2006</date>
<open>34</open>
<high>34.12</high>
<low>33.28</low>
<close>33.99</close>
<volume>4771400</volume>
</quote>
<quote>
<date>Thu Aug 17 12:00:00 GMT-0800 2006</date>
<open>33.75</open>
<high>34.19</high>
<low>33.45</low>
<close>34.01</close>
<volume>5097100</volume>
</quote>
<quote>
<date>Fri Aug 18 12:00:00 GMT-0800 2006</date>
<open>34</open>
<high>34.55</high>
<low>33.76</low>
<close>34.07</close>
<volume>4059100</volume>
</quote>
<quote>
<date>Mon Aug 21 12:00:00 GMT-0800 2006</date>
<open>33.8</open>
<high>33.99</high>
<low>33.18</low>
<close>33.18</close>
<volume>3575500</volume>
</quote>
<quote>
<date>Tue Aug 22 12:00:00 GMT-0800 2006</date>
<open>33.17</open>
<high>33.47</high>
<low>32.31</low>
<close>32.78</close>
<volume>5448000</volume>
</quote>
<quote>
<date>Wed Aug 23 12:00:00 GMT-0800 2006</date>
<open>32.91</open>
<high>32.99</high>
<low>32.14</low>
<close>32.41</close>
<volume>2674100</volume>
</quote>
<quote>
<date>Thu Aug 24 12:00:00 GMT-0800 2006</date>
<open>32.73</open>
<high>32.77</high>
<low>32.27</low>
<close>32.63</close>
<volume>1807000</volume>
</quote>
<quote>
<date>Fri Aug 25 12:00:00 GMT-0800 2006</date>
<open>32.41</open>
<high>32.96</high>
<low>32.41</low>
<close>32.53</close>
<volume>2143800</volume>
</quote>
<quote>
<date>Mon Aug 28 12:00:00 GMT-0800 2006</date>
<open>32.43</open>
<high>33</high>
<low>32.26</low>
<close>32.86</close>
<volume>2565100</volume>
</quote>
<quote>
<date>Tue Aug 29 12:00:00 GMT-0800 2006</date>
<open>32.92</open>
<high>32.98</high>
<low>31.51</low>
<close>31.86</close>
<volume>6086100</volume>
</quote>
<quote>
<date>Wed Aug 30 12:00:00 GMT-0800 2006</date>
<open></open>
<high></high>
<low></low>
<close></close>
<volume></volume>
</quote>
<quote>
<date>Thu Aug 31 12:00:00 GMT-0800 2006</date>
<open>32.23</open>
<high>32.75</high>
<low>32.01</low>
<close>32.44</close>
<volume>4030100</volume>
</quote>
<quote>
<date>Fri Sep 01 12:00:00 GMT-0800 2006</date>
<open>32.44</open>
<high>33.04</high>
<low>32</low>
<close>32.33</close>
<volume>2375400</volume>
</quote>
<quote>
<date>Tue Sep 05 12:00:00 GMT-0800 2006</date>
<open>32.15</open>
<high>32.95</high>
<low>32</low>
<close>32.67</close>
<volume>2343500</volume>
</quote>
<quote>
<date>Wed Sep 06 12:00:00 GMT-0800 2006</date>
<open>32.4</open>
<high>32.87</high>
<low>32</low>
<close>32.72</close>
<volume>3869100</volume>
</quote>
<quote>
<date>Thu Sep 07 12:00:00 GMT-0800 2006</date>
<open>32.49</open>
<high>32.73</high>
<low>31.49</low>
<close>31.5</close>
<volume>4359500</volume>
</quote>
<quote>
<date>Fri Sep 08 12:00:00 GMT-0800 2006</date>
<open>31.6</open>
<high>32.14</high>
<low>31.01</low>
<close>31.81</close>
<volume>3510100</volume>
</quote>
<quote>
<date>Mon Sep 11 12:00:00 GMT-0800 2006</date>
<open>31.42</open>
<high>32.37</high>
<low>31</low>
<close>31.84</close>
<volume>3426500</volume>
</quote>
<quote>
<volume>3801100</volume>
</quote>
<quote>
<date>Wed Sep 13 12:00:00 GMT-0800 2006</date>
<open>32.67</open>
<high>33.6</high>
<low>31.94</low>
<close>33.53</close>
<volume>5773400</volume>
</quote>
<quote>
<date>Thu Sep 14 12:00:00 GMT-0800 2006</date>
<open>33.54</open>
<high>33.81</high>
<low>32.95</low>
<close>33.65</close>
<volume>8652700</volume>
</quote>
<quote>
<date>Fri Sep 15 12:00:00 GMT-0800 2006</date>
<open>36.62</open>
<high>38.19</high>
<low>36.5</low>
<close>37</close>
<volume>33444300</volume>
</quote>
<quote>
<date>Mon Sep 18 12:00:00 GMT-0800 2006</date>
<open>36.23</open>
<high>37.77</high>
<low>36.23</low>
<close>37.51</close>
<volume>9228200</volume>
</quote>
<quote>
<date>Tue Sep 19 12:00:00 GMT-0800 2006</date>
<open>37.33</open>
<high>37.75</high>
<low>36.9</low>
<close>37.34</close>
<volume>5716100</volume>
</quote>
<quote>
<date>Wed Sep 20 12:00:00 GMT-0800 2006</date>
<open>37.33</open>
<high>37.81</high>
<low>37.28</low>
<close>37.7</close>
<volume>7012000</volume>
</quote>
<quote>
<date>Thu Sep 21 12:00:00 GMT-0800 2006</date>
<open>37.83</open>
<high>38.12</high>
<low>37.06</low>
<close>37.4</close>
<volume>4671600</volume>
</quote>
<quote>
<date>Fri Sep 22 12:00:00 GMT-0800 2006</date>
<open>37.4</open>
<high>37.73</high>
<low>36.56</low>
<close>37.06</close>
<volume>5190800</volume>
</quote>
<quote>
<date>Mon Sep 25 12:00:00 GMT-0800 2006</date>
<open>null</open>
<high>null</high>
<low>null</low>
<close>null</close>
<volume>10304500</volume>
</quote>
<quote>
<date>Tue Sep 26 12:00:00 GMT-0800 2006</date>
<open>38.19</open>
<high>38.5</high>
<low>37.62</low>
<close>37.67</close>
<volume>5634200</volume>
</quote>
<quote>
<date>Wed Sep 27 12:00:00 GMT-0800 2006</date>
<open>37.7</open>
<high>38.61</high>
<low>37.6</low>
<close>38.06</close>
<volume>5003600</volume>
</quote>
<quote>
<date>Thu Sep 28 12:00:00 GMT-0800 2006</date>
<open>38.22</open>
<high>38.6</high>
<low>37.58</low>
<close>38.33</close>
<volume>3447900</volume>
</quote>
<quote>
<date>Fri Sep 29 12:00:00 GMT-0800 2006</date>
<open>38.15</open>
<high>38.38</high>
<low>37.43</low>
<close>37.46</close>
<volume>4248100</volume>
</quote>
<quote>
<date>Mon Oct 02 12:00:00 GMT-0800 2006</date>
<open>37.54</open>
<high>37.82</high>
<low>36.8</low>
<close>37</close>
<volume>3678100</volume>
</quote>
<quote>
<date>Tue Oct 03 12:00:00 GMT-0800 2006</date>
<open>36.88</open>
<high>37.64</high>
<low>36.72</low>
<close>36.75</close>
<volume>4116600</volume>
</quote>
<quote>
<date>Wed Oct 04 12:00:00 GMT-0800 2006</date>
<open>36.75</open>
<high>37.91</high>
<low>36.69</low>
<close>37.76</close>
<volume>6851500</volume>
</quote>
<quote>
<date>Thu Oct 05 12:00:00 GMT-0800 2006</date>
<open>37.56</open>
<high>38.41</high>
<low>37.54</low>
<close>38.18</close>
<volume>4271600</volume>
</quote>
<quote>
<date>Fri Oct 06 12:00:00 GMT-0800 2006</date>
<open>38.25</open>
<high>38.3</high>
<low>37.57</low>
<close>38.15</close>
<volume>3142200</volume>
</quote>
<quote>
<date>Mon Oct 09 12:00:00 GMT-0800 2006</date>
<open>38.08</open>
<high>38.22</high>
<low>37.27</low>
<close>37.39</close>
<volume>3835200</volume>
</quote>
<quote>
<date>Tue Oct 10 12:00:00 GMT-0800 2006</date>
<open>37.43</open>
<high>37.98</high>
<low>37.23</low>
<close>37.77</close>
<volume>3518600</volume>
</quote>-->
</quotes>;

/// { date: "Wed Aug 30 12:00:00 GMT-0800 2006", open: 31.81, high: 32.13, low: 31.75, close: 32.05, volume: 4485900},
// { date: "Wed Aug 30 12:00:00 GMT-0800 2006", open: , high: , low: , close: , volume: },

	[Bindable] public var adbeA:Array = [
{date: "Mon Jul 31 12:00:00 GMT-0800 2006", open: 27.53, high: 28.56, low: 27.23, close: 28.51, volume: 5824400},
{date: "Tue Aug 01 12:00:00 GMT-0800 2006", open: 28.4, high: 28.97, low: 28, close: 28.34, volume: 6898600},
{ date: "Wed Aug 02 12:00:00 GMT-0800 2006", open: 30, high: 32.58, low: 29.99, close: 32.28, volume: 12151100},
{date: "Thu Aug 03 12:00:00 GMT-0800 2006", open: 31.55, high: 32.65, low: 31.3, close: 32.53, volume: 6407800},
{ date: "Fri Aug 04 12:00:00 GMT-0800 2006", open: 32.6, high: 32.74, low: 31.5, close: 31.72, volume: 5481600},
{ date: "Mon Aug 07 12:00:00 GMT-0800 2006", open: 31.63, high: 32, low: 31.13, close: 31.79, volume: 3815900},
{ date: "Tue Aug 08 12:00:00 GMT-0800 2006", open: 32.01, high: 32.7, low: 31.71, close: 31.95, volume: 4080200},
{ date: "Wed Aug 09 12:00:00 GMT-0800 2006", open: 32.14, high: 32.49, low: 31.35, close: 31.45, volume: 3558800},
{ date: "Thu Aug 10 12:00:00 GMT-0800 2006", open: 31.53, high: 32.37, low: 31.44, close: 32.2, volume: 3010100},
{ date: "Fri Aug 11 12:00:00 GMT-0800 2006", open: 32.07, high: 32.27, low: 31.52, close: 31.85, volume: 3479800},
{ date: "Mon Aug 14 12:00:00 GMT-0800 2006", open: 32.19, high: 32.89, low: 31.9, close: 32.51, volume: 3625900},
{ date: "Tue Aug 15 12:00:00 GMT-0800 2006", open: 32.7, high: 34, low: 32.64, close: 33.95, volume: 6188500},
{ date: "Wed Aug 16 12:00:00 GMT-0800 2006", open: 34, high: 34.12, low: 33.28, close: 33.99, volume: 4771400},
{ date: "Thu Aug 17 12:00:00 GMT-0800 2006", open: 33.75, high: 34.19, low: 33.45, close: 34.01, volume: 5097100},
{ date: "Fri Aug 18 12:00:00 GMT-0800 2006", open: 34, high: 34.55, low: 33.76, close: 34.07, volume: 4059100},
{ date: "Mon Aug 21 12:00:00 GMT-0800 2006", open: 33.8, high: 33.99, low: 33.18, close: 33.18, volume: 3575500},
{ date: "Tue Aug 22 12:00:00 GMT-0800 2006", open: 33.17, high: 33.47, low: 32.31, close: 32.78, volume: 5448000},
{ date: "Wed Aug 23 12:00:00 GMT-0800 2006", open: 32.91, high: 32.99, low: 32.14, close: 32.41, volume: 2674100},
{ date: "Thu Aug 24 12:00:00 GMT-0800 2006", open: 32.73, high: 32.77, low: 32.27, close: 32.63, volume: 1807000},
{ date: "Fri Aug 25 12:00:00 GMT-0800 2006", open: 32.41, high: 32.96, low: 32.41, close: 32.53, volume: 2143800},
{ date: "Mon Aug 28 12:00:00 GMT-0800 2006", open: 32.43, high: 33, low: 32.26, close: 32.86, volume: 2565100},
{ date: "Tue Aug 29 12:00:00 GMT-0800 2006", open: 32.92, high: 32.98, low: 31.51, close: 31.86, volume: 6086100},
{ date: "Wed Aug 30 12:00:00 GMT-0800 2006", open: 31.81, high: 32.13, low: 31.75, close: 32.05, volume: 4485900},
{ date: "Thu Aug 31 12:00:00 GMT-0800 2006", open: 32.23, high: 32.75, low: 32.01, close: 32.44, volume: 4030100},
{ date: "Fri Sep 01 12:00:00 GMT-0800 2006", open: 32.44, high: 33.04, low: 32, close: 32.33, volume: 2375400},
{ date: "Tue Sep 05 12:00:00 GMT-0800 2006", open: 32.15, high: 32.95, low: 32, close: 32.67, volume: 2343500},
{ date: "Wed Sep 06 12:00:00 GMT-0800 2006", open: 32.4, high: 32.87, low: 32, close: 32.72, volume: 3869100},
{ date: "Thu Sep 07 12:00:00 GMT-0800 2006", open: 32.49, high: 32.73, low: 31.49, close: 31.5, volume: 4359500},
{ date: "Fri Sep 08 12:00:00 GMT-0800 2006", open: 31.6, high: 32.14, low: 31.01, close: 31.81, volume: 3510100},
{ date: "Mon Sep 11 12:00:00 GMT-0800 2006", open: 31.42, high: 32.37, low: 31, close: 31.84, volume: 3426500},
{ volume: 3801100},
{ date: "Wed Sep 13 12:00:00 GMT-0800 2006", open: 32.67, high: 33.6, low: 31.94, close: 33.53, volume: 5773400},
{ date: "Thu Sep 14 12:00:00 GMT-0800 2006", open: 33.54, high: 33.81, low: 32.95, close: 33.65, volume: 8652700},
{ date: "Fri Sep 15 12:00:00 GMT-0800 2006", open: 36.62, high: 38.19, low: 36.5, close: 37, volume: 33444300},
{ date: "Mon Sep 18 12:00:00 GMT-0800 2006", open: 36.23, high: 37.77, low: 36.23, close: 37.51, volume: 9228200},
{ date: "Tue Sep 19 12:00:00 GMT-0800 2006", open: 37.33, high: 37.75, low: 36.9, close: 37.34, volume: 5716100},
{ date: "Wed Sep 20 12:00:00 GMT-0800 2006", open: 37.33, high: 37.81, low: 37.28, close: 37.7, volume: 7012000},
{ date: "Thu Sep 21 12:00:00 GMT-0800 2006", open: 37.83, high: 38.12, low: 37.06, close: 37.4, volume: 4671600},
{ date: "Fri Sep 22 12:00:00 GMT-0800 2006", open: 37.4, high: 37.73, low: 36.56, close: 37.06, volume: 5190800},
{ date: null, open: null, high: null, low: null, close: null, volume: 10304500},
{ date: "Tue Sep 26 12:00:00 GMT-0800 2006", open: 38.19, high: 38.5, low: 37.62, close: 37.67, volume: 5634200},
{ date: "Wed Sep 27 12:00:00 GMT-0800 2006", open: 37.7, high: 38.61, low: 37.6, close: 38.06, volume: 5003600},
{ date: "Thu Sep 28 12:00:00 GMT-0800 2006", open: 38.22, high: 38.6, low: 37.58, close: 38.33, volume: 3447900},
{ date: "Fri Sep 29 12:00:00 GMT-0800 2006", open: 38.15, high: 38.38, low: 37.43, close: 37.46, volume: 4248100},
{ date: "Mon Oct 02 12:00:00 GMT-0800 2006", open: 37.54, high: 37.82, low: 36.8, close: 37, volume: 3678100},
{ date: "Tue Oct 03 12:00:00 GMT-0800 2006", open: 36.88, high: 37.64, low: 36.72, close: 36.75, volume: 4116600},
{ date: "Wed Oct 04 12:00:00 GMT-0800 2006", open: 36.75, high: 37.91, low: 36.69, close: 37.76, volume: 6851500},
{ date: "Thu Oct 05 12:00:00 GMT-0800 2006", open: 37.56, high: 38.41, low: 37.54, close: 38.18, volume: 4271600},
{ date: "Fri Oct 06 12:00:00 GMT-0800 2006", open: 38.25, high: 38.3, low: 37.57, close: 38.15, volume: 3142200},
{ date: "Mon Oct 09 12:00:00 GMT-0800 2006", open: 38.08, high: 38.22, low: 37.27, close: 37.39, volume: 3835200},
{ date: "Tue Oct 10 12:00:00 GMT-0800 2006", open: 37.43, high: 37.98, low: 37.23, close: 37.77, volume: 3518600}];



		public function getHighFieldName():String { 
			return "high";
		}

		public function getLowFieldName():String { 
			return "low";
		}

		public function getCloseFieldName():String { 
			return "close";
		}

		public function getOpenFieldName():String { 
			return "open";
		}

		public function getDefaultYFieldName():String { 
			return "close";
		}

		public function getDefaultXFieldName():String { 
			return "date";
		}

		public function getData():Array { 
			return [ adbeA ];
		}

		public function getDataAsArray():Array { 
			return adbeA;
		}

		public function getDataAsCollection():ArrayCollection { 
			return new ArrayCollection(adbeA);
		}

		public function getDataAsXMLList():XMLList { 
			return adbeX.elements("quote");
		}

		public function getDataAsXML():XML { 
			return adbeX;
		}

		public function getName():String { 
			return "adbe";
		}


	}

}
