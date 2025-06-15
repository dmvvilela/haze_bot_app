/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 62 (31 per locale)
///
/// Built on 2025-06-15 at 05:35 UTC

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
	late final _StringsUiEn ui = _StringsUiEn._(_root);
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
	@override late final _StringsUiPt ui = _StringsUiPt._(_root);
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
			case 'face_types.classic.name': return 'Classic';
			case 'face_types.classic.description': return 'Full circular eyes with expressive pupils';
			case 'face_types.looi.name': return 'LOOI Style';
			case 'face_types.looi.description': return 'LOOI-inspired eyes with eyebrows';
			case 'face_types.minimal.name': return 'Minimal';
			case 'face_types.minimal.description': return 'Simple and clean design';
			case 'face_types.bean.name': return 'Bean Face';
			case 'face_types.bean.description': return 'Fall Guys inspired vertical bean eyes';
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
			case 'face_types.classic.name': return 'Clássico';
			case 'face_types.classic.description': return 'Olhos circulares completos com pupilas expressivas';
			case 'face_types.looi.name': return 'Estilo LOOI';
			case 'face_types.looi.description': return 'Olhos inspirados no LOOI com sobrancelhas';
			case 'face_types.minimal.name': return 'Minimalista';
			case 'face_types.minimal.description': return 'Design simples e limpo';
			case 'face_types.bean.name': return 'Rosto Feijão';
			case 'face_types.bean.description': return 'Olhos verticais inspirados no Fall Guys';
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
			default: return null;
		}
	}
}
