component singleton accessors="true" {

	property name="properties";
	property name="requestService" inject="coldbox:requestService";
	property name="moduleSettings" inject="coldbox:moduleSettings:cbotel";

	/**
	 * Returns a struct of key/value comment pairs to append to the SQL.
	 *
	 *              inspect the SQL to make any decisions about what comments to return.
	 *              This can be used to make decisions about what comments to return.
	 *
	 * @sql        The SQL to append the comments to. This is provided if you need to
	 * @datasource The datasource that will execute the query. If null, the default datasource will be used.
	 */
	public struct function getComments( required string sql, string datasource ){
		var comments = {};
		if ( moduleSettings.SQLCommentsEnabled ) {
			var event = requestService.getContext();
			var prc   = event.getPrivateCollection();
			if ( prc.keyExists( "openTelemetry" ) ) {
				comments[ "transactionId" ] = prc.openTelemetry.transactionId;
				comments[ "traceparent" ]   = prc.openTelemetry.traceParent;
			}
		}
		return comments;
	}

}
