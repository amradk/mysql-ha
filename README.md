## Реализация MySQL HA с помощью orcestrator + consul + ProxySQL

Компоненты:
* github/orchestrator
* consul
* consul-template
* proxysql

orchestrator - специальное ПО, выполняет отслеживание состояния  MySQL кластера
и в случае обнаружения проблем с мастер-сервером (недоступность) выполняет выбор и
назначение (promotion) нового мастера. 

consul - обнаружение сервисов и хранилище ключ-значение, используется для хранения 
и получения информаци об актуальном MySQL мастере

ProxySQL -  посредник между MySQL и приложением нужен для предотвращения split-brain т.е.
когда из-за сетевых проблем часть приложений сподключена и пишет в старый MySQL мастер а 
другая часть в новый. Задача ProxySQL в случае обнаружения недоступности мастера отключить
ВСЕХ клиентов от старого мастера на время необходимое orchestrator'у для назначения нового
мастера, а после выполнить подключение ВСЕХ клиентов к новому мастеру

consul-template - использует шаблоны чтобы менять настройки в конфигурационных файлах в 
соответствии со значениями полученными из consul и consul kv, а также выполнять команды в 
случае изменения шаблона. 