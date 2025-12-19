import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/report_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/report.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/report_card.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {

  StatoReport _selectedStatoReport = StatoReport.aperto;

  @override
  Widget build(BuildContext context) {

    final reportsAsyncValue = ref.watch(reportsProvider(_selectedStatoReport));
    final reportController = ref.read(reportControllerProvider.notifier);

    ref.listen(reportControllerProvider, (_, state) {

      if(state is ReportError) {
        showErrorSnackBar(context, state.message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Report"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(
                  Icons.filter_alt,
                  color: ResQPetColors.onBackground,
                ),
                const Text(
                  "Filtri",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              spacing: 5.0,
              children: StatoReport.values.map(
                (stato) {
                  return FilterChip(
                    label: Text(stato.stato),
                    selected: stato == _selectedStatoReport,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedStatoReport = selected ? stato : StatoReport.aperto;
                      });
                    },
                  );
                }
              ).toList(),
            ),
            const Divider(),
            reportsAsyncValue.when(
              data: (reports) {

                if(reports.isEmpty) {
                  return Center(
                    child: Text("Non sono presenti report.")
                  );
                }

                return ListView.builder(
                  itemCount: reports.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return ReportCard(
                      report: report,
                      onResolve: (report) => reportController.risolviReport(report),
                      onDelete: (report) => reportController.cancellaReport(report),
                    );
                  }
                );
              }, 
              error: (error, _) => Center(
                child: Text(error.toString()),
              ), 
              loading: () => const Center(
                child: CircularProgressIndicator(),
              )
            )
          ],
        ),
      ),
    );
  }
}