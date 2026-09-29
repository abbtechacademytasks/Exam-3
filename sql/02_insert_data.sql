-- Köhnə cədvəlin beş sifarişi və əlavə yoxlama məlumatları.
BEGIN;

-- Bakı, Gəncə və Sumqayıt mənbədən götürülüb; Şəki əlavə edilib.
INSERT INTO seherler (ad) VALUES ('Bakı'), ('Gəncə'), ('Sumqayıt'), ('Şəki');

-- İlk üç müştəri mənbədəndir. Muradın sifarişi, Nigarın telefonu yoxdur.
INSERT INTO musteriler (ad, soyad, email, telefon, seher_id) VALUES
    ('Aysel', 'Məmmədova', 'aysel@mail.az', '0501112233', 1),
    ('Tural', 'Həsənov', 'tural@gmail.com', '0552223344', 2),
    ('Leyla', 'Kərimova', 'leyla@mail.ru', '0703334455', 3),
    ('Murad', 'Əliyev', 'murad@example.com', '0504445566', 4),
    ('Nigar', 'İsmayılova', 'nigar@example.com', NULL, 1),
    ('Kamran', 'Rzayev', 'kamran@example.com', '0556667788', 2);

-- Mənbədəki kateqoriyalar.
INSERT INTO kateqoriyalar (ad) VALUES ('Elektronika'), ('Aksesuar');

-- İlk beş məhsul mənbədəndir. Veb-kamera heç satılmayıb.
INSERT INTO mehsullar (ad, kateqoriya_id, qiymet) VALUES
    ('Noutbuk', 1, 1500), ('Siçan', 2, 25), ('Telefon', 1, 900),
    ('Qulaqlıq', 2, 80), ('Planşet', 1, 650),
    ('Klaviatura', 2, 60), ('Monitor', 1, 300), ('Veb-kamera', 2, 120);

-- Mənbədəki iki kuryer.
INSERT INTO kuryerler (ad, soyad) VALUES ('Rəşad', 'Əliyev'), ('Nicat', 'Quliyev');

-- Köhnə cədvəldə status yoxdur: 1-5 sifarişləri çatdırılmış qəbul edilir.
-- Yeni sifarişlərdə bütün tələb olunan statuslar və müxtəlif aylar var.
INSERT INTO sifarisler (musteri_id, kuryer_id, tarix, status) VALUES
    (1, 1, '2026-01-05', 'Çatdırıldı'),
    (2, 2, '2026-01-17', 'Çatdırıldı'),
    (1, 1, '2026-02-03', 'Çatdırıldı'),
    (3, 1, '2026-02-20', 'Çatdırıldı'),
    (2, 2, '2026-03-11', 'Çatdırıldı'),
    (1, 1, '2026-04-10', 'Çatdırıldı'),
    (5, 2, '2026-05-15', 'Göndərildi'),
    (6, 1, '2026-06-20', 'Gözləmədə'),
    (2, 2, '2026-07-05', 'Ləğv edildi'),
    (5, 2, '2026-03-25', 'Çatdırıldı');

-- Siyahıdakı qiymət və miqdarlar eyni mövqedəki məhsula uyğundur.
INSERT INTO sifaris_detallari (sifaris_id, mehsul_id, qiymet, miqdar) VALUES
    (1, 1, 1500, 1), (1, 2, 25, 2),
    (2, 3, 900, 1),
    (3, 4, 80, 1), (3, 2, 25, 1),
    (4, 5, 650, 2),
    (5, 1, 1500, 1), (5, 4, 80, 1),
    (6, 7, 300, 2), (6, 6, 60, 1),
    (7, 7, 300, 2), (8, 6, 60, 1),
    (9, 3, 900, 1), (10, 4, 80, 2);
COMMIT;

-- Qəsdən səhv sorğular: hər birini ayrıca icra edin.
-- Bunlar əsas yükləməni dayandırmamaq üçün şərhə alınıb.
-- ERR-1: chk_mehsul_qiymet - mənfi qiymət.
-- INSERT INTO mehsullar (ad, kateqoriya_id, qiymet) VALUES ('Səhv qiymət', 1, -10);
-- ERR-2: uq_musteri_email - təkrar email.
-- INSERT INTO musteriler (ad, soyad, email, seher_id) VALUES ('Test', 'Email', 'aysel@mail.az', 1);
-- ERR-3: fk_sifaris_musteri - olmayan müştəri.
-- INSERT INTO sifarisler (musteri_id, kuryer_id) VALUES (99999, 1);
-- ERR-4: chk_sifaris_status - icazə verilməyən status.
-- INSERT INTO sifarisler (musteri_id, kuryer_id, status) VALUES (1, 1, 'Yanlış');
