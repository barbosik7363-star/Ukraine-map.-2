# AlertSim — симулятор тривог (SwiftUI, Liquid Glass)

## Як зібрати IPA на GitHub
1. Створіть новий репозиторій на GitHub і завантажте туди всі файли з цієї папки (зберігаючи структуру, включно з `.github/workflows/build.yml`).
2. Перейдіть у вкладку Actions → Build IPA → Run workflow.
3. Після завершення збірки внизу сторінки з'явиться артефакт `AlertSim-ipa` з файлом `AlertSim.ipa`.

## Встановлення
Збірка без підпису. Щоб поставити на iPhone, використайте AltStore, Sideloadly або Feather — вони підпишуть IPA вашим Apple ID.

## Вимоги
- Для збірки: GitHub-раннер macOS з Xcode 26 (Liquid Glass). Застосунок працює й на iOS 17+, там використовується матеріал замість Liquid Glass.
