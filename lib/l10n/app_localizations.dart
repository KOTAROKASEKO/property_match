import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @common_discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get common_discover;

  /// No description provided for @common_myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get common_myProfile;

  /// No description provided for @common_savedListings.
  ///
  /// In en, this message translates to:
  /// **'Saved Listings'**
  String get common_savedListings;

  /// No description provided for @common_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get common_chat;

  /// No description provided for @common_editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get common_editProfile;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get common_post;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @discover_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Bukit Jalil LRT, APU, Sunway Pyramid'**
  String get discover_searchHint;

  /// No description provided for @discover_noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found matching your criteria.\nTry adjusting the filters.'**
  String get discover_noPostsFound;

  /// No description provided for @discover_filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get discover_filtersTitle;

  /// No description provided for @discover_clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get discover_clearAll;

  /// No description provided for @discover_applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get discover_applyFilters;

  /// No description provided for @discover_aiSearchAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Search Assistant'**
  String get discover_aiSearchAssistant;

  /// No description provided for @discover_tryMe.
  ///
  /// In en, this message translates to:
  /// **'Try Me!!'**
  String get discover_tryMe;

  /// No description provided for @discover_propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get discover_propertyDetails;

  /// No description provided for @discover_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get discover_gender;

  /// No description provided for @discover_roomType.
  ///
  /// In en, this message translates to:
  /// **'Room Type'**
  String get discover_roomType;

  /// No description provided for @discover_rentRange.
  ///
  /// In en, this message translates to:
  /// **'Rent Range (RM)'**
  String get discover_rentRange;

  /// No description provided for @discover_availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get discover_availability;

  /// No description provided for @discover_durationMonths.
  ///
  /// In en, this message translates to:
  /// **'Duration (Months)'**
  String get discover_durationMonths;

  /// No description provided for @discover_anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any Date'**
  String get discover_anyDate;

  /// No description provided for @postDetail_listedBy.
  ///
  /// In en, this message translates to:
  /// **'Listed by'**
  String get postDetail_listedBy;

  /// No description provided for @postDetail_inquire.
  ///
  /// In en, this message translates to:
  /// **'Inquire'**
  String get postDetail_inquire;

  /// No description provided for @postDetail_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get postDetail_description;

  /// No description provided for @postDetail_noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get postDetail_noDescription;

  /// No description provided for @postDetail_contactOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Contact on WhatsApp'**
  String get postDetail_contactOnWhatsapp;

  /// No description provided for @postDetail_noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number available for this agent.'**
  String get postDetail_noPhoneNumber;

  /// No description provided for @postDetail_commentCount.
  ///
  /// In en, this message translates to:
  /// **'View Comments'**
  String get postDetail_commentCount;

  /// No description provided for @postDetail_deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get postDetail_deletePost;

  /// No description provided for @postDetail_editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get postDetail_editPost;

  /// No description provided for @postDetail_chat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get postDetail_chat;

  /// No description provided for @deposit_breakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Initial Payment Breakdown'**
  String get deposit_breakdownTitle;

  /// No description provided for @deposit_advanceRental.
  ///
  /// In en, this message translates to:
  /// **'Advance Rental (1st month)'**
  String get deposit_advanceRental;

  /// No description provided for @deposit_securityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Security Deposit'**
  String get deposit_securityDeposit;

  /// No description provided for @deposit_utilityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Utility Deposit'**
  String get deposit_utilityDeposit;

  /// No description provided for @deposit_totalMoveInCost.
  ///
  /// In en, this message translates to:
  /// **'Total Move-in Cost'**
  String get deposit_totalMoveInCost;

  /// No description provided for @deposit_mths.
  ///
  /// In en, this message translates to:
  /// **'mths'**
  String get deposit_mths;

  /// No description provided for @tenantList_title.
  ///
  /// In en, this message translates to:
  /// **'Find Roommates'**
  String get tenantList_title;

  /// No description provided for @tenantList_searchPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Ideal Tenant'**
  String get tenantList_searchPromptTitle;

  /// No description provided for @tenantList_searchPromptDesc.
  ///
  /// In en, this message translates to:
  /// **'Select one of your properties or use filters\nto find tenants matching your criteria.'**
  String get tenantList_searchPromptDesc;

  /// No description provided for @tenantList_matchButton.
  ///
  /// In en, this message translates to:
  /// **'Match with Property'**
  String get tenantList_matchButton;

  /// No description provided for @tenantList_searchBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Find with your property'**
  String get tenantList_searchBarTitle;

  /// No description provided for @tenantList_searchBarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap here!!'**
  String get tenantList_searchBarSubtitle;

  /// No description provided for @tenantList_sheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Property'**
  String get tenantList_sheetTitle;

  /// No description provided for @tenantList_guestSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Search with your Property!!'**
  String get tenantList_guestSheetTitle;

  /// No description provided for @tenantList_guestSheetDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t search manually. Select one of your properties, and we\'ll instantly show you tenants whose budget and location preferences match yours.'**
  String get tenantList_guestSheetDesc;

  /// No description provided for @tenantList_benefitMatch.
  ///
  /// In en, this message translates to:
  /// **'Match by Budget & Location'**
  String get tenantList_benefitMatch;

  /// No description provided for @tenantList_benefitSaveTime.
  ///
  /// In en, this message translates to:
  /// **'Save hours of scrolling'**
  String get tenantList_benefitSaveTime;

  /// No description provided for @tenantList_loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in to Match Properties'**
  String get tenantList_loginButton;

  /// No description provided for @tenantList_activeMatching.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE MATCHING'**
  String get tenantList_activeMatching;

  /// No description provided for @tenantList_clearSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Matching cleared. Showing all tenants.'**
  String get tenantList_clearSnackBar;

  /// No description provided for @tenantList_searchingSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Searching tenants for {name}...'**
  String tenantList_searchingSnackBar(Object name);

  /// No description provided for @placeholder_rmPerMonth.
  ///
  /// In en, this message translates to:
  /// **'RM {amount} / month'**
  String placeholder_rmPerMonth(Object amount);

  /// No description provided for @placeholder_age.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String placeholder_age(Object age);

  /// No description provided for @tenantFilter_title.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get tenantFilter_title;

  /// No description provided for @tenantFilter_clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get tenantFilter_clearAll;

  /// No description provided for @tenantFilter_tenancyDetails.
  ///
  /// In en, this message translates to:
  /// **'Tenancy Details'**
  String get tenantFilter_tenancyDetails;

  /// No description provided for @tenantFilter_moveInDate.
  ///
  /// In en, this message translates to:
  /// **'Move-in Date'**
  String get tenantFilter_moveInDate;

  /// No description provided for @tenantFilter_anyDate.
  ///
  /// In en, this message translates to:
  /// **'Any Date'**
  String get tenantFilter_anyDate;

  /// No description provided for @tenantFilter_pax.
  ///
  /// In en, this message translates to:
  /// **'Pax'**
  String get tenantFilter_pax;

  /// No description provided for @tenantFilter_tenantPreferences.
  ///
  /// In en, this message translates to:
  /// **'Tenant Preferences'**
  String get tenantFilter_tenantPreferences;

  /// No description provided for @tenantFilter_roomType.
  ///
  /// In en, this message translates to:
  /// **'Room Type'**
  String get tenantFilter_roomType;

  /// No description provided for @tenantFilter_budgetRange.
  ///
  /// In en, this message translates to:
  /// **'Budget Range'**
  String get tenantFilter_budgetRange;

  /// No description provided for @tenantFilter_budget5000Plus.
  ///
  /// In en, this message translates to:
  /// **'RM 5000+'**
  String get tenantFilter_budget5000Plus;

  /// No description provided for @tenantFilter_tenantProfile.
  ///
  /// In en, this message translates to:
  /// **'Tenant Profile'**
  String get tenantFilter_tenantProfile;

  /// No description provided for @tenantFilter_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get tenantFilter_gender;

  /// No description provided for @tenantFilter_nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get tenantFilter_nationality;

  /// No description provided for @tenantFilter_nationalityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Japanese'**
  String get tenantFilter_nationalityHint;

  /// No description provided for @tenantFilter_applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get tenantFilter_applyFilters;

  /// No description provided for @tenantFilter_roomSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get tenantFilter_roomSingle;

  /// No description provided for @tenantFilter_roomMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle'**
  String get tenantFilter_roomMiddle;

  /// No description provided for @tenantFilter_roomMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get tenantFilter_roomMaster;

  /// No description provided for @tenantFilter_genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get tenantFilter_genderMale;

  /// No description provided for @tenantFilter_genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get tenantFilter_genderFemale;

  /// No description provided for @tenantFilter_genderMix.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get tenantFilter_genderMix;

  /// No description provided for @profile_personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get profile_personalInfo;

  /// No description provided for @profile_occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get profile_occupation;

  /// No description provided for @profile_workLocation.
  ///
  /// In en, this message translates to:
  /// **'Work/Study Location'**
  String get profile_workLocation;

  /// No description provided for @profile_aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get profile_aboutMe;

  /// No description provided for @profile_hobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get profile_hobbies;

  /// No description provided for @profile_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profile_preferences;

  /// No description provided for @profile_preferredAreas.
  ///
  /// In en, this message translates to:
  /// **'Preferred Areas'**
  String get profile_preferredAreas;

  /// No description provided for @profile_budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get profile_budget;

  /// No description provided for @profile_numberOfPax.
  ///
  /// In en, this message translates to:
  /// **'Number of Pax'**
  String get profile_numberOfPax;

  /// No description provided for @profile_paxCount.
  ///
  /// In en, this message translates to:
  /// **'{count} person(s)'**
  String profile_paxCount(Object count);

  /// No description provided for @profile_roomPreference.
  ///
  /// In en, this message translates to:
  /// **'Room Preference'**
  String get profile_roomPreference;

  /// No description provided for @profile_propertyPreference.
  ///
  /// In en, this message translates to:
  /// **'Property Preference'**
  String get profile_propertyPreference;

  /// No description provided for @profile_pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get profile_pets;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get profile_createProfile;

  /// No description provided for @profile_benefitBanner.
  ///
  /// In en, this message translates to:
  /// **'If you create profile, agent who has your ideal room can find you!'**
  String get profile_benefitBanner;

  /// No description provided for @profile_displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profile_displayName;

  /// No description provided for @profile_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get profile_required;

  /// No description provided for @profile_selfIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Self Introduction'**
  String get profile_selfIntroduction;

  /// No description provided for @profile_ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String profile_ageYears(Object age);

  /// No description provided for @profile_notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profile_notSet;

  /// No description provided for @profile_preferredLivingAreas.
  ///
  /// In en, this message translates to:
  /// **'Preferred Living Areas'**
  String get profile_preferredLivingAreas;

  /// No description provided for @profile_addAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Add area (e.g. Bangsar)'**
  String get profile_addAreaHint;

  /// No description provided for @profile_allowPets.
  ///
  /// In en, this message translates to:
  /// **'Allow Pets?'**
  String get profile_allowPets;

  /// No description provided for @profile_monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get profile_monthlyBudget;

  /// No description provided for @profile_saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profile_saveProfile;

  /// No description provided for @profile_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip creating profile as of now'**
  String get profile_skip;

  /// No description provided for @profile_updatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profile_updatedSuccess;

  /// No description provided for @profile_updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String profile_updateFailed(Object error);

  /// No description provided for @profile_uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image: {error}'**
  String profile_uploadFailed(Object error);

  /// No description provided for @profile_notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get profile_notSpecified;

  /// No description provided for @profile_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get profile_yes;

  /// No description provided for @profile_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get profile_no;

  /// No description provided for @profile_any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get profile_any;

  /// No description provided for @propertyType_condo.
  ///
  /// In en, this message translates to:
  /// **'Condominium'**
  String get propertyType_condo;

  /// No description provided for @propertyType_apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get propertyType_apartment;

  /// No description provided for @propertyType_landed.
  ///
  /// In en, this message translates to:
  /// **'Landed House'**
  String get propertyType_landed;

  /// No description provided for @propertyType_studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get propertyType_studio;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
