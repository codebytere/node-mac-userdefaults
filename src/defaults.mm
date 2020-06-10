#include <napi.h>

// Apple APIs
#import <Foundation/Foundation.h>

#include "json_formatter.h"

/* HELPER FUNCTIONS */

Napi::Array NSArrayToNapiArray(Napi::Env env, NSArray *array);
Napi::Object NSDictionaryToNapiObject(Napi::Env env, NSDictionary *dict);
NSArray *NapiArrayToNSArray(Napi::Array array);
NSDictionary *NapiObjectToNSDictionary(Napi::Object object);

// Converts a std::string to an NSString.
NSString *ToNSString(const std::string &str) {
  return [NSString stringWithUTF8String:str.c_str()];
}

// Converts a NSArray to a Napi::Array.
Napi::Array NSArrayToNapiArray(Napi::Env env, NSArray *array) {
  if (!array)
    return Napi::Array::New(env, 0);

  size_t length = [array count];
  Napi::Array result = Napi::Array::New(env, length);

  for (size_t idx = 0; idx < length; idx++) {
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

// Converts a Napi::Object to an NSDictionary.
NSDictionary *NapiObjectToNSDictionary(Napi::Value value) {
  std::string json;
  if (!JSONFormatter::Format(value, &json))
    return nil;

  NSData *jsonData = [NSData dataWithBytes:json.c_str() length:json.length()];
  id obj = [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:0
                                             error:nil];

  return [obj isKindOfClass:[NSDictionary class]] ? obj : nil;
}

// Converts a Napi::Array to an NSArray.
NSArray *NapiArrayToNSArray(Napi::Array array) {
  NSMutableArray *mutable_array =
      [NSMutableArray arrayWithCapacity:array.Length()];

  for (size_t idx = 0; idx < array.Length(); idx++) {
    Napi::Value val = array[idx];
    if (val.IsNumber()) {
      NSNumber *wrappedInt = [NSNumber numberWithInt:val.ToNumber()];
      [mutable_array addObject:wrappedInt];
    } else if (val.IsBoolean()) {
      NSNumber *wrappedBool = [NSNumber numberWithBool:val.ToBoolean()];
      [mutable_array addObject:wrappedBool];
    } else if (val.IsString()) {
      const std::string str = (std::string)val.ToString();
      [mutable_array addObject:ToNSString(str)];
    } else if (val.IsArray()) {
      Napi::Array sub_array = val.As<Napi::Array>();
      if (NSArray *ns_arr = NapiArrayToNSArray(sub_array)) {
        [mutable_array addObject:ns_arr];
      }
    } else if (val.IsObject()) {
      if (NSDictionary *dict = NapiObjectToNSDictionary(val)) {
        [mutable_array addObject:dict];
      }
    }
  }

  return mutable_array;
}

// Converts an NSDictionary to a Napi::Object.
Napi::Object NSDictionaryToNapiObject(Napi::Env env, NSDictionary *dict) {
  Napi::Object result = Napi::Object::New(env);

  if (!dict)
    return result;

  for (id key in dict) {
    const std::string str_key =
        [key isKindOfClass:[NSString class]]
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

// Returns all NSUserDefaults for the current user.
Napi::Object GetAllDefaults(const Napi::CallbackInfo &info) {
  NSUserDefaults *defaults = [&]() {
    if (!info[0].IsEmpty()) {
      const std::string domain = (std::string)info[0].ToString();
      return [[NSUserDefaults alloc] initWithSuiteName:ToNSString(domain)];
    }
    return [NSUserDefaults standardUserDefaults];
  }();

  NSDictionary *all_defaults = [defaults dictionaryRepresentation];
  return NSDictionaryToNapiObject(info.Env(), all_defaults);
}

// Returns the value of 'key' in NSUserDefaults for a specified type.
Napi::Value GetUserDefault(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();

  const std::string type = (std::string)info[0].ToString();
  const std::string key = (std::string)info[1].ToString();

  NSUserDefaults *defaults = [&]() {
    if (!info[2].IsEmpty()) {
      const std::string domain = (std::string)info[2].ToString();
      return [[NSUserDefaults alloc] initWithSuiteName:ToNSString(domain)];
    }
    return [NSUserDefaults standardUserDefaults];
  }();

  NSString *default_key = [NSString stringWithUTF8String:key.c_str()];

  if (type == "string") {
    NSString *s = [defaults stringForKey:default_key];
    return Napi::String::New(env, s ? std::string([s UTF8String]) : "");
  } else if (type == "boolean") {
    bool b = [defaults boolForKey:default_key];
    return Napi::Boolean::New(env, b ? b : false);
  } else if (type == "float") {
    float f = [defaults floatForKey:default_key];
    return Napi::Number::New(env, f ? f : 0);
  } else if (type == "integer") {
    int i = [defaults integerForKey:default_key];
    return Napi::Number::New(env, i ? i : 0);
  } else if (type == "double") {
    double d = [defaults doubleForKey:default_key];
    return Napi::Number::New(env, d ? d : 0);
  } else if (type == "url") {
    NSString *u = [[defaults URLForKey:default_key] absoluteString];
    return Napi::String::New(env, u ? std::string([u UTF8String]) : "");
  } else if (type == "array") {
    NSArray *array = [defaults arrayForKey:default_key];
    return NSArrayToNapiArray(env, array);
  } else if (type == "dictionary") {
    NSDictionary *dict = [defaults dictionaryForKey:default_key];
    return NSDictionaryToNapiObject(env, dict);
  } else {
    return env.Null();
  }
}

// Sets the value of the NSUserDefault for 'key' in NSUserDefaults.
void SetUserDefault(const Napi::CallbackInfo &info) {
  const std::string type = (std::string)info[0].ToString();
  const std::string key = (std::string)info[1].ToString();
  NSString *default_key = ToNSString(key);

  NSUserDefaults *defaults = [&]() {
    if (!info[3].IsEmpty()) {
      const std::string domain = (std::string)info[3].ToString();
      return [[NSUserDefaults alloc] initWithSuiteName:ToNSString(domain)];
    }
    return [NSUserDefaults standardUserDefaults];
  }();

  if (type == "string") {
    const std::string value = (std::string)info[2].ToString();
    [defaults setObject:ToNSString(value) forKey:default_key];
  } else if (type == "boolean") {
    bool value = info[2].ToBoolean();
    [defaults setBool:value forKey:default_key];
  } else if (type == "float") {
    float value = info[2].ToNumber().FloatValue();
    [defaults setFloat:value forKey:default_key];
  } else if (type == "integer") {
    int value = info[2].ToNumber().Int32Value();
    [defaults setInteger:value forKey:default_key];
  } else if (type == "double") {
    double value = info[2].ToNumber().DoubleValue();
    [defaults setDouble:value forKey:default_key];
  } else if (type == "url") {
    std::string url_string = (std::string)info[2].ToString();
    NSURL *url = [NSURL URLWithString:ToNSString(url_string)];
    [defaults setURL:url forKey:default_key];
  } else if (type == "array") {
    Napi::Array array = info[2].As<Napi::Array>();
    if (NSArray *ns_arr = NapiArrayToNSArray(array)) {
      [defaults setObject:ns_arr forKey:default_key];
    }
  } else if (type == "dictionary") {
    Napi::Value value = info[2].As<Napi::Value>();
    if (NSDictionary *dict = NapiObjectToNSDictionary(value)) {
      [defaults setObject:dict forKey:default_key];
    }
  }
}

// Removes the default for 'key' in NSUserDefaults.
void RemoveUserDefault(const Napi::CallbackInfo &info) {
  const std::string key = (std::string)info[0].ToString();
  NSString *default_key = ToNSString(key);

  NSUserDefaults *defaults = [&]() {
    if (!info[1].IsEmpty()) {
      const std::string domain = (std::string)info[1].ToString();
      return [[NSUserDefaults alloc] initWithSuiteName:ToNSString(domain)];
    }
    return [NSUserDefaults standardUserDefaults];
  }();

  [defaults removeObjectForKey:default_key];
}

// Returns whether or not an NSUserDefault is managed by an admin.
Napi::Boolean IsKeyManaged(const Napi::CallbackInfo &info) {
  const std::string key = (std::string)info[0].ToString();

  NSUserDefaults *defaults = [&]() {
    if (!info[1].IsEmpty()) {
      const std::string domain = (std::string)info[1].ToString();
      return [[NSUserDefaults alloc] initWithSuiteName:ToNSString(domain)];
    }
    return [NSUserDefaults standardUserDefaults];
  }();

  bool managed = [defaults objectIsForcedForKey:ToNSString(key)];

  return Napi::Boolean::New(info.Env(), managed);
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "isKeyManaged"),
              Napi::Function::New(env, IsKeyManaged));
  exports.Set(Napi::String::New(env, "getAllDefaults"),
              Napi::Function::New(env, GetAllDefaults));
  exports.Set(Napi::String::New(env, "getUserDefault"),
              Napi::Function::New(env, GetUserDefault));
  exports.Set(Napi::String::New(env, "setUserDefault"),
              Napi::Function::New(env, SetUserDefault));
  exports.Set(Napi::String::New(env, "removeUserDefault"),
              Napi::Function::New(env, RemoveUserDefault));

  return exports;
}

NODE_API_MODULE(defaults, Init)