class ApiConstants {
  // Cloudflare Worker mock API - will be updated with actual URL after deploy
  static const baseUrl = 'https://smart-fujairah-api.waleedalrashed.workers.dev';

  static const categories = '/api/categories';
  static const services = '/api/services';
  static const announcements = '/api/announcements';
  static const requests = '/api/requests';
  static const upload = '/api/upload';

  static String categoryServices(int categoryId) => '/api/categories/$categoryId/services';
  static String serviceDetail(int serviceId) => '/api/services/$serviceId';
  static String searchServices(String query) => '/api/services/search?q=$query';
}
