-- 6.1-ci tapşırıq
-- Satış olan ayların ortalaması; il və ay birlikdə qruplaşdırılır.
-- Ləğv edilmiş sifarişlər gəlirə daxil deyil.
WITH aylig_gelir AS (
    SELECT DATE_TRUNC('month', s.tarix)::DATE AS ay,
           SUM(d.qiymet * d.miqdar) AS gelir
    FROM sifarisler AS s
    JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
    WHERE s.status <> 'Ləğv edildi'
    GROUP BY DATE_TRUNC('month', s.tarix)::DATE
)
SELECT ay, gelir FROM aylig_gelir
WHERE gelir > (SELECT AVG(gelir) FROM aylig_gelir)
ORDER BY ay;

-- 6.2-ci tapşırıq
-- Hər kateqoriyada bütün bərabər liderlər qaytarılır.
WITH mehsul_satisi AS (
    SELECT p.mehsul_id, p.ad, p.kateqoriya_id, SUM(d.miqdar) AS satilan_say
    FROM mehsullar AS p
    JOIN sifaris_detallari AS d ON d.mehsul_id = p.mehsul_id
    JOIN sifarisler AS s ON s.sifaris_id = d.sifaris_id
    WHERE s.status <> 'Ləğv edildi'
    GROUP BY p.mehsul_id, p.ad, p.kateqoriya_id
), siralama AS (
    SELECT *, RANK() OVER (PARTITION BY kateqoriya_id ORDER BY satilan_say DESC) AS yer
    FROM mehsul_satisi
)
SELECT k.ad AS kateqoriya, r.ad AS mehsul, r.satilan_say
FROM siralama AS r
JOIN kateqoriyalar AS k ON k.kateqoriya_id = r.kateqoriya_id
WHERE r.yer = 1
ORDER BY k.kateqoriya_id, r.mehsul_id;

-- 6.3-cü tapşırıq
-- Müştərinin ümumi xərcinə görə seqment. Sifarişsiz müştərinin xərci 0-dır.
WITH sifaris_meblegi AS (
    SELECT s.sifaris_id, s.musteri_id, SUM(d.qiymet * d.miqdar) AS mebleg
    FROM sifarisler AS s
    JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
    WHERE s.status <> 'Ləğv edildi'
    GROUP BY s.sifaris_id, s.musteri_id
), musteri_xerci AS (
    SELECT m.musteri_id, CONCAT(m.ad, ' ', m.soyad) AS musteri,
           COALESCE(SUM(sm.mebleg), 0) AS xerc
    FROM musteriler AS m
    LEFT JOIN sifaris_meblegi AS sm ON sm.musteri_id = m.musteri_id
    GROUP BY m.musteri_id, m.ad, m.soyad
)
SELECT musteri_id, musteri, xerc,
       CASE WHEN xerc > 2000 THEN 'VIP'
            WHEN xerc >= 500 THEN 'Adi' ELSE 'Yeni' END AS seqment
FROM musteri_xerci
ORDER BY musteri_id;

-- 6.4-cü tapşırıq
-- İlk və son sifariş tarixi. Sifarişsiz müştəridə tarixlər NULL-dır.
WITH tarixler AS (
    SELECT m.musteri_id, CONCAT(m.ad, ' ', m.soyad) AS musteri,
           MIN(s.tarix) AS ilk_tarix, MAX(s.tarix) AS son_tarix
    FROM musteriler AS m
    LEFT JOIN sifarisler AS s ON s.musteri_id = m.musteri_id
    GROUP BY m.musteri_id, m.ad, m.soyad
)
SELECT musteri_id, musteri, ilk_tarix, son_tarix,
       son_tarix - ilk_tarix AS gun_ferqi
FROM tarixler
ORDER BY musteri_id;

-- 6.5-ci tapşırıq (bonus)
-- Kateqoriya ağacı üçün özünə istinad edən xarici açar.
ALTER TABLE kateqoriyalar ADD COLUMN ust_kateqoriya_id INTEGER;
ALTER TABLE kateqoriyalar ADD CONSTRAINT fk_kateqoriya_ust
    FOREIGN KEY (ust_kateqoriya_id) REFERENCES kateqoriyalar (kateqoriya_id)
    ON DELETE RESTRICT;
ALTER TABLE kateqoriyalar ADD CONSTRAINT chk_kateqoriya_ozu
    CHECK (ust_kateqoriya_id <> kateqoriya_id);

-- Bonus üçün yeni alt kateqoriyalar; mövcud məhsulların kateqoriyası dəyişmir.
INSERT INTO kateqoriyalar (ad, ust_kateqoriya_id)
SELECT 'Kompüterlər', kateqoriya_id FROM kateqoriyalar WHERE ad = 'Elektronika';
INSERT INTO kateqoriyalar (ad, ust_kateqoriya_id)
SELECT 'Noutbuklar', kateqoriya_id FROM kateqoriyalar WHERE ad = 'Kompüterlər';

-- Ağacın səviyyələri; yol eyni ID-ni təkrar izləməyə imkan vermir.
WITH RECURSIVE agac AS (
    SELECT kateqoriya_id, ad, ust_kateqoriya_id, 0 AS seviyye,
           ARRAY[kateqoriya_id] AS yol
    FROM kateqoriyalar WHERE ust_kateqoriya_id IS NULL
    UNION ALL
    SELECT k.kateqoriya_id, k.ad, k.ust_kateqoriya_id, a.seviyye + 1,
           a.yol || k.kateqoriya_id
    FROM kateqoriyalar AS k
    JOIN agac AS a ON k.ust_kateqoriya_id = a.kateqoriya_id
    WHERE NOT k.kateqoriya_id = ANY(a.yol)
)
SELECT kateqoriya_id, ad, ust_kateqoriya_id, seviyye FROM agac
ORDER BY yol;
