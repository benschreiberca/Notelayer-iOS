import SwiftUI

/// Sheet for selecting when to set a reminder for a task
/// Provides quick presets and custom date/time picker
struct ReminderPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    
    let task: Task
    let onSave: (Date) -> Void
    
    @State private var showCustomPicker = false
    @State private var customDate = Date().addingTimeInterval(3600) // Default to 1 hour from now
    @State private var showPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Quick preset buttons
                    PresetButton(title: "30 mins", date: Date().addingTimeInterval(30 * 60))
                    PresetButton(title: "90 mins", date: Date().addingTimeInterval(90 * 60))
                    PresetButton(title: "3 hours", date: Date().addingTimeInterval(3 * 60 * 60))
                    PresetButton(title: "Tomorrow 9 AM", date: tomorrowAt9AM())
                    
                    // Custom picker button
                    Button {
                        showCustomPicker = true
                    } label: {
                        HStack {
                            Text("Custom...")
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(theme.tokens.accent)
                        }
                    }
                } header: {
                    Text("When would you like to be reminded?")
                }
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCustomPicker) {
                CustomDatePickerSheet(
                    selectedDate: $customDate,
                    onSave: { date in
                        showCustomPicker = false
                        handleReminderSelection(date: date)
                    },
                    onCancel: {
                        showCustomPicker = false
                    }
                )
            }
            .alert("Notifications Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Notelayer needs notification permission to send reminders. Please enable notifications in Settings.")
            }
        }
    }
    
    /// Preset button view
    private func PresetButton(title: String, date: Date) -> some View {
        Button {
            handleReminderSelection(date: date)
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(relativeDateText(for: date))
                    .font(.caption)
                    .foregroundColor(theme.tokens.textSecondary)
            }
        }
    }
    
    /// Handle reminder selection (check permission and save)
    private func handleReminderSelection(date: Date) {
        _Concurrency.Task {
            let manager = ReminderManager.shared
            let hasPermission = await manager.hasNotificationPermission
            
            if !hasPermission {
                let granted = await manager.requestNotificationPermission()
                if !granted {
                    await MainActor.run {
                        showPermissionAlert = true
                    }
                    return
                }
            }
            
            await MainActor.run {
                onSave(date)
                dismiss()
            }
        }
    }
    
    /// Calculate tomorrow at 9 AM
    private func tomorrowAt9AM() -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 9
        components.minute = 0
        return calendar.date(from: components) ?? tomorrow
    }
    
    /// Format relative date text (e.g., "Today 3:30 PM", "Tomorrow 9:00 AM")
    private func relativeDateText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

// CustomDatePickerSheet now extracted to Views/Shared/CustomDatePickerSheet.swift for reuse
