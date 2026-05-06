abstract class AppCommand {
  const AppCommand();

  String get label;

  bool get recordInHistory => true;
}
