package RateFlow_ConverterScreen {
    private import ScalarValues::*;

    part def ConverterScreen {
        attribute title : String = "RateFlow — Конвертер валют";
        part header : Header;
        part amountInput : AmountInput;
        part currencyPair : CurrencyPair;
        part result : ConversionResult;
        part validation : ValidationMessage;
        part footer : Footer;
    }

    part def Header {
        attribute logo : String = "RateFlow";
        attribute navigation : String = "Курсы / Конвертер / История / Уведомления";
    }

    part def AmountInput {
        attribute label : String = "Сумма для пересчёта";
        attribute range : String = "От 0 до 1 000 000 000";
        attribute separator : String = "Запятая или точка";
    }

    part def CurrencyPair {
        attribute sourceCurrency : String = "Исходная валюта";
        attribute targetCurrency : String = "Целевая валюта";
        attribute options : String = "BYN, USD, EUR, RUB";
    }

    part def ConversionResult {
        attribute amount : String = "Результат с двумя знаками";
        attribute date : String = "Единая дата курсов";
        attribute nominal : String = "Учёт номинала валюты";
    }

    part def ValidationMessage {
        attribute inputError : String = "Некорректная сумма";
        attribute dataError : String = "Нет курсов на одну дату";
        attribute hint : String = "Пояснение для исправления";
    }

    part def Footer {
        attribute source : String = "Источник курсов — НБРБ";
        attribute note : String = "Справочная информация";
    }

    part page : ConverterScreen;
}
