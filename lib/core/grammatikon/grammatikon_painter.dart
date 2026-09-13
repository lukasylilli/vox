// FILE: lib/core/grammatikon/grammatikon_painter.dart
// PURPOSE: Zeichnet das Grammatikon-Symbol (فاز V, Stufe ۱ — V.icon aus dem PLAN).
//          Liest NUR aus GrammatikonSpec (Geometrie/Farben) + GrammatikonDescriptor
//          (vom Resolver). Verwendung überall:
//              WortSymbol(card: karte, size: 24)
//              WortSymbol(card: karte, kasus: 'dativ', size: 36)  // flektiert
//          Design ändern = nur GrammatikonSpec/Resolver, alle Wort-JSONs bleiben.
//          (Port von WortSymbol.js — react-native-svg → Flutter CustomPainter.)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'grammatikon_resolver.dart';
import 'grammatikon_spec.dart';

/// Fertiges Widget: rendert das grammatische Symbol automatisch aus der Karte.
class WortSymbol extends StatelessWidget {
  final Map<String, dynamic> card;
  final double size;
  final String kasus;
  final String numerus;
  final String? genus;
  final String? form;
  final bool attributiv;

  const WortSymbol({
    super.key,
    required this.card,
    this.size = 24,
    this.kasus = 'nominativ',
    this.numerus = 'singular',
    this.genus,
    this.form,
    this.attributiv = false,
  });

  @override
  Widget build(BuildContext context) {
    final descriptor = GrammatikonResolver.resolve(
      card,
      GrammatikonContext(
        kasus: kasus,
        numerus: numerus,
        genus: genus,
        form: form,
        attributiv: attributiv,
      ),
    );
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: GrammatikonPainter(descriptor)),
    );
  }
}

class GrammatikonPainter extends CustomPainter {
  final GrammatikonDescriptor d;
  const GrammatikonPainter(this.d);

  static const double _vb = GrammatikonSpec.viewBox; // 100
  static const double _c = _vb / 2; // Mittelpunkt 50

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _vb, size.height / _vb);

    final konturPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = GrammatikonSpec.rahmenNormal
      ..strokeJoin = StrokeJoin.round
      ..color = GrammatikonSpec.kontur;

    switch (d.shape) {
      case 'kapsel':
        _zeichneKapsel(canvas, konturPaint);
        return;
      case 'blob_wellig':
        _zeichneBlob(canvas, wellig: true);
        return;
      case 'blob_zahnrad':
        _zeichneZahnrad(canvas);
        return;
      case 'doppel_kreis':
        _zeichneDoppel(canvas, blob: false);
        return;
      case 'doppel_blob':
        _zeichneDoppel(canvas, blob: true);
        return;
      case 'kurve_u':
        _zeichneKurve(canvas, konturPaint, welle: false);
        return;
      case 'kurve_welle':
        _zeichneKurve(canvas, konturPaint, welle: true);
        return;
      case 'kreis_mit_linie':
        _zeichneKreisMitLinie(canvas, konturPaint);
        return;
      case 'stern':
        _zeichneStern(canvas);
        return;
    }

    // Geschlossene Grundformen (quadrat/raute/dreieck_links/ellipse/kreis):
    final path = _grundformPfad(d.shape);
    _fuelle(canvas, path);
    if (d.marker == 'ausrufezeichen') _zeichneAusrufezeichen(canvas);
  }

  // ── Geschlossene Grundformen ───────────────────────────────────
  Path _grundformPfad(String shape) {
    final path = Path();
    switch (shape) {
      case 'raute':
        // Raute = Quadrat um 45° gedreht: Ecken oben/rechts/unten/links.
        final r = GrammatikonSpec.quadratSeite / 2 * math.sqrt2;
        path
          ..moveTo(_c, _c - r)
          ..lineTo(_c + r, _c)
          ..lineTo(_c, _c + r)
          ..lineTo(_c - r, _c)
          ..close();
      case 'dreieck_links':
        final h = GrammatikonSpec.dreieckHoehe;
        final half = h / 2;
        path
          ..moveTo(_c - half, _c) // Spitze links
          ..lineTo(_c + half, _c - half)
          ..lineTo(_c + half, _c + half)
          ..close();
      case 'ellipse':
        path.addOval(Rect.fromCenter(
          center: const Offset(_c, _c),
          width: GrammatikonSpec.ellipseRx * 2,
          height: GrammatikonSpec.ellipseRy * 2,
        ));
      case 'kreis':
        path.addOval(Rect.fromCircle(
            center: const Offset(_c, _c), radius: GrammatikonSpec.kreisRadius));
      case 'quadrat':
      default:
        final s = GrammatikonSpec.quadratSeite;
        path.addRect(Rect.fromCenter(center: const Offset(_c, _c), width: s, height: s));
    }
    return path;
  }

  // ── Füllungen anwenden ─────────────────────────────────────────
  void _fuelle(Canvas canvas, Path path) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = d.color;
    final kontur = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = GrammatikonSpec.rahmenNormal
      ..strokeJoin = StrokeJoin.round
      ..color = d.fuellung == 'voll' ? d.color : GrammatikonSpec.kontur;

    switch (d.fuellung) {
      case 'voll':
        canvas.drawPath(path, fill);
      case 'hohl':
        canvas.drawPath(path, kontur);
      case 'halb_unten':
        canvas.save();
        canvas.clipPath(path);
        canvas.drawRect(const Rect.fromLTRB(0, _c, _vb, _vb), fill);
        canvas.restore();
        canvas.drawPath(path, kontur..color = GrammatikonSpec.kontur);
      case 'streifen_vertikal':
        _streifen(canvas, path, diagonal: false);
      case 'streifen_diagonal':
        _streifen(canvas, path, diagonal: true);
      case 'doppel_voll':
        // Form-in-Form (Pronomen): äußere hohl, innere voll.
        canvas.drawPath(path, kontur..color = d.color);
        final inner = _skaliere(path, GrammatikonSpec.doppelInnenFaktor);
        canvas.drawPath(inner, fill);
      default:
        canvas.drawPath(path, fill);
    }
  }

  void _streifen(Canvas canvas, Path path, {required bool diagonal}) {
    canvas.save();
    canvas.clipPath(path);
    final p = Paint()
      ..color = d.color
      ..strokeWidth = GrammatikonSpec.streifenBreite
      ..style = PaintingStyle.stroke;
    if (diagonal) {
      canvas.translate(_c, _c);
      canvas.rotate(GrammatikonSpec.diagonalGrad * math.pi / 180);
      canvas.translate(-_c, -_c);
    }
    for (double x = -_vb; x < _vb * 2; x += GrammatikonSpec.streifenAbstand) {
      canvas.drawLine(Offset(x, -_vb), Offset(x, _vb * 2), p);
    }
    canvas.restore();
    // Kontur obendrauf.
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = GrammatikonSpec.rahmenNormal
          ..color = GrammatikonSpec.kontur);
  }

  Path _skaliere(Path path, double faktor) {
    final bounds = path.getBounds();
    final m = Matrix4.identity()
      ..translateByDouble(bounds.center.dx, bounds.center.dy, 0, 1)
      ..scaleByDouble(faktor, faktor, 1, 1)
      ..translateByDouble(-bounds.center.dx, -bounds.center.dy, 0, 1);
    return path.transform(m.storage);
  }

  // ── Sonderformen ───────────────────────────────────────────────
  void _zeichneKapsel(Canvas canvas, Paint kontur) {
    final rect = Rect.fromCenter(
      center: const Offset(_c, _c),
      width: GrammatikonSpec.kapselRx * 2,
      height: GrammatikonSpec.kapselRy * 2,
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(GrammatikonSpec.kapselRy)), kontur);

    final innenFill = Paint()..color = GrammatikonSpec.kontur;
    const g = 14.0; // Innenform-Halbgröße
    switch (d.innen) {
      case 'raute':
        final p = Path()
          ..moveTo(_c, _c - g)
          ..lineTo(_c + g, _c)
          ..lineTo(_c, _c + g)
          ..lineTo(_c - g, _c)
          ..close();
        canvas.drawPath(p, innenFill);
      case 'ellipse':
        canvas.drawOval(
            Rect.fromCenter(center: const Offset(_c, _c), width: g * 2.4, height: g * 1.4),
            innenFill);
      case 'beide': // Wechselpräposition: senkrechte Trennlinie
        canvas.drawLine(const Offset(_c, _c - g), const Offset(_c, _c + g),
            Paint()..strokeWidth = 4..color = GrammatikonSpec.kontur);
      default: // dreieck_links (Dativ)
        final p = Path()
          ..moveTo(_c - g, _c)
          ..lineTo(_c + g, _c - g)
          ..lineTo(_c + g, _c + g)
          ..close();
        canvas.drawPath(p, innenFill);
    }
  }

  void _zeichneBlob(Canvas canvas, {required bool wellig}) {
    final path = _blobPfad(zacken: wellig ? 10 : 8, amplitude: wellig ? 4 : 3);
    final voll = d.fuellung != 'hohl';
    canvas.drawPath(
        path,
        Paint()
          ..style = voll ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = GrammatikonSpec.rahmenNormal
          ..color = voll ? d.color : GrammatikonSpec.kontur);
    if (d.fuellung == 'streifen_vertikal' || d.fuellung == 'streifen_diagonal') {
      _streifen(canvas, path, diagonal: d.fuellung == 'streifen_diagonal');
    }
    if (d.marker == 'ausrufezeichen') _zeichneAusrufezeichen(canvas);
  }

  Path _blobPfad({required int zacken, required double amplitude}) {
    final r = GrammatikonSpec.kreisRadius;
    final path = Path();
    for (int i = 0; i <= 360; i += 6) {
      final rad = i * math.pi / 180;
      final wobble = amplitude * math.sin(zacken * rad);
      final rr = r + wobble;
      final x = _c + rr * math.cos(rad);
      final y = _c + rr * math.sin(rad);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  void _zeichneZahnrad(Canvas canvas) {
    // Modalverb: kreis mit Zahnrad-Kontur (6 Zähne).
    final path = _blobPfad(zacken: 6, amplitude: 6);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = GrammatikonSpec.rahmenNormal
          ..color = GrammatikonSpec.kontur);
  }

  void _zeichneDoppel(Canvas canvas, {required bool blob}) {
    final outer = blob ? _blobPfad(zacken: 10, amplitude: 3) : _grundformPfad('kreis');
    final voll = d.fuellung != 'hohl';
    final aussen = Paint()
      ..style = voll ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = GrammatikonSpec.rahmenNormal
      ..color = voll ? d.color : GrammatikonSpec.kontur;
    canvas.drawPath(outer, aussen);
    // Innerer Kreis (Kontur), zeigt "zusammengesetzt/trennbar".
    canvas.drawCircle(
        const Offset(_c, _c),
        GrammatikonSpec.kreisRadius * GrammatikonSpec.doppelInnenFaktor,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = GrammatikonSpec.rahmenNormal
          ..color = voll ? GrammatikonSpec.weiss : GrammatikonSpec.kontur);
  }

  void _zeichneKurve(Canvas canvas, Paint kontur, {required bool welle}) {
    final path = Path()..moveTo(_c - 34, _c);
    if (welle) {
      path
        ..quadraticBezierTo(_c - 17, _c - 20, _c, _c)
        ..quadraticBezierTo(_c + 17, _c + 20, _c + 34, _c);
    } else {
      // offenes U
      path
        ..lineTo(_c - 34, _c + 16)
        ..quadraticBezierTo(_c - 34, _c + 28, _c, _c + 28)
        ..quadraticBezierTo(_c + 34, _c + 28, _c + 34, _c + 16)
        ..lineTo(_c + 34, _c);
    }
    canvas.drawPath(path, kontur..strokeWidth = 3);
  }

  void _zeichneKreisMitLinie(Canvas canvas, Paint kontur) {
    canvas.drawCircle(const Offset(_c, _c), GrammatikonSpec.kreisRadius, kontur);
    canvas.drawLine(const Offset(_c + GrammatikonSpec.kreisRadius, _c),
        const Offset(_vb - 4, _c), kontur);
  }

  void _zeichneStern(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: '*',
        style: TextStyle(
            color: d.color, fontSize: 90, fontWeight: FontWeight.bold, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(_c - tp.width / 2, _c - tp.height * 0.42));
  }

  void _zeichneAusrufezeichen(Canvas canvas) {
    final tp = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(
            color: GrammatikonSpec.weiss, fontSize: 42, fontWeight: FontWeight.bold, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(_c - tp.width / 2, _c - tp.height / 2));
  }

  @override
  bool shouldRepaint(GrammatikonPainter old) =>
      old.d.shape != d.shape ||
      old.d.fuellung != d.fuellung ||
      old.d.color != d.color ||
      old.d.marker != d.marker ||
      old.d.innen != d.innen;
}
