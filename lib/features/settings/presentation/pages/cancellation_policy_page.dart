import 'package:flutter/material.dart';

class CancellationPolicyPage extends StatelessWidget {
  const CancellationPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widerrufsbelehrung'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Widerrufsrecht',
                children: [
                  _buildParagraph(
                    'Sie haben das Recht, binnen vierzehn Tagen ohne '
                    'Angabe von Gründen diesen Vertrag zu widerrufen.',
                  ),
                  _buildParagraph(
                    'Die Widerrufsfrist beträgt vierzehn Tage ab dem Tag '
                    'des Vertragsschlusses.',
                  ),
                  _buildParagraph(
                    'Um Ihr Widerrufsrecht auszuüben, müssen Sie uns',
                  ),
                  _buildContact(),
                  _buildParagraph(
                    'mittels einer eindeutigen Erklärung (z. B. eine per '
                    'E-Mail versandte Nachricht) über Ihren Entschluss, '
                    'diesen Vertrag zu widerrufen, informieren.',
                  ),
                  _buildParagraph(
                    'Sie können hierfür das nachfolgend beigefügte '
                    'Muster-Widerrufsformular verwenden. Dies ist jedoch '
                    'nicht vorgeschrieben.',
                  ),
                  _buildParagraph(
                    'Zur Wahrung der Widerrufsfrist reicht es aus, dass '
                    'Sie die Mitteilung über die Ausübung des Widerrufsrechts '
                    'vor Ablauf der Widerrufsfrist absenden.',
                  ),
                ],
              ),
              _buildSection(
                title: 'Folgen des Widerrufs',
                children: [
                  _buildParagraph(
                    'Wenn Sie diesen Vertrag widerrufen, haben wir Ihnen '
                    'alle Zahlungen, die wir von Ihnen erhalten haben, '
                    'einschließlich der Lieferkosten (mit Ausnahme der '
                    'zusätzlichen Kosten, die sich daraus ergeben, dass '
                    'Sie eine andere Art der Lieferung als die von uns '
                    'angebotene günstigste Standardlieferung gewählt haben), '
                    'unverzüglich und spätestens binnen vierzehn Tagen ab '
                    'dem Tag zurückzuzahlen, an dem die Mitteilung über '
                    'Ihren Widerruf dieses Vertrags bei uns eingegangen ist.',
                  ),
                  _buildParagraph(
                    'Für diese Rückzahlung verwenden wir dasselbe '
                    'Zahlungsmittel, das Sie bei der ursprünglichen '
                    'Transaktion eingesetzt haben, es sei denn, mit Ihnen '
                    'wurde ausdrücklich etwas anderes vereinbart. In keinem '
                    'Fall werden Ihnen wegen dieser Rückzahlung Entgelte '
                    'berechnet.',
                  ),
                  _buildParagraph(
                    'Haben Sie ausdrücklich verlangt, dass die Erbringung '
                    'der digitalen Dienstleistung bereits während der '
                    'Widerrufsfrist beginnen soll, so haben Sie uns für '
                    'die bis zum Zeitpunkt des Widerrufs erbrachte Leistung '
                    'einen angemessenen Betrag zu zahlen, der dem Anteil '
                    'der bis zu diesem Zeitpunkt bereits erbrachten Leistung '
                    'im Verhältnis zum Gesamtumfang der vertraglich '
                    'vorgesehenen Leistung entspricht.',
                  ),
                ],
              ),
              _buildSection(
                title: 'Muster-Widerrufsformular',
                children: [
                  _buildParagraph(
                    'Wenn Sie den Vertrag widerrufen wollen, dann füllen '
                    'Sie bitte dieses Formular aus und senden Sie es zurück.',
                  ),
                  const SizedBox(height: 8),
                  _buildContact(),
                  const SizedBox(height: 16),
                  _buildFormField(
                    'Hiermit widerrufe(n) ich/wir (*) den von mir/uns (*) '
                    'abgeschlossenen Vertrag über die Erbringung der '
                    'folgenden digitalen Dienstleistung:',
                  ),
                  _buildBoldParagraph(
                    'Premium-Abonnement der Haushaltsbuch-App',
                  ),
                  _buildFormField('Bestellt am:'),
                  _buildFormField('Name des/der Verbraucher(s):'),
                  _buildFormField('Anschrift des/der Verbraucher(s):'),
                  _buildFormField('Datum:'),
                  _buildFormField(
                    'Unterschrift des/der Verbraucher(s) '
                    '(nur bei Mitteilung auf Papier):',
                  ),
                  _buildFormField('____________________________'),
                  const SizedBox(height: 8),
                  _buildParagraph(
                    '(*) Unzutreffendes streichen.',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Ende der Widerrufsbelehrung',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) => Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  static Widget _buildBoldParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _buildContact() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        'Marcel Geirhos\n'
        'Gartenstraße 8, 73550 Waldstetten\n'
        'E-Mail: Marcel.Geirhos@gmail.com',
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  static Widget _buildFormField(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }
}
