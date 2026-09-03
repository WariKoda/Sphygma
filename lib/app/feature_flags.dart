// Compile-Time-Flags. Gesetzt per
//   flutter run --dart-define=SPHYGMA_ESC=true
// Im Release-Build ohne dart-define ist die Klassifikation AUS (PLAN.md
// §3.2, M6/M7): Sie kann die App zum Medizinprodukt machen; die
// Entscheidung faellt beim Release, nicht in der Architektur.
const bool escClassificationEnabled =
    bool.fromEnvironment('SPHYGMA_ESC', defaultValue: false);
