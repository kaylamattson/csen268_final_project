import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const SensleApp());

class C {
  static const ink = Color(0xFF06363B);
  static const teal = Color(0xFF7FAAB0);
  static const darkTeal = Color(0xFF39666C);
  static const pale = Color(0xFFD7E7E9);
  static const purple = Color(0xFFA997BB);
  static const purpleDark = Color(0xFF8E75A5);
  static const purplePale = Color(0xFFEADCF6);
  static const pink = Color(0xFFF4BBB5);
  static const rose = Color(0xFFCF8983);
  static const lightPink = Color(0xFFF9DBD9);
  static const lime = Color(0xFFACD049);
  static const limePale = Color(0xFFDEEDA7);
  static const olive = Color(0xFF7B913F);
}

class SensleApp extends StatelessWidget {
  const SensleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sensle',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: C.teal),
            textTheme: const TextTheme(
                bodyMedium: TextStyle(color: C.ink, fontSize: 16))),
        home: const SplashScreen(),
      );
}

// A reusable screen wrapper. SafeArea lets Android draw its own status bar.
class Base extends StatelessWidget {
  final Widget child;
  final Widget? bottom;
  const Base({super.key, required this.child, this.bottom});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: child))),
        bottomNavigationBar:
            bottom == null ? null : SafeArea(top: false, child: bottom!),
      );
}

Widget heading(String s, {double size = 27, Color color = C.ink}) => Text(s,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: .25));
Widget labelText(String s,
        {double size = 16,
        Color color = C.ink,
        FontWeight weight = FontWeight.w500,
        TextAlign? align}) =>
    Text(s,
        textAlign: align,
        style: TextStyle(
            color: color, fontSize: size, fontWeight: weight, height: 1.3));

class Pill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final double width;
  const Pill(
      {super.key,
      required this.text,
      required this.onTap,
      this.color = C.teal,
      this.textColor = C.ink,
      this.width = 200});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      height: 52,
      child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              elevation: 0),
          child: Text(text,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w700))));
}

enum SensorKind { direction, tilt, light }

Color sensorColor(SensorKind kind) => switch (kind) {
      SensorKind.direction => C.purple,
      SensorKind.tilt => C.pink,
      SensorKind.light => C.lime
    };
IconData sensorIcon(SensorKind kind) => switch (kind) {
      SensorKind.direction => Icons.navigation_outlined,
      SensorKind.tilt => Icons.screen_rotation_outlined,
      SensorKind.light => Icons.wb_sunny_outlined
    };
String sensorName(SensorKind kind) => switch (kind) {
      SensorKind.direction => 'Direction Task',
      SensorKind.tilt => 'Tilt Task',
      SensorKind.light => 'Light Task'
    };

class SensorBadge extends StatelessWidget {
  final SensorKind kind;
  final double size;
  const SensorBadge(this.kind, {super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: sensorColor(kind),
          borderRadius: BorderRadius.circular(size * .21)),
      child: Icon(sensorIcon(kind), color: C.ink, size: size * .65));
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Base(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const Spacer(flex: 2),
            const Icon(Icons.light_mode_outlined,
                size: 80, color: Color(0xFF242428)),
            const SizedBox(height: 20),
            Text('Sensle',
                style: TextStyle(
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    shadows: [
                      Shadow(color: C.teal, offset: const Offset(3, 4))
                    ])),
            const SizedBox(height: 8),
            labelText('Quick... Move. Measure. Master!',
                size: 16, color: Colors.black, weight: FontWeight.w800),
            const SizedBox(height: 58),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SensorBadge(SensorKind.direction, size: 76),
                  SensorBadge(SensorKind.tilt, size: 76),
                  SensorBadge(SensorKind.light, size: 76)
                ]),
            const SizedBox(height: 62),
            Pill(
                text: 'Let’s Go!',
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const TabsPage())),
                width: 197),
            const Spacer(flex: 3),
          ])));
}

class TabsPage extends StatefulWidget {
  final int initialIndex;
  const TabsPage({super.key, this.initialIndex = 0});
  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  late int tab = widget.initialIndex;
  @override
  Widget build(BuildContext context) => Base(
        bottom: Container(
            height: 72,
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFF999999), width: .6))),
            child: Row(children: [
              navItem(0, Icons.home_outlined, 'Home'),
              navItem(1, Icons.sports_esports_outlined, 'Practice'),
              navItem(2, Icons.bar_chart_outlined, 'Stats'),
            ])),
        child: switch (tab) {
          0 => home(context),
          1 => practice(context),
          _ => stats(context)
        },
      );
  Widget navItem(int i, IconData icon, String title) => Expanded(
      child: InkWell(
          onTap: () => setState(() => tab = i),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 31, color: tab == i ? C.ink : const Color(0xFF26262A)),
            Text(title,
                style: TextStyle(
                    fontSize: 11,
                    color: tab == i ? C.ink : Colors.black,
                    fontWeight: tab == i ? FontWeight.bold : FontWeight.w500))
          ])));
  Widget home(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Sensle',
            style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: Colors.black)),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: C.teal, borderRadius: BorderRadius.circular(24)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.calendar_month_outlined,
                    color: C.ink, size: 32),
                const SizedBox(width: 14),
                Expanded(child: heading("Today's Challenge", size: 25))
              ]),
              labelText('Oct 14, 2026', color: Colors.white70),
              const SizedBox(height: 32),
              labelText('3 tasks, 1 minute.\nCan you complete them all?',
                  color: Colors.white, align: TextAlign.center),
              const SizedBox(height: 8)
            ])),
        const SizedBox(height: 24),
        for (final s in SensorKind.values) ...[
          taskCard(
              s,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChallengePage(
                          initialTask: SensorKind.values.indexOf(s))))),
          const SizedBox(height: 18)
        ],
        const SizedBox(height: 16),
        Pill(
            text: 'Start Challenge',
            color: C.darkTeal,
            textColor: Colors.white,
            width: double.infinity,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChallengePage()))),
      ]));
  Widget practice(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(30, 25, 30, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Practice',
            style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w700,
                color: Colors.black)),
        const SizedBox(height: 10),
        labelText('Test and calibrate each\nsensor whenever you want!',
            color: const Color(0xFF68767A), size: 18),
        const SizedBox(height: 38),
        for (final kind in SensorKind.values) ...[
          taskCard(
              kind,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PracticePage(kind: kind)))),
          const SizedBox(height: 28)
        ]
      ]));
  Widget stats(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: heading('Statistics', size: 23)),
        const SizedBox(height: 30),
        const Row(children: [
          Expanded(child: MetricCard(value: 'X', title: 'Day Streak')),
          SizedBox(width: 30),
          Expanded(child: MetricCard(value: 'XX%', title: 'Accuracy'))
        ]),
        const SizedBox(height: 34),
        heading('Recent Results', size: 27),
        const SizedBox(height: 25),
        Expanded(
            child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, i) => InkWell(
                    onTap: () => showDialog(
                        context: context, builder: (_) => const ShareDialog()),
                    child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: C.lightPink,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 3))
                            ]),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              labelText('October ${18 - i}, 26',
                                  weight: FontWeight.w800),
                              labelText(
                                  [
                                    '00:42',
                                    '00:55',
                                    '00:37',
                                    '00:41',
                                    '00:59'
                                  ][i],
                                  weight: FontWeight.w800)
                            ]))))),
      ]));
  Widget taskCard(SensorKind kind, VoidCallback onTap) => Material(
      color: C.pale,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(children: [
                SensorBadge(kind),
                const SizedBox(width: 20),
                Expanded(child: heading(sensorName(kind), size: 21))
              ]))));
}

class MetricCard extends StatelessWidget {
  final String value, title;
  const MetricCard({super.key, required this.value, required this.title});
  @override
  Widget build(BuildContext context) => Container(
      height: 95,
      decoration: BoxDecoration(
          color: const Color(0xFFBDD4D7),
          borderRadius: BorderRadius.circular(28)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        heading(value, size: 26, color: Colors.black),
        labelText(title, color: Colors.black)
      ]));
}

class ChallengePage extends StatefulWidget {
  final int initialTask;
  const ChallengePage({super.key, this.initialTask = 0});
  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  late int current = widget.initialTask;
  @override
  Widget build(BuildContext context) {
    final kind = SensorKind.values[current];
    return Base(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(children: [
              Row(children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios,
                        color: C.ink, size: 28)),
                Expanded(
                    child: Column(children: [
                  labelText('Task ${current + 1} of 3',
                      color: Colors.black, size: 24),
                  const SizedBox(height: 2),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          3,
                          (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == current
                                      ? Colors.black
                                      : Colors.black26))))
                ])),
                Pill(
                    text: current == 2 ? 'Done' : 'Next',
                    width: 88,
                    color: C.pale,
                    onTap: () {
                      if (current < 2) {
                        setState(() => current++);
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CompletionPage()));
                      }
                    })
              ]),
              const SizedBox(height: 52),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SensorBadge(kind),
                const SizedBox(width: 18),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      heading(
                          switch (kind) {
                            SensorKind.direction => 'Point Due North',
                            SensorKind.tilt => 'Tilt to 45°',
                            SensorKind.light => 'Block the Light Sensor'
                          },
                          size: 20),
                      const SizedBox(height: 5),
                      labelText(
                          switch (kind) {
                            SensorKind.direction =>
                              'Rotate your phone until it points exactly north.',
                            SensorKind.tilt =>
                              'Tilt your phone forward to exactly 45 degrees.',
                            SensorKind.light =>
                              'Cover the top of your phone to block the light sensor.'
                          },
                          size: 14)
                    ]))
              ]),
              const SizedBox(height: 38),
              Expanded(child: SensorPanel(kind: kind, practice: false)),
              const SizedBox(height: 24),
              Container(
                  height: kind == SensorKind.direction ? 76 : 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: switch (kind) {
                        SensorKind.direction => C.purplePale,
                        SensorKind.tilt => C.lightPink,
                        SensorKind.light => C.limePale
                      },
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 3),
                            blurRadius: 3)
                      ]),
                  child: Center(
                      child: labelText(
                          switch (kind) {
                            SensorKind.direction =>
                              'Keep rotating...\nGet as close as possible!',
                            SensorKind.tilt => 'Tilt a bit more forward!',
                            SensorKind.light => 'Keep blocking the light!'
                          },
                          weight: FontWeight.w800,
                          align: TextAlign.center))),
              const Spacer(),
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                      value: (current + 1) / 3,
                      backgroundColor: const Color(0xFFE4E4E4),
                      color: C.teal,
                      minHeight: 5))
            ])));
  }
}

class PracticePage extends StatelessWidget {
  final SensorKind kind;
  const PracticePage({super.key, required this.kind});
  @override
  Widget build(BuildContext context) => Base(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 23, 26, 24),
          child: Column(children: [
            Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                      const Icon(Icons.arrow_back_ios, color: C.ink, size: 28)),
              const SizedBox(width: 18),
              SensorBadge(kind),
              const SizedBox(width: 18),
              Expanded(
                  child: heading(
                      switch (kind) {
                        SensorKind.direction => 'Navigation Practice',
                        SensorKind.tilt => 'Tilt Practice',
                        SensorKind.light => 'Light Practice'
                      },
                      size: 20))
            ]),
            const SizedBox(height: 42),
            SizedBox(
                height: MediaQuery.sizeOf(context).height * .43,
                child: SensorPanel(kind: kind, practice: true)),
            if (kind != SensorKind.light) ...[
              const SizedBox(height: 50),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                practiceMetric(
                    kind == SensorKind.direction ? 'Heading' : 'Pitch', 'X°'),
                practiceMetric(
                    kind == SensorKind.direction ? 'Accuracy' : 'Roll', '±X°')
              ])
            ],
            const Spacer(),
          ])));
  Widget practiceMetric(String title, String value) => Container(
      width: 122,
      height: 92,
      decoration: BoxDecoration(
          color: sensorColor(kind), borderRadius: BorderRadius.circular(30)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        labelText(title, color: Colors.black),
        heading(value, color: Colors.black, size: 26)
      ]));
}

class SensorPanel extends StatelessWidget {
  final SensorKind kind;
  final bool practice;
  const SensorPanel({super.key, required this.kind, this.practice = false});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: switch (kind) {
            SensorKind.direction => C.purpleDark,
            SensorKind.tilt => C.rose,
            SensorKind.light => C.olive
          },
          borderRadius: BorderRadius.circular(24)),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child: CustomPaint(
              painter: SensorPainter(kind),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (kind != SensorKind.direction) ...[
                  heading(kind == SensorKind.tilt ? '42°' : '12%',
                      size: 29, color: Colors.white),
                  labelText(
                      kind == SensorKind.tilt
                          ? 'Target: 45°'
                          : (practice
                              ? 'Ambient\nLight Level'
                              : 'Target: < 5%'),
                      size: 20,
                      color: Colors.white,
                      weight: FontWeight.w800,
                      align: TextAlign.center),
                  const SizedBox(height: 20),
                ]
              ]))));
}

class SensorPainter extends CustomPainter {
  final SensorKind kind;
  SensorPainter(this.kind);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .43);
    final radius = math.min(size.width * .42, size.height * .34);
    if (kind == SensorKind.direction) {
      final p = Paint()
        ..color = C.pale
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      canvas.drawCircle(center, radius, p);
      for (final (s, pos) in [
        ('N', Offset(0, -.79)),
        ('S', Offset(0, .79)),
        ('W', Offset(-.8, 0)),
        ('E', Offset(.8, 0))
      ]) {
        drawText(canvas, s, center + Offset(pos.dx * radius, pos.dy * radius),
            23, Colors.white);
      }
      final nav = Path()
        ..moveTo(center.dx - 9, center.dy + 4)
        ..lineTo(center.dx - 3, center.dy - 45)
        ..lineTo(center.dx + 22, center.dy - 10)
        ..lineTo(center.dx + 3, center.dy - 15)
        ..close();
      canvas.drawPath(
          nav,
          Paint()
            ..color = C.pale
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5);
      drawText(canvas, '15°', center + const Offset(0, 40), 28, Colors.white);
      drawText(canvas, 'from target', center + const Offset(0, 70), 14,
          Colors.white);
    } else if (kind == SensorKind.tilt) {
      final p = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final origin = Offset(size.width * .23, size.height * .55);
      drawDashed(canvas, origin, Offset(size.width * .79, origin.dy), p);
      drawDashed(
          canvas, origin, Offset(size.width * .65, size.height * .17), p);
    } else {
      final p = Paint()
        ..color = C.darkTeal
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * .7), -.2,
          math.pi * 1.65, false, p);
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * .7),
          -math.pi / 2,
          .75,
          false,
          Paint()
            ..color = C.teal
            ..strokeWidth = 18
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
      final sun = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, 13, sun);
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        canvas.drawLine(center + Offset(math.cos(a) * 23, math.sin(a) * 23),
            center + Offset(math.cos(a) * 31, math.sin(a) * 31), sun);
      }
    }
  }

  void drawText(
      Canvas canvas, String text, Offset center, double size, Color color) {
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                color: color, fontSize: size, fontWeight: FontWeight.w700)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  void drawDashed(Canvas c, Offset a, Offset b, Paint p) {
    final delta = b - a;
    final length = delta.distance;
    final unit = delta / length;
    for (double x = 0; x < length; x += 18) {
      c.drawLine(a + unit * x, a + unit * math.min(x + 9, length), p);
    }
  }

  @override
  bool shouldRepaint(covariant SensorPainter old) => old.kind != kind;
}

class CompletionPage extends StatelessWidget {
  const CompletionPage({super.key});
  @override
  Widget build(BuildContext context) => Base(
      child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 24),
              child: Column(children: [
                const Icon(Icons.emoji_events_outlined,
                    size: 95, color: Color(0xFF222227)),
                const SizedBox(height: 15),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: C.ink,
                    child: Column(children: [
                      heading('You Did It!', size: 35, color: Colors.white),
                      const SizedBox(height: 8),
                      labelText("Completed today’s challenge in",
                          color: Colors.white),
                      heading('00:00', size: 25, color: Colors.white)
                    ])),
                const SizedBox(height: 15),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                          width: 125,
                          child: MetricCard(value: 'X', title: 'Day Streak')),
                      SizedBox(
                          width: 125,
                          child: MetricCard(value: 'XX%', title: 'Accuracy'))
                    ]),
                const SizedBox(height: 15),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: C.teal, borderRadius: BorderRadius.circular(30)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          heading("Today’s Results",
                              color: Colors.white, size: 19),
                          const SizedBox(height: 28),
                          const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SensorBadge(SensorKind.direction, size: 74),
                                SensorBadge(SensorKind.tilt, size: 74),
                                SensorBadge(SensorKind.light, size: 74)
                              ]),
                          const SizedBox(height: 12),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (final s in [
                                  'X°\noff target',
                                  'X°\noff target',
                                  'X%\nlight level'
                                ])
                                  labelText(s,
                                      size: 12,
                                      color: Colors.black,
                                      align: TextAlign.center)
                              ]),
                        ])),
                const SizedBox(height: 20),
                Pill(
                    text: 'Share Results',
                    color: C.pale,
                    onTap: () => showDialog(
                        context: context, builder: (_) => const ShareDialog())),
                const SizedBox(height: 12),
                Pill(
                    text: 'Back to Home',
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const TabsPage()),
                        (_) => false)),
              ]))));
}

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key});
  @override
  Widget build(BuildContext context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              heading('Sensle', size: 30),
              labelText('June 27, 2026', size: 17, color: Colors.black)
            ]),
            const SizedBox(height: 20),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SensorBadge(SensorKind.direction, size: 76),
                  SensorBadge(SensorKind.tilt, size: 76),
                  SensorBadge(SensorKind.light, size: 76)
                ]),
            const SizedBox(height: 14),
            labelText('X°                 X°                 X%',
                color: Colors.black),
            const SizedBox(height: 22),
            heading('00:00', color: Colors.black, size: 39),
            const SizedBox(height: 10),
            labelText('X Day Streak!', color: Colors.black, size: 24),
            const SizedBox(height: 12),
            labelText('Move. Measure. Master!', weight: FontWeight.w800),
            const SizedBox(height: 18),
            Pill(
                text: 'Back to Home',
                onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TabsPage()),
                    (_) => false)),
          ])));
}
