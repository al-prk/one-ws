# One-WS

> Для платформ >=8.3.8 рекомендую использовать образ https://github.com/crsde/one-wsap c Apache 2.4 и без Ruby

Данный образ предназначен для публикации веб-сервисов 1С (SOAP, HTTP REST, веб-клиента).

Контейнер включает в себя
- Бибилиотеки сервера 1C:Предприятия
- Apache 2.2 в качестве веб-сервера с установленнвм расширением 1С:Предприятия
- Скрипт конфигурации дескрипторов

Для публикации веб-сервисов 1С используются файлы-дескрипторы с раширением .vrd, контейнер предполагает их размещение в каталоге, подключенном к образу как /descriptors.

# Сборка

Для сборки требуется поместить в директорию packages deb-пакеты server, common и ws соответствующие вашей версии предприятия, например, [отсюда](https://users.v8.1c.ru/distribution/version_files?nick=Platform83&ver=8.3.3.641).

Собираем образ:
```
docker build -t one-ws ./
```

# Использование

Чтобы запустить контейнер, нужно выполнить что-то вроде этого:
```
docker run -p 8080:80 -v /our_vrd:/descriptors one-ws
```
где /our_vrd - директория в которой лежать дескрипторы публикации.

После чего мы можем выполнить деплоймент нашего веб-сервиса, сохранив его в диалоге Администрирование/Публикация на веб-сервере Конфигуратора.
```
cd /our_vrd
cat > ./demo.vrd
<?xml version="1.0" encoding="UTF-8"?>
<point xmlns="http://v8.1c.ru/8.2/virtual-resource-system"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                base="/devel"
                ib="Srvr=&quot;server1c&quot;;Ref=&quot;devel&quot;;"
                enable="false">
        <ws>
                <point name="TestWS"
                                alias="ws1.1cws"
                                enable="true"/>
        </ws>
</point>
```

В консоли контейнера:
```
Deploying...
Descriptor "devel" from "/descriptors/demo.vrd" successfully deployed
Deploying complete
```

Должно работать:
```
curl http://user:password@localhost:8080/devel/ws/TestWS?wsdl
<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://schemas.xmlsoap.org/wsdl/"
                xmlns:soap12bind="http://schemas.xmlsoap.org/wsdl/soap12/"
                xmlns:soapbind="http://schemas.xmlsoap.org/wsdl/soap/"
                xmlns:tns="trade"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd1="trade"
                name="TestWS"
...
```
