# Guest Tracking — طريقة إنشاء الصفحات وتنفيذ Guest Mode

## 1. الهدف

ميزة **Guest Tracking** تسمح لأي شخص بمتابعة مركبة من خلال **Guest Code** بدون تسجيل دخول.

الـ API المعتمد هو:

`GET /guest/track/{guestCode}`

وهو endpoint عام **بدون Authorization**، ومخصص لإرجاع آخر موقع معروف للمركبة المرتبطة بالكود. مواصفات الـ API تذكر أن الكود غير الصالح أو المنتهي أو الملغى قد يعيد `404/410`.

## 2. تجربة المستخدم

يجب دعم طريقتين:

### الطريقة الأولى — إدخال الكود

صفحة:

`/guest`

تحتوي على:
- حقل Guest Code
- زر «تتبع المركبة»
- رسالة خطأ
- إمكانية إعادة المحاولة

بعد إدخال الكود:

`/guest/track/{guestCode}`

### الطريقة الثانية — رابط مباشر

مثال:

`https://your-domain.com/guest/track/KHALED-GUEST`

عند فتح الرابط، يتم أخذ `guestCode` من الـ route واستدعاء API مباشرة، بدون شاشة إدخال وبدون تسجيل دخول.

لذلك الأفضل تنفيذ **الطريقتين معاً**.

## 3. الصفحات المطلوبة

البنية المقترحة:

```text
features/
└── guest_tracking/
    ├── data/
    │   ├── datasources/
    │   │   └── guest_tracking_remote_datasource.dart
    │   └── models/
    │       └── guest_tracking_model.dart
    │
    └── presentation/
        ├── cubit/
        │   ├── guest_tracking_cubit.dart
        │   └── guest_tracking_state.dart
        └── screens/
            ├── guest_entry_screen.dart
            └── guest_tracking_screen.dart
```

## 4. Guest Entry Screen

اسم الصفحة:

`GuestEntryScreen`

المسار:

`/guest`

وظيفتها إدخال الكود فقط.

عند الضغط على «تتبع المركبة» يتم الانتقال إلى:

`/guest/track/{guestCode}`

## 5. Guest Tracking Screen

اسم الصفحة:

`GuestTrackingScreen`

وتستقبل:

```dart
final String guestCode;
```

عند فتح الصفحة يتم استدعاء:

```text
GET /guest/track/KHALED-GUEST
```

ولا يتم إرسال Bearer Token.

## 6. Response الحالي

الـ response الذي تم اختباره:

```json
{
  "data": {
    "vehicle": {
      "plate_no": "KHA-001",
      "type": "Truck",
      "model": "Model 2020"
    },
    "location": null,
    "expires_at": "2026-09-11T15:00:45.000000Z",
    "live_channel": "tracking-code.KHALED-GUEST"
  }
}
```

يجب أن يكون `location` nullable.

نماذج مقترحة:

```dart
class GuestTrackingModel {
  final GuestVehicleModel vehicle;
  final GuestLocationModel? location;
  final String? expiresAt;
  final String? liveChannel;

  const GuestTrackingModel({
    required this.vehicle,
    this.location,
    this.expiresAt,
    this.liveChannel,
  });
}
```

```dart
class GuestVehicleModel {
  final String plateNo;
  final String type;
  final String model;

  const GuestVehicleModel({
    required this.plateNo,
    required this.type,
    required this.model,
  });
}
```

```dart
class GuestLocationModel {
  final double lat;
  final double lng;
  final String? at;

  const GuestLocationModel({
    required this.lat,
    required this.lng,
    this.at,
  });
}
```

## 7. عندما تكون location = null

هذا **ليس خطأ في الكود**.

يعني أنه لا يوجد موقع حالي معروف يمكن عرضه.

الواجهة تعرض الخريطة بدون Marker، مع رسالة مثل:

```text
لا يوجد موقع حالي للمركبة
بانتظار وصول الموقع...
```

ولا يجب إنشاء Marker باستخدام قيم null.

## 8. عندما تكون location موجودة

إذا أصبحت:

```json
"location": {
  "lat": 33.5178,
  "lng": 36.2765,
  "at": "2026-07-31T23:19:04+00:00"
}
```

يتم:

1. وضع Marker للمركبة.
2. تحريك الكاميرا للموقع عند الحاجة.
3. عرض وقت آخر تحديث.
4. تحديث الـ Marker عند وصول موقع جديد.

## 9. إعادة استخدام الـ Map الموجودة في المشروع

**لا تنشئ Map جديدة خاصة بالـ Guest.**

المشروع لديه Map مستخدمة حالياً، لذلك يجب فصل الـ Map عن منطق الصفحة وإعادة استخدامها.

يفضل أن تكون الخريطة Widget قابلة لإعادة الاستخدام، مثلاً:

```dart
TrackingMap(
  location: location,
  markers: markers,
)
```

ويستخدمها:

```text
Manager Tracking
Driver Tracking
Guest Tracking
```

إذا كانت الخريطة الحالية مرتبطة بـ Cubit خاص بصفحة معينة، يجب جعل الـ Map تستقبل البيانات المطلوبة كـ parameters بدلاً من ربطها مباشرة بـ Cubit واحد.

## 10. Live Tracking

الـ response يحتوي على:

```json
"live_channel": "tracking-code.KHALED-GUEST"
```

يجب استخدام `live_channel` الذي يرجعه الـ API كما هو.

قناة الضيف تستقبل:

```text
location.updated
```

التدفق:

```text
GET /guest/track/{guestCode}
          |
          v
     live_channel
          |
          v
  Subscribe to channel
          |
          v
 location.updated
          |
          v
      Update Map
```

حسب توثيق المشروع، قناة الضيف هي:

`tracking-code.{code}`

والـ event المطلوب الاستماع إليه هو:

`location.updated`

ولا يجب الاستماع إلى `client-*`.

## 11. Guest Cubit

الحالات المقترحة:

```text
GuestTrackingInitial
GuestTrackingLoading
GuestTrackingLoaded
GuestTrackingError
```

الـ Cubit مسؤول عن:
- استدعاء API.
- إدارة loading/error/success.
- الاحتفاظ ببيانات المركبة.
- تحديث بيانات الموقع.
- إدارة subscription للـ live channel إذا تم وضع منطق WebSocket داخله.

## 12. لا تضع Guest Cubit في app.dart

لا نحتاج:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<GuestTrackingCubit>(
      create: (_) => GuestTrackingCubit(),
    ),
  ],
)
```

في `app.dart`.

يتم إنشاء Cubit فقط عند فتح صفحة Guest:

```dart
BlocProvider(
  create: (_) => GuestTrackingCubit(),
  child: GuestTrackingScreen(
    guestCode: guestCode,
  ),
)
```

وهذا يتوافق مع مبدأ أن الصفحة هي التي تحتاج الـ Cubit.

## 13. Routing

يجب إضافة:

```text
/guest
```

و:

```text
/guest/track/:guestCode
```

مثال باستخدام GoRouter:

```dart
GoRoute(
  path: '/guest',
  builder: (context, state) {
    return const GuestEntryScreen();
  },
),

GoRoute(
  path: '/guest/track/:guestCode',
  builder: (context, state) {
    final guestCode =
        state.pathParameters['guestCode']!;

    return BlocProvider(
      create: (_) => GuestTrackingCubit(),
      child: GuestTrackingScreen(
        guestCode: guestCode,
      ),
    );
  },
),
```

إذا كان المشروع يستخدم نظام Routing آخر، يتم تطبيق نفس الفكرة بدون تغيير نظام المشروع.

## 14. DataSource

الـ DataSource مسؤول عن API فقط:

```dart
Future<GuestTrackingModel> track(String guestCode) async {
  final response =
      await _api.get(
        '/guest/track/$guestCode',
        auth: false,
      );

  return GuestTrackingModel.fromJson(
    response['data'],
  );
}
```

بما أن `ApiClient` الحالي يضيف Bearer Token افتراضياً، يفضل دعم:

```dart
get(
  String path, {
  bool auth = true,
})
```

ثم استخدام:

```dart
auth: false
```

للـ Guest endpoint.

## 15. حالات الصفحة

### Loading

```text
جار تحميل بيانات المركبة...
```

### Invalid / Expired Code

عند `404` أو `410`:

```text
كود التتبع غير صالح أو منتهي الصلاحية
```

مع:

```text
[ إدخال كود آخر ]
```

### Valid + location = null

```text
بيانات المركبة

KHA-001
Truck
Model 2020

[ MAP بدون Marker ]

لا يوجد موقع حالي للمركبة
بانتظار وصول الموقع...
```

### Valid + location موجود

```text
بيانات المركبة

KHA-001
Truck
Model 2020

[ MAP ]
     ● KHA-001

آخر تحديث: ...
```

### Live Update

عند وصول:

```text
location.updated
```

يتم تحديث الـ Marker بدون إعادة تحميل الصفحة بالكامل.

## 16. Guest Link

عند إنشاء Guest Code من لوحة الإدارة، يفضل عرض:

```text
Guest Code:
KHALED-GUEST

رابط التتبع:
https://your-domain.com/guest/track/KHALED-GUEST

[ نسخ الرابط ]
[ مشاركة ]
```

## 17. QR Code

يمكن تحويل نفس الرابط إلى QR:

```text
QR
 |
 v
https://your-domain.com/guest/track/KHALED-GUEST
 |
 v
Guest Tracking Screen
```

وعند مسح QR تفتح صفحة التتبع مباشرة.

## 18. انتهاء الصلاحية

الـ API يعيد:

```json
"expires_at": "2026-09-11T15:00:45.000000Z"
```

يمكن عرض تاريخ الانتهاء للمستخدم، لكن لا يجب أن يكون Flutter هو المصدر الأساسي لتحديد صلاحية الكود.

الـ Backend هو المصدر الأساسي، وعند انتهاء أو إلغاء الكود يجب التعامل مع الاستجابة القادمة من API.

## 19. مسؤوليات الملفات

### GuestEntryScreen

- إدخال الكود.
- validation بسيط.
- الانتقال إلى route التتبع.

### GuestTrackingScreen

- عرض بيانات المركبة.
- عرض Map.
- عرض loading/error/empty states.
- الاستماع إلى Cubit state.

### GuestTrackingCubit

- استدعاء DataSource.
- إدارة states.
- تحديث الموقع.
- إدارة live updates حسب architecture المشروع.

### GuestTrackingRemoteDataSource

- استدعاء `/guest/track/{guestCode}`.

### Tracking Map Widget

- رسم الخريطة.
- Marker.
- تحريك الكاميرا.
- استقبال الموقع الجديد.

## 20. البنية النهائية

```text
Guest
 |
 +-------------------+
 |                   |
 v                   v
/guest          /guest/track/CODE
 |                   |
 |                   v
 |          GuestTrackingScreen
 |                   |
 |                   v
 |        GuestTrackingCubit
 |                   |
 |                   v
 |       RemoteDataSource
 |                   |
 |                   v
 | GET /guest/track/CODE
 |                   |
 +-------------------+
                     |
              +------+------+
              |             |
       location == null   location != null
              |             |
              v             v
        Map بدون Marker   Map + Marker
              |             |
              +------+------+
                     |
                     v
                live_channel
                     |
                     v
              location.updated
                     |
                     v
                 Update Map
```

## 21. القرار النهائي

التنفيذ الأنسب للمشروع:

1. صفحة `/guest` للإدخال اليدوي.
2. صفحة `/guest/track/:guestCode` للتتبع المباشر.
3. دعم رابط مشاركة يحتوي على Guest Code.
4. دعم QR لنفس الرابط لاحقاً.
5. Guest لا يحتاج Login.
6. Guest API يعمل بدون Bearer Token.
7. `location` يجب أن تكون nullable.
8. إذا كانت `location == null` نعرض الخريطة بدون Marker ورسالة انتظار.
9. إذا كان الموقع موجوداً نعرض Marker.
10. استخدام `live_channel` لإجراء live tracking.
11. الاستماع إلى `location.updated`.
12. إعادة استخدام الـ Map الموجودة حالياً في المشروع بدلاً من بناء Map جديدة.
13. إنشاء Guest Cubit عند فتح صفحة Guest فقط، وليس في `app.dart`.
14. التعامل مع `404/410` ككود غير صالح/منتهي.
