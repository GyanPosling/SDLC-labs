# Графическая часть RateFlow

| Исходник SysMLv2 | Изображение | Содержание |
|---|---|---|
| [use-cases.sysml](use-cases.sysml) | [use-cases.png](use-cases.png) | Шесть вариантов использования, их субъект RateFlow и актор User |
| [ui-structure.sysml](ui-structure.sysml) | [ui-structure.png](ui-structure.png) | Структура приложения, четыре экрана и элементы интерфейса |

Исходники написаны в текстовой нотации SysMLv2. Первая модель использует `use case def`, `subject`, `actor` и `objective`; вторая — `part def`, `part` и строковые атрибуты. Структурная модель GUI описывает состав экранов, а не точные координаты реальных кнопок.

PNG созданы локальным скриптом [render.ps1](render.ps1), который читает эти модели и рисует их представления средствами Windows System.Drawing. Это специально подготовленные иллюстрации моделей, а не экспорт из полноценного SysMLv2-редактора. Скрипт поддерживает только структуру этих двух исходников и не проверяет семантику всего языка. Проверка специализированным SysMLv2-компилятором не выполнялась.

Пересоздать обе картинки из корня репозитория в PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File diagrams/render.ps1
```

Для просмотра исходников в редакторе SysMLv2 можно использовать VS Code с расширением `JamieD.sysml-v2-support`: открыть файл, выполнить `SysML: Show Model Visualizer`, затем `SysML: Export Visualization (PNG/SVG)`. Результат расположения блоков может отличаться от локальных PNG.
