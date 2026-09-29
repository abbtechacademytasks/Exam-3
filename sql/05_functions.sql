-- 7.1-ci tapşırıq
-- Adın böyük hərfləri, tam ad və email domeni.
SELECT musteri_id, UPPER(ad) AS boyuk_ad, CONCAT(ad, ' ', soyad) AS tam_ad,
       SUBSTRING(email FROM POSITION('@' IN email) + 1) AS domen
FROM musteriler ORDER BY musteri_id;

-- 7.2-ci tapşırıq
-- Sifarişdən bu günə qədər keçən günlərin sayı.
SELECT sifaris_id, tarix, CURRENT_DATE - tarix AS kecen_gun
FROM sifarisler ORDER BY sifaris_id;

-- 7.3-cü tapşırıq
-- İl və ay üzrə bütün sifarişlərin sayı.
SELECT EXTRACT(YEAR FROM tarix)::INTEGER AS il,
       EXTRACT(MONTH FROM tarix)::INTEGER AS ay, COUNT(*) AS sifaris_sayi
FROM sifarisler
GROUP BY EXTRACT(YEAR FROM tarix), EXTRACT(MONTH FROM tarix)
ORDER BY il, ay;

-- 7.4-cü tapşırıq
-- Əvvəl sifariş məbləğlərini tapırıq, sonra ləğv edilməyənlərin ortasını alırıq.
SELECT ROUND(AVG(sm.mebleg), 2) AS orta_sifaris_meblegi
FROM (
    SELECT s.sifaris_id, SUM(d.qiymet * d.miqdar) AS mebleg
    FROM sifarisler AS s
    JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
    WHERE s.status <> 'Ləğv edildi'
    GROUP BY s.sifaris_id
) AS sm;

-- 7.5-ci tapşırıq
-- Telefon NULL olduqda Qeyd olunmayıb göstərilir.
SELECT musteri_id, CONCAT(ad, ' ', soyad) AS musteri,
       COALESCE(telefon, 'Qeyd olunmayıb') AS telefon
FROM musteriler ORDER BY musteri_id;

-- 7.6-cı tapşırıq
-- Müştərinin ləğv edilməyən sifarişlərinin ümumi xərcini qaytarır.
-- Sifariş yoxdursa 0; olmayan ID üçün də 0 qaytarılması qəbul edilib.
CREATE FUNCTION musteri_umumi_xerci(p_musteri_id INTEGER)
RETURNS NUMERIC
LANGUAGE SQL
STABLE
AS $$
    SELECT COALESCE(SUM(d.qiymet * d.miqdar), 0)
    FROM sifarisler AS s
    JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
    WHERE s.musteri_id = p_musteri_id AND s.status <> 'Ləğv edildi';
$$;

-- Funksiyanı bütün müştərilər üçün çağırırıq.
SELECT musteri_id, CONCAT(ad, ' ', soyad) AS musteri,
       musteri_umumi_xerci(musteri_id) AS umumi_xerc
FROM musteriler ORDER BY musteri_id;
