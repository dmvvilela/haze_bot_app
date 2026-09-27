///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$app$en app = Translations$app$en.internal(_root);
	late final Translations$expressions$en expressions = Translations$expressions$en.internal(_root);
	late final Translations$emotion_names$en emotion_names = Translations$emotion_names$en.internal(_root);
	late final Translations$game$en game = Translations$game$en.internal(_root);
	late final Translations$lab$en lab = Translations$lab$en.internal(_root);
	late final Translations$ui$en ui = Translations$ui$en.internal(_root);
	late final Translations$aurea$en aurea = Translations$aurea$en.internal(_root);
	late final Translations$home$en home = Translations$home$en.internal(_root);
}

// Path: app
class Translations$app$en {
	Translations$app$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'HazeBot Face'
	String get title => 'HazeBot Face';
}

// Path: expressions
class Translations$expressions$en {
	Translations$expressions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'I am so happy!'
	String get happy => 'I am so happy!';

	/// en: 'Oh wow! That surprised me!'
	String get surprised => 'Oh wow! That surprised me!';

	/// en: 'I am feeling sleepy...'
	String get sleepy => 'I am feeling sleepy...';

	/// en: 'This is so exciting!'
	String get excited => 'This is so exciting!';

	/// en: 'Hmm, I am confused...'
	String get confused => 'Hmm, I am confused...';

	/// en: 'I love you!'
	String get love => 'I love you!';

	/// en: 'I am not happy about this!'
	String get angry => 'I am not happy about this!';

	/// en: 'Wink wink!'
	String get winking => 'Wink wink!';

	/// en: 'I feel a little sad...'
	String get sad => 'I feel a little sad...';

	/// en: 'Eek! That is scary!'
	String get scared => 'Eek! That is scary!';
}

// Path: emotion_names
class Translations$emotion_names$en {
	Translations$emotion_names$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Happy'
	String get happy => 'Happy';

	/// en: 'Surprised'
	String get surprised => 'Surprised';

	/// en: 'Sleepy'
	String get sleepy => 'Sleepy';

	/// en: 'Excited'
	String get excited => 'Excited';

	/// en: 'Confused'
	String get confused => 'Confused';

	/// en: 'In love'
	String get love => 'In love';

	/// en: 'Angry'
	String get angry => 'Angry';

	/// en: 'Winking'
	String get winking => 'Winking';

	/// en: 'Sad'
	String get sad => 'Sad';

	/// en: 'Scared'
	String get scared => 'Scared';
}

// Path: game
class Translations$game$en {
	Translations$game$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feelings Game'
	String get title => 'Feelings Game';

	/// en: 'How does Haze feel?'
	String get prompt => 'How does Haze feel?';

	/// en: 'That's right — $name!'
	String correct({required Object name}) => 'That\'s right — ${name}!';

	List<String> get praise => [
		'Great job!',
		'You got it!',
		'Amazing!',
	];

	/// en: 'Hmm, look again...'
	String get try_again => 'Hmm, look again...';

	/// en: 'Score'
	String get score => 'Score';

	/// en: 'Streak'
	String get streak => 'Streak';

	/// en: 'Feelings game'
	String get play => 'Feelings game';
}

// Path: lab
class Translations$lab$en {
	Translations$lab$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$lab$references$en references = Translations$lab$references$en.internal(_root);

	/// en: 'Haze Lab'
	String get title => 'Haze Lab';

	/// en: 'Current mood: $name'
	String feeling_now({required Object name}) => 'Current mood: ${name}';

	/// en: 'Boop! Dopamine and adrenaline stirred.'
	String get boop_reaction => 'Boop! Dopamine and adrenaline stirred.';

	/// en: 'Cuddle! Oxytocin and endorphins stirred.'
	String get cuddle_reaction => 'Cuddle! Oxytocin and endorphins stirred.';

	/// en: 'Tell Haze what happened...'
	String get tell_haze => 'Tell Haze what happened...';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Body chemistry'
	String get chemistry => 'Body chemistry';

	/// en: 'Emotion mix'
	String get emotion_mix => 'Emotion mix';

	/// en: 'Tap a chemical to give Haze a tiny dose — then watch the face and the bars react. Feelings fade on their own, each at its own speed.'
	String get hint => 'Tap a chemical to give Haze a tiny dose — then watch the face and the bars react. Feelings fade on their own, each at its own speed.';

	/// en: 'Back to baseline'
	String get reset => 'Back to baseline';

	late final Translations$lab$challenge$en challenge = Translations$lab$challenge$en.internal(_root);
	late final Translations$lab$emotions$en emotions = Translations$lab$emotions$en.internal(_root);
	late final Translations$lab$chemicals$en chemicals = Translations$lab$chemicals$en.internal(_root);
}

// Path: ui
class Translations$ui$en {
	Translations$ui$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Choose Colors'
	String get choose_colors => 'Choose Colors';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Eye Color'
	String get eye_color => 'Eye Color';

	/// en: 'Mouth Color'
	String get mouth_color => 'Mouth Color';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Speech Enabled'
	String get speech_enabled => 'Speech Enabled';

	/// en: 'Robot will speak when expressions change'
	String get speech_description => 'Robot will speak when expressions change';

	/// en: 'Speech Rate'
	String get speech_rate => 'Speech Rate';

	/// en: 'Speech Pitch'
	String get speech_pitch => 'Speech Pitch';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Theme'
	String get theme => 'Theme';

	/// en: 'Dark Theme'
	String get dark_theme => 'Dark Theme';

	/// en: 'Light Theme'
	String get light_theme => 'Light Theme';

	/// en: 'Never sleep'
	String get never_sleep => 'Never sleep';

	/// en: 'Keep Haze awake while the app is open'
	String get never_sleep_description => 'Keep Haze awake while the app is open';
}

// Path: aurea
class Translations$aurea$en {
	Translations$aurea$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Aurea · Haze Lab'
	String get title => 'Aurea · Haze Lab';

	/// en: 'The meaning behind a feeling'
	String get subtitle => 'The meaning behind a feeling';

	/// en: 'INTERACTIVE PROTOTYPE'
	String get prototype => 'INTERACTIVE PROTOTYPE';

	/// en: 'One moment. Different ways to meet it.'
	String get introduction => 'One moment. Different ways to meet it.';

	/// en: 'Choose a moment'
	String get choose => 'Choose a moment';

	/// en: 'How does Haze read this?'
	String get interpretation => 'How does Haze read this?';

	/// en: 'Earlier experiences'
	String get history => 'Earlier experiences';

	/// en: 'First time here'
	String get firstTime => 'First time here';

	/// en: 'With practice'
	String get practiced => 'With practice';

	/// en: 'An imagined history for this replay. Your companion's memory stays separate.'
	String get historyHint => 'An imagined history for this replay. Your companion\'s memory stays separate.';

	/// en: 'Watch the response'
	String get play => 'Watch the response';

	/// en: 'Replay this moment'
	String get replay => 'Replay this moment';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Continue'
	String get resume => 'Continue';

	/// en: 'Reset experiment'
	String get reset => 'Reset experiment';

	List<String> get phases => [
		'Notice',
		'Make sense of it',
		'Choose a response',
	];

	/// en: 'Why this response?'
	String get why => 'Why this response?';

	/// en: 'Explore the ingredients from Aurea.'
	String get whyHint => 'Explore the ingredients from Aurea.';

	/// en: 'Taking shape'
	String get forming => 'Taking shape';

	/// en: 'Coming together'
	String get emerging => 'Coming together';

	/// en: 'Something is missing'
	String get incomplete => 'Something is missing';

	/// en: 'Press play to watch the feeling develop.'
	String get ready => 'Press play to watch the feeling develop.';

	/// en: 'The event stays the same. Meaning and experience change the response.'
	String get sameEvent => 'The event stays the same. Meaning and experience change the response.';

	/// en: 'Practice gives the response more steadiness; the initial feeling remains.'
	String get practiceEffect => 'Practice gives the response more steadiness; the initial feeling remains.';

	/// en: 'This is unfamiliar. The response is tentative, and can still take shape.'
	String get firstEffect => 'This is unfamiliar. The response is tentative, and can still take shape.';

	/// en: 'Inspired by Aurea's framework. Timing, signal levels and behavior are experimental design choices, not measurements of a person.'
	String get modelNote => 'Inspired by Aurea\'s framework. Timing, signal levels and behavior are experimental design choices, not measurements of a person.';

	/// en: 'Bars show simulated ingredient strength, not scientific probabilities.'
	String get signalNote => 'Bars show simulated ingredient strength, not scientific probabilities.';

	/// en: 'About Aurea · aureasystem.com'
	String get website => 'About Aurea · aureasystem.com';

	/// en: 'Could not open the website. You can copy the link instead.'
	String get websiteError => 'Could not open the website. You can copy the link instead.';

	/// en: 'Copy link'
	String get copyLink => 'Copy link';

	/// en: 'Source: aureasystem.com · snapshot 21 Sep 2026'
	String get source => 'Source: aureasystem.com · snapshot 21 Sep 2026';

	/// en: 'Original chemistry lab'
	String get chemistry => 'Original chemistry lab';

	/// en: 'The experiment could not load.'
	String get loadingError => 'The experiment could not load.';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Response timeline'
	String get timeline => 'Response timeline';

	List<String> get layers => [
		'Chemistry',
		'Basic emotion',
		'Appraisal',
		'Value',
		'Compound',
	];
}

// Path: home
class Translations$home$en {
	Translations$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'A little company.'
	String get companion => 'A little company.';

	/// en: 'Here with you.'
	String get greeting => 'Here with you.';

	/// en: 'Tap to play · hold to cuddle'
	String get hint => 'Tap to play · hold to cuddle';

	/// en: 'Talk'
	String get talk => 'Talk';

	/// en: 'Play'
	String get play => 'Play';

	/// en: 'Lab'
	String get lab => 'Lab';

	/// en: 'Explore a feeling'
	String get explore => 'Explore a feeling';

	/// en: 'A little moment in the Aurea lab.'
	String get exploreHint => 'A little moment in the Aurea lab.';

	/// en: 'Mimic'
	String get mimic => 'Mimic';

	/// en: 'Timer'
	String get timer => 'Timer';

	/// en: 'Say something'
	String get say => 'Say something';

	/// en: 'More'
	String get more => 'More';

	/// en: 'Colors'
	String get colors => 'Colors';

	/// en: 'Light theme'
	String get light => 'Light theme';

	/// en: 'Dark theme'
	String get dark => 'Dark theme';

	/// en: 'Quiet mode'
	String get hide => 'Quiet mode';

	/// en: 'Show controls'
	String get show => 'Show controls';

	/// en: 'Listening to you…'
	String get listening => 'Listening to you…';

	/// en: 'Playing it back…'
	String get replaying => 'Playing it back…';

	/// en: 'A little thinking…'
	String get thinking => 'A little thinking…';

	/// en: 'Haze is speaking'
	String get speaking => 'Haze is speaking';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'A moment with Haze'
	String get chat => 'A moment with Haze';

	/// en: 'Say something to Haze…'
	String get chatHint => 'Say something to Haze…';

	/// en: 'Using built-in replies for now.'
	String get fallback => 'Using built-in replies for now.';

	/// en: 'Resume'
	String get resume => 'Resume';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Stop'
	String get stop => 'Stop';

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'A little time together'
	String get timerTitle => 'A little time together';

	/// en: 'Choose how long to stay with Haze.'
	String get timerHint => 'Choose how long to stay with Haze.';

	/// en: 'Time together'
	String get timerRunning => 'Time together';

	/// en: 'Taking a pause'
	String get timerPaused => 'Taking a pause';

	/// en: '$n min'
	String minutes({required Object n}) => '${n} min';

	/// en: 'Make Haze feel a little more like you.'
	String get colorHint => 'Make Haze feel a little more like you.';

	List<String> get colorNames => [
		'Cyan',
		'Blue',
		'Green',
		'Purple',
		'Orange',
		'Red',
		'Yellow',
		'Pink',
	];
}

// Path: lab.references
class Translations$lab$references$en {
	Translations$lab$references$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Start with a reference'
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

	/// en: 'Examples of Haze’s simulated emotions, not recipes for human brain chemistry.'
	String get model => 'Examples of Haze’s simulated emotions, not recipes for human brain chemistry.';

	/// en: 'Try increasing $chemical. What changes?'
	String try_change({required Object chemical}) => 'Try increasing ${chemical}. What changes?';

	/// en: 'Time paused — your changes stay still.'
	String get paused => 'Time paused — your changes stay still.';

	/// en: 'Time is running — the mixture evolves.'
	String get running => 'Time is running — the mixture evolves.';

	/// en: 'Resume time'
	String get resume => 'Resume time';

	/// en: 'Pause time'
	String get pause => 'Pause time';

	/// en: 'Restore starting state'
	String get restore => 'Restore starting state';

	/// en: 'Experiment freely'
	String get free => 'Experiment freely';

	/// en: 'No measurable change — this control may have reached its limit.'
	String get no_change => 'No measurable change — this control may have reached its limit.';

	/// en: 'Starting state → Now'
	String get comparison => 'Starting state → Now';

	/// en: 'Last $chemical adjustment (intensity points):'
	String changed({required Object chemical}) => 'Last ${chemical} adjustment (intensity points):';

	/// en: 'Make one change to compare its effect.'
	String get unchanged => 'Make one change to compare its effect.';
}

// Path: lab.challenge
class Translations$lab$challenge$en {
	Translations$lab$challenge$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chemistry challenge'
	String get title => 'Chemistry challenge';

	/// en: 'Haze will name a feeling. Change the chemicals—or interact with Haze—until the body and face reach it.'
	String get explanation => 'Haze will name a feeling. Change the chemicals—or interact with Haze—until the body and face reach it.';

	/// en: 'Challenge in progress'
	String get active => 'Challenge in progress';

	/// en: 'Current goal: $name'
	String current({required Object name}) => 'Current goal: ${name}';

	/// en: 'Start a challenge'
	String get start => 'Start a challenge';

	/// en: 'Back to free play'
	String get stop => 'Back to free play';

	/// en: 'Make Haze feel $name!'
	String target({required Object name}) => 'Make Haze feel ${name}!';

	/// en: 'Haze's mood just shifted! Mix the chemicals until it feels $name.'
	String shifted({required Object name}) => 'Haze\'s mood just shifted! Mix the chemicals until it feels ${name}.';

	/// en: 'You did it — Haze feels $name!'
	String solved({required Object name}) => 'You did it — Haze feels ${name}!';
}

// Path: lab.emotions
class Translations$lab$emotions$en {
	Translations$lab$emotions$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'happy'
	String get happiness => 'happy';

	/// en: 'excited'
	String get excitement => 'excited';

	/// en: 'grumpy'
	String get anger => 'grumpy';

	/// en: 'calm'
	String get calm => 'calm';

	/// en: 'loved'
	String get bonding => 'loved';

	/// en: 'worried'
	String get anxiety => 'worried';

	/// en: 'sad'
	String get sadness => 'sad';

	/// en: 'euphoria'
	String get euphoria => 'euphoria';
}

// Path: lab.chemicals
class Translations$lab$chemicals$en {
	Translations$lab$chemicals$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$lab$chemicals$dopamine$en dopamine = Translations$lab$chemicals$dopamine$en.internal(_root);
	late final Translations$lab$chemicals$serotonin$en serotonin = Translations$lab$chemicals$serotonin$en.internal(_root);
	late final Translations$lab$chemicals$oxytocin$en oxytocin = Translations$lab$chemicals$oxytocin$en.internal(_root);
	late final Translations$lab$chemicals$testosterone$en testosterone = Translations$lab$chemicals$testosterone$en.internal(_root);
	late final Translations$lab$chemicals$cortisol$en cortisol = Translations$lab$chemicals$cortisol$en.internal(_root);
	late final Translations$lab$chemicals$adrenaline$en adrenaline = Translations$lab$chemicals$adrenaline$en.internal(_root);
	late final Translations$lab$chemicals$endorphins$en endorphins = Translations$lab$chemicals$endorphins$en.internal(_root);
	late final Translations$lab$chemicals$gaba$en gaba = Translations$lab$chemicals$gaba$en.internal(_root);
}

// Path: lab.chemicals.dopamine
class Translations$lab$chemicals$dopamine$en {
	Translations$lab$chemicals$dopamine$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Dopamine'
	String get name => 'Dopamine';

	/// en: 'the reward spark'
	String get tag => 'the reward spark';
}

// Path: lab.chemicals.serotonin
class Translations$lab$chemicals$serotonin$en {
	Translations$lab$chemicals$serotonin$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Serotonin'
	String get name => 'Serotonin';

	/// en: 'the sunshine'
	String get tag => 'the sunshine';
}

// Path: lab.chemicals.oxytocin
class Translations$lab$chemicals$oxytocin$en {
	Translations$lab$chemicals$oxytocin$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Oxytocin'
	String get name => 'Oxytocin';

	/// en: 'the cuddle chemical'
	String get tag => 'the cuddle chemical';
}

// Path: lab.chemicals.testosterone
class Translations$lab$chemicals$testosterone$en {
	Translations$lab$chemicals$testosterone$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Testosterone'
	String get name => 'Testosterone';

	/// en: 'the drive'
	String get tag => 'the drive';
}

// Path: lab.chemicals.cortisol
class Translations$lab$chemicals$cortisol$en {
	Translations$lab$chemicals$cortisol$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cortisol'
	String get name => 'Cortisol';

	/// en: 'the stress alarm'
	String get tag => 'the stress alarm';
}

// Path: lab.chemicals.adrenaline
class Translations$lab$chemicals$adrenaline$en {
	Translations$lab$chemicals$adrenaline$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Adrenaline'
	String get name => 'Adrenaline';

	/// en: 'the turbo boost'
	String get tag => 'the turbo boost';
}

// Path: lab.chemicals.endorphins
class Translations$lab$chemicals$endorphins$en {
	Translations$lab$chemicals$endorphins$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Endorphins'
	String get name => 'Endorphins';

	/// en: 'the giggle glow'
	String get tag => 'the giggle glow';
}

// Path: lab.chemicals.gaba
class Translations$lab$chemicals$gaba$en {
	Translations$lab$chemicals$gaba$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'GABA'
	String get name => 'GABA';

	/// en: 'the calm blanket'
	String get tag => 'the calm blanket';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'HazeBot Face',
			'expressions.happy' => 'I am so happy!',
			'expressions.surprised' => 'Oh wow! That surprised me!',
			'expressions.sleepy' => 'I am feeling sleepy...',
			'expressions.excited' => 'This is so exciting!',
			'expressions.confused' => 'Hmm, I am confused...',
			'expressions.love' => 'I love you!',
			'expressions.angry' => 'I am not happy about this!',
			'expressions.winking' => 'Wink wink!',
			'expressions.sad' => 'I feel a little sad...',
			'expressions.scared' => 'Eek! That is scary!',
			'emotion_names.happy' => 'Happy',
			'emotion_names.surprised' => 'Surprised',
			'emotion_names.sleepy' => 'Sleepy',
			'emotion_names.excited' => 'Excited',
			'emotion_names.confused' => 'Confused',
			'emotion_names.love' => 'In love',
			'emotion_names.angry' => 'Angry',
			'emotion_names.winking' => 'Winking',
			'emotion_names.sad' => 'Sad',
			'emotion_names.scared' => 'Scared',
			'game.title' => 'Feelings Game',
			'game.prompt' => 'How does Haze feel?',
			'game.correct' => ({required Object name}) => 'That\'s right — ${name}!',
			'game.praise.0' => 'Great job!',
			'game.praise.1' => 'You got it!',
			'game.praise.2' => 'Amazing!',
			'game.try_again' => 'Hmm, look again...',
			'game.score' => 'Score',
			'game.streak' => 'Streak',
			'game.play' => 'Feelings game',
			'lab.references.title' => 'Start with a reference',
			'lab.references.names.0' => 'Content',
			'lab.references.names.1' => 'Excited',
			'lab.references.names.2' => 'Affectionate',
			'lab.references.names.3' => 'Tense',
			'lab.references.names.4' => 'Sad',
			'lab.references.descriptions.0' => 'Comfortable and positive, with little excitement.',
			'lab.references.descriptions.1' => 'Full of energy and anticipation.',
			'lab.references.descriptions.2' => 'Warm and connected.',
			'lab.references.descriptions.3' => 'Agitated, with anger and anxiety together.',
			'lab.references.descriptions.4' => 'Low and withdrawn.',
			'lab.references.model' => 'Examples of Haze’s simulated emotions, not recipes for human brain chemistry.',
			'lab.references.try_change' => ({required Object chemical}) => 'Try increasing ${chemical}. What changes?',
			'lab.references.paused' => 'Time paused — your changes stay still.',
			'lab.references.running' => 'Time is running — the mixture evolves.',
			'lab.references.resume' => 'Resume time',
			'lab.references.pause' => 'Pause time',
			'lab.references.restore' => 'Restore starting state',
			'lab.references.free' => 'Experiment freely',
			'lab.references.no_change' => 'No measurable change — this control may have reached its limit.',
			'lab.references.comparison' => 'Starting state → Now',
			'lab.references.changed' => ({required Object chemical}) => 'Last ${chemical} adjustment (intensity points):',
			'lab.references.unchanged' => 'Make one change to compare its effect.',
			'lab.title' => 'Haze Lab',
			'lab.feeling_now' => ({required Object name}) => 'Current mood: ${name}',
			'lab.boop_reaction' => 'Boop! Dopamine and adrenaline stirred.',
			'lab.cuddle_reaction' => 'Cuddle! Oxytocin and endorphins stirred.',
			'lab.tell_haze' => 'Tell Haze what happened...',
			'lab.send' => 'Send',
			'lab.chemistry' => 'Body chemistry',
			'lab.emotion_mix' => 'Emotion mix',
			'lab.hint' => 'Tap a chemical to give Haze a tiny dose — then watch the face and the bars react. Feelings fade on their own, each at its own speed.',
			'lab.reset' => 'Back to baseline',
			'lab.challenge.title' => 'Chemistry challenge',
			'lab.challenge.explanation' => 'Haze will name a feeling. Change the chemicals—or interact with Haze—until the body and face reach it.',
			'lab.challenge.active' => 'Challenge in progress',
			'lab.challenge.current' => ({required Object name}) => 'Current goal: ${name}',
			'lab.challenge.start' => 'Start a challenge',
			'lab.challenge.stop' => 'Back to free play',
			'lab.challenge.target' => ({required Object name}) => 'Make Haze feel ${name}!',
			'lab.challenge.shifted' => ({required Object name}) => 'Haze\'s mood just shifted! Mix the chemicals until it feels ${name}.',
			'lab.challenge.solved' => ({required Object name}) => 'You did it — Haze feels ${name}!',
			'lab.emotions.happiness' => 'happy',
			'lab.emotions.excitement' => 'excited',
			'lab.emotions.anger' => 'grumpy',
			'lab.emotions.calm' => 'calm',
			'lab.emotions.bonding' => 'loved',
			'lab.emotions.anxiety' => 'worried',
			'lab.emotions.sadness' => 'sad',
			'lab.emotions.euphoria' => 'euphoria',
			'lab.chemicals.dopamine.name' => 'Dopamine',
			'lab.chemicals.dopamine.tag' => 'the reward spark',
			'lab.chemicals.serotonin.name' => 'Serotonin',
			'lab.chemicals.serotonin.tag' => 'the sunshine',
			'lab.chemicals.oxytocin.name' => 'Oxytocin',
			'lab.chemicals.oxytocin.tag' => 'the cuddle chemical',
			'lab.chemicals.testosterone.name' => 'Testosterone',
			'lab.chemicals.testosterone.tag' => 'the drive',
			'lab.chemicals.cortisol.name' => 'Cortisol',
			'lab.chemicals.cortisol.tag' => 'the stress alarm',
			'lab.chemicals.adrenaline.name' => 'Adrenaline',
			'lab.chemicals.adrenaline.tag' => 'the turbo boost',
			'lab.chemicals.endorphins.name' => 'Endorphins',
			'lab.chemicals.endorphins.tag' => 'the giggle glow',
			'lab.chemicals.gaba.name' => 'GABA',
			'lab.chemicals.gaba.tag' => 'the calm blanket',
			'ui.choose_colors' => 'Choose Colors',
			'ui.settings' => 'Settings',
			'ui.eye_color' => 'Eye Color',
			'ui.mouth_color' => 'Mouth Color',
			'ui.done' => 'Done',
			'ui.speech_enabled' => 'Speech Enabled',
			'ui.speech_description' => 'Robot will speak when expressions change',
			'ui.speech_rate' => 'Speech Rate',
			'ui.speech_pitch' => 'Speech Pitch',
			'ui.language' => 'Language',
			'ui.theme' => 'Theme',
			'ui.dark_theme' => 'Dark Theme',
			'ui.light_theme' => 'Light Theme',
			'ui.never_sleep' => 'Never sleep',
			'ui.never_sleep_description' => 'Keep Haze awake while the app is open',
			'aurea.title' => 'Aurea · Haze Lab',
			'aurea.subtitle' => 'The meaning behind a feeling',
			'aurea.prototype' => 'INTERACTIVE PROTOTYPE',
			'aurea.introduction' => 'One moment. Different ways to meet it.',
			'aurea.choose' => 'Choose a moment',
			'aurea.interpretation' => 'How does Haze read this?',
			'aurea.history' => 'Earlier experiences',
			'aurea.firstTime' => 'First time here',
			'aurea.practiced' => 'With practice',
			'aurea.historyHint' => 'An imagined history for this replay. Your companion\'s memory stays separate.',
			'aurea.play' => 'Watch the response',
			'aurea.replay' => 'Replay this moment',
			'aurea.pause' => 'Pause',
			'aurea.resume' => 'Continue',
			'aurea.reset' => 'Reset experiment',
			'aurea.phases.0' => 'Notice',
			'aurea.phases.1' => 'Make sense of it',
			'aurea.phases.2' => 'Choose a response',
			'aurea.why' => 'Why this response?',
			'aurea.whyHint' => 'Explore the ingredients from Aurea.',
			'aurea.forming' => 'Taking shape',
			'aurea.emerging' => 'Coming together',
			'aurea.incomplete' => 'Something is missing',
			'aurea.ready' => 'Press play to watch the feeling develop.',
			'aurea.sameEvent' => 'The event stays the same. Meaning and experience change the response.',
			'aurea.practiceEffect' => 'Practice gives the response more steadiness; the initial feeling remains.',
			'aurea.firstEffect' => 'This is unfamiliar. The response is tentative, and can still take shape.',
			'aurea.modelNote' => 'Inspired by Aurea\'s framework. Timing, signal levels and behavior are experimental design choices, not measurements of a person.',
			'aurea.signalNote' => 'Bars show simulated ingredient strength, not scientific probabilities.',
			'aurea.website' => 'About Aurea · aureasystem.com',
			'aurea.websiteError' => 'Could not open the website. You can copy the link instead.',
			'aurea.copyLink' => 'Copy link',
			'aurea.source' => 'Source: aureasystem.com · snapshot 21 Sep 2026',
			'aurea.chemistry' => 'Original chemistry lab',
			'aurea.loadingError' => 'The experiment could not load.',
			'aurea.retry' => 'Try again',
			'aurea.timeline' => 'Response timeline',
			'aurea.layers.0' => 'Chemistry',
			'aurea.layers.1' => 'Basic emotion',
			'aurea.layers.2' => 'Appraisal',
			'aurea.layers.3' => 'Value',
			'aurea.layers.4' => 'Compound',
			'home.companion' => 'A little company.',
			'home.greeting' => 'Here with you.',
			'home.hint' => 'Tap to play · hold to cuddle',
			'home.talk' => 'Talk',
			'home.play' => 'Play',
			'home.lab' => 'Lab',
			'home.explore' => 'Explore a feeling',
			'home.exploreHint' => 'A little moment in the Aurea lab.',
			'home.mimic' => 'Mimic',
			'home.timer' => 'Timer',
			'home.say' => 'Say something',
			'home.more' => 'More',
			'home.colors' => 'Colors',
			'home.light' => 'Light theme',
			'home.dark' => 'Dark theme',
			'home.hide' => 'Quiet mode',
			'home.show' => 'Show controls',
			'home.listening' => 'Listening to you…',
			'home.replaying' => 'Playing it back…',
			'home.thinking' => 'A little thinking…',
			'home.speaking' => 'Haze is speaking',
			'home.done' => 'Done',
			'home.close' => 'Close',
			'home.send' => 'Send',
			'home.chat' => 'A moment with Haze',
			'home.chatHint' => 'Say something to Haze…',
			'home.fallback' => 'Using built-in replies for now.',
			'home.resume' => 'Resume',
			'home.pause' => 'Pause',
			'home.stop' => 'Stop',
			'home.start' => 'Start',
			'home.cancel' => 'Cancel',
			'home.timerTitle' => 'A little time together',
			'home.timerHint' => 'Choose how long to stay with Haze.',
			'home.timerRunning' => 'Time together',
			'home.timerPaused' => 'Taking a pause',
			'home.minutes' => ({required Object n}) => '${n} min',
			'home.colorHint' => 'Make Haze feel a little more like you.',
			'home.colorNames.0' => 'Cyan',
			'home.colorNames.1' => 'Blue',
			'home.colorNames.2' => 'Green',
			'home.colorNames.3' => 'Purple',
			'home.colorNames.4' => 'Orange',
			'home.colorNames.5' => 'Red',
			'home.colorNames.6' => 'Yellow',
			'home.colorNames.7' => 'Pink',
			_ => null,
		};
	}
}
