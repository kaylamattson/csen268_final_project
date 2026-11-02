import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/metric_card.dart';
import 'share_dialog.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
Widget build(BuildContext context) => Padding(
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
}
