class Validator {

  static String validateNotEmpty(String input){
    if(input.isEmpty){
      return "Cannot be empty";
    }
    return null;
  }

  static String validateShortLength(String input){
    if (validateNotEmpty(input) != null) {
      return validateNotEmpty(input);
    } else {
      if(input.length > 30){
        return "Exceeds character limit (30)";
      }
    }
    return null;
  }

  static String validateLongLength(String input){
    if (validateNotEmpty(input) != null) {
      return validateNotEmpty(input);
    } else {
      if(input.length > 300){
        return "Exceeds character limit (300)";
      }
    }
    return null;
  }

  static String validateEmail(String input){
    if(validateShortLength(input) != null){
      return validateShortLength(input);
    } else {
      RegExp regex = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
      if(!regex.hasMatch(input)){
        return "Not a valid email";
      }
    }
    return null;
  }

}