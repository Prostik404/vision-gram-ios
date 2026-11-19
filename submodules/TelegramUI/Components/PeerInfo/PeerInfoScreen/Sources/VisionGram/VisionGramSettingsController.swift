// MARK: Vision Gram
//
// Главный экран мода Vision Gram (Настройки → Vision Gram).
// Этап 4: оболочка меню. Разделы наполняются на этапах 5–8.

import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import UndoUI

let visionGramSettingsIcon: UIImage? = renderSettingsIcon(name: "Item List/Icons/VisionGram", backgroundColors: [UIColor(rgb: 0x7D3CF2), UIColor(rgb: 0x3D63F5)])

private let visionGramChatsIcon: UIImage? = renderSettingsIcon(name: "Item List/Icons/Brush", backgroundColors: [UIColor(rgb: 0x0A84FF)])
private let visionGramGhostIcon: UIImage? = renderSettingsIcon(name: "Item List/Icons/Privacy", backgroundColors: [UIColor(rgb: 0x34C759)])
private let visionGramAppearanceIcon: UIImage? = renderSettingsIcon(name: "Item List/Icons/Appearance", backgroundColors: [UIColor(rgb: 0xFF9F0A)])

private final class VisionGramSettingsArguments {
    let openSection: (String) -> Void

    init(openSection: @escaping (String) -> Void) {
        self.openSection = openSection
    }
}

private enum VisionGramSettingsSection: Int32 {
    case header
    case sections
}

private enum VisionGramSettingsEntry: ItemListNodeEntry, Equatable {
    case header(String, String)
    case gifts(String, String)
    case chats(String, String)
    case ghost(String, String)
    case appearance(String, String)
    case footer(String)

    var section: ItemListSectionId {
        switch self {
        case .header:
            return VisionGramSettingsSection.header.rawValue
        case .gifts, .chats, .ghost, .appearance, .footer:
            return VisionGramSettingsSection.sections.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .header:
            return 0
        case .gifts:
            return 1
        case .chats:
            return 2
        case .ghost:
            return 3
        case .appearance:
            return 4
        case .footer:
            return 5
        }
    }

    static func <(lhs: VisionGramSettingsEntry, rhs: VisionGramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! VisionGramSettingsArguments
        switch self {
        case let .header(title, text):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: visionGramSettingsIcon, title: title, label: text, labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .none, action: nil)
        case let .gifts(title, text):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: PresentationResourcesSettings.premiumGift, title: title, label: text, labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openSection(title)
            })
        case let .chats(title, text):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: visionGramChatsIcon, title: title, label: text, labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openSection(title)
            })
        case let .ghost(title, text):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: visionGramGhostIcon, title: title, label: text, labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openSection(title)
            })
        case let .appearance(title, text):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: visionGramAppearanceIcon, title: title, label: text, labelStyle: .multilineDetailText, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openSection(title)
            })
        case let .footer(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private func visionGramSettingsEntries() -> [VisionGramSettingsEntry] {
    var entries: [VisionGramSettingsEntry] = []
    entries.append(.header("Vision Gram", "Версия 0.1 · тестовая сборка"))
    entries.append(.gifts("Подарки", "Фантом-Stars, TON и визуальные подарки"))
    entries.append(.chats("Чаты", "Визуальный редактор звонков и сообщений"))
    entries.append(.ghost("Ghost", "Скрытые функции и защита"))
    entries.append(.appearance("Внешний вид", "Бейджик, цвета и иконка приложения"))
    entries.append(.footer("Разделы наполняются по этапам. Все визуальные элементы мода отмечены меткой DEMO."))
    return entries
}

func visionGramSettingsController(context: AccountContext) -> ViewController {
    var presentControllerImpl: ((ViewController) -> Void)?

    let arguments = VisionGramSettingsArguments(openSection: { title in
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        presentControllerImpl?(UndoOverlayController(presentationData: presentationData, content: .info(title: nil, text: "Раздел «\(title)» появится в следующей версии Vision Gram.", timeout: nil, customUndoText: nil), action: { _ in return false }))
    })

    let signal = context.sharedContext.presentationData
    |> map { presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Vision Gram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: visionGramSettingsEntries(), style: .blocks)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] c in
        controller?.present(c, in: .window(.root))
    }
    return controller
}
