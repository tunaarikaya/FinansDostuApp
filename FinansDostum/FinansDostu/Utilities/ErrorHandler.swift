
import Foundation

enum AppError: Error {
    case networkError
    case databaseError
    case authenticationError
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "İnternet bağlantınızı kontrol edin"
        case .databaseError:
            return "Veriler yüklenirken bir hata oluştu"
        case .authenticationError:
            return "Oturum süreniz doldu"
        }
    }
} 
