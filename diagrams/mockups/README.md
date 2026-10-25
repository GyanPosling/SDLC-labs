# Визуальные мокапы RateFlow

Эти PNG дополняют структурные диаграммы: они показывают пример размещения навигации, полей, таблиц, кнопок, графика и уведомлений на экранах приложения. Это статические макеты, элементы на изображениях не интерактивны.

| Экран | Мокап PNG | Соответствующая модель SysMLv2 |
|---|---|---|
| Курсы валют | [rates-mockup.png](rates-mockup.png) | [rates-page.sysml](../rates-page.sysml) |
| Конвертер | [converter-mockup.png](converter-mockup.png) | [converter-page.sysml](../converter-page.sysml) |
| История курсов | [history-mockup.png](history-mockup.png) | [history-page.sysml](../history-page.sysml) |
| Уведомления | [notifications-mockup.png](notifications-mockup.png) | [notifications-page.sysml](../notifications-page.sysml) |

Использованы вымышленные данные для демонстрации интерфейса. Значения не являются фактическими курсами на указанную дату. Макеты показывают основной успешный сценарий при ширине 1600 пикселей; отдельные мобильные варианты и экраны ошибок пока не подготовлены.

Мокапы создаются [render-mockups.py](render-mockups.py) с помощью Python и Pillow. Скрипт читает заголовок и проверяет базовый состав соответствующей SysMLv2-модели. Расположение элементов и демонстрационные значения заданы в самом скрипте; это дополнительная визуальная интерпретация моделей, а не результат исполнения SysMLv2 или экспорт из специализированного редактора.

Для повторного создания на Windows с установленными Pillow и шрифтами Arial:

```powershell
python diagrams/mockups/render-mockups.py
```
