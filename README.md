# Kafka-usage-log Plugin

This plugin publishes logs from Kong to Apache Kafka.

It requires [lua-resty-kafka](https://github.com/doujiang24/lua-resty-kafka) to be installed. <br/>
`luarocks install lua-resty-kafka`

### Parameters

Here's a list of all the parameters which can be used in this plugin's configuration:

| Form Parameter | default | description |
| --- 						| --- | --- |
| `name` 					                        |       | The name of the plugin to use, in this case `kafka-log` |
| `config.bootstrap_servers` 	                    |       | List of bootstrap brokers in `host:port` format |
| `config.topic` 			                        |       | Topic to publish to |
| `config.timeout`   <br /> <small>Optional</small> | 10000 | Socket timeout in millis |
| `config.keepalive` <br /> <small>Optional</small> | 60000 | Keepalive timeout in millis |
| `config.producer_request_acks` <br /> <small>Optional</small>                              | 1       | The number of acknowledgments the producer requires the leader to have received before considering a request complete. Allowed values: 0 for no acknowledgments, 1 for only the leader and -1 for the full ISR |
| `config.producer_request_timeout` <br /> <small>Optional</small>                           | 2000    | Time to wait for a Produce response in millis |
| `config.producer_request_limits_messages_per_request` <br /> <small>Optional</small>       | 200     | Maximum number of messages to include into a single Produce request |
| `config.producer_request_limits_bytes_per_request` <br /> <small>Optional</small> 	     | 1048576 | Maximum size of a Produce request in bytes |
| `config.producer_request_retries_max_attempts` <br /> <small>Optional</small> 	         | 10      | Maximum number of retry attempts per single Produce request |
| `config.producer_request_retries_backoff_timeout` <br /> <small>Optional</small>	     	 | 100     | Backoff interval between retry attempts in millis |
| `config.producer_async` <br /> <small>Optional</small>                                     | true    | Flag to enable asynchronous mode |
| `config.producer_async_flush_timeout` <br /> <small>Optional</small>                       | 1000    | Maximum time interval in millis between buffer flushes in in asynchronous mode | 
| `config.producer_async_buffering_limits_messages_in_memory` <br /> <small>Optional</small> | 50000   | Maximum number of messages that can be buffered in memory in asynchronous mode |

### Log format

The logs are modified such that it publishes only the fields required for usage tracking in Kafka.

| Field | Description |
| ---   | ---         |
| status | The response status code. |
| consumerUUID | The UUID of the Kong Consumer/Service Subscriber. |
| scope | The scope of that route. |
| uri | The uri of the route. |
| methodType | The CRUD method, i.e. GET, POST, PUT, DELETE. |
| start_time | The time at which Kong receives the request. |
| service | The service name. |
| responseTime | The time taken by the proxy server to return the response. |
| dealerUUID | The dealer UUID. Multiple values get stored in the form of a list. |
| departmentUUID | The department UUID. Multiple values get stored in the form of a list. |
| requestUUID | The unique requestUUID. If the request does not have a requestUUID, it gets assigned automatically. |
