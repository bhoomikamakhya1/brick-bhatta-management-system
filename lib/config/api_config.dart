class ApiConfig {
  // Update these with your actual FastAPI backend credentials
  static const String baseUrl = "https://brick-bhatta-backend.onrender.com";
  static const String apiKey = "brick_bhatta_123"; // Your actual API key
  static const String tenantId = "kiln-001"; // Your tenant ID
  
  // API Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'X-API-KEY': apiKey,
    'X-Tenant-ID': tenantId,
  };
  
  // API Endpoints
  static const String namesEndpoint = '/api/names';
  static const String healthEndpoint = '/health';
  
  // Full URLs
  static String get namesUrl => '$baseUrl$namesEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
  
  // Helper method to get name URL with ID
  static String getNameUrl(String id) => '$baseUrl$namesEndpoint/$id';
}
