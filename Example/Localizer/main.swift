//
//  main.swift
//  localizer2
//
//  Created by EVGENII Loshchenko on 22.03.2021.
//

import Foundation

let fileManager = FileManager.default

if CommandLine.arguments.count >= 2 {
    let projectPath = CommandLine.arguments[1]
    if projectPath.count > 10 && projectPath.contains("webim-client-sdk-ios/Example") { // protection from misunderstanded usage
        ProjectParser.run(projectPath)
    } else {
        print("project path is to short, looks like error, it should be absolute path")
    }

} else {
    print("project path not found")
}
/*
Пример использования утилиты для локализации проекта
в проект добавлен новый target - Localizer
при его запуске он пройдет по всем .swift .storyboard и .xib файлам,
найдет в них значения которые надо локализовать и добавит их в Localizable.strings и .strings файлы относящиеся к UI

////////
как это работает для значений в коде
мы вносим изменения в код, скажем добавляем алерт с текстом "My new message" .localized
перед коммитом мы запускаем target - Localizer и он добавляет новое значение в каждый из Localizable.strings файлов, т.е. в них появятся строки вроде

//RatingDialogViewController.swift
"My new message" = "My new message";

меняем в файле для русской локали строку на
"My new message" = "Мое новое сообщение";
готово, можно коммитить.

////////
как это работает для значений в storyboard и xib
добавляем новую кнопку в IB с текстом "My new button"
перед коммитом мы запускаем target - Localizer и он добавляет новое значение в каждый из Localizable.strings файлов, и в ConnectionErrorView.strings

при этом для каждой локали в Localizable.strings появится
//ConnectionErrorView.xib
"My new button" = "My new button";

а в ConnectionErrorView.strings
"fGs-8a-dfc.text" = "My new button";

мы меняем ТОЛЬКО значение в Localizable.strings на
"My new button" = "Моя новая кнопка";
еще раз запускаем Localizer. Готово, можно коммитить
значение в ConnectionErrorView.strings будет обновлено автоматически

плюсы, при таком подходе
мы не можем пропустить какое либо не локализованное значение
мы не создаем новые енумы и убираем дублирование переводов
нам не нужно совершать дополнительные действия в IB чтобы локализовать текст
*/
