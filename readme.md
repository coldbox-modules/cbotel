
# Open Telemetry Module for the Coldbox Platform

This module provides support for the distributed tracing and other information used by [Open Telemetry](https://opentelemetry.io) and other APM services.

Once installed this module will parse or [create `traceparent` and `tracestate` information](https://www.w3.org/TR/trace-context/#tracestate-header) which can be passed along to subsequent transactions ( e.g. database, http, etc. ) to provide distributed tracing data and waterfall visualizations of request workflows.

For more information on installing the [OpenTelemetry java agents](https://opentelemetry.io/docs/languages/java/intro/) and information read the [docs here](https://opentelemetry.io/docs/).

## Configuration

The following config settings may be applied to your `moduleSettings` structure in `config/Coldbox.cfc` or used within a `config/modules/cbotel.cfc` settings file when configuring Coldbox:

```java
{
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
}

```

## Usage

### Request Variable `prc.openTelemetry`

If the inbound request is supplied with a `traceparent` header or the `autoAddTraceParent` setting is set to true, a `prc` struct named `openTelemetry` will be created.  This struct will contain the following keys:

* `traceParent` - the original provided or generated trace parent identifier
* `parentId` - the 16 character hash of the parent span identifier
* `traceId` - the 32 character hash of the trace identifier
* `traceState` - a struct containing any provided trace state information.  The framework may contribute to the trace state via the interception points `onTraceStateReceived` and `onTraceStateFinalized`.  
* `transactionId` - a unique span identifier for the request transaction, which is a 16 character hash of a UUID and the HTTP request data.  This value can be used as a unique identifer for additional distributed tracing and grouping. In the case of an auto-generated `traceparent` this value will be the same as the `parentId` value.

### Interception Points

* If the `hyperTraceEnabled` flag is set to `true`, all hyper requests will have the `traceparent` header applied to every HTTP transaction, as well as the `tracestate` if not empty.
* If the `logstashTraceEnabled` flag is set to `true`, all logstash entries will be appended with `span.id` ( `parentId` ), `trace.id` ( `traceId` ) and `transaction.id` information, which can be used by the Elastic APM for real-time monitoring and grouping.

### QB SQL Commenter

* By adding `SQLCommenter@cbotel` as an [SQL Commenter to your QB Configuration](https://qb.ortusbooks.com/query-builder/debugging/sqlcommenter#commenters), the `transactionId` and the `traceParent` values will be appended as comments to all QB ( and Quick ) queries generated.


## About ColdBox

ColdBox *Hierarchical* MVC is the de-facto enterprise-level [HMVC](https://en.wikipedia.org/wiki/Hierarchical_model%E2%80%93view%E2%80%93controller) framework for ColdFusion (CFML) developers. It's professionally backed, conventions-based, modular, highly extensible, and productive. Getting started with ColdBox is quick and painless.  ColdBox takes the pain out of development by giving you a standardized methodology for modern ColdFusion (CFML) development with features such as:

* [Conventions instead of configuration](https://coldbox.ortusbooks.com/getting-started/conventions)
* [Modern URL routing](https://coldbox.ortusbooks.com/the-basics/routing)
* [RESTFul APIs](https://coldbox.ortusbooks.com/the-basics/event-handlers/rendering-data)
* [A hierarchical approach to MVC using ColdBox Modules](https://coldbox.ortusbooks.com/hmvc/modules)
* [Event-driven programming](https://coldbox.ortusbooks.com/digging-deeper/interceptors)
* [Async and Parallel programming constructs](https://coldbox.ortusbooks.com/digging-deeper/promises-async-programming)
* [Integration & Unit Testing](https://coldbox.ortusbooks.com/testing/testing-coldbox-applications)
* [Included dependency injection](https://wirebox.ortusbooks.com)
* [Caching engine and API](https://cachebox.ortusbooks.com)
* [Logging engine](https://logbox.ortusbooks.com)
* [An extensive eco-system](https://forgebox.io)
* Much More

## Learning ColdBox

ColdBox is the defacto standard for building modern ColdFusion (CFML) applications.  It has the most extensive [documentation](https://coldbox.ortusbooks.com) of all modern web application frameworks.


If you don't like reading so much, then you can try our video learning platform: [CFCasts (www.cfcasts.com)](https://www.cfcasts.com)

## Ortus Sponsors

ColdBox is a professional open-source project and it is completely funded by the [community](https://patreon.com/ortussolutions) and [Ortus Solutions, Corp](https://www.ortussolutions.com).  Ortus Patreons get many benefits like a cfcasts account, a FORGEBOX Pro account and so much more.  If you are interested in becoming a sponsor, please visit our patronage page: [https://patreon.com/ortussolutions](https://patreon.com/ortussolutions)

