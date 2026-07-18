# SuperDictate

Быстрая локальная диктовка для Mac: нажал **правый Command**, сказал текст,
нажал ещё раз — текст появился в активном поле. Аудио и расшифровка не
отправляются в облако.

## Установка

Нужен Mac с Apple Silicon (`M1` или новее) и macOS 14+.

1. Откройте **Terminal**.
2. Вставьте команду и нажмите Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/shlgd/SuperDictate/main/install.sh | bash
```

3. В открывшемся SuperDictate выдайте три разрешения: **Microphone**,
   **Accessibility** и **Input Monitoring**.

При первом запуске приложение один раз скачает локальную модель распознавания
речи (около 600 МБ). После этого интернет для диктовки не нужен.

Эти три разрешения обязательны: macOS не позволяет приложению самостоятельно
включить микрофон, слушать глобальную горячую клавишу или вставлять текст в
другие приложения.

## Использование

- **Правый Command** — начать или закончить диктовку.
- **Правый Shift + правый Command** — открыть или закрыть быструю историю.
- **Правый Option + правый Command** — альтернативное завершение; поведение
  Enter настраивается в панели SuperDictate.
- Откройте `SuperDictate` из Applications, чтобы проверить службу, разрешения
  и изменить цвета.

Панель настроек можно полностью закрыть: отдельная фоновая служба продолжит
работать и сама запустится после входа в macOS.

## Что делает установщик

Установщик скачивает готовую сборку из
[GitHub Releases](https://github.com/shlgd/SuperDictate/releases), проверяет её
SHA-256 и подпись, помещает `SuperDictate.app` в `/Applications` и открывает
его. Xcode и инструменты разработчика для обычной установки не нужны. Код
установщика находится в [install.sh](install.sh).

Публичная сборка подписана ad-hoc и пока не нотарифицирована Apple. Команда
установки не обходит Gatekeeper через `xattr`, но при обновлении приложения
macOS может повторно запросить разрешения. Стабильная нотарифицированная
подпись потребует сертификат Apple Developer ID.

## Приватность

- Распознавание выполняется локально моделью Parakeet TDT через FluidAudio.
- Аудио не загружается на сервер и не хранится после штатной транскрибации.
- История и настройки лежат только в `~/Library/Application Support/SuperDictate`.
- Аналитики, аккаунтов и телеметрии нет.

Подробнее: [PRIVACY.md](PRIVACY.md).

## Сборка вручную

```bash
git clone https://github.com/shlgd/SuperDictate.git
cd SuperDictate
./scripts/build-app.sh ./dist/SuperDictate.app
open ./dist/SuperDictate.app
```

Ту же проверяемую установку можно целиком выполнить из исходников одной
командой. Для этого понадобятся бесплатные Apple Command Line Tools:

```bash
curl -fsSL https://raw.githubusercontent.com/shlgd/SuperDictate/main/install.sh | SUPERDICTATE_BUILD_FROM_SOURCE=1 bash
```

## Удаление

```bash
curl -fsSL https://raw.githubusercontent.com/shlgd/SuperDictate/main/uninstall.sh | bash
```

Локальная история и модель при обычном удалении сохраняются, чтобы их нельзя
было потерять случайно.

## Происхождение и лицензия

SuperDictate основан на открытом проекте
[Parakey](https://github.com/rcourtman/parakey) Richard Courtman. Исходный и
изменённый код распространяется по лицензии MIT. См. [LICENSE](LICENSE) и
[NOTICE.md](NOTICE.md).
