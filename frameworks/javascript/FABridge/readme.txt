== What Is the Flex AJAX Bridge? ==

The Flex AJAX Bridge (FABridge) is a small, unobtrusive code library that you can insert 
into an Apache® Flex application, a Flex component, or even an empty SWF file to expose 
it to scripting in the browser. It is being released to the community under the Apache
Software Foundation, v2 license.  See http://www.apache.org/licenses/LICENSE-2.0.

To humbly borrow a page from the Ruby on Rails community, FABridge is built with the 
"don't repeat yourself" principle in mind. Rather than having to define new, simplified 
APIs to expose a graph of ActionScript objects to JavaScript, with FABridge you can make 
your ActionScript classes available to JavaScript without any additional coding. After you
insert the library, essentially anything you can do with ActionScript, you can do with 
JavaScript.

Adobe® Flash® Player has the native ability, through the External API (the 
ExternalInterface class), to call JavaScript from ActionScript, and vice versa. But 
ExternalInterface has some limitations:
* The ExternalInterface class requires you, the developer, to write a library of extra 
code in both ActionScript and JavaScript, to expose the functionality of your Flex 
application to JavaScript, and vice versa.  
* The ExternalInterface class also limits what you can pass across the gap. Primitive 
types, arrays, and simple objects are legal, but user-defined classes, with associated 
properties and methods, are off-limits. 
* The ExternalInterface class enables you to define an interface so your JavaScript can 
call your ActionScript. FABridge essentially lets you write JavaScript instead of 
ActionScript.

== When Should I Use the Flex AJAX Bridge? ==

The FABridge library is useful in the following situations:
* You want to use a rich Flex component in an AJAX application but do not want to write a 
lot of Flex code. If you wrap the component in a FABridge-enabled stub application, you 
can script it entirely from JavaScript, including using eval()’d JavaScript generated 
remotely by the server.
* You have only one or two people on your team who know Flex.  Although I would strongly 
encourage everyone to grab a copy of Flex and try it out (you will love it, I promise!), 
the FABridge library lets everyone on your team use the work produced by one or two Flex 
specialists.
* You are building an integrated rich Internet application (RIA) with both Flex and AJAX 
portions.  While you could build the integration yourself using ExternalInterface, you 
might find it faster to start with the FABridge as a head start.

== What Do I Need to Use It? ==

To use the FABridge library and samples, you must have the following:
* AJAX Bridge, which is included in the following directory of the LiveCycle Data 
Services installation:

installation_dir\resources\FABridge

* Flex 2 SDK included in the LiveCycle Data Services installation
* Flash Player 9
* Microsoft Internet Explorer, Mozilla Firefox, or Opera with JavaScript enabled
* Any HTTP server to run the samples

== Download and Installation ==

To run the sample files, follow these steps:

1. Copy the src and samples directories from the install_dir\resources\FABridge directory 
of the LiveCycle Data Services installation side by side on any HTTP server.
2. Open a web browser to <your web server>/samples/FABridgeSample.html and 
samples/SimpleSample.html and follow the instructions there.

Make sure you access the samples through http:// URLs and not file:// URLs. The Flash 
Player security sandbox may prevent them from working correctly if accessed as local files.

== How Do I Use the Flex AJAX Bridge? ==

To use the FABridge library in your own Flex and AJAX applications, follow these steps:
* Add the src folder to the ActionScript <code>classpath</code> of your Flex application.
* If you are compiling from the command line, you can add the src folder to your 
application by specifying it using the --actionscript-classpath compiler option.
* Add the following tag to your application file:

  <mx:Application ...>
    <fab:FABridge xmlns:fab="bridge.*" />
    ...

Use the following code to access your application instance from JavaScript:

  function useBridge() 
  {
      var flexApp = FABridge.flash.root();
  }

To get the value of a property, call it like a function; use the same syntax to access 
objects by id, as the following example shows:

  function getMaxPrice() 
  {
      var flexApp = FABridge.flash.root();
      var appWidth = flexApp.getWidth();
      var maxPrice = flexApp.getMaxPriceSlider().getValue();
  }

To set the value of a property from JavaScript, call the function 
<code>setPropertyName()</code>, as the following example shows:

  function setMaxPrice(newMaxPrice) 
  {
      var flexApp = FABridge.flash.root();
      flexApp.getMaxPriceSlider().setValue(newMaxPrice);
  }

You can call object methods directly, just as you would from ActionScript, as the 
following example shows:

  function setMaxPrice(newMaxPrice) 
  {
      var flexApp = FABridge.flash.root();
      flexApp.getShoppingCart().addItem("Antique Figurine", 12.99);
  }

You can also pass functions, such as event handlers, from JavaScript to ActionScript, as 
the following example shows:

  function listenToMaxPrice() 
  {
      var flexApp = FABridge.flash.root();
      var maxPriceCallback = function(event)
      {
          document.maxPrice = event.getNewValue();
          document.loadFilteredProducts(document.minPrice, document.maxPrice);
      }
      flexApp.getMaxPriceSlider().addEventListener("change", maxPriceCallback);
  }

To run initialization code on a Flex file, you must wait for it to download and initialize 
first. Register a callback to be invoked when the movie is initialized, as the following 
example shows:

 function initMaxPrice(maxPrice)
  {
      var initCallback = function()
      {
          var flexApp = FABridge.flash.root();
          flexApp.getMaxPriceSlider().setValue(maxPrice);
      }
      FABridge.addInitializationCallback("flash",initCallback);
  } 

To script multiple Flash applications on the same page, give them unique bridge names 
through the flashvars mechanism.  Use the bridge name to access them from the bridge, and 
to register for initialization callbacks, as the following example shows:

  <object ...>
    <param name='flashvars' value='bridgeName=shoppingPanel'/>
    <param name='src' value='app.swf'/>
    <embed ... flashvars='bridgeName=shoppingPanel'/>
  </object>
  
  function initMaxPrice(maxPrice)
  {
      var initCallback = function()
      {
          var flexApp = FABridge.shoppingPanel.root();
          flexApp.getMaxPriceSlider().setValue(maxPrice);
      }
      FABridge.addInitializationCallback("shoppingPanel",initCallback);
  }

<b>Automatic memory management</b>

The FABridge provides automatic memory management that uses a reference counting mechanism
for all objects that are passed across the bridge. Objects created from the JavaScript 
side are kept in memory unless the memory is manually released. Events and other 
Actionscript-initiated objects are destroyed as soon as the corresponding JavaScript 
function that handles them directly completes its execution. You can manually call the 
<code>addRef()</code> for an object to have it remain available or call the 
<code>release()</code> method to decrease its reference counter.

If you must break the function call chain by using the <code>setTimeout()</code> function 
in JavaScript, for example to act on an event later on as the following example shows, you
must ensure that the event will still exist. Because the FABridge implements a reference 
counting mechanism to save memory, events thrown from ActionScript exist only for the 
duration of the dispatch function.

<pre>
var flexApp = FABridge.flash.root();
flexApp.getMaxPriceSlider().addEventListener("change", maxPriceCallback );
function maxPriceCallback(event) {
    //when the doSomethingLater function is hit, the event is no longer available;
    //to make it work you would have to call
    //FABridge.addRef(event);
    //then, when you're done with it call FABridge.release(event);
    setTimeout(function() {doSomethingLater(event);},10);
}
</pre>  

<b>Manually destroying objects</b>

You can manually destroy a specific object that has been passed across the bridge, 
regardless of its reference count by invoking the <code>releaseNamedASObject(myObject)</code> 
method from JavaScript. This invalidates the object over the bridge and any future calls 
to it or one of its methods will throw an error.

<b>Handling exceptions</b>

Exceptions that take place in the ActionScript of the bridge as a direct consequence of 
some JavaScript action are now thrown over the bridge into JavaScript. The mechanism 
works as follows:
* When an exception is raised in the ActionScript section, it is caught in a try-catch 
block, serialized, and passed to JavaScript. 
* When the JavaScript part receives an answer from ActionScript, it checks for the 
exception serialization and, if found, throws a JavaScript error with the message received
from ActionScript.

Note: To catch and use the exception information, you must surround the code that calls 
into ActionScript with a try-catch block. You can handle the error in the <code>catch(e)</code> 
block.

== What Are the Limitations? ==

The FABridge library is currently in a beta state. It has been tested on Mozilla Firefox 2
(Windows and Linux), Microsoft Internet Explorer 6, Opera 9, and Apple Safari 2.0.4.

Exceptions thrown across the bridge into JavaScript depend on the user having installed 
Flash Debug Player to display the entire error description. Otherwise, only the error ID
is thrown.

For performance reasons, when an anonymous object is sent from ActionScript to JavaScript,
the bridge assumes it contains only primitives, arrays, and other anonymous objects, and 
no strongly typed objects or methods. Instances or methods sent as part of an anonymous 
object are not bridged correctly.

== Summary ==

You can use the FABridge library to automatically expose your Flex application to 
AJAX-based HTML applications.  Using the bridge, you can easily embed rich Flex components
in your applications, integrating them tightly with the rest of the page content. After a
Flex application is enabled through the bridge, JavaScript developers have access to all
of the functionality it provides.
