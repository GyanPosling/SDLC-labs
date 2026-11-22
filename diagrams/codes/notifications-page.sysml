package RateFlow_NotificationsScreen {
    private import ScalarValues::*;

    part def NotificationsScreen {
        attribute title : String = "RateFlow — Уведомления";
        part header : Header;
        part ruleEditor : RuleEditor;
        part ruleState : RuleState;
        part eventList : NotificationList;
        part actions : NotificationActions;
        part footer : Footer;
    }

    part def Header {
        attribute logo : String = "RateFlow";
        attribute navigation : String = "Курсы / Конвертер / История / Уведомления";
    }

    part def RuleEditor {
        attribute currency : String = "USD / EUR / RUB";
        attribute threshold : String = "Порог от 0,1 до 100 процентов";
        attribute defaultThreshold : String = "По умолчанию 2 процента";
    }

    part def RuleState {
        attribute toggle : String = "Включить / отключить";
        attribute storage : String = "Сохранение в этом браузере";
        attribute delivery : String = "Проверка при открытом сайте";
    }

    part def NotificationList {
        attribute event : String = "Валюта, даты, направление";
        attribute change : String = "Процент изменения курса";
        attribute limit : String = "Последние 100 событий";
    }

    part def NotificationActions {
        attribute read : String = "Отметить прочитанным";
        attribute clear : String = "Очистить список";
        attribute duplicates : String = "Без повторов для одной даты";
    }

    part def Footer {
        attribute source : String = "Источник курсов — НБРБ";
        attribute note : String = "Справочная информация";
    }

    part page : NotificationsScreen;
}
