#include <napi.h>

// Apple APIs
#import <Foundation/Foundation.h>

/* HELPER FUNCTIONS */

Napi::Array NSArrayToNapiArray(Napi::Env env, NSArray *array);
Napi::Object NSDictionaryToNapiObject(Napi::Env env, NSDictionary *dict);

Napi::Array NSArrayToNapiArray(Napi::Env env, NSArray *array) {
  if (!array)
    return Napi::Array::New(env, 0);

  int length = [array count];
  Napi::Array result = Napi::Array::New(env, length);

  for (int idx = 0; idx < length; idx++) {
    id value = array[idx];
    if ([value isKindOfClass:[NSString class]]) {
      result[idx] = std::string([value UTF8String]);
    } else if ([value isKindOfClass:[NSNumber class]]) {
      const char *objc_type = [value objCType];
      if (strcmp(objc_type, @encode(BOOL)) == 0 ||
          strcmp(objc_type, @encode(char)) == 0) {
        result[idx] = [value boolValue];
      } else if (strcmp(objc_type, @encode(double)) == 0 ||
                 strcmp(objc_type, @encode(float)) == 0) {
        result[idx] = [value doubleValue];
      } else {
        result[idx] = [value intValue];
      }
    } else if ([value isKindOfClass:[NSArray class]]) {
      result[idx] = NSArrayToNapiArray(env, value);
    } else if ([value isKindOfClass:[NSDictionary class]]) {
      result[idx] = NSDictionaryToNapiObject(env, value);
    } else {
      result[idx] = std::string([[value description] UTF8String]);
    }
  }

  return result;
}

Napi::Object NSDictionaryToNapiObject(Napi::Env env, NSDictionary *dict) {
  Napi::Object result = Napi::Object::New(env);

  if (!dict)
    return result;

  for (id key in dict) {
    std::string str_key = [key isKindOfClass:[NSString class]]
                              ? std::string([key UTF8String])
                              : std::string([[key description] UTF8String]);

    id value = [dict objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
      result.Set(str_key, std::string([value UTF8String]));
    } else if ([value isKindOfClass:[NSNumber class]]) {
      const char *objc_type = [value objCType];
      if (strcmp(objc_type, @encode(BOOL)) == 0 ||
          strcmp(objc_type, @encode(char)) == 0)
        result.Set(str_key, [value boolValue]);
      else if (strcmp(objc_type, @encode(double)) == 0 ||
               strcmp(objc_type, @encode(float)) == 0)
        result.Set(str_key, [value doubleValue]);
      else
        result.Set(str_key, [value intValue]);
    } else if ([value isKindOfClass:[NSArray class]]) {
      result.Set(str_key, NSArrayToNapiArray(env, value));
    } else if ([value isKindOfClass:[NSDictionary class]]) {
      result.Set(str_key, NSDictionaryToNapiObject(env, value));
    } else {
      result.Set(str_key, std::string([[value description] UTF8String]));
    }
  }

  return result;
}

/* EXPORTED FUNCTIONS */

Napi::Value GetUserDefault(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  std::string key = info[0].As<Napi::String>().Utf8Value();
  std::string type = info[1].As<Napi::String>().Utf8Value();

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *default_key = [NSString stringWithUTF8String:key.c_str()];

  if (type == "string") {
    NSString *ret = [defaults stringForKey:default_key];
    return Napi::String::New(env, std::string([ret UTF8String]));
  } else if (type == "boolean") {
    return Napi::Boolean::New(env, [defaults boolForKey:default_key]);
  } else if (type == "float") {
    return Napi::Number::New(env, [defaults floatForKey:default_key]);
  } else if (type == "integer") {
    return Napi::Number::New(env, [defaults integerForKey:default_key]);
  } else if (type == "double") {
    return Napi::Number::New(env, [defaults doubleForKey:default_key]);
  } else if (type == "url") {
    NSString *url_string = [[defaults URLForKey:default_key] absoluteString];
    return Napi::String::New(env, std::string([url_string UTF8String]));
  } else if (type == "array") {
    return NSArrayToNapiArray(env, [defaults arrayForKey:default_key]);
  } else if (type == "dictionary") {
    return NSDictionaryToNapiObject(env, [defaults dictionaryForKey:default_key]);
  } else {
    return env.Null();
  }
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "getUserDefault"),
              Napi::Function::New(env, GetUserDefault));

  return exports;
}

NODE_API_MODULE(defaults, Init)