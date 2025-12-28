import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/abbonamento_controller.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/info_message.dart';

class RiepilogoVendite {
  final int numeroVendite;
  final double guadagnoLordo;
  final double percentualeCommissione;
  final double importoCommissioni;

  RiepilogoVendite({
    required this.numeroVendite,
    required this.guadagnoLordo,
    required this.percentualeCommissione,
    required this.importoCommissioni
  });

  double get guadagnoNetto => guadagnoLordo - importoCommissioni;
}

class DashboardVenditeScreen extends ConsumerWidget {

  const DashboardVenditeScreen({ super.key });

  List<AnnuncioVendita> _getAnnunciConclusi(List<Annuncio> annunci) {
    return annunci
      .where((a) => a.statoAnnuncio == StatoAnnuncio.concluso)
      .map((a) => a as AnnuncioVendita)
      .toList();
  }

  RiepilogoVendite getRiepilogo(List<AnnuncioVendita> annunci, Abbonamento abbonamento) {
    
    double guadagnoLordo = 0;
    double commissioni = 0;

    final percentualeGuadagni = abbonamento.percentualeGuadagni.toDouble();

    for(final annuncio in annunci) {
      guadagnoLordo += annuncio.prezzo;
      commissioni += annuncio.prezzo * (percentualeGuadagni / 100);
    }

    return RiepilogoVendite(
      importoCommissioni: commissioni,
      numeroVendite: annunci.length, 
      guadagnoLordo: guadagnoLordo, 
      percentualeCommissione: percentualeGuadagni
    );
  }
    
  Widget _buildHeader(Abbonamento abbonamento) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ResQPetColors.primaryDark,
            ResQPetColors.primaryVariant
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Dashboard Vendite',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ResQPetColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: ResQPetColors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Commissione: ${abbonamento.percentualeGuadagni.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: ResQPetColors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String titolo,
    String valore,
    IconData icona,
    Color colore,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ResQPetColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colore.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: colore.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icona, color: colore, size: 28),
            const SizedBox(height: 8),
            Text(
              titolo,
              style: TextStyle(
                fontSize: 12,
                color: ResQPetColors.onBackground.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valore,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colore,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiepilogo(RiepilogoVendite riepilogo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResQPetColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ResQPetColors.primaryDark.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assessment,
                color: ResQPetColors.primaryDark,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Riepilogo',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ResQPetColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                'Vendite',
                '${riepilogo.numeroVendite}',
                Icons.shopping_bag,
                ResQPetColors.accent,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Guadagno Lordo',
                '€ ${riepilogo.guadagnoLordo.toStringAsFixed(2)}',
                Icons.attach_money,
                ResQPetColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                'Guadagno Netto',
                '€ ${riepilogo.guadagnoNetto.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Commissioni',
                '€ ${riepilogo.importoCommissioni.toStringAsFixed(2)}',
                Icons.trending_down,
                const Color(0xFFFF5722),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCardVendita(AnnuncioVendita vendita, Abbonamento abbonamento) {

    final guadagnoNetto = vendita.prezzo - (vendita.prezzo * (abbonamento.percentualeGuadagni.toDouble() / 100));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ResQPetColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ResQPetColors.primaryDark.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ResQPetColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.pets,
                color: ResQPetColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendita.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ResQPetColors.primaryDark,
                    ),
                  ),
                  Text(
                    vendita.razza,
                    style: TextStyle(
                      fontSize: 14,
                      color: ResQPetColors.onBackground.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${guadagnoNetto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaVendite(List<AnnuncioVendita> vendite, Abbonamento abbonamento) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history, color: ResQPetColors.primaryDark, size: 24),
            SizedBox(width: 12),
            Text(
              'Storico Vendite',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ResQPetColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vendite.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: ResQPetColors.onBackground.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessuna vendita nel periodo selezionato',
                    style: TextStyle(
                      fontSize: 16,
                      color: ResQPetColors.onBackground.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...vendite.map((vendita) => _buildCardVendita(vendita, abbonamento)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final abbonamentoAsyncValue = ref.watch(abbonamentoProvider);
    final annunciAsyncValue = ref.watch(annunciPubblicatiProvider);

    return Scaffold(
      backgroundColor: ResQPetColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ResQPetColors.primaryDark,
        iconTheme: const IconThemeData(color: ResQPetColors.primaryDark),
        title: const Text('Dashboard Vendite'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: abbonamentoAsyncValue.when(
          data: (abbonamento) {
            
            return annunciAsyncValue.when(
              data: (annunci) {

                final annunciConclusi = _getAnnunciConclusi(annunci);
                final riepilogo = getRiepilogo(annunciConclusi, abbonamento);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(abbonamento),
                    const SizedBox(height: 20),
                    _buildRiepilogo(riepilogo),
                    const SizedBox(height: 30),
                    if(annunciConclusi.isNotEmpty) 
                      _buildListaVendite(annunciConclusi, abbonamento),
                    const SizedBox(height: 20),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: InfoMessage(
                  message: "Errore durante il caricamento delle statistiche"
                ),
              )
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: InfoMessage(
              message: "Errore durante il caricamento delle statistiche"
            ),
          )
        )
      ),
    );
  }
}