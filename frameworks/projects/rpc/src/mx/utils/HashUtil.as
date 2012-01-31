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

package mx.utils
{

[ExcludeClass]

/**
 * @private
 *
 *  Provides several hash implementations, RS, AP, etc.
 */
public class HashUtil
{

   public static function rsHash(value:String):Number
   {
      var a:int = 63689;
      var b:int = 378551;
      var result:Number;

      for (var i:int = 0; i < value.length; i++)
      {
         result = (result * a) + value.charCodeAt(i);
         a = a * b;
      }

      return (result & 0x7FFFFFFF);
   }

   public static function jsHash(value:String):Number
   {
      var result:Number = 1315423911;

      for (var i:int = 0; i < value.length; i++)
      {
         result ^= ((result << 5) + value.charCodeAt(i) + (result >> 2));
      }

      return (result & 0x7FFFFFFF);
   }

   public static function apHash(value:String):Number
   {
      var result:int;

      for (var i:int = 0; i < value.length; i++)
      {

         if ((i & 1) == 0)
         {
            result ^= ((result << 7)^value.charCodeAt(i)^(result >> 3));
         }
         else
         {
            result ^= (~((result << 11)^value.charCodeAt(i)^(result >> 5)));
         }

      }

      return (result & 0x7FFFFFFF);

   }

   public static function dbjHash(value:String):Number
   {
      var result:Number = 5381;

      for (var i:int = 0; i < value.length; i++)
      {
         result = ((result << 5) + result) + value.charCodeAt(i);
      }

      return (result & 0x7FFFFFFF);
   }
}

}