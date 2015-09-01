/*
 * Copyright (c) 2007-2009-2010 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.reflect {

	import flexunit.framework.TestCase;

	import org.as3commons.reflect.testclasses.PublicClass;

	/**
	 * @author Christophe Herreman
	 */
	public class MethodTest extends TestCase {

		public function MethodTest(methodName:String = null) {
			super(methodName);
		}

		public function testInvoke():void {

			/*var a = getQualifiedClassName(this);
			   var b = getQualifiedClassName(String);
			   var c = getQualifiedClassName(MethodTest);
			   var d = getQualifiedSuperclassName(this);
			 var e = getQualifiedSuperclassName(MethodTest);*/

			var instance:PublicClass = new PublicClass();
			var type:Type = Type.forInstance(instance);

			for each (var method:Method in type.methods) {
				if ("method1" == method.name) {
					method.invoke(instance, null);
					assertEquals(Type.VOID, method.returnType);
				}
				if ("method5" == method.name) {
					method.invoke(instance, [1, 2, 3, "four", 5, true, ["a", "b"]]);
					assertEquals(Type.UNTYPED, method.returnType);
				}
				if ("method6" == method.name) {
					var m6result:uint = method.invoke(instance, ["test", 7, false]);
					assertEquals(25, m6result);
					assertEquals(uint, method.returnType.clazz);
				}
			}
		}

		// --------------------------------------------------------------------
		//
		// as3commons_reflect
		//
		// --------------------------------------------------------------------

		public function testSetProperties():void {
			var instance:PublicClass = new PublicClass();
			var type:Type = Type.forInstance(instance);
			var method:Method = type.methods[0];

			method.as3commons_reflect::setDeclaringType("Number");
			method.as3commons_reflect::setIsStatic(true);
			method.as3commons_reflect::setName("renamed");
			method.as3commons_reflect::setNamespaceURI("org.as3commons.reflect.testclasses");
			method.as3commons_reflect::setParameters([]);
			method.as3commons_reflect::setReturnType(Type.VOID.fullName);
			method.as3commons_reflect::setFullName("org.as3commons.reflect.testclasses.PublicClass:renamed");

			assertEquals(Type.forClass(Number), method.declaringType);
			assertTrue(method.isStatic);
			assertEquals("renamed", method.name);
			assertEquals("org.as3commons.reflect.testclasses", method.namespaceURI);
			assertTrue(method.parameters.length == 0);
			assertEquals(Type.VOID, method.returnType);
			assertEquals("org.as3commons.reflect.testclasses.PublicClass:renamed", method.fullName);
		}
	}
}
