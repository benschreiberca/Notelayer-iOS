import SwiftUI

/// Reusable custom date/time picker sheet for selecting reminder dates
/// Enforces future dates only and provides clean iOS-native UI
struct CustomDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    let onSave: (Date) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Remind me at",
                    selection: $selectedDate,
                    in: Date()..., // Only allow future dates
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Custom Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(selectedDate)
                    }
                }
            }
        }
    }
}
