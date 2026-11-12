enum Environment {
  development,
  production,
}

class AppEnvironment {
  static Environment current = Environment.development;
}
