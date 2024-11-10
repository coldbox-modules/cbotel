/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 */
component {

	// Module Properties
	this.title       = "Coldbox Open Telementry Module";
	this.author      = "Ortus Solutions";
	this.webURL      = "https://www.ortussolutions.com";
	this.description = "A coldbox module which provides Open Telemetry information to the framework";
	this.version     = "@build.version@+@build.number@";

	// Model Namespace
	this.modelNamespace = "cbotel";

	// CF Mapping
	this.cfmapping = "cbotel";

	// Dependencies
	this.dependencies = [];

	/**
	 * Configure Module
	 */
	function configure(){
		settings = {
			// Whether to auto-add a traceparent header to the event headers, if one is not supplied
			"autoAddTraceParent"   : true,
			// Whether to auto-add a trace state header to the event headers, if one is not supplied
			"autoAddTraceState"    : true,
			// Whether to append the trace headers to hyper requests
			"hyperTraceEnabled"    : true,
			// Whether to append the trace informat to logstash entries
			"logstashTraceEnabled" : true,
			// Whether to enable SQL comments which will supply the traceparent header as an SQL comment to QB requests
			"SQLCommentsEnabled"   : true
		};

		interceptors = [
			// API Security Interceptor
			{ class : "cbotel.interceptors.Tracing" }
		];

		interceptorSettings = {
			customInterceptionPoints : [
				"onTraceStateReceived",
				"onTraceStateFinalized"
			]
		};
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){
	}

	/**
	 * Fired when the module is unregistered and unloaded
	 */
	function onUnload(){
	}

}
