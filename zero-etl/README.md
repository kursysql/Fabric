<a href="https://www.kursyfabric.pl">
<img src="https://kursyfabric.pl/wp-content/uploads/2025/01/kursySQLlogo_fabric_transparent-145x57.png" title="KursyFabric.pl" alt="KursyFabric.pl"></a>


# Fabric Zero-ETL

Materiały do serii **Fabric Zero-ETL** oraz sesji konferencyjnej *„Zero-ETL czy tylko mniej ETL?”*.

## Źródła

Azure SQL Database:

- `AdventureWorks_Mirror` – baza używana do Mirroring oraz scenariuszy bez natywnego CDC
- `AdventureWorks_CDC` – baza używana do Copy Job z CDC

Obie bazy bazują na AdventureWorksLT i zawierają ten sam zestaw danych testowych.

## Obiekty w Microsoft Fabric

- `sql_zeroetl_control` – Fabric SQL Database z konfiguracją procesów
- `lh_zeroetl_dest` – docelowy Lakehouse

## Filmy

**26. Fabric Zero-ETL: Mirroring i Delta Change Data Feed**  
Mirroring Azure SQL, synchronizacja zmian, CDF, możliwości i ograniczenia.

**27. Fabric Zero-ETL: Copy Job – watermark, CDC i SCD2**  
Full/incremental load, watermark, CDC, DELETE, Merge oraz historia SCD Type 2.

**28. Fabric Zero-ETL: Pipelines**  
Parametryzowany incremental load Azure SQL → Lakehouse, tabela konfiguracyjna, watermark i Upsert.

**29. Zero-ETL czy tylko mniej ETL? Mirroring vs Copy Job vs Pipelines**  
Porównanie podejść, macierz decyzyjna i odpowiedź na pytanie: **Movement ≠ Data Engineering**.