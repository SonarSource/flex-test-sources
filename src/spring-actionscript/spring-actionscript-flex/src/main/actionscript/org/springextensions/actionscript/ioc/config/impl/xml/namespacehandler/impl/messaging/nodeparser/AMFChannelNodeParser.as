/*
 * Copyright 2007-2011 the original author or authors.
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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.messaging.nodeparser {

	import mx.messaging.channels.AMFChannel;

	import org.as3commons.lang.ClassUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.ParsingUtils;
	import org.springextensions.actionscript.ioc.config.impl.xml.ns.spring_actionscript_messaging;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;

	use namespace spring_actionscript_messaging;

	/**
	 * @docref xml-schema-based-configuration.html#the_messaging_schema
	 * @author Christophe Herreman
	 * @productionversion SpringActionscript 2.0
	 */
	public class AMFChannelNodeParser extends ChannelNodeParser {

		public static const PIGGYBACKING_ENABLED_ATTR:String = "piggybacking-enabled";

		public static const POLLING_ENABLED_ATTR:String = "polling-enabled";

		public static const POLLING_INTERVAL_ATTR:String = "polling-interval";

		public function AMFChannelNodeParser() {
		}

		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			var result:IObjectDefinition = IObjectDefinition(super.parseInternal(node, context));

			result.className = ClassUtils.getFullyQualifiedName(AMFChannel, true);
			mapProperties(result, node);

			return result;
		}

		override protected function mapProperties(objectDefinition:IObjectDefinition, node:XML):void {
			super.mapProperties(objectDefinition, node);
			ParsingUtils.mapProperties(spring_actionscript_messaging, objectDefinition, node, PIGGYBACKING_ENABLED_ATTR, POLLING_ENABLED_ATTR, POLLING_INTERVAL_ATTR);
		}

	}
}
