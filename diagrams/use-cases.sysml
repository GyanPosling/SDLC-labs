package RateFlowUseCases {
    part def User;
    part def RateFlowSystem;

    use case def ViewRates {
        subject system : RateFlowSystem;
        actor user : User;
        objective { doc /* Просмотр актуальных курсов */ }
    }

    use case def SelectCurrencies {
        subject system : RateFlowSystem;
        actor user : User;
        objective { doc /* Выбор отображаемых валют */ }
    }

    use case def ConvertAmount {
        subject system : RateFlowSystem;
        actor user : User;
        objective { doc /* Конвертация суммы */ }
    }

    use case def ViewHistory {
        subject system : RateFlowSystem;
        actor user : User;
        objective { doc /* Просмотр графиков изменений */ }
    }

    use case def ConfigureAlerts {
        subject system : RateFlowSystem;
        actor user : User;
        objective { doc /* Настройка порога уведомлений */ }
    }

    use case def ViewAlerts {
        subject system : RateFlowSystem;
        actor user : User;
        objective { doc /* Просмотр и очистка уведомлений */ }
    }
}
