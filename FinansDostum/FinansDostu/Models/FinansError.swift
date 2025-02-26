import Foundation

enum FinansError: LocalizedError {
    case invalidAmount(String)
    case invalidDate
    case invalidTitle
    case invalidCategory
    case saveFailed(String)
    case deleteFailed(String)
    case fetchFailed(String)
    case notificationPermissionDenied
    case recurringPaymentError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount(let amount):
            return "Geçersiz tutar: \(amount)"
        case .invalidDate:
            return "Geçersiz tarih"
        case .invalidTitle:
            return "Başlık boş olamaz"
        case .invalidCategory:
            return "Geçersiz kategori"
        case .saveFailed(let reason):
            return "Kaydetme hatası: \(reason)"
        case .deleteFailed(let reason):
            return "Silme hatası: \(reason)"
        case .fetchFailed(let reason):
            return "Veri getirme hatası: \(reason)"
        case .notificationPermissionDenied:
            return "Bildirim izni reddedildi"
        case .recurringPaymentError(let reason):
            return "Tekrarlayan ödeme hatası: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidAmount:
            return "Lütfen geçerli bir tutar giriniz (örn: 100.50)"
        case .invalidDate:
            return "Lütfen geçerli bir tarih seçiniz"
        case .invalidTitle:
            return "Lütfen bir başlık giriniz"
        case .invalidCategory:
            return "Lütfen geçerli bir kategori seçiniz"
        case .saveFailed:
            return "Lütfen tekrar deneyiniz"
        case .deleteFailed:
            return "Lütfen tekrar deneyiniz"
        case .fetchFailed:
            return "Lütfen uygulamayı yeniden başlatıp tekrar deneyiniz"
        case .notificationPermissionDenied:
            return "Bildirimlere izin vermek için Ayarlar > Bildirimler yolunu takip ediniz"
        case .recurringPaymentError:
            return "Tekrarlayan ödeme ayarlarınızı kontrol ediniz"
        }
    }
} 