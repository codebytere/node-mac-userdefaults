#include <napi.h>

#include <sstream>
#include <string>

#include "json_formatter.h"

template <typename T> std::string ToString(T arg) {
  std::stringstream ss;
  ss << arg;
  return ss.str();
}

JSONFormatter::JSONFormatter(std::string *json) : json_string_(json) {}

// static
bool JSONFormatter::Format(Napi::Value value, std::string *json) {
  json->clear();
  json->reserve(1024);

  JSONFormatter formatter(json);
  return formatter.BuildJSONString(value, 0U);
}

bool JSONFormatter::BuildJSONString(Napi::Value value, size_t depth) {
  if (depth >= max_depth_)
    return false;

  if (value.IsBoolean()) {
    json_string_->append(value.ToBoolean() ? "true" : "false");
    return true;
  } else if (value.IsString()) {
    std::string str = value.ToString().Utf8Value();
    // This needs quotes to ensure well-formed JSON.
    json_string_->append("\"" + str + "\"");
    return true;
  } else if (value.IsNumber()) {
    int num = value.ToNumber();
    std::string str = ToString(num);
    json_string_->append(str);
    return true;
  } else if (value.IsArray()) {
    json_string_->push_back('[');

    bool first_value_has_been_output = false;
    bool result = true;

    Napi::Array arr = value.As<Napi::Array>();
    for (size_t idx = 0; idx < arr.Length(); idx++) {
      if (first_value_has_been_output)
        json_string_->push_back(',');

      if (!BuildJSONString(arr[idx], depth))
        result = false;

      first_value_has_been_output = true;
    }

    json_string_->push_back(']');
    return result;
  } else if (value.IsObject()) {
    json_string_->push_back('{');

    bool first_value_has_been_output = false;
    bool result = true;

    Napi::Object obj = value.As<Napi::Object>();
    Napi::Array props = obj.GetPropertyNames();

    for (size_t idx = 0; idx < props.Length(); idx++) {
      std::string key = props.Get(idx).ToString().Utf8Value();
      const auto &value = obj.Get(key);

      if (first_value_has_been_output)
        json_string_->push_back(',');

      // This needs quotes to ensure well-formed JSON.
      json_string_->append("\"" + key + "\"");
      json_string_->push_back(':');

      if (!BuildJSONString(value, depth + 1U))
        result = false;

      first_value_has_been_output = true;
    }

    json_string_->push_back('}');
    return result;
  }

  return false;
}
