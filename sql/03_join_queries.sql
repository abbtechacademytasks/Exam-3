-- Hesabatlarda ləğv edilmiş sifarişlər gəlirə daxil edilmir.
-- 5.1-ci tapşırıq
-- Bütün sifarişlər və detaldakı qiymətlə hesablanan məbləğ.
SELECT s.sifaris_id, s.tarix, CONCAT(m.ad, ' ', m.soyad) AS musteri,
       sh.ad AS seher, CONCAT(k.ad, ' ', k.soyad) AS kuryer,
       SUM(d.qiymet * d.miqdar) AS umumi_mebleg
FROM sifarisler AS s
INNER JOIN musteriler AS m ON m.musteri_id = s.musteri_id
INNER JOIN seherler AS sh ON sh.seher_id = m.seher_id
INNER JOIN kuryerler AS k ON k.kuryer_id = s.kuryer_id
INNER JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
GROUP BY s.sifaris_id, s.tarix, m.musteri_id, sh.ad, k.kuryer_id
ORDER BY s.sifaris_id;

-- 5.2-ci tapşırıq
-- Heç bir sifarişi olmayan müştərilər.
SELECT m.musteri_id, CONCAT(m.ad, ' ', m.soyad) AS musteri
FROM musteriler AS m
LEFT JOIN sifarisler AS s ON s.musteri_id = m.musteri_id
WHERE s.sifaris_id IS NULL
ORDER BY m.musteri_id;

-- 5.3-cü tapşırıq
-- Ləğv edilməyən sifarişdə heç satılmamış məhsullar.
SELECT p.mehsul_id, p.ad
FROM mehsullar AS p
LEFT JOIN (
    SELECT DISTINCT d.mehsul_id
    FROM sifaris_detallari AS d
    INNER JOIN sifarisler AS s ON s.sifaris_id = d.sifaris_id
    WHERE s.status <> 'Ləğv edildi'
) AS satilan ON satilan.mehsul_id = p.mehsul_id
WHERE satilan.mehsul_id IS NULL
ORDER BY p.mehsul_id;

-- 5.4-cü tapşırıq
-- Say dedikdə satılan vahidlərin cəmi nəzərdə tutulur.
SELECT k.ad AS kateqoriya, COALESCE(SUM(satis.miqdar), 0) AS vahid_sayi,
       COALESCE(SUM(satis.qiymet * satis.miqdar), 0) AS gelir
FROM kateqoriyalar AS k
LEFT JOIN mehsullar AS p ON p.kateqoriya_id = k.kateqoriya_id
LEFT JOIN (
    SELECT d.* FROM sifaris_detallari AS d
    INNER JOIN sifarisler AS s ON s.sifaris_id = d.sifaris_id
    WHERE s.status <> 'Ləğv edildi'
) AS satis ON satis.mehsul_id = p.mehsul_id
GROUP BY k.kateqoriya_id, k.ad
ORDER BY k.kateqoriya_id;

-- 5.5-ci tapşırıq
-- Kuryerin çatdırdığı sifarişlərin sayı və məbləği.
SELECT CONCAT(k.ad, ' ', k.soyad) AS kuryer,
       COUNT(DISTINCT s.sifaris_id) AS sifaris_sayi,
       COALESCE(SUM(d.qiymet * d.miqdar), 0) AS umumi_mebleg
FROM kuryerler AS k
LEFT JOIN sifarisler AS s ON s.kuryer_id = k.kuryer_id AND s.status = 'Çatdırıldı'
LEFT JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
GROUP BY k.kuryer_id, k.ad, k.soyad
ORDER BY sifaris_sayi DESC, k.kuryer_id;

-- 5.6-cı tapşırıq
-- Şəhərlər üzrə müştəri sayı və gəlir. Sifarişsiz müştəri də sayılır.
SELECT sh.ad AS seher, COUNT(DISTINCT m.musteri_id) AS musteri_sayi,
       COALESCE(SUM(d.qiymet * d.miqdar), 0) AS gelir
FROM seherler AS sh
LEFT JOIN musteriler AS m ON m.seher_id = sh.seher_id
LEFT JOIN sifarisler AS s ON s.musteri_id = m.musteri_id AND s.status <> 'Ləğv edildi'
LEFT JOIN sifaris_detallari AS d ON d.sifaris_id = s.sifaris_id
GROUP BY sh.seher_id, sh.ad
ORDER BY sh.seher_id;
