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
package org.springextensions.actionscript.ioc.config.impl.mxml.custom.eventbus {

	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mx.core.IMXMLObject;

	import org.springextensions.actionscript.context.IApplicationContext;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistry;
	import org.springextensions.actionscript.eventbus.IEventBusUserRegistryAware;
	import org.springextensions.actionscript.ioc.config.impl.mxml.ICustomObjectDefinitionComponent;
	import org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.eventbus.customconfiguration.EventHandlerCustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IBaseObjectDefinition;
	import org.springextensions.actionscript.ioc.objectdefinition.ICustomConfigurator;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;
	import org.springextensions.actionscript.util.ContextUtils;

	/**
	 *
	 * @author Roland Zwaga
	 * @productionversion SpringActionscript 2.0
	 */
	public class EventHandlerMethod extends EventDispatcher implements IMXMLObject, ICustomObjectDefinitionComponent {
		public static const NAME_CHANGED_EVENT:String = "nameChanged";
		public static const EVENTNAME_CHANGED_EVENT:String = "eventNameChanged";
		public static const PROPERTIES_CHANGED_EVENT:String = "propertiesChanged";
		public static const EVENTCLASS_CHANGED_EVENT:String = "eventClassChanged";
		public static const TOPICS_CHANGED_EVENT:String = "topicsChanged";
		public static const TOPICPROPERTIES_CHANGED_EVENT:String = "topicPropertiesChanged";

		private var _id:String;
		private var _document:Object;
		private var _name:String;
		private var _eventName:String;
		private var _properties:String;
		private var _eventClass:Class;
		private var _topics:String;
		private var _topicProperties:String;
		private var _eventBusUserRegistry:IEventBusUserRegistry;

		/**
		 * Creates a new <code>EventHandlerMethod</code> instance.
		 */
		public function EventHandlerMethod() {
			super();
		}

		public function get eventBusUserRegistry():IEventBusUserRegistry {
			return _eventBusUserRegistry;
		}

		public function set eventBusUserRegistry(value:IEventBusUserRegistry):void {
			_eventBusUserRegistry = value;
		}


		[Bindable(event="nameChanged")]
		public function get name():String {
			return _name;
		}

		public function set name(value:String):void {
			if (_name != value) {
				_name = value;
				dispatchEvent(new Event(NAME_CHANGED_EVENT));
			}
		}

		[Bindable(event="eventNameChanged")]
		public function get eventName():String {
			return _eventName;
		}

		public function set eventName(value:String):void {
			if (_eventName != value) {
				_eventName = value;
				dispatchEvent(new Event(EVENTNAME_CHANGED_EVENT));
			}
		}

		[Bindable(event="propertiesChanged")]
		public function get properties():String {
			return _properties;
		}

		public function set properties(value:String):void {
			if (_properties != value) {
				_properties = value;
				dispatchEvent(new Event(PROPERTIES_CHANGED_EVENT));
			}
		}

		[Bindable(event="eventClassChanged")]
		public function get eventClass():Class {
			return _eventClass;
		}

		public function set eventClass(value:Class):void {
			if (_eventClass != value) {
				_eventClass = value;
				dispatchEvent(new Event(EVENTCLASS_CHANGED_EVENT));
			}
		}

		[Bindable(event="topicsChanged")]
		public function get topics():String {
			return _topics;
		}

		public function set topics(value:String):void {
			if (_topics != value) {
				_topics = value;
				dispatchEvent(new Event(TOPICS_CHANGED_EVENT));
			}
		}

		[Bindable(event="topicPropertiesChanged")]
		public function get topicProperties():String {
			return _topicProperties;
		}

		public function set topicProperties(value:String):void {
			if (_topicProperties != value) {
				_topicProperties = value;
				dispatchEvent(new Event(TOPICPROPERTIES_CHANGED_EVENT));
			}
		}

		public function get id():String {
			return _id;
		}

		public function set id(value:String):void {
			_id = value;
		}

		public function get document():Object {
			return _document;
		}

		public function set document(value:Object):void {
			_document = value;
		}

		public function initialized(document:Object, id:String):void {
			_id = id;
			_document = document;
		}

		public function execute(applicationContext:IApplicationContext, objectDefinitions:Object, defaultDefinition:IBaseObjectDefinition=null, parentDefinition:IObjectDefinition=null, parentId:String=null):void {
			if (applicationContext is IEventBusUserRegistryAware) {
				eventBusUserRegistry = (applicationContext as IEventBusUserRegistryAware).eventBusUserRegistry;
			}
			var objectName:String = parentId;
			var customConfiguration:Vector.<Object> = ContextUtils.getCustomConfigurationForObjectName(objectName, applicationContext.objectDefinitionRegistry);
			var topics:Vector.<String> = ContextUtils.commaSeparatedPropertyValueToStringVector(topics);
			var topicProperties:Vector.<String> = ContextUtils.commaSeparatedPropertyValueToStringVector(topicProperties);
			var properties:Vector.<String> = ContextUtils.commaSeparatedPropertyValueToStringVector(properties);
			var configurator:EventHandlerCustomConfigurator = new EventHandlerCustomConfigurator(eventBusUserRegistry, name, eventName, eventClass, properties, topics, topicProperties);
			customConfiguration[customConfiguration.length] = configurator;
			applicationContext.objectDefinitionRegistry.registerCustomConfiguration(objectName, customConfiguration);
		}
	}
}
