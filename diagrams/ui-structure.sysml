package RateFlowUI {
    private import ScalarValues::*;

    part def RatesScreen {
        attribute title : String = "Курсы";
        attribute currencySelector : String = "Выбор: USD / EUR / RUB";
        attribute ratesTable : String = "Код | Номинал | Курс BYN | Изменение";
        attribute rateDate : String = "Дата действия курса и источник";
        attribute refreshButton : String = "Обновить";
        attribute dataStatus : String = "Статус получения данных";
    }

    part def ConverterScreen {
        attribute title : String = "Конвертер";
        attribute amountInput : String = "Сумма: 0 ... 1 000 000 000";
        attribute sourceCurrency : String = "Из: BYN / USD / EUR / RUB";
        attribute targetCurrency : String = "В: BYN / USD / EUR / RUB";
        attribute result : String = "Результат и дата расчёта";
        attribute validationMessage : String = "Ошибка ввода или статуса данных";
    }

    part def HistoryScreen {
        attribute title : String = "История";
        attribute currencySelector : String = "Валюта: USD / EUR / RUB";
        attribute periodSelector : String = "Период: 7 / 30 / 90 дней";
        attribute chart : String = "График: дата — BYN за 1 единицу";
        attribute summary : String = "Первый курс / последний курс / изменение";
        attribute emptyState : String = "Нет данных / недостаточно данных";
    }

    part def NotificationsScreen {
        attribute title : String = "Уведомления";
        attribute currencySelector : String = "Валюта: USD / EUR / RUB";
        attribute thresholdInput : String = "Порог: 0,1 ... 100%; по умолчанию 2%";
        attribute ruleToggle : String = "Включить / отключить правило";
        attribute eventList : String = "События: дата / направление / процент";
        attribute eventActions : String = "Прочитано / очистить список";
        attribute deliveryNote : String = "Проверка при открытом приложении";
    }

    part def RateFlow {
        attribute navigation : String = "Курсы | Конвертер | История | Уведомления";
        part rates : RatesScreen;
        part converter : ConverterScreen;
        part history : HistoryScreen;
        part alerts : NotificationsScreen;
    }

    part application : RateFlow;
}