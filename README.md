# **Vault Installation Platform**

![](https://cybr.com/wp-content/uploads/2023/05/vault-explained-thumbnail-blog.jpg)

**Vault Installation Platform** – проект, представляющий собой набор решений для автоматизированного развертывания и дальнейшей настройки такого программного обеспечения, как Vault от компании HashiCorp. Достигается вышеупомянутая автоматизация за счет таких инструментов, как Ansible, Terraform и Kubernetes. Покрывает все основные сценарии, среди которых можно отметить установку на одиночный сервер, установку в виде кластера как на базе Raft, так и на базе Consul, с сертификатами или без, с прокси-сервером или без, а также в сочетании с многими другими вариантами. Ниже представлено краткое содержание:

- [Содержание:](#vault-installation-platform)
  - [Мотивация](#мотивация)
  - [Предустановка](#предустановка)
  - [Структура репозитория](#структура-репозитория)
  - [Мануальное развертывание](#мануальное-развертывание-vault)
  - [Автоматизированное развертывание с помощью Ansible](#автоматизированное-развертывание-vault-с-помощью-ansible)
    - [Подготовка](#подготовка)
    - [Поддерживаемые операционные системы](#поддерживаемые-операционные-системы)
    - [manual-single-vault.yaml](#запуск-плейбука-manual-single-vaultyaml)
    - [docker-single-vault.yaml](#запуск-плейбука-docker-single-vaultyaml)
    - [manual-cluster-vault.yaml](#запуск-плейбука-manual-cluster-vaultyaml)
    - [manual-cluster-consul.yaml](#запуск-плейбука-manual-cluster-consulyaml)
    - [manual-single-consul-agent.yaml](#запуск-плейбука-manual-single-consul-agentyaml)
    - [system-unseal-single-vault.yaml](#запуск-плейбука-system-unseal-single-vaultyaml)
    - [system-unseal-cluster-vault.yaml](#запуск-плейбука-system-unseal-cluster-vaultyaml)
    - [system-proxy-nginx.yaml](#запуск-плейбука-system-proxy-nginxyaml)
    - [system-proxy-haproxy.yaml](#запуск-плейбука-system-proxy-haproxyyaml)
  - [Автоматизированное конфигурирование с помощью Terraform](#автоматизированное-конфигурирование-с-помощью-terraform)

## **Мотивация:**

Каких-то явных причин для достижения реальных целей или надобности при решении тех или иных проблем не было. Проект, в первую очередь, несет образовательный характер. Возник интерес понять, как развертывать Vault в том или ином режиме работы и используя для этого тот или иной инструмент автоматизации. Однако это не отменяет того, что предоставленные здесь решения также могут быть использованы в Production-среде.

## **Предустановка:**

Для комфортной работы необходимо установить минимальное количество программных компонентов. В частности, это:

- `Git`, с помощью которого вами будет загружен репозиторий из Github.

- `Docker` (и `Docker Compose`), средствами которых осуществляется мануальное (в представлении этого репозитория) развертывание Vault в системе.

- `Ansible`, если вы собираетесь развертывать Vault в автоматическом режиме на двух или более серверах с разными ОС. Ещё потребуется пользователь с правами sudo на удаленных серверах, из под которого будут запускаться плейбуки.

- `Terraform`, если вы собираетесь конфигурировать непосредственно сам Vault с помощью IaC подхода.

- `K8s` инструментарий для взаимодействия, если вы собираетесь развертывать Vault в кластере Kubernetes.

## **Структура репозитория:**

Ниже представлено краткое описание того, что собой представляет каждый файл или директория в корне репозитория:

- **vault.sh:** Файл представляет собой скрипт и относится к этапу мануального развертывания Vault, только нативно, в качестве сервиса в самой системе. Поддерживает все базовые семейства дистрибутивов.

- **Dockerfile:** Файл для сборки индивидуального образа, который используется для последующего запуска Vault при мануальном развертывании (в роли `docker-single-vault` лежит аналог для запуска с помощью Ansible).

- **vault-docker-compose.yaml:** Файл для непосредственного запуска Vault на базе образа, который был собран с помощью Dockerfile (в роли `docker-single-vault` лежит аналог для запуска с помощью Ansible).

- **ansible:** Директория, предназначенная для развертывания Vault с помощью такого инструмента автоматизации, как Ansible. Содержит в себе различные плейбуки для вызова ролей, сами роли, дополнительные конфигурационные файлы для запуска и т.д.

- **dockerfiles:** Директория с файлами Dockerfiles, на базе которых были собраны образы различных операционных систем (образы хранятся на DockerHub). На данный момент это актуальные версии Debian/Ubuntu, Centos/RedHat и OpenSUSE. В будущем возможно расширение представленного списка. Данные образы используются для тестирования плейбуков Ansible, а сам процесс осуществляется с помощью такого инструмента, как Molecule. По умолчанию все тесты организованы на базе Docker. Представлены здесь исключительно в ознакомительных целях и никак не влияют непосредственно на развертывание самого Vault. Однако при желании вы можете запустить тесты и у себя, чтобы посмотреть на результат работы. Особенно это уместно, если вы решите внести те или иные изменения в работу одной из ролей.

Прочие файлы являются вспомогательными и не представляют особого интереса.

## **Мануальное развертывание Vault:**

...

## **Автоматизированное развертывание Vault с помощью Ansible:**

### Подготовка:

Для начала вводная часть. Директория `ansible/`, как уже было отмечено ранее, содержит в себе набор плейбуков, ролей и переменных, которые используются для вызова различных сценариев, что в конечном итоге приводит к автоматизированному развертыванию Vault. Некоторые из ролей обладают двумя или более вариантами развертывания (и дальше это будет подсвечено), каждый из которых достигается за счет использования той или иной переменной в каждой из ролей. В общем случае структура директории `ansible` такова:

- **Директория inventory:** Содержит в себе структуру всех хостов (в моем случае файл `servers.yaml` больше выступает в роли примера со всеми сценариями) и всех глобальных переменных (в представлении данного проекта), которые используются для одной или нескольких ролей. Inventory – это то место, которое необходимо подготовить перед запуском любой из ролей.

- **Директория playbooks:** Содержит в себе все основные файлы для вызова того или иного сценария. В моём случае каждый из файлов предназначен для вызова какой-то одной основной роли, однако каждая из основных ролей может вызывать одну или несколько вспомогательных.

- **Директория roles:** Содержит в себе весь список ролей, которые отвечают за автоматизированное развертывание Vault в том или ином режиме работы, в зависимости от установленной глобальной переменной.

Все ключевые переменные уже заполнены валидными данными, поэтому каждая роль работает из коробки, однако для задействования дополнительных режимов работы (некоторые роли содержат в себе два и более режима) понадобится изменение ключевых глобальных переменных. Об этом будет подробно рассказано в каждой из ролей. Параметр `-i` во время запуска плейбука можно не указывать, поскольку путь прописан в `ansible.cfg` (при условии что вами будет использован файл `servers.yaml`). Подробнее про Inventory-файл и каждую глобальную переменную можно почитать [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Поддерживаемые операционные системы:

Ниже представлен список операционных систем, на которых были протестированы все роли в рамках данного проекта:

| Семейство | Дистрибутив | Версия | Поддержка |
|---|---|---|---|
| Debian | Debian | 11 | ✅ |
| Debian | Debian | 12 | ✅ |
| Debian | Debian | 13 | ✅ |
| Debian | Ubuntu | 20.04 | ✅ |
| Debian | Ubuntu | 22.04 | ✅ |
| Debian | Ubuntu | 24.04 | ✅ |
| RedHat | CentOS Stream | 8 | ✅ |
| RedHat | CentOS Stream | 9 | ✅ |
| RedHat | Red Hat Enterprise Linux | 8 | ✅ |
| RedHat | Red Hat Enterprise Linux | 9 | ✅ |
| SUSE | openSUSE Leap | 15.6 | ✅ |
| SUSE | openSUSE Leap | 16.0 | ✅ |
| SUSE | SUSE Linux Enterprise Server (SLES) | 15.6 | ✅ |
| SUSE | SUSE Linux Enterprise Server (SLES) | 16.0 | ✅ |

---

### Запуск плейбука `manual-single-vault.yaml`:

**Роль manual-single-vault** – по умолчанию данная роль используется для развертывания Vault в виде бинарного файла с Systemd-юнитом. Такой Vault работает в режиме Standalone с базовым набором параметров в своей конфигурации, поэтому роль предназначена для одиночных серверов, без сценария с кластеризацией. Чтобы запустить базовый вариант воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/manual-single-vault.yaml
```

Опционально роль `manual-single-vault` также поддерживает развертывание Vault для работы с Transit-сервером. Обычно вариант с Transit используется для автоматического распечатывания основного Vault (как Standalone так и Cluster версии), дабы не использовать ручной режим. По умолчанию поддержка Transit отключена, поэтому если вы хотите развернуть Vault в таком режиме работы, то для этого в файле `all.yaml`, что в корне `group_vars` необходимо поменять значения для данного списка переменных. В случае с Transit выглядеть это будет следующим образом:

```yaml
global_vault_transit_backend_enable: true
global_vault_transit_backend_unseal_host: "vault-transit.example.com"
global_vault_transit_backend_host_port: 8200
global_vault_transit_backend_token: "hvs.xxxxxxxxxxxxxxx"
global_vault_transit_backend_key_name: "autounseal"
global_vault_transit_backend_mount_path: "transit-backend-01/"
global_vault_transit_backend_disable_renewal: false
global_vault_transit_backend_tls_skip_verify: true
```

Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/manual-single-vault.yaml
```

При этом все ключевые переменные также можно передать через параметр `-e`:

```
ansible-playbook -i <inventory> -l <group> -u <user> -e global_vault_transit_backend_enable=true -e ... --private-key=<ssh-key> playbooks/manual-single-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `docker-single-vault.yaml`:

**Роль docker-single-vault** – по умолчанию данная роль используется для развертывания Vault в виде Docker-контейнера с использованием Docker Compose. Такой Vault работает в режиме Standalone с базовым набором параметров в своей конфигурации, поэтому роль предназначена для одиночных серверов, без сценария с кластеризацией. Docker устанавливается на целевой сервер автоматически через зависимость роли, если он ещё не присутствует в системе. Чтобы запустить базовый вариант воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/docker-single-vault.yaml
```

Опционально роль `docker-single-vault` также поддерживает развертывание Vault для работы с Transit-сервером. Обычно вариант с Transit используется для автоматического распечатывания основного Vault (как Standalone так и Cluster версии), дабы не использовать ручной режим распечатывания. По умолчанию поддержка Transit отключена, поэтому если вы хотите развернуть Vault в таком режиме работы, то для этого в файле `all.yaml`, что в корне `group_vars` необходимо поменять значения для данного списка переменных. В случае с Transit выглядеть это будет следующим образом:

```yaml
global_vault_transit_backend_enable: true
global_vault_transit_backend_unseal_host: "vault-transit.example.com"
global_vault_transit_backend_host_port: 8200
global_vault_transit_backend_token: "hvs.xxxxxxxxxxxxxxx"
global_vault_transit_backend_key_name: "autounseal"
global_vault_transit_backend_mount_path: "transit-backend-01/"
global_vault_transit_backend_disable_renewal: false
global_vault_transit_backend_tls_skip_verify: true
```

Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/docker-single-vault.yaml
```

При этом все ключевые переменные также можно передать через параметр `-e`:

```
ansible-playbook -i <inventory> -l <group> -u <user> -e global_vault_transit_backend_enable=true -e ... --private-key=<ssh-key> playbooks/docker-single-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `manual-cluster-vault.yaml`:

**Роль manual-cluster-vault** – по умолчанию данная роль используется для развертывания Vault в режиме кластера посредством бинарного файла с Systemd-юнитом. Роль поддерживает два взаимоисключающих варианта Storage Backend – **Raft** (встроенный по умолчанию) и **Consul** (внешний), а также ряд опциональных режимов: TLS (HTTP (по умолчанию) и HTTPS с автоматической генерацией самоподписных сертификатов через роль `system-internal-certificates`) для API и межнодовой коммуникации, TLS для соединения с Consul, и Transit Auto-Unseal. Переменные для данной роли задаются в файле `all.yaml`, что в директории `group_vars/vault_cluster/` (параметры кластера и TLS) и в корневом `group_vars/all.yaml` для указания базовых параметров. Чтобы запустить роль с параметрами по умолчанию воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> playbooks/manual-cluster-vault.yaml
```

Плейбук по умолчанию работает с группой `vault_cluster` из инвентори. То бишь, нужно будет добавить все свои хосты в группу хостов с именем `vault_cluster`, что в файле `servers.yaml` (в данном случае это мой inventory-файл). При этом файл `group_vars/vault_cluster/all.yaml` загружается автоматически – именно там задаются почти все переменные для данной роли. Переменная `global_vault_cluster_inventory_group` (по умолчанию `"vault_cluster"`) дополнительно используется внутри шаблонов конфигурации Vault для динамического формирования блока `retry_join` при использовании **Raft**: роль итерирует по хостам указанной группы и прописывает их адреса в конфигурацию каждого узла. Если вы хотите запустить роль против нестандартной группы (например, имя группы `ubuntu`), необходимо явно передать и файл переменных, и название группы. Сделать это можно с помощью следующей команды:

```
ansible-playbook -i <inventory> -l ubuntu -u <user> --private-key=<ssh-key> \
  -e @inventory/group_vars/vault_cluster/all.yaml \
  -e global_vault_cluster_inventory_group=ubuntu \
  playbooks/manual-cluster-vault.yaml
```

- `-l ubuntu`: Ограничивает выполнение хостами группы `ubuntu`.

- `-e @inventory/group_vars/vault_cluster/all.yaml`: Явно подгружает переменные роли, так как они не будут загружены автоматически для нестандартной группы.

- `-e global_vault_cluster_inventory_group=ubuntu`: Указывает роли, по каким хостам строить `retry_join` в конфигурации **Raft**.

Ниже представлены все ключевые переменные в рамках данной роли и то, за какой режим работы каждая из них отвечает:

```yaml
global_vault_cluster_enable_raft: true           # Storage backend на базе встроенного Raft
global_vault_cluster_enable_consul: false        # Storage backend на базе внешнего Consul
global_vault_cluster_enable_https: false         # TLS для Vault API и межнодовой коммуникации
global_vault_cluster_enable_consul_https: false  # TLS для соединения Vault → Consul (только при Consul backend)
global_vault_cluster_enable_transit: false       # Transit Auto-Unseal
```

Роль поддерживает **12 режимов работы**, которые определяются комбинацией переменных:

**Storage backend: Raft**

```yaml
# Режим 1: Raft + HTTP (по умолчанию)
global_vault_cluster_enable_raft: true
global_vault_cluster_enable_https: false
global_vault_cluster_enable_transit: false

# Режим 2: Raft + HTTP + Transit Auto-Unseal
global_vault_cluster_enable_raft: true
global_vault_cluster_enable_https: false
global_vault_cluster_enable_transit: true

# Режим 3: Raft + HTTPS (самоподписные сертификаты генерируются автоматически)
global_vault_cluster_enable_raft: true
global_vault_cluster_enable_https: true
global_vault_cluster_enable_transit: false

# Режим 4: Raft + HTTPS + Transit Auto-Unseal
global_vault_cluster_enable_raft: true
global_vault_cluster_enable_https: true
global_vault_cluster_enable_transit: true
```

**Storage backend: Consul**

```yaml
# Режим 5: Consul HTTP + Vault HTTP
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: false
global_vault_cluster_enable_https: false
global_vault_cluster_enable_transit: false

# Режим 6: Consul HTTP + Vault HTTP + Transit Auto-Unseal
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: false
global_vault_cluster_enable_https: false
global_vault_cluster_enable_transit: true

# Режим 7: Consul HTTPS + Vault HTTP
# Vault → Consul соединение по TLS. Требует предварительно развёрнутого Consul кластера с TLS.
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: true
global_vault_cluster_enable_https: false
global_vault_cluster_enable_transit: false

# Режим 8: Consul HTTPS + Vault HTTP + Transit Auto-Unseal
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: true
global_vault_cluster_enable_https: false
global_vault_cluster_enable_transit: true

# Режим 9: Consul HTTP + Vault HTTPS
# Самоподписные сертификаты для Vault API и межнодовой коммуникации, Consul без TLS.
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: false
global_vault_cluster_enable_https: true
global_vault_cluster_enable_transit: false

# Режим 10: Consul HTTP + Vault HTTPS + Transit Auto-Unseal
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: false
global_vault_cluster_enable_https: true
global_vault_cluster_enable_transit: true

# Режим 11: Consul HTTPS + Vault HTTPS
# TLS везде: Vault API, межнодовая коммуникация и соединение Vault → Consul.
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: true
global_vault_cluster_enable_https: true
global_vault_cluster_enable_transit: false

# Режим 12: Consul HTTPS + Vault HTTPS + Transit Auto-Unseal
global_vault_cluster_enable_consul: true
global_vault_cluster_enable_consul_https: true
global_vault_cluster_enable_https: true
global_vault_cluster_enable_transit: true
```

Команда для запуска остаётся одинаковой для всех режимов работы в случае, если вы используете в качестве группы имя `vault_cluster` и ваши узлы добавлены в эту группу:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> playbooks/manual-cluster-vault.yaml
```

При этом все ключевые переменные также могут быть переданы через параметр `-e`:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> -e global_vault_cluster_enable_raft=true -e global_vault_cluster_enable_https=true -e ... --private-key=<ssh-key> playbooks/manual-cluster-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `manual-cluster-consul.yaml`:

**Роль manual-cluster-consul** – данная роль используется для развертывания Consul в режиме кластера посредством бинарного файла с Systemd-юнитом. Роль поддерживает два режима работы: HTTP (по умолчанию) и HTTPS с автоматической генерацией самоподписных сертификатов через роль `system-internal-certificates`. Переменные роли задаются в двух местах: в файле `all.yaml` директории `group_vars/consul_cluster/` (параметры кластера и TLS) и в корневом файле `all.yaml`, расположённом в `group_vars/` для указания базовых параметров. Чтобы запустить роль с параметрами по умолчанию воспользуйтесь следующей командой, находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l consul_cluster -u <user> --private-key=<ssh-key> playbooks/manual-cluster-consul.yaml
```

Плейбук по умолчанию работает с группой `consul_cluster` из инвентори – нужно добавить хосты в группу `consul_cluster` в файле `servers.yaml`. Файл `group_vars/consul_cluster/all.yaml` загружается автоматически. Переменная `global_consul_cluster_inventory_group` (по умолчанию `"consul_cluster"`) используется внутри шаблона конфигурации для динамического формирования блока `retry_join` и значения `bootstrap_expect`: роль итерирует по хостам указанной группы, прописывает их IP-адреса в `retry_join` каждой ноды и автоматически выставляет `bootstrap_expect` равным числу хостов в группе. Если кластер Consul разворачивается на тех же нодах, что и Vault, можно запустить плейбук против группы `vault_cluster`, явно передав файл переменных и имя группы:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> \
  -e @inventory/group_vars/consul_cluster/all.yaml \
  -e global_consul_cluster_inventory_group=vault_cluster \
  playbooks/manual-cluster-consul.yaml
```

- `-l vault_cluster`: Ограничивает выполнение хостами группы `vault_cluster`.

- `-e @inventory/group_vars/consul_cluster/all.yaml`: Явно подгружает переменные роли, так как они не будут загружены автоматически для нестандартной группы.

- `-e global_consul_cluster_inventory_group=vault_cluster`: Указывает роли по каким хостам строить `retry_join` и `bootstrap_expect` в конфигурации кластера.

Ниже представлены все ключевые переменные в рамках данной роли и то, за какой режим работы каждая из них отвечает:

```yaml
global_consul_cluster_enable_https: false               # TLS для Consul API и межнодовой коммуникации
global_consul_cluster_enable_tls_incoming: true         # Проверка входящих TLS-соединений (только при enable_https)
global_consul_cluster_enable_tls_outgoing: true         # Проверка исходящих TLS-соединений (только при enable_https)
global_consul_cluster_enable_tls_server_hostname: true  # Проверка имени сервера в TLS (только при enable_https)
```

Роль поддерживает **2 режима работы**, которые определяются переменной `global_consul_cluster_enable_https`:

```yaml
# Режим 1: HTTP (по умолчанию)
global_consul_cluster_enable_https: false

# Режим 2: HTTPS (самоподписные сертификаты генерируются автоматически)
# CA создаётся на первом узле группы и хранится в /opt/consul/tls/ca/
# Сертификаты для каждой ноды выпускаются и распределяются автоматически
global_consul_cluster_enable_https: true
```

Команда для запуска остаётся одинаковой для всех режимов работы в случае, если вы используете в качестве группы имя `consul_cluster` и ваши узлы добавлены в эту группу:

```
ansible-playbook -i <inventory> -l consul_cluster -u <user> --private-key=<ssh-key> playbooks/manual-cluster-consul.yaml
```

При этом все ключевые переменные также могут быть переданы через параметр `-e`:

```
ansible-playbook -i <inventory> -l consul_cluster -u <user> -e global_consul_cluster_enable_https=true -e ... --private-key=<ssh-key> playbooks/manual-cluster-consul.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `manual-single-consul-agent.yaml`:

**Роль manual-single-consul-agent** – данная роль используется для развертывания Consul в режиме клиентского агента (Client Mode) на узлах, где нет сервера Consul. Роль нужна тогда, когда кластер Vault развернут на отдельных от кластера Consul узлах. Тогда Vault подключается к локальному агенту Consul на `127.0.0.1`, а агент пересылает трафик серверам кластера. Если Vault и Consul находятся на одних узлах, данный плейбук запускать не нужно. Переменные роли задаются как в файле `all.yaml` директории `group_vars/consul_agent/`, так и в корневом `group_vars/all.yaml` для указания базовых параметров. Плейбук работает с группой `consul_agent` из инвентори. В отличие от роли `manual-cluster-consul`, список адресов Consul-серверов для подключения задаётся вручную через переменную `global_consul_manual_agent_retry_join`, поскольку автоматической итерации по группе нет:

```yaml
global_consul_manual_agent_retry_join:
  - "10.0.0.1"
  - "10.0.0.2"
  - "10.0.0.3"
```

Переменная `global_consul_cluster_inventory_group` (по умолчанию `"consul_cluster"`) используется ролью только при включённом HTTPS: роль автоматически находит узел, относящийся к кластеру Consul, с которого забирает CA-сертификат и приватный ключ, подписывает ими новый сертификат для агента, после чего приватный ключ CA с узла агента удаляется. Значение переменной должно совпадать с фактическим именем группы кластера Consul в инвентори, которое указывается в переменной `global_consul_cluster_inventory_group` роли `manual-cluster-consul`. Если вы используете нестандартное имя группы (не `consul_cluster`), то в таком случае необходимо передать имя явно через `-e global_consul_cluster_inventory_group=<имя_группы>`. При HTTPS роль ходит на узлы кластера Consul через `delegate_to` и если у таких узлов SSH-пользователь отличается по имени того, что вы использовали для развертывания агента Consul, его необходимо прописать через `ansible_user` в инвентори на уровне группы. В противном случае Ansible попытается подключиться с именем пользователя текущего плея и получит `Permission denied`:

```yaml
consul_cluster:
  vars:
    ansible_user: admin
  hosts:
    consul_cluster1:
      ansible_host: 10.0.0.1
    consul_cluster2:
      ansible_host: 10.0.0.2
    consul_cluster3:
      ansible_host: 10.0.0.3
```

Ниже представлены все ключевые переменные в рамках данной роли:

```yaml
global_consul_manual_agent_data_center: "dc1"                # Датацентр (должен совпадать с Consul-кластером)
global_consul_manual_agent_retry_join: [...]                 # Список IP-адресов Consul-серверов для подключения
global_consul_manual_agent_enable_https: false               # TLS для соединения агента с Consul-кластером
global_consul_manual_agent_enable_tls_incoming: true         # Проверка входящих TLS-соединений (только при enable_https)
global_consul_manual_agent_enable_tls_outgoing: true         # Проверка исходящих TLS-соединений (только при enable_https)
global_consul_manual_agent_enable_tls_server_hostname: true  # Проверка имени сервера в TLS (только при enable_https)
```

Чтобы запустить роль с параметрами по умолчанию воспользуйтесь следующей командой, находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l consul_agent -u <user> --private-key=<ssh-key> playbooks/manual-single-consul-agent.yaml
```

Роль поддерживает **2 режима работы**, которые определяются переменной `global_consul_manual_agent_enable_https`:

```yaml
# Режим 1: HTTP (по умолчанию)
global_consul_manual_agent_enable_https: false

# Режим 2: HTTPS
# Требует предварительно развёрнутого Consul-кластера с global_consul_cluster_enable_https: true.
global_consul_manual_agent_enable_https: true
```

Если узлы кластера Vault развёрнуты на отдельных от кластера Consul узлах (группа `vault_cluster`), агент Consul необходимо запустить именно на узлах Vault. Поскольку узлы `vault_cluster` не входят в группу `consul_agent`, переменные из `inventory/group_vars/consul_agent/all.yaml` не загружаются автоматически, так что файл необходимо передать явно через `-e @`. Перед запуском убедитесь, что переменная `global_consul_manual_agent_retry_join` содержит актуальные IP-адреса узлов кластера Consul. Команда для запуска роли в режиме работы по умолчанию (он же HTTP-режим):

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> \
  -e @inventory/group_vars/consul_agent/all.yaml \
  playbooks/manual-single-consul-agent.yaml
```

Команда для запуска роли в режиме работы по HTTPS (кластер Consul должен быть развёрнут с использованием переменной `global_consul_cluster_enable_https:` и значением `true` для этой переменной):

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> \
  -e @inventory/group_vars/consul_agent/all.yaml \
  -e global_consul_manual_agent_enable_https=true \
  playbooks/manual-single-consul-agent.yaml
```

После того как агент Consul был запущен на узлах Vault, разворачивается сам кластер Vault с Consul в качестве Backend. Затем Vault автоматически подключается к локальному агенту на `127.0.0.1:8500` (HTTP) или `127.0.0.1:8443` (HTTPS). Если запустить установку кластера Vault до фактической установки агента Consul, такой плейбук упадет на этапе проверки доступности Vault, хотя при этом сам Vault может быть корректно установлен и настроен:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> playbooks/manual-cluster-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `system-unseal-single-vault.yaml`:

**Роль system-unseal-single-vault** – данная роль предназначена исключительно для одиночных серверов и выполняет два взаимосвязанных сценария: первоначальную инициализацию Vault и его последующее распечатывание. Роль самостоятельно определяет текущее состояние Vault через Health API и в зависимости от него выбирает нужный путь: инициализирует (если Vault ещё не был инициализирован), распечатывает (если Vault запечатан после перезагрузки), либо завершает работу без каких-либо действий (если Vault уже инициализирован и распечатан). Полученные в ходе инициализации ключи и корневой токен сохраняются на исполняемой системе в директорию `vault_keys/`, которая в свою очередь появляется там, где изначально был запущен плейбук. Чтобы запустить роль воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-unseal-single-vault.yaml
```

Для корректной работы роли необходимо задать значения для списка переменных в файле `all.yaml`, что в корне `group_vars`, однако плейбук будет успешно завершен даже со значениями по умолчанию:

```yaml
global_vault_unseal_secret_shares: 5
global_vault_unseal_secret_threshold: 3
global_vault_unseal_tls_skip_verify: true
global_vault_unseal_tls_disable: true
```

Роль обрабатывает следующие сценарии в зависимости от статуса Vault:

- **Статус 501 (не инициализирован)**: Vault инициализируется, полученные ключи и корневой токен сохраняются в `vault_keys.json` на исполняемой системе, после чего Vault немедленно распечатывается.

- **Статус 503 (запечатан)**: Ключи считываются из ранее сохранённого `vault_keys.json` и используются для повторного распечатывания Vault.

- **Статус 200 (активен)**: Роль завершает работу без каких-либо действий.

Опционально роль `system-unseal-single-vault` поддерживает режим Transit Auto-Unseal. В таком случае вместо Shamir-ключей генерируются Recovery Keys, а распечатывание происходит автоматически через Transit-сервер, без ручного ввода ключей. Для включения данного режима достаточно установить переменную `global_vault_transit_backend_enable: true` в том же файле `all.yaml`, что в `group_vars`. Работает только по отношению к тем одиночным серверам, которые изначально были развернуты для работы в режиме Transit. Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-unseal-single-vault.yaml
```

При этом все ключевые переменные также могут быть переданы через параметр `-e`:

```
ansible-playbook -i <inventory> -l <group> -u <user> -e global_vault_unseal_secret_shares=5 -e global_vault_unseal_secret_threshold=3 -e ... --private-key=<ssh-key> playbooks/system-unseal-single-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `system-unseal-cluster-vault.yaml`:

**Роль system-unseal-cluster-vault** – данная роль применима исключительно в тех случаях, когда Vault был развернут в режиме кластера. Она выполняет инициализацию и распечатывание всех узлов кластера в правильном порядке. Первый хост из группы инвентори автоматически становится **Master Node** – именно он инициализируется первым и именно от него берутся ключи для распечатывания остальных узлов. Прочие хосты в группе становятся **Standby Nodes** и распечатываются с использованием ключей, сохранённых в ходе инициализации **Master Node**. Роль самостоятельно определяет текущее состояние каждой ноды через Health API и выбирает нужный путь: инициализирует и распечатывает (если кластер ещё не был инициализирован), повторно распечатывает (если ноды запечатаны после перезагрузки), либо завершает работу без каких-либо действий (если все ноды уже активны). Ключи и корневой токен сохраняются на исполняемой системе в директорию `vault_keys/`, которая появляется там, где был запущен плейбук. Чтобы запустить роль воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> playbooks/system-unseal-cluster-vault.yaml
```

Для корректной работы роли необходимо задать значения для списка переменных в файле `all.yaml`, что в корне `group_vars`. При этом, если использовать значения по умолчанию для распечатывания кластера Vault, то плейбук всегда будет падать в той ситуации, когда во время развертывания кластера Vault была задействована переменная `global_vault_cluster_enable_https` со значением `true`, из `group_vars/vault_cluster/all.yaml`. Это связано с тем, что роль будет обращаться к HTTPS-серверу по HTTP, в результате чего будет получена ошибка `400 Bad Request`. Поэтому значение переменной `global_vault_unseal_tls_disable` необходимо изменить на `false`. При этом `global_vault_unseal_tls_skip_verify` можно не менять, поскольку мы используем самоподписные сертификаты:

```yaml
global_vault_unseal_secret_shares: 5
global_vault_unseal_secret_threshold: 3
global_vault_unseal_tls_skip_verify: true
global_vault_unseal_tls_disable: false
```

Роль обрабатывает следующие сценарии в зависимости от статуса каждого узла:

- **Статус 501 (не инициализирован)**: **Master Node** инициализируется, полученные ключи и корневой токен сохраняются в `vault_keys.json` на исполняемой системе, после чего **Master Node** распечатывается, а **Standby Nodes** распечатываются с использованием тех же ключей.

- **Статус 503 (запечатан)**: Ключи считываются из ранее сохранённого `vault_keys.json` и используются для повторного распечатывания **Master Node**, после чего **Standby Nodes** распечатываются аналогичным образом.

- **Статус 200 / 429 (активен / standby)**: Роль завершает работу без каких-либо действий.

Опционально роль поддерживает режим Transit Auto-Unseal. В таком случае, при инициализации **Master Node**, вместо Unseal Keys генерируются Recovery Keys, которые сохраняются в `vault_recovery_keys.json`. Сам **Master Node** распечатывается автоматически через Transit-сервер, а **Standby Nodes** ожидают автоматического распечатывания без какого-либо ручного вмешательства. Для включения данного режима достаточно установить переменную `global_vault_transit_backend_enable` в `true` во всё том же файле `all.yaml`, что в `group_vars`. Работает только по отношению к тем кластерам, которые изначально были развернуты с поддержкой Transit. Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> playbooks/system-unseal-cluster-vault.yaml
```

При этом все ключевые переменные также могут быть переданы через параметр `-e`:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> -e global_vault_unseal_secret_shares=5 -e global_vault_unseal_secret_threshold=3 -e ... --private-key=<ssh-key> playbooks/system-unseal-cluster-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `system-proxy-nginx.yaml`:

**Роль system-proxy-nginx** – по умолчанию данная роль устанавливает и настраивает Nginx в качестве Reverse Proxy для работы с одиночным Vault-сервером по схеме HTTP → HTTP. Для данной роли переменная `global_nginx_host_domain` задаётся непосредственно в inventory-файле на уровне конкретного хоста – именно так роль получает уникальный домен для каждого сервера. Значение в `group_vars/all.yaml` является заглушкой и используется только во время тестов Molecule. Остальные переменные для данной роли задаются в файле `all.yaml`, что в корне `group_vars`:

```yaml
# inventory/servers.yaml
    ubuntu:
      children:
        ubuntu24.04:
          hosts:
            ubuntu24.04-instance1:
              ansible_host: 1.2.3.4
              global_nginx_host_domain: vault.example.com

# inventory/group_vars/all.yaml
global_nginx_set_http_scheme: "http"
```

Роль поддерживает **4 режима работы**, которые определяются комбинацией переменных:

```yaml
# Режим 1: Single Vault + HTTP (по умолчанию)
global_nginx_set_cluster_vault_config: false
global_nginx_set_http_scheme: "http"
global_nginx_enable_certbot_certificates: false

# Режим 2: Single Vault + HTTPS (сертификат через Certbot)
global_nginx_set_cluster_vault_config: false
global_nginx_enable_certbot_certificates: true
global_nginx_set_http_scheme: "https"

# Режим 3: Cluster Vault + HTTP
global_nginx_set_cluster_vault_config: true
global_nginx_set_http_scheme: "http"
global_nginx_enable_certbot_certificates: false

# Режим 4: Cluster Vault + HTTPS (сертификат через Certbot)
global_nginx_set_cluster_vault_config: true
global_nginx_enable_certbot_certificates: true
global_nginx_set_http_scheme: "https"
```

Чтобы запустить базовый вариант воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-proxy-nginx.yaml
```

Опционально роль `system-proxy-nginx` поддерживает автоматическое получение SSL-сертификата через Certbot. В таком случае Nginx сначала поднимается по HTTP для прохождения **ACME-challenge**, после чего получает сертификат и автоматически перестраивает конфигурацию под HTTPS. Для включения данного режима необходимо задать следующие переменные в файле `all.yaml`, что в корне `group_vars` (по умолчанию данный режим работы отключен):

```yaml
global_nginx_enable_certbot_certificates: true
global_nginx_enable_certbot_certificates_email_address: "your@email.com"
global_nginx_set_http_scheme: "https"
```

Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-proxy-nginx.yaml
```

Помимо всего вышесказанного роль `system-proxy-nginx` также поддерживает развертывание Nginx в роли балансировщика нагрузки для кластера Vault. В таком случае вместо проксирования на локальный `127.0.0.1` Nginx формирует `upstream` с алгоритмом `ip_hash` и распределяет входящие запросы по всем узлам кластера, обеспечивая маршрутизацию запросов одного клиента на один и тот же узел. Для включения данного режима необходимо задать следующие переменные в файле `all.yaml`, что в корне `group_vars` (по умолчанию данный режим работы отключен):

```yaml
global_nginx_set_cluster_vault_config: true
global_nginx_set_cluster_vault_addresses:
  - "10.0.0.1"
  - "10.0.0.2"
  - "10.0.0.3"
global_nginx_set_cluster_vault_weight:
  - "10"
  - "5"
  - "3"
```

Через переменную `global_nginx_set_cluster_vault_addresses` задаётся список IP-адресов узлов кластера Vault, а с помощью `global_nginx_set_cluster_vault_weight` указываются соответствующие им веса при балансировке. Количество весов должно совпадать с количеством адресов. Если кластер Vault был развернут с TLS (`global_vault_cluster_enable_https: true`), необходимо дополнительно изменить схему соединения Nginx → Vault:

```yaml
global_nginx_set_proxy_pass_scheme: "https"
```

Режим кластера также совместим с работой Certbot. Можно одновременно задать `global_nginx_set_cluster_vault_config` в `true` и `global_nginx_enable_certbot_certificates` тоже в `true`, что соответствует **режиму 4**. Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-proxy-nginx.yaml
```

При этом все ключевые переменные также могут быть переданы через параметр `-e`:

```
ansible-playbook -i <inventory> -l <group> -u <user> -e global_nginx_host_domain=vault.example.com -e global_nginx_set_http_scheme=https -e ... --private-key=<ssh-key> playbooks/system-proxy-nginx.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `system-proxy-haproxy.yaml`:

**Роль system-proxy-haproxy** – по умолчанию данная роль устанавливает и настраивает HAProxy в качестве Reverse Proxy для работы с одиночным Vault-сервером по схеме HTTP → HTTP. Переменная `global_haproxy_host_domain` задаётся непосредственно в inventory-файле на уровне конкретного хоста – именно так роль получает уникальный домен для каждого сервера. Значение в `group_vars/all.yaml` является заглушкой и используется только во время тестов Molecule. Остальные переменные для данной роли по умолчанию всё также задаются в файле `all.yaml`, что в корне `group_vars`:

```yaml
# inventory/servers.yaml
    ubuntu:
      children:
        ubuntu24.04:
          hosts:
            ubuntu24.04-instance1:
              ansible_host: 1.2.3.4
              global_haproxy_host_domain: vault.example.com

# inventory/group_vars/all.yaml
global_haproxy_set_http_scheme: "http"
```

Роль поддерживает **4 режима работы**, которые определяются комбинацией переменных:

```yaml
# Режим 1: Single Vault + HTTP (по умолчанию)
global_haproxy_set_cluster_vault_config: false
global_haproxy_set_http_scheme: "http"
global_haproxy_enable_certbot_certificates: false

# Режим 2: Single Vault + HTTPS (сертификат через Certbot)
global_haproxy_set_cluster_vault_config: false
global_haproxy_enable_certbot_certificates: true
global_haproxy_set_http_scheme: "https"

# Режим 3: Cluster Vault + HTTP
global_haproxy_set_cluster_vault_config: true
global_haproxy_set_http_scheme: "http"
global_haproxy_enable_certbot_certificates: false

# Режим 4: Cluster Vault + HTTPS (сертификат через Certbot)
global_haproxy_set_cluster_vault_config: true
global_haproxy_enable_certbot_certificates: true
global_haproxy_set_http_scheme: "https"
```

Чтобы запустить базовый вариант воспользуйтесь следующей командой находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-proxy-haproxy.yaml
```

Опционально роль `system-proxy-haproxy` поддерживает автоматическое получение SSL-сертификата через Certbot. В отличие от Nginx, HAProxy использует режим `--standalone`, при котором Certbot самостоятельно поднимает временный HTTP-сервер на 80 порту для прохождения **ACME-challenge** – HAProxy в этот момент ещё не запущен, поэтому конфликта портов не возникает. После получения сертификата роль автоматически объединяет `fullchain.pem` и `privkey.pem` в единый файл, который HAProxy использует для терминации SSL. Для включения данного режима необходимо задать следующие переменные в файле `all.yaml`, что в `group_vars` (по умолчанию данный режим работы отключен):

```yaml
global_haproxy_enable_certbot_certificates: true
global_haproxy_enable_certbot_certificates_email_address: "your@email.com"
global_haproxy_set_http_scheme: "https"
```

Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-proxy-haproxy.yaml
```

Помимо всего вышесказанного роль `system-proxy-haproxy` поддерживает развертывание HAProxy в роли балансировщика нагрузки для кластера Vault. В таком случае вместо проксирования на локальный `127.0.0.1` HAProxy формирует backend с алгоритмом `balance first` и направляет входящие запросы на первый доступный узел кластера, автоматически переключаясь на следующий при его недоступности. Для включения данного режима необходимо задать следующие переменные в файле `all.yaml`, что в корне `group_vars` (по умолчанию данный режим работы отключен):

```yaml
global_haproxy_set_cluster_vault_config: true
global_haproxy_set_cluster_vault_addresses:
  - "10.0.0.1"
  - "10.0.0.2"
  - "10.0.0.3"
```

Переменная `global_haproxy_set_cluster_vault_addresses` задаёт список IP-адресов узлов кластера Vault. Если кластер Vault был развернут с TLS (`global_vault_cluster_enable_https: true`), необходимо дополнительно изменить схему соединения HAProxy → Vault:

```yaml
global_haproxy_set_proxy_pass_scheme: "https"
```

Режим кластера также совместим с работой Certbot. Можно одновременно задать переменную `global_haproxy_set_cluster_vault_config` со значением `true` и `global_haproxy_enable_certbot_certificates` со значением `true`, что соответствует **режиму 4**. Команда для запуска будет точно такой же:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-proxy-haproxy.yaml
```

При этом все ключевые переменные также могут быть переданы через параметр `-e`:

```
ansible-playbook -i <inventory> -l <group> -u <user> -e global_haproxy_host_domain=vault.example.com -e global_haproxy_set_http_scheme=https -e ... --private-key=<ssh-key> playbooks/system-proxy-haproxy.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

## **Автоматизированное конфигурирование с помощью Terraform:**

...

---
