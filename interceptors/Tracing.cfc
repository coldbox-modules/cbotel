component {

	property name="OpenTelemetryUtil" inject="OpenTelemetryUtil@cbotel";
	property name="moduleSettings"    inject="coldbox:moduleSettings:cbotel";

	/**
	 * Processes the inbound open telemetry information and sets it in the private request context
	 *
	 * @event
	 * @rc   
	 * @prc  
	 */
	function preProcess( event, rc, prc ){
		var traceParent   = event.getHttpHeader( "traceparent", "" );
		var traceState    = event.getHttpHeader( "tracestate", "" );
		var traceStateObj = listToArray( traceState, ";" ).reduce( ( result, item ) => {
			var parts = listToArray( item, "=" );
			if ( parts.len() == 2 ) {
				result[ parts[ 1 ] ] = parts[ 2 ];
			}
			return result;
		}, structNew( "ordered" ) );

		if ( len( traceParent ) && !OpenTelemetryUtil.traceParentIsValid( traceParent ) ) {
			traceParent = "";
		}

		if ( !len( traceParent ) && moduleSettings.autoAddTraceParent ) {
			var isSampled = event.getHttpHeader( "X-B3-Sampled", "0" );
			var parentId  = event.getHttpHeader( "X-B3-ParentSpanId", "" );
			var traceId   = event.getHttpHeader( "X-B3-TraceId", "" );
			var spanId    = event.getHttpHeader( "X-B3-SpanId", "" );

			var seed = OpenTelemetryUtil.newUUID();

			traceParent = OpenTelemetryUtil.newTraceparent(
				seed      = seed,
				isSampled = !!isSampled,
				parentId  = len( parentId ) ? parentId : spanId,
				traceId   = traceId
			);

			prc[ "openTelemetry" ] = {
				"traceParent"   : traceParent,
				"parentId"      : listGetAt( traceParent, 3, "-" ),
				"traceId"       : listGetAt( traceParent, 2, "-" ),
				"traceState"    : traceStateObj,
				"transactionId" : OpenTelemetryUtil.createSpanId(
					seed & serializeJSON( getHTTPRequestData( false ) )
				)
			};
		} else if ( len( traceParent ) ) {
			prc[ "openTelemetry" ] = {
				"traceParent"   : traceParent,
				"parentId"      : listGetAt( traceParent, 3, "-" ),
				"traceId"       : listGetAt( traceParent, 2, "-" ),
				"traceState"    : traceStateObj,
				"transactionId" : OpenTelemetryUtil.createSpanId(
					OpenTelemetryUtil.newUUID() & serializeJSON( getHTTPRequestData( false ) )
				)
			};
		}

		if ( len( traceParent ) ) {
			// Allow other parts of the application to contribute to the trace state
			announce( "onTraceStateReceived", { "traceState" : prc.openTelemetry.traceState } );
		}
	}

	/**
	 * Adds the traceparent and tracestate headers to the response
	 *
	 * @event
	 * @rc   
	 * @prc  
	 */
	function postProcess( event, rc, prc ){
		if ( structKeyExists( prc, "openTelemetry" ) && structKeyExists( prc.openTelemetry, "traceParent" ) ) {
			event.setHttpHeader( name = "traceparent", value = prc.openTelemetry.traceParent );
			event.setHttpHeader( name = "X-B3-SpanId", value = prc.openTelemetry.transactionId );
			announce( "onTraceStateFinalized", { "traceState" : prc.openTelemetry.traceState } );
			if ( !structIsEmpty( prc.openTelemetry.traceState ) ) {
				event.setHttpHeader(
					name  = "tracestate",
					value = prc.openTelemetry.traceState
						.reduce( ( result, key, value ) => {
							result.append( "#key#=#value#" );
							return result
						}, [] )
						.toList( ";" )
				);
			}
		}
	}

	/**
	 * Intercepts the hyper request and appends the trace headers
	 */
	function onHyperRequest( event, rc, prc, interceptData ){
		if ( moduleSettings.hyperTraceEnabled && prc.keyExists( "openTelemetry" ) ) {
			var hyperRequest = interceptData.request;
			var otel         = prc.openTelemetry;
			if ( len( otel.traceParent ) && !len( hyperRequest.getHeader( "traceparent" ) ) ) {
				hyperRequest.setHeader( "traceparent", otel.traceParent );
			}
			if ( len( otel.traceState ) && !len( hyperRequest.getHeader( "tracestate" ) ) ) {
				hyperRequest.setHeader(
					"tracestate",
					otel.traceState
						.reduce( ( result, key, value ) => {
							result.append( "#key#=#value#" );
							return result
						}, [] )
						.toList( ";" )
				);
			}
		}
	}

	/**
	 * Appends the trace information to logstash entries
	 *
	 * @event        
	 * @rc           
	 * @prc          
	 * @interceptData
	 */
	function onLogstashEntryCreate( event, rc, prc, interceptData ){
		if ( moduleSettings.logstashTraceEnabled && prc.keyExists( "openTelemetry" ) ) {
			var entry                 = interceptData.entry;
			entry[ "span.id" ]        = prc.openTelemetry.parentId;
			entry[ "trace.id" ]       = prc.openTelemetry.traceId;
			entry[ "transaction.id" ] = prc.openTelemetry.transactionId;
		}
	}

}
