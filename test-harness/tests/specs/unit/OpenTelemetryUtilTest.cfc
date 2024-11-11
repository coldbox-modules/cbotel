/**
 * The base model test case will use the 'model' annotation as the instantiation path
 * and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
 * responsibility to update the model annotation instantiation path and init your model.
 */
component extends="coldbox.system.testing.BaseModelTest" model="cbotel.models.OpenTelemetryUtil" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();

		// setup the model
		super.setup();
	}

	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "otel.models.OpenTelemetryUtil Suite", function(){
			it( "can be created", function(){
				expect( model ).toBeComponent();
			} );

			it( "can create a traceId", function(){
				var traceId = model.createTraceId( createUUID() );
				expect( traceId ).toBeString().toHaveLength( 32 );
			} );

			it( "can create a spanId", function(){
				var traceId = model.createSpanId( createUUID() );
				expect( traceId ).toBeString().toHaveLength( 16 );
			} );

			it( "can create a traceparent value", function(){
				var traceParent = model.newTraceparent();
				expect( traceParent ).toBeString();
				expect( listToArray( traceParent, "-" ) ).toHaveLength( 4 );
				expect( model.traceParentIsValid( traceParent ) ).toBeTrue();
			} )
		} );
	}

}

