import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'models/user.dart';
import 'models/environment.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

String? _accessToken;

Map<String, dynamic> createQuickQuotePayload(User user) {
  return {
    "agentCode": "1337ab2d-ef71-4465-b6dc-d598e9967940",
    "uniqueIntegrationId": "PC51124021927789",
    "integrationUserId": user.integrationUserId,
    "intermediaryCode": user.intermediaryCode,
    "redirectUrl": "https://1up-uat.hdfcergo.com/v3/dashBoardScreen?id=2",
    "integrationUserDisplayName": null,
    "agentDealId": null,
    "agentVerticalCode": "null",
    "agentCampaignName": null,
    "agentPospCode": null,
    "agentPospName": null,
    "intermediaryName": null,
    "intermediaryStateName": null,
    "intermediaryOfficeCode": null,
    "intermediaryVerticalDescription": null,
    "intermediaryOfficeTelephone": null,
    "parentIntermediaryCode": null,
    "parentIntermediaryName": null,
    "parentIntermediaryOfficeTelephone": "NA",
    "requestTracking": {
        "correlationId": null,
        "urlReferrer": null,
        "customerIp": null,
        "deviceInfo": null,
        "queryStringInfo": null
    },
    "proposerDetail": {
        "salutationName": null,
        "firstname": "Test User",
        "middlename": null,
        "lastname": null,
        "gender": "MALE",
        "mobileNo": "9999999999",
        "emailId": "test@test.com",
        "age": 30,
        "dateOfBirth": "11/06/1989",
        "addressLine1": "Address 01",
        "addressLine2": null,
        "addressLine3": null,
        "cityName": "Mumbai",
        "stateName": "Maharashtra",
        "pincode": "400001",
        "cityId": 0,
        "correspondenceAddressLine1": null,
        "correspondenceAddressLine2": null,
        "correspondenceAddressLine3": null,
        "correspondenceCityName": null,
        "correspondenceStateName": null,
        "correspondencePincode": 0,
        "nationality": null,
        "maritalStatus": null,
        "occupation": null,
        "annualIncome": 5000000,
        "haveExistingCover": false,
        "pehchaanId": null,
        "gstInNumber": null,
        "panCardNumber": ""
    },
    "insuredMembers": [
        {
            "dateOfBirth": "11/06/1989",
            "genderCode": "MALE",
            "isDiabetic": false,
            "relationShipCode": "SELF",
            "relationShipName": "SELF",
            "bmiHeight": "55",
            "bmiWeight": null,
            "isAdult": true
        },
        {
            "firstName": "LOL",
            "middleName": null,
            "lastName": null,
            "age": 29,
            "dateOfBirth": "30/07/1994",
            "genderCode": "FEMALE",
            "isDiabetic": false,
            "relationShipCode": "SPOUSE",
            "relationShipName": "WIFE",
            "bmiHeight": "56",
            "bmiWeight": null,
            "isAdult": true
        }
    ],
    "planDetail": {}
  };
}

Map<String, dynamic> createNewQuotePayload(User user) {
  return {
    "agentCode": "1337ab2d-ef71-4465-b6dc-d598e9967940",
    "integrationUserId": user.integrationUserId,
    "uniqueIntegrationId": "PC51124021927789",
    "intermediaryCode": user.intermediaryCode,
    "redirectUrl": "https://1up-uat.hdfcergo.com/v3/dashBoardScreen?id=2"
  };
}

const Map<String, String> authCredentials = {
  'grant_type': 'client_credentials',
  'client_id': 'vzO5HEH9CQPkQBqMmNKvzwTVokBHDKUMFoqZkjAayADTTrlw',
  'client_secret': 'GvBaPG3NAGvA21wzscpTG11XQVGpfr6qaRTMUYJZb5xrb9uxtfkN0HYqRZIrVi2R',
};

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true); // This will be true only in debug mode
  return inDebugMode;
}

void log(String message) {
  if (isInDebugMode) {
    print(message);
  }
}

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiry = prefs.getInt(_tokenExpiryKey);
    
    if (token != null && expiry != null) {
      if (DateTime.now().millisecondsSinceEpoch < expiry) {
        return token;
      }
    }
    return null;
  }
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    // Set token expiry to 55 minutes from now (assuming 1 hour token life)
    final expiry = DateTime.now().add(const Duration(minutes: 55)).millisecondsSinceEpoch;
    
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_tokenExpiryKey, expiry);
  }
  
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(150, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Portal Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<Environment, User> _selectedUsers = {
    for (var env in Environment.values) env: users[0]
  };

  final Map<Environment, TextEditingController> _uuidControllers = {
    for (var env in Environment.values) 
      env: TextEditingController()
  };
  
  final Map<Environment, bool> _isValidUuids = {
    for (var env in Environment.values)
      env: false
  };

  final Map<Environment, String?> _apiErrors = {
    for (var env in Environment.values)
      env: null
  };

  @override
  void dispose() {
    for (var controller in _uuidControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _validateUuid(String uuid) {
    final RegExp uuidRegExp = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegExp.hasMatch(uuid);
  }

  void _openWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: url,
          title: title,
        ),
      ),
    );
  }

  void _navigateToWebView(String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: url,
          title: title,
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _makeResumeJourneyRequest({
    required String resumeUrl,
    required String authUrl,
    required Map<String, dynamic> payload,
    required String environment,
    required Function retryCallback,
  }) async {
    try {
      log('Starting $environment request...');
      log('Auth URL: $authUrl');
      log('Resume URL: $resumeUrl');
      log('Payload: ${jsonEncode(payload)}');
      
      _accessToken = await _getAuthToken(authUrl);
      if (_accessToken == null) {
        log('Failed to get auth token');
        return null;
      }

      log('Making resume journey request with token: $_accessToken');
      final response = await http.post(
        Uri.parse(resumeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('Request timed out');
          throw TimeoutException('The request timed out');
        },
      );

      log('Resume Journey Response Status: ${response.statusCode}');
      log('Resume Journey Response Headers: ${response.headers}');
      log('Resume Journey Response Body: ${response.body}');

      if (response.statusCode == 401) {
        log('Token expired, clearing cache and retrying...');
        await TokenManager.clearToken();
        _accessToken = null;
        return retryCallback();
      }

      return jsonDecode(response.body);
    } catch (e, stackTrace) {
      log('Error occurred: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> _getAuthToken(String authUrl) async {
    // First try to get cached token
    _accessToken = await TokenManager.getToken();
    if (_accessToken != null) {
      log('Using cached token: $_accessToken');
      return _accessToken;
    }

    log('No valid token found, requesting new token...');
    try {
      final formData = {
        'grant_type': 'client_credentials',
        'client_id': 'vzO5HEH9CQPkQBqMmNKvzwTVokBHDKUMFoqZkjAayADTTrlw',
        'client_secret': 'GvBaPG3NAGvA21wzscpTG11XQVGpfr6qaRTMUYJZb5xrb9uxtfkN0HYqRZIrVi2R',
      };

      log('Auth Request URL: $authUrl');
      log('Auth Request Body: ${Uri(queryParameters: formData).query}');

      final authResponse = await http.post(
        Uri.parse(authUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: Uri(queryParameters: formData).query,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('Auth request timed out');
          throw TimeoutException('Auth request timed out');
        },
      );
      
      log('Auth Response Status: ${authResponse.statusCode}');
      log('Auth Response Body: ${authResponse.body}');
      
      if (authResponse.statusCode == 200) {
        final authData = jsonDecode(authResponse.body);
        _accessToken = authData['access_token'];
        await TokenManager.saveToken(_accessToken!);
        log('New token received and cached: $_accessToken');
        return _accessToken;
      } else {
        log('Failed to get token. Status: ${authResponse.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      log('Error getting auth token: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> _handleNewQuote(Environment env) async {
    try {
      log('=== Starting New Quote Request ===');
      log('Environment: ${env.displayName}');
      log('Base URL: ${env.baseUrl}');
      log('Resume URL: ${env.resumeUrl}');
      log('Auth URL: ${env.authUrl}');
      
      final payload = createNewQuotePayload(_selectedUsers[env]!);
      log('New Quote Payload:');
      log(JsonEncoder.withIndent('  ').convert(payload));
      
      _showLoadingDialog();

      final responseData = await _makeResumeJourneyRequest(
        resumeUrl: env.resumeUrl,
        authUrl: env.authUrl,
        payload: payload,
        environment: 'New Quote ${env.displayName}',
        retryCallback: () => _handleNewQuote(env),
      );

      // Always dismiss loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (responseData != null && responseData['responseData']?['redirectUrl'] != null) {
        final redirectUrl = env.modifyRedirectUrl(
          responseData['responseData']['redirectUrl']
        );
        log('Original Redirect URL: ${responseData['responseData']['redirectUrl']}');
        log('Modified Redirect URL: $redirectUrl');
        
        if (context.mounted) {
          _navigateToWebView(
            redirectUrl,
            'Portal ${env.displayName}',
          );
        }
      } else {
        log('Error: No redirectUrl found in response');
        if (responseData != null) {
          log('Response Data Structure:');
          log(JsonEncoder.withIndent('  ').convert(responseData));
        } else {
          log('Response Data is null');
        }
        
        // Show error dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to get redirect URL. Please check logs for details.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      log('Error in _handleNewQuote: $e');
      log('Stack trace: $stackTrace');
      
      // Always dismiss loading dialog on error
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      log('=== End New Quote Request ===\n');
    }
  }

  Future<void> _handleQuickQuote(Environment env) async {
    try {
      log('=== Starting Quick Quote Request ===');
      log('Environment: ${env.displayName}');
      log('Base URL: ${env.baseUrl}');
      log('Resume URL: ${env.resumeUrl}');
      log('Auth URL: ${env.authUrl}');
      
      final payload = createQuickQuotePayload(_selectedUsers[env]!);
      log('Quick Quote Payload:');
      log(JsonEncoder.withIndent('  ').convert(payload));
      
      _showLoadingDialog();

      final responseData = await _makeResumeJourneyRequest(
        resumeUrl: env.resumeUrl,
        authUrl: env.authUrl,
        payload: payload,
        environment: 'Quick Quote ${env.displayName}',
        retryCallback: () => _handleQuickQuote(env),
      );

      // Always dismiss loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (responseData != null && responseData['responseData']?['redirectUrl'] != null) {
        final redirectUrl = env.modifyRedirectUrl(
          responseData['responseData']['redirectUrl']
        );
        log('Original Redirect URL: ${responseData['responseData']['redirectUrl']}');
        log('Modified Redirect URL: $redirectUrl');
        
        if (context.mounted) {
          _navigateToWebView(
            redirectUrl,
            'Portal ${env.displayName}',
          );
        }
      } else {
        log('Error: No redirectUrl found in response');
        if (responseData != null) {
          log('Response Data Structure:');
          log(JsonEncoder.withIndent('  ').convert(responseData));
        } else {
          log('Response Data is null');
        }
        
        // Show error dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to get redirect URL. Please check logs for details.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      log('Error in _handleQuickQuote: $e');
      log('Stack trace: $stackTrace');
      
      // Always dismiss loading dialog on error
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      log('=== End Quick Quote Request ===\n');
    }
  }

  Future<void> _handleContinueJourney(Environment env) async {
    try {
      final prospectId = _uuidControllers[env]!.text;
      final user = _selectedUsers[env]!;
      
      log('=== Starting Continue Journey Request ===');
      log('Environment: ${env.displayName}');
      log('Base URL: ${env.baseUrl}');
      log('Auth URL: ${env.authUrl}');
      log('Prospect ID: $prospectId');
      
      _accessToken = await _getAuthToken(env.authUrl);
      if (_accessToken == null) {
        log('Failed to get auth token');
        return;
      }

      final payload = {
        "agentCode": "1337ab2d-ef71-4465-b6dc-d598e9967940",
        "integrationUserId": user.integrationUserId,
      };

      log('Continue Journey Payload:');
      log(JsonEncoder.withIndent('  ').convert(payload));

      _showLoadingDialog();

      final url = '${env.continueUrl}/$prospectId/resume-journey';
      log('Continue Journey URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'x-trace-id': '${DateTime.now().millisecondsSinceEpoch}',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('Request timed out');
          throw TimeoutException('The request timed out');
        },
      );

      log('Continue Journey Response Status: ${response.statusCode}');
      log('Continue Journey Response Headers: ${response.headers}');
      log('Continue Journey Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Continue Journey Response Data:');
        log(JsonEncoder.withIndent('  ').convert(responseData));
        
        // Check for error in response footer first
        if (responseData['responseFooter']?['status'] == 'FAILED') {
          final validationMessage = responseData['responseFooter']?['validations']?['validations']?[0]?['detail'] ??
                                  responseData['responseFooter']?['validations']?['message'] ??
                                  responseData['responseFooter']?['message'] ??
                                  'Unknown error occurred';
          setState(() {
            _apiErrors[env] = validationMessage;
          });
          if (context.mounted) {
            Navigator.pop(context); // Dismiss loading
          }
          return; // Return early without navigating to webview
        }

        // Only proceed to webview if we have valid responseData
        if (responseData['responseData'] != null) {
          final redirectUrl = env.modifyRedirectUrl(responseData['responseData']);
          log('Original Redirect URL: ${responseData['responseData']}');
          log('Modified Redirect URL: $redirectUrl');
          
          if (context.mounted) {
            Navigator.pop(context); // Dismiss loading
            _navigateToWebView(redirectUrl, 'Portal ${env.displayName}');
          }
        } else {
          if (context.mounted) {
            Navigator.pop(context); // Dismiss loading
          }
          setState(() {
            _apiErrors[env] = 'No redirect URL in response';
          });
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
        }
        setState(() {
          _apiErrors[env] = 'Invalid Prospect ID';
        });
      }
    } catch (e, stackTrace) {
      log('Error in continue journey: $e');
      log('Stack trace: $stackTrace');
      if (context.mounted) {
        Navigator.pop(context); // Ensure loading is dismissed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to continue journey: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      log('=== End Continue Journey Request ===\n');
    }
  }

  void _handleDropoff(Environment env) {
    final prospectId = _uuidControllers[env]!.text;
    final dropoffUrl = '${env.dropoffUrl}?prospectId=$prospectId';
    
    log('=== Handling Dropoff ===');
    log('Environment: ${env.displayName}');
    log('Prospect ID: $prospectId');
    log('Dropoff URL: $dropoffUrl');
    
    _navigateToWebView(dropoffUrl, 'Dropoff ${env.displayName}');
  }

  void _showDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Device Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device: ${androidInfo.manufacturer} ${androidInfo.model}'),
              Text('Android Version: ${androidInfo.version.release}'),
              Text('SDK Version: ${androidInfo.version.sdkInt}'),
              Text('Brand: ${androidInfo.brand}'),
              Text('Device: ${androidInfo.device}'),
              Text('Hardware: ${androidInfo.hardware}'),
              Text('Product: ${androidInfo.product}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Device Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${iosInfo.name}'),
              Text('Model: ${iosInfo.model}'),
              Text('System Name: ${iosInfo.systemName}'),
              Text('System Version: ${iosInfo.systemVersion}'),
              Text('Machine: ${iosInfo.utsname.machine}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Environment Cards
                for (final env in Environment.values)
                  Card(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Text(
                              env.displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<User>(
                                  value: _selectedUsers[env],
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                  items: users.map((User user) {
                                    return DropdownMenuItem<User>(
                                      value: user,
                                      child: Text(
                                        '${user.displayName} (${user.integrationUserId})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (User? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedUsers[env] = newValue;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _handleNewQuote(env),
                                      icon: const Icon(Icons.add_circle_outline),
                                      label: const Text('New Quote'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _handleQuickQuote(env),
                                      icon: const Icon(Icons.flash_on),
                                      label: const Text('Quick Quote'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _uuidControllers[env],
                                        decoration: InputDecoration(
                                          labelText: 'Prospect ID',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          errorText: _apiErrors[env] ?? 
                                            (_uuidControllers[env]!.text.isNotEmpty && !_isValidUuids[env]!
                                              ? 'Please enter valid Prospect ID'
                                              : null),
                                        ),
                                        onTap: () {
                                          if (_uuidControllers[env]!.text.isEmpty) {
                                            _uuidControllers[env]!.clear();
                                          }
                                          // Clear API error when user starts typing again
                                          if (_apiErrors[env] != null) {
                                            setState(() {
                                              _apiErrors[env] = null;
                                            });
                                          }
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            _isValidUuids[env] = _validateUuid(value);
                                            // Clear API error when user changes the input
                                            _apiErrors[env] = null;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: _isValidUuids[env]! ? () => _handleContinueJourney(env) : null,
                                            icon: const Icon(Icons.play_arrow),
                                            label: const Text('Continue'),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: _isValidUuids[env]! ? () => _handleDropoff(env) : null,
                                            icon: const Icon(Icons.stop),
                                            label: const Text('Drop-Off'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Test Card
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('TEST', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(100, 40),
                                ),
                                onPressed: () => _openWebView('http://localhost:3000/?agentCode=d4ed1852-32b0-43b1-b92f-cf0937b824a0', 'TEST'),
                                child: const Text('Open'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(100, 40),
                                ),
                                onPressed: _showDeviceInfo,
                                child: const Text('Device Info'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WebViewPage extends StatelessWidget {
  final String url;
  final String title;

  const WebViewPage({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(title),
        actions: title == 'Portal Localhost' ? [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(
                      url: url,
                      title: title,
                    ),
                  ),
                );
              }
            },
          ),
        ] : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
      ),
    );
  }
}