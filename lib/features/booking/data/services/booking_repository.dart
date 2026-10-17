import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/app_runtime.dart';
import '../../../home/data/models/washer_card_data.dart';
import '../models/order_summary_draft.dart';
import '../models/payment_method_data.dart';
import '../models/reservation_data.dart';
import '../models/service_addon.dart';
import '../models/service_package.dart';
import '../models/washer_details_data.dart';

class BookingRepository {
  const BookingRepository();

  static const String _defaultWasherAsset = 'assets/images/service_car.svg';

  bool get usesFirestoreBackend => AppRuntime.supportsFirebaseBackend;

  Future<WasherDetailsData> loadWasherDetails({
    required String washerId,
    WasherCardData? preview,
  }) async {
    if (!usesFirestoreBackend) {
      return _fallbackWasherDetails(preview: preview, washerId: washerId);
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference<Map<String, dynamic>> laveurRef = firestore
        .collection('laveurs')
        .doc(washerId);
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = currentUser?.uid == washerId;

    try {
      final List<Future<Object>> requests = <Future<Object>>[
        firestore.collection('pub_laveurs').doc(washerId).get(),
        laveurRef
            .collection('services')
            .where('published', isEqualTo: true)
            .get(),
        laveurRef
            .collection('addons')
            .where('published', isEqualTo: true)
            .get(),
      ];
      if (isOwner) {
        requests.insert(1, laveurRef.get());
      }

      final List<Object> results = await Future.wait<Object>(requests);

      final DocumentSnapshot<Map<String, dynamic>> publicSnapshot =
          results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final DocumentSnapshot<Map<String, dynamic>>? privateSnapshot = isOwner
          ? results[1] as DocumentSnapshot<Map<String, dynamic>>
          : null;
      final QuerySnapshot<Map<String, dynamic>> servicesSnapshot =
          results[isOwner ? 2 : 1] as QuerySnapshot<Map<String, dynamic>>;
      final QuerySnapshot<Map<String, dynamic>> addonsSnapshot =
          results[isOwner ? 3 : 2] as QuerySnapshot<Map<String, dynamic>>;

      final Map<String, dynamic> publicData = publicSnapshot.data() ?? {};
      final Map<String, dynamic> privateData = privateSnapshot?.data() ?? {};
      final Map<String, dynamic> laveurData =
          _asMap(privateData['laveurData']) ??
          _asMap(privateData['LaveurData']) ??
          <String, dynamic>{};
      final List<ServicePackage> packages = _buildPackages(servicesSnapshot.docs);
      final List<ServiceAddon> addons = _buildAddons(addonsSnapshot.docs);

      return WasherDetailsData(
        id: washerId,
        name:
            _readString(publicData['businessName']) ??
            _readString(publicData['fullName']) ??
            _readString(privateData['businessName']) ??
            _readString(privateData['fullName']) ??
            preview?.title ??
            'Go Wash Pro',
        subtitle:
            _readBusinessTypeLabel(
              _readStringList(
                publicData['businessTypes'] ??
                    privateData['businessTypes'] ??
                    laveurData['businessTypes'] ??
                    laveurData['services'],
              ),
            ) ??
            preview?.subtitle ??
            'Mobile Detailer',
        description:
            _readString(publicData['description']) ??
            _readString(privateData['description']) ??
            _readString(laveurData['description']) ??
            'Professional mobile car detailer ready to come to you whenever your car needs attention.',
        ratingLabel:
            preview?.rating ??
            _formatRating(
              _readDouble(publicData['rating']) ??
                  _readDouble(privateData['rating']) ??
                  _readDouble(laveurData['rating']),
            ),
        reviewLabel:
            preview?.reviews ??
            _formatJobCount(
              _readInt(publicData['completedJobs']) ??
                  _readInt(privateData['completedJobs']) ??
                  _readInt(laveurData['completedJobs']) ??
                  0,
            ),
        rankLabel: preview?.rank ?? '#1',
        badgeLabel: preview?.badge ?? 'Top washer',
        locationPrimary:
            preview?.city ??
            _cityFromLocation(
              _asMap(publicData['location']) ??
                  _asMap(privateData['location']) ??
                  _asMap(laveurData['location']),
            ),
        locationSecondary:
            _locationDescription(
              _asMap(publicData['location']) ??
                  _asMap(privateData['location']) ??
                  _asMap(laveurData['location']),
            ) ??
            'Service area',
        imageAsset: preview?.imageAsset ?? _defaultWasherAsset,
        vehicleCategories: _buildVehicleCategories(packages, addons),
        packages: packages,
        addons: addons,
        galleryImageUrls: _readGalleryUrls(publicData, privateData, laveurData),
        coverImageUrl:
            _readPrimaryImageUrl(publicData) ??
            _readPrimaryImageUrl(privateData) ??
            preview?.imageUrl,
        avatarImageUrl:
            _readString(publicData['logoUrl']) ??
            _readString(privateData['logoUrl']) ??
            _firstString(_readGalleryUrls(publicData, privateData, laveurData)) ??
            preview?.imageUrl,
        phoneNumber:
            _readString(publicData['phoneNumber']) ??
            _readString(privateData['phoneNumber']) ??
            _readString(laveurData['phoneNumber']),
        preview: preview,
      );
    } catch (_) {
      return _fallbackWasherDetails(preview: preview, washerId: washerId);
    }
  }

  Future<List<PaymentMethodData>> loadPaymentMethods() async {
    if (!usesFirestoreBackend) {
      return _fallbackPaymentMethods();
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return <PaymentMethodData>[];
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final List<PaymentMethodData> subcollectionMethods =
        await _loadPaymentMethodsFromUserSubcollection(
          firestore: firestore,
          userId: user.uid,
        );
    if (subcollectionMethods.isNotEmpty) {
      return subcollectionMethods;
    }

    final List<PaymentMethodData> topLevelMethods =
        await _loadTopLevelPaymentMethods(
          firestore: firestore,
          userId: user.uid,
        );
    if (topLevelMethods.isNotEmpty) {
      return topLevelMethods;
    }

    return _loadPaymentMethodsFromPaymentsDocument(
      firestore: firestore,
      userId: user.uid,
    );
  }

  Stream<List<ReservationData>> watchReservations() {
    if (!usesFirestoreBackend) {
      return Stream<List<ReservationData>>.value(_fallbackReservations());
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream<List<ReservationData>>.value(const <ReservationData>[]);
    }

    return FirebaseFirestore.instance
        .collection('reservations')
        .where('clientId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final List<ReservationData> reservations = snapshot.docs
              .map((doc) => _reservationFromDocument(doc))
              .toList()
            ..sort((a, b) {
              final DateTime aDate = a.scheduledAt ?? DateTime(1970);
              final DateTime bDate = b.scheduledAt ?? DateTime(1970);
              return bDate.compareTo(aDate);
            });
          return reservations;
        });
  }

  Future<String> createReservation({
    required OrderSummaryDraft draft,
    required PaymentMethodData paymentMethod,
  }) async {
    if (!usesFirestoreBackend) {
      return 'preview-order';
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in before creating a reservation.');
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final Map<String, dynamic> userData = userSnapshot.data() ?? {};
    final DocumentReference<Map<String, dynamic>> reservationRef = firestore
        .collection('reservations')
        .doc();
    final DateTime now = DateTime.now().toUtc();
    final String referenceCode =
        '#TXN-${now.millisecondsSinceEpoch.toString().substring(5)}';

    await reservationRef.set({
      'id': reservationRef.id,
      'referenceCode': referenceCode,
      'clientId': user.uid,
      'userId': user.uid,
      'customerId': user.uid,
      'laveurId': draft.washerId,
      'washerId': draft.washerId,
      'washerName': draft.washerName,
      'washerPhoneNumber': draft.washerPhoneNumber,
      'vehicleCategory': draft.vehicleCategory,
      'packageId': draft.selectedPackage.id,
      'packageName': draft.selectedPackage.name,
      'addonIds': draft.selectedAddons.map((item) => item.id).toList(),
      'addonNames': draft.selectedAddons.map((item) => item.name).toList(),
      'totalPrice': draft.totalPrice,
      'paymentMethodId': paymentMethod.id,
      'paymentMethodTitle': paymentMethod.title,
      'paymentMethodSubtitle': paymentMethod.subtitle,
      'status': 'in_progress',
      'progressLabel': '~ 30 min',
      'scheduledAt': now.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'clientSnapshot': {
        'id': user.uid,
        'fullName':
            _readString(userData['fullName']) ??
            _readString(user.displayName) ??
            'Client',
        'email': _readString(userData['email']) ?? _readString(user.email),
        'phoneNumber': _readString(userData['phoneNumber']),
      },
      'washerSnapshot': {
        'id': draft.washerId,
        'name': draft.washerName,
        'subtitle': draft.washerSubtitle,
        'imageUrl': draft.washerImageUrl,
        'imageAsset': draft.washerImageAsset,
      },
      'serviceSnapshot': {
        'id': draft.selectedPackage.id,
        'name': draft.selectedPackage.name,
        'features': draft.selectedPackage.features,
        'price': draft.selectedPackage.priceFor(draft.vehicleCategory),
      },
      'selectedAddons': draft.selectedAddons
          .map(
            (addon) => <String, dynamic>{
              'id': addon.id,
              'name': addon.name,
              'price': addon.priceFor(draft.vehicleCategory),
            },
          )
          .toList(),
    });

    return reservationRef.id;
  }

  List<ServicePackage> _buildPackages(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final List<ServicePackage> packages = docs
        .map((doc) {
          final Map<String, dynamic> data = doc.data();
          return ServicePackage(
            id: _readString(data['id']) ?? doc.id,
            name: _readString(data['name']) ?? 'Package',
            features: _readStringList(data['features']),
            addonIds: _readStringList(data['addonIds']),
            prices: _readPriceMap(data['prices']),
            position: _readInt(data['position']) ?? 0,
            isBestOffer: _readBool(data['isBestOffer']),
            published: !_hasValue(data['published']) || _readBool(data['published']),
            vehicleCategory: _readString(data['vehicleCategory']),
          );
        })
        .where((item) => item.published)
        .toList()
      ..sort((a, b) {
        final int positionCompare = a.position.compareTo(b.position);
        if (positionCompare != 0) {
          return positionCompare;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return packages;
  }

  List<ServiceAddon> _buildAddons(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final List<ServiceAddon> addons = docs
        .map((doc) {
          final Map<String, dynamic> data = doc.data();
          return ServiceAddon(
            id: _readString(data['id']) ?? doc.id,
            name: _readString(data['name']) ?? 'Add-on',
            basePrice: _readDouble(data['basePrice']) ?? 0,
            categoryPrices: _readPriceMap(data['categoryPrices']),
            position: _readInt(data['position']) ?? 0,
            published: !_hasValue(data['published']) || _readBool(data['published']),
            iconKey: _readString(data['iconPath']),
            vehicleCategory: _readString(data['vehicleCategory']),
          );
        })
        .where((item) => item.published)
        .toList()
      ..sort((a, b) {
        final int positionCompare = a.position.compareTo(b.position);
        if (positionCompare != 0) {
          return positionCompare;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return addons;
  }

  List<String> _buildVehicleCategories(
    List<ServicePackage> packages,
    List<ServiceAddon> addons,
  ) {
    final Set<String> categories = <String>{};
    for (final ServicePackage package in packages) {
      categories.addAll(package.prices.keys.where((item) => item.isNotEmpty));
      final String? category = package.vehicleCategory?.trim().toLowerCase();
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }
    for (final ServiceAddon addon in addons) {
      categories.addAll(
        addon.categoryPrices.keys.where((item) => item.isNotEmpty),
      );
      final String? category = addon.vehicleCategory?.trim().toLowerCase();
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }

    if (categories.isEmpty) {
      return <String>['sedan'];
    }

    final List<String> orderedCategories = <String>[
      if (categories.contains('small')) 'small',
      if (categories.contains('sedan')) 'sedan',
      if (categories.contains('suv')) 'suv',
      ...categories.where((item) => item != 'small' && item != 'sedan' && item != 'suv'),
    ];
    return orderedCategories;
  }

  List<String> _readGalleryUrls(
    Map<String, dynamic> publicData,
    Map<String, dynamic> privateData,
    Map<String, dynamic> laveurData,
  ) {
    final List<String> urls =
        _readStringList(publicData['galleryUrls']) +
        _readStringList(privateData['galleryUrls']) +
        _readStringList(laveurData['galleryUrls']);
    return urls.toSet().toList();
  }

  String? _readPrimaryImageUrl(Map<String, dynamic> data) {
    return _firstString(_readStringList(data['galleryUrls'])) ??
        _readString(data['bannerUrl']) ??
        _readString(data['logoUrl']) ??
        _readString(data['imageUrl']);
  }

  String? _readBusinessTypeLabel(List<String> values) {
    final List<String> formatted = values
        .take(2)
        .map((item) {
          switch (item.trim().toLowerCase()) {
            case 'car':
              return 'Car Wash';
            case 'interior':
              return 'Interior Care';
            case 'exterior':
              return 'Exterior Care';
            default:
              return _titleCase(item);
          }
        })
        .where((item) => item.isNotEmpty)
        .toList();
    if (formatted.isEmpty) {
      return null;
    }
    return formatted.join(' • ');
  }

  String _formatRating(double? rating) {
    if (rating == null || rating <= 0) {
      return 'New';
    }
    return rating.toStringAsFixed(1);
  }

  String _formatJobCount(int count) {
    if (count <= 1) {
      return '$count Review';
    }
    return '$count Reviews';
  }

  String _cityFromLocation(Map<String, dynamic>? location) {
    final String? address = _readString(location?['address']);
    if (address == null) {
      return 'Nearby';
    }

    final List<String> parts = address
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return parts[parts.length - 2];
    }
    return parts.isEmpty ? 'Nearby' : parts.first;
  }

  String? _locationDescription(Map<String, dynamic>? location) {
    final String? address = _readString(location?['address']);
    if (address == null) {
      return null;
    }

    final List<String> parts = address
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts[parts.length - 1]}';
    }
    return parts.isEmpty ? null : parts.first;
  }

  ReservationData _reservationFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    final Map<String, dynamic> washerSnapshot =
        _asMap(data['washerSnapshot']) ?? <String, dynamic>{};
    final Map<String, dynamic> serviceSnapshot =
        _asMap(data['serviceSnapshot']) ?? <String, dynamic>{};

    return ReservationData(
      id: doc.id,
      status: _readString(data['status']) ?? 'in_progress',
      referenceCode:
          _readString(data['referenceCode']) ?? '#TXN-${doc.id.substring(0, 8)}',
      washerName:
          _readString(data['washerName']) ??
          _readString(washerSnapshot['name']) ??
          _readString(washerSnapshot['fullName']) ??
          'Go Wash Pro',
      vehicleCategory:
          _readString(data['vehicleCategory']) ??
          _readString(data['vehicleType']) ??
          'sedan',
      packageName:
          _readString(data['packageName']) ??
          _readString(serviceSnapshot['name']) ??
          'Full Wash',
      addonNames:
          _readStringList(data['addonNames']).isNotEmpty
              ? _readStringList(data['addonNames'])
              : _readAddonNames(data['selectedAddons']),
      totalPrice:
          _readDouble(data['totalPrice']) ??
          _readDouble(data['total']) ??
          _readDouble(data['amount']) ??
          _readDouble(serviceSnapshot['price']) ??
          0,
      scheduledAt:
          _readDateTime(data['scheduledAt']) ??
          _readDateTime(data['reservationDate']) ??
          _readDateTime(data['createdAt']),
      progressLabel: _readString(data['progressLabel']) ?? _readString(data['eta']),
      washerPhoneNumber:
          _readString(data['washerPhoneNumber']) ??
          _readString(washerSnapshot['phoneNumber']),
      invoiceUrl: _readString(data['invoiceUrl']) ?? _readString(data['factureUrl']),
    );
  }

  List<String> _readAddonNames(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
            if (item is Map) {
              return _readString(item['name']);
            }
            return _readString(item);
          })
          .whereType<String>()
          .toList();
    }
    return <String>[];
  }

  Future<List<PaymentMethodData>> _loadPaymentMethodsFromUserSubcollection({
    required FirebaseFirestore firestore,
    required String userId,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .get();
      return _parsePaymentMethodDocuments(snapshot.docs);
    } catch (_) {
      return <PaymentMethodData>[];
    }
  }

  Future<List<PaymentMethodData>> _loadTopLevelPaymentMethods({
    required FirebaseFirestore firestore,
    required String userId,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('payments')
          .where('clientId', isEqualTo: userId)
          .get();
      return _parsePaymentMethodDocuments(snapshot.docs);
    } catch (_) {
      return <PaymentMethodData>[];
    }
  }

  Future<List<PaymentMethodData>> _loadPaymentMethodsFromPaymentsDocument({
    required FirebaseFirestore firestore,
    required String userId,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('payments')
          .doc(userId)
          .get();
      final Map<String, dynamic> data = snapshot.data() ?? {};
      if (data.isEmpty) {
        return <PaymentMethodData>[];
      }

      final dynamic methods = data['methods'] ?? data['paymentMethods'];
      if (methods is List) {
        return _parseEmbeddedPaymentMethods(methods);
      }

      final PaymentMethodData? singleMethod = _paymentMethodFromData(
        id: snapshot.id,
        data: data,
      );
      return singleMethod == null
          ? <PaymentMethodData>[]
          : <PaymentMethodData>[singleMethod];
    } catch (_) {
      return <PaymentMethodData>[];
    }
  }

  List<PaymentMethodData> _parsePaymentMethodDocuments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final List<PaymentMethodData> methods = <PaymentMethodData>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      final Map<String, dynamic> data = doc.data();
      final dynamic embeddedMethods = data['methods'] ?? data['paymentMethods'];
      if (embeddedMethods is List) {
        methods.addAll(_parseEmbeddedPaymentMethods(embeddedMethods));
        continue;
      }

      final PaymentMethodData? method = _paymentMethodFromData(
        id: doc.id,
        data: data,
      );
      if (method != null) {
        methods.add(method);
      }
    }

    methods.sort((a, b) {
      if (a.isDefault == b.isDefault) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
      return a.isDefault ? -1 : 1;
    });
    return methods;
  }

  List<PaymentMethodData> _parseEmbeddedPaymentMethods(List<dynamic> items) {
    final List<PaymentMethodData> methods = <PaymentMethodData>[];
    for (int index = 0; index < items.length; index++) {
      final Map<String, dynamic>? data = _asMap(items[index]);
      if (data == null) {
        continue;
      }
      final PaymentMethodData? method = _paymentMethodFromData(
        id: _readString(data['id']) ?? 'payment_$index',
        data: data,
      );
      if (method != null) {
        methods.add(method);
      }
    }
    return methods;
  }

  PaymentMethodData? _paymentMethodFromData({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final String? type = _readString(
      data['type'] ?? data['provider'] ?? data['brand'] ?? data['name'],
    );
    final PaymentMethodKind kind = _paymentKindFromValue(type);
    final String title =
        _readString(data['title']) ??
        _readString(data['label']) ??
        _paymentTitleFromKind(kind);
    final String subtitle =
        _readString(data['subtitle']) ??
        _readString(data['maskedNumber']) ??
        _maskedNumberFromData(data) ??
        'Saved payment';

    if (title.trim().isEmpty) {
      return null;
    }

    return PaymentMethodData(
      id: id,
      title: title,
      subtitle: subtitle,
      kind: kind,
      isDefault: _readBool(data['isDefault']) || _readBool(data['default']),
    );
  }

  String? _maskedNumberFromData(Map<String, dynamic> data) {
    final String? explicitMask = _readString(data['mask']);
    if (explicitMask != null) {
      return explicitMask;
    }

    final String? last4 =
        _readString(data['last4']) ??
        _readString(data['digits']) ??
        _readString(_asMap(data['card'])?['last4']);
    if (last4 != null) {
      return '•••• •••• •••• $last4';
    }
    return null;
  }

  PaymentMethodKind _paymentKindFromValue(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.contains('google')) {
      return PaymentMethodKind.googlePay;
    }
    if (normalized.contains('paypal')) {
      return PaymentMethodKind.paypal;
    }
    if (normalized.contains('card') ||
        normalized.contains('visa') ||
        normalized.contains('master')) {
      return PaymentMethodKind.card;
    }
    return PaymentMethodKind.unknown;
  }

  String _paymentTitleFromKind(PaymentMethodKind kind) {
    switch (kind) {
      case PaymentMethodKind.googlePay:
        return 'Google Pay';
      case PaymentMethodKind.paypal:
        return 'PayPal';
      case PaymentMethodKind.card:
        return 'Credit Card';
      case PaymentMethodKind.unknown:
        return 'Payment Method';
    }
  }

  WasherDetailsData _fallbackWasherDetails({
    required String washerId,
    WasherCardData? preview,
  }) {
    const ServicePackage fullWash = ServicePackage(
      id: 'package_16',
      name: 'Full Wash',
      features: <String>[
        'Hand exterior wash',
        'Wheel cleaning & tire shine',
        'Exterior window cleaning',
        'Vacuum & dashboard',
        'Interior windows',
      ],
      addonIds: <String>['addon_19', 'addon_25'],
      prices: <String, double>{'sedan': 89},
      position: 0,
      isBestOffer: true,
      published: true,
      vehicleCategory: 'sedan',
    );
    const ServicePackage interiorWash = ServicePackage(
      id: 'package_17',
      name: 'Interior Wash',
      features: <String>[
        'Vacuum interior',
        'Dashboard cleaning',
        'Interior windows',
      ],
      addonIds: <String>['addon_25'],
      prices: <String, double>{'sedan': 69},
      position: 1,
      isBestOffer: false,
      published: true,
      vehicleCategory: 'sedan',
    );
    const ServicePackage exteriorWash = ServicePackage(
      id: 'package_18',
      name: 'Exterior Wash',
      features: <String>[
        'Hand wash exterior',
        'Tar removal',
        'Wheels & tire shine',
      ],
      addonIds: <String>['addon_19'],
      prices: <String, double>{'sedan': 39},
      position: 2,
      isBestOffer: false,
      published: true,
      vehicleCategory: 'sedan',
    );

    const List<ServiceAddon> addons = <ServiceAddon>[
      ServiceAddon(
        id: 'addon_19',
        name: 'Engine cleaning',
        basePrice: 15,
        categoryPrices: <String, double>{'sedan': 15},
        position: 0,
        published: true,
      ),
      ServiceAddon(
        id: 'addon_20',
        name: 'Leather care',
        basePrice: 30,
        categoryPrices: <String, double>{'sedan': 30},
        position: 1,
        published: true,
      ),
      ServiceAddon(
        id: 'addon_21',
        name: 'Seat shampoo',
        basePrice: 30,
        categoryPrices: <String, double>{'sedan': 30},
        position: 2,
        published: true,
      ),
      ServiceAddon(
        id: 'addon_25',
        name: 'Plastic dressing',
        basePrice: 25,
        categoryPrices: <String, double>{'sedan': 25},
        position: 3,
        published: true,
      ),
      ServiceAddon(
        id: 'addon_30',
        name: 'Pet hair removal',
        basePrice: 20,
        categoryPrices: <String, double>{'sedan': 20},
        position: 4,
        published: true,
      ),
    ];

    return WasherDetailsData(
      id: washerId,
      name: preview?.title ?? 'Marco’s AutoSpa',
      subtitle: preview?.subtitle ?? 'Mobile Detailer',
      description:
          'Professional mobile car detailer with 8+ years of experience. I come to you at home, work, or wherever your car is parked.',
      ratingLabel: preview?.rating ?? '4.9',
      reviewLabel: preview?.reviews ?? '83 Reviews',
      rankLabel: preview?.rank ?? '#1',
      badgeLabel: preview?.badge ?? 'Top washer',
      locationPrimary: preview?.city ?? 'Belgrade',
      locationSecondary: 'Service area',
      imageAsset: preview?.imageAsset ?? _defaultWasherAsset,
      vehicleCategories: const <String>['sedan'],
      packages: const <ServicePackage>[fullWash, interiorWash, exteriorWash],
      addons: addons,
      galleryImageUrls: const <String>[],
      coverImageUrl: preview?.imageUrl,
      avatarImageUrl: preview?.imageUrl,
      phoneNumber: preview == null ? '(409) 444-6666' : null,
      preview: preview,
    );
  }

  List<PaymentMethodData> _fallbackPaymentMethods() {
    return const <PaymentMethodData>[
      PaymentMethodData(
        id: 'card_1',
        title: 'Credit Card',
        subtitle: '5211••••4647',
        kind: PaymentMethodKind.card,
        isDefault: true,
      ),
      PaymentMethodData(
        id: 'gpay_1',
        title: 'Google Pay',
        subtitle: '5246••••1257',
        kind: PaymentMethodKind.googlePay,
      ),
      PaymentMethodData(
        id: 'paypal_1',
        title: 'PayPal',
        subtitle: '9205••••3389',
        kind: PaymentMethodKind.paypal,
      ),
    ];
  }

  List<ReservationData> _fallbackReservations() {
    return const <ReservationData>[
      ReservationData(
        id: 'reservation_in_progress',
        status: 'in_progress',
        referenceCode: '#TXN-2024-0312',
        washerName: 'Luka Car Wash',
        vehicleCategory: 'sedan',
        packageName: 'Full Wash',
        addonNames: <String>['Leather care', 'Plastic dressing'],
        totalPrice: 144,
        scheduledAt: null,
        progressLabel: '~ 30 min',
        washerPhoneNumber: '(409) 444-6666',
      ),
      ReservationData(
        id: 'reservation_completed',
        status: 'completed',
        referenceCode: '#TXN-2024-0312',
        washerName: 'Luka Car Wash',
        vehicleCategory: 'sedan',
        packageName: 'Full Wash',
        addonNames: <String>[],
        totalPrice: 69,
        scheduledAt: null,
      ),
    ];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, innerValue) => MapEntry(key.toString(), innerValue),
      );
    }
    return null;
  }

  bool _hasValue(dynamic value) {
    return value != null;
  }

  String? _readString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _titleCase(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return '';
    }

    return text
        .split(RegExp(r'[\s_-]+'))
        .map((part) {
          final String lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.trim().toLowerCase() == 'true';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  double? _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => _readString(item))
          .whereType<String>()
          .toList();
    }
    return <String>[];
  }

  Map<String, double> _readPriceMap(dynamic value) {
    final Map<String, dynamic>? map = _asMap(value);
    if (map == null) {
      return <String, double>{};
    }

    final Map<String, double> prices = <String, double>{};
    map.forEach((key, rawValue) {
      final double? number = _readDouble(rawValue);
      if (number != null) {
        prices[key.trim().toLowerCase()] = number;
      }
    });
    return prices;
  }

  DateTime? _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  String? _firstString(List<String> items) {
    return items.isEmpty ? null : items.first;
  }
}
