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

  String get resumeUrl => switch (this) {
    Environment.localhost => 'https://devapigee.itnext-dev.com/healthportal-dev/internal/v1/integration-gateway/resume-journey',
    Environment.dev => 'https://devapigee.itnext-dev.com/healthportal-dev/internal/v1/integration-gateway/resume-journey',
    Environment.devNiveus => 'https://devapigee.itnext-dev.com/healthportal-dev/internal/v1/integration-gateway/resume-journey',
    Environment.qa => 'https://devapigee.itnext-dev.com/healthportal-qa/internal/v1/integration-gateway/resume-journey',
    Environment.qaNiveus => 'https://devapigee.itnext-dev.com/healthportal-qa/internal/v1/integration-gateway/resume-journey',
    Environment.uat => 'https://devapigee.itnext-dev.com/healthportal/internal/v1/integration-gateway/resume-journey',
  };

  String get baseUrl => resumeUrl;
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