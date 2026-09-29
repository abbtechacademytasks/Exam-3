# Exam 3

PostgreSQL-də onlayn mağaza: normallaşdırma, constraint-lər, JOIN, CTE və funksiyalar.

## Fayllar

- `sql/01_create_tables.sql` - 7 cədvəl və constraint-lər
- `sql/02_insert_data.sql` - məlumatlar və 4 səhv INSERT
- `sql/03_join_queries.sql` - JOIN sorğuları
- `sql/04_cte_queries.sql` - CTE və bonus kateqoriya ağacı
- `sql/05_functions.sql` - SQL funksiyaları
- `docs/pashayev_vaqif_hesabat.pdf` - hesabat, ER diaqramı və ekran görüntüləri
- `docs/er.png` - ER diaqramı
- `screenshots/` - nəticələrin brauzerdə ekran görüntüləri
- `compose.yaml` - PostgreSQL 17
- `Pashayev_Vaqif_CH22.zip` - təhvil üçün SQL faylları, hesabat və ekran görüntüləri

## İşə salmaq

PowerShell:

```powershell
$env:EXAM3_DB_PASSWORD = 'yerli-test-ucun-parol'
docker compose up -d
docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U postgres -d onlayn_magaza -f /sql/01_create_tables.sql
docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U postgres -d onlayn_magaza -f /sql/02_insert_data.sql
docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U postgres -d onlayn_magaza -f /sql/03_join_queries.sql
docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U postgres -d onlayn_magaza -f /sql/04_cte_queries.sql
docker compose exec -T postgres psql -X -v ON_ERROR_STOP=1 -U postgres -d onlayn_magaza -f /sql/05_functions.sql
```

SQL faylları boş bazada 01-05 ardıcıllığı ilə bir dəfə işlədilir. `02` faylındakı səhv INSERT-lər ayrıca yoxlanılır. Təkrar icra üçün yeni boş baza istifadə edin.

## Qəbul edilən qaydalar

İlk beş sifariş `Çatdırıldı` qəbul edilib. Gəlir və xərc hesablarında `Ləğv edildi` çıxılır, gözləyən və göndərilən sifarişlər qalır; bu, alınmış ödəniş deyil, sifariş dövriyyəsidir. 5.1 bütün, 5.5 yalnız çatdırılmış sifarişləri göstərir.

Satış sayı vahidlərin cəmidir. Orta aylıq gəlir satış olan aylar üzrədir. Bərabər liderlərin hamısı qaytarılır. Sifarişsiz müştərinin xərci 0, tarixləri NULL-dır.

Ekran görüntüləri PostgreSQL nəticələrinin yerli HTML baxışındandır, pgAdmin görüntüsü deyil. 7.2 nəticəsi icra tarixindən asılıdır.
