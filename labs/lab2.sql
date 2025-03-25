-- 1. Wszystkie dane dokumentów sprzedaży wraz z pełną nazwą i adresem klienta uporządkowane alfabetycznie
-- według nazw klientów; tylko pierwszych 7 dokumentów sprzedaży

SELECT nagsprzedaz.*, klienci.nazwa, klienci.adres 
FROM nagsprzedaz
JOIN klienci ON nagsprzedaz.idklienta = klienci.idklienta
ORDER BY klienci.nazwa
LIMIT 7;

-- 2. Nazwy i adresy klientów, którzy kupowali w pierwszych pięciu dniach dowolnego miesiąca

SELECT DISTINCT klienci.nazwa, klienci.adres 
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
WHERE EXTRACT(DAY FROM nagsprzedaz.datasp) <= 5;

-- 3. Identyfikatory produktów kupowanych między 25 a 30 dniem każdego miesiąca przez klienta K03.

SELECT DISTINCT pozsprzedaz.idproduktu FROM pozsprzedaz
JOIN nagsprzedaz ON pozsprzedaz.nrfaktury = nagsprzedaz.nrfaktury
WHERE EXTRACT(DAY FROM nagsprzedaz.datasp) BETWEEN 25 AND 30
AND nagsprzedaz.idklienta = 'K03';

-- 4. Nazwy i adresy klientów, którzy kupili produkty Malfarba

SELECT DISTINCT klienci.nazwa, klienci.adres 
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE produkty.producent ILIKE '%malfarb%';

-- 5. Nazwy i adresy klientów z Sopotu lub Gdańska, którzy kupowali liczone na metry lub kilogramy produkty w cenie
-- wyższej niż 40

SELECT DISTINCT klienci.nazwa, klienci.adres 
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE klienci.miasto IN ('Sopot', 'Gdańsk')
AND (produkty.cena > 40 AND produkty.ilosc_w_op > 0);

-- 6. Nazwy i producenci produktów, które nie były sprzedawane

SELECT produkty.nazwa, produkty.producent 
FROM produkty
LEFT JOIN pozsprzedaz ON produkty.idproduktu = pozsprzedaz.idproduktu
WHERE pozsprzedaz.idproduktu IS NULL;

-- 7. Identyfikatory sprzedanych produktów nie zapisanych w tabeli produkty

SELECT pozsprzedaz.idproduktu FROM pozsprzedaz
LEFT JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE produkty.idproduktu IS NULL;

-- 8. Numery faktur i identyfikatory klientów, którym je wystawiono, ale o których to klientach nic poza identyfikatorem
-- nie wiadomo

SELECT nagsprzedaz.nrfaktury, nagsprzedaz.idklienta 
FROM nagsprzedaz
LEFT JOIN klienci ON nagsprzedaz.idklienta = klienci.idklienta
WHERE klienci.idklienta IS NULL;

-- 9. Łączne sprzedane ilości poszczególnych produktów

SELECT pozsprzedaz.idproduktu, 
       SUM(pozsprzedaz.ilosc) AS laczna_sprzedana_ilosc 
FROM pozsprzedaz
GROUP BY pozsprzedaz.idproduktu;

-- 10. Numery, daty wystawienia i wartości brutto i poszczególnych dokumentów sprzedaży

SELECT pozsprzedaz.nrfaktury, 
	   nagsprzedaz.datasp,
	   ROUND(produkty.cena * pozsprzedaz.ilosc * (1 + produkty.vat), 2) AS cena_brutto
FROM pozsprzedaz
JOIN nagsprzedaz ON pozsprzedaz.nrfaktury = nagsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu;

-- 11. Dla każdego klienta (identyfikator) podaj wartość netto jego zakupów z okresu 15 lutego – 15 marca

SELECT klienci.idklienta, 
       ROUND(SUM(produkty.cena * pozsprzedaz.ilosc), 2) AS wartosc_netto
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE 
(EXTRACT(MONTH FROM nagsprzedaz.datasp) = 2 AND EXTRACT(DAY FROM nagsprzedaz.datasp) >= 15)
OR 
(EXTRACT(MONTH FROM nagsprzedaz.datasp) = 3 AND EXTRACT(DAY FROM nagsprzedaz.datasp) <= 15)
GROUP BY klienci.idklienta;

-- 12. Dla każdego klienta (identyfikator) podaj datę ostatniej sprzedaży i liczbę wystawionych mu dokumentów
-- sprzedaży

SELECT klienci.idklienta,
       MAX(nagsprzedaz.datasp) AS ostatnia_sprzedaz,
       COUNT(nagsprzedaz.nrfaktury) AS liczba_dokumentow_sprzedazy
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
GROUP BY klienci.idklienta;

-- 13. Dla każdego klienta podaj wartość brutto jego zakupów z podziałem na zapłacone i niezapłacone.
-- I sposób:

SELECT klienci.idklienta,
	   nagsprzedaz.zaplacono,
       SUM(pozsprzedaz.ilosc * (1 + produkty.vat * produkty.cena)) AS cena_brutto
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY klienci.idklienta, nagsprzedaz.zaplacono;

-- II sposób:

SELECT klienci.idklienta,
       SUM(CASE WHEN nagsprzedaz.zaplacono = 'tak' THEN pozsprzedaz.ilosc * (1 + produkty.vat * produkty.cena) ELSE 0 END) AS wartosc_zaplacona,
       SUM(CASE WHEN nagsprzedaz.zaplacono = 'nie' THEN pozsprzedaz.ilosc * (1 + produkty.vat * produkty.cena) ELSE 0 END) AS wartosc_nie_zaplacona
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY klienci.idklienta;

-- 14. Jakie ilości poszczególnych produktów kupowano w poszczególnych miesiącach

SELECT EXTRACT(MONTH FROM nagsprzedaz.datasp) AS miesiac,
       SUM(pozsprzedaz.ilosc) AS ilosc,
       produkty.nazwa
FROM nagsprzedaz
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY produkty.nazwa, miesiac

-- 15. Dni (data) z utargiem (brutto) większym niż 2000

SELECT EXTRACT(DAY FROM nagsprzedaz.datasp) AS dzien,
       SUM(pozsprzedaz.ilosc * produkty.cena * (1 + produkty.vat)) AS utarg_brutto
FROM nagsprzedaz
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY nagsprzedaz.datasp
HAVING SUM(pozsprzedaz.ilosc * produkty.cena * (1 + produkty.vat)) > 2000;

-- 16. Identyfikatory produktów, których wartość sprzedaży (netto) w marcu wyniosła więcej niż 1000

SELECT produkty.idproduktu,
       SUM(produkty.cena * pozsprzedaz.ilosc) AS wartosc_netto
FROM nagsprzedaz
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE EXTRACT(MONTH FROM nagsprzedaz.datasp) = 3
GROUP BY produkty.idproduktu
HAVING SUM(pozsprzedaz.ilosc * produkty.cena) > 1000;

-- 17. Liczone na sztuki produkty, które były sprzedawane co najmniej 5 razy; których łączna wartość sprzedaży
-- wyniosła więcej niż 2000

SELECT produkty.idproduktu,
	   produkty.nazwa,
	   SUM(pozsprzedaz.ilosc * produkty.cena) AS cena_netto,
	   COUNT(pozsprzedaz.nrfaktury) AS liczba_transakcji
FROM pozsprzedaz
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
JOIN nagsprzedaz ON pozsprzedaz.nrfaktury = nagsprzedaz.nrfaktury
GROUP BY produkty.idproduktu, produkty.nazwa
HAVING COUNT(pozsprzedaz.nrfaktury) >=  5
AND SUM(pozsprzedaz.ilosc * produkty.cena) > 2000;

-- 18. Identyfikatory klientów, których ostatnia wizyta w sklepie odbyła się po 10 marca

SELECT DISTINCT nagsprzedaz.idklienta,
                nagsprzedaz.datasp
FROM nagsprzedaz
JOIN klienci ON nagsprzedaz.idklienta = klienci.idklienta
WHERE EXTRACT(MONTH FROM nagsprzedaz.datasp) = 3
AND EXTRACT(DAY FROM nagsprzedaz.datasp) > 10

-- 19. Producent, którego produkty dały największe wpływy

SELECT produkty.producent, 
       SUM(pozsprzedaz.ilosc * produkty.cena) AS wartosc_sprzedazy
FROM produkty
JOIN pozsprzedaz ON produkty.idproduktu = pozsprzedaz.idproduktu
GROUP BY produkty.producent
ORDER BY wartosc_sprzedazy DESC
LIMIT 1;

-- 20. Nazwy klientów z siedzibami w tym samym mieście, co WodKanRem

SELECT k1.nazwa FROM klienci k1
JOIN klienci k2 ON k1.miasto = k2.miasto 
WHERE k2.nazwa = 'WodKanRem' 
AND k1.idklienta != k2.idklienta;

-- 21. Nazwy, adresy klientów, którzy nic nie kupowali w lutym

SELECT klienci.nazwa, klienci.adres
FROM klienci
WHERE klienci.idklienta NOT IN (
    SELECT DISTINCT nagsprzedaz.idklienta
    FROM nagsprzedaz
    WHERE EXTRACT(MONTH FROM nagsprzedaz.datasp) = 2
);

-- 22. Identyfikator produktu, który był najczęściej kupowany

SELECT pozsprzedaz.idproduktu FROM pozsprzedaz
GROUP BY pozsprzedaz.idproduktu
ORDER BY SUM(pozsprzedaz.ilosc) DESC
LIMIT 1;
-- 23. Dla każdego produktu podaj, ilu różnych klientów go kupowało

SELECT produkty.nazwa, 
       COUNT(DISTINCT nagsprzedaz.idklienta) AS liczba_klientow
FROM pozsprzedaz
JOIN nagsprzedaz ON pozsprzedaz.nrfaktury = nagsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY produkty.nazwa;

-- 24. Średnia wartość wystawionej faktury

SELECT klienci.nazwa, nagsprzedaz.nrfaktury
FROM nagsprzedaz
JOIN klienci ON nagsprzedaz.idklienta = klienci.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY klienci.nazwa, nagsprzedaz.nrfaktury
HAVING SUM(pozsprzedaz.ilosc * produkty.cena) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(pozsprzedaz.ilosc * produkty.cena) AS total
        FROM pozsprzedaz
        JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
        GROUP BY pozsprzedaz.nrfaktury
    ) AS faktury
);

-- 25. Nazwy klientów i numery faktur o wartości wyższej niż średnia wartość faktury

SELECT klienci.nazwa, 
       nagsprzedaz.nrfaktury, 
       SUM(pozsprzedaz.ilosc * produkty.cena) AS wartosc_faktury
FROM klienci
JOIN nagsprzedaz ON klienci.idklienta = nagsprzedaz.idklienta
JOIN pozsprzedaz ON nagsprzedaz.nrfaktury = pozsprzedaz.nrfaktury
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
GROUP BY klienci.nazwa, nagsprzedaz.nrfaktury
HAVING SUM(pozsprzedaz.ilosc * produkty.cena) > 
    (SELECT AVG(wartosc_faktury)
     FROM (
        SELECT SUM(pozsprzedaz.ilosc * produkty.cena) AS wartosc_faktury
        FROM pozsprzedaz
        JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
        GROUP BY pozsprzedaz.nrfaktury
     ) AS srednia_wartosc);