/**
 * The base interceptor test case will use the 'interceptor' annotation as the instantiation path to the interceptor
 * and then create it, prepare it for mocking, and then place it in the variables scope as 'interceptor'. It is your
 * responsibility to update the interceptor annotation instantiation path.
 */
component extends="coldbox.system.testing.BaseInterceptorTest" interceptor="cbotel.interceptors.Tracing" {

	this.loadColbox    = true;
	this.unloadColdbox = false;

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();

		// interceptor configuration properties, if any
		configProperties = {};
		// init and configure interceptor
		super.setup();
		// we are now ready to test this interceptor
		getWirebox().autoWire( interceptor );

		variables.OpenTelemetryUtil = getWirebox().getInstance( "OpenTelemetryUtil@cbotel" );

		interceptor.$( "announce", () => nullValue() );
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "otel.interceptors.Tracing", function(){
			var event;
			var rc;
			var prc;

			beforeEach( function(){
				event = getMockRequestContext();
				prc   = event.getPrivateCollection();
				rc    = event.getCollection();
			} );

			it( "will construct open telemetry data if none is supplied", function(){
				interceptor.preProcess( event, rc, prc );
				expect( prc ).toHaveKey( "openTelemetry" );
				expect( prc.openTelemetry ).toHaveKey( "traceParent" );
				expect( prc.openTelemetry ).toHaveKey( "traceId" );
				expect( prc.openTelemetry ).toHaveKey( "traceState" );
				expect( prc.openTelemetry ).toHaveKey( "parentId" );
			} );

			it( "will deconstruct and preserve open telemetry data if supplied", function(){
				var testParentId   = "00-b48652ca043c66c38c2d1a320c9dfcd4-782eabf364406345-00";
				expect( OpenTelemetryUtil.traceParentIsValid( testParentId ) ).toBeTrue();
				var testTraceState = "foo=bar;baz=qux";
				event.$( method="getHttpHeader", callback=function( name, defaultValue ){
					switch( name ){
						case "traceparent":
							return testParentId;
						case "tracestate":
							return testTraceState;
						default:
							return defaultValue;
					}
				} );

				interceptor.preProcess( event, rc, prc );
				expect( prc ).toHaveKey( "openTelemetry" );
				expect( prc.openTelemetry ).toHaveKey( "traceParent" );
				expect( prc.openTelemetry ).toHaveKey( "traceId" );
				expect( prc.openTelemetry ).toHaveKey( "traceState" );
				expect( prc.openTelemetry ).toHaveKey( "parentId" );
				expect( prc.openTelemetry.traceParent ).toBe( testParentId );
				expect( prc.openTelemetry.traceState )
					.toBeStruct()
					.toHaveKey( "foo" )
					.toHaveKey( "baz" );
			} );

			it( "will append trace information to a hyper request", function(){
				var testParentId   = "00-b48652ca043c66c38c2d1a320c9dfcd4-782eabf364406345-00";
				expect( OpenTelemetryUtil.traceParentIsValid( testParentId ) ).toBeTrue();
				var testTraceState = "foo=bar;baz=qux";
				event.$( method="getHttpHeader", callback=function( name, defaultValue ){
					switch( name ){
						case "traceparent":
							return testParentId;
						case "tracestate":
							return testTraceState;
						default:
							return defaultValue;
					}
				} );

				interceptor.preProcess( event, rc, prc );
				var testHyperRequest = createMock( "root.modules.hyper.models.HyperRequest" ).init();
				expect( prc ).toHaveKey( "openTelemetry" );
				expect( prc.openTelemetry ).toHaveKey( "traceParent" );
				expect( prc.openTelemetry ).toHaveKey( "traceId" );
				expect( prc.openTelemetry ).toHaveKey( "traceState" );
				expect( prc.openTelemetry ).toHaveKey( "parentId" );
				expect( prc.openTelemetry.traceParent ).toBe( testParentId );
				expect( prc.openTelemetry.traceState )
					.toBeStruct()
					.toHaveKey( "foo" )
					.toHaveKey( "baz" );

				interceptor.onHyperRequest( event, rc, prc, { "request" : testHyperRequest } );

				expect( testHyperRequest.getHeader( "traceparent" ) ).toBe( testParentId );
				expect( testHyperRequest.getHeader( "tracestate" ) ).toBe( testTraceState );

			} );

			it( "will append trace information to a Logstash entry", function(){
				var testParentId   = "00-b48652ca043c66c38c2d1a320c9dfcd4-782eabf364406345-00";
				expect( OpenTelemetryUtil.traceParentIsValid( testParentId ) ).toBeTrue();
				var testTraceState = "foo=bar;baz=qux";
				event.$( method="getHttpHeader", callback=function( name, defaultValue ){
					switch( name ){
						case "traceparent":
							return testParentId;
						case "tracestate":
							return testTraceState;
						default:
							return defaultValue;
					}
				} );

				interceptor.preProcess( event, rc, prc );
				var testHyperRequest = createMock( "root.modules.hyper.models.HyperRequest" ).init();
				expect( prc ).toHaveKey( "openTelemetry" );
				expect( prc.openTelemetry ).toHaveKey( "traceParent" );
				expect( prc.openTelemetry ).toHaveKey( "traceId" );
				expect( prc.openTelemetry ).toHaveKey( "traceState" );
				expect( prc.openTelemetry ).toHaveKey( "parentId" );
				expect( prc.openTelemetry.traceParent ).toBe( testParentId );
				expect( prc.openTelemetry.traceState )
					.toBeStruct()
					.toHaveKey( "foo" )
					.toHaveKey( "baz" );

				var testEntry = {};

				interceptor.onLogstashEntryCreate( event, rc, prc, { "entry" : testEntry } );

				expect( testEntry ).toHaveKey( "span.id" ).toHaveKey( "trace.id" ).toHaveKey( "transaction.id" );

				expect( testEntry[ "span.id" ] ).toBe( prc.openTelemetry.parentId );
				expect( testEntry[ "trace.id" ] ).toBe( prc.openTelemetry.traceId );
				expect( testEntry[ "transaction.id" ] ).toBe( prc.openTelemetry.transactionId );

			} );
		} );
	}

}
