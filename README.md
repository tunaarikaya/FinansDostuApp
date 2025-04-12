# 💸 Finans Dostum(Finance Buddy) 2025 Apple Student Challenge Winner Project 🏆

**Finans Dostum**, kişisel bütçe kontrolünü basit, hızlı ve estetik bir deneyime dönüştüren modern bir iOS uygulamasıdır. SwiftUI ve Core Data’nın gücünü arkasına alan bu uygulama, sade arayüzü ve akıllı analizleriyle kullanıcılarına etkili bir finans yönetimi aracı sunar.


> [📲 App Store'dan İndir](https://apps.apple.com/tr/app/finans-dostum/id6741549762) 

---

## ✨ Özellikler

- 🔄 **Hızlı & Minimalist Arayüz**  
  Karmaşık grafikler ve menüler yok. Sade, sezgisel ve kullanımı kolay.

- 🎨 **Kişiselleştirilebilir Tasarım**  
  Pastel renkler, karanlık mod ve sade tipografiyle rahatlatıcı bir deneyim.

- 📊 **Akıllı Harcama Analizi**  
  Sadece veri girişi değil, harcama alışkanlıklarını anlamaya yönelik dinamik grafikler ve kategorik raporlar.

- 🔔 **Bütçe Hatırlatıcıları**  
  Belirlediğin limitleri aşmamak için seni nazikçe uyaran bildirim sistemi.

---

## 🛠️ Kullanılan Teknolojiler

| Teknoloji          | Kullanım Amacı                                      |
|--------------------|-----------------------------------------------------|
| **SwiftUI**        | Modern kullanıcı arayüzü tasarımı                   |
| **Swift**          | Uygulama iş mantığı ve etkileşim kontrolü           |
| **Core Data**      | Yerel veri saklama ve performanslı veri erişimi     |
| **Combine**        | Reaktif veri akışı ve ViewModel senkronizasyonu     |
| **SF Symbols**     | Sistem simgeleriyle tutarlı ve estetik ikonografi   |

---

## 🧩 Proje Yapısı
FinansDostum/
├── Models/           # Harcama, kategori, bütçe gibi veri modelleri
│   ├── Harcama.swift  # Harcama modelini tanımlar
│   └── Kategori.swift # Kategori modelini tanımlar
│
├── Views/            # SwiftUI arayüz bileşenleri
│   ├── AnaSayfaView.swift  # Ana sayfa görünümleri
│   ├── HarcamaListView.swift # Harcama listesi ve detayları
│   └── BütçeView.swift      # Bütçe görünümleri
│
├── ViewModels/       # Ekran mantığı, veri işleme ve Combine entegrasyonu
│   ├── AnaSayfaViewModel.swift # Ana sayfa iş mantığı
│   ├── HarcamaViewModel.swift  # Harcama verilerini yöneten ViewModel
│   └── BütçeViewModel.swift    # Bütçe yönetimini sağlayan ViewModel
│
├── Core/             # Yardımcı sınıflar, veri yöneticileri, renk temaları
│   ├── RenkYönetimi.swift  # Uygulama renk yönetimi
│   ├── VeriYöneticisi.swift # Core Data işlemleri
│   └── Yardımcı.swift       # Genel yardımcı fonksiyonlar
│
├── Resources/        # Renk paletleri, sabitler, lokalizasyon desteği
│   ├── RenkPaleti.swift   # Uygulama için renk paletleri
│   └── Sabitler.swift     # Uygulama genelindeki sabitler (örneğin, API URL’leri)
---

## 📸 Ekran Görüntüsü

<p float="left">
   <img width="250" alt="Screenshot 5" src="https://github.com/user-attachments/assets/0eaeeb15-e6b0-4afa-be67-033e222f3a30" />
   <img width="250" alt="Screenshot 4" src="https://github.com/user-attachments/assets/5fee9962-b71d-445e-998f-4cd0e3977644" />
   <img width="250" alt="Screenshot 3" src="https://github.com/user-attachments/assets/f15acd8c-e48c-4f76-9d6a-41fa448e9959" />
   <img width="250" alt="Screenshot 2" src="https://github.com/user-attachments/assets/9603dc2b-08de-4dd5-8622-13b6aba5c0ce" />
  <img width="250" alt="Screenshot 1" src="https://github.com/user-attachments/assets/95f579a9-8e9f-438a-b7d4-feec793a494f" />
 
 
 
 
</p>

---

## 🚧 Geliştirme Notları

- Uygulama MVVM mimarisiyle yapılandırılmıştır.
- Core Data için `@FetchRequest` ve `@Environment(\.managedObjectContext)` kullanılmıştır.
- Uygulama içi temalar `@AppStorage` aracılığıyla kullanıcı tercihlerine göre otomatik değiştirilmektedir.
- Bildirim sistemi OneSignal ile yapılandırılmıştır.

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) ile açık kaynak olarak sunulmuştur.

---

## 📬 Geri Bildirim & Katkı

Her türlü geri bildirime açığım. Uygulama hakkında fikirlerinizi [issue](https://github.com/senin-kullanici-adin/FinansDostum/issues) olarak paylaşabilir veya katkıda bulunmak için pull request gönderebilirsiniz.
