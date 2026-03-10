# **Vault Installation Platform**

![](https://cybr.com/wp-content/uploads/2023/05/vault-explained-thumbnail-blog.jpg)

**Vault Installation Platform** – проект, представляющий собой набор решений для автоматизированного развертывания и дальнейшей настройки такого программного обеспечения, как Vault от компании HashiCorp. Достигается вышеупомянутая автоматизация за счёт таких инструментов, как Ansible, Terraform и Kubernetes. Покрывает все основные сценарии, среди которых можно отметить установку на одиночный сервер, установку в виде кластера как на базе Raft, так и на базе Consul, с сертификатами или без, с прокси-сервером или без, а также в сочетании с многими другими вариантами. Ниже представлено краткое содержание:

- [Содержание:](#vault-installation-platform)
  - [Мотивация](#мотивация)
  - [Предустановка](#предустановка)
  - [Структура репозитория](#структура-репозитория)
  - [Локальное развертывание](#локальное-развертывание-vault)
    - [Развертывание Vault с помощью Bash Script](#развертывание-vault-с-помощью-bash-script)
    - [Развертывание Vault с помощью Docker Compose](#развертывание-vault-с-помощью-docker-compose)
  - [Автоматизированное развертывание с помощью Ansible](#автоматизированное-развертывание-vault-с-помощью-ansible)
    - [Поддерживаемые операционные системы](#поддерживаемые-операционные-системы)
    - [Роль Manual Single Vault](#запуск-плейбука-manual-single-vaultyaml)
    - [Роль Docker Single Vaultl](#запуск-плейбука-docker-single-vaultyaml)
    - [Роль Manual Cluster Vault](#запуск-плейбука-manual-cluster-vaultyaml)
    - [Роль Manual Cluster Consul](#запуск-плейбука-manual-cluster-consulyaml)
    - [Роль Manual Single Consul Agent](#запуск-плейбука-manual-single-consul-agentyaml)
    - [Роль System Unseal Single Vault](#запуск-плейбука-system-unseal-single-vaultyaml)
    - [Роль System Unseal Cluster Vault](#запуск-плейбука-system-unseal-cluster-vaultyaml)
    - [Роль System Proxy Nginx](#запуск-плейбука-system-proxy-nginxyaml)
    - [Роль System Proxy HAProxy](#запуск-плейбука-system-proxy-haproxyyaml)
  - [Автоматизированное конфигурирование с помощью Terraform](#автоматизированное-конфигурирование-vault-с-помощью-terraform)
    - [Структура иерархии и процесс запуска](#структура-иерархии-и-процесс-запуска)
    - [Модуль включения аудита](#вызов-модуля-system_audit)
    - [Модуль политики по умолчанию](#вызов-модуля-vault_default_policy)
    - [Модуль произвольных политик](#вызов-модуля-vault_custom_policy)
    - [Модуль парольной политики](#вызов-модуля-system_password_policy)
    - [Модуль аутентификации AppRole](#вызов-модуля-auth_approle)
    - [Модуль аутентификации JWT](#вызов-модуля-auth_jwt)
    - [Модуль аутентификации Userpass](#вызов-модуля-auth_userpass)
    - [Модуль хранилища секретов KV](#вызов-модуля-secret_engine_kv)
    - [Модуль хранилища секретов Transit Engine](#вызов-модуля-secret_engine_transit)
    - [Модуль Identity Entity](#вызов-модуля-system_identity_entity)
    - [Модуль Identity Group](#вызов-модуля-system_identity_group)
    - [Модуль Identity OIDC](#вызов-модуля-system_identity_oidc)

## **Мотивация**

Каких-то явных причин для достижения реальных целей или надобности при решении тех или иных проблем не было. Проект, в первую очередь, несёт образовательный характер. Возник интерес понять, как развертывать Vault в том или ином режиме работы и используя для этого тот или иной инструмент автоматизации. Однако это не отменяет того, что предоставленные здесь решения также могут быть использованы в Production-среде.

## **Предустановка**

Для комфортной работы необходимо установить минимальное количество программных компонентов. В частности, это:

- `Git`, с помощью которого вами будет загружен репозиторий из Github.

- `Docker` (и `Docker Compose`), средствами которых осуществляется мануальное (в представлении этого репозитория) развертывание Vault в системе.

- `Ansible`, если вы собираетесь развертывать Vault в автоматическом режиме на двух или более серверах с разными ОС. Ещё потребуется пользователь с правами sudo на удаленных серверах, из-под которого будут запускаться плейбуки.

- `Terraform`, если вы собираетесь конфигурировать непосредственно сам Vault с помощью IaC подхода.

- `K8s`-инструментарий для взаимодействия, если вы собираетесь развертывать Vault в кластере Kubernetes.

## **Структура репозитория**

Ниже представлено краткое описание того, что собой представляет каждый файл или директория в корне репозитория:

- **vault.sh:** Файл представляет собой скрипт и относится к этапу мануального развертывания Vault, только нативно, в качестве сервиса в самой системе. Поддерживает все базовые семейства дистрибутивов.

- **Dockerfile:** Файл для сборки индивидуального образа, который используется для последующего запуска Vault при мануальном развертывании (в роли `docker-single-vault` лежит аналог для запуска с помощью Ansible).

- **vault-docker-compose.yaml:** Файл для непосредственного запуска Vault на базе образа, который был собран с помощью Dockerfile (в роли `docker-single-vault` лежит аналог для запуска с помощью Ansible).

- **requirements.txt:** Файл зависимостей для установки Ansible Molecule с последующим тестированием всех существующих ролей в проекте, которые запускаются в рамках исполняемого CI в Github.

- **ansible:** Директория, предназначенная для развертывания Vault с помощью такого инструмента автоматизации, как Ansible. Содержит в себе различные плейбуки для вызова ролей, сами роли, дополнительные конфигурационные файлы для запуска и т.д.

- **dockerfiles:** Директория с файлами Dockerfiles, на базе которых были собраны образы различных операционных систем (образы хранятся на DockerHub). На данный момент это актуальные версии Debian/Ubuntu, CentOS/RedHat/AlmaLinux/Rocky и OpenSUSE/SLES. В будущем возможно расширение представленного списка. Данные образы используются для тестирования плейбуков Ansible, а сам процесс осуществляется с помощью такого инструмента, как Molecule. По умолчанию все тесты организованы на базе Docker. Представлены здесь исключительно в ознакомительных целях и никак не влияют непосредственно на развертывание самого Vault. Однако при желании вы можете запустить тесты и у себя, чтобы посмотреть на результат работы. Особенно это уместно, если вы решите внести те или иные изменения в работу одной из ролей.

- **terraform:** Директория, предназначенная для конфигурирования Vault с помощью такого инструмента автоматизации, как Terraform. Содержит в себе различного рода самописные модули и окружения, где эти модули могут быть вызваны, что в конечном итоге позволяет описать конфигурацию Vault в виде кода.

Прочие файлы являются вспомогательными и не представляют особого интереса.

## **Локальное развертывание Vault**

Локальное развертывание подразумевает под собой запуск Vault в ручном режиме на локальном узле, без участия каких-либо сторонних инструментов автоматизации. Это на тот случай, если кто-то с Ansible незнаком, считает его использование избыточным и просто хочет понять, что собой представляет Vault. И, чисто технически, вы можете использовать данный подход для развертывания Vault на узле в реальном окружении. Однако подразумевается, что для таких целей всё же будет применен тот или иной инструмент автоматизации. При этом для каждого из сценариев используются конфигурационные файлы из директории `properties`. Можно поменять как конфигурацию непосредственно самого Vault, так и файл Systemd для нативного запуска в системе. В общем случае после того, как проект был склонирован, есть два варианта локального развертывания Vault в системе.

---

### Развертывание Vault с помощью Bash Script:

Этот вариант предлагает использовать файл `vault.sh` для простого развертывания Vault в системе. В сущности своей данный самописный сценарий заменяет N-ое количество шагов, которые необходимо было бы выполнить вручную. Является сжатым вариантом того, что происходит, когда мы развертываем Vault с помощью Ansible на удаленных узлах. Сценарий поддерживает самые распространенные дистрибутивы таких семейств как Debian, Redhat и SUSE. И, хотя он покрывает базовые варианты развития событий, данный сценарий не был протестирован на каждой версии каждого дистрибутива ранее вышеупомянутых семейств. Об этом стоит помнить. Чтобы запустить его выполните следующую команду:

```
sudo ./vault.sh
```

Сценарий `vault.sh` также обладает несколькими параметрами, с помощью которых, например, можно узнать список доступных версий Vault, чтобы в свою очередь установить желаемый вариант:

```
sudo ./vault.sh -l
```

Если вы всё же надумали установить более старую версию Vault, то в таком случае можно воспользоваться этой командой:

```
sudo ./vault.sh -s 1.19.0
```

---

### Развертывание Vault с помощью Docker Compose:

Этот вариант подразумевает запуск Vault с помощью Docker Compose. На самом деле в случае с Vault вариант через Docker хоть и упрощает установку, в то же время этот метод подвержен ряду недостатков со стороны безопасности, поскольку секреты можно получить из памяти при работе Vault в контейнере. С другой стороны, в нашем случае уже была добавлена реализация по предотвращению данного инцидента в лице:

```
cap_add:
  - IPC_LOCK
ulimits:
  memlock:
    soft: -1
    hard: -1
```

Чтобы запустить сам Vault с помощью Docker Compose необходимо воспользоваться следующей командой:

```
docker compose -f vault-docker-compose.yaml up -d
```

Если есть потребность в смене версии Vault, то в таком случае нужно изменить значение аргумента `VERSION` внутри файла Compose. Это же можно сделать через передачу аргумента во время выполнения команды:

```
docker compose up -f vault-docker-compose.yaml -d --build --build-arg VERSION=1.19.0
```

## **Автоматизированное развертывание Vault с помощью Ansible**

Для начала вводная часть. Директория `ansible/`, как уже было отмечено ранее, содержит в себе набор плейбуков, ролей и переменных, которые используются для вызова различных сценариев, что в конечном итоге приводит к автоматизированному развертыванию Vault. Некоторые из ролей обладают двумя или более вариантами развертывания (и дальше это будет подсвечено), каждый из которых достигается за счёт использования той или иной переменной в каждой из ролей. В общем случае структура директории `ansible` такова:

- **Директория inventory:** Содержит в себе структуру всех хостов (в моем случае файл `servers.yaml` больше выступает в роли примера со всеми сценариями) и всех глобальных переменных (в представлении данного проекта), которые используются для одной или нескольких ролей. Inventory – это то место, которое необходимо подготовить перед запуском любой из ролей.

- **Директория playbooks:** Содержит в себе все основные файлы для вызова того или иного сценария. В моём случае каждый из файлов предназначен для вызова какой-то одной основной роли, однако каждая из основных ролей может вызывать одну или несколько вспомогательных.

- **Директория roles:** Содержит в себе весь список ролей, которые отвечают за автоматизированное развертывание Vault в том или ином режиме работы, в зависимости от установленной глобальной переменной.

Все ключевые переменные уже заполнены валидными данными, поэтому каждая роль работает из коробки, однако для задействования дополнительных режимов работы (некоторые роли содержат в себе два и более режима) понадобится изменение ключевых глобальных переменных. Об этом будет подробно рассказано в каждой из ролей. Параметр `-i` во время запуска плейбука можно не указывать, поскольку путь прописан в `ansible.cfg` (при условии, что вами будет использован файл `servers.yaml`). Подробнее про Inventory-файл и каждую глобальную переменную можно почитать [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Поддерживаемые операционные системы:

Ниже представлен список операционных систем, на которых были протестированы все роли в рамках данного проекта:

| Семейство | Дистрибутив | Версия | Поддержка |
|---|---|---|---|
| Debian | Debian | 11 | ✅ |
| Debian | Debian | 12 | ✅ |
| Debian | Debian | 13 | ✅ |
| Debian | Ubuntu | 20.04 | ⚠️ |
| Debian | Ubuntu | 22.04 | ✅ |
| Debian | Ubuntu | 24.04 | ✅ |
| RedHat | CentOS Stream | 8 | ⚠️ |
| RedHat | CentOS Stream | 9 | ✅ |
| RedHat | Red Hat Enterprise Linux | 8 | ⚠️ |
| RedHat | Red Hat Enterprise Linux | 9 | ✅ |
| RedHat | Red Hat Enterprise Linux | 10 | ✅ |
| RedHat | AlmaLinux | 8 | ⚠️ |
| RedHat | AlmaLinux | 9 | ✅ |
| RedHat | AlmaLinux | 10 | ✅ |
| RedHat | Rocky Linux | 8 | ⚠️ |
| RedHat | Rocky Linux | 9 | ✅ |
| RedHat | Rocky Linux | 10 | ✅ |
| SUSE | openSUSE Leap | 15.6 | ✅ |
| SUSE | openSUSE Leap | 16.0 | ✅ |
| SUSE | SUSE Linux Enterprise Server | 15.6 | ✅ |
| SUSE | SUSE Linux Enterprise Server | 16.0 | ✅ |

Примечание: ⚠️ – означает, что все представленные роли в этом проекте также могут быть развернуты, теоретически, и для таких версий дистрибутивов, однако на практике, со 100% вероятностью, возникнет конфликт версий между `Python` на целевых узлах (обычно версии 3.6 для представленных дистрибутивов) и последними версиями `Ansible` (начиная с 2.19+), которые запрашивают `Python` более старшей версии. Самым простым вариантом будет установка `Ansible` версии 2.11-2.13 для успешного развертывания существующих ролей в рамках данного списка проблемных дистрибутивов. В качестве альтернативы можно попробовать установить более свежую версию `Python` на такие дистрибутивы. Так или иначе, в рамках данного репозитория было решено отказаться от поддержки представленного списка проблемных дистрибутивов. И, хотя формально работоспособность ролей для них сохранена, на деле придется столкнуться с вышеупомянутой проблемой. Поддержка на уровне `Molecule` и CI в `Github` также была удалена для данного списка дистрибутивов. Если какого-то дистрибутива нет в списке вообще, значит для такого дистрибутива нет поддержки по развертыванию всех ролей в рамках данного проекта.

---

### Запуск плейбука `manual-single-vault.yaml`:

**Роль manual-single-vault** – по умолчанию данная роль используется для развертывания Vault в виде бинарного файла с Systemd-юнитом. Такой Vault работает в режиме Standalone с базовым набором параметров в своей конфигурации, поэтому роль предназначена для одиночных серверов, без сценария с кластеризацией. Чтобы запустить базовый вариант, воспользуйтесь следующей командой, находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/manual-single-vault.yaml
```

Опционально роль `manual-single-vault` также поддерживает развертывание Vault для работы с Transit-сервером. Обычно вариант с Transit используется для автоматического распечатывания основного Vault (как Standalone так и Cluster версии), дабы не использовать ручной режим. По умолчанию поддержка Transit отключена, поэтому если вы хотите развернуть Vault в таком режиме работы, то для этого в файле `all.yaml`, что в корне `group_vars`, необходимо поменять значения для данного списка переменных. В случае с Transit выглядеть это будет следующим образом:

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

**Роль docker-single-vault** – по умолчанию данная роль используется для развертывания Vault в виде Docker-контейнера с использованием Docker Compose. Такой Vault работает в режиме Standalone с базовым набором параметров в своей конфигурации, поэтому роль предназначена для одиночных серверов, без сценария с кластеризацией. Docker устанавливается на целевой сервер автоматически через зависимость роли, если он ещё не присутствует в системе. Чтобы запустить базовый вариант, воспользуйтесь следующей командой, находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/docker-single-vault.yaml
```

Опционально роль `docker-single-vault` также поддерживает развертывание Vault для работы с Transit-сервером. Обычно вариант с Transit используется для автоматического распечатывания основного Vault (как Standalone так и Cluster версии), дабы не использовать ручной режим распечатывания. По умолчанию поддержка Transit отключена, поэтому если вы хотите развернуть Vault в таком режиме работы, то для этого в файле `all.yaml`, что в корне `group_vars`, необходимо поменять значения для данного списка переменных. В случае с Transit выглядеть это будет следующим образом:

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

**Роль manual-cluster-vault** – по умолчанию данная роль используется для развертывания Vault в режиме кластера посредством бинарного файла с Systemd-юнитом. Роль поддерживает два взаимоисключающих варианта Storage Backend – **Raft** (встроенный по умолчанию) и **Consul** (внешний), а также ряд опциональных режимов: TLS (HTTP (по умолчанию) и HTTPS с автоматической генерацией самоподписных сертификатов через роль `system-internal-certificates`) для API и межнодовой коммуникации, TLS для соединения с Consul, и Transit Auto-Unseal. Переменные для данной роли задаются в файле `all.yaml`, что в директории `group_vars/vault_cluster/` (параметры кластера и TLS) и в корневом `group_vars/all.yaml` для указания базовых параметров. Чтобы запустить роль с параметрами по умолчанию, воспользуйтесь следующей командой, находясь в директории `ansible`:

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

**Роль manual-cluster-consul** – данная роль используется для развертывания Consul в режиме кластера посредством бинарного файла с Systemd-юнитом. Роль поддерживает два режима работы: HTTP (по умолчанию) и HTTPS с автоматической генерацией самоподписных сертификатов через роль `system-internal-certificates`. Переменные роли задаются в двух местах: в файле `all.yaml` директории `group_vars/consul_cluster/` (параметры кластера и TLS) и в корневом файле `all.yaml`, расположённом в `group_vars/` для указания базовых параметров. Чтобы запустить роль с параметрами по умолчанию, воспользуйтесь следующей командой, находясь в директории `ansible`:

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

- `-e global_consul_cluster_inventory_group=vault_cluster`: Указывает роли, по каким хостам строить `retry_join` и `bootstrap_expect` в конфигурации кластера.

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

Переменная `global_consul_cluster_inventory_group` (по умолчанию `"consul_cluster"`) используется ролью только при включённом HTTPS: роль автоматически находит узел, относящийся к кластеру Consul, с которого забирает CA-сертификат и приватный ключ, подписывает ими новый сертификат для агента, после чего приватный ключ CA с узла агента удаляется. Значение переменной должно совпадать с фактическим именем группы кластера Consul в инвентори, которое указывается в переменной `global_consul_cluster_inventory_group` роли `manual-cluster-consul`. Если вы используете нестандартное имя группы (не `consul_cluster`), то в таком случае необходимо передать имя явно через `-e global_consul_cluster_inventory_group=<имя_группы>`. При HTTPS роль ходит на узлы кластера Consul через `delegate_to` и если у таких узлов SSH-пользователь отличается по имени от того, что вы использовали для развертывания агента Consul, его необходимо прописать через `ansible_user` в инвентори на уровне группы. В противном случае Ansible попытается подключиться с именем пользователя текущего плея и получит `Permission denied`:

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

Чтобы запустить роль с параметрами по умолчанию, воспользуйтесь следующей командой, находясь в директории `ansible`:

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

После того как агент Consul был запущен на узлах Vault, разворачивается сам кластер Vault с Consul в качестве Backend. Затем Vault автоматически подключается к локальному агенту на `127.0.0.1:8500` (HTTP) или `127.0.0.1:8443` (HTTPS). Если запустить установку кластера Vault до фактической установки агента Consul, такой плейбук упадёт на этапе проверки доступности Vault, хотя при этом сам Vault может быть корректно установлен и настроен:

```
ansible-playbook -i <inventory> -l vault_cluster -u <user> --private-key=<ssh-key> playbooks/manual-cluster-vault.yaml
```

Примечание: Подробнее о том, за что отвечает каждая из переменных можно посмотреть [тут](https://github.com/exitfound/vip/tree/main/ansible/inventory).

---

### Запуск плейбука `system-unseal-single-vault.yaml`:

**Роль system-unseal-single-vault** – данная роль предназначена исключительно для одиночных серверов и выполняет два взаимосвязанных сценария: первоначальную инициализацию Vault и его последующее распечатывание. Роль самостоятельно определяет текущее состояние Vault через Health API и в зависимости от него выбирает нужный путь: инициализирует (если Vault ещё не был инициализирован), распечатывает (если Vault запечатан после перезагрузки), либо завершает работу без каких-либо действий (если Vault уже инициализирован и распечатан). Полученные в ходе инициализации ключи и корневой токен сохраняются на исполняемой системе в директорию `vault_keys/`, которая в свою очередь появляется там, где изначально был запущен плейбук. Чтобы запустить роль, воспользуйтесь следующей командой, находясь в директории `ansible`:

```
ansible-playbook -i <inventory> -l <group> -u <user> --private-key=<ssh-key> playbooks/system-unseal-single-vault.yaml
```

Для корректной работы роли необходимо задать значения для списка переменных в файле `all.yaml`, что в корне `group_vars`, однако плейбук будет успешно завершён даже со значениями по умолчанию:

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

**Роль system-unseal-cluster-vault** – данная роль применима исключительно в тех случаях, когда Vault был развернут в режиме кластера. Она выполняет инициализацию и распечатывание всех узлов кластера в правильном порядке. Первый хост из группы инвентори автоматически становится **Master Node** – именно он инициализируется первым и именно от него берутся ключи для распечатывания остальных узлов. Прочие хосты в группе становятся **Standby Nodes** и распечатываются с использованием ключей, сохранённых в ходе инициализации **Master Node**. Роль самостоятельно определяет текущее состояние каждой ноды через Health API и выбирает нужный путь: инициализирует и распечатывает (если кластер ещё не был инициализирован), повторно распечатывает (если ноды запечатаны после перезагрузки), либо завершает работу без каких-либо действий (если все ноды уже активны). Ключи и корневой токен сохраняются на исполняемой системе в директорию `vault_keys/`, которая появляется там, где был запущен плейбук. Чтобы запустить роль, воспользуйтесь следующей командой, находясь в директории `ansible`:

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

Чтобы запустить базовый вариант, воспользуйтесь следующей командой, находясь в директории `ansible`:

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

**Роль system-proxy-haproxy** – по умолчанию данная роль устанавливает и настраивает HAProxy в качестве Reverse Proxy для работы с одиночным Vault-сервером по схеме HTTP → HTTP. Переменная `global_haproxy_host_domain` задаётся непосредственно в inventory-файле на уровне конкретного хоста – именно так роль получает уникальный домен для каждого сервера. Значение в `group_vars/all.yaml` является заглушкой и используется только во время тестов Molecule. Остальные переменные для данной роли по умолчанию всё так же задаются в файле `all.yaml`, что в корне `group_vars`:

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

Чтобы запустить базовый вариант, воспользуйтесь следующей командой, находясь в директории `ansible`:

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

## **Автоматизированное конфигурирование Vault с помощью Terraform**

Сперва общая информация. Директория `terraform/`, как было отмечено ранее, содержит набор модулей и окружений, предназначенных для конфигурирования уже развёрнутого сервера Vault. Иными словами, если Ansible отвечает за установку и запуск Vault в системе, то Terraform берёт на себя всё, что происходит внутри него: создание хранилищ секретов, политик, методов аутентификации и т.д. Оркестрация между окружениями организована через [Terragrunt](https://terragrunt.gruntwork.io/), поэтому его наличие в вашей системе обязательно. Он генерирует файлы `versions.tf`, `backend.tf` и `provider.tf` для каждой рабочей директории автоматически при каждом выполнении инициализации. Эти файлы создаются в момент исполнения и в репозиторий не попадают. Вручную нужно описать только сами `.tf` файлы, которые вызывают нужные вам модули. Если вы не готовы использовать Terragrunt, то в таком случае вышеупомянутые файлы `versions.tf`, `backend.tf` и `provider.tf` придется создать и заполнить самостоятельно. Только после этого команда `terraform` заработает. В общем случае структура директории `terraform/` такова:

- **Директория modules:** Данная директория содержит список переиспользуемых модулей, каждый из которых инкапсулирует один логический блок конфигурации Vault. На данный момент этих модулей 12 и все они отражают базовые возможности Terraform. Можно написать свой модуль и также легко его внедрить в общую структуру иерархии.

- **Директория environments:** На данный момент содержит такие окружения как `localhost` с локальным состоянием инфраструктуры (для разработки и тестирования) и `production` с удаленным состоянием инфраструктуры на базе S3 (для реального использования). Каждое окружение содержит одну или несколько рабочих директорий с набором `.tf` файлов, которые в свою очередь вызывают нужные модули.

Вы можете создавать столько рабочих директорий, сколько вам нужно в рамках того или иного окружения. По своей сути вся текущая инфраструктура, представленная в директории `environments`, является лишь одним большим примером для общего понимания. В рамках данного репозитория рабочая директория с именем `vault-local-1` по пути `./environments/localhost/` представляет собой сугубо демонстрационный вариант вызова всех модулей. Каждый модуль вызывается в том или ином `.tf` файле в корне вышеупомянутой директории. В общем случае все вызываемые модули представлены в виде двух вариантов:

- **Простой вариант:** Минимальный автономный пример с приставкой `simple` без зависимостей на другие модули. Удобен как отправная точка для копирования.

- **Полный вариант:** Конфигурация со связями между модулями, где политика передаётся в Auth-роль, Auth-роль используется для алиаса в Entity, а сам Entity добавляется в группу. Все ключевые переменные заполнены валидными значениями и каждый модуль работает из коробки.

---

### Структура иерархии и процесс запуска:

На самом деле вариантов того, как выстроить архитектуру через Terraform (+ Terragrunt) для работы с Vault (да и не только) масса. Какие-то варианты плохие, какие-то хорошие, но все они, так или иначе, позволят конфигурировать целевой объект и описывать все настройки в виде кода. Предложенный в данном репозитории вариант является лишь одним из возможных. По определению нельзя учесть все варианты развития событий, поскольку Vault может быть использован для разных целей. Он также имеет большое число интеграций, поэтому очень сложно выстроить такую структуру и описать все модули так, чтобы они подошли каждому. Это важно понимать. Так что не стоит зацикливаться на том, как это было реализовано конкретно здесь. В общем случае структура иерархии при работе с Terraform (+ Terragrunt) в рамках данного репозитория выглядит следующим образом:

```
terraform/
├── modules/
│   ├── audit_device/           # Audit devices
│   ├── vault_default_policy/   # Default policy
│   ├── vault_custom_policy/    # User ACL policies
│   ├── secrets_kv/             # KV v2 Secrets Engine
│   ├── auth_approle/           # AppRole Auth Method
│   ├── auth_jwt/               # JWT/OIDC Auth Method (GitHub Actions, GitLab CI)
│   ├── auth_userpass/          # Userpass Auth Method
│   ├── transit_backend_key/    # Transit Engine
│   ├── identity_entity/        # Identity Entity + aliases
│   ├── identity_group/         # Identity Group
│   ├── identity_oidc/          # OIDC token provider (signing key + roles)
│   └── password_policy/        # Password Policy
└── environments/
    ├── localhost/              # Local state
    │   ├── terragrunt.hcl
    │   └── vault-local-1/
    │       ├── terragrunt.hcl
    │       ├── audit.tf
    │       ├── default_policy.tf
    │       ├── custom_policy.tf
    │       ├── secrets_kv.tf
    │       ├── auth_approle.tf
    │       ├── auth_jwt.tf
    │       ├── auth_userpass.tf
    │       ├── transit.tf
    │       ├── identity_entity.tf
    │       ├── identity_group.tf
    │       ├── identity_oidc.tf
    │       ├── password_policy.tf
    │       └── outputs.tf
    └── production/             # Remote state в S3
        ├── terragrunt.hcl
        ├── vault-single-1/
        └── vault-cluster-1/
```

Перед запуском в любой рабочей директории необходимо выставить переменные окружения, которые провайдер Vault считывает нативно – адрес узла и токен аутентификации с соответствующими правами для управления и настройки:

```bash
export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=hvs.xxx
```

После этого запускается стандартная последовательность команд. Все примеры ниже приведены для рабочей директории `vault-local-1`, однако для любого другого окружения команды идентичны:

```bash
cd terraform/environments/localhost/vault-local-1
terragrunt init
terragrunt plan
terragrunt apply
```

Примечание: Для работы с Production-окружением необходимо предварительно прописать свой S3-бакет в файле `environments/production/terragrunt.hcl`, заменив плейсхолдер `YOUR-STATE-BUCKET` на реальное название вашего бакета. Состояние инфраструктуры будет отдельно храниться в файле S3. Для доступа к S3 дополнительно потребуется переменная `AWS_PROFILE` с именем профиля из `~/.aws/credentials`. 

После выполнения команды `terragrunt apply` все созданные значения доступны через Outputs. Sensitive-значения – токены, начальные пароли, secret_id не отображаются в стандартном выводе и запрашиваются явно:

```bash
terragrunt output -raw transit_token
terragrunt output -json auth_userpass_initial_passwords
terragrunt output auth_approle_role_id
terragrunt output auth_approle_secret_id_accessor
```

---

### Вызов модуля `system_audit`:

**Модуль system_audit** – используется для включения функции аудита в Vault. Поддерживает два типа: `file` (запись в файл на диске) и `syslog` (передача в системный журнал). Поскольку Vault не позволяет зарегистрировать два варианта одного типа на одном и том же пути, один экземпляр модуля отвечает только за один тип и для включения обоих необходимо создать два отдельных экземпляра:

```yaml
enable_file: true/false    # Включить file audit device
enable_syslog: true/false  # Включить syslog audit device
file_path: ""              # Путь к файлу (только при enable_file = true)
file_mode: "0600"          # Права на файл
log_raw: false             # Писать данные в открытом виде – только для отладки
hmac_accessor: true        # Хешировать Accessor токена в записях
format: "json"             # Формат записей: json или jsonx
syslog_facility: "AUTH"    # Syslog facility (только при enable_syslog = true)
syslog_tag: "vault"        # Syslog tag (только при enable_syslog = true)
```

Параметр `log_raw = true` выводит секреты в открытом виде, что допустимо исключительно в отладочных целях. Важно помнить, что при включённом аудите Vault отказывается обрабатывать запросы, если запись в источник аудита завершается с ошибкой. Это поведение по умолчанию, обеспечивающее гарантию аудита. Пример вызова модуля ниже:

```hcl
module "audit_file" {
  source = "../../../modules/system_audit"

  enable_file = true
  file_path   = "/var/log/vault/audit.log"
}

module "audit_syslog" {
  source = "../../../modules/system_audit"

  enable_syslog = true
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/system_audit/README.md).

---

### Вызов модуля `vault_default_policy`:

**Модуль vault_default_policy** – используется для управления встроенной политикой `default` в Vault. Эта политика автоматически выдаётся всем токенам, если они не создаются с явным указанием параметра `no_default_policy`. Базовый набор правил, который модуль всегда включает, состоит из `auth/token/lookup-self`, `auth/token/renew-self`, `auth/token/revoke-self`, `sys/leases/renew`, `sys/leases/lookup`, `sys/capabilities-self`. Через переменную `extra_rules` можно добавить дополнительные правила поверх базовых, не заменяя их:

```yaml
extra_rules: []  # Список дополнительных правил поверх базовых (пусто – только базовые)
```

На ресурс `vault_policy.default` внутри модуля выставлен `lifecycle { prevent_destroy = true }` – удаление политики `default` через Terraform заблокировано, что предотвращает случайное уничтожение встроенной политики Vault. Один экземпляр данного модуля для всего узла Vault. Пример вызова модуля ниже:

```hcl
module "default_policy" {
  source = "../../../modules/vault_default_policy"

  extra_rules = [
    { path = "sys/mounts",       capabilities = ["read"] },
    { path = "sys/policies/acl", capabilities = ["list"] },
  ]
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/vault_default_policy/README.md).

---

### Вызов модуля `vault_custom_policy`:

**Модуль vault_custom_policy** – используется для создания произвольных ACL-политик. Один экземпляр модуля соответствует одной политике. Правила описываются структурированным списком объектов с полями `path` и `capabilities`. Модуль самостоятельно рендерит HCL-синтаксис политики из переданных данных, поэтому отдельный `.hcl` файл политики создавать не нужно. Имя политики затем передаётся в другие модули через собственные переменные:

```yaml
name: ""   # Имя политики (обязательно)
rules: []  # Список правил; формат: [{ path = "...", capabilities = ["read", "list"] }]
```

```hcl
module "policy_app" {
  source = "../../../modules/vault_custom_policy"
  name   = "app-policy"

  rules = [
    { path = "my-app/data/*",          capabilities = ["read", "list"] },
    { path = "my-app/metadata/*",      capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
    { path = "auth/token/renew-self",  capabilities = ["update"] },
  ]
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/vault_custom_policy/README.md).

---

### Вызов модуля `system_password_policy`:

**Модуль system_password_policy** – используется для создания Password Policy. Password Policy в Vault описывает правила генерации паролей на стороне сервера: длину и набор допустимых символов с минимальными требованиями к каждому набору. После `terragrunt apply` пароль генерируется по запросу командой:

```
vault read sys/policies/password/<name>/generate
```

И не попадает в состояние инфраструктуры, что принципиально отличает этот подход от генерации через `random_password`. Типичный сценарий представляет собой создание политики через модуль, после чего использовать её имя для ручной генерации паролей операторами:

```yaml
name: ""    # Имя политики паролей
length: 20  # Длина генерируемых паролей
rules: []   # Правила символов и формат вида [{ charset = "abc...", min_chars = 1 }]
```

Сумма всех `min_chars` не должна превышать `length`. В противном случае Vault отклонит политику с ошибкой при выполнении `terragrunt apply`. В рабочей директории `vault-local-1` представлены три готовых примера: `demo-password` (16 символов, только буквы и цифры), `ops-password` (24 символа, с заглавными и спецсимволами) и `service-password` (32 символа, для машинных учётных записей). Пример вызова модуля ниже:

```hcl
module "password_policy_ops" {
  source = "../../../modules/system_password_policy"
  name   = "ops-password"
  length = 24

  rules = [
    { charset = "abcdefghijklmnopqrstuvwxyz", min_chars = 2 },
    { charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ", min_chars = 2 },
    { charset = "0123456789",                 min_chars = 2 },
    { charset = "!@#$%&*",                    min_chars = 1 },
  ]
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/system_password_policy/README.md).

---

### Вызов модуля `auth_approle`:

**Модуль auth_approle** – используется для настройки метода аутентификации AppRole. Данный метод предназначен для машинной аутентификации: сервисы и приложения проходят этап аутентификации в Vault, предъявляя `role_id` и `secret_id`. Параметр `role_id` статичен и является публичным идентификатором роли, тогда как `secret_id` – это секрет, который должен передаваться приложению вне Terraform (например, через CI/CD). Если выставить `generate_secret_id = true`, модуль создаст `secret_id` самостоятельно и выставит его как Sensitive Output. При этом повторный `terragrunt apply` не перегенерирует `secret_id`, поскольку на ресурс наложен `lifecycle { ignore_changes = [...] }`:

```yaml
path: "approle"           # Путь монтирования для AppRole Backend
role_name: "my-app-role"  # Имя роли
token_policies: []        # Список политик, выдаваемых токену
token_ttl: 3600           # TTL токена в секундах
token_max_ttl: 86400      # Максимальный TTL токена в секундах
token_num_uses: 0         # Количество использований токена (0 = неограниченно)
token_period: 0           # Период periodic-токена (0 = обычный токен с TTL)
token_type: "default"     # Тип токена – default, service или batch
token_bound_cidrs: []     # CIDR-ограничения на использование токена
bind_secret_id: true      # Требовать secret_id при логине
secret_id_ttl: 86400      # TTL secret_id в секундах (0 = без истечения)
secret_id_num_uses: 5     # Количество использований secret_id (0 = неограниченно)
secret_id_bound_cidrs: [] # CIDR-ограничения на использование secret_id
generate_secret_id: false # Создать secret_id через Terraform и вывести как Output
```

Параметр `token_period` при ненулевом значении создаёт периодический токен без TTL, который продлевается при каждом использовании. Это удобно для долгоживущих сервисов. Параметр `bind_secret_id = false` позволяет логиниться только по `role_id` без `secret_id`, что допустимо при использовании совместно с `token_bound_cidrs` в доверенных сетях. Пример вызова модуля ниже:

```hcl
module "auth_approle" {
  source = "../../../modules/auth_approle"

  path           = "approle"
  role_name      = "my-app-role"
  token_policies = [module.policy_app.policy_name]
  token_ttl      = 3600
  token_max_ttl  = 86400
  token_type     = "default"

  bind_secret_id     = true
  secret_id_num_uses = 0
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/auth_approle/README.md).

---

### Вызов модуля `auth_jwt`:

**Модуль auth_jwt** – используется для настройки метода аутентификации JWT/OIDC. Предназначен прежде всего для аутентификации в CI/CD: GitHub Actions и GitLab CI выпускают подписанные JWT, которые Vault верифицирует через JWKS Endpoint. Параметры `bound_claims` позволяют ограничить доступ по конкретному репозиторию, ветке или окружению – Vault примет токен только если все указанные Claims совпадают с теми, что содержатся в JWT:

```yaml
path: "jwt"                    # Путь монтирования JWT Backend
role_name: "github-actions"    # Имя роли
role_type: "jwt"               # Тип – jwt или oidc
user_claim: "sub"              # Claim из JWT, используемый как имя пользователя
jwks_url: ""                   # URL для получения JWKS (публичных ключей)
jwks_ca_pem: ""                # PEM CA для JWKS URL (пусто = системный CA)
bound_issuer: ""               # Ожидаемый issuer (iss claim), пусто = не проверять
bound_audiences: []            # Ожидаемые audience (aud claim)
bound_subject: ""              # Ожидаемый subject (sub claim), пусто = не проверять
bound_claims: {}               # Map claims, которые должны присутствовать в JWT
token_policies: []             # Список политик
token_ttl: 300                 # TTL токена в секундах
token_max_ttl: 300             # Максимальный TTL токена
token_type: "batch"            # Тип токена
token_bound_cidrs: []          # CIDR-ограничения
```

Для GitHub Actions `jwks_url` – `https://token.actions.githubusercontent.com/.well-known/jwks`, тогда как для GitLab CI – `https://gitlab.example.com/-/jwks`. При использовании самоподписного сертификата для JWKS Endpoint PEM сертификат передаётся через `jwks_ca_pem`. Параметр `token_type = "batch"` – оптимальный выбор для CI, потому что batch-токены легковесны, не хранятся в хранилище Vault и автоматически инвалидируются по истечении TTL. Пример вызова модуля ниже:

```hcl
module "auth_jwt" {
  source = "../../../modules/auth_jwt"

  path           = "jwt"
  role_name      = "github-actions"
  jwks_url       = "https://token.actions.githubusercontent.com/.well-known/jwks"
  token_policies = [module.policy_ci.policy_name]
  token_ttl      = 300
  token_max_ttl  = 300
  token_type     = "batch"

  bound_claims = {
    repository = "my-org/my-repo"
  }
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/auth_jwt/README.md).

---

### Вызов модуля `auth_userpass`:

**Модуль auth_userpass** – используется для настройки метода аутентификации Userpass. Предназначен для аутентификации операторов и людей, логинящихся в Vault с именем пользователя и паролем. Пользователи описываются списком объектов, каждый из которых содержит имя, политики и параметры токена. Terraform управляет конфигурацией пользователей, но не паролями в долгосрочной перспективе: начальный пароль генерируется автоматически через `random_password` при первом `terragrunt apply` и доступен как Sensitive Output – пользователь должен поменять его самостоятельно после первого входа, а Terraform никогда не перезапишет уже установленный пароль:

```yaml
path: "userpass"  # Путь монтирования Userpass Backend
description: ""   # Описание Backend
users: []         # Список пользователей, поля каждого объекта:
                    # username, token_policies, token_ttl, token_max_ttl, token_type, token_num_uses, token_bound_cidrs
```

Получить начальные пароли после apply можно с помощью следующей команды:

```
terragrunt output -json auth_userpass_initial_passwords
```

Сменить пароль вручную можно с помощью следующей команды:

```
vault write auth/<path>/users/<username>/password password=<new>
```

При последующем выполнении `terragrunt apply` пароль на стороне Vault остаётся нетронутым – обновляются только политики и TTL. Пример вызова модуля ниже:


```hcl
module "auth_userpass" {
  source      = "../../../modules/auth_userpass"
  path        = "userpass"
  description = "Userpass auth for operations team"

  users = [
    {
      username          = "alice"
      token_policies    = [module.policy_ops.policy_name]
      token_ttl         = 3600
      token_max_ttl     = 28800
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
  ]
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/auth_userpass/README.md).

---

### Вызов модуля `secret_engine_kv`:

**Модуль secret_engine_kv** – используется для создания KV Secrets Engine версии 2. Создаёт Mount с заданным путём и конфигурирует параметры версионирования. Terraform управляет только монтированием и его настройками, а контент (сами секреты) заносит пользователь вручную или через CI/CD после `terragrunt apply`. Как правило, каждый сервис или команда получают свой изолированный путь монтирования с независимой конфигурацией:

```yaml
path: "my-app"                # Путь монтирования в Vault
max_versions: 10              # Количество хранимых версий секрета (0 = неограниченно)
cas_required: false           # Обязательная проверка Check-And-Set при записи
delete_version_after: "24h"   # TTL версии секрета, "" = не удалять
```

Параметр `cas_required = true` при записи требует явно указывать текущую версию секрета – это защищает от гонок при конкурентной записи. Параметр `delete_version_after` принимает строку в формате Go Duration (`"24h"`, `"168h"` и т.д.), по истечении которой версия автоматически помечается как удалённая. Пример вызова модуля ниже:

```hcl
module "kv_my_app" {
  source = "../../../modules/secret_engine_kv"

  path         = "my-app"
  max_versions = 10
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/secret_engine_kv/README.md).

---

### Вызов модуля `secret_engine_transit`:

**Модуль secret_engine_transit** – используется для создания Transit Secret Engine с ключом шифрования и периодическим бесхозным токеном для автоматического распечатывания Vault. Transit Engine – это Encryption as a Service. Данные не хранятся внутри Vault, он лишь шифрует и расшифровывает их по запросу. Наиболее распространённое применение в рамках данного проекта – Transit Auto-Unseal, когда один узел Vault выступает Transit-сервером для автоматического распечатывания другого (или кластера). Для этого сценария модуль создаёт токен с параметром (`no_parent = true`) и с политикой, ограниченной только операциями `encrypt/decrypt` на конкретном ключе:

```yaml
name: "autounseal"              # Имя Transit ключа
path: "transit"                 # Путь монтирования Transit Engine
policy_name: ""                 # Имя политики, прикреплённой к токену
period: "8760h"                 # Период обновления periodic-токена (0 = обычный токен)
renewable: true                 # Разрешить ручное продление токена
no_default_policy: true         # Исключить политику default из токена
no_parent: true                 # Orphan-токен, не привязанный к Terraform-сессии
explicit_max_ttl: ""            # Жёсткий лимит жизни токена вне зависимости от продлений
allow_plaintext_backup: false   # Разрешить plaintext-бэкап ключа
deletion_allowed: false         # Разрешить удаление ключа через API
exportable: false               # Разрешить экспорт материала ключа
auto_rotate_period: 0           # Автоматическая ротация ключа в секундах (0 = выключено)
```

Значение токена доступно как Sensitive Output. Именно это значение передаётся в переменную `global_vault_transit_backend_token` при развёртывании Vault с Transit Auto-Unseal через Ansible. Пример вызова модуля ниже:

```hcl
module "transit" {
  source = "../../../modules/secret_engine_transit"

  name        = "autounseal"
  path        = "transit"
  policy_name = module.policy_transit.policy_name
  period      = "8760h"
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/secret_engine_transit/README.md).

---

### Вызов модуля `system_identity_entity`:

**Модуль system_identity_entity** – используется для создания Identity Entity. Entity – это логическая сущность, объединяющая несколько способов аутентификации одного и того же пользователя или сервиса в единую идентичность с общими метаданными. Например, если у пользователя есть и Userpass-логин, и AppRole, через Entity можно объединить оба алиаса под одной сущностью. Метаданные, назначенные Entity, доступны в OIDC-токенах и Vault ACL-шаблонах через `identity.entity.metadata.*`:

```yaml
name: ""         # Имя Entity
metadata: {}     # Произвольные метаданные { ключ = "значение" }
disabled: false  # Заблокировать Entity (все токены через алиасы будут отклоняться)
policies: []     # Политики напрямую на Entity (рекомендуется назначать через группы)
aliases: []      # Алиасы аутентификации формата [{ name = "...", mount_accessor = "..." }]
```

Параметр `disabled = true` немедленно блокирует все токены, выданные через любой алиас данной Entity, без удаления самой сущности. Бывает полезно для временной блокировки пользователя без потери конфигурации. Пример вызова модуля ниже:

```hcl
module "entity_alice" {
  source   = "../../../modules/system_identity_entity"
  name     = "alice"
  metadata = { team = "ops", env = "prod" }
  disabled = false

  aliases = [
    {
      name           = "alice"
      mount_accessor = module.auth_userpass.accessor
    },
  ]
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/system_identity_entity/README.md).

---

### Вызов модуля `system_identity_group`:

**Модуль system_identity_group** – используется для создания Identity Group. Группы позволяют назначать политики сразу множеству Entity, а также выстраивать иерархию через вложенные группы и это предпочтительный способ управления правами по сравнению с прямым назначением политик на Entity. Модуль поддерживает два типа групп:

- **Internal:** Члены группы назначаются явно через параметр `member_entity_ids` и `member_group_ids`.

- **External:** Членство синхронизируется из внешней системы (LDAP, GitHub) через алиас групп и в таком случае `member_entity_ids` не используется:

```yaml
name: ""                  # Имя группы
type: "internal"          # Internal (Terraform управляет составом) или External (членство из внешней системы)
policies: []              # Политики, наследуемые всеми членами группы
metadata: {}              # Произвольные метаданные группы
member_entity_ids: []     # ID Entity-участников (только для Internal)
member_group_ids: []      # ID дочерних групп (только для Internal)
alias_name: ""            # Имя группы во внешней системе (только для External)
alias_mount_accessor: ""  # Accessor Auth Backend, предоставляющего внешнее членство (только для External)
```

Для External-группы вместо `member_entity_ids` задаются `alias_name` (имя группы во внешней системе, например DN в LDAP или Slug команды в GitHub) и `alias_mount_accessor` (Accessor соответствующего Auth Backend). Пример вызова модуля ниже:

```hcl
module "group_ops" {
  source            = "../../../modules/system_identity_group"
  name              = "ops-team"
  type              = "internal"
  policies          = []
  member_entity_ids = [module.entity_alice.entity_id, module.entity_bob.entity_id]
  member_group_ids  = []
  metadata          = { team = "ops" }
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/system_identity_group/README.md).

---

### Вызов модуля `system_identity_oidc`:

**Модуль system_identity_oidc** – используется для превращения Vault в OIDC Token Provider. Vault может выпускать подписанные JWT-токены с Claims, основанными на метаданных Entity и группах. Это позволяет использовать Vault как источник идентичности для внешних систем, умеющих верифицировать OIDC-токены. Модуль создаёт подписанный ключ с автоматической ротацией и набором ролей, каждая из которых определяет TTL токена, его Claims-шаблон и опциональный идентификатор клиента. Параметр `verification_ttl` должен быть не меньше `rotation_period`, чтобы клиенты успевали обновить публичный ключ после ротации:

```yaml
key_name: "default"      # Имя подписывающего ключа
algorithm: "RS256"       # Алгоритмы подписи – RS256/RS384/RS512/ES256/ES384/ES512/EdDSA
rotation_period: 86400   # Период ротации ключа в секундах
verification_ttl: 86400  # TTL публичного ключа после ротации в секундах (должен быть >= rotation_period)
allowed_client_ids: []   # Разрешённые client_id ролей (пусто = все)
issuer: ""               # Issuer URL OIDC-провайдера (пусто = адрес Vault)
roles: []                # Список ролей и формат вида [{ name, ttl, template, client_id }]
```

Токен для конкретной роли генерируется следующей командой:
```
vault read identity/oidc/token/<role_name>
```

Поле `template` задаётся как строка с Vault-шаблонами в `{{...}}` для подстановки данных в Entity. Пустая строка означает токен без дополнительных Claims. Пример вызова модуля ниже:

```hcl
module "oidc" {
  source           = "../../../modules/system_identity_oidc"
  key_name         = "apps"
  algorithm        = "RS256"
  rotation_period  = 86400
  verification_ttl = 172800

  roles = [
    {
      name      = "my-app"
      ttl       = 3600
      template  = "{\"groups\": {{identity.entity.groups.names}}, \"team\": {{identity.entity.metadata.team}}}"
      client_id = ""
    },
  ]
}
```

Примечание: Подробнее про модуль можно посмотреть [тут](terraform/modules/system_identity_oidc/README.md).

---
