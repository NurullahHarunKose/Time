PROJE ADI: TIME - KAPSAMLI ZAMAN YÖNETİMİ UYGULAMASI

================================================================================
1. PROJE HAKKINDA GENEL BİLGİ VE VİZYON
================================================================================
Time, modern yaşamın getirdiği zaman yönetimi zorluklarına çözüm üretmek amacıyla geliştirilmiş, kullanıcı dostu bir mobil uygulamadır. Sıradan not alma veya yapılacaklar listesi uygulamalarının ötesine geçerek, üç farklı zaman yönetimi metodolojisini (Günlük Tutma, Eisenhower Matrisi ve Görsel Zaman Planlama) tek bir platformda birleştirir.

Uygulamanın temel felsefesi "Görselleştir, Planla ve Yönet"tir. Kullanıcıların günlerini sadece listeleyerek değil, görsel olarak (analog saat üzerinde) planlamalarına olanak tanır. Aciliyet ve önem düzeyine göre görevleri sınıflandırarak verimliliği artırır.

Bu proje, Flutter framework'ü kullanılarak geliştirilmiş olup, temiz kod mimarisi (Clean Architecture) prensiplerine ve modern durum yönetimi (State Management) tekniklerine sadık kalınarak tasarlanmıştır.

================================================================================
2. UYGULAMA MİMARİSİ VE SAYFA DETAYLARI
================================================================================
Uygulama, kullanıcı deneyimini (UX) en üst düzeye çıkarmak için üç ana sayfa üzerine kurgulanmıştır. Sayfalar arası geçişler sezgiseldir ve her sayfa belirli bir amaca hizmet eder.

A. SOL SAYFA: NOTLAR, GÜNLÜK VE TAKVİM (LeftPage)
-------------------------------------------------
Bu modül, kullanıcının dijital bir ajanda gibi kullanabileceği alandır.
- İşlevi: Geçmişe dönük kayıt tutma ve geleceğe not düşme.
- Özellikler:
  * Gelişmiş Takvim Arayüzü: Kullanıcılar aylar ve haftalar arasında gezinebilir. Herhangi bir güne tıklandığında, o güne ait notlar anında yüklenir.
  * Sınırsız Not Ekleme: Seçilen güne başlık ve içerik detaylarıyla sınırsız not eklenebilir.
  * Anlık Düzenleme: Eklenen notlar üzerinde değişiklik yapılabilir veya notlar silinebilir. Silme işlemi öncesi kullanıcıdan onay alınarak veri kaybı önlenir.
  * Filtresiz Görünüm: "Tüm Notlar" seçeneği sayesinde, tarih ayrımı olmaksızın bugüne kadar kaydedilen bütün notlar tek bir liste halinde görüntülenebilir. Bu, aranan bir bilginin bulunmasını kolaylaştırır.

B. ORTA (ANA) SAYFA: GÖREV YÖNETİMİ VE EISENHOWER MATRİSİ (HomePage)
---------------------------------------------------------------------
Burası uygulamanın stratejik merkezidir. Görevler sadece listelenmez, önem derecesine göre sınıflandırılır.
- Metodoloji: Eisenhower Matrisi prensibi kullanılmıştır. Görevler 4 ana bölgeye ayrılır:
  1. Kırmızı Bölge (Acil ve Önemli): Hemen yapılması gereken krizler ve son tarihli projeler.
  2. Turuncu Bölge (Acil Değil ama Önemli): Stratejik planlar, vizyon çalışmaları.
  3. Mavi Bölge (Acil ama Önemli Değil): Başkasına devredilebilecek veya hızlıca halledilecek işler.
  4. Yeşil Bölge (Acil Değil ve Önemli Değil): Zaman kaybettirenler, silinebilecekler.
  
- Teknik Detaylar:
  * Dinamik Grid Yapısı: Flutter'ın Grid sistemleri kullanılarak matris görselleştirilmiştir.
  * Kategori Sistemi: Görevler "İş", "Okul", "Özel" gibi kategorilere ayrılabilir ve her kategori için özel ikonlar atanabilir.
  * Detaylı Görev Kartları: Her görev için tarih, saat, kategori ve detaylı açıklama girilebilir.

C. SAĞ SAYFA: GÜNLÜK PLAN VE GÖRSEL ZAMAN ÇİZELGESİ (RightPage)
---------------------------------------------------------------
Bu sayfa, klasik "To-Do" listelerinden ayrılarak, günün 24 saatini görsel bir analog saat üzerinde dilimler halinde sunar.
- Görselleştirme Teknolojisi:
  * CustomPainter: Uygulamadaki analog saat ve üzerindeki renkli aktivite dilimleri (Pie Chart benzeri), herhangi bir hazır paket kullanılmadan, Flutter'ın grafik motoru (Canvas) kullanılarak matematiksel formüllerle (Trigonometri) sıfırdan çizilmiştir.
  * Gece/Gündüz Modu: Saat sadece 12 saati göstermez. Kullanıcı tek tuşla 00:00-12:00 (Gündüz) ve 12:00-24:00 (Gece) görünümleri arasında geçiş yapabilir. Gündüz modu açık renklerle, gece modu ise koyu ve lacivert tonlarla tasarlanmıştır.

- Kaydırma ve Hizalama (Akıllı Metin Yerleşimi):
  * Saatin üzerindeki aktivite isimleri, saatin dönme açısına göre dinamik olarak hesaplanır.
  * Yazılar okuma kolaylığı sağlamak için saatin dış çemberinden merkezine doğru akacak şekilde hizalanmıştır.
  * Uzun metinler otomatik olarak alt satıra geçer ve belirlenen dilimlerin dışına taşmaz.

- Timeline (Zaman Çizelgesi) Görünümü:
  * Görsel saatin yanı sıra, "Günlük Program" butonu ile aktiviteler alt alta sıralanmış bir zaman çizelgesi olarak da görüntülenebilir.
  * Akıllı Takip: Eğer bir aktivite (Örneğin: 09:00 - 11:00 arası Toplantı) birden fazla saati kapsıyorsa, sonraki saatlerde (10:00'da) tekrar aynı kart gösterilmez; bunun yerine işin devam ettiğini belirten şık bir dikey çizgi ve ok işareti gösterilir. Bu sayede ekran kalabalığı önlenir.

================================================================================
3. KULLANILAN TEKNOLOJİLER VE KÜTÜPHANELER
================================================================================
Bu proje, modern mobil uygulama geliştirme standartlarına uygun olarak aşağıdaki teknolojilerle inşa edilmiştir:

1. Flutter & Dart:
   - UI (Kullanıcı Arayüzü) oluşturma ve mantıksal işlemler için Google'ın geliştirdiği Flutter SDK kullanılmıştır.

2. State Management (Durum Yönetimi) - Provider:
   - Uygulama genelindeki verilerin (Notlar, Görevler, Planlar) anlık olarak tüm sayfalarda senkronize olması için 'Provider' paketi tercih edilmiştir. Bu sayede bir sayfada yapılan değişiklik (örneğin görev silme), diğer sayfalarda anında güncellenir.
   - Provider Dosyaları: `TaskProvider`, `NoteProvider`, `ScheduleProvider`

3. Veri Kalıcılığı (Local Storage) - Shared Preferences:
   - Uygulama kapatılıp açıldığında verilerin kaybolmaması için veriler cihazın yerel hafızasında JSON formatında saklanmaktadır. Veritabanı kurulumu gerektirmez, hızlı ve hafiftir.

4. Table Calendar:
   - Özelleştirilebilir, Türkçe dil desteği olan ve performanslı bir takvim deneyimi sunmak için kullanılmıştır.

5. Intl (Internationalization):
   - Tarih ve saat formatlarının (Örn: "31 Aralık 2025 Çarşamba") Türkçe olarak ve doğru formatta gösterilmesi için kullanılmıştır.

6. UUID:
   - Eklenen her not, görev ve aktiviteye benzersiz bir kimlik numarası (ID) atamak için kullanılmıştır. Bu, verilerin karışmasını ve silme işlemlerinde hata oluşmasını engeller.

================================================================================
4. KURULUM VE ÇALIŞTIRMA TALİMATLARI
================================================================================
Bu projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

Gereksinimler:
- Flutter SDK (Son sürüm önerilir)
- Dart SDK
- Android Studio veya VS Code (Flutter eklentileri yüklü)

Adımlar:
1. Proje dosyalarını bilgisayarınıza indirin (Download ZIP) veya Git kullanarak klonlayın.
2. Terminali açın ve proje klasörünün içine girin.
3. Gerekli kütüphaneleri (paketleri) indirmek için şu komutu yazın ve Enter'a basın:
   "flutter pub get"
4. Uygulamayı bir emülatörde veya USB ile bağlı gerçek cihazda çalıştırmak için şu komutu yazın:
   "flutter run"

================================================================================
5. GELİŞTİRİCİ NOTU
================================================================================
Time uygulaması, sadece kod yazmak değil, bir ürün geliştirme vizyonuyla ortaya çıkmıştır. Kullanıcı arayüzünde (UI) sadelik ve işlevsellik ön planda tutulmuş, kullanıcı deneyimini (UX) iyileştirmek için mikro-animasyonlar ve yumuşak geçişler kullanılmıştır. Kod yapısı, gelecekte yeni özelliklerin (Örn: Bulut yedekleme, bildirim sistemi) kolayca eklenebileceği şekilde modüler tasarlanmıştır.
