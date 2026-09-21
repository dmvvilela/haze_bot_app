/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 320 (160 per locale)
///
/// Built on 2026-09-21 at 18:12 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	pt(languageCode: 'pt', build: _StringsPt.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _StringsAppEn app = _StringsAppEn._(_root);
	late final _StringsExpressionsEn expressions = _StringsExpressionsEn._(_root);
	late final _StringsFaceTypesEn face_types = _StringsFaceTypesEn._(_root);
	late final _StringsEmotionNamesEn emotion_names = _StringsEmotionNamesEn._(_root);
	late final _StringsGameEn game = _StringsGameEn._(_root);
	late final _StringsLabEn lab = _StringsLabEn._(_root);
	late final _StringsUiEn ui = _StringsUiEn._(_root);
	late final _StringsAureaEn aurea = _StringsAureaEn._(_root);
}

// Path: app
class _StringsAppEn {
	_StringsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'HazeBot Face';
}

// Path: expressions
class _StringsExpressionsEn {
	_StringsExpressionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get happy => 'I am so happy!';
	String get surprised => 'Oh wow! That surprised me!';
	String get sleepy => 'I am feeling sleepy...';
	String get excited => 'This is so exciting!';
	String get confused => 'Hmm, I am confused...';
	String get love => 'I love you!';
	String get angry => 'I am not happy about this!';
	String get winking => 'Wink wink!';
	String get sad => 'I feel a little sad...';
	String get scared => 'Eek! That is scary!';
}

// Path: face_types
class _StringsFaceTypesEn {
	_StringsFaceTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsFaceTypesClassicEn classic = _StringsFaceTypesClassicEn._(_root);
	late final _StringsFaceTypesLooiEn looi = _StringsFaceTypesLooiEn._(_root);
	late final _StringsFaceTypesMinimalEn minimal = _StringsFaceTypesMinimalEn._(_root);
	late final _StringsFaceTypesBeanEn bean = _StringsFaceTypesBeanEn._(_root);
}

// Path: emotion_names
class _StringsEmotionNamesEn {
	_StringsEmotionNamesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get happy => 'Happy';
	String get surprised => 'Surprised';
	String get sleepy => 'Sleepy';
	String get excited => 'Excited';
	String get confused => 'Confused';
	String get love => 'In love';
	String get angry => 'Angry';
	String get winking => 'Winking';
	String get sad => 'Sad';
	String get scared => 'Scared';
}

// Path: game
class _StringsGameEn {
	_StringsGameEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Feelings Game';
	String get prompt => 'How does Haze feel?';
	String correct({required Object name}) => 'That\'s right — ${name}!';
	List<String> get praise => [
		'Great job!',
		'You got it!',
		'Amazing!',
	];
	String get try_again => 'Hmm, look again...';
	String get score => 'Score';
	String get streak => 'Streak';
	String get play => 'Feelings game';
}

// Path: lab
class _StringsLabEn {
	_StringsLabEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsLabReferencesEn references = _StringsLabReferencesEn._(_root);
	String get title => 'Haze Lab';
	String feeling_now({required Object name}) => 'Current mood: ${name}';
	String get boop_reaction => 'Boop! Dopamine and adrenaline stirred.';
	String get cuddle_reaction => 'Cuddle! Oxytocin and endorphins stirred.';
	String get tell_haze => 'Tell Haze what happened...';
	String get send => 'Send';
	String get chemistry => 'Body chemistry';
	String get emotion_mix => 'Emotion mix';
	String get hint => 'Tap a chemical to give Haze a tiny dose — then watch the face and the bars react. Feelings fade on their own, each at its own speed.';
	String get reset => 'Back to baseline';
	late final _StringsLabChallengeEn challenge = _StringsLabChallengeEn._(_root);
	late final _StringsLabEmotionsEn emotions = _StringsLabEmotionsEn._(_root);
	late final _StringsLabChemicalsEn chemicals = _StringsLabChemicalsEn._(_root);
}

// Path: ui
class _StringsUiEn {
	_StringsUiEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get choose_colors => 'Choose Colors';
	String get choose_face_type => 'Choose Face Type';
	String get settings => 'Settings';
	String get eye_color => 'Eye Color';
	String get mouth_color => 'Mouth Color';
	String get done => 'Done';
	String get speech_enabled => 'Speech Enabled';
	String get speech_description => 'Robot will speak when expressions change';
	String get speech_rate => 'Speech Rate';
	String get speech_pitch => 'Speech Pitch';
	String get language => 'Language';
	String get theme => 'Theme';
	String get dark_theme => 'Dark Theme';
	String get light_theme => 'Light Theme';
	String get never_sleep => 'Never sleep';
	String get never_sleep_description => 'Keep Haze awake while the app is open';
}

// Path: aurea
class _StringsAureaEn {
	_StringsAureaEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Aurea · Haze Lab';
	String get subtitle => 'The meaning behind a feeling';
	String get prototype => 'INTERACTIVE PROTOTYPE';
	String get introduction => 'One moment. Different ways to meet it.';
	String get choose => 'Choose a moment';
	String get interpretation => 'How does Haze read this?';
	String get history => 'Earlier experiences';
	String get firstTime => 'First time here';
	String get practiced => 'With practice';
	String get historyHint => 'An imagined history for this replay. Your companion\'s memory stays separate.';
	String get play => 'Watch the response';
	String get replay => 'Replay this moment';
	String get pause => 'Pause';
	String get resume => 'Continue';
	String get reset => 'Reset experiment';
	List<String> get phases => [
		'Notice',
		'Make sense of it',
		'Choose a response',
	];
	String get why => 'Why this response?';
	String get whyHint => 'Explore the ingredients from Aurea.';
	String get forming => 'Taking shape';
	String get emerging => 'Coming together';
	String get incomplete => 'Something is missing';
	String get ready => 'Press play to watch the feeling develop.';
	String get sameEvent => 'The event stays the same. Meaning and experience change the response.';
	String get practiceEffect => 'Practice gives the response more steadiness; the initial feeling remains.';
	String get firstEffect => 'This is unfamiliar. The response is tentative, and can still take shape.';
	String get modelNote => 'Inspired by Aurea\'s framework. Timing, signal levels and behavior are experimental design choices, not measurements of a person.';
	String get signalNote => 'Bars show simulated ingredient strength, not scientific probabilities.';
	String get source => 'Source: aureasystem.com · snapshot 21 Sep 2026';
	String get chemistry => 'Original chemistry lab';
	String get loadingError => 'The experiment could not load.';
	String get retry => 'Try again';
	String get timeline => 'Response timeline';
	List<String> get layers => [
		'Chemistry',
		'Basic emotion',
		'Appraisal',
		'Value',
		'Compound',
	];
}

// Path: face_types.classic
class _StringsFaceTypesClassicEn {
	_StringsFaceTypesClassicEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Classic';
	String get description => 'Full circular eyes with expressive pupils';
}

// Path: face_types.looi
class _StringsFaceTypesLooiEn {
	_StringsFaceTypesLooiEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'LOOI Style';
	String get description => 'LOOI-inspired eyes with eyebrows';
}

// Path: face_types.minimal
class _StringsFaceTypesMinimalEn {
	_StringsFaceTypesMinimalEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Minimal';
	String get description => 'Simple and clean design';
}

// Path: face_types.bean
class _StringsFaceTypesBeanEn {
	_StringsFaceTypesBeanEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Bean Face';
	String get description => 'Fall Guys inspired vertical bean eyes';
}

// Path: lab.references
class _StringsLabReferencesEn {
	_StringsLabReferencesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Start with a reference';
	List<String> get names => [
		'Content',
		'Excited',
		'Affectionate',
		'Tense',
		'Sad',
	];
	List<String> get descriptions => [
		'Comfortable and positive, with little excitement.',
		'Full of energy and anticipation.',
		'Warm and connected.',
		'Agitated, with anger and anxiety together.',
		'Low and withdrawn.',
	];
	String get model => 'Examples of Haze’s simulated emotions, not recipes for human brain chemistry.';
	String try_change({required Object chemical}) => 'Try increasing ${chemical}. What changes?';
	String get paused => 'Time paused — your changes stay still.';
	String get running => 'Time is running — the mixture evolves.';
	String get resume => 'Resume time';
	String get pause => 'Pause time';
	String get restore => 'Restore starting state';
	String get free => 'Experiment freely';
	String get no_change => 'No measurable change — this control may have reached its limit.';
	String get comparison => 'Starting state → Now';
	String changed({required Object chemical}) => 'Last ${chemical} adjustment (intensity points):';
	String get unchanged => 'Make one change to compare its effect.';
}

// Path: lab.challenge
class _StringsLabChallengeEn {
	_StringsLabChallengeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Chemistry challenge';
	String get explanation => 'Haze will name a feeling. Change the chemicals—or interact with Haze—until the body and face reach it.';
	String get active => 'Challenge in progress';
	String current({required Object name}) => 'Current goal: ${name}';
	String get start => 'Start a challenge';
	String get stop => 'Back to free play';
	String target({required Object name}) => 'Make Haze feel ${name}!';
	String shifted({required Object name}) => 'Haze\'s mood just shifted! Mix the chemicals until it feels ${name}.';
	String solved({required Object name}) => 'You did it — Haze feels ${name}!';
}

// Path: lab.emotions
class _StringsLabEmotionsEn {
	_StringsLabEmotionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get happiness => 'happy';
	String get excitement => 'excited';
	String get anger => 'grumpy';
	String get calm => 'calm';
	String get bonding => 'loved';
	String get anxiety => 'worried';
	String get sadness => 'sad';
	String get euphoria => 'euphoria';
}

// Path: lab.chemicals
class _StringsLabChemicalsEn {
	_StringsLabChemicalsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _StringsLabChemicalsDopamineEn dopamine = _StringsLabChemicalsDopamineEn._(_root);
	late final _StringsLabChemicalsSerotoninEn serotonin = _StringsLabChemicalsSerotoninEn._(_root);
	late final _StringsLabChemicalsOxytocinEn oxytocin = _StringsLabChemicalsOxytocinEn._(_root);
	late final _StringsLabChemicalsTestosteroneEn testosterone = _StringsLabChemicalsTestosteroneEn._(_root);
	late final _StringsLabChemicalsCortisolEn cortisol = _StringsLabChemicalsCortisolEn._(_root);
	late final _StringsLabChemicalsAdrenalineEn adrenaline = _StringsLabChemicalsAdrenalineEn._(_root);
	late final _StringsLabChemicalsEndorphinsEn endorphins = _StringsLabChemicalsEndorphinsEn._(_root);
	late final _StringsLabChemicalsGabaEn gaba = _StringsLabChemicalsGabaEn._(_root);
}

// Path: lab.chemicals.dopamine
class _StringsLabChemicalsDopamineEn {
	_StringsLabChemicalsDopamineEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Dopamine';
	String get tag => 'the reward spark';
}

// Path: lab.chemicals.serotonin
class _StringsLabChemicalsSerotoninEn {
	_StringsLabChemicalsSerotoninEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Serotonin';
	String get tag => 'the sunshine';
}

// Path: lab.chemicals.oxytocin
class _StringsLabChemicalsOxytocinEn {
	_StringsLabChemicalsOxytocinEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Oxytocin';
	String get tag => 'the cuddle chemical';
}

// Path: lab.chemicals.testosterone
class _StringsLabChemicalsTestosteroneEn {
	_StringsLabChemicalsTestosteroneEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Testosterone';
	String get tag => 'the drive';
}

// Path: lab.chemicals.cortisol
class _StringsLabChemicalsCortisolEn {
	_StringsLabChemicalsCortisolEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Cortisol';
	String get tag => 'the stress alarm';
}

// Path: lab.chemicals.adrenaline
class _StringsLabChemicalsAdrenalineEn {
	_StringsLabChemicalsAdrenalineEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Adrenaline';
	String get tag => 'the turbo boost';
}

// Path: lab.chemicals.endorphins
class _StringsLabChemicalsEndorphinsEn {
	_StringsLabChemicalsEndorphinsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'Endorphins';
	String get tag => 'the giggle glow';
}

// Path: lab.chemicals.gaba
class _StringsLabChemicalsGabaEn {
	_StringsLabChemicalsGabaEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'GABA';
	String get tag => 'the calm blanket';
}

// Path: <root>
class _StringsPt extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsPt.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _StringsPt _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsAppPt app = _StringsAppPt._(_root);
	@override late final _StringsExpressionsPt expressions = _StringsExpressionsPt._(_root);
	@override late final _StringsFaceTypesPt face_types = _StringsFaceTypesPt._(_root);
	@override late final _StringsEmotionNamesPt emotion_names = _StringsEmotionNamesPt._(_root);
	@override late final _StringsGamePt game = _StringsGamePt._(_root);
	@override late final _StringsLabPt lab = _StringsLabPt._(_root);
	@override late final _StringsUiPt ui = _StringsUiPt._(_root);
	@override late final _StringsAureaPt aurea = _StringsAureaPt._(_root);
}

// Path: app
class _StringsAppPt extends _StringsAppEn {
	_StringsAppPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'HazeBot Rosto';
}

// Path: expressions
class _StringsExpressionsPt extends _StringsExpressionsEn {
	_StringsExpressionsPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get happy => 'Estou muito feliz!';
	@override String get surprised => 'Nossa! Isso me surpreendeu!';
	@override String get sleepy => 'Estou com sono...';
	@override String get excited => 'Isso é muito emocionante!';
	@override String get confused => 'Hmm, estou confuso...';
	@override String get love => 'Eu te amo!';
	@override String get angry => 'Não estou feliz com isso!';
	@override String get winking => 'Piscadinha!';
	@override String get sad => 'Estou um pouco triste...';
	@override String get scared => 'Ai! Que medo!';
}

// Path: face_types
class _StringsFaceTypesPt extends _StringsFaceTypesEn {
	_StringsFaceTypesPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override late final _StringsFaceTypesClassicPt classic = _StringsFaceTypesClassicPt._(_root);
	@override late final _StringsFaceTypesLooiPt looi = _StringsFaceTypesLooiPt._(_root);
	@override late final _StringsFaceTypesMinimalPt minimal = _StringsFaceTypesMinimalPt._(_root);
	@override late final _StringsFaceTypesBeanPt bean = _StringsFaceTypesBeanPt._(_root);
}

// Path: emotion_names
class _StringsEmotionNamesPt extends _StringsEmotionNamesEn {
	_StringsEmotionNamesPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get happy => 'Feliz';
	@override String get surprised => 'Surpreso';
	@override String get sleepy => 'Sonolento';
	@override String get excited => 'Animado';
	@override String get confused => 'Confuso';
	@override String get love => 'Apaixonado';
	@override String get angry => 'Bravo';
	@override String get winking => 'Piscando';
	@override String get sad => 'Triste';
	@override String get scared => 'Assustado';
}

// Path: game
class _StringsGamePt extends _StringsGameEn {
	_StringsGamePt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jogo dos Sentimentos';
	@override String get prompt => 'Como o Haze está se sentindo?';
	@override String correct({required Object name}) => 'Isso mesmo — ${name}!';
	@override List<String> get praise => [
		'Muito bem!',
		'Você acertou!',
		'Incrível!',
	];
	@override String get try_again => 'Hmm, olhe de novo...';
	@override String get score => 'Pontos';
	@override String get streak => 'Sequência';
	@override String get play => 'Jogo dos sentimentos';
}

// Path: lab
class _StringsLabPt extends _StringsLabEn {
	_StringsLabPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override late final _StringsLabReferencesPt references = _StringsLabReferencesPt._(_root);
	@override String get title => 'Laboratório do Haze';
	@override String feeling_now({required Object name}) => 'Humor atual: ${name}';
	@override String get boop_reaction => 'Boop! A dopamina e a adrenalina se agitaram.';
	@override String get cuddle_reaction => 'Abraço! A ocitocina e as endorfinas se agitaram.';
	@override String get tell_haze => 'Conte ao Haze o que aconteceu...';
	@override String get send => 'Enviar';
	@override String get chemistry => 'Química do corpo';
	@override String get emotion_mix => 'Mistura de emoções';
	@override String get hint => 'Toque em uma substância para dar uma dosezinha ao Haze — e veja o rosto e as barras reagirem. Os sentimentos passam sozinhos, cada um na sua velocidade.';
	@override String get reset => 'Voltar ao normal';
	@override late final _StringsLabChallengePt challenge = _StringsLabChallengePt._(_root);
	@override late final _StringsLabEmotionsPt emotions = _StringsLabEmotionsPt._(_root);
	@override late final _StringsLabChemicalsPt chemicals = _StringsLabChemicalsPt._(_root);
}

// Path: ui
class _StringsUiPt extends _StringsUiEn {
	_StringsUiPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get choose_colors => 'Escolher Cores';
	@override String get choose_face_type => 'Escolher Tipo de Rosto';
	@override String get settings => 'Configurações';
	@override String get eye_color => 'Cor dos Olhos';
	@override String get mouth_color => 'Cor da Boca';
	@override String get done => 'Pronto';
	@override String get speech_enabled => 'Fala Ativada';
	@override String get speech_description => 'O robô falará quando as expressões mudarem';
	@override String get speech_rate => 'Velocidade da Fala';
	@override String get speech_pitch => 'Tom da Fala';
	@override String get language => 'Idioma';
	@override String get theme => 'Tema';
	@override String get dark_theme => 'Tema Escuro';
	@override String get light_theme => 'Tema Claro';
	@override String get never_sleep => 'Nunca dormir';
	@override String get never_sleep_description => 'Manter o Haze acordado enquanto o app estiver aberto';
}

// Path: aurea
class _StringsAureaPt extends _StringsAureaEn {
	_StringsAureaPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aurea · Haze Lab';
	@override String get subtitle => 'O sentido por trás de um sentimento';
	@override String get prototype => 'PROTÓTIPO INTERATIVO';
	@override String get introduction => 'Um momento. Diferentes formas de vivê-lo.';
	@override String get choose => 'Escolha um momento';
	@override String get interpretation => 'Como Haze interpreta isso?';
	@override String get history => 'Experiências anteriores';
	@override String get firstTime => 'Primeira vez';
	@override String get practiced => 'Com prática';
	@override String get historyHint => 'Um passado imaginado para esta cena. A memória do seu companheiro fica separada.';
	@override String get play => 'Ver a reação';
	@override String get replay => 'Rever este momento';
	@override String get pause => 'Pausar';
	@override String get resume => 'Continuar';
	@override String get reset => 'Reiniciar experimento';
	@override List<String> get phases => [
		'Perceber',
		'Entender o momento',
		'Escolher uma resposta',
	];
	@override String get why => 'Por que essa reação?';
	@override String get whyHint => 'Explore os ingredientes da Aurea.';
	@override String get forming => 'Ganhando forma';
	@override String get emerging => 'Se formando';
	@override String get incomplete => 'Algo está faltando';
	@override String get ready => 'Dê o play para ver o sentimento se desenvolver.';
	@override String get sameEvent => 'O acontecimento é o mesmo. O sentido e a experiência mudam a reação.';
	@override String get practiceEffect => 'A prática traz mais firmeza à resposta; o sentimento inicial permanece.';
	@override String get firstEffect => 'Isso é novo para Haze. A resposta é hesitante e ainda pode ganhar forma.';
	@override String get modelNote => 'Inspirado no modelo da Aurea. Tempos, níveis e comportamentos são escolhas experimentais, não medidas sobre uma pessoa.';
	@override String get signalNote => 'As barras mostram a força simulada dos ingredientes, não probabilidades científicas.';
	@override String get source => 'Fonte: aureasystem.com · versão de 21 set 2026';
	@override String get chemistry => 'Laboratório de química original';
	@override String get loadingError => 'Não foi possível carregar o experimento.';
	@override String get retry => 'Tentar novamente';
	@override String get timeline => 'Linha do tempo da resposta';
	@override List<String> get layers => [
		'Química',
		'Emoção básica',
		'Interpretação',
		'Valor',
		'Composto',
	];
}

// Path: face_types.classic
class _StringsFaceTypesClassicPt extends _StringsFaceTypesClassicEn {
	_StringsFaceTypesClassicPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Clássico';
	@override String get description => 'Olhos circulares completos com pupilas expressivas';
}

// Path: face_types.looi
class _StringsFaceTypesLooiPt extends _StringsFaceTypesLooiEn {
	_StringsFaceTypesLooiPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Estilo LOOI';
	@override String get description => 'Olhos inspirados no LOOI com sobrancelhas';
}

// Path: face_types.minimal
class _StringsFaceTypesMinimalPt extends _StringsFaceTypesMinimalEn {
	_StringsFaceTypesMinimalPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Minimalista';
	@override String get description => 'Design simples e limpo';
}

// Path: face_types.bean
class _StringsFaceTypesBeanPt extends _StringsFaceTypesBeanEn {
	_StringsFaceTypesBeanPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Rosto Feijão';
	@override String get description => 'Olhos verticais inspirados no Fall Guys';
}

// Path: lab.references
class _StringsLabReferencesPt extends _StringsLabReferencesEn {
	_StringsLabReferencesPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Comece com uma referência';
	@override List<String> get names => [
		'Contente',
		'Animado',
		'Carinhoso',
		'Tenso',
		'Triste',
	];
	@override List<String> get descriptions => [
		'Confortável e positivo, com pouca agitação.',
		'Cheio de energia e expectativa.',
		'Acolhedor e conectado.',
		'Agitado, com raiva e ansiedade juntas.',
		'Desanimado e retraído.',
	];
	@override String get model => 'Exemplos das emoções simuladas do Haze, não receitas da química cerebral humana.';
	@override String try_change({required Object chemical}) => 'Experimente aumentar ${chemical}. O que muda?';
	@override String get paused => 'Tempo pausado — suas mudanças ficam estáveis.';
	@override String get running => 'O tempo está passando — a mistura evolui.';
	@override String get resume => 'Retomar tempo';
	@override String get pause => 'Pausar tempo';
	@override String get restore => 'Restaurar estado inicial';
	@override String get free => 'Experimentar livremente';
	@override String get no_change => 'Nenhuma mudança mensurável — este controle pode ter atingido o limite.';
	@override String get comparison => 'Estado inicial → Agora';
	@override String changed({required Object chemical}) => 'Último ajuste de ${chemical} (pontos de intensidade):';
	@override String get unchanged => 'Faça uma mudança para comparar o efeito.';
}

// Path: lab.challenge
class _StringsLabChallengePt extends _StringsLabChallengeEn {
	_StringsLabChallengePt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Desafio de química';
	@override String get explanation => 'O Haze vai escolher um sentimento. Mude as substâncias — ou interaja com ele — até o corpo e o rosto chegarem lá.';
	@override String get active => 'Desafio em andamento';
	@override String current({required Object name}) => 'Objetivo atual: ${name}';
	@override String get start => 'Começar um desafio';
	@override String get stop => 'Voltar ao modo livre';
	@override String target({required Object name}) => 'Faça o Haze se sentir ${name}!';
	@override String shifted({required Object name}) => 'O humor do Haze mudou! Misture as substâncias até ele se sentir ${name}.';
	@override String solved({required Object name}) => 'Você conseguiu — o Haze está se sentindo ${name}!';
}

// Path: lab.emotions
class _StringsLabEmotionsPt extends _StringsLabEmotionsEn {
	_StringsLabEmotionsPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get happiness => 'feliz';
	@override String get excitement => 'animado';
	@override String get anger => 'bravinho';
	@override String get calm => 'calmo';
	@override String get bonding => 'amado';
	@override String get anxiety => 'preocupado';
	@override String get sadness => 'triste';
	@override String get euphoria => 'euforia';
}

// Path: lab.chemicals
class _StringsLabChemicalsPt extends _StringsLabChemicalsEn {
	_StringsLabChemicalsPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override late final _StringsLabChemicalsDopaminePt dopamine = _StringsLabChemicalsDopaminePt._(_root);
	@override late final _StringsLabChemicalsSerotoninPt serotonin = _StringsLabChemicalsSerotoninPt._(_root);
	@override late final _StringsLabChemicalsOxytocinPt oxytocin = _StringsLabChemicalsOxytocinPt._(_root);
	@override late final _StringsLabChemicalsTestosteronePt testosterone = _StringsLabChemicalsTestosteronePt._(_root);
	@override late final _StringsLabChemicalsCortisolPt cortisol = _StringsLabChemicalsCortisolPt._(_root);
	@override late final _StringsLabChemicalsAdrenalinePt adrenaline = _StringsLabChemicalsAdrenalinePt._(_root);
	@override late final _StringsLabChemicalsEndorphinsPt endorphins = _StringsLabChemicalsEndorphinsPt._(_root);
	@override late final _StringsLabChemicalsGabaPt gaba = _StringsLabChemicalsGabaPt._(_root);
}

// Path: lab.chemicals.dopamine
class _StringsLabChemicalsDopaminePt extends _StringsLabChemicalsDopamineEn {
	_StringsLabChemicalsDopaminePt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Dopamina';
	@override String get tag => 'a faísca da recompensa';
}

// Path: lab.chemicals.serotonin
class _StringsLabChemicalsSerotoninPt extends _StringsLabChemicalsSerotoninEn {
	_StringsLabChemicalsSerotoninPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Serotonina';
	@override String get tag => 'o solzinho';
}

// Path: lab.chemicals.oxytocin
class _StringsLabChemicalsOxytocinPt extends _StringsLabChemicalsOxytocinEn {
	_StringsLabChemicalsOxytocinPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Ocitocina';
	@override String get tag => 'a química do abraço';
}

// Path: lab.chemicals.testosterone
class _StringsLabChemicalsTestosteronePt extends _StringsLabChemicalsTestosteroneEn {
	_StringsLabChemicalsTestosteronePt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Testosterona';
	@override String get tag => 'a garra';
}

// Path: lab.chemicals.cortisol
class _StringsLabChemicalsCortisolPt extends _StringsLabChemicalsCortisolEn {
	_StringsLabChemicalsCortisolPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Cortisol';
	@override String get tag => 'o alarme do estresse';
}

// Path: lab.chemicals.adrenaline
class _StringsLabChemicalsAdrenalinePt extends _StringsLabChemicalsAdrenalineEn {
	_StringsLabChemicalsAdrenalinePt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Adrenalina';
	@override String get tag => 'o turbo';
}

// Path: lab.chemicals.endorphins
class _StringsLabChemicalsEndorphinsPt extends _StringsLabChemicalsEndorphinsEn {
	_StringsLabChemicalsEndorphinsPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Endorfinas';
	@override String get tag => 'o brilho da risada';
}

// Path: lab.chemicals.gaba
class _StringsLabChemicalsGabaPt extends _StringsLabChemicalsGabaEn {
	_StringsLabChemicalsGabaPt._(_StringsPt root) : this._root = root, super._(root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'GABA';
	@override String get tag => 'o cobertor da calma';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'HazeBot Face';
			case 'expressions.happy': return 'I am so happy!';
			case 'expressions.surprised': return 'Oh wow! That surprised me!';
			case 'expressions.sleepy': return 'I am feeling sleepy...';
			case 'expressions.excited': return 'This is so exciting!';
			case 'expressions.confused': return 'Hmm, I am confused...';
			case 'expressions.love': return 'I love you!';
			case 'expressions.angry': return 'I am not happy about this!';
			case 'expressions.winking': return 'Wink wink!';
			case 'expressions.sad': return 'I feel a little sad...';
			case 'expressions.scared': return 'Eek! That is scary!';
			case 'face_types.classic.name': return 'Classic';
			case 'face_types.classic.description': return 'Full circular eyes with expressive pupils';
			case 'face_types.looi.name': return 'LOOI Style';
			case 'face_types.looi.description': return 'LOOI-inspired eyes with eyebrows';
			case 'face_types.minimal.name': return 'Minimal';
			case 'face_types.minimal.description': return 'Simple and clean design';
			case 'face_types.bean.name': return 'Bean Face';
			case 'face_types.bean.description': return 'Fall Guys inspired vertical bean eyes';
			case 'emotion_names.happy': return 'Happy';
			case 'emotion_names.surprised': return 'Surprised';
			case 'emotion_names.sleepy': return 'Sleepy';
			case 'emotion_names.excited': return 'Excited';
			case 'emotion_names.confused': return 'Confused';
			case 'emotion_names.love': return 'In love';
			case 'emotion_names.angry': return 'Angry';
			case 'emotion_names.winking': return 'Winking';
			case 'emotion_names.sad': return 'Sad';
			case 'emotion_names.scared': return 'Scared';
			case 'game.title': return 'Feelings Game';
			case 'game.prompt': return 'How does Haze feel?';
			case 'game.correct': return ({required Object name}) => 'That\'s right — ${name}!';
			case 'game.praise.0': return 'Great job!';
			case 'game.praise.1': return 'You got it!';
			case 'game.praise.2': return 'Amazing!';
			case 'game.try_again': return 'Hmm, look again...';
			case 'game.score': return 'Score';
			case 'game.streak': return 'Streak';
			case 'game.play': return 'Feelings game';
			case 'lab.references.title': return 'Start with a reference';
			case 'lab.references.names.0': return 'Content';
			case 'lab.references.names.1': return 'Excited';
			case 'lab.references.names.2': return 'Affectionate';
			case 'lab.references.names.3': return 'Tense';
			case 'lab.references.names.4': return 'Sad';
			case 'lab.references.descriptions.0': return 'Comfortable and positive, with little excitement.';
			case 'lab.references.descriptions.1': return 'Full of energy and anticipation.';
			case 'lab.references.descriptions.2': return 'Warm and connected.';
			case 'lab.references.descriptions.3': return 'Agitated, with anger and anxiety together.';
			case 'lab.references.descriptions.4': return 'Low and withdrawn.';
			case 'lab.references.model': return 'Examples of Haze’s simulated emotions, not recipes for human brain chemistry.';
			case 'lab.references.try_change': return ({required Object chemical}) => 'Try increasing ${chemical}. What changes?';
			case 'lab.references.paused': return 'Time paused — your changes stay still.';
			case 'lab.references.running': return 'Time is running — the mixture evolves.';
			case 'lab.references.resume': return 'Resume time';
			case 'lab.references.pause': return 'Pause time';
			case 'lab.references.restore': return 'Restore starting state';
			case 'lab.references.free': return 'Experiment freely';
			case 'lab.references.no_change': return 'No measurable change — this control may have reached its limit.';
			case 'lab.references.comparison': return 'Starting state → Now';
			case 'lab.references.changed': return ({required Object chemical}) => 'Last ${chemical} adjustment (intensity points):';
			case 'lab.references.unchanged': return 'Make one change to compare its effect.';
			case 'lab.title': return 'Haze Lab';
			case 'lab.feeling_now': return ({required Object name}) => 'Current mood: ${name}';
			case 'lab.boop_reaction': return 'Boop! Dopamine and adrenaline stirred.';
			case 'lab.cuddle_reaction': return 'Cuddle! Oxytocin and endorphins stirred.';
			case 'lab.tell_haze': return 'Tell Haze what happened...';
			case 'lab.send': return 'Send';
			case 'lab.chemistry': return 'Body chemistry';
			case 'lab.emotion_mix': return 'Emotion mix';
			case 'lab.hint': return 'Tap a chemical to give Haze a tiny dose — then watch the face and the bars react. Feelings fade on their own, each at its own speed.';
			case 'lab.reset': return 'Back to baseline';
			case 'lab.challenge.title': return 'Chemistry challenge';
			case 'lab.challenge.explanation': return 'Haze will name a feeling. Change the chemicals—or interact with Haze—until the body and face reach it.';
			case 'lab.challenge.active': return 'Challenge in progress';
			case 'lab.challenge.current': return ({required Object name}) => 'Current goal: ${name}';
			case 'lab.challenge.start': return 'Start a challenge';
			case 'lab.challenge.stop': return 'Back to free play';
			case 'lab.challenge.target': return ({required Object name}) => 'Make Haze feel ${name}!';
			case 'lab.challenge.shifted': return ({required Object name}) => 'Haze\'s mood just shifted! Mix the chemicals until it feels ${name}.';
			case 'lab.challenge.solved': return ({required Object name}) => 'You did it — Haze feels ${name}!';
			case 'lab.emotions.happiness': return 'happy';
			case 'lab.emotions.excitement': return 'excited';
			case 'lab.emotions.anger': return 'grumpy';
			case 'lab.emotions.calm': return 'calm';
			case 'lab.emotions.bonding': return 'loved';
			case 'lab.emotions.anxiety': return 'worried';
			case 'lab.emotions.sadness': return 'sad';
			case 'lab.emotions.euphoria': return 'euphoria';
			case 'lab.chemicals.dopamine.name': return 'Dopamine';
			case 'lab.chemicals.dopamine.tag': return 'the reward spark';
			case 'lab.chemicals.serotonin.name': return 'Serotonin';
			case 'lab.chemicals.serotonin.tag': return 'the sunshine';
			case 'lab.chemicals.oxytocin.name': return 'Oxytocin';
			case 'lab.chemicals.oxytocin.tag': return 'the cuddle chemical';
			case 'lab.chemicals.testosterone.name': return 'Testosterone';
			case 'lab.chemicals.testosterone.tag': return 'the drive';
			case 'lab.chemicals.cortisol.name': return 'Cortisol';
			case 'lab.chemicals.cortisol.tag': return 'the stress alarm';
			case 'lab.chemicals.adrenaline.name': return 'Adrenaline';
			case 'lab.chemicals.adrenaline.tag': return 'the turbo boost';
			case 'lab.chemicals.endorphins.name': return 'Endorphins';
			case 'lab.chemicals.endorphins.tag': return 'the giggle glow';
			case 'lab.chemicals.gaba.name': return 'GABA';
			case 'lab.chemicals.gaba.tag': return 'the calm blanket';
			case 'ui.choose_colors': return 'Choose Colors';
			case 'ui.choose_face_type': return 'Choose Face Type';
			case 'ui.settings': return 'Settings';
			case 'ui.eye_color': return 'Eye Color';
			case 'ui.mouth_color': return 'Mouth Color';
			case 'ui.done': return 'Done';
			case 'ui.speech_enabled': return 'Speech Enabled';
			case 'ui.speech_description': return 'Robot will speak when expressions change';
			case 'ui.speech_rate': return 'Speech Rate';
			case 'ui.speech_pitch': return 'Speech Pitch';
			case 'ui.language': return 'Language';
			case 'ui.theme': return 'Theme';
			case 'ui.dark_theme': return 'Dark Theme';
			case 'ui.light_theme': return 'Light Theme';
			case 'ui.never_sleep': return 'Never sleep';
			case 'ui.never_sleep_description': return 'Keep Haze awake while the app is open';
			case 'aurea.title': return 'Aurea · Haze Lab';
			case 'aurea.subtitle': return 'The meaning behind a feeling';
			case 'aurea.prototype': return 'INTERACTIVE PROTOTYPE';
			case 'aurea.introduction': return 'One moment. Different ways to meet it.';
			case 'aurea.choose': return 'Choose a moment';
			case 'aurea.interpretation': return 'How does Haze read this?';
			case 'aurea.history': return 'Earlier experiences';
			case 'aurea.firstTime': return 'First time here';
			case 'aurea.practiced': return 'With practice';
			case 'aurea.historyHint': return 'An imagined history for this replay. Your companion\'s memory stays separate.';
			case 'aurea.play': return 'Watch the response';
			case 'aurea.replay': return 'Replay this moment';
			case 'aurea.pause': return 'Pause';
			case 'aurea.resume': return 'Continue';
			case 'aurea.reset': return 'Reset experiment';
			case 'aurea.phases.0': return 'Notice';
			case 'aurea.phases.1': return 'Make sense of it';
			case 'aurea.phases.2': return 'Choose a response';
			case 'aurea.why': return 'Why this response?';
			case 'aurea.whyHint': return 'Explore the ingredients from Aurea.';
			case 'aurea.forming': return 'Taking shape';
			case 'aurea.emerging': return 'Coming together';
			case 'aurea.incomplete': return 'Something is missing';
			case 'aurea.ready': return 'Press play to watch the feeling develop.';
			case 'aurea.sameEvent': return 'The event stays the same. Meaning and experience change the response.';
			case 'aurea.practiceEffect': return 'Practice gives the response more steadiness; the initial feeling remains.';
			case 'aurea.firstEffect': return 'This is unfamiliar. The response is tentative, and can still take shape.';
			case 'aurea.modelNote': return 'Inspired by Aurea\'s framework. Timing, signal levels and behavior are experimental design choices, not measurements of a person.';
			case 'aurea.signalNote': return 'Bars show simulated ingredient strength, not scientific probabilities.';
			case 'aurea.source': return 'Source: aureasystem.com · snapshot 21 Sep 2026';
			case 'aurea.chemistry': return 'Original chemistry lab';
			case 'aurea.loadingError': return 'The experiment could not load.';
			case 'aurea.retry': return 'Try again';
			case 'aurea.timeline': return 'Response timeline';
			case 'aurea.layers.0': return 'Chemistry';
			case 'aurea.layers.1': return 'Basic emotion';
			case 'aurea.layers.2': return 'Appraisal';
			case 'aurea.layers.3': return 'Value';
			case 'aurea.layers.4': return 'Compound';
			default: return null;
		}
	}
}

extension on _StringsPt {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'HazeBot Rosto';
			case 'expressions.happy': return 'Estou muito feliz!';
			case 'expressions.surprised': return 'Nossa! Isso me surpreendeu!';
			case 'expressions.sleepy': return 'Estou com sono...';
			case 'expressions.excited': return 'Isso é muito emocionante!';
			case 'expressions.confused': return 'Hmm, estou confuso...';
			case 'expressions.love': return 'Eu te amo!';
			case 'expressions.angry': return 'Não estou feliz com isso!';
			case 'expressions.winking': return 'Piscadinha!';
			case 'expressions.sad': return 'Estou um pouco triste...';
			case 'expressions.scared': return 'Ai! Que medo!';
			case 'face_types.classic.name': return 'Clássico';
			case 'face_types.classic.description': return 'Olhos circulares completos com pupilas expressivas';
			case 'face_types.looi.name': return 'Estilo LOOI';
			case 'face_types.looi.description': return 'Olhos inspirados no LOOI com sobrancelhas';
			case 'face_types.minimal.name': return 'Minimalista';
			case 'face_types.minimal.description': return 'Design simples e limpo';
			case 'face_types.bean.name': return 'Rosto Feijão';
			case 'face_types.bean.description': return 'Olhos verticais inspirados no Fall Guys';
			case 'emotion_names.happy': return 'Feliz';
			case 'emotion_names.surprised': return 'Surpreso';
			case 'emotion_names.sleepy': return 'Sonolento';
			case 'emotion_names.excited': return 'Animado';
			case 'emotion_names.confused': return 'Confuso';
			case 'emotion_names.love': return 'Apaixonado';
			case 'emotion_names.angry': return 'Bravo';
			case 'emotion_names.winking': return 'Piscando';
			case 'emotion_names.sad': return 'Triste';
			case 'emotion_names.scared': return 'Assustado';
			case 'game.title': return 'Jogo dos Sentimentos';
			case 'game.prompt': return 'Como o Haze está se sentindo?';
			case 'game.correct': return ({required Object name}) => 'Isso mesmo — ${name}!';
			case 'game.praise.0': return 'Muito bem!';
			case 'game.praise.1': return 'Você acertou!';
			case 'game.praise.2': return 'Incrível!';
			case 'game.try_again': return 'Hmm, olhe de novo...';
			case 'game.score': return 'Pontos';
			case 'game.streak': return 'Sequência';
			case 'game.play': return 'Jogo dos sentimentos';
			case 'lab.references.title': return 'Comece com uma referência';
			case 'lab.references.names.0': return 'Contente';
			case 'lab.references.names.1': return 'Animado';
			case 'lab.references.names.2': return 'Carinhoso';
			case 'lab.references.names.3': return 'Tenso';
			case 'lab.references.names.4': return 'Triste';
			case 'lab.references.descriptions.0': return 'Confortável e positivo, com pouca agitação.';
			case 'lab.references.descriptions.1': return 'Cheio de energia e expectativa.';
			case 'lab.references.descriptions.2': return 'Acolhedor e conectado.';
			case 'lab.references.descriptions.3': return 'Agitado, com raiva e ansiedade juntas.';
			case 'lab.references.descriptions.4': return 'Desanimado e retraído.';
			case 'lab.references.model': return 'Exemplos das emoções simuladas do Haze, não receitas da química cerebral humana.';
			case 'lab.references.try_change': return ({required Object chemical}) => 'Experimente aumentar ${chemical}. O que muda?';
			case 'lab.references.paused': return 'Tempo pausado — suas mudanças ficam estáveis.';
			case 'lab.references.running': return 'O tempo está passando — a mistura evolui.';
			case 'lab.references.resume': return 'Retomar tempo';
			case 'lab.references.pause': return 'Pausar tempo';
			case 'lab.references.restore': return 'Restaurar estado inicial';
			case 'lab.references.free': return 'Experimentar livremente';
			case 'lab.references.no_change': return 'Nenhuma mudança mensurável — este controle pode ter atingido o limite.';
			case 'lab.references.comparison': return 'Estado inicial → Agora';
			case 'lab.references.changed': return ({required Object chemical}) => 'Último ajuste de ${chemical} (pontos de intensidade):';
			case 'lab.references.unchanged': return 'Faça uma mudança para comparar o efeito.';
			case 'lab.title': return 'Laboratório do Haze';
			case 'lab.feeling_now': return ({required Object name}) => 'Humor atual: ${name}';
			case 'lab.boop_reaction': return 'Boop! A dopamina e a adrenalina se agitaram.';
			case 'lab.cuddle_reaction': return 'Abraço! A ocitocina e as endorfinas se agitaram.';
			case 'lab.tell_haze': return 'Conte ao Haze o que aconteceu...';
			case 'lab.send': return 'Enviar';
			case 'lab.chemistry': return 'Química do corpo';
			case 'lab.emotion_mix': return 'Mistura de emoções';
			case 'lab.hint': return 'Toque em uma substância para dar uma dosezinha ao Haze — e veja o rosto e as barras reagirem. Os sentimentos passam sozinhos, cada um na sua velocidade.';
			case 'lab.reset': return 'Voltar ao normal';
			case 'lab.challenge.title': return 'Desafio de química';
			case 'lab.challenge.explanation': return 'O Haze vai escolher um sentimento. Mude as substâncias — ou interaja com ele — até o corpo e o rosto chegarem lá.';
			case 'lab.challenge.active': return 'Desafio em andamento';
			case 'lab.challenge.current': return ({required Object name}) => 'Objetivo atual: ${name}';
			case 'lab.challenge.start': return 'Começar um desafio';
			case 'lab.challenge.stop': return 'Voltar ao modo livre';
			case 'lab.challenge.target': return ({required Object name}) => 'Faça o Haze se sentir ${name}!';
			case 'lab.challenge.shifted': return ({required Object name}) => 'O humor do Haze mudou! Misture as substâncias até ele se sentir ${name}.';
			case 'lab.challenge.solved': return ({required Object name}) => 'Você conseguiu — o Haze está se sentindo ${name}!';
			case 'lab.emotions.happiness': return 'feliz';
			case 'lab.emotions.excitement': return 'animado';
			case 'lab.emotions.anger': return 'bravinho';
			case 'lab.emotions.calm': return 'calmo';
			case 'lab.emotions.bonding': return 'amado';
			case 'lab.emotions.anxiety': return 'preocupado';
			case 'lab.emotions.sadness': return 'triste';
			case 'lab.emotions.euphoria': return 'euforia';
			case 'lab.chemicals.dopamine.name': return 'Dopamina';
			case 'lab.chemicals.dopamine.tag': return 'a faísca da recompensa';
			case 'lab.chemicals.serotonin.name': return 'Serotonina';
			case 'lab.chemicals.serotonin.tag': return 'o solzinho';
			case 'lab.chemicals.oxytocin.name': return 'Ocitocina';
			case 'lab.chemicals.oxytocin.tag': return 'a química do abraço';
			case 'lab.chemicals.testosterone.name': return 'Testosterona';
			case 'lab.chemicals.testosterone.tag': return 'a garra';
			case 'lab.chemicals.cortisol.name': return 'Cortisol';
			case 'lab.chemicals.cortisol.tag': return 'o alarme do estresse';
			case 'lab.chemicals.adrenaline.name': return 'Adrenalina';
			case 'lab.chemicals.adrenaline.tag': return 'o turbo';
			case 'lab.chemicals.endorphins.name': return 'Endorfinas';
			case 'lab.chemicals.endorphins.tag': return 'o brilho da risada';
			case 'lab.chemicals.gaba.name': return 'GABA';
			case 'lab.chemicals.gaba.tag': return 'o cobertor da calma';
			case 'ui.choose_colors': return 'Escolher Cores';
			case 'ui.choose_face_type': return 'Escolher Tipo de Rosto';
			case 'ui.settings': return 'Configurações';
			case 'ui.eye_color': return 'Cor dos Olhos';
			case 'ui.mouth_color': return 'Cor da Boca';
			case 'ui.done': return 'Pronto';
			case 'ui.speech_enabled': return 'Fala Ativada';
			case 'ui.speech_description': return 'O robô falará quando as expressões mudarem';
			case 'ui.speech_rate': return 'Velocidade da Fala';
			case 'ui.speech_pitch': return 'Tom da Fala';
			case 'ui.language': return 'Idioma';
			case 'ui.theme': return 'Tema';
			case 'ui.dark_theme': return 'Tema Escuro';
			case 'ui.light_theme': return 'Tema Claro';
			case 'ui.never_sleep': return 'Nunca dormir';
			case 'ui.never_sleep_description': return 'Manter o Haze acordado enquanto o app estiver aberto';
			case 'aurea.title': return 'Aurea · Haze Lab';
			case 'aurea.subtitle': return 'O sentido por trás de um sentimento';
			case 'aurea.prototype': return 'PROTÓTIPO INTERATIVO';
			case 'aurea.introduction': return 'Um momento. Diferentes formas de vivê-lo.';
			case 'aurea.choose': return 'Escolha um momento';
			case 'aurea.interpretation': return 'Como Haze interpreta isso?';
			case 'aurea.history': return 'Experiências anteriores';
			case 'aurea.firstTime': return 'Primeira vez';
			case 'aurea.practiced': return 'Com prática';
			case 'aurea.historyHint': return 'Um passado imaginado para esta cena. A memória do seu companheiro fica separada.';
			case 'aurea.play': return 'Ver a reação';
			case 'aurea.replay': return 'Rever este momento';
			case 'aurea.pause': return 'Pausar';
			case 'aurea.resume': return 'Continuar';
			case 'aurea.reset': return 'Reiniciar experimento';
			case 'aurea.phases.0': return 'Perceber';
			case 'aurea.phases.1': return 'Entender o momento';
			case 'aurea.phases.2': return 'Escolher uma resposta';
			case 'aurea.why': return 'Por que essa reação?';
			case 'aurea.whyHint': return 'Explore os ingredientes da Aurea.';
			case 'aurea.forming': return 'Ganhando forma';
			case 'aurea.emerging': return 'Se formando';
			case 'aurea.incomplete': return 'Algo está faltando';
			case 'aurea.ready': return 'Dê o play para ver o sentimento se desenvolver.';
			case 'aurea.sameEvent': return 'O acontecimento é o mesmo. O sentido e a experiência mudam a reação.';
			case 'aurea.practiceEffect': return 'A prática traz mais firmeza à resposta; o sentimento inicial permanece.';
			case 'aurea.firstEffect': return 'Isso é novo para Haze. A resposta é hesitante e ainda pode ganhar forma.';
			case 'aurea.modelNote': return 'Inspirado no modelo da Aurea. Tempos, níveis e comportamentos são escolhas experimentais, não medidas sobre uma pessoa.';
			case 'aurea.signalNote': return 'As barras mostram a força simulada dos ingredientes, não probabilidades científicas.';
			case 'aurea.source': return 'Fonte: aureasystem.com · versão de 21 set 2026';
			case 'aurea.chemistry': return 'Laboratório de química original';
			case 'aurea.loadingError': return 'Não foi possível carregar o experimento.';
			case 'aurea.retry': return 'Tentar novamente';
			case 'aurea.timeline': return 'Linha do tempo da resposta';
			case 'aurea.layers.0': return 'Química';
			case 'aurea.layers.1': return 'Emoção básica';
			case 'aurea.layers.2': return 'Interpretação';
			case 'aurea.layers.3': return 'Valor';
			case 'aurea.layers.4': return 'Composto';
			default: return null;
		}
	}
}
