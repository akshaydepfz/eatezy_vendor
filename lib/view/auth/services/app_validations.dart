class AppValidations {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email address.';
    }
    RegExp emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? email) {
    if (email == null) {
      return 'Password is required';
    }
    if (email.length < 8) {
      return 'Atleast 8 characters required';
    }
    return null;
  }
}
