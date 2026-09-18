// FILE: lib/core/constants/app_routes.dart
// PURPOSE: Route path constants — single source of truth for all navigation
class AppRoutes {
  AppRoutes._();

  static const home = '/';

  // Wortschatz
  static const wortschatz             = '/wortschatz';
  static const wortschatzList         = '/wortschatz/list';
  static const wortschatzBooks        = '/wortschatz/books';
  static const wortschatzBookWords    = '/wortschatz/books/:bookId';
  static const wortschatzLevel        = '/wortschatz/level';
  static const wortschatzType         = '/wortschatz/type';
  static const wortschatzWordDetail   = '/wortschatz/word/:wordId';
  static const wortschatzAddWord      = '/wortschatz/add';
  static const wortschatzCategories   = '/wortschatz/categories';
  static const wortschatzCategoryDetail = '/wortschatz/categories/:categoryId';

  // Leitner
  static const leitner      = '/leitner';
  static const leitnerReview = '/leitner/review';
  static const leitnerStats  = '/leitner/stats';

  // Grammatik
  static const grammatik         = '/grammatik';
  static const grammatikLevel    = '/grammatik/:level';
  static const grammatikLesson   = '/grammatik/lesson/:lessonId';
  static const grammatikExercise = '/grammatik/exercise/:lessonId';
  static const grammatikQuiz     = '/grammatik/quiz/:lessonId';

  /// Katalog-Ansicht (G1): view = niveau|thema|satzglied
  static String grammatikKatalog(String view, String key) =>
      '/grammatik/katalog/$view/$key';

  /// Lektion-Content-Screen (G2)
  static String grammatikLektion(String slug) => '/grammatik/lektion/$slug';
  /// G7b: kombinierter Niveau-Test (level = a1…c2).
  static String grammatikNiveauTest(String level) =>
      '/grammatik/quiz-niveau/${level.toLowerCase()}';
  /// G7a: Übungen einer Lektion.
  static String grammatikLektionUebung(String slug) =>
      '/grammatik/lektion/$slug/uebung';

  // Lesen
  static const lesen      = '/lesen';
  static const lesenLevel = '/lesen/:level';
  static const lesenText  = '/lesen/text/:textId';
  static const lesenNews  = '/lesen/news';

  // Hören
  static const hoeren         = '/hoeren';
  static const hoerenLevel    = '/hoeren/:level';
  static const hoerenKaraoke  = '/hoeren/karaoke/:audioId';
  static const hoerenShadowing = '/hoeren/shadowing/:audioId';
  static const hoerenQuiz     = '/hoeren/quiz/:audioId';

  static const sprechen  = '/sprechen';
  static const schreiben = '/schreiben';

  // Auswendiglernen
  static const auswendiglernen         = '/auswendiglernen';
  static const auswendiglernCategory   = '/auswendiglernen/:categoryId';
  static const auswendiglernMemorize   = '/auswendiglernen/:categoryId/memorize';
  static const auswendiglernCloze      = '/auswendiglernen/:categoryId/cloze';

  // Prüfungen
  static const pruefungen           = '/pruefungen';
  static const pruefungenType       = '/pruefungen/:type';
  static const pruefungenSimulation = '/pruefungen/:type/:level/simulation';

  // Selbstlernen
  static const selbstlernen = '/selbstlernen';
  static const pomodoro     = '/selbstlernen/pomodoro';
  static const leitfaden    = '/selbstlernen/leitfaden';
  static const vorlagen     = '/selbstlernen/vorlagen';

  static const fragen      = '/fragen';
  static const sozialmedien = '/sozialmedien';

  // Search
  static const search = '/search';

  // More
  static const more          = '/more';
  static const settings      = '/more/settings';
  static const profile       = '/more/profile';
  static const privacyPolicy = '/more/privacy';

  // Import
  static const contentImport = '/import';

  // Konnektoren
  static const konnektoren        = '/konnektoren';
  static const konnektorenQuiz    = '/konnektoren/quiz';
  static const konnektorenGrammar = '/konnektoren/grammar';

  static String konnektorenDetail(int id) => '/konnektoren/$id';

  // Dativ-Verben
  static const dativVerben        = '/dativ-verben';
  static const dativVerbenQuiz    = '/dativ-verben/quiz';
  static const dativVerbenGrammar = '/dativ-verben/grammar';

  static String dativVerbenDetail(int id) => '/dativ-verben/$id';

  static bool isDativVerbenDetail(String location) =>
      RegExp(r'^/dativ-verben/\d+$').hasMatch(location);

  // NVV (Nomen-Verb-Verbindungen)
  static const nvv        = '/nvv';
  static const nvvQuiz    = '/nvv/quiz';
  static const nvvGrammar = '/nvv/grammar';

  static String nvvDetail(int id) => '/nvv/$id';

  // Präpositionen
  static const praepositionen         = '/praepositionen';
  static const praepositonenQuiz      = '/praepositionen/quiz';
  static const praepositonenGrammar   = '/praepositionen/grammar';

  static String praepositonenDetail(int id) => '/praepositionen/$id';

  // Reflexivverben
  static const reflexiv        = '/reflexiv';
  static const reflexivQuiz    = '/reflexiv/quiz';
  static const reflexivGrammar = '/reflexiv/grammar';

  static String reflexivDetail(int id) => '/reflexiv/$id';

  // Trennbare / Untrennbare Verben
  static const trennbar        = '/trennbar';
  static const trennbarQuiz    = '/trennbar/quiz';
  static const trennbarGrammar = '/trennbar/grammar';

  static String trennbarDetail(int id) => '/trennbar/$id';

  // Verben mit Präpositionen
  static const verbPraep        = '/verb-praep';
  static const verbPraepQuiz    = '/verb-praep/quiz';
  static const verbPraepGrammar = '/verb-praep/grammar';

  static String verbPraepDetail(int id) => '/verb-praep/$id';

  // Unregelmäßige Verben
  static const unregelVerben        = '/unregelm-verben';
  static const unregelVerbenQuiz    = '/unregelm-verben/quiz';
  static const unregelVerbenGrammar = '/unregelm-verben/grammar';

  static String unregelVerbenDetail(int id) => '/unregelm-verben/$id';

  // Redemittel 1010
  static const redemittel1010       = '/redemittel-1010';
  static const redemittel1010Quiz   = '/redemittel-1010/quiz';
  static const redemittel1010Grammar = '/redemittel-1010/grammar';

  static String redemittel1010Detail(int id) => '/redemittel-1010/$id';

  // Redemittel — Prüfungsdecks (Goethe / ÖSD)
  static const redemittelGoetheB2     = '/redemittel-goethe-b2';
  static const redemittelGoetheB2Quiz = '/redemittel-goethe-b2/quiz';

  static String redemittelGoetheB2Detail(int id) => '/redemittel-goethe-b2/$id';

  static const redemittelOesdB2     = '/redemittel-oesd-b2';
  static const redemittelOesdB2Quiz = '/redemittel-oesd-b2/quiz';

  static String redemittelOesdB2Detail(int id) => '/redemittel-oesd-b2/$id';

  static const redemittelOesdC1     = '/redemittel-oesd-c1';
  static const redemittelOesdC1Quiz = '/redemittel-oesd-c1/quiz';

  static String redemittelOesdC1Detail(int id) => '/redemittel-oesd-c1/$id';

  // Modalverben
  static const modalverben        = '/modalverben';
  static const modalverbenGrammar = '/modalverben/grammar';

  static String modalverbenDetail(String id) => '/modalverben/$id';

  // Grammatik — eigenständige Themen (generisch, siehe grammar_topic.dart)
  static String grammatikThema(String topicId) => '/grammatik/thema/$topicId';

  // Wort-Seiten der Vokabular-Karten (فاز V) — Liste = «Alle Wörter»
  // (/wortschatz/list); das frühere Vokabular-Archiv wurde dorthin verschmolzen.
  static const vokabularWortDetail = '/vokabular/wort/:id';

  static String vokabularWort(String id) => '/vokabular/wort/$id';
}
