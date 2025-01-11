class EnvironmentUrls {
  final String resumeJourneyUrl;
  final String continueJourneyUrl;
  final String dropoffUrl;

  const EnvironmentUrls({
    required this.resumeJourneyUrl,
    required this.continueJourneyUrl,
    required this.dropoffUrl,
  });
}

enum Environment {
  localhost('Localhost'),
  dev('DEV'),
  devNiveus('DEV-Niveus'),
  qa('QA'),
  qaNiveus('QA-Niveus'),
  uat('UAT');

  final String displayName;
  const Environment(this.displayName);

  String get baseUrl => switch (this) {
    Environment.localhost => 'https://devapigee.itnext-dev.com/healthportal-dev/internal/v1/integration-gateway',
    Environment.dev => 'https://devapigee.itnext-dev.com/healthportal-dev/internal/v1/integration-gateway',
    Environment.devNiveus => 'https://devapigee.itnext-dev.com/healthportal-dev/internal/v1/integration-gateway',
    Environment.qa => 'https://devapigee.itnext-dev.com/healthportal-qa/internal/v1/integration-gateway',
    Environment.qaNiveus => 'https://devapigee.itnext-dev.com/healthportal-qa/internal/v1/integration-gateway',
    Environment.uat => 'https://devapigee.itnext-dev.com/healthportal/internal/v1/integration-gateway',
  };

  String get dropoffUrl => switch (this) {
    Environment.localhost => 'http://localhost:3000/dropoff-journey',
    Environment.dev => 'https://hp-dev.itnext-dev.com/dropoff-journey',
    Environment.devNiveus => 'https://hp-dev.itnext-dev.com//v2/new/dropoff-journey',
    Environment.qa => 'https://hp-qa.itnext-dev.com/dropoff-journey',
    Environment.qaNiveus => 'https://hp-qa.itnext-dev.com/dropoff-journey',
    Environment.uat => 'https://hp.test-uat.com/dropoff-journey',
  };

  String get resumeUrl => switch (this) {
    Environment.localhost => '$baseUrl/resume-journey',
    Environment.dev => '$baseUrl/resume-journey',
    Environment.devNiveus => '$baseUrl/resume-journey',
    Environment.qa => '$baseUrl/resume-journey',
    Environment.qaNiveus => '$baseUrl/resume-journey',
    Environment.uat => '$baseUrl/resume-journey',
  };

  String get continueUrl => switch (this) {
    Environment.localhost => baseUrl,
    Environment.dev => baseUrl,
    Environment.devNiveus => baseUrl,
    Environment.qa => baseUrl,
    Environment.qaNiveus => baseUrl,
    Environment.uat => baseUrl,
  };

  String get authUrl => 'https://devapigee.itnext-dev.com/api/v1/auth/token';

  String modifyRedirectUrl(String url) {
    if (this == Environment.localhost) {
      return url.replaceAll('https://hp-dev.itnext-dev.com', 'http://localhost:3000');
    } else if (this == Environment.devNiveus) {
      return url.replaceAll('https://hp-dev.itnext-dev.com', 'https://hp-dev.itnext-dev.com/v2/new');
    }
    return url;
  }
} 