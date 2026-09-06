class AppImages {
  // Added trailing slashes to prevent path errors
  static const String imgbasepath = 'assets/images/';
  static const String imgbasepathIcon = 'assets/icons/';
  static const String imgbasepathIconRoot = 'assets/icon/';

  static const String logo = '${imgbasepathIconRoot}logo.svg';

  // Onboarding
  static const String onboarding1 = '${imgbasepath}onboarding1.png';
  static const String onboarding2 = '${imgbasepath}onboarding2.png';
  static const String onboarding3 = '${imgbasepath}onboarding3.png';

  static const String successful = '${imgbasepath}successful.png';
 // static const String manBanner = '${imgbasepath}manP.svg';
  //static const String phoneReceiver = '${imgbasepath}phone-receiver.svg';

  // Avatars / People
  static const String alexSmith = '${imgbasepath}man1.png';
  static const String map = '${imgbasepath}map.png';
  static const String jason = '${imgbasepath}man2.png';
  static const String priya = '${imgbasepath}man3.png';
  static const String david = '${imgbasepath}man4.png';
  static const String emily = '${imgbasepath}man5.png';
  static const String ryan = '${imgbasepath}man6.png';
  static const String sarah = '${imgbasepath}man2.png';
  static const String kevin = '${imgbasepath}man4.png';
  static const String michael = '${imgbasepath}man5.png';
  static const String letsGo = '${imgbasepath}letsGo.png';
  static const String profilePlaceholder =
      '${imgbasepath}man1.png'; // Reusing man1 as placeholder

  // General Icons
  static const String pencil = '${imgbasepathIcon}pencil.svg';
  static const String delete = '${imgbasepathIcon}delete.svg';
  static const String checkbox = '${imgbasepathIcon}checkbox-circle-fill.svg';
  static const String notification = '${imgbasepathIcon}notification.svg';
  static const String bell = '${imgbasepathIcon}bell.svg';

  // Profile Icons
  //
  static const String user = '${imgbasepathIcon}user.svg';
  static const String lock = '${imgbasepathIcon}lock-line.svg';
  static const String wallet = '${imgbasepathIcon}wallet.svg';
  static const String info = '${imgbasepathIcon}info-i.svg';
  static const String logout = '${imgbasepathIcon}logout.svg';
  static const String checkBig = '${imgbasepathIcon}check_big.svg';
  static const String camera = '${imgbasepathIcon}camera.svg';
  static const String visa = '${imgbasepathIcon}icon_visa.svg';

  // Dashboard & Home
  static const String home = '${imgbasepathIcon}home1.svg';
  static const String order = '${imgbasepathIcon}file-list.svg';
  static const String chat = '${imgbasepathIcon}chat.svg';
  static const String profile = '${imgbasepathIcon}user.svg';
  static const String location = '${imgbasepathIcon}home.svg';
  static const String calendar = '${imgbasepathIcon}calendar.svg';
  static const String time = '${imgbasepathIcon}time.svg';
  static const String google = '${imgbasepathIcon}google_icon.svg';
  static const String apple = '${imgbasepathIcon}apple.svg';
  static const String search = '${imgbasepathIcon}search.svg';

  // Home Banner
  static const String homeBanner1 = '${imgbasepath}home_banner1.jpg';
  static const String homeBanner2 = '${imgbasepath}home_banner2.jpg';
  static const String homeBanner3 = '${imgbasepath}home_banner3.jpg';
  static const String homeBanner4 = '${imgbasepath}home_banner4.jpg';

  // Services
   static const String furnitureAssembly =
      '${imgbasepathIcon}furniture_assembly.svg';
  static const String homeAssistance = '${imgbasepathIcon}home_assistance.svg';
  static const String minorRepairs = '${imgbasepathIcon}minor_repairs.svg';
  static const String petServices = '${imgbasepathIcon}pet_services.svg';
  static const String companionService =
      '${imgbasepathIcon}companion_service.svg';
  static const String marketingPromotion = '${imgbasepathIcon}marketing.svg';
  static const String lockSmith = '${imgbasepathIcon}lock_smith.svg';
  static const String gardenCleaning = '${imgbasepathIcon}garden_cleaning.svg';
  static const String addCircle = '${imgbasepathIcon}add-circle-line.svg';

  /// Maps API category icon names to asset paths.
  /// Falls back to [minorRepairs] for unknown icons.
  static String categoryIcon(String? apiIconName) {
    if (apiIconName == null || apiIconName.isEmpty) return minorRepairs;
    switch (apiIconName) {
      case 'plumbing':
      case 'electrical_services':
      case 'hvac':
        return minorRepairs;
      case 'cleaning_services':
      case 'painting':
        return homeAssistance;
      case 'moving':
      case 'carpenter':
        return furnitureAssembly;
      case 'yard':
        return gardenCleaning;
      default:
        return minorRepairs;
    }
  }
}

class AppIcons {
  static const String imgbasepathIcon = 'assets/icons/';
  static const String flagEn = '${imgbasepathIcon}flag_en.svg';
  static const String flagZh = '${imgbasepathIcon}flag_zh.svg';
  static const String arrowRight = '${imgbasepathIcon}arrow_right.svg';
}
