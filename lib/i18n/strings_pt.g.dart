///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsPt extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsPt _root = this; // ignore: unused_field

	@override 
	TranslationsPt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPt(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$app$pt app = _Translations$app$pt._(_root);
	@override late final _Translations$expressions$pt expressions = _Translations$expressions$pt._(_root);
	@override late final _Translations$emotion_names$pt emotion_names = _Translations$emotion_names$pt._(_root);
	@override late final _Translations$game$pt game = _Translations$game$pt._(_root);
	@override late final _Translations$lab$pt lab = _Translations$lab$pt._(_root);
	@override late final _Translations$ui$pt ui = _Translations$ui$pt._(_root);
	@override late final _Translations$aurea$pt aurea = _Translations$aurea$pt._(_root);
	@override late final _Translations$home$pt home = _Translations$home$pt._(_root);
}

// Path: app
class _Translations$app$pt extends Translations$app$en {
	_Translations$app$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'HazeBot Rosto';
}

// Path: expressions
class _Translations$expressions$pt extends Translations$expressions$en {
	_Translations$expressions$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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

// Path: emotion_names
class _Translations$emotion_names$pt extends Translations$emotion_names$en {
	_Translations$emotion_names$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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
class _Translations$game$pt extends Translations$game$en {
	_Translations$game$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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
class _Translations$lab$pt extends Translations$lab$en {
	_Translations$lab$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _Translations$lab$references$pt references = _Translations$lab$references$pt._(_root);
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
	@override late final _Translations$lab$challenge$pt challenge = _Translations$lab$challenge$pt._(_root);
	@override late final _Translations$lab$emotions$pt emotions = _Translations$lab$emotions$pt._(_root);
	@override late final _Translations$lab$chemicals$pt chemicals = _Translations$lab$chemicals$pt._(_root);
}

// Path: ui
class _Translations$ui$pt extends Translations$ui$en {
	_Translations$ui$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get choose_colors => 'Escolher Cores';
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
class _Translations$aurea$pt extends Translations$aurea$en {
	_Translations$aurea$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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
	@override String get website => 'Sobre Aurea · aureasystem.com';
	@override String get websiteError => 'Não foi possível abrir o site. Você pode copiar o link.';
	@override String get copyLink => 'Copiar link';
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

// Path: home
class _Translations$home$pt extends Translations$home$en {
	_Translations$home$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get companion => 'Um pouco de companhia.';
	@override String get greeting => 'Aqui com você.';
	@override String get hint => 'Toque para brincar · segure para fazer carinho';
	@override String get talk => 'Conversar';
	@override String get play => 'Brincar';
	@override String get lab => 'Lab';
	@override String get explore => 'Explore um sentimento';
	@override String get exploreHint => 'Um pequeno momento no laboratório Aurea.';
	@override String get mimic => 'Imitar';
	@override String get timer => 'Timer';
	@override String get say => 'Diga alguma coisa';
	@override String get more => 'Mais';
	@override String get colors => 'Cores';
	@override String get light => 'Tema claro';
	@override String get dark => 'Tema escuro';
	@override String get hide => 'Modo tranquilo';
	@override String get show => 'Mostrar controles';
	@override String get listening => 'Ouvindo você…';
	@override String get replaying => 'Repetindo…';
	@override String get thinking => 'Pensando um pouquinho…';
	@override String get speaking => 'Haze está falando';
	@override String get done => 'Pronto';
	@override String get close => 'Fechar';
	@override String get send => 'Enviar';
	@override String get chat => 'Um momento com Haze';
	@override String get chatHint => 'Diga algo para Haze…';
	@override String get fallback => 'Usando respostas prontas por enquanto.';
	@override String get resume => 'Continuar';
	@override String get pause => 'Pausar';
	@override String get stop => 'Parar';
	@override String get start => 'Começar';
	@override String get cancel => 'Cancelar';
	@override String get timerTitle => 'Um tempinho juntos';
	@override String get timerHint => 'Escolha quanto tempo ficar com Haze.';
	@override String get timerRunning => 'Tempo juntos';
	@override String get timerPaused => 'Uma pequena pausa';
	@override String minutes({required Object n}) => '${n} min';
	@override String get colorHint => 'Deixe Haze um pouco mais com a sua cara.';
	@override List<String> get colorNames => [
		'Ciano',
		'Azul',
		'Verde',
		'Roxo',
		'Laranja',
		'Vermelho',
		'Amarelo',
		'Rosa',
	];
}

// Path: lab.references
class _Translations$lab$references$pt extends Translations$lab$references$en {
	_Translations$lab$references$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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
class _Translations$lab$challenge$pt extends Translations$lab$challenge$en {
	_Translations$lab$challenge$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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
class _Translations$lab$emotions$pt extends Translations$lab$emotions$en {
	_Translations$lab$emotions$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

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
class _Translations$lab$chemicals$pt extends Translations$lab$chemicals$en {
	_Translations$lab$chemicals$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _Translations$lab$chemicals$dopamine$pt dopamine = _Translations$lab$chemicals$dopamine$pt._(_root);
	@override late final _Translations$lab$chemicals$serotonin$pt serotonin = _Translations$lab$chemicals$serotonin$pt._(_root);
	@override late final _Translations$lab$chemicals$oxytocin$pt oxytocin = _Translations$lab$chemicals$oxytocin$pt._(_root);
	@override late final _Translations$lab$chemicals$testosterone$pt testosterone = _Translations$lab$chemicals$testosterone$pt._(_root);
	@override late final _Translations$lab$chemicals$cortisol$pt cortisol = _Translations$lab$chemicals$cortisol$pt._(_root);
	@override late final _Translations$lab$chemicals$adrenaline$pt adrenaline = _Translations$lab$chemicals$adrenaline$pt._(_root);
	@override late final _Translations$lab$chemicals$endorphins$pt endorphins = _Translations$lab$chemicals$endorphins$pt._(_root);
	@override late final _Translations$lab$chemicals$gaba$pt gaba = _Translations$lab$chemicals$gaba$pt._(_root);
}

// Path: lab.chemicals.dopamine
class _Translations$lab$chemicals$dopamine$pt extends Translations$lab$chemicals$dopamine$en {
	_Translations$lab$chemicals$dopamine$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Dopamina';
	@override String get tag => 'a faísca da recompensa';
}

// Path: lab.chemicals.serotonin
class _Translations$lab$chemicals$serotonin$pt extends Translations$lab$chemicals$serotonin$en {
	_Translations$lab$chemicals$serotonin$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Serotonina';
	@override String get tag => 'o solzinho';
}

// Path: lab.chemicals.oxytocin
class _Translations$lab$chemicals$oxytocin$pt extends Translations$lab$chemicals$oxytocin$en {
	_Translations$lab$chemicals$oxytocin$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Ocitocina';
	@override String get tag => 'a química do abraço';
}

// Path: lab.chemicals.testosterone
class _Translations$lab$chemicals$testosterone$pt extends Translations$lab$chemicals$testosterone$en {
	_Translations$lab$chemicals$testosterone$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Testosterona';
	@override String get tag => 'a garra';
}

// Path: lab.chemicals.cortisol
class _Translations$lab$chemicals$cortisol$pt extends Translations$lab$chemicals$cortisol$en {
	_Translations$lab$chemicals$cortisol$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Cortisol';
	@override String get tag => 'o alarme do estresse';
}

// Path: lab.chemicals.adrenaline
class _Translations$lab$chemicals$adrenaline$pt extends Translations$lab$chemicals$adrenaline$en {
	_Translations$lab$chemicals$adrenaline$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Adrenalina';
	@override String get tag => 'o turbo';
}

// Path: lab.chemicals.endorphins
class _Translations$lab$chemicals$endorphins$pt extends Translations$lab$chemicals$endorphins$en {
	_Translations$lab$chemicals$endorphins$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Endorfinas';
	@override String get tag => 'o brilho da risada';
}

// Path: lab.chemicals.gaba
class _Translations$lab$chemicals$gaba$pt extends Translations$lab$chemicals$gaba$en {
	_Translations$lab$chemicals$gaba$pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'GABA';
	@override String get tag => 'o cobertor da calma';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.title' => 'HazeBot Rosto',
			'expressions.happy' => 'Estou muito feliz!',
			'expressions.surprised' => 'Nossa! Isso me surpreendeu!',
			'expressions.sleepy' => 'Estou com sono...',
			'expressions.excited' => 'Isso é muito emocionante!',
			'expressions.confused' => 'Hmm, estou confuso...',
			'expressions.love' => 'Eu te amo!',
			'expressions.angry' => 'Não estou feliz com isso!',
			'expressions.winking' => 'Piscadinha!',
			'expressions.sad' => 'Estou um pouco triste...',
			'expressions.scared' => 'Ai! Que medo!',
			'emotion_names.happy' => 'Feliz',
			'emotion_names.surprised' => 'Surpreso',
			'emotion_names.sleepy' => 'Sonolento',
			'emotion_names.excited' => 'Animado',
			'emotion_names.confused' => 'Confuso',
			'emotion_names.love' => 'Apaixonado',
			'emotion_names.angry' => 'Bravo',
			'emotion_names.winking' => 'Piscando',
			'emotion_names.sad' => 'Triste',
			'emotion_names.scared' => 'Assustado',
			'game.title' => 'Jogo dos Sentimentos',
			'game.prompt' => 'Como o Haze está se sentindo?',
			'game.correct' => ({required Object name}) => 'Isso mesmo — ${name}!',
			'game.praise.0' => 'Muito bem!',
			'game.praise.1' => 'Você acertou!',
			'game.praise.2' => 'Incrível!',
			'game.try_again' => 'Hmm, olhe de novo...',
			'game.score' => 'Pontos',
			'game.streak' => 'Sequência',
			'game.play' => 'Jogo dos sentimentos',
			'lab.references.title' => 'Comece com uma referência',
			'lab.references.names.0' => 'Contente',
			'lab.references.names.1' => 'Animado',
			'lab.references.names.2' => 'Carinhoso',
			'lab.references.names.3' => 'Tenso',
			'lab.references.names.4' => 'Triste',
			'lab.references.descriptions.0' => 'Confortável e positivo, com pouca agitação.',
			'lab.references.descriptions.1' => 'Cheio de energia e expectativa.',
			'lab.references.descriptions.2' => 'Acolhedor e conectado.',
			'lab.references.descriptions.3' => 'Agitado, com raiva e ansiedade juntas.',
			'lab.references.descriptions.4' => 'Desanimado e retraído.',
			'lab.references.model' => 'Exemplos das emoções simuladas do Haze, não receitas da química cerebral humana.',
			'lab.references.try_change' => ({required Object chemical}) => 'Experimente aumentar ${chemical}. O que muda?',
			'lab.references.paused' => 'Tempo pausado — suas mudanças ficam estáveis.',
			'lab.references.running' => 'O tempo está passando — a mistura evolui.',
			'lab.references.resume' => 'Retomar tempo',
			'lab.references.pause' => 'Pausar tempo',
			'lab.references.restore' => 'Restaurar estado inicial',
			'lab.references.free' => 'Experimentar livremente',
			'lab.references.no_change' => 'Nenhuma mudança mensurável — este controle pode ter atingido o limite.',
			'lab.references.comparison' => 'Estado inicial → Agora',
			'lab.references.changed' => ({required Object chemical}) => 'Último ajuste de ${chemical} (pontos de intensidade):',
			'lab.references.unchanged' => 'Faça uma mudança para comparar o efeito.',
			'lab.title' => 'Laboratório do Haze',
			'lab.feeling_now' => ({required Object name}) => 'Humor atual: ${name}',
			'lab.boop_reaction' => 'Boop! A dopamina e a adrenalina se agitaram.',
			'lab.cuddle_reaction' => 'Abraço! A ocitocina e as endorfinas se agitaram.',
			'lab.tell_haze' => 'Conte ao Haze o que aconteceu...',
			'lab.send' => 'Enviar',
			'lab.chemistry' => 'Química do corpo',
			'lab.emotion_mix' => 'Mistura de emoções',
			'lab.hint' => 'Toque em uma substância para dar uma dosezinha ao Haze — e veja o rosto e as barras reagirem. Os sentimentos passam sozinhos, cada um na sua velocidade.',
			'lab.reset' => 'Voltar ao normal',
			'lab.challenge.title' => 'Desafio de química',
			'lab.challenge.explanation' => 'O Haze vai escolher um sentimento. Mude as substâncias — ou interaja com ele — até o corpo e o rosto chegarem lá.',
			'lab.challenge.active' => 'Desafio em andamento',
			'lab.challenge.current' => ({required Object name}) => 'Objetivo atual: ${name}',
			'lab.challenge.start' => 'Começar um desafio',
			'lab.challenge.stop' => 'Voltar ao modo livre',
			'lab.challenge.target' => ({required Object name}) => 'Faça o Haze se sentir ${name}!',
			'lab.challenge.shifted' => ({required Object name}) => 'O humor do Haze mudou! Misture as substâncias até ele se sentir ${name}.',
			'lab.challenge.solved' => ({required Object name}) => 'Você conseguiu — o Haze está se sentindo ${name}!',
			'lab.emotions.happiness' => 'feliz',
			'lab.emotions.excitement' => 'animado',
			'lab.emotions.anger' => 'bravinho',
			'lab.emotions.calm' => 'calmo',
			'lab.emotions.bonding' => 'amado',
			'lab.emotions.anxiety' => 'preocupado',
			'lab.emotions.sadness' => 'triste',
			'lab.emotions.euphoria' => 'euforia',
			'lab.chemicals.dopamine.name' => 'Dopamina',
			'lab.chemicals.dopamine.tag' => 'a faísca da recompensa',
			'lab.chemicals.serotonin.name' => 'Serotonina',
			'lab.chemicals.serotonin.tag' => 'o solzinho',
			'lab.chemicals.oxytocin.name' => 'Ocitocina',
			'lab.chemicals.oxytocin.tag' => 'a química do abraço',
			'lab.chemicals.testosterone.name' => 'Testosterona',
			'lab.chemicals.testosterone.tag' => 'a garra',
			'lab.chemicals.cortisol.name' => 'Cortisol',
			'lab.chemicals.cortisol.tag' => 'o alarme do estresse',
			'lab.chemicals.adrenaline.name' => 'Adrenalina',
			'lab.chemicals.adrenaline.tag' => 'o turbo',
			'lab.chemicals.endorphins.name' => 'Endorfinas',
			'lab.chemicals.endorphins.tag' => 'o brilho da risada',
			'lab.chemicals.gaba.name' => 'GABA',
			'lab.chemicals.gaba.tag' => 'o cobertor da calma',
			'ui.choose_colors' => 'Escolher Cores',
			'ui.settings' => 'Configurações',
			'ui.eye_color' => 'Cor dos Olhos',
			'ui.mouth_color' => 'Cor da Boca',
			'ui.done' => 'Pronto',
			'ui.speech_enabled' => 'Fala Ativada',
			'ui.speech_description' => 'O robô falará quando as expressões mudarem',
			'ui.speech_rate' => 'Velocidade da Fala',
			'ui.speech_pitch' => 'Tom da Fala',
			'ui.language' => 'Idioma',
			'ui.theme' => 'Tema',
			'ui.dark_theme' => 'Tema Escuro',
			'ui.light_theme' => 'Tema Claro',
			'ui.never_sleep' => 'Nunca dormir',
			'ui.never_sleep_description' => 'Manter o Haze acordado enquanto o app estiver aberto',
			'aurea.title' => 'Aurea · Haze Lab',
			'aurea.subtitle' => 'O sentido por trás de um sentimento',
			'aurea.prototype' => 'PROTÓTIPO INTERATIVO',
			'aurea.introduction' => 'Um momento. Diferentes formas de vivê-lo.',
			'aurea.choose' => 'Escolha um momento',
			'aurea.interpretation' => 'Como Haze interpreta isso?',
			'aurea.history' => 'Experiências anteriores',
			'aurea.firstTime' => 'Primeira vez',
			'aurea.practiced' => 'Com prática',
			'aurea.historyHint' => 'Um passado imaginado para esta cena. A memória do seu companheiro fica separada.',
			'aurea.play' => 'Ver a reação',
			'aurea.replay' => 'Rever este momento',
			'aurea.pause' => 'Pausar',
			'aurea.resume' => 'Continuar',
			'aurea.reset' => 'Reiniciar experimento',
			'aurea.phases.0' => 'Perceber',
			'aurea.phases.1' => 'Entender o momento',
			'aurea.phases.2' => 'Escolher uma resposta',
			'aurea.why' => 'Por que essa reação?',
			'aurea.whyHint' => 'Explore os ingredientes da Aurea.',
			'aurea.forming' => 'Ganhando forma',
			'aurea.emerging' => 'Se formando',
			'aurea.incomplete' => 'Algo está faltando',
			'aurea.ready' => 'Dê o play para ver o sentimento se desenvolver.',
			'aurea.sameEvent' => 'O acontecimento é o mesmo. O sentido e a experiência mudam a reação.',
			'aurea.practiceEffect' => 'A prática traz mais firmeza à resposta; o sentimento inicial permanece.',
			'aurea.firstEffect' => 'Isso é novo para Haze. A resposta é hesitante e ainda pode ganhar forma.',
			'aurea.modelNote' => 'Inspirado no modelo da Aurea. Tempos, níveis e comportamentos são escolhas experimentais, não medidas sobre uma pessoa.',
			'aurea.signalNote' => 'As barras mostram a força simulada dos ingredientes, não probabilidades científicas.',
			'aurea.website' => 'Sobre Aurea · aureasystem.com',
			'aurea.websiteError' => 'Não foi possível abrir o site. Você pode copiar o link.',
			'aurea.copyLink' => 'Copiar link',
			'aurea.source' => 'Fonte: aureasystem.com · versão de 21 set 2026',
			'aurea.chemistry' => 'Laboratório de química original',
			'aurea.loadingError' => 'Não foi possível carregar o experimento.',
			'aurea.retry' => 'Tentar novamente',
			'aurea.timeline' => 'Linha do tempo da resposta',
			'aurea.layers.0' => 'Química',
			'aurea.layers.1' => 'Emoção básica',
			'aurea.layers.2' => 'Interpretação',
			'aurea.layers.3' => 'Valor',
			'aurea.layers.4' => 'Composto',
			'home.companion' => 'Um pouco de companhia.',
			'home.greeting' => 'Aqui com você.',
			'home.hint' => 'Toque para brincar · segure para fazer carinho',
			'home.talk' => 'Conversar',
			'home.play' => 'Brincar',
			'home.lab' => 'Lab',
			'home.explore' => 'Explore um sentimento',
			'home.exploreHint' => 'Um pequeno momento no laboratório Aurea.',
			'home.mimic' => 'Imitar',
			'home.timer' => 'Timer',
			'home.say' => 'Diga alguma coisa',
			'home.more' => 'Mais',
			'home.colors' => 'Cores',
			'home.light' => 'Tema claro',
			'home.dark' => 'Tema escuro',
			'home.hide' => 'Modo tranquilo',
			'home.show' => 'Mostrar controles',
			'home.listening' => 'Ouvindo você…',
			'home.replaying' => 'Repetindo…',
			'home.thinking' => 'Pensando um pouquinho…',
			'home.speaking' => 'Haze está falando',
			'home.done' => 'Pronto',
			'home.close' => 'Fechar',
			'home.send' => 'Enviar',
			'home.chat' => 'Um momento com Haze',
			'home.chatHint' => 'Diga algo para Haze…',
			'home.fallback' => 'Usando respostas prontas por enquanto.',
			'home.resume' => 'Continuar',
			'home.pause' => 'Pausar',
			'home.stop' => 'Parar',
			'home.start' => 'Começar',
			'home.cancel' => 'Cancelar',
			'home.timerTitle' => 'Um tempinho juntos',
			'home.timerHint' => 'Escolha quanto tempo ficar com Haze.',
			'home.timerRunning' => 'Tempo juntos',
			'home.timerPaused' => 'Uma pequena pausa',
			'home.minutes' => ({required Object n}) => '${n} min',
			'home.colorHint' => 'Deixe Haze um pouco mais com a sua cara.',
			'home.colorNames.0' => 'Ciano',
			'home.colorNames.1' => 'Azul',
			'home.colorNames.2' => 'Verde',
			'home.colorNames.3' => 'Roxo',
			'home.colorNames.4' => 'Laranja',
			'home.colorNames.5' => 'Vermelho',
			'home.colorNames.6' => 'Amarelo',
			'home.colorNames.7' => 'Rosa',
			_ => null,
		};
	}
}
