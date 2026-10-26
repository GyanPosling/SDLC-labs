package RateFlow_HistoryScreen {
    private import ScalarValues::*;

    part def HistoryScreen {
        attribute title : String = "RateFlow — История курсов";
        part header : Header;
        part filters : HistoryFilters;
        part chart : RateChart;
        part summary : PeriodSummary;
        part emptyState : EmptyState;
        part footer : Footer;
    }

    part def Header {
        attribute logo : String = "RateFlow";
        attribute navigation : String = "Курсы / Конвертер / История / Уведомления";
    }

    part def HistoryFilters {
        attribute currency : String = "USD / EUR / RUB";
        attribute period : String = "7 / 30 / 90 дней";
    }

    part def RateChart {
        attribute horizontalAxis : String = "Дата";
        attribute verticalAxis : String = "BYN за 1 единицу валюты";
        attribute gaps : String = "Пропуски без подмены нулями";
    }

    part def PeriodSummary {
        attribute first : String = "Первая доступная дата и курс";
        attribute last : String = "Последняя дата и курс";
        attribute change : String = "Изменение за период в процентах";
    }

    part def EmptyState {
        attribute noData : String = "История отсутствует";
        attribute onePoint : String = "Недостаточно данных для изменения";
    }

    part def Footer {
        attribute source : String = "Источник курсов — НБРБ";
        attribute note : String = "Справочная информация";
    }

    part page : HistoryScreen;
}
