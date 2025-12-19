import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:resqpet/models/report.dart';
import 'package:resqpet/theme.dart';

extension StatoReportUI on StatoReport {
  String get label {
    switch (this) {
      case StatoReport.aperto:
        return 'Aperto';
      case StatoReport.risolto:
        return 'Risolto';
    }
  }

  Color get color {
    switch (this) {
      case StatoReport.aperto:
        return Colors.red;
      case StatoReport.risolto:
        return Colors.green;
    }
  }
}

class ReportCard extends StatelessWidget {

  final Report report;
  final void Function(Report report)? onResolve;
  final void Function(Report report)? onDelete;

  const ReportCard({
    super.key,
    required this.report,
    this.onResolve,
    this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 3,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.descrizione,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16
              ),
            ),
            const Divider(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Motivazione: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ), 
                  TextSpan(text: report.motivazione)
                ]
              )
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Cittadino: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ), 
                  TextSpan(text: report.cittadinoRef)
                ]
              )
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Annuncio: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ), 
                  TextSpan(text: report.annuncioRef)
                ]
              )
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(report.stato.label),
              backgroundColor: report.stato.color.withAlpha(51),
              avatar: Icon(
                Icons.circle,
                color: report.stato.color,
                size: 12,
              ),
            ),
            const SizedBox(height: 8),
            if(report.stato == StatoReport.aperto) Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    if(onResolve != null) {
                      onResolve!(report);
                    }
                  },
                  child: const Text(
                    "Risolvi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    if(onDelete != null) {
                      onDelete!(report);
                    }
                  },
                  child: const Text(
                    "Cancella",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

@Preview(name: "Report card")
Widget cardPreview() {
  return MaterialApp(
    theme: resqpetTheme,
    home: ReportCard(
      report: Report(
        motivazione: "Hei",
        descrizione: "boh",
        cittadinoRef: "",
        annuncioRef: "",
        stato: StatoReport.aperto
      )
    )
  );
   
}