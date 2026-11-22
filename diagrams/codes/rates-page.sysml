package RateFlow_RatesScreen {
    private import ScalarValues::*;

    part def RatesScreen {
        attribute title : String = "RateFlow — Курсы валют";
        part header : Header;
        part currencySelector : CurrencySelector;
        part ratesTable : RatesTable;
        part refreshPanel : RefreshPanel;
        part dataStatus : DataStatus;
        part footer : Footer;
    }

    part def Header {
        attribute logo : String = "RateFlow";
        attribute navigation : String = "Курсы / Конвертер / История / Уведомления";
    }

    part def CurrencySelector {
        attribute currencies : String = "USD, EUR, RUB";
        attribute selection : String = "Выбор отображаемых валют";
    }

    part def RatesTable {
        attribute columns : String = "Код, номинал, курс BYN";
        attribute change : String = "Рост или снижение курса";
        attribute date : String = "Дата действия курса";
    }

    part def RefreshPanel {
        attribute button : String = "Обновить курсы";
        attribute interval : String = "Каждые 60 минут";
    }

    part def DataStatus {
        attribute lastUpdate : String = "Время последнего обновления";
        attribute error : String = "Ошибка загрузки / повторить";
        attribute cached : String = "Отметка сохранённых данных";
    }

    part def Footer {
        attribute source : String = "Источник курсов — НБРБ";
        attribute note : String = "Справочная информация";
    }

    part page : RatesScreen;
}
