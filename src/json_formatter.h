#include <napi.h>

#ifndef JSON_FORMATTER_H_
#define JSON_FORMATTER_H_

class JSONFormatter {
public:
  static bool Format(Napi::Value value, std::string *json);

private:
  JSONFormatter(std::string *json);

  bool BuildJSONString(Napi::Value value, size_t depth);

  std::string *json_string_;
  size_t max_depth_{200};
};

#endif // JSON_FORMATTER_H_