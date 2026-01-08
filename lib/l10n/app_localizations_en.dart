// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_discover => 'Discover';

  @override
  String get common_myProfile => 'My Profile';

  @override
  String get common_savedListings => 'Saved Listings';

  @override
  String get common_chat => 'Chat';

  @override
  String get common_editProfile => 'Edit Profile';

  @override
  String get common_save => 'Save';

  @override
  String get common_post => 'Post';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get discover_searchHint => 'Bukit Jalil LRT, APU, Sunway Pyramid';

  @override
  String get discover_noPostsFound =>
      'No posts found matching your criteria.\nTry adjusting the filters.';

  @override
  String get discover_filtersTitle => 'Filters';

  @override
  String get discover_clearAll => 'Clear All';

  @override
  String get discover_applyFilters => 'Apply Filters';

  @override
  String get discover_aiSearchAssistant => 'AI Search Assistant';

  @override
  String get discover_tryMe => 'Try Me!!';

  @override
  String get discover_propertyDetails => 'Property Details';

  @override
  String get discover_gender => 'Gender';

  @override
  String get discover_roomType => 'Room Type';

  @override
  String get discover_rentRange => 'Rent Range (RM)';

  @override
  String get discover_availability => 'Availability';

  @override
  String get discover_durationMonths => 'Duration (Months)';

  @override
  String get discover_anyDate => 'Any Date';

  @override
  String get postDetail_listedBy => 'Listed by';

  @override
  String get postDetail_inquire => 'Inquire';

  @override
  String get postDetail_description => 'Description';

  @override
  String get postDetail_noDescription => 'No description provided.';

  @override
  String get postDetail_contactOnWhatsapp => 'Contact on WhatsApp';

  @override
  String get postDetail_noPhoneNumber =>
      'No phone number available for this agent.';

  @override
  String get postDetail_commentCount => 'View Comments';

  @override
  String get postDetail_deletePost => 'Delete Post';

  @override
  String get postDetail_editPost => 'Edit Post';

  @override
  String get postDetail_chat => 'Start Chat';

  @override
  String get deposit_breakdownTitle => 'Initial Payment Breakdown';

  @override
  String get deposit_advanceRental => 'Advance Rental (1st month)';

  @override
  String get deposit_securityDeposit => 'Security Deposit';

  @override
  String get deposit_utilityDeposit => 'Utility Deposit';

  @override
  String get deposit_totalMoveInCost => 'Total Move-in Cost';

  @override
  String get deposit_mths => 'mths';

  @override
  String get tenantList_title => 'Find Roommates';

  @override
  String get tenantList_searchPromptTitle => 'Find Your Ideal Tenant';

  @override
  String get tenantList_searchPromptDesc =>
      'Select one of your properties or use filters\nto find tenants matching your criteria.';

  @override
  String get tenantList_matchButton => 'Match with Property';

  @override
  String get tenantList_searchBarTitle => 'Find with your property';

  @override
  String get tenantList_searchBarSubtitle => 'Tap here!!';

  @override
  String get tenantList_sheetTitle => 'Select a Property';

  @override
  String get tenantList_guestSheetTitle => 'Search with your Property!!';

  @override
  String get tenantList_guestSheetDesc =>
      'Don\'t search manually. Select one of your properties, and we\'ll instantly show you tenants whose budget and location preferences match yours.';

  @override
  String get tenantList_benefitMatch => 'Match by Budget & Location';

  @override
  String get tenantList_benefitSaveTime => 'Save hours of scrolling';

  @override
  String get tenantList_loginButton => 'Log in to Match Properties';

  @override
  String get tenantList_activeMatching => 'ACTIVE MATCHING';

  @override
  String get tenantList_clearSnackBar =>
      'Matching cleared. Showing all tenants.';

  @override
  String tenantList_searchingSnackBar(Object name) {
    return 'Searching tenants for $name...';
  }

  @override
  String placeholder_rmPerMonth(Object amount) {
    return 'RM $amount / month';
  }

  @override
  String placeholder_age(Object age) {
    return '$age years old';
  }

  @override
  String get tenantFilter_title => 'Filters';

  @override
  String get tenantFilter_clearAll => 'Clear All';

  @override
  String get tenantFilter_tenancyDetails => 'Tenancy Details';

  @override
  String get tenantFilter_moveInDate => 'Move-in Date';

  @override
  String get tenantFilter_anyDate => 'Any Date';

  @override
  String get tenantFilter_pax => 'Pax';

  @override
  String get tenantFilter_tenantPreferences => 'Tenant Preferences';

  @override
  String get tenantFilter_roomType => 'Room Type';

  @override
  String get tenantFilter_budgetRange => 'Budget Range';

  @override
  String get tenantFilter_budget5000Plus => 'RM 5000+';

  @override
  String get tenantFilter_tenantProfile => 'Tenant Profile';

  @override
  String get tenantFilter_gender => 'Gender';

  @override
  String get tenantFilter_nationality => 'Nationality';

  @override
  String get tenantFilter_nationalityHint => 'e.g. Japanese';

  @override
  String get tenantFilter_applyFilters => 'Apply Filters';

  @override
  String get tenantFilter_roomSingle => 'Single';

  @override
  String get tenantFilter_roomMiddle => 'Middle';

  @override
  String get tenantFilter_roomMaster => 'Master';

  @override
  String get tenantFilter_genderMale => 'Male';

  @override
  String get tenantFilter_genderFemale => 'Female';

  @override
  String get tenantFilter_genderMix => 'Mix';

  @override
  String get profile_personalInfo => 'Personal Info';

  @override
  String get profile_occupation => 'Occupation';

  @override
  String get profile_workLocation => 'Work/Study Location';

  @override
  String get profile_aboutMe => 'About Me';

  @override
  String get profile_hobbies => 'Hobbies';

  @override
  String get profile_preferences => 'Preferences';

  @override
  String get profile_preferredAreas => 'Preferred Areas';

  @override
  String get profile_budget => 'Budget';

  @override
  String get profile_numberOfPax => 'Number of Pax';

  @override
  String profile_paxCount(Object count) {
    return '$count person(s)';
  }

  @override
  String get profile_roomPreference => 'Room Preference';

  @override
  String get profile_propertyPreference => 'Property Preference';

  @override
  String get profile_pets => 'Pets';

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_createProfile => 'Create Profile';

  @override
  String get profile_benefitBanner =>
      'If you create profile, agent who has your ideal room can find you!';

  @override
  String get profile_displayName => 'Display Name';

  @override
  String get profile_required => 'Required';

  @override
  String get profile_selfIntroduction => 'Self Introduction';

  @override
  String profile_ageYears(Object age) {
    return '$age years';
  }

  @override
  String get profile_notSet => 'Not set';

  @override
  String get profile_preferredLivingAreas => 'Preferred Living Areas';

  @override
  String get profile_addAreaHint => 'Add area (e.g. Bangsar)';

  @override
  String get profile_allowPets => 'Allow Pets?';

  @override
  String get profile_monthlyBudget => 'Monthly Budget';

  @override
  String get profile_saveProfile => 'Save Profile';

  @override
  String get profile_skip => 'Skip creating profile as of now';

  @override
  String get profile_updatedSuccess => 'Profile updated successfully!';

  @override
  String profile_updateFailed(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String profile_uploadFailed(Object error) {
    return 'Failed to upload image: $error';
  }

  @override
  String get profile_notSpecified => 'Not specified';

  @override
  String get profile_yes => 'Yes';

  @override
  String get profile_no => 'No';

  @override
  String get profile_any => 'Any';

  @override
  String get propertyType_condo => 'Condominium';

  @override
  String get propertyType_apartment => 'Apartment';

  @override
  String get propertyType_landed => 'Landed House';

  @override
  String get propertyType_studio => 'Studio';
}
