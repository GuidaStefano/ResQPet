import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/abbonamento_controller.dart';
import 'package:resqpet/controllers/dati_utente_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTitleTap;
  final Widget trailing;

  const HomeCard._({
    super.key,
    required this.title,
    required this.description,
    required this.onTitleTap,
    required this.trailing,
  });

  factory HomeCard.image({
    Key? key,
    required String title,
    required String description,
    VoidCallback? onTitleTap,
    required Image image,
  }) =>  HomeCard._(
    key: key,
    title: title,
    description: description,
    onTitleTap: onTitleTap,
    trailing: image
  );

  factory HomeCard.icon({
    Key? key,
    required String title,
    required String description,
    VoidCallback? onTitleTap,
    required IconData icon,
    Color? iconColor = ResQPetColors.primaryDark,
    double iconSize = 40,
  }) => HomeCard._(
    key: key,
    title: title,
    description: description,
    onTitleTap: onTitleTap,
    trailing: Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ResQPetColors.primaryVariant.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      )
    ),
  );

  @override
  Widget build(BuildContext context) {

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: onTitleTap,
                    icon: const Icon(
                      Icons.arrow_right_alt,
                      color: ResQPetColors.accent,
                      size: 30,
                    ),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: ResQPetColors.accent
                      ),
                    ),
                  ),
                  Text(description),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: trailing,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget navbar({
    bool showProfileButton = false,
    void Function()? onProfileClick
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 150,
          height: 70,
          child: Image.asset("assets/logo-con-scritta.png"),
        ),
        if(showProfileButton) IconButton(
          onPressed: onProfileClick, 
          icon: Icon(
            Icons.account_circle_sharp,
            color: Colors.black,
          )
        )
      ],
    );
  }

  List<Widget> bodyCittadino(BuildContext context) {
    return [
      Text(
        "La tua app, la loro sicurezza,\nSegnala, Adotta, connetti.",
        style: resqpetTheme.textTheme.displaySmall,
        textAlign: TextAlign.start,
      ),
      const SizedBox(height: 50),
      HomeCard.image(
        title: "ADOTTA ORA", 
        description: "scopri gli annunci di adozione", 
        image: Image.asset(
          "assets/card1.jpg",
          height: 120,
          fit: BoxFit.cover
        ),
        onTitleTap: () {
          context.pushNamed(
            Routes.bacheca.name,
            extra: TipoAnnuncio.adozione
          );
        }
      ),
      HomeCard.image(
        title: "AQUISTA", 
        description: "acquista un animale in sicurezza",
        image: Image.asset(
          "assets/card2.jpg",
          height: 120,
          fit: BoxFit.cover
        ),
        onTitleTap: () {
          context.pushNamed(
            Routes.bacheca.name,
            extra: TipoAnnuncio.vendita
          );
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              const Text(
                "Hai trovato un animale abbandonato?\nEffetua una segnalazione, i nostri\nsoccorritori si attiveranno il prima\npossibile",
                textAlign: TextAlign.center
              ),
              SizedBox(height: 10,),
              Image.asset(
                "assets/arrow.png",
              )
            ],
          )
        ]
      )
    ];
  }

  List<Widget> bodyEnte(BuildContext context) {
    return [
      const Text(
        'Pannello Ente',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
        textAlign: TextAlign.start,
      ),
      const SizedBox(height: 50),
      HomeCard.icon(
        title: 'VISUALIZZA ANNUNCI',
        description: 'Visualizza i tuoi annunci pubblicati',
        icon: Icons.newspaper_outlined,
        onTitleTap: () => context.pushNamed(
          Routes.annunciPubblicati.name
        ),
      ),
      HomeCard.icon(
        title: 'VISUALIZZA ANNUNCI IN BOZZA',
        description: 'Visualizza le bozze dei tuoi annunci',
        icon: Icons.raw_on_outlined,
        onTitleTap: () => context.pushNamed(
          Routes.annunciBozze.name
        ),
      )
    ];
  }

  List<Widget> bodyVenditore(BuildContext context) {
    return [
      const Text(
        'Pannello Venditore',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
        textAlign: TextAlign.start,
      ),
      const SizedBox(height: 50),
      HomeCard.icon(
        title: 'VISUALIZZA ANNUNCI',
        description: 'Visualizza i tuoi annunci pubblicati',
        icon: Icons.newspaper_outlined,
        onTitleTap: () => context.pushNamed(
          Routes.annunciPubblicati.name
        ),
      ),
      HomeCard.icon(
        title: 'VISUALIZZA ANNUNCI IN BOZZA',
        description: 'Visualizza le bozze dei tuoi annunci',
        icon: Icons.raw_on_outlined,
        onTitleTap: () => context.pushNamed(
          Routes.annunciBozze.name
        ),
      ),
      HomeCard.icon(
        title: 'VISUALIZZA DASHBOARD VENDITE',
        description: 'Visualizza l\'andamento delle tue vendite',
        icon: Icons.monetization_on_outlined
      )
    ];
  }

  List<Widget> bodySoccorritore(BuildContext context) {
    return [
      const Text(
        'Pannello Soccorritore',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
        textAlign: TextAlign.start,
      ),
      const SizedBox(height: 50),
      HomeCard.icon(
        title: 'VISUALIZZA MAPPA',
        description: 'Visualizza la mappa delle segnalazioni',
        icon: Icons.map_sharp,
        onTitleTap: () => context.pushNamed(Routes.map.name),
      ),
      HomeCard.icon(
        title: 'VISUALIZZA SEGNALAZIONI',
        description: 'Visualizza le tue segnalazioni attualmete in carico',
        icon: Icons.campaign,
        onTitleTap: () => context.pushNamed(Routes.segnalazioniInCarico.name),
      )
    ];
  }

  List<Widget> bodyAdmin(BuildContext context) {
    return [
      const Text(
        'Pannello di amministrazione',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
        textAlign: TextAlign.start,
      ),
      const SizedBox(height: 50),
      HomeCard.icon(
        title: 'GESTIONE UTENTI',
        description: 'Visualizza e gestisci gli utenti',
        icon: Icons.people,
        onTitleTap: () => context.pushNamed(Routes.adminUsers.name)
      ),
      HomeCard.icon(
        title: 'GESTIONE ANNUNCI',
        description: 'Adozioni e vendite',
        icon: Icons.campaign,
         onTitleTap: () => context.pushNamed(Routes.adminAnnunci.name)
      ),
      HomeCard.icon(
        title: 'GESTIONE REPORT',
        description: 'Segnalazioni e moderazione',
        icon: Icons.report,
        onTitleTap: () => context.pushNamed(Routes.adminReports.name),
      ),
      HomeCard.icon(
        title: 'REGISTRA ENTE',
        description: 'Registra un nuovo ente',
        icon: Icons.group_add_outlined,
        onTitleTap: () => context.pushNamed(Routes.adminRegistraEnte.name),
      )
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final datiUtente = ref.watch(datiUtenteProvider);

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home_background.png',
              fit: BoxFit.cover,
            )
          ),
          datiUtente.when(
            data: (utente){
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      navbar(
                        showProfileButton: TipoUtente.admin != utente.tipo,
                        onProfileClick: () {
                          context.pushNamed(Routes.profilo.name);
                        }
                      ),
                      ...switch(utente.tipo) {
                        TipoUtente.admin => bodyAdmin(context),
                        TipoUtente.cittadino => bodyCittadino(context),
                        TipoUtente.soccorritore => bodySoccorritore(context),
                        TipoUtente.venditore => bodyVenditore(context),
                        TipoUtente.ente => bodyEnte(context),
                      }
                    ],
                  ),
                )
              );
            },
            error: (error, _) => Align(
              alignment: AlignmentGeometry.center,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(error.toString())
              ),
            ),
            loading: () => const Align(
              alignment: AlignmentGeometry.center,
              child: CircularProgressIndicator(),
            )
          )
        ],
      ),
      floatingActionButton: datiUtente.whenOrNull(
        data: (utente) {
          
          return switch(utente.tipo) {
            TipoUtente.cittadino => FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed(Routes.creaSegnalazione.name);
              },
              icon: Image.asset(
                "assets/zampa_icon.png",
                width: 40,
                height: 40
              ),
              label: const Text("Segnala")
            ),
            TipoUtente.ente => FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed(
                  Routes.creaAnnuncio.name,
                  pathParameters: {
                    'tipo': TipoAnnuncio.adozione.toFirestore()
                  }
                );
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: const Text("Crea Annuncio")
            ),
            TipoUtente.venditore => FloatingActionButton.extended(
              onPressed: () async {
                
                try {
                  final isAbbonamentoExpired = await ref.read(isAbbonamentoExpiredProvider.future);
                  
                  if(isAbbonamentoExpired) {
                    
                    if(context.mounted) {
                      showErrorSnackBar(context, "Il tuo abbonamento e' scaduto.");
                    }
                    
                    return;
                  }

                  final canPublish = await ref.read(abbonamentoControllerProvider.notifier)
                    .canPublishMoreAd();

                  if(!canPublish) {
                    if(context.mounted) {
                      showErrorSnackBar(context, "Hai superato il limite di annunci consentito.");
                    }

                    return;
                  }

                  if(!context.mounted) return;

                  context.pushNamed(
                    Routes.creaAnnuncio.name,
                    pathParameters: {
                      'tipo': TipoAnnuncio.vendita.toFirestore()
                    }
                  );

                } catch(e) {
                  if(context.mounted) {
                    showErrorSnackBar(context, "Impossibile creare un nuovo annuncio.");
                  }
                }
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: const Text("Crea Annuncio")
            ),
            _ => null
          };
        }
      )
    );
  }
  
}