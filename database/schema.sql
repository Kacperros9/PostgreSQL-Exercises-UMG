CREATE TABLE klienci
(
   idklienta character(5),
   nazwa character varying(30),
   nip character(8),
   adres character varying(30),
   miasto character varying(20),
   kod character(6),
   rabat numeric(6,2)
);

CREATE TABLE produkty
(
  idproduktu character(5),
  nazwa character varying(30),
  cena numeric(8,2),
  vat numeric(6,2),
  ilosc_w_op numeric(8,2),
  miara character varying(10),
  producent character varying(30),
  stan numeric(8,2)
 );

CREATE TABLE nagsprzedaz
(
  nrfaktury serial,
  idklienta character(5),
  datasp date,
  zaplacono character(3)
 );  

CREATE TABLE pozsprzedaz
(
   idpoz serial,
   nrfaktury integer,
   idproduktu character(5),
   ilosc numeric(8,2)
);