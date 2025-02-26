# Bilinen Hatalar ve Çözümleri

## Value of type 'RecurringPaymentManager' has no member 'createRecurringPayment'
Hata: MainViewModel'de RecurringPaymentManager'ın createRecurringPayment fonksiyonu bulunamıyor.
Çözüm: RecurringPaymentManager sınıfına createRecurringPayment fonksiyonunu ekle:
```swift
func createRecurringPayment(
    title: String,
    amount: Double,
    startDate: Date,
    interval: String,
    note: String?,
    in context: NSManagedObjectContext
) throws {
    // İlk ödemeyi oluştur
    let firstPayment = PlannedPaymentEntity(context: context)
    // ... ödeme detayları ...
    
    // Gelecek aylar için ödemeler oluştur
    var currentDate = startDate
    for _ in 1...11 {
        guard let nextDate = calculateNextDueDate(from: currentDate, interval: interval) else { break }
        let payment = PlannedPaymentEntity(context: context)
        // ... ödeme detayları ...
        currentDate = nextDate
    }
    try context.save()
}
```

## Tekrarlayan Ödemeler Yanlış Tarihe Kaydediliyor
Çözüm: Calendar.current kullanarak tarih hesaplamalarını düzelt ve ay sonu kontrolü ekle.

## Aylık Ödemeler Düzgün Tekrarlanmıyor
Çözüm: Ay geçişlerinde ve yıl sonunda doğru tarih hesaplaması için özel kontroller ekle.

## Tekrarlayan Ödemeler İşlenmiyor
Çözüm: processRecurringPayments() fonksiyonunu try-catch bloğu içinde çağır ve hata yönetimini ekle.

## Bakiye Güncellenmiyor
Çözüm: Her işlem sonrası updateBalance() fonksiyonunu çağır ve CoreData ile senkronize et.

## Invalid redeclaration of View Component
Hata: Aynı View bileşeninin birden fazla yerde tanımlanması (örn: 'RecentTransactionsView' redeclaration)
Çözüm: 
1. View bileşenini sadece bir yerde tanımla
2. Bileşeni Components klasörü altında ayrı bir dosyada tut
3. Bileşeni kullanacak diğer view'larda import et
4. Aynı bileşeni farklı dosyalarda tekrar tanımlama

## İşlem Silme Özelliği Eksik
Hata: İşlem detay sheet'inden silme özelliğinin kaldırılması, toplam bakiye hesaplamasını etkiler
Çözüm: 
1. İşlem detay sheet'ine silme butonu ekle
2. Silme işlemi için onay alert'i göster
3. Silme işleminden sonra viewModel.deleteTransaction() çağır
4. Silme sonrası sheet'i kapat ve toplam bakiyeyi güncelle
5. UI güncellemelerini withAnimation ile yap

## Sheet İçinde Silme İşlemi Çalışmıyor
Hata: İşlem detay sheet'indeki silme butonu ve alert'i doğru çalışmıyor
Çözüm: 
1. Alert'i sheet içindeki NavigationView'a taşı
2. Alert'i showingDeleteAlert state'ine bağla
3. Silme işlemini doğrudan seçili transaction üzerinde gerçekleştir
4. transactionToDelete state'ini kaldır (gereksiz)
5. Silme sonrası sheet'i kapat ve UI'ı güncelle

## Missing argument for parameter 'viewModel' in call
Hata: TransactionListView içindeki TransactionRowView çağrısında viewModel parametresi eksik.
Çözüm:
1. TransactionListView'a viewModel parametresi ekle:
```swift
@ObservedObject var viewModel: MainViewModel
```

2. TransactionRowView çağrısına viewModel'i ilet:
```swift
TransactionRowView(transaction: Transaction(from: transaction), viewModel: viewModel)
```

Algoritma:
1. Önce hatayı veren view'ı incele
2. View'ın kullandığı child view'ların required parametrelerini kontrol et
3. Eğer child view bir parametre gerektiriyorsa (örn: viewModel), parent view'a bu parametreyi ekle
4. Parent view'a eklenen parametreyi child view'a ilet
5. Kodun girintileme ve düzenini kontrol et

Not: SwiftUI'da view'lar arası veri aktarımında, eğer bir view model kullanılıyorsa ve alt view'lar bu model'e ihtiyaç duyuyorsa, üst view'dan alt view'a model'in iletilmesi gerekir.

## Duplicate Extension Implementation
Hata: Var olan bir extension'ı (Double+Extensions.swift) tekrar oluşturma hatası.
Çözüm:
1. Yeni bir extension oluşturmadan önce projeyi kontrol et
2. `cmd + shift + f` ile tüm projede arama yap
3. Özellikle extension'lar için şu dizinleri kontrol et:
   - Extensions/
   - Utilities/
   - Helpers/
4. Eğer varsa, mevcut extension'ı kullan
5. Eğer yoksa, yeni extension oluştur

Not: SwiftUI projelerinde yaygın extension'lar (Date, Double, String vb.) genellikle başlangıçta oluşturulur. Yeni bir extension eklemeden önce mutlaka mevcut kodları kontrol et.
