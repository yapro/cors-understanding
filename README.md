# cors-understanding

Понимая CORS - см. тесты

Суть проекта в исследовании поведения браузера согласно респонса, а именно атрибутов http-заголовка Set-Cookie, например:
```sql
Set-Cookie: testname=63ef085e4d9f0b20b9f099e1d0dbf123; path=/; domain=back.local; secure; HttpOnly; SameSite=none
```

Итак, имеем 2 сайта: front.local и back.local, а далее: 
* сайт front.local всегда посылает запрос на авторизацию (XHR из браузера - с помощью Ajax)
* сайт back.local всегда отвечает успешной авторизацией (но с разными флагами http-заголовка Set-Cookie)

1. При такой куке на оба сайта не установлена кука:
```sql
Set-Cookie: test1=t1;
```
2. При такой куке на оба сайта не установлена кука:
```sql
Set-Cookie: test2=t2; path=/; 
```
3. При такой куке на оба сайта не установлена кука:
```sql
Set-Cookie: test3=t3; path=/; domain=back.local;
```
4. При такой куке на оба сайта не установлена кука:
```sql
Set-Cookie: test4=t4; path=/; domain=back.local; secure;
```

### Test

Добавьте в файл hosts два адреса:
```
127.0.0.1   front.local back.local
```
Делаем сборку контейнера:
```sh
docker build -t yapro/cors-understanding:latest -f ./Dockerfile ./
```
Запускаем контейнер:
```sh
docker run -it --rm --net=host -v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf -v $(pwd):/app -w /app yapro/cors-understanding:latest
```
Открываем в браузере оба адреса и соглашаемся использовать самоподписные сертификаты:
- front: https://front.local:8901/
- back:  https://back.local:8902/
