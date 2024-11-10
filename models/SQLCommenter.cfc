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
			var event       = requestService.getContext();
			var traceParent = event.getHttpHeader( "traceparent", "" );
			if ( len( traceParent ) ) {
				comments[ "traceparent" ] = traceParent;
			}
		}
		return comments;
	}

}
