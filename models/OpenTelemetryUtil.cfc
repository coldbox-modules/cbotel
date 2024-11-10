component singleton {

	// This is the only version currently support by the specification
	variables.traceVersion  = "00";
	variables.UUIDGenerator = createObject( "java", "java.util.UUID" );

	/**
	 * Generate a new UUID
	 */
	function newUUID(){
		return UUIDGenerator.randomUUID().toString();
	}

	/**
	 * Generate a new traceparent header according to the OpenTelemetry specification
	 * https://www.w3.org/TR/trace-context/#traceparent-header
	 */
	public string function newTraceparent(
		string seed,
		boolean isSampled = true,
		parentId          = "",
		traceId           = "",
		spanId            = ""
	){
		param arguments.seed = UUIDGenerator.randomUUID().toString();
		var traceId          = len( traceId ) ? traceId : createTraceId( arguments.seed );
		var parentId         = len( parentId ) ? parentId : createSpanId( arguments.seed );
		var traceFlags       = getTraceFlags( arguments.isSampled );
		return [
			variables.traceVersion,
			traceId,
			parentID,
			traceFlags
		].toList( "-" );
	}

	/**
	 * Deconstructs a traceparent header into its parts and determines if it is valid
	 *
	 * @traceParent
	 */
	public boolean function traceParentIsValid( string traceParent ){
		var parts = listToArray( traceParent, "-" );
		return parts.len() == 4
		&& len( parts[ 1 ] ) == 2
		&& len( parts[ 2 ] ) == 32
		&& len( parts[ 3 ] ) == 16
		&& !reFind( "[^0-9]", parts[ 4 ] );
	}

	/**
	 * Create a new trace id from a seed
	 * The generated string will be a 32 character hex string
	 *
	 * @seed The seed to create the trace id from
	 */
	function createTraceId( string seed ){
		return lCase( hash( arguments.seed, "MD5" ) );
	}

	/**
	 * Create a new parent id from a seed
	 * The generated string will be a 16 character hex string
	 *
	 * @seed The seed to create the parent id from
	 */
	function createSpanId( string seed ){
		return lCase( hash( arguments.seed, "QUICK" ) );
	}

	/**
	 * Get the trace flags from a boolean value
	 * Currently only the sampled flag is supported
	 *
	 * @isSampled Whether the trace is sampled
	 */
	function getTraceFlags( boolean isSampled ){
		return isSampled ? "01" : "00";
	}

}
