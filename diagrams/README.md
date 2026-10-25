# Графическая часть RateFlow

Дополнительно подготовлены [визуальные мокапы четырёх экранов](mockups/README.md): расположение элементов интерфейса в виде страниц будущего приложения. Структурные схемы ниже сохранены отдельно.

Схемы экранов оформлены по предоставленному образцу: сверху определение страницы `part def`, посередине её составные части `part`, снизу определения компонентов с атрибутами. Чёрный ромб обозначает композицию страницы и её частей; стрелки от частей к нижним блокам показывают их типы.

| Экран или модель | Исходник SysMLv2 | Изображение |
|---|---|---|
| Курсы валют | [rates-page.sysml](rates-page.sysml) | [rates-page.png](rates-page.png) |
| Конвертер валют | [converter-page.sysml](converter-page.sysml) | [converter-page.png](converter-page.png) |
| История курсов | [history-page.sysml](history-page.sysml) | [history-page.png](history-page.png) |
| Уведомления | [notifications-page.sysml](notifications-page.sysml) | [notifications-page.png](notifications-page.png) |
| Варианты использования | [use-cases.sysml](use-cases.sysml) | [use-cases.png](use-cases.png) |

Каждая модель страницы находится в своём пакете и содержит шесть компонентов. Header и Footer имеют локальные определения внутри пакетов; остальные компоненты отражают назначение экрана. Это структурные прототипы GUI, описывающие состав страниц, а не координаты реальных элементов сайта.

PNG созданы локальными скриптами Windows System.Drawing: [render-pages.ps1](render-pages.ps1) строит схемы страниц из исходников, [render.ps1](render.ps1) запускает его и создаёт диаграмму вариантов использования. Скрипты поддерживают только структуру этих моделей и не заменяют полноценный редактор и семантический анализатор SysMLv2. Проверка специализированным компилятором не выполнялась.

Пересоздать все пять картинок из корня репозитория:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File diagrams/render.ps1
```

Для просмотра исходников в редакторе SysMLv2 можно использовать VS Code с расширением `JamieD.sysml-v2-support`: открыть файл, выполнить `SysML: Show Model Visualizer`, затем `SysML: Export Visualization (PNG/SVG)`. Расположение блоков в редакторе может отличаться от подготовленных PNG.
