# SPEAKEX

Быстрая локальная диктовка для macOS на Apple Silicon. Аудио и расшифровка
не отправляются в облачный API.

SPEAKEX — форк [SuperDictate](https://github.com/shlgd/SuperDictate)
(в свою очередь основанного на [Parakey](https://github.com/rcourtman/parakey)).

Отличия от SuperDictate:

- Исправлен toggle-режим для хоткея «правый Option»: второе нажатие снова
  останавливает диктовку и вставляет текст (раньше его перехватывала
  комбинация Option+Command).

## Установка

**Нужен Mac с Apple Silicon (`M1` или новее) и macOS 14+.**

Сборка из исходников и установка в `/Applications`:

```bash
curl -fsSL https://raw.githubusercontent.com/raxmiev/SPEAKEX/main/install.sh | SPEAKEX_BUILD_FROM_SOURCE=1 bash
```

Понадобятся бесплатные Apple Command Line Tools; если их нет, установщик
откроет диалог установки — после завершения запустите команду ещё раз.

Установка готовой сборки (`curl … | bash` без переменной) заработает после
публикации первого GitHub-релиза SPEAKEX.

После установки нажмите `Grant` для **Microphone**, **Accessibility** и
**Input Monitoring**, дождитесь статуса `Ready` и диктуйте по хоткею.

При первом запуске один раз загрузится локальная модель распознавания
(~460 МБ на диске; для установки лучше иметь не менее 1 ГБ свободного
места). После загрузки интернет для диктовки не нужен.

## Горячие клавиши

- **Хоткей диктовки** (настраивается: правые модификаторы или F-клавиши) —
  начать или закончить диктовку.
- **Правый Shift + правый Command** — открыть или закрыть быструю историю.
- Панель SPEAKEX из Applications — служба, разрешения и настройки.

Панель можно полностью закрыть. Отдельная фоновая служба продолжит работать
и автоматически запустится после следующего входа в macOS.

## Зачем нужны разрешения

- **Microphone** — записывать голос во время активной диктовки.
- **Accessibility** — находить активное поле и вставлять готовый текст.
- **Input Monitoring** — видеть глобальную горячую клавишу.

## Ручная сборка для разработки

```bash
xcode-select --install
git clone https://github.com/raxmiev/SPEAKEX.git
cd SPEAKEX
swift run -c debug --package-path swift Speakex --self-test all
./scripts/build-app.sh ./dist/SPEAKEX.app
open ./dist/SPEAKEX.app
```

По умолчанию локальная сборка подписывается ad-hoc. Чтобы использовать свой
сертификат, передайте его имя:

```bash
SIGN_IDENTITY="Apple Development: Your Name (TEAMID)" ./scripts/build-app.sh ./dist/SPEAKEX.app
```

## Проверки перед коммитом

```bash
./scripts/check.sh
swift run -c debug --package-path swift Speakex --self-test all
./scripts/build-app.sh ./dist/SPEAKEX.app
codesign --verify --deep --strict ./dist/SPEAKEX.app
```

## Данные и приватность

- История и настройки: `~/Library/Application Support/SPEAKEX`.
- Модель FluidAudio: `~/Library/Application Support/FluidAudio/Models`.
- LaunchAgent: `~/Library/LaunchAgents/com.local.speakex.agent.plist`.
- Логи: `~/Library/Logs/SPEAKEX*`.
- Аналитики, аккаунтов и телеметрии нет.

Подробнее: [PRIVACY.md](PRIVACY.md).

## Удаление

```bash
curl -fsSL https://raw.githubusercontent.com/raxmiev/SPEAKEX/main/uninstall.sh | bash
```

История, настройки и модель при этом сохраняются.

## Происхождение и лицензия

SPEAKEX основан на [SuperDictate](https://github.com/shlgd/SuperDictate),
который основан на открытом проекте
[Parakey](https://github.com/rcourtman/parakey) Richard Courtman. Исходный и
изменённый код распространяется по лицензии MIT. См. [LICENSE](LICENSE) и
[NOTICE.md](NOTICE.md).
