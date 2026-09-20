// FILE: lib/features/more/widgets/profil_angaben_karte.dart
// PHASE: فاز P / P.1 (2026-09-20)
// PURPOSE: Persönliche Angaben bearbeiten — Name, Telefonnummer, Adressen.
//          Die E-Mail steht bewusst nicht hier, sondern in der Konto-Karte
//          (sie gehört dem Anmeldebestand, nicht dem Profil).
//
// ⚠️ **Ein Speichern speichert das ganze Formular.** Wer eine Adresse
//    hinzufügt, während im Namensfeld noch ungespeicherter Text steht, verliert
//    diesen nicht — und ein Fehler (z. B. ungültige Nummer) verhindert dann
//    auch das Speichern der Adresse, statt sie halb zu speichern.
// ⚠️ Alles freiwillig; ein leeres Profil ist der Normalfall.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backup/nutzer_profil.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/vox_dialog.dart';
import '../controllers/profil_controller.dart';
import 'konto_texte.dart';

class ProfilAngabenKarte extends ConsumerWidget {
  const ProfilAngabenKarte({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profil = ref.watch(profilProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: profil.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
          // Der Schlüssel folgt dem Änderungszeitpunkt: Kommt ein anderer
          // Stand herein (Abgleich, Datei), baut sich das Formular neu auf.
          data: (p) => _AngabenFormular(
            key: ValueKey(p.am?.microsecondsSinceEpoch ?? 0),
            profil: p,
          ),
        ),
      ),
    );
  }
}

class _AngabenFormular extends ConsumerStatefulWidget {
  const _AngabenFormular({super.key, required this.profil});

  final NutzerProfil profil;

  @override
  ConsumerState<_AngabenFormular> createState() => _AngabenFormularState();
}

class _AngabenFormularState extends ConsumerState<_AngabenFormular> {
  late final TextEditingController _name;
  late final TextEditingController _telefon;
  bool _laeuft = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profil.name);
    _telefon = TextEditingController(text: widget.profil.telefon);
  }

  @override
  void dispose() {
    _name.dispose();
    _telefon.dispose();
    super.dispose();
  }

  void _zeige(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Speichert Felder + `adressen`. Texte vorher auflösen (kein `context`
  /// nach dem await, `use_build_context_synchronously`).
  Future<void> _speichern(List<ProfilAdresse> adressen) async {
    if (_laeuft) return;
    final gespeichert = AppL10n.t(context, 'profile_saved');
    final neu = widget.profil.kopie(
      name: _name.text,
      telefon: _telefon.text,
      adressen: adressen,
    );
    // Vorab prüfen, damit der Fehlertext mit dem richtigen `context` entsteht.
    final vorab = neu.bereinigt().pruefen();
    if (vorab != null) {
      _zeige(profilFehlerText(context, vorab));
      return;
    }
    setState(() => _laeuft = true);
    try {
      final fehler = await ref.read(profilProvider.notifier).speichern(neu);
      if (!mounted) return;
      if (fehler != null) {
        _zeige(profilFehlerText(context, fehler));
      } else {
        _zeige(gespeichert);
      }
    } finally {
      if (mounted) setState(() => _laeuft = false);
    }
  }

  Future<void> _adresseBearbeiten({int? index}) async {
    final alt = index == null ? null : widget.profil.adressen[index];
    final neu = await showDialog<ProfilAdresse>(
      context: context,
      builder: (_) => _AdresseDialog(alt: alt),
    );
    if (neu == null || !mounted) return;
    final liste = [...widget.profil.adressen];
    if (index == null) {
      liste.add(neu);
    } else {
      liste[index] = neu;
    }
    await _speichern(liste);
  }

  Future<void> _adresseLoeschen(int index) async {
    final ok = await VoxDialog.confirm(
      context,
      title: AppL10n.t(context, 'profile_address_delete_q'),
      message: '',
      confirmLabel: 'delete',
    );
    if (!ok || !mounted) return;
    final liste = [...widget.profil.adressen]..removeAt(index);
    await _speichern(liste);
  }

  @override
  Widget build(BuildContext context) {
    final adressen = widget.profil.adressen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppL10n.t(context, 'profile_details_hint'),
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSizes.md),
        TextField(
          controller: _name,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: AppL10n.t(context, 'profile_name_label'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        TextField(
          controller: _telefon,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: AppL10n.t(context, 'profile_phone_label'),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(AppL10n.t(context, 'profile_addresses'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSizes.xs),
        if (adressen.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            child: Text(AppL10n.t(context, 'profile_address_none'),
                style: Theme.of(context).textTheme.bodySmall),
          )
        else
          for (var i = 0; i < adressen.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.home_outlined),
              title: Text(adressen[i].bezeichnung.isEmpty
                  ? AppL10n.t(context, 'profile_addresses')
                  : adressen[i].bezeichnung),
              subtitle: Text(_adressZeilen(adressen[i])),
              onTap: () => _adresseBearbeiten(index: i),
              trailing: VoxIconButton(
                icon: Icons.delete_outline,
                tooltip: AppL10n.t(context, 'delete'),
                onPressed: () => _adresseLoeschen(i),
              ),
            ),
        if (adressen.length < profilMaxAdressen)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: VoxButton.text(
              label: AppL10n.t(context, 'profile_address_add'),
              icon: Icons.add_location_alt_outlined,
              onPressed: () => _adresseBearbeiten(),
            ),
          ),
        const SizedBox(height: AppSizes.md),
        VoxButton.primary(
          label: AppL10n.t(context, 'profile_save'),
          icon: Icons.save_outlined,
          loading: _laeuft,
          onPressed: () => _speichern(widget.profil.adressen),
        ),
      ],
    );
  }

  static String _adressZeilen(ProfilAdresse a) {
    final ortZeile = [a.plz, a.ort].where((t) => t.isNotEmpty).join(' ');
    return [a.strasse, ortZeile, a.land].where((t) => t.isNotEmpty).join('\n');
  }
}

/// Dialog zum Anlegen und Bearbeiten einer Adresse. Gibt eine
/// [ProfilAdresse] zurück oder `null` bei Abbruch.
class _AdresseDialog extends StatefulWidget {
  const _AdresseDialog({this.alt});

  final ProfilAdresse? alt;

  @override
  State<_AdresseDialog> createState() => _AdresseDialogState();
}

class _AdresseDialogState extends State<_AdresseDialog> {
  late final TextEditingController _bezeichnung;
  late final TextEditingController _strasse;
  late final TextEditingController _plz;
  late final TextEditingController _ort;
  late final TextEditingController _land;
  bool _leerFehler = false;

  @override
  void initState() {
    super.initState();
    final a = widget.alt;
    _bezeichnung = TextEditingController(text: a?.bezeichnung ?? '');
    _strasse = TextEditingController(text: a?.strasse ?? '');
    _plz = TextEditingController(text: a?.plz ?? '');
    _ort = TextEditingController(text: a?.ort ?? '');
    _land = TextEditingController(text: a?.land ?? '');
  }

  @override
  void dispose() {
    _bezeichnung.dispose();
    _strasse.dispose();
    _plz.dispose();
    _ort.dispose();
    _land.dispose();
    super.dispose();
  }

  void _uebernehmen() {
    final adresse = ProfilAdresse(
      bezeichnung: _bezeichnung.text,
      strasse: _strasse.text,
      plz: _plz.text,
      ort: _ort.text,
      land: _land.text,
    );
    if (adresse.istLeer) {
      setState(() => _leerFehler = true);
      return;
    }
    Navigator.pop(context, adresse);
  }

  Widget _feld(TextEditingController c, String schluessel,
          {TextInputType? typ, bool ltr = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: TextField(
          controller: c,
          keyboardType: typ,
          textDirection: ltr ? TextDirection.ltr : null,
          decoration: InputDecoration(
            labelText: AppL10n.t(context, schluessel),
            border: const OutlineInputBorder(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppL10n.t(context,
          widget.alt == null ? 'profile_address_add' : 'profile_address_edit')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _feld(_bezeichnung, 'profile_address_label'),
            _feld(_strasse, 'profile_address_street'),
            _feld(_plz, 'profile_address_zip',
                typ: TextInputType.text, ltr: true),
            _feld(_ort, 'profile_address_city'),
            _feld(_land, 'profile_address_country'),
            if (_leerFehler)
              Text(AppL10n.t(context, 'profile_address_need_one'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        VoxButton.text(
          label: AppL10n.t(context, 'cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        VoxButton.primary(
          label: AppL10n.t(context, 'profile_save'),
          onPressed: _uebernehmen,
        ),
      ],
    );
  }
}
