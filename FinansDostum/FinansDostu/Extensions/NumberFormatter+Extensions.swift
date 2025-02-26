import Foundation

extension Double {
    func formattedCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        guard let formattedString = formatter.string(from: NSNumber(value: self)) else {
            return String(format: "%.2f ₺", self)
        }
        return "\(formattedString) ₺"
    }
} 