# kong-kafka-custom-log Plugin

This plugin publishes logs from Kong to Apache Kafka.

It requires [lua-resty-kafka](https://github.com/doujiang24/lua-resty-kafka) to be installed. <br/>
**Note**: The version of `lua-resty-kafka` should be greater than `v0.09`. <br/>
`luarocks install lua-resty-kafka`

### Installation

**Using Luarocks:**<br/>
The plugin can be installed by using the following command:<br/>
`luarocks install kong-kafka-custom-log`

**Using source:**<br/>
`git clone https://github.com/mykaarma/kong-kafka-custom-log`<br/>
`cd kong-kafka-custom-log`<br/>
`luarocks make`<br/>

Then, add the plugin to the `plugins` key in `kong.conf` file.<br/>
`plugins=kong-kafka-custom-log`

### Parameters

Here's a list of all the parameters which can be used in this plugin's configuration:

| Form Parameter | default | description |
| --- 						| --- | --- |
| `name` 					                        |       | The name of the plugin to use, in this case `kafka-log` |
| `config.custom_fields_mapping`          |       | The map containing the fields in the kong logs (`kong.log`) which are required to be published to kafka and their address. For eg, to publish the status code the key should be `status` (or any other desired name) and its value should be `response.status` because it can be accessed using `kong.log.response.status`  |
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

### Sample configurations in terraform

```
resource "kong_plugin" "kong-kafka-custom-log" {
    name        = "kong-kafka-custom-log"
    enabled     = true
    config_json = <<EOT
    {
        "bootstrap_servers": ["kafka-server-1:9092", "kafka-server-2:9092"],
        "topic": "kong-logs",
        "custom_fields_mapping": {
            "status": "response.status",
            "consumerUsername": "consumer.username",
            "consumerCustomID": "consumer.custom_id",
            "uri": "request.uri",
            "methodType": "request.method",
            "start_time": "started_at",
            "service": "service.name"
        }
    }
EOT
}
```

### Implementation details

Original source rewritten from [kong-plugin-kafka-log](https://github.com/yskopets/kong-plugin-kafka-log) by [yskopets](https://github.com/yskopets), Thanks!
