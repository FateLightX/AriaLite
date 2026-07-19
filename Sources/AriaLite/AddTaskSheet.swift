import AppKit
import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject private var store: AppStore
    @State private var urlText = ""
    @State private var fileName = ""
    @State private var downloadDirectory = ""
    @State private var splitCount = 64

    private var hasURLInput: Bool {
        !parsedURLs.isEmpty
    }

    private var hasInvalidURLInput: Bool {
        let lines = urlText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return !lines.isEmpty && lines.count != parsedURLs.count
    }

    private var parsedURLs: [String] {
        urlText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { isSupportedURL($0) }
    }

    var body: some View {
        Group {
            if #available(macOS 26.0, *) {
                GlassEffectContainer(spacing: 14) {
                    sheetContent
                }
            } else {
                sheetContent
            }
        }
        .onAppear {
            downloadDirectory = store.settings.downloadDirectory
            splitCount = store.settings.splitCount
        }
    }

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            urlTaskForm

            Spacer(minLength: 0)

            footer
        }
        .padding(24)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("新建任务")
                .font(.title3.weight(.semibold))

            Text("添加 http、https、ftp 或磁力链接")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var urlTaskForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            glassPanel {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center) {
                        Label("下载链接", systemImage: "link")
                            .font(.headline)

                        Spacer()

                        Button {
                            pasteURLText()
                        } label: {
                            Label("粘贴", systemImage: "doc.on.clipboard")
                        }
                        .ariaLiteGlassButtonStyle()
                        .controlSize(.small)
                    }

                    urlEditor

                    if hasInvalidURLInput {
                        Label("仅支持 http、https、ftp 和 magnet 链接。", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }

            glassPanel {
                VStack(spacing: 10) {
                    directoryRow
                    fileNameRow
                    splitCountRow
                }
            }
        }
    }

    private var urlEditor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)

            TextEditor(text: $urlText)
                .font(.callout.monospaced())
                .scrollContentBackground(.hidden)
                .padding(8)

            if urlText.isEmpty {
                Text("https://example.com/file.zip")
                    .font(.callout.monospaced())
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 13)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 104)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(hasInvalidURLInput ? Color.red.opacity(0.7) : Color(nsColor: .separatorColor).opacity(0.65), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func glassPanel<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if #available(macOS 26.0, *) {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.55), lineWidth: 1)
                }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Text("\(parsedURLs.count) 个有效链接")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("取消") {
                store.showAddTask = false
            }
            .ariaLiteGlassButtonStyle()
            .keyboardShortcut(.cancelAction)

            Button("开始下载") {
                Task {
                    await store.addURLTask(
                        urlText: parsedURLs.joined(separator: "\n"),
                        fileName: fileName,
                        splitCount: splitCount,
                        downloadDirectory: downloadDirectory
                    )
                }
            }
            .ariaLiteGlassButtonStyle(prominent: true)
            .keyboardShortcut(.defaultAction)
            .disabled(!hasURLInput || hasInvalidURLInput)
        }
    }

    private var directoryRow: some View {
        formRow("保存到") {
            HStack(spacing: 8) {
                Text(downloadDirectory)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .frame(height: 28)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Button("选择...") {
                    chooseDownloadDirectory()
                }
                .ariaLiteGlassButtonStyle()
                .controlSize(.small)
            }
        }
    }

    private var fileNameRow: some View {
        formRow("文件名") {
            TextField("自动识别", text: $fileName)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var splitCountRow: some View {
        formRow("分片数") {
            HStack(spacing: 8) {
                Text("\(splitCount)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 34, alignment: .leading)

                Stepper("分片数", value: $splitCount, in: 1...64)
                    .labelsHidden()
                    .controlSize(.small)

                Spacer()
            }
        }
    }

    private func formRow<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .trailing)

            content()
        }
        .font(.callout)
    }

    private func chooseDownloadDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "选择"

        if panel.runModal() == .OK, let url = panel.url {
            downloadDirectory = url.path
        }
    }

    private func pasteURLText() {
        if let text = NSPasteboard.general.string(forType: .string) {
            urlText = text
        }
    }

    private func isSupportedURL(_ value: String) -> Bool {
        let lowercased = value.lowercased()
        return lowercased.hasPrefix("http://")
            || lowercased.hasPrefix("https://")
            || lowercased.hasPrefix("ftp://")
            || lowercased.hasPrefix("magnet:")
    }
}

private extension View {
    @ViewBuilder
    func ariaLiteGlassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                buttonStyle(.glassProminent)
            } else {
                buttonStyle(.glass)
            }
        } else if prominent {
            buttonStyle(.borderedProminent)
        } else {
            buttonStyle(.bordered)
        }
    }
}
