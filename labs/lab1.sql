-- 1. Oblicz ile wynosi 2*2 (SELECT 2*2 AS iloczyn)

SELECT 2*2 AS iloczyn;

-- 2. Podaj wszystkie dane o klientach (SELECT * FROM klienci)

SELECT * FROM klienci;

-- 3. Podaj identyfikator, nazwę, producenta i cenę każdego produktu

SELECT idproduktu, nazwa, producent, cena 
FROM produkty;

-- 4. Nazwa, cena, stan produktów producenta Cersanit

SELECT nazwa, cena, stan 
FROM produkty
WHERE producent = 'Cersanit';

-- 5. Identyfikator, nazwa, producent, cena produktów droższych niż 100

SELECT idproduktu, nazwa, producent, cena
FROM produkty
WHERE cena > 100;

-- 6. Numer faktury, id klienta, data dokumentów sprzedaży z okresu 15 – 25 stycznia

SELECT nrfaktury, idklienta, datasp 
FROM nagsprzedaz
WHERE EXTRACT(MONTH FROM datasp) = 1
AND EXTRACT(DAY FROM datasp) BETWEEN 15 AND 25;

-- 7. Nazwa, cena, miara i stan lakierów

SELECT nazwa, cena, miara, stan 
FROM produkty
WHERE nazwa ILIKE '%lakier%';

-- 8. Identyfikator, nazwa, adres klientów z Gdyni i Sopotu

-- I sposób:
SELECT idklienta, nazwa, adres 
FROM klienci
WHERE miasto IN ('Gdynia', 'Sopot');

-- II sposób (Jeśli w tabeli są miasta z wielkimi, jak i małymi literami):
SELECT idklienta, nazwa, adres 
FROM klienci
WHERE miasto ILIKE 'gdynia' OR miasto ILIKE 'sopot';

-- 9. Nazwa, producent, stan produktów Malfarba i Cersanita ze stanami w granicach [200, 2000]

-- I sposób:
SELECT nazwa, producent, stan 
FROM produkty
WHERE producent IN ('Malfarb', 'Cersanit')
AND stan BETWEEN 200 and 2000;

-- II sposób (Jeśli w tabeli są produkty z wielkimi jak i małymi literami):
SELECT nazwa, producent, stan 
FROM produkty
WHERE (producent ILIKE 'malfarb' OR producent ILIKE 'cersanit')
AND (stan BETWEEN 200 AND 2000);

-- 10. Nazwa, miasto, rabat klientów z Gdyni lub Słupska lub z niezerowym rabatem

SELECT nazwa, miasto, rabat 
FROM klienci
WHERE miasto IN ('Gdynia', 'Słupsk')
OR rabat > 0;

-- 11. Identyfikator, nazwa klienta z niezerowym rabatem z Gdyni lub Gdańska

SELECT idklienta, nazwa 
FROM klienci
WHERE rabat > 0 AND miasto IN ('Gdynia', 'Słupsk');

-- 12. Pełna informacja o każdym produkcie oraz jego cena brutto (w tabeli przechowujemy cenę netto)

SELECT *, ROUND(cena * (1 + vat), 2) AS cena_brutto
FROM produkty;

-- 13. Pełna informacja o nieopłaconych dokumentach sprzedaży oraz liczba dni jakie minęły od dnia sprzedaży do dziś

SELECT *, CURRENT_DATE - datasp AS dni_od_sprzedazy
FROM nagsprzedaz
WHERE zaplacono = 'nie';

-- 14. Numery dokumentów sprzedaży na które sprzedano produkty o identyfikatorach P06, P15, P36

SELECT DISTINCT pozsprzedaz.nrfaktury FROM pozsprzedaz
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE produkty.idproduktu IN ('P06', 'P15', 'P36');

-- 15. Identyfikatory klientów, którzy kupowali w styczniu

SELECT DISTINCT idklienta FROM nagsprzedaz
WHERE EXTRACT(MONTH FROM datasp) = 1 
AND zaplacono = 'tak';

-- 16. Identyfikatory produktów, które były sprzedawane

SELECT DISTINCT pozsprzedaz.idproduktu FROM pozsprzedaz;

-- 17. Wartości poszczególnych produktów, jakie mamy na stanie

SELECT *, (cena * stan) AS wartosc_na_stanie
FROM produkty;

-- 18. Numery i daty nieopłaconych dokumentów sprzedaży zrealizowanych w lutym

SELECT nrfaktury, datasp 
FROM nagsprzedaz
WHERE zaplacono = 'nie'
AND EXTRACT(MONTH FROM datasp) = 2;

-- 19. Kiedy (data) pojawił się pierwszy klient

SELECT datasp FROM nagsprzedaz
ORDER BY datasp
LIMIT 1;

-- 20. Nazwa i producent najdroższego produktu

SELECT nazwa, producent 
FROM produkty
ORDER BY cena DESC
LIMIT 1;

-- 21. Pełna informacja o dokumentach sprzedaży wraz z pełnymi danymi klienta

SELECT klienci.*, nagsprzedaz.* 
FROM nagsprzedaz
JOIN klienci ON nagsprzedaz.idklienta = klienci.idklienta;

-- 22. Pełny opis pozycji sprzedaży oraz jej wartość netto i brutto

SELECT pozsprzedaz.*,
       produkty.cena AS cena_netto,
	   produkty.cena * (1 + produkty.vat) AS cena_brutto 
FROM pozsprzedaz
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu;

-- 23. Nazwy, miary i stany sprzedawanych produktów producenta Cersanit 

SELECT produkty.nazwa, 
	   produkty.miara,
	   produkty.stan
FROM produkty
JOIN pozsprzedaz ON produkty.idproduktu = pozsprzedaz.idproduktu
WHERE producent = 'Cersanit';

-- 24. Nazwy i miary farb i emulsji, które sprzedano w ilościach (ilosc*ilość_w_op) większych niż 10

SELECT produkty.nazwa, produkty.miara
FROM produkty
JOIN pozsprzedaz ON produkty.idproduktu = pozsprzedaz.idproduktu
WHERE (produkty.nazwa ILIKE '%farba%' OR produkty.nazwa ILIKE '%emulsja%')
AND (produkty.ilosc_w_op * pozsprzedaz.ilosc) > 10;

-- 25. Numery dokumentów sprzedaży, na które kupowano farby i taśmę malarską (na jednym dokumencie)

SELECT pozsprzedaz.nrfaktury FROM pozsprzedaz
JOIN produkty ON pozsprzedaz.idproduktu = produkty.idproduktu
WHERE produkty.nazwa ILIKE '%farba%' OR produkty.nazwa ILIKE '%taśma malarska%';

-- 26. Identyfikatory produktów zakupionych w okresie 15 stycznia – 15 lutego

SELECT pozsprzedaz.idproduktu FROM pozsprzedaz
JOIN nagsprzedaz ON pozsprzedaz.nrfaktury = nagsprzedaz.nrfaktury
WHERE 
EXTRACT(MONTH FROM nagsprzedaz.datasp) = 1 AND EXTRACT(DAY FROM nagsprzedaz.datasp) >= 15
OR 
EXTRACT(MONTH FROM nagsprzedaz.datasp) = 2 AND EXTRACT(DAY FROM nagsprzedaz.datasp) <= 15;