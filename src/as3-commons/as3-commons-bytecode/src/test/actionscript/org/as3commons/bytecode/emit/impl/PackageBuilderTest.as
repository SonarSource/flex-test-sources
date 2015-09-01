/*
 * Copyright 2007-2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.bytecode.emit.impl {


	import org.flexunit.asserts.assertEquals;

	public class PackageBuilderTest {

		public function PackageBuilderTest() {
			super();
		}

		[Test]
		public function testRemoveTrailingPeriod():void {
			var str1:String = "com.classes.generated";
			str1 = PackageBuilder.removeTrailingPeriod(str1);
			assertEquals(str1, "com.classes.generated");
			str1 = "com.classes.generated.";
			str1 = PackageBuilder.removeTrailingPeriod(str1);
			assertEquals(str1, "com.classes.generated");
		}
	}
}