# 🔍 Backend Veri Çekme Sorunu - Debug Rehberi

## ✅ Yaptığımız Değişiklikler (Backend'i Etkilemez):
- ✅ Test modu ekleme (_testMode flag)
- ✅ SMS gönderme fonksiyonları
- ✅ Progress dialog güncellemeleri
- ✅ Batch sistemi

**Hiçbir backend çağrısına dokunmadık!**

## 🔍 Sorun Kontrolleri:

### 1. API Endpoint Kontrolü:
```dart
// lib/api_constants.dart
static const String baseUrl = 'http://216.250.11.255:9000/api/';
static const String clients = '${baseUrl}client/';
```
✅ Backend server çalışıyor mu? → http://216.250.11.255:9000/api/client/ tarayıcıda test edin

### 2. Network Kontrolü:
- ✅ Telefonun/emülatörün internete bağlı olduğundan emin olun
- ✅ Aynı ağda mısınız?
- ✅ Backend server ayakta mı?

### 3. Token Kontrolü:
Backend çağrısı `requiresToken: true` kullanıyor:
```dart
final data = await ApiService().getRequest(uri.toString(), requiresToken: true);
```

**Token var mı kontrol edin:**
- Kullanıcı giriş yaptı mı?
- Token expire olmadı mı?

### 4. Debug Console'da Hata Var mı?
Terminal'de şu hataları arayın:
- `SocketException` → Network sorunu
- `401 Unauthorized` → Token sorunu
- `404 Not Found` → Endpoint yanlış
- `500 Server Error` → Backend sorunu

## 🛠️ Hızlı Testler:

### Test 1: Backend Server Test
Terminal'de:
```bash
curl http://216.250.11.255:9000/api/client/
```

### Test 2: Token Test
Login sayfasına gidip tekrar giriş yapın.

### Test 3: Debug Print Ekle
`lib/app/modules/sendSMS/controllers/clients_service.dart` dosyasına:
```dart
Future<List<ClientModel>> getClients() async {
  print('🔍 [DEBUG] Fetching clients from backend...');
  final uri = Uri.parse(ApiConstants.clients);
  print('🔍 [DEBUG] URL: ${uri.toString()}');
  
  final data = await ApiService().getRequest(uri.toString(), requiresToken: true);
  
  print('🔍 [DEBUG] Response data: $data');
  
  if (data is Map && data['results'] != null) {
    print('🔍 [DEBUG] Found ${data['results'].length} clients');
    return (data['results'] as List).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
  } else if (data is List) {
    print('🔍 [DEBUG] Found ${data.length} clients (direct list)');
    return (data).map((item) => ClientModel.fromJson(item)).toList().reversed.toList();
  } else {
    print('❌ [DEBUG] No data or unexpected format');
    return [];
  }
}
```

### Test 4: API Service Debug
`lib/api_service.dart` dosyasında satır 25-50 arasına print ekleyin.

## 📱 Ne Görüyorsunuz?

Uygulamada ne görüyorsunuz?
- ⭕ Loading (spinKit) sonsuza kadar mı dönüyor?
- ❌ Error ekranı mı gösteriyor?
- 📭 "No data" (boş liste) mi gösteriyor?

## 🔧 Olası Çözümler:

### Çözüm 1: Logout & Login
```dart
// Ayarlar → Logout → Tekrar Login
```

### Çözüm 2: App Restart
```bash
flutter clean
flutter pub get
flutter run
```

### Çözüm 3: Backend Server Restart
Backend sunucuyu yeniden başlatın.

### Çözüm 4: Network Permission
`android/app/src/main/AndroidManifest.xml` kontrolü:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## 📝 Bana Bildirin:

Aşağıdaki bilgileri paylaşın:
1. Debug console'da ne hata var?
2. Uygulamada ne ekran görüyorsunuz?
3. Backend server çalışıyor mu?
4. Curl komutu çalışıyor mu?

Bu bilgilerle tam çözüm getirebilirim! 🚀
