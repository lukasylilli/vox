// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _germanMeta = const VerificationMeta('german');
  @override
  late final GeneratedColumn<String> german = GeneratedColumn<String>(
    'german',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleMeta = const VerificationMeta(
    'article',
  );
  @override
  late final GeneratedColumn<String> article = GeneratedColumn<String>(
    'article',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pluralMeta = const VerificationMeta('plural');
  @override
  late final GeneratedColumn<String> plural = GeneratedColumn<String>(
    'plural',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordTypeMeta = const VerificationMeta(
    'wordType',
  );
  @override
  late final GeneratedColumn<String> wordType = GeneratedColumn<String>(
    'word_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningFaMeta = const VerificationMeta(
    'meaningFa',
  );
  @override
  late final GeneratedColumn<String> meaningFa = GeneratedColumn<String>(
    'meaning_fa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  @override
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  @override
  late final GeneratedColumn<String> pronunciation = GeneratedColumn<String>(
    'pronunciation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examplesJsonMeta = const VerificationMeta(
    'examplesJson',
  );
  @override
  late final GeneratedColumn<String> examplesJson = GeneratedColumn<String>(
    'examples_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conjugationJsonMeta = const VerificationMeta(
    'conjugationJson',
  );
  @override
  late final GeneratedColumn<String> conjugationJson = GeneratedColumn<String>(
    'conjugation_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etymologyMeta = const VerificationMeta(
    'etymology',
  );
  @override
  late final GeneratedColumn<String> etymology = GeneratedColumn<String>(
    'etymology',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commonErrorsMeta = const VerificationMeta(
    'commonErrors',
  );
  @override
  late final GeneratedColumn<String> commonErrors = GeneratedColumn<String>(
    'common_errors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarNoteMeta = const VerificationMeta(
    'grammarNote',
  );
  @override
  late final GeneratedColumn<String> grammarNote = GeneratedColumn<String>(
    'grammar_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _regelmaessigMeta = const VerificationMeta(
    'regelmaessig',
  );
  @override
  late final GeneratedColumn<bool> regelmaessig = GeneratedColumn<bool>(
    'regelmaessig',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("regelmaessig" IN (0, 1))',
    ),
  );
  static const VerificationMeta _trennbarMeta = const VerificationMeta(
    'trennbar',
  );
  @override
  late final GeneratedColumn<bool> trennbar = GeneratedColumn<bool>(
    'trennbar',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("trennbar" IN (0, 1))',
    ),
  );
  static const VerificationMeta _grammatikDetailMeta = const VerificationMeta(
    'grammatikDetail',
  );
  @override
  late final GeneratedColumn<String> grammatikDetail = GeneratedColumn<String>(
    'grammatik_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ausAppMeta = const VerificationMeta('ausApp');
  @override
  late final GeneratedColumn<bool> ausApp = GeneratedColumn<bool>(
    'aus_app',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aus_app" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    german,
    article,
    plural,
    wordType,
    level,
    meaningFa,
    meaningEn,
    pronunciation,
    examplesJson,
    conjugationJson,
    etymology,
    commonErrors,
    grammarNote,
    createdAt,
    regelmaessig,
    trennbar,
    grammatikDetail,
    ausApp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('german')) {
      context.handle(
        _germanMeta,
        german.isAcceptableOrUnknown(data['german']!, _germanMeta),
      );
    } else if (isInserting) {
      context.missing(_germanMeta);
    }
    if (data.containsKey('article')) {
      context.handle(
        _articleMeta,
        article.isAcceptableOrUnknown(data['article']!, _articleMeta),
      );
    }
    if (data.containsKey('plural')) {
      context.handle(
        _pluralMeta,
        plural.isAcceptableOrUnknown(data['plural']!, _pluralMeta),
      );
    }
    if (data.containsKey('word_type')) {
      context.handle(
        _wordTypeMeta,
        wordType.isAcceptableOrUnknown(data['word_type']!, _wordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_wordTypeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('meaning_fa')) {
      context.handle(
        _meaningFaMeta,
        meaningFa.isAcceptableOrUnknown(data['meaning_fa']!, _meaningFaMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningFaMeta);
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    }
    if (data.containsKey('examples_json')) {
      context.handle(
        _examplesJsonMeta,
        examplesJson.isAcceptableOrUnknown(
          data['examples_json']!,
          _examplesJsonMeta,
        ),
      );
    }
    if (data.containsKey('conjugation_json')) {
      context.handle(
        _conjugationJsonMeta,
        conjugationJson.isAcceptableOrUnknown(
          data['conjugation_json']!,
          _conjugationJsonMeta,
        ),
      );
    }
    if (data.containsKey('etymology')) {
      context.handle(
        _etymologyMeta,
        etymology.isAcceptableOrUnknown(data['etymology']!, _etymologyMeta),
      );
    }
    if (data.containsKey('common_errors')) {
      context.handle(
        _commonErrorsMeta,
        commonErrors.isAcceptableOrUnknown(
          data['common_errors']!,
          _commonErrorsMeta,
        ),
      );
    }
    if (data.containsKey('grammar_note')) {
      context.handle(
        _grammarNoteMeta,
        grammarNote.isAcceptableOrUnknown(
          data['grammar_note']!,
          _grammarNoteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('regelmaessig')) {
      context.handle(
        _regelmaessigMeta,
        regelmaessig.isAcceptableOrUnknown(
          data['regelmaessig']!,
          _regelmaessigMeta,
        ),
      );
    }
    if (data.containsKey('trennbar')) {
      context.handle(
        _trennbarMeta,
        trennbar.isAcceptableOrUnknown(data['trennbar']!, _trennbarMeta),
      );
    }
    if (data.containsKey('grammatik_detail')) {
      context.handle(
        _grammatikDetailMeta,
        grammatikDetail.isAcceptableOrUnknown(
          data['grammatik_detail']!,
          _grammatikDetailMeta,
        ),
      );
    }
    if (data.containsKey('aus_app')) {
      context.handle(
        _ausAppMeta,
        ausApp.isAcceptableOrUnknown(data['aus_app']!, _ausAppMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {german, wordType},
  ];
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      german: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}german'],
      )!,
      article: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article'],
      ),
      plural: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plural'],
      ),
      wordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_type'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      meaningFa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_fa'],
      )!,
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronunciation'],
      ),
      examplesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples_json'],
      ),
      conjugationJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conjugation_json'],
      ),
      etymology: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etymology'],
      ),
      commonErrors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_errors'],
      ),
      grammarNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      regelmaessig: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}regelmaessig'],
      ),
      trennbar: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}trennbar'],
      ),
      grammatikDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammatik_detail'],
      ),
      ausApp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aus_app'],
      ),
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;
  final String german;
  final String? article;
  final String? plural;
  final String wordType;
  final String? level;
  final String meaningFa;
  final String? meaningEn;
  final String? pronunciation;
  final String? examplesJson;
  final String? conjugationJson;
  final String? etymology;
  final String? commonErrors;
  final String? grammarNote;
  final DateTime createdAt;
  final bool? regelmaessig;
  final bool? trennbar;
  final String? grammatikDetail;
  final bool? ausApp;
  const Word({
    required this.id,
    required this.german,
    this.article,
    this.plural,
    required this.wordType,
    this.level,
    required this.meaningFa,
    this.meaningEn,
    this.pronunciation,
    this.examplesJson,
    this.conjugationJson,
    this.etymology,
    this.commonErrors,
    this.grammarNote,
    required this.createdAt,
    this.regelmaessig,
    this.trennbar,
    this.grammatikDetail,
    this.ausApp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['german'] = Variable<String>(german);
    if (!nullToAbsent || article != null) {
      map['article'] = Variable<String>(article);
    }
    if (!nullToAbsent || plural != null) {
      map['plural'] = Variable<String>(plural);
    }
    map['word_type'] = Variable<String>(wordType);
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    map['meaning_fa'] = Variable<String>(meaningFa);
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    if (!nullToAbsent || pronunciation != null) {
      map['pronunciation'] = Variable<String>(pronunciation);
    }
    if (!nullToAbsent || examplesJson != null) {
      map['examples_json'] = Variable<String>(examplesJson);
    }
    if (!nullToAbsent || conjugationJson != null) {
      map['conjugation_json'] = Variable<String>(conjugationJson);
    }
    if (!nullToAbsent || etymology != null) {
      map['etymology'] = Variable<String>(etymology);
    }
    if (!nullToAbsent || commonErrors != null) {
      map['common_errors'] = Variable<String>(commonErrors);
    }
    if (!nullToAbsent || grammarNote != null) {
      map['grammar_note'] = Variable<String>(grammarNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || regelmaessig != null) {
      map['regelmaessig'] = Variable<bool>(regelmaessig);
    }
    if (!nullToAbsent || trennbar != null) {
      map['trennbar'] = Variable<bool>(trennbar);
    }
    if (!nullToAbsent || grammatikDetail != null) {
      map['grammatik_detail'] = Variable<String>(grammatikDetail);
    }
    if (!nullToAbsent || ausApp != null) {
      map['aus_app'] = Variable<bool>(ausApp);
    }
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      german: Value(german),
      article: article == null && nullToAbsent
          ? const Value.absent()
          : Value(article),
      plural: plural == null && nullToAbsent
          ? const Value.absent()
          : Value(plural),
      wordType: Value(wordType),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      meaningFa: Value(meaningFa),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
      pronunciation: pronunciation == null && nullToAbsent
          ? const Value.absent()
          : Value(pronunciation),
      examplesJson: examplesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(examplesJson),
      conjugationJson: conjugationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conjugationJson),
      etymology: etymology == null && nullToAbsent
          ? const Value.absent()
          : Value(etymology),
      commonErrors: commonErrors == null && nullToAbsent
          ? const Value.absent()
          : Value(commonErrors),
      grammarNote: grammarNote == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarNote),
      createdAt: Value(createdAt),
      regelmaessig: regelmaessig == null && nullToAbsent
          ? const Value.absent()
          : Value(regelmaessig),
      trennbar: trennbar == null && nullToAbsent
          ? const Value.absent()
          : Value(trennbar),
      grammatikDetail: grammatikDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(grammatikDetail),
      ausApp: ausApp == null && nullToAbsent
          ? const Value.absent()
          : Value(ausApp),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      german: serializer.fromJson<String>(json['german']),
      article: serializer.fromJson<String?>(json['article']),
      plural: serializer.fromJson<String?>(json['plural']),
      wordType: serializer.fromJson<String>(json['wordType']),
      level: serializer.fromJson<String?>(json['level']),
      meaningFa: serializer.fromJson<String>(json['meaningFa']),
      meaningEn: serializer.fromJson<String?>(json['meaningEn']),
      pronunciation: serializer.fromJson<String?>(json['pronunciation']),
      examplesJson: serializer.fromJson<String?>(json['examplesJson']),
      conjugationJson: serializer.fromJson<String?>(json['conjugationJson']),
      etymology: serializer.fromJson<String?>(json['etymology']),
      commonErrors: serializer.fromJson<String?>(json['commonErrors']),
      grammarNote: serializer.fromJson<String?>(json['grammarNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      regelmaessig: serializer.fromJson<bool?>(json['regelmaessig']),
      trennbar: serializer.fromJson<bool?>(json['trennbar']),
      grammatikDetail: serializer.fromJson<String?>(json['grammatikDetail']),
      ausApp: serializer.fromJson<bool?>(json['ausApp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'german': serializer.toJson<String>(german),
      'article': serializer.toJson<String?>(article),
      'plural': serializer.toJson<String?>(plural),
      'wordType': serializer.toJson<String>(wordType),
      'level': serializer.toJson<String?>(level),
      'meaningFa': serializer.toJson<String>(meaningFa),
      'meaningEn': serializer.toJson<String?>(meaningEn),
      'pronunciation': serializer.toJson<String?>(pronunciation),
      'examplesJson': serializer.toJson<String?>(examplesJson),
      'conjugationJson': serializer.toJson<String?>(conjugationJson),
      'etymology': serializer.toJson<String?>(etymology),
      'commonErrors': serializer.toJson<String?>(commonErrors),
      'grammarNote': serializer.toJson<String?>(grammarNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'regelmaessig': serializer.toJson<bool?>(regelmaessig),
      'trennbar': serializer.toJson<bool?>(trennbar),
      'grammatikDetail': serializer.toJson<String?>(grammatikDetail),
      'ausApp': serializer.toJson<bool?>(ausApp),
    };
  }

  Word copyWith({
    int? id,
    String? german,
    Value<String?> article = const Value.absent(),
    Value<String?> plural = const Value.absent(),
    String? wordType,
    Value<String?> level = const Value.absent(),
    String? meaningFa,
    Value<String?> meaningEn = const Value.absent(),
    Value<String?> pronunciation = const Value.absent(),
    Value<String?> examplesJson = const Value.absent(),
    Value<String?> conjugationJson = const Value.absent(),
    Value<String?> etymology = const Value.absent(),
    Value<String?> commonErrors = const Value.absent(),
    Value<String?> grammarNote = const Value.absent(),
    DateTime? createdAt,
    Value<bool?> regelmaessig = const Value.absent(),
    Value<bool?> trennbar = const Value.absent(),
    Value<String?> grammatikDetail = const Value.absent(),
    Value<bool?> ausApp = const Value.absent(),
  }) => Word(
    id: id ?? this.id,
    german: german ?? this.german,
    article: article.present ? article.value : this.article,
    plural: plural.present ? plural.value : this.plural,
    wordType: wordType ?? this.wordType,
    level: level.present ? level.value : this.level,
    meaningFa: meaningFa ?? this.meaningFa,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
    pronunciation: pronunciation.present
        ? pronunciation.value
        : this.pronunciation,
    examplesJson: examplesJson.present ? examplesJson.value : this.examplesJson,
    conjugationJson: conjugationJson.present
        ? conjugationJson.value
        : this.conjugationJson,
    etymology: etymology.present ? etymology.value : this.etymology,
    commonErrors: commonErrors.present ? commonErrors.value : this.commonErrors,
    grammarNote: grammarNote.present ? grammarNote.value : this.grammarNote,
    createdAt: createdAt ?? this.createdAt,
    regelmaessig: regelmaessig.present ? regelmaessig.value : this.regelmaessig,
    trennbar: trennbar.present ? trennbar.value : this.trennbar,
    grammatikDetail: grammatikDetail.present
        ? grammatikDetail.value
        : this.grammatikDetail,
    ausApp: ausApp.present ? ausApp.value : this.ausApp,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      german: data.german.present ? data.german.value : this.german,
      article: data.article.present ? data.article.value : this.article,
      plural: data.plural.present ? data.plural.value : this.plural,
      wordType: data.wordType.present ? data.wordType.value : this.wordType,
      level: data.level.present ? data.level.value : this.level,
      meaningFa: data.meaningFa.present ? data.meaningFa.value : this.meaningFa,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      examplesJson: data.examplesJson.present
          ? data.examplesJson.value
          : this.examplesJson,
      conjugationJson: data.conjugationJson.present
          ? data.conjugationJson.value
          : this.conjugationJson,
      etymology: data.etymology.present ? data.etymology.value : this.etymology,
      commonErrors: data.commonErrors.present
          ? data.commonErrors.value
          : this.commonErrors,
      grammarNote: data.grammarNote.present
          ? data.grammarNote.value
          : this.grammarNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      regelmaessig: data.regelmaessig.present
          ? data.regelmaessig.value
          : this.regelmaessig,
      trennbar: data.trennbar.present ? data.trennbar.value : this.trennbar,
      grammatikDetail: data.grammatikDetail.present
          ? data.grammatikDetail.value
          : this.grammatikDetail,
      ausApp: data.ausApp.present ? data.ausApp.value : this.ausApp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('german: $german, ')
          ..write('article: $article, ')
          ..write('plural: $plural, ')
          ..write('wordType: $wordType, ')
          ..write('level: $level, ')
          ..write('meaningFa: $meaningFa, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('examplesJson: $examplesJson, ')
          ..write('conjugationJson: $conjugationJson, ')
          ..write('etymology: $etymology, ')
          ..write('commonErrors: $commonErrors, ')
          ..write('grammarNote: $grammarNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('regelmaessig: $regelmaessig, ')
          ..write('trennbar: $trennbar, ')
          ..write('grammatikDetail: $grammatikDetail, ')
          ..write('ausApp: $ausApp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    german,
    article,
    plural,
    wordType,
    level,
    meaningFa,
    meaningEn,
    pronunciation,
    examplesJson,
    conjugationJson,
    etymology,
    commonErrors,
    grammarNote,
    createdAt,
    regelmaessig,
    trennbar,
    grammatikDetail,
    ausApp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.german == this.german &&
          other.article == this.article &&
          other.plural == this.plural &&
          other.wordType == this.wordType &&
          other.level == this.level &&
          other.meaningFa == this.meaningFa &&
          other.meaningEn == this.meaningEn &&
          other.pronunciation == this.pronunciation &&
          other.examplesJson == this.examplesJson &&
          other.conjugationJson == this.conjugationJson &&
          other.etymology == this.etymology &&
          other.commonErrors == this.commonErrors &&
          other.grammarNote == this.grammarNote &&
          other.createdAt == this.createdAt &&
          other.regelmaessig == this.regelmaessig &&
          other.trennbar == this.trennbar &&
          other.grammatikDetail == this.grammatikDetail &&
          other.ausApp == this.ausApp);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> german;
  final Value<String?> article;
  final Value<String?> plural;
  final Value<String> wordType;
  final Value<String?> level;
  final Value<String> meaningFa;
  final Value<String?> meaningEn;
  final Value<String?> pronunciation;
  final Value<String?> examplesJson;
  final Value<String?> conjugationJson;
  final Value<String?> etymology;
  final Value<String?> commonErrors;
  final Value<String?> grammarNote;
  final Value<DateTime> createdAt;
  final Value<bool?> regelmaessig;
  final Value<bool?> trennbar;
  final Value<String?> grammatikDetail;
  final Value<bool?> ausApp;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.german = const Value.absent(),
    this.article = const Value.absent(),
    this.plural = const Value.absent(),
    this.wordType = const Value.absent(),
    this.level = const Value.absent(),
    this.meaningFa = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.examplesJson = const Value.absent(),
    this.conjugationJson = const Value.absent(),
    this.etymology = const Value.absent(),
    this.commonErrors = const Value.absent(),
    this.grammarNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.regelmaessig = const Value.absent(),
    this.trennbar = const Value.absent(),
    this.grammatikDetail = const Value.absent(),
    this.ausApp = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String german,
    this.article = const Value.absent(),
    this.plural = const Value.absent(),
    required String wordType,
    this.level = const Value.absent(),
    required String meaningFa,
    this.meaningEn = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.examplesJson = const Value.absent(),
    this.conjugationJson = const Value.absent(),
    this.etymology = const Value.absent(),
    this.commonErrors = const Value.absent(),
    this.grammarNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.regelmaessig = const Value.absent(),
    this.trennbar = const Value.absent(),
    this.grammatikDetail = const Value.absent(),
    this.ausApp = const Value.absent(),
  }) : german = Value(german),
       wordType = Value(wordType),
       meaningFa = Value(meaningFa);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? german,
    Expression<String>? article,
    Expression<String>? plural,
    Expression<String>? wordType,
    Expression<String>? level,
    Expression<String>? meaningFa,
    Expression<String>? meaningEn,
    Expression<String>? pronunciation,
    Expression<String>? examplesJson,
    Expression<String>? conjugationJson,
    Expression<String>? etymology,
    Expression<String>? commonErrors,
    Expression<String>? grammarNote,
    Expression<DateTime>? createdAt,
    Expression<bool>? regelmaessig,
    Expression<bool>? trennbar,
    Expression<String>? grammatikDetail,
    Expression<bool>? ausApp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (german != null) 'german': german,
      if (article != null) 'article': article,
      if (plural != null) 'plural': plural,
      if (wordType != null) 'word_type': wordType,
      if (level != null) 'level': level,
      if (meaningFa != null) 'meaning_fa': meaningFa,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (examplesJson != null) 'examples_json': examplesJson,
      if (conjugationJson != null) 'conjugation_json': conjugationJson,
      if (etymology != null) 'etymology': etymology,
      if (commonErrors != null) 'common_errors': commonErrors,
      if (grammarNote != null) 'grammar_note': grammarNote,
      if (createdAt != null) 'created_at': createdAt,
      if (regelmaessig != null) 'regelmaessig': regelmaessig,
      if (trennbar != null) 'trennbar': trennbar,
      if (grammatikDetail != null) 'grammatik_detail': grammatikDetail,
      if (ausApp != null) 'aus_app': ausApp,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? german,
    Value<String?>? article,
    Value<String?>? plural,
    Value<String>? wordType,
    Value<String?>? level,
    Value<String>? meaningFa,
    Value<String?>? meaningEn,
    Value<String?>? pronunciation,
    Value<String?>? examplesJson,
    Value<String?>? conjugationJson,
    Value<String?>? etymology,
    Value<String?>? commonErrors,
    Value<String?>? grammarNote,
    Value<DateTime>? createdAt,
    Value<bool?>? regelmaessig,
    Value<bool?>? trennbar,
    Value<String?>? grammatikDetail,
    Value<bool?>? ausApp,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      german: german ?? this.german,
      article: article ?? this.article,
      plural: plural ?? this.plural,
      wordType: wordType ?? this.wordType,
      level: level ?? this.level,
      meaningFa: meaningFa ?? this.meaningFa,
      meaningEn: meaningEn ?? this.meaningEn,
      pronunciation: pronunciation ?? this.pronunciation,
      examplesJson: examplesJson ?? this.examplesJson,
      conjugationJson: conjugationJson ?? this.conjugationJson,
      etymology: etymology ?? this.etymology,
      commonErrors: commonErrors ?? this.commonErrors,
      grammarNote: grammarNote ?? this.grammarNote,
      createdAt: createdAt ?? this.createdAt,
      regelmaessig: regelmaessig ?? this.regelmaessig,
      trennbar: trennbar ?? this.trennbar,
      grammatikDetail: grammatikDetail ?? this.grammatikDetail,
      ausApp: ausApp ?? this.ausApp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (german.present) {
      map['german'] = Variable<String>(german.value);
    }
    if (article.present) {
      map['article'] = Variable<String>(article.value);
    }
    if (plural.present) {
      map['plural'] = Variable<String>(plural.value);
    }
    if (wordType.present) {
      map['word_type'] = Variable<String>(wordType.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (meaningFa.present) {
      map['meaning_fa'] = Variable<String>(meaningFa.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<String>(pronunciation.value);
    }
    if (examplesJson.present) {
      map['examples_json'] = Variable<String>(examplesJson.value);
    }
    if (conjugationJson.present) {
      map['conjugation_json'] = Variable<String>(conjugationJson.value);
    }
    if (etymology.present) {
      map['etymology'] = Variable<String>(etymology.value);
    }
    if (commonErrors.present) {
      map['common_errors'] = Variable<String>(commonErrors.value);
    }
    if (grammarNote.present) {
      map['grammar_note'] = Variable<String>(grammarNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (regelmaessig.present) {
      map['regelmaessig'] = Variable<bool>(regelmaessig.value);
    }
    if (trennbar.present) {
      map['trennbar'] = Variable<bool>(trennbar.value);
    }
    if (grammatikDetail.present) {
      map['grammatik_detail'] = Variable<String>(grammatikDetail.value);
    }
    if (ausApp.present) {
      map['aus_app'] = Variable<bool>(ausApp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('german: $german, ')
          ..write('article: $article, ')
          ..write('plural: $plural, ')
          ..write('wordType: $wordType, ')
          ..write('level: $level, ')
          ..write('meaningFa: $meaningFa, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('examplesJson: $examplesJson, ')
          ..write('conjugationJson: $conjugationJson, ')
          ..write('etymology: $etymology, ')
          ..write('commonErrors: $commonErrors, ')
          ..write('grammarNote: $grammarNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('regelmaessig: $regelmaessig, ')
          ..write('trennbar: $trennbar, ')
          ..write('grammatikDetail: $grammatikDetail, ')
          ..write('ausApp: $ausApp')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String name;
  const Book({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(id: Value(id), name: Value(name));
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Book copyWith({int? id, String? name}) =>
      Book(id: id ?? this.id, name: name ?? this.name);
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book && other.id == this.id && other.name == this.name);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> name;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  BooksCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  BooksCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return BooksCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WordBooksTable extends WordBooks
    with TableInfo<$WordBooksTable, WordBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id)',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [wordId, bookId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordId, bookId};
  @override
  WordBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordBook(
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
    );
  }

  @override
  $WordBooksTable createAlias(String alias) {
    return $WordBooksTable(attachedDatabase, alias);
  }
}

class WordBook extends DataClass implements Insertable<WordBook> {
  final int wordId;
  final int bookId;
  const WordBook({required this.wordId, required this.bookId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_id'] = Variable<int>(wordId);
    map['book_id'] = Variable<int>(bookId);
    return map;
  }

  WordBooksCompanion toCompanion(bool nullToAbsent) {
    return WordBooksCompanion(wordId: Value(wordId), bookId: Value(bookId));
  }

  factory WordBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordBook(
      wordId: serializer.fromJson<int>(json['wordId']),
      bookId: serializer.fromJson<int>(json['bookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordId': serializer.toJson<int>(wordId),
      'bookId': serializer.toJson<int>(bookId),
    };
  }

  WordBook copyWith({int? wordId, int? bookId}) =>
      WordBook(wordId: wordId ?? this.wordId, bookId: bookId ?? this.bookId);
  WordBook copyWithCompanion(WordBooksCompanion data) {
    return WordBook(
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordBook(')
          ..write('wordId: $wordId, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordId, bookId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordBook &&
          other.wordId == this.wordId &&
          other.bookId == this.bookId);
}

class WordBooksCompanion extends UpdateCompanion<WordBook> {
  final Value<int> wordId;
  final Value<int> bookId;
  final Value<int> rowid;
  const WordBooksCompanion({
    this.wordId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordBooksCompanion.insert({
    required int wordId,
    required int bookId,
    this.rowid = const Value.absent(),
  }) : wordId = Value(wordId),
       bookId = Value(bookId);
  static Insertable<WordBook> custom({
    Expression<int>? wordId,
    Expression<int>? bookId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordId != null) 'word_id': wordId,
      if (bookId != null) 'book_id': bookId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordBooksCompanion copyWith({
    Value<int>? wordId,
    Value<int>? bookId,
    Value<int>? rowid,
  }) {
    return WordBooksCompanion(
      wordId: wordId ?? this.wordId,
      bookId: bookId ?? this.bookId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordBooksCompanion(')
          ..write('wordId: $wordId, ')
          ..write('bookId: $bookId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LeitnerFortschrittTable extends LeitnerFortschritt
    with TableInfo<$LeitnerFortschrittTable, LeitnerFortschrittData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeitnerFortschrittTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wortIdMeta = const VerificationMeta('wortId');
  @override
  late final GeneratedColumn<String> wortId = GeneratedColumn<String>(
    'wort_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uebungMeta = const VerificationMeta('uebung');
  @override
  late final GeneratedColumn<String> uebung = GeneratedColumn<String>(
    'uebung',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fachMeta = const VerificationMeta('fach');
  @override
  late final GeneratedColumn<int> fach = GeneratedColumn<int>(
    'fach',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _naechsteWiederholungMeta =
      const VerificationMeta('naechsteWiederholung');
  @override
  late final GeneratedColumn<DateTime> naechsteWiederholung =
      GeneratedColumn<DateTime>(
        'naechste_wiederholung',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _letzteWiederholungMeta =
      const VerificationMeta('letzteWiederholung');
  @override
  late final GeneratedColumn<DateTime> letzteWiederholung =
      GeneratedColumn<DateTime>(
        'letzte_wiederholung',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    wortId,
    uebung,
    fach,
    naechsteWiederholung,
    letzteWiederholung,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leitner_fortschritt';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeitnerFortschrittData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wort_id')) {
      context.handle(
        _wortIdMeta,
        wortId.isAcceptableOrUnknown(data['wort_id']!, _wortIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wortIdMeta);
    }
    if (data.containsKey('uebung')) {
      context.handle(
        _uebungMeta,
        uebung.isAcceptableOrUnknown(data['uebung']!, _uebungMeta),
      );
    } else if (isInserting) {
      context.missing(_uebungMeta);
    }
    if (data.containsKey('fach')) {
      context.handle(
        _fachMeta,
        fach.isAcceptableOrUnknown(data['fach']!, _fachMeta),
      );
    }
    if (data.containsKey('naechste_wiederholung')) {
      context.handle(
        _naechsteWiederholungMeta,
        naechsteWiederholung.isAcceptableOrUnknown(
          data['naechste_wiederholung']!,
          _naechsteWiederholungMeta,
        ),
      );
    }
    if (data.containsKey('letzte_wiederholung')) {
      context.handle(
        _letzteWiederholungMeta,
        letzteWiederholung.isAcceptableOrUnknown(
          data['letzte_wiederholung']!,
          _letzteWiederholungMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wortId, uebung};
  @override
  LeitnerFortschrittData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeitnerFortschrittData(
      wortId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wort_id'],
      )!,
      uebung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uebung'],
      )!,
      fach: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fach'],
      )!,
      naechsteWiederholung: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}naechste_wiederholung'],
      ),
      letzteWiederholung: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}letzte_wiederholung'],
      ),
    );
  }

  @override
  $LeitnerFortschrittTable createAlias(String alias) {
    return $LeitnerFortschrittTable(attachedDatabase, alias);
  }
}

class LeitnerFortschrittData extends DataClass
    implements Insertable<LeitnerFortschrittData> {
  final String wortId;
  final String uebung;
  final int fach;
  final DateTime? naechsteWiederholung;
  final DateTime? letzteWiederholung;
  const LeitnerFortschrittData({
    required this.wortId,
    required this.uebung,
    required this.fach,
    this.naechsteWiederholung,
    this.letzteWiederholung,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wort_id'] = Variable<String>(wortId);
    map['uebung'] = Variable<String>(uebung);
    map['fach'] = Variable<int>(fach);
    if (!nullToAbsent || naechsteWiederholung != null) {
      map['naechste_wiederholung'] = Variable<DateTime>(naechsteWiederholung);
    }
    if (!nullToAbsent || letzteWiederholung != null) {
      map['letzte_wiederholung'] = Variable<DateTime>(letzteWiederholung);
    }
    return map;
  }

  LeitnerFortschrittCompanion toCompanion(bool nullToAbsent) {
    return LeitnerFortschrittCompanion(
      wortId: Value(wortId),
      uebung: Value(uebung),
      fach: Value(fach),
      naechsteWiederholung: naechsteWiederholung == null && nullToAbsent
          ? const Value.absent()
          : Value(naechsteWiederholung),
      letzteWiederholung: letzteWiederholung == null && nullToAbsent
          ? const Value.absent()
          : Value(letzteWiederholung),
    );
  }

  factory LeitnerFortschrittData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeitnerFortschrittData(
      wortId: serializer.fromJson<String>(json['wortId']),
      uebung: serializer.fromJson<String>(json['uebung']),
      fach: serializer.fromJson<int>(json['fach']),
      naechsteWiederholung: serializer.fromJson<DateTime?>(
        json['naechsteWiederholung'],
      ),
      letzteWiederholung: serializer.fromJson<DateTime?>(
        json['letzteWiederholung'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wortId': serializer.toJson<String>(wortId),
      'uebung': serializer.toJson<String>(uebung),
      'fach': serializer.toJson<int>(fach),
      'naechsteWiederholung': serializer.toJson<DateTime?>(
        naechsteWiederholung,
      ),
      'letzteWiederholung': serializer.toJson<DateTime?>(letzteWiederholung),
    };
  }

  LeitnerFortschrittData copyWith({
    String? wortId,
    String? uebung,
    int? fach,
    Value<DateTime?> naechsteWiederholung = const Value.absent(),
    Value<DateTime?> letzteWiederholung = const Value.absent(),
  }) => LeitnerFortschrittData(
    wortId: wortId ?? this.wortId,
    uebung: uebung ?? this.uebung,
    fach: fach ?? this.fach,
    naechsteWiederholung: naechsteWiederholung.present
        ? naechsteWiederholung.value
        : this.naechsteWiederholung,
    letzteWiederholung: letzteWiederholung.present
        ? letzteWiederholung.value
        : this.letzteWiederholung,
  );
  LeitnerFortschrittData copyWithCompanion(LeitnerFortschrittCompanion data) {
    return LeitnerFortschrittData(
      wortId: data.wortId.present ? data.wortId.value : this.wortId,
      uebung: data.uebung.present ? data.uebung.value : this.uebung,
      fach: data.fach.present ? data.fach.value : this.fach,
      naechsteWiederholung: data.naechsteWiederholung.present
          ? data.naechsteWiederholung.value
          : this.naechsteWiederholung,
      letzteWiederholung: data.letzteWiederholung.present
          ? data.letzteWiederholung.value
          : this.letzteWiederholung,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeitnerFortschrittData(')
          ..write('wortId: $wortId, ')
          ..write('uebung: $uebung, ')
          ..write('fach: $fach, ')
          ..write('naechsteWiederholung: $naechsteWiederholung, ')
          ..write('letzteWiederholung: $letzteWiederholung')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    wortId,
    uebung,
    fach,
    naechsteWiederholung,
    letzteWiederholung,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeitnerFortschrittData &&
          other.wortId == this.wortId &&
          other.uebung == this.uebung &&
          other.fach == this.fach &&
          other.naechsteWiederholung == this.naechsteWiederholung &&
          other.letzteWiederholung == this.letzteWiederholung);
}

class LeitnerFortschrittCompanion
    extends UpdateCompanion<LeitnerFortschrittData> {
  final Value<String> wortId;
  final Value<String> uebung;
  final Value<int> fach;
  final Value<DateTime?> naechsteWiederholung;
  final Value<DateTime?> letzteWiederholung;
  final Value<int> rowid;
  const LeitnerFortschrittCompanion({
    this.wortId = const Value.absent(),
    this.uebung = const Value.absent(),
    this.fach = const Value.absent(),
    this.naechsteWiederholung = const Value.absent(),
    this.letzteWiederholung = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LeitnerFortschrittCompanion.insert({
    required String wortId,
    required String uebung,
    this.fach = const Value.absent(),
    this.naechsteWiederholung = const Value.absent(),
    this.letzteWiederholung = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : wortId = Value(wortId),
       uebung = Value(uebung);
  static Insertable<LeitnerFortschrittData> custom({
    Expression<String>? wortId,
    Expression<String>? uebung,
    Expression<int>? fach,
    Expression<DateTime>? naechsteWiederholung,
    Expression<DateTime>? letzteWiederholung,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wortId != null) 'wort_id': wortId,
      if (uebung != null) 'uebung': uebung,
      if (fach != null) 'fach': fach,
      if (naechsteWiederholung != null)
        'naechste_wiederholung': naechsteWiederholung,
      if (letzteWiederholung != null) 'letzte_wiederholung': letzteWiederholung,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LeitnerFortschrittCompanion copyWith({
    Value<String>? wortId,
    Value<String>? uebung,
    Value<int>? fach,
    Value<DateTime?>? naechsteWiederholung,
    Value<DateTime?>? letzteWiederholung,
    Value<int>? rowid,
  }) {
    return LeitnerFortschrittCompanion(
      wortId: wortId ?? this.wortId,
      uebung: uebung ?? this.uebung,
      fach: fach ?? this.fach,
      naechsteWiederholung: naechsteWiederholung ?? this.naechsteWiederholung,
      letzteWiederholung: letzteWiederholung ?? this.letzteWiederholung,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wortId.present) {
      map['wort_id'] = Variable<String>(wortId.value);
    }
    if (uebung.present) {
      map['uebung'] = Variable<String>(uebung.value);
    }
    if (fach.present) {
      map['fach'] = Variable<int>(fach.value);
    }
    if (naechsteWiederholung.present) {
      map['naechste_wiederholung'] = Variable<DateTime>(
        naechsteWiederholung.value,
      );
    }
    if (letzteWiederholung.present) {
      map['letzte_wiederholung'] = Variable<DateTime>(letzteWiederholung.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeitnerFortschrittCompanion(')
          ..write('wortId: $wortId, ')
          ..write('uebung: $uebung, ')
          ..write('fach: $fach, ')
          ..write('naechsteWiederholung: $naechsteWiederholung, ')
          ..write('letzteWiederholung: $letzteWiederholung, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elternIdMeta = const VerificationMeta(
    'elternId',
  );
  @override
  late final GeneratedColumn<String> elternId = GeneratedColumn<String>(
    'eltern_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordnungMeta = const VerificationMeta(
    'ordnung',
  );
  @override
  late final GeneratedColumn<int> ordnung = GeneratedColumn<int>(
    'ordnung',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modusMeta = const VerificationMeta('modus');
  @override
  late final GeneratedColumn<String> modus = GeneratedColumn<String>(
    'modus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(deckModusNotiz),
  );
  static const VerificationMeta _neuProTagMeta = const VerificationMeta(
    'neuProTag',
  );
  @override
  late final GeneratedColumn<int> neuProTag = GeneratedColumn<int>(
    'neu_pro_tag',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameAmMsMeta = const VerificationMeta(
    'nameAmMs',
  );
  @override
  late final GeneratedColumn<int> nameAmMs = GeneratedColumn<int>(
    'name_am_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _standAmMsMeta = const VerificationMeta(
    'standAmMs',
  );
  @override
  late final GeneratedColumn<int> standAmMs = GeneratedColumn<int>(
    'stand_am_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    elternId,
    ordnung,
    modus,
    neuProTag,
    nameAmMs,
    standAmMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('eltern_id')) {
      context.handle(
        _elternIdMeta,
        elternId.isAcceptableOrUnknown(data['eltern_id']!, _elternIdMeta),
      );
    }
    if (data.containsKey('ordnung')) {
      context.handle(
        _ordnungMeta,
        ordnung.isAcceptableOrUnknown(data['ordnung']!, _ordnungMeta),
      );
    }
    if (data.containsKey('modus')) {
      context.handle(
        _modusMeta,
        modus.isAcceptableOrUnknown(data['modus']!, _modusMeta),
      );
    }
    if (data.containsKey('neu_pro_tag')) {
      context.handle(
        _neuProTagMeta,
        neuProTag.isAcceptableOrUnknown(data['neu_pro_tag']!, _neuProTagMeta),
      );
    }
    if (data.containsKey('name_am_ms')) {
      context.handle(
        _nameAmMsMeta,
        nameAmMs.isAcceptableOrUnknown(data['name_am_ms']!, _nameAmMsMeta),
      );
    }
    if (data.containsKey('stand_am_ms')) {
      context.handle(
        _standAmMsMeta,
        standAmMs.isAcceptableOrUnknown(data['stand_am_ms']!, _standAmMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      elternId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eltern_id'],
      ),
      ordnung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordnung'],
      )!,
      modus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modus'],
      )!,
      neuProTag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}neu_pro_tag'],
      ),
      nameAmMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}name_am_ms'],
      ),
      standAmMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stand_am_ms'],
      ),
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final String id;
  final String name;
  final String? elternId;
  final int ordnung;
  final String modus;
  final int? neuProTag;
  final int? nameAmMs;
  final int? standAmMs;
  const Deck({
    required this.id,
    required this.name,
    this.elternId,
    required this.ordnung,
    required this.modus,
    this.neuProTag,
    this.nameAmMs,
    this.standAmMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || elternId != null) {
      map['eltern_id'] = Variable<String>(elternId);
    }
    map['ordnung'] = Variable<int>(ordnung);
    map['modus'] = Variable<String>(modus);
    if (!nullToAbsent || neuProTag != null) {
      map['neu_pro_tag'] = Variable<int>(neuProTag);
    }
    if (!nullToAbsent || nameAmMs != null) {
      map['name_am_ms'] = Variable<int>(nameAmMs);
    }
    if (!nullToAbsent || standAmMs != null) {
      map['stand_am_ms'] = Variable<int>(standAmMs);
    }
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      name: Value(name),
      elternId: elternId == null && nullToAbsent
          ? const Value.absent()
          : Value(elternId),
      ordnung: Value(ordnung),
      modus: Value(modus),
      neuProTag: neuProTag == null && nullToAbsent
          ? const Value.absent()
          : Value(neuProTag),
      nameAmMs: nameAmMs == null && nullToAbsent
          ? const Value.absent()
          : Value(nameAmMs),
      standAmMs: standAmMs == null && nullToAbsent
          ? const Value.absent()
          : Value(standAmMs),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      elternId: serializer.fromJson<String?>(json['elternId']),
      ordnung: serializer.fromJson<int>(json['ordnung']),
      modus: serializer.fromJson<String>(json['modus']),
      neuProTag: serializer.fromJson<int?>(json['neuProTag']),
      nameAmMs: serializer.fromJson<int?>(json['nameAmMs']),
      standAmMs: serializer.fromJson<int?>(json['standAmMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'elternId': serializer.toJson<String?>(elternId),
      'ordnung': serializer.toJson<int>(ordnung),
      'modus': serializer.toJson<String>(modus),
      'neuProTag': serializer.toJson<int?>(neuProTag),
      'nameAmMs': serializer.toJson<int?>(nameAmMs),
      'standAmMs': serializer.toJson<int?>(standAmMs),
    };
  }

  Deck copyWith({
    String? id,
    String? name,
    Value<String?> elternId = const Value.absent(),
    int? ordnung,
    String? modus,
    Value<int?> neuProTag = const Value.absent(),
    Value<int?> nameAmMs = const Value.absent(),
    Value<int?> standAmMs = const Value.absent(),
  }) => Deck(
    id: id ?? this.id,
    name: name ?? this.name,
    elternId: elternId.present ? elternId.value : this.elternId,
    ordnung: ordnung ?? this.ordnung,
    modus: modus ?? this.modus,
    neuProTag: neuProTag.present ? neuProTag.value : this.neuProTag,
    nameAmMs: nameAmMs.present ? nameAmMs.value : this.nameAmMs,
    standAmMs: standAmMs.present ? standAmMs.value : this.standAmMs,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      elternId: data.elternId.present ? data.elternId.value : this.elternId,
      ordnung: data.ordnung.present ? data.ordnung.value : this.ordnung,
      modus: data.modus.present ? data.modus.value : this.modus,
      neuProTag: data.neuProTag.present ? data.neuProTag.value : this.neuProTag,
      nameAmMs: data.nameAmMs.present ? data.nameAmMs.value : this.nameAmMs,
      standAmMs: data.standAmMs.present ? data.standAmMs.value : this.standAmMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('elternId: $elternId, ')
          ..write('ordnung: $ordnung, ')
          ..write('modus: $modus, ')
          ..write('neuProTag: $neuProTag, ')
          ..write('nameAmMs: $nameAmMs, ')
          ..write('standAmMs: $standAmMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    elternId,
    ordnung,
    modus,
    neuProTag,
    nameAmMs,
    standAmMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.name == this.name &&
          other.elternId == this.elternId &&
          other.ordnung == this.ordnung &&
          other.modus == this.modus &&
          other.neuProTag == this.neuProTag &&
          other.nameAmMs == this.nameAmMs &&
          other.standAmMs == this.standAmMs);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> elternId;
  final Value<int> ordnung;
  final Value<String> modus;
  final Value<int?> neuProTag;
  final Value<int?> nameAmMs;
  final Value<int?> standAmMs;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.elternId = const Value.absent(),
    this.ordnung = const Value.absent(),
    this.modus = const Value.absent(),
    this.neuProTag = const Value.absent(),
    this.nameAmMs = const Value.absent(),
    this.standAmMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String name,
    this.elternId = const Value.absent(),
    this.ordnung = const Value.absent(),
    this.modus = const Value.absent(),
    this.neuProTag = const Value.absent(),
    this.nameAmMs = const Value.absent(),
    this.standAmMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Deck> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? elternId,
    Expression<int>? ordnung,
    Expression<String>? modus,
    Expression<int>? neuProTag,
    Expression<int>? nameAmMs,
    Expression<int>? standAmMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (elternId != null) 'eltern_id': elternId,
      if (ordnung != null) 'ordnung': ordnung,
      if (modus != null) 'modus': modus,
      if (neuProTag != null) 'neu_pro_tag': neuProTag,
      if (nameAmMs != null) 'name_am_ms': nameAmMs,
      if (standAmMs != null) 'stand_am_ms': standAmMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? elternId,
    Value<int>? ordnung,
    Value<String>? modus,
    Value<int?>? neuProTag,
    Value<int?>? nameAmMs,
    Value<int?>? standAmMs,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      elternId: elternId ?? this.elternId,
      ordnung: ordnung ?? this.ordnung,
      modus: modus ?? this.modus,
      neuProTag: neuProTag ?? this.neuProTag,
      nameAmMs: nameAmMs ?? this.nameAmMs,
      standAmMs: standAmMs ?? this.standAmMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (elternId.present) {
      map['eltern_id'] = Variable<String>(elternId.value);
    }
    if (ordnung.present) {
      map['ordnung'] = Variable<int>(ordnung.value);
    }
    if (modus.present) {
      map['modus'] = Variable<String>(modus.value);
    }
    if (neuProTag.present) {
      map['neu_pro_tag'] = Variable<int>(neuProTag.value);
    }
    if (nameAmMs.present) {
      map['name_am_ms'] = Variable<int>(nameAmMs.value);
    }
    if (standAmMs.present) {
      map['stand_am_ms'] = Variable<int>(standAmMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('elternId: $elternId, ')
          ..write('ordnung: $ordnung, ')
          ..write('modus: $modus, ')
          ..write('neuProTag: $neuProTag, ')
          ..write('nameAmMs: $nameAmMs, ')
          ..write('standAmMs: $standAmMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeckWoerterTable extends DeckWoerter
    with TableInfo<$DeckWoerterTable, DeckWoerterData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckWoerterTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id)',
    ),
  );
  static const VerificationMeta _wortIdMeta = const VerificationMeta('wortId');
  @override
  late final GeneratedColumn<String> wortId = GeneratedColumn<String>(
    'wort_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hinzuMsMeta = const VerificationMeta(
    'hinzuMs',
  );
  @override
  late final GeneratedColumn<int> hinzuMs = GeneratedColumn<int>(
    'hinzu_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [deckId, wortId, hinzuMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_woerter';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckWoerterData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('wort_id')) {
      context.handle(
        _wortIdMeta,
        wortId.isAcceptableOrUnknown(data['wort_id']!, _wortIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wortIdMeta);
    }
    if (data.containsKey('hinzu_ms')) {
      context.handle(
        _hinzuMsMeta,
        hinzuMs.isAcceptableOrUnknown(data['hinzu_ms']!, _hinzuMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deckId, wortId};
  @override
  DeckWoerterData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckWoerterData(
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      wortId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wort_id'],
      )!,
      hinzuMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hinzu_ms'],
      )!,
    );
  }

  @override
  $DeckWoerterTable createAlias(String alias) {
    return $DeckWoerterTable(attachedDatabase, alias);
  }
}

class DeckWoerterData extends DataClass implements Insertable<DeckWoerterData> {
  final String deckId;
  final String wortId;
  final int hinzuMs;
  const DeckWoerterData({
    required this.deckId,
    required this.wortId,
    required this.hinzuMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deck_id'] = Variable<String>(deckId);
    map['wort_id'] = Variable<String>(wortId);
    map['hinzu_ms'] = Variable<int>(hinzuMs);
    return map;
  }

  DeckWoerterCompanion toCompanion(bool nullToAbsent) {
    return DeckWoerterCompanion(
      deckId: Value(deckId),
      wortId: Value(wortId),
      hinzuMs: Value(hinzuMs),
    );
  }

  factory DeckWoerterData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckWoerterData(
      deckId: serializer.fromJson<String>(json['deckId']),
      wortId: serializer.fromJson<String>(json['wortId']),
      hinzuMs: serializer.fromJson<int>(json['hinzuMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deckId': serializer.toJson<String>(deckId),
      'wortId': serializer.toJson<String>(wortId),
      'hinzuMs': serializer.toJson<int>(hinzuMs),
    };
  }

  DeckWoerterData copyWith({String? deckId, String? wortId, int? hinzuMs}) =>
      DeckWoerterData(
        deckId: deckId ?? this.deckId,
        wortId: wortId ?? this.wortId,
        hinzuMs: hinzuMs ?? this.hinzuMs,
      );
  DeckWoerterData copyWithCompanion(DeckWoerterCompanion data) {
    return DeckWoerterData(
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      wortId: data.wortId.present ? data.wortId.value : this.wortId,
      hinzuMs: data.hinzuMs.present ? data.hinzuMs.value : this.hinzuMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckWoerterData(')
          ..write('deckId: $deckId, ')
          ..write('wortId: $wortId, ')
          ..write('hinzuMs: $hinzuMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deckId, wortId, hinzuMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckWoerterData &&
          other.deckId == this.deckId &&
          other.wortId == this.wortId &&
          other.hinzuMs == this.hinzuMs);
}

class DeckWoerterCompanion extends UpdateCompanion<DeckWoerterData> {
  final Value<String> deckId;
  final Value<String> wortId;
  final Value<int> hinzuMs;
  final Value<int> rowid;
  const DeckWoerterCompanion({
    this.deckId = const Value.absent(),
    this.wortId = const Value.absent(),
    this.hinzuMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckWoerterCompanion.insert({
    required String deckId,
    required String wortId,
    this.hinzuMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deckId = Value(deckId),
       wortId = Value(wortId);
  static Insertable<DeckWoerterData> custom({
    Expression<String>? deckId,
    Expression<String>? wortId,
    Expression<int>? hinzuMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deckId != null) 'deck_id': deckId,
      if (wortId != null) 'wort_id': wortId,
      if (hinzuMs != null) 'hinzu_ms': hinzuMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckWoerterCompanion copyWith({
    Value<String>? deckId,
    Value<String>? wortId,
    Value<int>? hinzuMs,
    Value<int>? rowid,
  }) {
    return DeckWoerterCompanion(
      deckId: deckId ?? this.deckId,
      wortId: wortId ?? this.wortId,
      hinzuMs: hinzuMs ?? this.hinzuMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (wortId.present) {
      map['wort_id'] = Variable<String>(wortId.value);
    }
    if (hinzuMs.present) {
      map['hinzu_ms'] = Variable<int>(hinzuMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckWoerterCompanion(')
          ..write('deckId: $deckId, ')
          ..write('wortId: $wortId, ')
          ..write('hinzuMs: $hinzuMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MitgliedschaftenTable extends Mitgliedschaften
    with TableInfo<$MitgliedschaftenTable, MitgliedschaftenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MitgliedschaftenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
    'art',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schluesselMeta = const VerificationMeta(
    'schluessel',
  );
  @override
  late final GeneratedColumn<String> schluessel = GeneratedColumn<String>(
    'schluessel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wortMeta = const VerificationMeta('wort');
  @override
  late final GeneratedColumn<String> wort = GeneratedColumn<String>(
    'wort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _drinMeta = const VerificationMeta('drin');
  @override
  late final GeneratedColumn<bool> drin = GeneratedColumn<bool>(
    'drin',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("drin" IN (0, 1))',
    ),
  );
  static const VerificationMeta _amMsMeta = const VerificationMeta('amMs');
  @override
  late final GeneratedColumn<int> amMs = GeneratedColumn<int>(
    'am_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [art, schluessel, wort, drin, amMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mitgliedschaften';
  @override
  VerificationContext validateIntegrity(
    Insertable<MitgliedschaftenData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('art')) {
      context.handle(
        _artMeta,
        art.isAcceptableOrUnknown(data['art']!, _artMeta),
      );
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    if (data.containsKey('schluessel')) {
      context.handle(
        _schluesselMeta,
        schluessel.isAcceptableOrUnknown(data['schluessel']!, _schluesselMeta),
      );
    } else if (isInserting) {
      context.missing(_schluesselMeta);
    }
    if (data.containsKey('wort')) {
      context.handle(
        _wortMeta,
        wort.isAcceptableOrUnknown(data['wort']!, _wortMeta),
      );
    }
    if (data.containsKey('drin')) {
      context.handle(
        _drinMeta,
        drin.isAcceptableOrUnknown(data['drin']!, _drinMeta),
      );
    } else if (isInserting) {
      context.missing(_drinMeta);
    }
    if (data.containsKey('am_ms')) {
      context.handle(
        _amMsMeta,
        amMs.isAcceptableOrUnknown(data['am_ms']!, _amMsMeta),
      );
    } else if (isInserting) {
      context.missing(_amMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {art, schluessel, wort};
  @override
  MitgliedschaftenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MitgliedschaftenData(
      art: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art'],
      )!,
      schluessel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schluessel'],
      )!,
      wort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wort'],
      )!,
      drin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}drin'],
      )!,
      amMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}am_ms'],
      )!,
    );
  }

  @override
  $MitgliedschaftenTable createAlias(String alias) {
    return $MitgliedschaftenTable(attachedDatabase, alias);
  }
}

class MitgliedschaftenData extends DataClass
    implements Insertable<MitgliedschaftenData> {
  final String art;
  final String schluessel;
  final String wort;
  final bool drin;
  final int amMs;
  const MitgliedschaftenData({
    required this.art,
    required this.schluessel,
    required this.wort,
    required this.drin,
    required this.amMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['art'] = Variable<String>(art);
    map['schluessel'] = Variable<String>(schluessel);
    map['wort'] = Variable<String>(wort);
    map['drin'] = Variable<bool>(drin);
    map['am_ms'] = Variable<int>(amMs);
    return map;
  }

  MitgliedschaftenCompanion toCompanion(bool nullToAbsent) {
    return MitgliedschaftenCompanion(
      art: Value(art),
      schluessel: Value(schluessel),
      wort: Value(wort),
      drin: Value(drin),
      amMs: Value(amMs),
    );
  }

  factory MitgliedschaftenData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MitgliedschaftenData(
      art: serializer.fromJson<String>(json['art']),
      schluessel: serializer.fromJson<String>(json['schluessel']),
      wort: serializer.fromJson<String>(json['wort']),
      drin: serializer.fromJson<bool>(json['drin']),
      amMs: serializer.fromJson<int>(json['amMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'art': serializer.toJson<String>(art),
      'schluessel': serializer.toJson<String>(schluessel),
      'wort': serializer.toJson<String>(wort),
      'drin': serializer.toJson<bool>(drin),
      'amMs': serializer.toJson<int>(amMs),
    };
  }

  MitgliedschaftenData copyWith({
    String? art,
    String? schluessel,
    String? wort,
    bool? drin,
    int? amMs,
  }) => MitgliedschaftenData(
    art: art ?? this.art,
    schluessel: schluessel ?? this.schluessel,
    wort: wort ?? this.wort,
    drin: drin ?? this.drin,
    amMs: amMs ?? this.amMs,
  );
  MitgliedschaftenData copyWithCompanion(MitgliedschaftenCompanion data) {
    return MitgliedschaftenData(
      art: data.art.present ? data.art.value : this.art,
      schluessel: data.schluessel.present
          ? data.schluessel.value
          : this.schluessel,
      wort: data.wort.present ? data.wort.value : this.wort,
      drin: data.drin.present ? data.drin.value : this.drin,
      amMs: data.amMs.present ? data.amMs.value : this.amMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MitgliedschaftenData(')
          ..write('art: $art, ')
          ..write('schluessel: $schluessel, ')
          ..write('wort: $wort, ')
          ..write('drin: $drin, ')
          ..write('amMs: $amMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(art, schluessel, wort, drin, amMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MitgliedschaftenData &&
          other.art == this.art &&
          other.schluessel == this.schluessel &&
          other.wort == this.wort &&
          other.drin == this.drin &&
          other.amMs == this.amMs);
}

class MitgliedschaftenCompanion extends UpdateCompanion<MitgliedschaftenData> {
  final Value<String> art;
  final Value<String> schluessel;
  final Value<String> wort;
  final Value<bool> drin;
  final Value<int> amMs;
  final Value<int> rowid;
  const MitgliedschaftenCompanion({
    this.art = const Value.absent(),
    this.schluessel = const Value.absent(),
    this.wort = const Value.absent(),
    this.drin = const Value.absent(),
    this.amMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MitgliedschaftenCompanion.insert({
    required String art,
    required String schluessel,
    this.wort = const Value.absent(),
    required bool drin,
    required int amMs,
    this.rowid = const Value.absent(),
  }) : art = Value(art),
       schluessel = Value(schluessel),
       drin = Value(drin),
       amMs = Value(amMs);
  static Insertable<MitgliedschaftenData> custom({
    Expression<String>? art,
    Expression<String>? schluessel,
    Expression<String>? wort,
    Expression<bool>? drin,
    Expression<int>? amMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (art != null) 'art': art,
      if (schluessel != null) 'schluessel': schluessel,
      if (wort != null) 'wort': wort,
      if (drin != null) 'drin': drin,
      if (amMs != null) 'am_ms': amMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MitgliedschaftenCompanion copyWith({
    Value<String>? art,
    Value<String>? schluessel,
    Value<String>? wort,
    Value<bool>? drin,
    Value<int>? amMs,
    Value<int>? rowid,
  }) {
    return MitgliedschaftenCompanion(
      art: art ?? this.art,
      schluessel: schluessel ?? this.schluessel,
      wort: wort ?? this.wort,
      drin: drin ?? this.drin,
      amMs: amMs ?? this.amMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (schluessel.present) {
      map['schluessel'] = Variable<String>(schluessel.value);
    }
    if (wort.present) {
      map['wort'] = Variable<String>(wort.value);
    }
    if (drin.present) {
      map['drin'] = Variable<bool>(drin.value);
    }
    if (amMs.present) {
      map['am_ms'] = Variable<int>(amMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MitgliedschaftenCompanion(')
          ..write('art: $art, ')
          ..write('schluessel: $schluessel, ')
          ..write('wort: $wort, ')
          ..write('drin: $drin, ')
          ..write('amMs: $amMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrammarLessonsTable extends GrammarLessons
    with TableInfo<$GrammarLessonsTable, GrammarLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarLessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, level, content, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarLesson> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarLesson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GrammarLessonsTable createAlias(String alias) {
    return $GrammarLessonsTable(attachedDatabase, alias);
  }
}

class GrammarLesson extends DataClass implements Insertable<GrammarLesson> {
  final int id;
  final String title;
  final String level;
  final String content;
  final int sortOrder;
  const GrammarLesson({
    required this.id,
    required this.title,
    required this.level,
    required this.content,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['level'] = Variable<String>(level);
    map['content'] = Variable<String>(content);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GrammarLessonsCompanion toCompanion(bool nullToAbsent) {
    return GrammarLessonsCompanion(
      id: Value(id),
      title: Value(title),
      level: Value(level),
      content: Value(content),
      sortOrder: Value(sortOrder),
    );
  }

  factory GrammarLesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarLesson(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      level: serializer.fromJson<String>(json['level']),
      content: serializer.fromJson<String>(json['content']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'level': serializer.toJson<String>(level),
      'content': serializer.toJson<String>(content),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  GrammarLesson copyWith({
    int? id,
    String? title,
    String? level,
    String? content,
    int? sortOrder,
  }) => GrammarLesson(
    id: id ?? this.id,
    title: title ?? this.title,
    level: level ?? this.level,
    content: content ?? this.content,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  GrammarLesson copyWithCompanion(GrammarLessonsCompanion data) {
    return GrammarLesson(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      level: data.level.present ? data.level.value : this.level,
      content: data.content.present ? data.content.value : this.content,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarLesson(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, level, content, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarLesson &&
          other.id == this.id &&
          other.title == this.title &&
          other.level == this.level &&
          other.content == this.content &&
          other.sortOrder == this.sortOrder);
}

class GrammarLessonsCompanion extends UpdateCompanion<GrammarLesson> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> level;
  final Value<String> content;
  final Value<int> sortOrder;
  const GrammarLessonsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.level = const Value.absent(),
    this.content = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  GrammarLessonsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String level,
    required String content,
    this.sortOrder = const Value.absent(),
  }) : title = Value(title),
       level = Value(level),
       content = Value(content);
  static Insertable<GrammarLesson> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? level,
    Expression<String>? content,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (level != null) 'level': level,
      if (content != null) 'content': content,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  GrammarLessonsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? level,
    Value<String>? content,
    Value<int>? sortOrder,
  }) {
    return GrammarLessonsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      content: content ?? this.content,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarLessonsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MemorizeItemsTable extends MemorizeItems
    with TableInfo<$MemorizeItemsTable, MemorizeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemorizeItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phraseMeta = const VerificationMeta('phrase');
  @override
  late final GeneratedColumn<String> phrase = GeneratedColumn<String>(
    'phrase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  @override
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _examplesJsonMeta = const VerificationMeta(
    'examplesJson',
  );
  @override
  late final GeneratedColumn<String> examplesJson = GeneratedColumn<String>(
    'examples_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    phrase,
    meaning,
    meaningEn,
    level,
    examplesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memorize_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemorizeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('phrase')) {
      context.handle(
        _phraseMeta,
        phrase.isAcceptableOrUnknown(data['phrase']!, _phraseMeta),
      );
    } else if (isInserting) {
      context.missing(_phraseMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('examples_json')) {
      context.handle(
        _examplesJsonMeta,
        examplesJson.isAcceptableOrUnknown(
          data['examples_json']!,
          _examplesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemorizeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemorizeItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      phrase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phrase'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      examplesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples_json'],
      ),
    );
  }

  @override
  $MemorizeItemsTable createAlias(String alias) {
    return $MemorizeItemsTable(attachedDatabase, alias);
  }
}

class MemorizeItem extends DataClass implements Insertable<MemorizeItem> {
  final int id;
  final String category;
  final String phrase;
  final String meaning;
  final String? meaningEn;
  final String? level;
  final String? examplesJson;
  const MemorizeItem({
    required this.id,
    required this.category,
    required this.phrase,
    required this.meaning,
    this.meaningEn,
    this.level,
    this.examplesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['phrase'] = Variable<String>(phrase);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    if (!nullToAbsent || examplesJson != null) {
      map['examples_json'] = Variable<String>(examplesJson);
    }
    return map;
  }

  MemorizeItemsCompanion toCompanion(bool nullToAbsent) {
    return MemorizeItemsCompanion(
      id: Value(id),
      category: Value(category),
      phrase: Value(phrase),
      meaning: Value(meaning),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      examplesJson: examplesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(examplesJson),
    );
  }

  factory MemorizeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemorizeItem(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      phrase: serializer.fromJson<String>(json['phrase']),
      meaning: serializer.fromJson<String>(json['meaning']),
      meaningEn: serializer.fromJson<String?>(json['meaningEn']),
      level: serializer.fromJson<String?>(json['level']),
      examplesJson: serializer.fromJson<String?>(json['examplesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'phrase': serializer.toJson<String>(phrase),
      'meaning': serializer.toJson<String>(meaning),
      'meaningEn': serializer.toJson<String?>(meaningEn),
      'level': serializer.toJson<String?>(level),
      'examplesJson': serializer.toJson<String?>(examplesJson),
    };
  }

  MemorizeItem copyWith({
    int? id,
    String? category,
    String? phrase,
    String? meaning,
    Value<String?> meaningEn = const Value.absent(),
    Value<String?> level = const Value.absent(),
    Value<String?> examplesJson = const Value.absent(),
  }) => MemorizeItem(
    id: id ?? this.id,
    category: category ?? this.category,
    phrase: phrase ?? this.phrase,
    meaning: meaning ?? this.meaning,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
    level: level.present ? level.value : this.level,
    examplesJson: examplesJson.present ? examplesJson.value : this.examplesJson,
  );
  MemorizeItem copyWithCompanion(MemorizeItemsCompanion data) {
    return MemorizeItem(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      phrase: data.phrase.present ? data.phrase.value : this.phrase,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
      level: data.level.present ? data.level.value : this.level,
      examplesJson: data.examplesJson.present
          ? data.examplesJson.value
          : this.examplesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemorizeItem(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('phrase: $phrase, ')
          ..write('meaning: $meaning, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('level: $level, ')
          ..write('examplesJson: $examplesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    phrase,
    meaning,
    meaningEn,
    level,
    examplesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemorizeItem &&
          other.id == this.id &&
          other.category == this.category &&
          other.phrase == this.phrase &&
          other.meaning == this.meaning &&
          other.meaningEn == this.meaningEn &&
          other.level == this.level &&
          other.examplesJson == this.examplesJson);
}

class MemorizeItemsCompanion extends UpdateCompanion<MemorizeItem> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> phrase;
  final Value<String> meaning;
  final Value<String?> meaningEn;
  final Value<String?> level;
  final Value<String?> examplesJson;
  const MemorizeItemsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.phrase = const Value.absent(),
    this.meaning = const Value.absent(),
    this.meaningEn = const Value.absent(),
    this.level = const Value.absent(),
    this.examplesJson = const Value.absent(),
  });
  MemorizeItemsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String phrase,
    required String meaning,
    this.meaningEn = const Value.absent(),
    this.level = const Value.absent(),
    this.examplesJson = const Value.absent(),
  }) : category = Value(category),
       phrase = Value(phrase),
       meaning = Value(meaning);
  static Insertable<MemorizeItem> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? phrase,
    Expression<String>? meaning,
    Expression<String>? meaningEn,
    Expression<String>? level,
    Expression<String>? examplesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (phrase != null) 'phrase': phrase,
      if (meaning != null) 'meaning': meaning,
      if (meaningEn != null) 'meaning_en': meaningEn,
      if (level != null) 'level': level,
      if (examplesJson != null) 'examples_json': examplesJson,
    });
  }

  MemorizeItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? phrase,
    Value<String>? meaning,
    Value<String?>? meaningEn,
    Value<String?>? level,
    Value<String?>? examplesJson,
  }) {
    return MemorizeItemsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      phrase: phrase ?? this.phrase,
      meaning: meaning ?? this.meaning,
      meaningEn: meaningEn ?? this.meaningEn,
      level: level ?? this.level,
      examplesJson: examplesJson ?? this.examplesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (phrase.present) {
      map['phrase'] = Variable<String>(phrase.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (examplesJson.present) {
      map['examples_json'] = Variable<String>(examplesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemorizeItemsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('phrase: $phrase, ')
          ..write('meaning: $meaning, ')
          ..write('meaningEn: $meaningEn, ')
          ..write('level: $level, ')
          ..write('examplesJson: $examplesJson')
          ..write(')'))
        .toString();
  }
}

class $ReadingTextsTable extends ReadingTexts
    with TableInfo<$ReadingTextsTable, ReadingText> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    level,
    content,
    audioPath,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_texts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingText> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingText map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingText(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $ReadingTextsTable createAlias(String alias) {
    return $ReadingTextsTable(attachedDatabase, alias);
  }
}

class ReadingText extends DataClass implements Insertable<ReadingText> {
  final int id;
  final String title;
  final String level;
  final String content;
  final String? audioPath;
  final DateTime addedAt;
  const ReadingText({
    required this.id,
    required this.title,
    required this.level,
    required this.content,
    this.audioPath,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['level'] = Variable<String>(level);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ReadingTextsCompanion toCompanion(bool nullToAbsent) {
    return ReadingTextsCompanion(
      id: Value(id),
      title: Value(title),
      level: Value(level),
      content: Value(content),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      addedAt: Value(addedAt),
    );
  }

  factory ReadingText.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingText(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      level: serializer.fromJson<String>(json['level']),
      content: serializer.fromJson<String>(json['content']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'level': serializer.toJson<String>(level),
      'content': serializer.toJson<String>(content),
      'audioPath': serializer.toJson<String?>(audioPath),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ReadingText copyWith({
    int? id,
    String? title,
    String? level,
    String? content,
    Value<String?> audioPath = const Value.absent(),
    DateTime? addedAt,
  }) => ReadingText(
    id: id ?? this.id,
    title: title ?? this.title,
    level: level ?? this.level,
    content: content ?? this.content,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    addedAt: addedAt ?? this.addedAt,
  );
  ReadingText copyWithCompanion(ReadingTextsCompanion data) {
    return ReadingText(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      level: data.level.present ? data.level.value : this.level,
      content: data.content.present ? data.content.value : this.content,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingText(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('content: $content, ')
          ..write('audioPath: $audioPath, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, level, content, audioPath, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingText &&
          other.id == this.id &&
          other.title == this.title &&
          other.level == this.level &&
          other.content == this.content &&
          other.audioPath == this.audioPath &&
          other.addedAt == this.addedAt);
}

class ReadingTextsCompanion extends UpdateCompanion<ReadingText> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> level;
  final Value<String> content;
  final Value<String?> audioPath;
  final Value<DateTime> addedAt;
  const ReadingTextsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.level = const Value.absent(),
    this.content = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  ReadingTextsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String level,
    required String content,
    this.audioPath = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : title = Value(title),
       level = Value(level),
       content = Value(content);
  static Insertable<ReadingText> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? level,
    Expression<String>? content,
    Expression<String>? audioPath,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (level != null) 'level': level,
      if (content != null) 'content': content,
      if (audioPath != null) 'audio_path': audioPath,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  ReadingTextsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? level,
    Value<String>? content,
    Value<String?>? audioPath,
    Value<DateTime>? addedAt,
  }) {
    return ReadingTextsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      content: content ?? this.content,
      audioPath: audioPath ?? this.audioPath,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingTextsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('content: $content, ')
          ..write('audioPath: $audioPath, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $AudioItemsTable extends AudioItems
    with TableInfo<$AudioItemsTable, AudioItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    level,
    audioPath,
    transcript,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    } else if (isInserting) {
      context.missing(_audioPathMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      )!,
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
    );
  }

  @override
  $AudioItemsTable createAlias(String alias) {
    return $AudioItemsTable(attachedDatabase, alias);
  }
}

class AudioItem extends DataClass implements Insertable<AudioItem> {
  final int id;
  final String title;
  final String level;
  final String audioPath;
  final String? transcript;
  const AudioItem({
    required this.id,
    required this.title,
    required this.level,
    required this.audioPath,
    this.transcript,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['level'] = Variable<String>(level);
    map['audio_path'] = Variable<String>(audioPath);
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    return map;
  }

  AudioItemsCompanion toCompanion(bool nullToAbsent) {
    return AudioItemsCompanion(
      id: Value(id),
      title: Value(title),
      level: Value(level),
      audioPath: Value(audioPath),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
    );
  }

  factory AudioItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioItem(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      level: serializer.fromJson<String>(json['level']),
      audioPath: serializer.fromJson<String>(json['audioPath']),
      transcript: serializer.fromJson<String?>(json['transcript']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'level': serializer.toJson<String>(level),
      'audioPath': serializer.toJson<String>(audioPath),
      'transcript': serializer.toJson<String?>(transcript),
    };
  }

  AudioItem copyWith({
    int? id,
    String? title,
    String? level,
    String? audioPath,
    Value<String?> transcript = const Value.absent(),
  }) => AudioItem(
    id: id ?? this.id,
    title: title ?? this.title,
    level: level ?? this.level,
    audioPath: audioPath ?? this.audioPath,
    transcript: transcript.present ? transcript.value : this.transcript,
  );
  AudioItem copyWithCompanion(AudioItemsCompanion data) {
    return AudioItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      level: data.level.present ? data.level.value : this.level,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('audioPath: $audioPath, ')
          ..write('transcript: $transcript')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, level, audioPath, transcript);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.level == this.level &&
          other.audioPath == this.audioPath &&
          other.transcript == this.transcript);
}

class AudioItemsCompanion extends UpdateCompanion<AudioItem> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> level;
  final Value<String> audioPath;
  final Value<String?> transcript;
  const AudioItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.level = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.transcript = const Value.absent(),
  });
  AudioItemsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String level,
    required String audioPath,
    this.transcript = const Value.absent(),
  }) : title = Value(title),
       level = Value(level),
       audioPath = Value(audioPath);
  static Insertable<AudioItem> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? level,
    Expression<String>? audioPath,
    Expression<String>? transcript,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (level != null) 'level': level,
      if (audioPath != null) 'audio_path': audioPath,
      if (transcript != null) 'transcript': transcript,
    });
  }

  AudioItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? level,
    Value<String>? audioPath,
    Value<String?>? transcript,
  }) {
    return AudioItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      audioPath: audioPath ?? this.audioPath,
      transcript: transcript ?? this.transcript,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('audioPath: $audioPath, ')
          ..write('transcript: $transcript')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysJsonMeta = const VerificationMeta(
    'daysJson',
  );
  @override
  late final GeneratedColumn<String> daysJson = GeneratedColumn<String>(
    'days_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftMeta = const VerificationMeta('shift');
  @override
  late final GeneratedColumn<String> shift = GeneratedColumn<String>(
    'shift',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakCountMeta = const VerificationMeta(
    'streakCount',
  );
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
    'streak_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    daysJson,
    shift,
    streakCount,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('days_json')) {
      context.handle(
        _daysJsonMeta,
        daysJson.isAcceptableOrUnknown(data['days_json']!, _daysJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_daysJsonMeta);
    }
    if (data.containsKey('shift')) {
      context.handle(
        _shiftMeta,
        shift.isAcceptableOrUnknown(data['shift']!, _shiftMeta),
      );
    } else if (isInserting) {
      context.missing(_shiftMeta);
    }
    if (data.containsKey('streak_count')) {
      context.handle(
        _streakCountMeta,
        streakCount.isAcceptableOrUnknown(
          data['streak_count']!,
          _streakCountMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      daysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_json'],
      )!,
      shift: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift'],
      )!,
      streakCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_count'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final String daysJson;
  final String shift;
  final int streakCount;
  final bool isActive;
  const Habit({
    required this.id,
    required this.name,
    required this.daysJson,
    required this.shift,
    required this.streakCount,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['days_json'] = Variable<String>(daysJson);
    map['shift'] = Variable<String>(shift);
    map['streak_count'] = Variable<int>(streakCount);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      daysJson: Value(daysJson),
      shift: Value(shift),
      streakCount: Value(streakCount),
      isActive: Value(isActive),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      daysJson: serializer.fromJson<String>(json['daysJson']),
      shift: serializer.fromJson<String>(json['shift']),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'daysJson': serializer.toJson<String>(daysJson),
      'shift': serializer.toJson<String>(shift),
      'streakCount': serializer.toJson<int>(streakCount),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    String? daysJson,
    String? shift,
    int? streakCount,
    bool? isActive,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    daysJson: daysJson ?? this.daysJson,
    shift: shift ?? this.shift,
    streakCount: streakCount ?? this.streakCount,
    isActive: isActive ?? this.isActive,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      daysJson: data.daysJson.present ? data.daysJson.value : this.daysJson,
      shift: data.shift.present ? data.shift.value : this.shift,
      streakCount: data.streakCount.present
          ? data.streakCount.value
          : this.streakCount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('daysJson: $daysJson, ')
          ..write('shift: $shift, ')
          ..write('streakCount: $streakCount, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, daysJson, shift, streakCount, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.daysJson == this.daysJson &&
          other.shift == this.shift &&
          other.streakCount == this.streakCount &&
          other.isActive == this.isActive);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> daysJson;
  final Value<String> shift;
  final Value<int> streakCount;
  final Value<bool> isActive;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.daysJson = const Value.absent(),
    this.shift = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String daysJson,
    required String shift,
    this.streakCount = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       daysJson = Value(daysJson),
       shift = Value(shift);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? daysJson,
    Expression<String>? shift,
    Expression<int>? streakCount,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (daysJson != null) 'days_json': daysJson,
      if (shift != null) 'shift': shift,
      if (streakCount != null) 'streak_count': streakCount,
      if (isActive != null) 'is_active': isActive,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? daysJson,
    Value<String>? shift,
    Value<int>? streakCount,
    Value<bool>? isActive,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      daysJson: daysJson ?? this.daysJson,
      shift: shift ?? this.shift,
      streakCount: streakCount ?? this.streakCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (daysJson.present) {
      map['days_json'] = Variable<String>(daysJson.value);
    }
    if (shift.present) {
      map['shift'] = Variable<String>(shift.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('daysJson: $daysJson, ')
          ..write('shift: $shift, ')
          ..write('streakCount: $streakCount, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $HabitSessionsTable extends HabitSessions
    with TableInfo<$HabitSessionsTable, HabitSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    completedAt,
    durationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      ),
    );
  }

  @override
  $HabitSessionsTable createAlias(String alias) {
    return $HabitSessionsTable(attachedDatabase, alias);
  }
}

class HabitSession extends DataClass implements Insertable<HabitSession> {
  final int id;
  final int habitId;
  final DateTime completedAt;
  final int? durationMinutes;
  const HabitSession({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.durationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    return map;
  }

  HabitSessionsCompanion toCompanion(bool nullToAbsent) {
    return HabitSessionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      completedAt: Value(completedAt),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
    );
  }

  factory HabitSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitSession(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
    };
  }

  HabitSession copyWith({
    int? id,
    int? habitId,
    DateTime? completedAt,
    Value<int?> durationMinutes = const Value.absent(),
  }) => HabitSession(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    completedAt: completedAt ?? this.completedAt,
    durationMinutes: durationMinutes.present
        ? durationMinutes.value
        : this.durationMinutes,
  );
  HabitSession copyWithCompanion(HabitSessionsCompanion data) {
    return HabitSession(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitSession(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMinutes: $durationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, completedAt, durationMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitSession &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.completedAt == this.completedAt &&
          other.durationMinutes == this.durationMinutes);
}

class HabitSessionsCompanion extends UpdateCompanion<HabitSession> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> completedAt;
  final Value<int?> durationMinutes;
  const HabitSessionsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
  });
  HabitSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime completedAt,
    this.durationMinutes = const Value.absent(),
  }) : habitId = Value(habitId),
       completedAt = Value(completedAt);
  static Insertable<HabitSession> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? completedAt,
    Expression<int>? durationMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
    });
  }

  HabitSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? completedAt,
    Value<int?>? durationMinutes,
  }) {
    return HabitSessionsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitSessionsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMinutes: $durationMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $WordBooksTable wordBooks = $WordBooksTable(this);
  late final $LeitnerFortschrittTable leitnerFortschritt =
      $LeitnerFortschrittTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $DeckWoerterTable deckWoerter = $DeckWoerterTable(this);
  late final $MitgliedschaftenTable mitgliedschaften = $MitgliedschaftenTable(
    this,
  );
  late final $GrammarLessonsTable grammarLessons = $GrammarLessonsTable(this);
  late final $MemorizeItemsTable memorizeItems = $MemorizeItemsTable(this);
  late final $ReadingTextsTable readingTexts = $ReadingTextsTable(this);
  late final $AudioItemsTable audioItems = $AudioItemsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitSessionsTable habitSessions = $HabitSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    books,
    wordBooks,
    leitnerFortschritt,
    decks,
    deckWoerter,
    mitgliedschaften,
    grammarLessons,
    memorizeItems,
    readingTexts,
    audioItems,
    habits,
    habitSessions,
  ];
}

typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String german,
      Value<String?> article,
      Value<String?> plural,
      required String wordType,
      Value<String?> level,
      required String meaningFa,
      Value<String?> meaningEn,
      Value<String?> pronunciation,
      Value<String?> examplesJson,
      Value<String?> conjugationJson,
      Value<String?> etymology,
      Value<String?> commonErrors,
      Value<String?> grammarNote,
      Value<DateTime> createdAt,
      Value<bool?> regelmaessig,
      Value<bool?> trennbar,
      Value<String?> grammatikDetail,
      Value<bool?> ausApp,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> german,
      Value<String?> article,
      Value<String?> plural,
      Value<String> wordType,
      Value<String?> level,
      Value<String> meaningFa,
      Value<String?> meaningEn,
      Value<String?> pronunciation,
      Value<String?> examplesJson,
      Value<String?> conjugationJson,
      Value<String?> etymology,
      Value<String?> commonErrors,
      Value<String?> grammarNote,
      Value<DateTime> createdAt,
      Value<bool?> regelmaessig,
      Value<bool?> trennbar,
      Value<String?> grammatikDetail,
      Value<bool?> ausApp,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordBooksTable, List<WordBook>>
  _wordBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordBooks,
    aliasName: 'words__id__word_books__word_id',
  );

  $$WordBooksTableProcessedTableManager get wordBooksRefs {
    final manager = $$WordBooksTableTableManager(
      $_db,
      $_db.wordBooks,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get german => $composableBuilder(
    column: $table.german,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get article => $composableBuilder(
    column: $table.article,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plural => $composableBuilder(
    column: $table.plural,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningFa => $composableBuilder(
    column: $table.meaningFa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conjugationJson => $composableBuilder(
    column: $table.conjugationJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etymology => $composableBuilder(
    column: $table.etymology,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonErrors => $composableBuilder(
    column: $table.commonErrors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammarNote => $composableBuilder(
    column: $table.grammarNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get regelmaessig => $composableBuilder(
    column: $table.regelmaessig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trennbar => $composableBuilder(
    column: $table.trennbar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammatikDetail => $composableBuilder(
    column: $table.grammatikDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ausApp => $composableBuilder(
    column: $table.ausApp,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordBooksRefs(
    Expression<bool> Function($$WordBooksTableFilterComposer f) f,
  ) {
    final $$WordBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableFilterComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get german => $composableBuilder(
    column: $table.german,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get article => $composableBuilder(
    column: $table.article,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plural => $composableBuilder(
    column: $table.plural,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningFa => $composableBuilder(
    column: $table.meaningFa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conjugationJson => $composableBuilder(
    column: $table.conjugationJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etymology => $composableBuilder(
    column: $table.etymology,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonErrors => $composableBuilder(
    column: $table.commonErrors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammarNote => $composableBuilder(
    column: $table.grammarNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get regelmaessig => $composableBuilder(
    column: $table.regelmaessig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trennbar => $composableBuilder(
    column: $table.trennbar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammatikDetail => $composableBuilder(
    column: $table.grammatikDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ausApp => $composableBuilder(
    column: $table.ausApp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get german =>
      $composableBuilder(column: $table.german, builder: (column) => column);

  GeneratedColumn<String> get article =>
      $composableBuilder(column: $table.article, builder: (column) => column);

  GeneratedColumn<String> get plural =>
      $composableBuilder(column: $table.plural, builder: (column) => column);

  GeneratedColumn<String> get wordType =>
      $composableBuilder(column: $table.wordType, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get meaningFa =>
      $composableBuilder(column: $table.meaningFa, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conjugationJson => $composableBuilder(
    column: $table.conjugationJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etymology =>
      $composableBuilder(column: $table.etymology, builder: (column) => column);

  GeneratedColumn<String> get commonErrors => $composableBuilder(
    column: $table.commonErrors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grammarNote => $composableBuilder(
    column: $table.grammarNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get regelmaessig => $composableBuilder(
    column: $table.regelmaessig,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trennbar =>
      $composableBuilder(column: $table.trennbar, builder: (column) => column);

  GeneratedColumn<String> get grammatikDetail => $composableBuilder(
    column: $table.grammatikDetail,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ausApp =>
      $composableBuilder(column: $table.ausApp, builder: (column) => column);

  Expression<T> wordBooksRefs<T extends Object>(
    Expression<T> Function($$WordBooksTableAnnotationComposer a) f,
  ) {
    final $$WordBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool wordBooksRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> german = const Value.absent(),
                Value<String?> article = const Value.absent(),
                Value<String?> plural = const Value.absent(),
                Value<String> wordType = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> meaningFa = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> pronunciation = const Value.absent(),
                Value<String?> examplesJson = const Value.absent(),
                Value<String?> conjugationJson = const Value.absent(),
                Value<String?> etymology = const Value.absent(),
                Value<String?> commonErrors = const Value.absent(),
                Value<String?> grammarNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool?> regelmaessig = const Value.absent(),
                Value<bool?> trennbar = const Value.absent(),
                Value<String?> grammatikDetail = const Value.absent(),
                Value<bool?> ausApp = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                german: german,
                article: article,
                plural: plural,
                wordType: wordType,
                level: level,
                meaningFa: meaningFa,
                meaningEn: meaningEn,
                pronunciation: pronunciation,
                examplesJson: examplesJson,
                conjugationJson: conjugationJson,
                etymology: etymology,
                commonErrors: commonErrors,
                grammarNote: grammarNote,
                createdAt: createdAt,
                regelmaessig: regelmaessig,
                trennbar: trennbar,
                grammatikDetail: grammatikDetail,
                ausApp: ausApp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String german,
                Value<String?> article = const Value.absent(),
                Value<String?> plural = const Value.absent(),
                required String wordType,
                Value<String?> level = const Value.absent(),
                required String meaningFa,
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> pronunciation = const Value.absent(),
                Value<String?> examplesJson = const Value.absent(),
                Value<String?> conjugationJson = const Value.absent(),
                Value<String?> etymology = const Value.absent(),
                Value<String?> commonErrors = const Value.absent(),
                Value<String?> grammarNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool?> regelmaessig = const Value.absent(),
                Value<bool?> trennbar = const Value.absent(),
                Value<String?> grammatikDetail = const Value.absent(),
                Value<bool?> ausApp = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                german: german,
                article: article,
                plural: plural,
                wordType: wordType,
                level: level,
                meaningFa: meaningFa,
                meaningEn: meaningEn,
                pronunciation: pronunciation,
                examplesJson: examplesJson,
                conjugationJson: conjugationJson,
                etymology: etymology,
                commonErrors: commonErrors,
                grammarNote: grammarNote,
                createdAt: createdAt,
                regelmaessig: regelmaessig,
                trennbar: trennbar,
                grammatikDetail: grammatikDetail,
                ausApp: ausApp,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({wordBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordBooksRefs) db.wordBooks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordBooksRefs)
                    await $_getPrefetchedData<Word, $WordsTable, WordBook>(
                      currentTable: table,
                      referencedTable: $$WordsTableReferences
                          ._wordBooksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordsTableReferences(db, table, p0).wordBooksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool wordBooksRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({Value<int> id, required String name});
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({Value<int> id, Value<String> name});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordBooksTable, List<WordBook>>
  _wordBooksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordBooks,
    aliasName: 'books__id__word_books__book_id',
  );

  $$WordBooksTableProcessedTableManager get wordBooksRefs {
    final manager = $$WordBooksTableTableManager(
      $_db,
      $_db.wordBooks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordBooksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordBooksRefs(
    Expression<bool> Function($$WordBooksTableFilterComposer f) f,
  ) {
    final $$WordBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableFilterComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> wordBooksRefs<T extends Object>(
    Expression<T> Function($$WordBooksTableAnnotationComposer a) f,
  ) {
    final $$WordBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordBooks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.wordBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({bool wordBooksRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => BooksCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  BooksCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({wordBooksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordBooksRefs) db.wordBooks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordBooksRefs)
                    await $_getPrefetchedData<Book, $BooksTable, WordBook>(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences
                          ._wordBooksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).wordBooksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({bool wordBooksRefs})
    >;
typedef $$WordBooksTableCreateCompanionBuilder =
    WordBooksCompanion Function({
      required int wordId,
      required int bookId,
      Value<int> rowid,
    });
typedef $$WordBooksTableUpdateCompanionBuilder =
    WordBooksCompanion Function({
      Value<int> wordId,
      Value<int> bookId,
      Value<int> rowid,
    });

final class $$WordBooksTableReferences
    extends BaseReferences<_$AppDatabase, $WordBooksTable, WordBook> {
  $$WordBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_books__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('word_books__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordBooksTableFilterComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordBooksTable> {
  $$WordBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordBooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordBooksTable,
          WordBook,
          $$WordBooksTableFilterComposer,
          $$WordBooksTableOrderingComposer,
          $$WordBooksTableAnnotationComposer,
          $$WordBooksTableCreateCompanionBuilder,
          $$WordBooksTableUpdateCompanionBuilder,
          (WordBook, $$WordBooksTableReferences),
          WordBook,
          PrefetchHooks Function({bool wordId, bool bookId})
        > {
  $$WordBooksTableTableManager(_$AppDatabase db, $WordBooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wordId = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordBooksCompanion(
                wordId: wordId,
                bookId: bookId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int wordId,
                required int bookId,
                Value<int> rowid = const Value.absent(),
              }) => WordBooksCompanion.insert(
                wordId: wordId,
                bookId: bookId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordId = false, bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordBooksTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordBooksTableReferences
                                    ._wordIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$WordBooksTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$WordBooksTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WordBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordBooksTable,
      WordBook,
      $$WordBooksTableFilterComposer,
      $$WordBooksTableOrderingComposer,
      $$WordBooksTableAnnotationComposer,
      $$WordBooksTableCreateCompanionBuilder,
      $$WordBooksTableUpdateCompanionBuilder,
      (WordBook, $$WordBooksTableReferences),
      WordBook,
      PrefetchHooks Function({bool wordId, bool bookId})
    >;
typedef $$LeitnerFortschrittTableCreateCompanionBuilder =
    LeitnerFortschrittCompanion Function({
      required String wortId,
      required String uebung,
      Value<int> fach,
      Value<DateTime?> naechsteWiederholung,
      Value<DateTime?> letzteWiederholung,
      Value<int> rowid,
    });
typedef $$LeitnerFortschrittTableUpdateCompanionBuilder =
    LeitnerFortschrittCompanion Function({
      Value<String> wortId,
      Value<String> uebung,
      Value<int> fach,
      Value<DateTime?> naechsteWiederholung,
      Value<DateTime?> letzteWiederholung,
      Value<int> rowid,
    });

class $$LeitnerFortschrittTableFilterComposer
    extends Composer<_$AppDatabase, $LeitnerFortschrittTable> {
  $$LeitnerFortschrittTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wortId => $composableBuilder(
    column: $table.wortId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uebung => $composableBuilder(
    column: $table.uebung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fach => $composableBuilder(
    column: $table.fach,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get naechsteWiederholung => $composableBuilder(
    column: $table.naechsteWiederholung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get letzteWiederholung => $composableBuilder(
    column: $table.letzteWiederholung,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LeitnerFortschrittTableOrderingComposer
    extends Composer<_$AppDatabase, $LeitnerFortschrittTable> {
  $$LeitnerFortschrittTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wortId => $composableBuilder(
    column: $table.wortId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uebung => $composableBuilder(
    column: $table.uebung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fach => $composableBuilder(
    column: $table.fach,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get naechsteWiederholung => $composableBuilder(
    column: $table.naechsteWiederholung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get letzteWiederholung => $composableBuilder(
    column: $table.letzteWiederholung,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LeitnerFortschrittTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeitnerFortschrittTable> {
  $$LeitnerFortschrittTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wortId =>
      $composableBuilder(column: $table.wortId, builder: (column) => column);

  GeneratedColumn<String> get uebung =>
      $composableBuilder(column: $table.uebung, builder: (column) => column);

  GeneratedColumn<int> get fach =>
      $composableBuilder(column: $table.fach, builder: (column) => column);

  GeneratedColumn<DateTime> get naechsteWiederholung => $composableBuilder(
    column: $table.naechsteWiederholung,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get letzteWiederholung => $composableBuilder(
    column: $table.letzteWiederholung,
    builder: (column) => column,
  );
}

class $$LeitnerFortschrittTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeitnerFortschrittTable,
          LeitnerFortschrittData,
          $$LeitnerFortschrittTableFilterComposer,
          $$LeitnerFortschrittTableOrderingComposer,
          $$LeitnerFortschrittTableAnnotationComposer,
          $$LeitnerFortschrittTableCreateCompanionBuilder,
          $$LeitnerFortschrittTableUpdateCompanionBuilder,
          (
            LeitnerFortschrittData,
            BaseReferences<
              _$AppDatabase,
              $LeitnerFortschrittTable,
              LeitnerFortschrittData
            >,
          ),
          LeitnerFortschrittData,
          PrefetchHooks Function()
        > {
  $$LeitnerFortschrittTableTableManager(
    _$AppDatabase db,
    $LeitnerFortschrittTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeitnerFortschrittTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeitnerFortschrittTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeitnerFortschrittTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> wortId = const Value.absent(),
                Value<String> uebung = const Value.absent(),
                Value<int> fach = const Value.absent(),
                Value<DateTime?> naechsteWiederholung = const Value.absent(),
                Value<DateTime?> letzteWiederholung = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeitnerFortschrittCompanion(
                wortId: wortId,
                uebung: uebung,
                fach: fach,
                naechsteWiederholung: naechsteWiederholung,
                letzteWiederholung: letzteWiederholung,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String wortId,
                required String uebung,
                Value<int> fach = const Value.absent(),
                Value<DateTime?> naechsteWiederholung = const Value.absent(),
                Value<DateTime?> letzteWiederholung = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LeitnerFortschrittCompanion.insert(
                wortId: wortId,
                uebung: uebung,
                fach: fach,
                naechsteWiederholung: naechsteWiederholung,
                letzteWiederholung: letzteWiederholung,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LeitnerFortschrittTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeitnerFortschrittTable,
      LeitnerFortschrittData,
      $$LeitnerFortschrittTableFilterComposer,
      $$LeitnerFortschrittTableOrderingComposer,
      $$LeitnerFortschrittTableAnnotationComposer,
      $$LeitnerFortschrittTableCreateCompanionBuilder,
      $$LeitnerFortschrittTableUpdateCompanionBuilder,
      (
        LeitnerFortschrittData,
        BaseReferences<
          _$AppDatabase,
          $LeitnerFortschrittTable,
          LeitnerFortschrittData
        >,
      ),
      LeitnerFortschrittData,
      PrefetchHooks Function()
    >;
typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      required String id,
      required String name,
      Value<String?> elternId,
      Value<int> ordnung,
      Value<String> modus,
      Value<int?> neuProTag,
      Value<int?> nameAmMs,
      Value<int?> standAmMs,
      Value<int> rowid,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> elternId,
      Value<int> ordnung,
      Value<String> modus,
      Value<int?> neuProTag,
      Value<int?> nameAmMs,
      Value<int?> standAmMs,
      Value<int> rowid,
    });

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DeckWoerterTable, List<DeckWoerterData>>
  _deckWoerterRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deckWoerter,
    aliasName: 'decks__id__deck_woerter__deck_id',
  );

  $$DeckWoerterTableProcessedTableManager get deckWoerterRefs {
    final manager = $$DeckWoerterTableTableManager(
      $_db,
      $_db.deckWoerter,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_deckWoerterRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get elternId => $composableBuilder(
    column: $table.elternId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordnung => $composableBuilder(
    column: $table.ordnung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modus => $composableBuilder(
    column: $table.modus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get neuProTag => $composableBuilder(
    column: $table.neuProTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nameAmMs => $composableBuilder(
    column: $table.nameAmMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standAmMs => $composableBuilder(
    column: $table.standAmMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> deckWoerterRefs(
    Expression<bool> Function($$DeckWoerterTableFilterComposer f) f,
  ) {
    final $$DeckWoerterTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckWoerter,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckWoerterTableFilterComposer(
            $db: $db,
            $table: $db.deckWoerter,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get elternId => $composableBuilder(
    column: $table.elternId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordnung => $composableBuilder(
    column: $table.ordnung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modus => $composableBuilder(
    column: $table.modus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get neuProTag => $composableBuilder(
    column: $table.neuProTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nameAmMs => $composableBuilder(
    column: $table.nameAmMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standAmMs => $composableBuilder(
    column: $table.standAmMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get elternId =>
      $composableBuilder(column: $table.elternId, builder: (column) => column);

  GeneratedColumn<int> get ordnung =>
      $composableBuilder(column: $table.ordnung, builder: (column) => column);

  GeneratedColumn<String> get modus =>
      $composableBuilder(column: $table.modus, builder: (column) => column);

  GeneratedColumn<int> get neuProTag =>
      $composableBuilder(column: $table.neuProTag, builder: (column) => column);

  GeneratedColumn<int> get nameAmMs =>
      $composableBuilder(column: $table.nameAmMs, builder: (column) => column);

  GeneratedColumn<int> get standAmMs =>
      $composableBuilder(column: $table.standAmMs, builder: (column) => column);

  Expression<T> deckWoerterRefs<T extends Object>(
    Expression<T> Function($$DeckWoerterTableAnnotationComposer a) f,
  ) {
    final $$DeckWoerterTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckWoerter,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckWoerterTableAnnotationComposer(
            $db: $db,
            $table: $db.deckWoerter,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          Deck,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (Deck, $$DecksTableReferences),
          Deck,
          PrefetchHooks Function({bool deckWoerterRefs})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> elternId = const Value.absent(),
                Value<int> ordnung = const Value.absent(),
                Value<String> modus = const Value.absent(),
                Value<int?> neuProTag = const Value.absent(),
                Value<int?> nameAmMs = const Value.absent(),
                Value<int?> standAmMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                name: name,
                elternId: elternId,
                ordnung: ordnung,
                modus: modus,
                neuProTag: neuProTag,
                nameAmMs: nameAmMs,
                standAmMs: standAmMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> elternId = const Value.absent(),
                Value<int> ordnung = const Value.absent(),
                Value<String> modus = const Value.absent(),
                Value<int?> neuProTag = const Value.absent(),
                Value<int?> nameAmMs = const Value.absent(),
                Value<int?> standAmMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                name: name,
                elternId: elternId,
                ordnung: ordnung,
                modus: modus,
                neuProTag: neuProTag,
                nameAmMs: nameAmMs,
                standAmMs: standAmMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DecksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({deckWoerterRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (deckWoerterRefs) db.deckWoerter],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deckWoerterRefs)
                    await $_getPrefetchedData<
                      Deck,
                      $DecksTable,
                      DeckWoerterData
                    >(
                      currentTable: table,
                      referencedTable: $$DecksTableReferences
                          ._deckWoerterRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DecksTableReferences(db, table, p0).deckWoerterRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      Deck,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (Deck, $$DecksTableReferences),
      Deck,
      PrefetchHooks Function({bool deckWoerterRefs})
    >;
typedef $$DeckWoerterTableCreateCompanionBuilder =
    DeckWoerterCompanion Function({
      required String deckId,
      required String wortId,
      Value<int> hinzuMs,
      Value<int> rowid,
    });
typedef $$DeckWoerterTableUpdateCompanionBuilder =
    DeckWoerterCompanion Function({
      Value<String> deckId,
      Value<String> wortId,
      Value<int> hinzuMs,
      Value<int> rowid,
    });

final class $$DeckWoerterTableReferences
    extends BaseReferences<_$AppDatabase, $DeckWoerterTable, DeckWoerterData> {
  $$DeckWoerterTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('deck_woerter__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeckWoerterTableFilterComposer
    extends Composer<_$AppDatabase, $DeckWoerterTable> {
  $$DeckWoerterTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wortId => $composableBuilder(
    column: $table.wortId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hinzuMs => $composableBuilder(
    column: $table.hinzuMs,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckWoerterTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckWoerterTable> {
  $$DeckWoerterTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wortId => $composableBuilder(
    column: $table.wortId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hinzuMs => $composableBuilder(
    column: $table.hinzuMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckWoerterTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckWoerterTable> {
  $$DeckWoerterTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wortId =>
      $composableBuilder(column: $table.wortId, builder: (column) => column);

  GeneratedColumn<int> get hinzuMs =>
      $composableBuilder(column: $table.hinzuMs, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckWoerterTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckWoerterTable,
          DeckWoerterData,
          $$DeckWoerterTableFilterComposer,
          $$DeckWoerterTableOrderingComposer,
          $$DeckWoerterTableAnnotationComposer,
          $$DeckWoerterTableCreateCompanionBuilder,
          $$DeckWoerterTableUpdateCompanionBuilder,
          (DeckWoerterData, $$DeckWoerterTableReferences),
          DeckWoerterData,
          PrefetchHooks Function({bool deckId})
        > {
  $$DeckWoerterTableTableManager(_$AppDatabase db, $DeckWoerterTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckWoerterTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckWoerterTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckWoerterTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deckId = const Value.absent(),
                Value<String> wortId = const Value.absent(),
                Value<int> hinzuMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckWoerterCompanion(
                deckId: deckId,
                wortId: wortId,
                hinzuMs: hinzuMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deckId,
                required String wortId,
                Value<int> hinzuMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckWoerterCompanion.insert(
                deckId: deckId,
                wortId: wortId,
                hinzuMs: hinzuMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeckWoerterTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$DeckWoerterTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$DeckWoerterTableReferences
                                    ._deckIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeckWoerterTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckWoerterTable,
      DeckWoerterData,
      $$DeckWoerterTableFilterComposer,
      $$DeckWoerterTableOrderingComposer,
      $$DeckWoerterTableAnnotationComposer,
      $$DeckWoerterTableCreateCompanionBuilder,
      $$DeckWoerterTableUpdateCompanionBuilder,
      (DeckWoerterData, $$DeckWoerterTableReferences),
      DeckWoerterData,
      PrefetchHooks Function({bool deckId})
    >;
typedef $$MitgliedschaftenTableCreateCompanionBuilder =
    MitgliedschaftenCompanion Function({
      required String art,
      required String schluessel,
      Value<String> wort,
      required bool drin,
      required int amMs,
      Value<int> rowid,
    });
typedef $$MitgliedschaftenTableUpdateCompanionBuilder =
    MitgliedschaftenCompanion Function({
      Value<String> art,
      Value<String> schluessel,
      Value<String> wort,
      Value<bool> drin,
      Value<int> amMs,
      Value<int> rowid,
    });

class $$MitgliedschaftenTableFilterComposer
    extends Composer<_$AppDatabase, $MitgliedschaftenTable> {
  $$MitgliedschaftenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wort => $composableBuilder(
    column: $table.wort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get drin => $composableBuilder(
    column: $table.drin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amMs => $composableBuilder(
    column: $table.amMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MitgliedschaftenTableOrderingComposer
    extends Composer<_$AppDatabase, $MitgliedschaftenTable> {
  $$MitgliedschaftenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wort => $composableBuilder(
    column: $table.wort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get drin => $composableBuilder(
    column: $table.drin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amMs => $composableBuilder(
    column: $table.amMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MitgliedschaftenTableAnnotationComposer
    extends Composer<_$AppDatabase, $MitgliedschaftenTable> {
  $$MitgliedschaftenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);

  GeneratedColumn<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wort =>
      $composableBuilder(column: $table.wort, builder: (column) => column);

  GeneratedColumn<bool> get drin =>
      $composableBuilder(column: $table.drin, builder: (column) => column);

  GeneratedColumn<int> get amMs =>
      $composableBuilder(column: $table.amMs, builder: (column) => column);
}

class $$MitgliedschaftenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MitgliedschaftenTable,
          MitgliedschaftenData,
          $$MitgliedschaftenTableFilterComposer,
          $$MitgliedschaftenTableOrderingComposer,
          $$MitgliedschaftenTableAnnotationComposer,
          $$MitgliedschaftenTableCreateCompanionBuilder,
          $$MitgliedschaftenTableUpdateCompanionBuilder,
          (
            MitgliedschaftenData,
            BaseReferences<
              _$AppDatabase,
              $MitgliedschaftenTable,
              MitgliedschaftenData
            >,
          ),
          MitgliedschaftenData,
          PrefetchHooks Function()
        > {
  $$MitgliedschaftenTableTableManager(
    _$AppDatabase db,
    $MitgliedschaftenTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MitgliedschaftenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MitgliedschaftenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MitgliedschaftenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> art = const Value.absent(),
                Value<String> schluessel = const Value.absent(),
                Value<String> wort = const Value.absent(),
                Value<bool> drin = const Value.absent(),
                Value<int> amMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MitgliedschaftenCompanion(
                art: art,
                schluessel: schluessel,
                wort: wort,
                drin: drin,
                amMs: amMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String art,
                required String schluessel,
                Value<String> wort = const Value.absent(),
                required bool drin,
                required int amMs,
                Value<int> rowid = const Value.absent(),
              }) => MitgliedschaftenCompanion.insert(
                art: art,
                schluessel: schluessel,
                wort: wort,
                drin: drin,
                amMs: amMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MitgliedschaftenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MitgliedschaftenTable,
      MitgliedschaftenData,
      $$MitgliedschaftenTableFilterComposer,
      $$MitgliedschaftenTableOrderingComposer,
      $$MitgliedschaftenTableAnnotationComposer,
      $$MitgliedschaftenTableCreateCompanionBuilder,
      $$MitgliedschaftenTableUpdateCompanionBuilder,
      (
        MitgliedschaftenData,
        BaseReferences<
          _$AppDatabase,
          $MitgliedschaftenTable,
          MitgliedschaftenData
        >,
      ),
      MitgliedschaftenData,
      PrefetchHooks Function()
    >;
typedef $$GrammarLessonsTableCreateCompanionBuilder =
    GrammarLessonsCompanion Function({
      Value<int> id,
      required String title,
      required String level,
      required String content,
      Value<int> sortOrder,
    });
typedef $$GrammarLessonsTableUpdateCompanionBuilder =
    GrammarLessonsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> level,
      Value<String> content,
      Value<int> sortOrder,
    });

class $$GrammarLessonsTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarLessonsTable> {
  $$GrammarLessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GrammarLessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarLessonsTable> {
  $$GrammarLessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrammarLessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarLessonsTable> {
  $$GrammarLessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$GrammarLessonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrammarLessonsTable,
          GrammarLesson,
          $$GrammarLessonsTableFilterComposer,
          $$GrammarLessonsTableOrderingComposer,
          $$GrammarLessonsTableAnnotationComposer,
          $$GrammarLessonsTableCreateCompanionBuilder,
          $$GrammarLessonsTableUpdateCompanionBuilder,
          (
            GrammarLesson,
            BaseReferences<_$AppDatabase, $GrammarLessonsTable, GrammarLesson>,
          ),
          GrammarLesson,
          PrefetchHooks Function()
        > {
  $$GrammarLessonsTableTableManager(
    _$AppDatabase db,
    $GrammarLessonsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarLessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarLessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarLessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GrammarLessonsCompanion(
                id: id,
                title: title,
                level: level,
                content: content,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String level,
                required String content,
                Value<int> sortOrder = const Value.absent(),
              }) => GrammarLessonsCompanion.insert(
                id: id,
                title: title,
                level: level,
                content: content,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrammarLessonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrammarLessonsTable,
      GrammarLesson,
      $$GrammarLessonsTableFilterComposer,
      $$GrammarLessonsTableOrderingComposer,
      $$GrammarLessonsTableAnnotationComposer,
      $$GrammarLessonsTableCreateCompanionBuilder,
      $$GrammarLessonsTableUpdateCompanionBuilder,
      (
        GrammarLesson,
        BaseReferences<_$AppDatabase, $GrammarLessonsTable, GrammarLesson>,
      ),
      GrammarLesson,
      PrefetchHooks Function()
    >;
typedef $$MemorizeItemsTableCreateCompanionBuilder =
    MemorizeItemsCompanion Function({
      Value<int> id,
      required String category,
      required String phrase,
      required String meaning,
      Value<String?> meaningEn,
      Value<String?> level,
      Value<String?> examplesJson,
    });
typedef $$MemorizeItemsTableUpdateCompanionBuilder =
    MemorizeItemsCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> phrase,
      Value<String> meaning,
      Value<String?> meaningEn,
      Value<String?> level,
      Value<String?> examplesJson,
    });

class $$MemorizeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MemorizeItemsTable> {
  $$MemorizeItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemorizeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemorizeItemsTable> {
  $$MemorizeItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phrase => $composableBuilder(
    column: $table.phrase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemorizeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemorizeItemsTable> {
  $$MemorizeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get phrase =>
      $composableBuilder(column: $table.phrase, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => column,
  );
}

class $$MemorizeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemorizeItemsTable,
          MemorizeItem,
          $$MemorizeItemsTableFilterComposer,
          $$MemorizeItemsTableOrderingComposer,
          $$MemorizeItemsTableAnnotationComposer,
          $$MemorizeItemsTableCreateCompanionBuilder,
          $$MemorizeItemsTableUpdateCompanionBuilder,
          (
            MemorizeItem,
            BaseReferences<_$AppDatabase, $MemorizeItemsTable, MemorizeItem>,
          ),
          MemorizeItem,
          PrefetchHooks Function()
        > {
  $$MemorizeItemsTableTableManager(_$AppDatabase db, $MemorizeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemorizeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemorizeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemorizeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> phrase = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> examplesJson = const Value.absent(),
              }) => MemorizeItemsCompanion(
                id: id,
                category: category,
                phrase: phrase,
                meaning: meaning,
                meaningEn: meaningEn,
                level: level,
                examplesJson: examplesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String phrase,
                required String meaning,
                Value<String?> meaningEn = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String?> examplesJson = const Value.absent(),
              }) => MemorizeItemsCompanion.insert(
                id: id,
                category: category,
                phrase: phrase,
                meaning: meaning,
                meaningEn: meaningEn,
                level: level,
                examplesJson: examplesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemorizeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemorizeItemsTable,
      MemorizeItem,
      $$MemorizeItemsTableFilterComposer,
      $$MemorizeItemsTableOrderingComposer,
      $$MemorizeItemsTableAnnotationComposer,
      $$MemorizeItemsTableCreateCompanionBuilder,
      $$MemorizeItemsTableUpdateCompanionBuilder,
      (
        MemorizeItem,
        BaseReferences<_$AppDatabase, $MemorizeItemsTable, MemorizeItem>,
      ),
      MemorizeItem,
      PrefetchHooks Function()
    >;
typedef $$ReadingTextsTableCreateCompanionBuilder =
    ReadingTextsCompanion Function({
      Value<int> id,
      required String title,
      required String level,
      required String content,
      Value<String?> audioPath,
      Value<DateTime> addedAt,
    });
typedef $$ReadingTextsTableUpdateCompanionBuilder =
    ReadingTextsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> level,
      Value<String> content,
      Value<String?> audioPath,
      Value<DateTime> addedAt,
    });

class $$ReadingTextsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingTextsTable> {
  $$ReadingTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingTextsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingTextsTable> {
  $$ReadingTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingTextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingTextsTable> {
  $$ReadingTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$ReadingTextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingTextsTable,
          ReadingText,
          $$ReadingTextsTableFilterComposer,
          $$ReadingTextsTableOrderingComposer,
          $$ReadingTextsTableAnnotationComposer,
          $$ReadingTextsTableCreateCompanionBuilder,
          $$ReadingTextsTableUpdateCompanionBuilder,
          (
            ReadingText,
            BaseReferences<_$AppDatabase, $ReadingTextsTable, ReadingText>,
          ),
          ReadingText,
          PrefetchHooks Function()
        > {
  $$ReadingTextsTableTableManager(_$AppDatabase db, $ReadingTextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => ReadingTextsCompanion(
                id: id,
                title: title,
                level: level,
                content: content,
                audioPath: audioPath,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String level,
                required String content,
                Value<String?> audioPath = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => ReadingTextsCompanion.insert(
                id: id,
                title: title,
                level: level,
                content: content,
                audioPath: audioPath,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingTextsTable,
      ReadingText,
      $$ReadingTextsTableFilterComposer,
      $$ReadingTextsTableOrderingComposer,
      $$ReadingTextsTableAnnotationComposer,
      $$ReadingTextsTableCreateCompanionBuilder,
      $$ReadingTextsTableUpdateCompanionBuilder,
      (
        ReadingText,
        BaseReferences<_$AppDatabase, $ReadingTextsTable, ReadingText>,
      ),
      ReadingText,
      PrefetchHooks Function()
    >;
typedef $$AudioItemsTableCreateCompanionBuilder =
    AudioItemsCompanion Function({
      Value<int> id,
      required String title,
      required String level,
      required String audioPath,
      Value<String?> transcript,
    });
typedef $$AudioItemsTableUpdateCompanionBuilder =
    AudioItemsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> level,
      Value<String> audioPath,
      Value<String?> transcript,
    });

class $$AudioItemsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioItemsTable> {
  $$AudioItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AudioItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioItemsTable> {
  $$AudioItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AudioItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioItemsTable> {
  $$AudioItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );
}

class $$AudioItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioItemsTable,
          AudioItem,
          $$AudioItemsTableFilterComposer,
          $$AudioItemsTableOrderingComposer,
          $$AudioItemsTableAnnotationComposer,
          $$AudioItemsTableCreateCompanionBuilder,
          $$AudioItemsTableUpdateCompanionBuilder,
          (
            AudioItem,
            BaseReferences<_$AppDatabase, $AudioItemsTable, AudioItem>,
          ),
          AudioItem,
          PrefetchHooks Function()
        > {
  $$AudioItemsTableTableManager(_$AppDatabase db, $AudioItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> audioPath = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
              }) => AudioItemsCompanion(
                id: id,
                title: title,
                level: level,
                audioPath: audioPath,
                transcript: transcript,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String level,
                required String audioPath,
                Value<String?> transcript = const Value.absent(),
              }) => AudioItemsCompanion.insert(
                id: id,
                title: title,
                level: level,
                audioPath: audioPath,
                transcript: transcript,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AudioItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioItemsTable,
      AudioItem,
      $$AudioItemsTableFilterComposer,
      $$AudioItemsTableOrderingComposer,
      $$AudioItemsTableAnnotationComposer,
      $$AudioItemsTableCreateCompanionBuilder,
      $$AudioItemsTableUpdateCompanionBuilder,
      (AudioItem, BaseReferences<_$AppDatabase, $AudioItemsTable, AudioItem>),
      AudioItem,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String name,
      required String daysJson,
      required String shift,
      Value<int> streakCount,
      Value<bool> isActive,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> daysJson,
      Value<String> shift,
      Value<int> streakCount,
      Value<bool> isActive,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitSessionsTable, List<HabitSession>>
  _habitSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitSessions,
    aliasName: 'habits__id__habit_sessions__habit_id',
  );

  $$HabitSessionsTableProcessedTableManager get habitSessionsRefs {
    final manager = $$HabitSessionsTableTableManager(
      $_db,
      $_db.habitSessions,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysJson => $composableBuilder(
    column: $table.daysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitSessionsRefs(
    Expression<bool> Function($$HabitSessionsTableFilterComposer f) f,
  ) {
    final $$HabitSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitSessions,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitSessionsTableFilterComposer(
            $db: $db,
            $table: $db.habitSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysJson => $composableBuilder(
    column: $table.daysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get daysJson =>
      $composableBuilder(column: $table.daysJson, builder: (column) => column);

  GeneratedColumn<String> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<int> get streakCount => $composableBuilder(
    column: $table.streakCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> habitSessionsRefs<T extends Object>(
    Expression<T> Function($$HabitSessionsTableAnnotationComposer a) f,
  ) {
    final $$HabitSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitSessions,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool habitSessionsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> daysJson = const Value.absent(),
                Value<String> shift = const Value.absent(),
                Value<int> streakCount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                daysJson: daysJson,
                shift: shift,
                streakCount: streakCount,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String daysJson,
                required String shift,
                Value<int> streakCount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                daysJson: daysJson,
                shift: shift,
                streakCount: streakCount,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({habitSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (habitSessionsRefs) db.habitSessions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitSessionsRefs)
                    await $_getPrefetchedData<
                      Habit,
                      $HabitsTable,
                      HabitSession
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._habitSessionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$HabitsTableReferences(
                        db,
                        table,
                        p0,
                      ).habitSessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool habitSessionsRefs})
    >;
typedef $$HabitSessionsTableCreateCompanionBuilder =
    HabitSessionsCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime completedAt,
      Value<int?> durationMinutes,
    });
typedef $$HabitSessionsTableUpdateCompanionBuilder =
    HabitSessionsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> completedAt,
      Value<int?> durationMinutes,
    });

final class $$HabitSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitSessionsTable, HabitSession> {
  $$HabitSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_sessions__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitSessionsTable> {
  $$HabitSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitSessionsTable> {
  $$HabitSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitSessionsTable> {
  $$HabitSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitSessionsTable,
          HabitSession,
          $$HabitSessionsTableFilterComposer,
          $$HabitSessionsTableOrderingComposer,
          $$HabitSessionsTableAnnotationComposer,
          $$HabitSessionsTableCreateCompanionBuilder,
          $$HabitSessionsTableUpdateCompanionBuilder,
          (HabitSession, $$HabitSessionsTableReferences),
          HabitSession,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitSessionsTableTableManager(_$AppDatabase db, $HabitSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int?> durationMinutes = const Value.absent(),
              }) => HabitSessionsCompanion(
                id: id,
                habitId: habitId,
                completedAt: completedAt,
                durationMinutes: durationMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime completedAt,
                Value<int?> durationMinutes = const Value.absent(),
              }) => HabitSessionsCompanion.insert(
                id: id,
                habitId: habitId,
                completedAt: completedAt,
                durationMinutes: durationMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitSessionsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitSessionsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitSessionsTable,
      HabitSession,
      $$HabitSessionsTableFilterComposer,
      $$HabitSessionsTableOrderingComposer,
      $$HabitSessionsTableAnnotationComposer,
      $$HabitSessionsTableCreateCompanionBuilder,
      $$HabitSessionsTableUpdateCompanionBuilder,
      (HabitSession, $$HabitSessionsTableReferences),
      HabitSession,
      PrefetchHooks Function({bool habitId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$WordBooksTableTableManager get wordBooks =>
      $$WordBooksTableTableManager(_db, _db.wordBooks);
  $$LeitnerFortschrittTableTableManager get leitnerFortschritt =>
      $$LeitnerFortschrittTableTableManager(_db, _db.leitnerFortschritt);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$DeckWoerterTableTableManager get deckWoerter =>
      $$DeckWoerterTableTableManager(_db, _db.deckWoerter);
  $$MitgliedschaftenTableTableManager get mitgliedschaften =>
      $$MitgliedschaftenTableTableManager(_db, _db.mitgliedschaften);
  $$GrammarLessonsTableTableManager get grammarLessons =>
      $$GrammarLessonsTableTableManager(_db, _db.grammarLessons);
  $$MemorizeItemsTableTableManager get memorizeItems =>
      $$MemorizeItemsTableTableManager(_db, _db.memorizeItems);
  $$ReadingTextsTableTableManager get readingTexts =>
      $$ReadingTextsTableTableManager(_db, _db.readingTexts);
  $$AudioItemsTableTableManager get audioItems =>
      $$AudioItemsTableTableManager(_db, _db.audioItems);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitSessionsTableTableManager get habitSessions =>
      $$HabitSessionsTableTableManager(_db, _db.habitSessions);
}
