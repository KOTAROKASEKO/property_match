// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get common_discover => '探す';

  @override
  String get common_myProfile => 'マイプロフィール';

  @override
  String get common_savedListings => '保存した物件';

  @override
  String get common_chat => 'チャット';

  @override
  String get common_editProfile => 'プロフィール編集';

  @override
  String get common_save => '保存';

  @override
  String get common_post => '投稿';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get discover_searchHint => 'ブキット・ジャリル LRT, APU, サンウェイ・ピラミッド';

  @override
  String get discover_noPostsFound =>
      '条件に一致する投稿は見つかりませんでした。\nフィルターを調整してみてください。';

  @override
  String get discover_filtersTitle => 'フィルター';

  @override
  String get discover_clearAll => 'すべてクリア';

  @override
  String get discover_applyFilters => 'フィルターを適用';

  @override
  String get discover_aiSearchAssistant => 'AI検索アシスタント';

  @override
  String get discover_tryMe => '試す!!';

  @override
  String get discover_propertyDetails => '物件詳細';

  @override
  String get discover_gender => '性別';

  @override
  String get discover_roomType => '部屋タイプ';

  @override
  String get discover_rentRange => '家賃範囲 (RM)';

  @override
  String get discover_availability => '入居可能期間';

  @override
  String get discover_durationMonths => '期間 (月)';

  @override
  String get discover_anyDate => 'いつでも';

  @override
  String get postDetail_listedBy => '掲載者';

  @override
  String get postDetail_inquire => '問い合わせる';

  @override
  String get postDetail_description => '説明';

  @override
  String get postDetail_noDescription => '説明はありません。';

  @override
  String get postDetail_contactOnWhatsapp => 'WhatsAppで連絡';

  @override
  String get postDetail_noPhoneNumber => 'このエージェントの電話番号はありません。';

  @override
  String get postDetail_commentCount => 'コメントを見る';

  @override
  String get postDetail_deletePost => '投稿を削除';

  @override
  String get postDetail_editPost => '投稿を編集';

  @override
  String get postDetail_chat => 'チャットを開始';

  @override
  String get deposit_breakdownTitle => '初期費用内訳';

  @override
  String get deposit_advanceRental => '前家賃 (1ヶ月目)';

  @override
  String get deposit_securityDeposit => '敷金';

  @override
  String get deposit_utilityDeposit => '光熱費デポジット';

  @override
  String get deposit_totalMoveInCost => '総初期費用';

  @override
  String get deposit_mths => 'ヶ月分';

  @override
  String get tenantList_title => 'ルームメイトを探す';

  @override
  String get tenantList_searchPromptTitle => '理想のテナントを見つけよう';

  @override
  String get tenantList_searchPromptDesc =>
      'あなたの物件を選択するか、フィルターを使用して\n条件に合うテナントを探しましょう。';

  @override
  String get tenantList_matchButton => '物件とマッチング';

  @override
  String get tenantList_searchBarTitle => '物件情報で探す';

  @override
  String get tenantList_searchBarSubtitle => 'ここをタップ!!';

  @override
  String get tenantList_sheetTitle => '物件を選択';

  @override
  String get tenantList_guestSheetTitle => '物件情報を使って検索!!';

  @override
  String get tenantList_guestSheetDesc =>
      '手動で探すのはもう終わり。物件を選択するだけで、予算や場所の希望が合うテナントを瞬時に表示します。';

  @override
  String get tenantList_benefitMatch => '予算と場所でマッチング';

  @override
  String get tenantList_benefitSaveTime => 'スクロールの手間を大幅削減';

  @override
  String get tenantList_loginButton => 'ログインしてマッチング';

  @override
  String get tenantList_activeMatching => 'マッチング適用中';

  @override
  String get tenantList_clearSnackBar => 'マッチングを解除しました。すべてのテナントを表示します。';

  @override
  String tenantList_searchingSnackBar(Object name) {
    return '$name に合うテナントを検索中...';
  }

  @override
  String placeholder_rmPerMonth(Object amount) {
    return '月額 RM $amount';
  }

  @override
  String placeholder_age(Object age) {
    return '$age 歳';
  }

  @override
  String get tenantFilter_title => 'フィルター';

  @override
  String get tenantFilter_clearAll => 'すべてクリア';

  @override
  String get tenantFilter_tenancyDetails => '入居詳細';

  @override
  String get tenantFilter_moveInDate => '入居日';

  @override
  String get tenantFilter_anyDate => '指定なし';

  @override
  String get tenantFilter_pax => '人数';

  @override
  String get tenantFilter_tenantPreferences => '希望条件';

  @override
  String get tenantFilter_roomType => '部屋タイプ';

  @override
  String get tenantFilter_budgetRange => '予算範囲';

  @override
  String get tenantFilter_budget5000Plus => 'RM 5000以上';

  @override
  String get tenantFilter_tenantProfile => 'テナント情報';

  @override
  String get tenantFilter_gender => '性別';

  @override
  String get tenantFilter_nationality => '国籍';

  @override
  String get tenantFilter_nationalityHint => '例: Japanese';

  @override
  String get tenantFilter_applyFilters => 'フィルターを適用';

  @override
  String get tenantFilter_roomSingle => 'シングル';

  @override
  String get tenantFilter_roomMiddle => 'ミドル';

  @override
  String get tenantFilter_roomMaster => 'マスター';

  @override
  String get tenantFilter_genderMale => '男性';

  @override
  String get tenantFilter_genderFemale => '女性';

  @override
  String get tenantFilter_genderMix => '男女共用';

  @override
  String get profile_personalInfo => '基本情報';

  @override
  String get profile_occupation => '職業';

  @override
  String get profile_workLocation => '勤務地 / 通学先';

  @override
  String get profile_aboutMe => '自己紹介';

  @override
  String get profile_hobbies => '趣味';

  @override
  String get profile_preferences => '希望条件';

  @override
  String get profile_preferredAreas => '希望エリア';

  @override
  String get profile_budget => '予算';

  @override
  String get profile_numberOfPax => '入居人数';

  @override
  String profile_paxCount(Object count) {
    return '$count 名';
  }

  @override
  String get profile_roomPreference => '希望の部屋タイプ';

  @override
  String get profile_propertyPreference => '希望の物件タイプ';

  @override
  String get profile_pets => 'ペット';

  @override
  String get profile_logout => 'ログアウト';

  @override
  String get profile_createProfile => 'プロフィール作成';

  @override
  String get profile_benefitBanner =>
      'プロフィールを作成すると、条件に合う物件を持つエージェントから連絡が来るかもしれません！';

  @override
  String get profile_displayName => '表示名';

  @override
  String get profile_required => '必須';

  @override
  String get profile_selfIntroduction => '自己紹介';

  @override
  String profile_ageYears(Object age) {
    return '$age 歳';
  }

  @override
  String get profile_notSet => '未設定';

  @override
  String get profile_preferredLivingAreas => '住みたいエリア';

  @override
  String get profile_addAreaHint => 'エリアを追加 (例: Bangsar)';

  @override
  String get profile_allowPets => 'ペット可否';

  @override
  String get profile_monthlyBudget => '月額予算';

  @override
  String get profile_saveProfile => 'プロフィールを保存';

  @override
  String get profile_skip => '今はスキップする';

  @override
  String get profile_updatedSuccess => 'プロフィールを更新しました！';

  @override
  String profile_updateFailed(Object error) {
    return 'プロフィールの更新に失敗しました: $error';
  }

  @override
  String profile_uploadFailed(Object error) {
    return '画像のアップロードに失敗しました: $error';
  }

  @override
  String get profile_notSpecified => '指定なし';

  @override
  String get profile_yes => 'はい';

  @override
  String get profile_no => 'いいえ';

  @override
  String get profile_any => '指定なし';

  @override
  String get propertyType_condo => 'コンドミニアム';

  @override
  String get propertyType_apartment => 'アパート';

  @override
  String get propertyType_landed => '一軒家';

  @override
  String get propertyType_studio => 'スタジオ';
}
