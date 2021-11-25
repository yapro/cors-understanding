# cors-understanding

Понимая CORS - см. тесты

Суть проекта в исследовании поведения браузера согласно респонса, а именно атрибутов http-заголовка Set-Cookie, например:
```sql
Set-Cookie: testname=63ef085e4d9f0b20b9f099e1d0dbf123; path=/; domain=back.local; secure; HttpOnly; SameSite=none
```

Итак, имеем 2 сайта: front.local и back.local, а далее: 
* сайт front.local посылает запрос на страницу https://back.local:8902/page-set-cookies (XHR из браузера)
* сайт back.local всегда отвечает успешно (но с разными флагами http-заголовка Set-Cookie)

При следующих куки-флагах на сайт back.local не будет установлена кука:
```sql
Set-Cookie: test0=t0;
Set-Cookie: test1=t1; path=/;
Set-Cookie: test2=t2; path=/; domain=back.local;
Set-Cookie: test3=t3; path=/; domain=back.local; secure;
Set-Cookie: test4=t4; path=/; domain=back.local; secure; HttpOnly;
Set-Cookie: test7=t7; path=/; domain=back.local; SameSite=none
Set-Cookie: test8=t8; path=/; SameSite=none
Set-Cookie: test9=t9; SameSite=none
```
При следующих куки-флагах на сайт back.local будет установлена кука:
```sql
Set-Cookie: test5=t5; path=/; domain=back.local; secure; HttpOnly; SameSite=none
Set-Cookie: test6=t6; path=/; domain=back.local; secure; SameSite=none
```
Напомню, что наличие атрибута HttpOnly говорит браузеру, что cookie не должна быть доступна через скриптовые языки браузера (например JavaScript).

Еще больше подробностей на странице: https://yapro.ru/article/6506

Интересно - если в браузере просто открыть страницу https://back.local:8902/page-set-cookies то браузер запомнит куки:
```sql
Set-Cookie: test0=t0;
Set-Cookie: test1=t1; path=/;
Set-Cookie: test2=t2; path=/; domain=back.local;
Set-Cookie: test3=t3; path=/; domain=back.local; secure;
Set-Cookie: test4=t4; path=/; domain=back.local; secure; HttpOnly;
Set-Cookie: test5=t5; path=/; domain=back.local; secure; HttpOnly; SameSite=none
Set-Cookie: test6=t6; path=/; domain=back.local; secure; SameSite=none
```
А следующие куки будут проигнорированы (браузер их не запомнит):
```sql
Set-Cookie: test7=t7; path=/; domain=back.local; SameSite=none
Set-Cookie: test8=t8; path=/; SameSite=none
Set-Cookie: test9=t9; SameSite=none
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

### Поддомен

Провел опыт на браузере Chrome, считает ли он запросы на поддомен - запросами CORS, в итоге:

* с https://front.local:8901 на https://sub.front.local:8902/page-set-cookies - это CORS запрос
* с https://front.local:8901 на https://sub.front.local:8901/page-set-cookies - это CORS запрос
* с https://front.local на https://sub.front.local/page-set-cookies - это CORS запрос (используется порт 443)

Таким образом, если нет желания возиться с CORS, следует использовать проксирование запросов по префиксу, например:
```
location ^~ /backend/ {
    proxy_set_header Host yapro.backend;
    proxy_pass http://127.0.0.1:80;
    proxy_redirect default;
}
```
