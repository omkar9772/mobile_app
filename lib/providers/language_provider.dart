import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  bool get isMarathi => _currentLocale.languageCode == 'mr';

  void toggleLanguage() {
    _currentLocale = _currentLocale.languageCode == 'en' 
        ? const Locale('mr') 
        : const Locale('en');
    notifyListeners();
  }

  // Dictionary of localized strings
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App Common
      'app_title': 'Naad Bailgada',
      'app_subtitle': 'Bailgada Sharyat',
      'app_version': 'Naad Bailgada v1.0.0',

      // Bottom Navigation
      'nav_home': 'Home',
      'nav_races': 'Races',
      'nav_community': 'Community',
      'nav_available': 'Available',
      'nav_profile': 'Profile',

      // Common Actions
      'cancel': 'Cancel',
      'retry': 'Retry',
      'required': 'Required',

      // Home Screen
      'welcome_back': 'Welcome back',
      'recent_results': 'Recent Results',
      'upcoming_races': 'Upcoming Races',
      'no_races': 'No races available right now',
      'try_again': 'Try Again',

      // Auth/Login
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'contact_admin_reset': 'Contact Admin to reset password',
      'full_name': 'Full Name',
      'email': 'Email',
      'phone_optional': 'Phone (Optional)',
      'create_account': 'Create Account',
      'min_3_chars': 'Min 3 chars',
      'min_6_chars': 'Min 6 chars',
      'invalid_email': 'Invalid email',

      // Logout
      'logout': 'Logout',
      'log_out': 'Log Out',
      'logout_confirm_title': 'Logout',
      'logout_confirm_msg': 'Are you sure you want to logout?',

      // Profile Screen
      'profile': 'Profile',
      'my_bulls_for_sale': 'My Bulls for Sale',
      'manage_listings': 'Manage your listings',
      'edit_profile': 'Edit Profile',
      'update_details': 'Update your details',
      'change_password': 'Change Password',
      'update_security': 'Update your security',
      'support_contribution': 'Support & Contribution',
      'email_us': 'Email Us',
      'email_address': 'info@naadbailgada.com',
      'share_via_whatsapp': 'Share Data via WhatsApp',
      'submit_race_bull_details': 'Submit Race/Bull details',
      'follow_us': 'Follow Us',
      'youtube': 'YouTube',
      'naad_bailgada_official': 'Naad Bailgada Official',
      'instagram': 'Instagram',
      'instagram_handle': '@naad_bailgada.official',
      'could_not_launch_app': 'Could not launch app',

      // Edit Profile
      'update_your_profile': 'Update Your Profile',
      'edit_personal_info': 'Edit your personal information',
      'must_be_unique': 'Must be unique',
      'full_name_optional': 'Full Name (Optional)',
      'update_profile': 'Update Profile',
      'profile_updated': 'Profile updated successfully!',
      'enter_username': 'Please enter username',
      'username_min_3': 'Username must be at least 3 characters',
      'username_max_50': 'Username must not exceed 50 characters',
      'enter_email': 'Please enter email',
      'valid_email': 'Please enter a valid email',

      // Change Password
      'change_your_password': 'Change Your Password',
      'enter_current_new_password': 'Enter your current password and choose a new one',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm New Password',
      'password_changed': 'Password changed successfully!',
      'enter_current_password': 'Please enter current password',
      'enter_new_password': 'Please enter new password',
      'password_min_6': 'Password must be at least 6 characters',
      'confirm_password': 'Please confirm new password',
      'passwords_not_match': 'New passwords do not match',

      // Race Details
      'race_details': 'Race Details',
      'dates': 'Dates',
      'location': 'Location',
      'track_length': 'Track Length',
      'description': 'Description',

      // Bulls/Community
      'champions': 'Champions',
      'owners': 'Owners',
      'search_champions': 'Search champions...',
      'search_owners': 'Search owners...',
      'filter_all': 'All',
      'filter_name': 'Name',
      'filter_location': 'Location',
      'no_more_bulls': 'No more bulls',
      'no_bulls_found': 'No bulls found',
      'no_bulls_match': 'No bulls match your search',
      'no_more_owners': 'No more owners',
      'no_owners_found': 'No owners found',
      'no_owners_match': 'No owners match your search',
      'bulls_count': 'Bulls',

      // Races Screen
      'all_races': 'All Races',
      'search_races': 'Search by race name or location...',
      'no_races_found': 'No races found',
      'no_races_match': 'No races match your search',
      'no_more_races': 'No more races',

      // Marketplace
      'marketplace': 'Marketplace',
      'no_more_listings': 'No more listings',
      'no_bulls_available': 'No bulls available yet',
      'owner': 'Owner',
      'could_not_launch_phone': 'Could not launch phone app',

      // Bull Details
      'wins': 'Wins',
      'color': 'Color',
      'age': 'Age',
      'share_profile': 'Share Profile',
    },
    'mr': {
      // App Common
      'app_title': 'नाद बैलगाडा',
      'app_subtitle': 'बैलगाडा शर्यत',
      'app_version': 'नाद बैलगाडा v1.0.0',

      // Bottom Navigation
      'nav_home': 'मुख्यपृष्ठ',
      'nav_races': 'शर्यती',
      'nav_community': 'समुदाय',
      'nav_available': 'उपलब्ध',
      'nav_profile': 'प्रोफाईल',

      // Common Actions
      'cancel': 'रद्द करा',
      'retry': 'पुन्हा प्रयत्न करा',
      'required': 'आवश्यक',

      // Home Screen
      'welcome_back': 'स्वागत आहे',
      'recent_results': 'अलीकडील निकाल',
      'upcoming_races': 'आगामी शर्यती',
      'no_races': 'सध्या कोणतीही शर्यत उपलब्ध नाही',
      'try_again': 'पुन्हा प्रयत्न करा',

      // Auth/Login
      'login': 'लॉगिन',
      'register': 'नोंदणी',
      'username': 'वापरकर्तानाव',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड विसरलात?',
      'contact_admin_reset': 'पासवर्ड रीसेट करण्यासाठी अॅडमिनशी संपर्क साधा',
      'full_name': 'पूर्ण नाव',
      'email': 'ईमेल',
      'phone_optional': 'फोन (ऐच्छिक)',
      'create_account': 'खाते तयार करा',
      'min_3_chars': 'किमान ३ अक्षरे',
      'min_6_chars': 'किमान ६ अक्षरे',
      'invalid_email': 'अवैध ईमेल',

      // Logout
      'logout': 'बाहेर पडा',
      'log_out': 'बाहेर पडा',
      'logout_confirm_title': 'बाहेर पडा',
      'logout_confirm_msg': 'तुम्हाला नक्की लॉगआउट करायचे आहे का?',

      // Profile Screen
      'profile': 'प्रोफाईल',
      'my_bulls_for_sale': 'माझे विक्रीसाठी बैल',
      'manage_listings': 'तुमची यादी व्यवस्थापित करा',
      'edit_profile': 'प्रोफाईल संपादित करा',
      'update_details': 'तुमचे तपशील अपडेट करा',
      'change_password': 'पासवर्ड बदला',
      'update_security': 'तुमची सुरक्षा अपडेट करा',
      'support_contribution': 'समर्थन आणि योगदान',
      'email_us': 'आम्हाला ईमेल करा',
      'email_address': 'info@naadbailgada.com',
      'share_via_whatsapp': 'व्हाट्सअॅपद्वारे डेटा शेअर करा',
      'submit_race_bull_details': 'शर्यत/बैल तपशील सबमिट करा',
      'follow_us': 'आम्हाला फॉलो करा',
      'youtube': 'यूट्यूब',
      'naad_bailgada_official': 'नाद बैलगाडा अधिकृत',
      'instagram': 'इंस्टाग्राम',
      'instagram_handle': '@naad_bailgada.official',
      'could_not_launch_app': 'अॅप लाँच करू शकलो नाही',

      // Edit Profile
      'update_your_profile': 'तुमची प्रोफाईल अपडेट करा',
      'edit_personal_info': 'तुमची वैयक्तिक माहिती संपादित करा',
      'must_be_unique': 'अनन्य असणे आवश्यक आहे',
      'full_name_optional': 'पूर्ण नाव (ऐच्छिक)',
      'update_profile': 'प्रोफाईल अपडेट करा',
      'profile_updated': 'प्रोफाईल यशस्वीरित्या अपडेट केले!',
      'enter_username': 'कृपया वापरकर्तानाव प्रविष्ट करा',
      'username_min_3': 'वापरकर्तानाव किमान ३ अक्षरांचे असणे आवश्यक आहे',
      'username_max_50': 'वापरकर्तानाव ५० अक्षरांपेक्षा जास्त नसावे',
      'enter_email': 'कृपया ईमेल प्रविष्ट करा',
      'valid_email': 'कृपया वैध ईमेल प्रविष्ट करा',

      // Change Password
      'change_your_password': 'तुमचा पासवर्ड बदला',
      'enter_current_new_password': 'तुमचा वर्तमान पासवर्ड प्रविष्ट करा आणि नवीन निवडा',
      'current_password': 'वर्तमान पासवर्ड',
      'new_password': 'नवीन पासवर्ड',
      'confirm_new_password': 'नवीन पासवर्डची पुष्टी करा',
      'password_changed': 'पासवर्ड यशस्वीरित्या बदलला!',
      'enter_current_password': 'कृपया वर्तमान पासवर्ड प्रविष्ट करा',
      'enter_new_password': 'कृपया नवीन पासवर्ड प्रविष्ट करा',
      'password_min_6': 'पासवर्ड किमान ६ अक्षरांचा असणे आवश्यक आहे',
      'confirm_password': 'कृपया नवीन पासवर्डची पुष्टी करा',
      'passwords_not_match': 'नवीन पासवर्ड जुळत नाहीत',

      // Race Details
      'race_details': 'शर्यत तपशील',
      'dates': 'तारखा',
      'location': 'स्थान',
      'track_length': 'ट्रॅक लांबी',
      'description': 'वर्णन',

      // Bulls/Community
      'champions': 'चॅम्पियन्स',
      'owners': 'बैलागाडा मालक',
      'search_champions': 'चॅम्पियन शोधा...',
      'search_owners': 'बैलागाडा मालक शोधा...',
      'filter_all': 'सर्व',
      'filter_name': 'नाव',
      'filter_location': 'स्थान',
      'no_more_bulls': 'आणखी बैल नाहीत',
      'no_bulls_found': 'कोणतेही बैल सापडले नाहीत',
      'no_bulls_match': 'तुमच्या शोधाशी कोणतेही बैल जुळत नाहीत',
      'no_more_owners': 'आणखी मालक नाहीत',
      'no_owners_found': 'कोणतेही मालक सापडले नाहीत',
      'no_owners_match': 'तुमच्या शोधाशी कोणतेही मालक जुळत नाहीत',
      'bulls_count': 'बैल',

      // Races Screen
      'all_races': 'सर्व शर्यती',
      'search_races': 'शर्यतीचे नाव किंवा स्थान शोधा...',
      'no_races_found': 'कोणतीही शर्यत सापडली नाही',
      'no_races_match': 'तुमच्या शोधाशी कोणतीही शर्यत जुळत नाही',
      'no_more_races': 'आणखी शर्यती नाहीत',

      // Marketplace
      'marketplace': 'बाजारपेठ',
      'no_more_listings': 'आणखी सूची नाहीत',
      'no_bulls_available': 'अद्याप कोणतेही बैल उपलब्ध नाहीत',
      'owner': 'मालक',
      'could_not_launch_phone': 'फोन अॅप लाँच करू शकलो नाही',

      // Bull Details
      'wins': 'विजय',
      'color': 'रंग',
      'age': 'वय',
      'share_profile': 'प्रोफाईल शेअर करा',
    },
  };

  String getText(String key) {
    return _localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }
}
