import '../models/provider_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'auth_service.dart';

class ProviderService {
  static final ProviderService _instance = ProviderService._internal();
  factory ProviderService() => _instance;
  ProviderService._internal();

  final _db = DatabaseService();
  final _auth = AuthService();
  Provider? _cachedCurrentProvider;
  String? _cachedProviderUserId;
  DateTime? _cachedProviderAt;
  static const Duration _providerCacheTtl = Duration(minutes: 3);

  // ─── Provider Profile ──────────────────────────────────────────────────────

  Future<Provider?> getCurrentProvider() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    if (user.role != UserRole.provider) {
      return null;
    }
    if (user.id.isEmpty) return null;

    final now = DateTime.now();
    if (_cachedCurrentProvider != null &&
        _cachedProviderUserId == user.id &&
        _cachedProviderAt != null &&
        now.difference(_cachedProviderAt!) < _providerCacheTtl) {
      return _cachedCurrentProvider;
    }

    final fetched = await _db.getProviderByUserId(user.id);
    if (fetched != null) {
      _cachedCurrentProvider = fetched;
      _cachedProviderUserId = user.id;
      _cachedProviderAt = now;
      return fetched;
    }

    // Fallback to cached value if we were rate-limited by API.
    if (_cachedCurrentProvider != null && _cachedProviderUserId == user.id) {
      return _cachedCurrentProvider;
    }

    return null;
  }

  Future<List<Provider>> getAllProviders() => _db.getAllProviders();

  Future<Provider?> getProviderById(String id) => _db.getProviderById(id);

  Future<bool> updateProvider(Provider updatedProvider) =>
      _db.updateProvider(updatedProvider).then((success) {
        if (success) {
          _cachedCurrentProvider = updatedProvider;
          _cachedProviderUserId = updatedProvider.userId;
          _cachedProviderAt = DateTime.now();
        }
        return success;
      });

  Future<bool> toggleAvailability() async {
    final provider = await getCurrentProvider();
    if (provider == null) return false;

    final updated = provider.copyWith(isAvailable: !provider.isAvailable);
    return updateProvider(updated);
  }

  // ─── Service Management ────────────────────────────────────────────────────

  Future<List<ServiceModel>> getProviderServices([String? providerId]) async {
    final effectiveProviderId = providerId ?? (await getCurrentProvider())?.id;
    if (effectiveProviderId == null) return [];
    return _db.getServicesByProvider(effectiveProviderId);
  }

  Future<bool> createService(ServiceModel service) =>
      _db.insertService(service);

  Future<bool> updateService(ServiceModel service) =>
      _db.updateService(service.id, service.toMap());

  Future<bool> deleteService(String serviceId) => _db.deleteService(serviceId);

  // ─── Discovery & Filtering ─────────────────────────────────────────────────

  Future<List<Provider>> searchProviders(String query) async {
    final all = await getAllProviders();
    return all.where((p) {
      final nameMatches = p.companyName.toLowerCase().contains(
        query.toLowerCase(),
      );
      final descMatches = p.description.toLowerCase().contains(
        query.toLowerCase(),
      );
      return nameMatches || descMatches;
    }).toList();
  }

  Future<List<Provider>> filterProvidersByCategory(String category) async {
    final allServices = await _db.getAllServices();
    final providerIds = allServices
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .map((s) => s.providerId)
        .toSet();

    final allProviders = await getAllProviders();
    return allProviders.where((p) => providerIds.contains(p.id)).toList();
  }
}
