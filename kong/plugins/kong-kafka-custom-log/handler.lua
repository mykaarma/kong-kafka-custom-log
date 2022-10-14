local BasePlugin = require "kong.plugins.base_plugin"
local producers = require "kong.plugins.kong-kafka-custom-log.producers"
local cjson = require "cjson"
local cjson_encode = cjson.encode
local kong = kong
local uuid = require("uuid")

local KafkaLogHandler = BasePlugin:extend()

KafkaLogHandler.PRIORITY = 5
KafkaLogHandler.VERSION = "0.0.1"

local mt_cache = { __mode = "k" }
local producers_cache = setmetatable({}, mt_cache)

--- Computes a cache key for a given configuration.
local function cache_key(conf)
  -- here we rely on validation logic in schema that automatically assigns a unique id
  -- on every configuartion update
  return conf.id
end

--- Publishes a message to Kafka.
-- Must run in the context of `ngx.timer.at`.
local function log(premature, conf, message)
  if premature then
    return
  end

  local producer
  local err
  producer, err = producers.new(conf)
  if not producer then
    ngx.log(ngx.ERR, "[kong-kafka-custom-log] failed to create a Kafka Producer for a given configuration: ", err)
    return
  end

  local ok, err = producer:send(conf.topic, nil, cjson_encode(message))
  if not ok then
    ngx.log(ngx.ERR, "[kong-kafka-custom-log] failed to send a message on topic ", conf.topic, ": ", err)
    return
  end
end

local function split (inputstr, sep)
  if sep == nil then
     sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
     table.insert(t, str)
  end
  return t
end

function KafkaLogHandler:new()
  KafkaLogHandler.super.new(self, "kafka-log")
end

function KafkaLogHandler:log(conf, other)
  KafkaLogHandler.super.log(self)

  local logs = kong.log.serialize()

  local message = {}
  

  for key, value in pairs(conf.custom_fields_mapping) do
    local log_location_list = split(value, ".")
    local log_value = logs
    for _, location in ipairs(log_location_list) do
      log_value = log_value[location]
      if log_value == nil then
        kong.log.warn(value .. " not present in logs")
        break
      end
    end
    message[key] = log_value
  end

  local ok, err = ngx.timer.at(0, log, conf, message)
  if not ok then
    ngx.log(ngx.ERR, "[kong-kafka-custom-log] failed to create timer: ", err)
  end
end

return KafkaLogHandler
