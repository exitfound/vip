## Описание Inventory:

Директория содержит основной inventory-файл `servers.yaml` и групповые переменные (`group_vars/`). Всё, что здесь указано – лишь пример: IP-адреса, имена хостов и доменные имена выставлены в демонстрационных целях и должны быть заменены на реальные значения перед запуском любого из плейбуков.

---

### Структура инвентори:

Группы `vault_cluster`, `consul_cluster` и `consul_agent` – это основные рабочие группы для кластерных ролей. Группы по семействам дистрибутивов (`SUSE`, `RedHat` и `Debian-like`) служат для запуска одиночных ролей на конкретных узлах в зависимости от их ОС.


```
all
├── vault_cluster              # Группа нод кластера Vault (обычно 3 ноды)
├── consul_cluster             # Группа нод кластера Consul (обычно 3 ноды)
├── consul_agent               # Группа нод с Consul-агентами
├── suse                       # Семейство SUSE
│   ├── opensuse15.6
│   ├── opensuse16.0
│   ├── sles15.6
│   └── sles16.0
├── redhat                     # Семейство RedHat
│   ├── centos8
│   ├── centos9
│   ├── redhat8
│   ├── redhat9
│   └── redhat10
├── debian                     # Семейство Debian
│   ├── debian11
│   ├── debian12
│   └── debian13
└── ubuntu                     # Семейство Ubuntu
    ├── ubuntu20.04
    ├── ubuntu22.04
    └── ubuntu24.04
```

---

### Переменные на уровне хоста:

Переменные ниже задаются непосредственно в `servers.yaml` на уровне каждого хоста или группы, а не в `group_vars`. Именно так роль получает уникальное значение для каждого сервера:

- `ansible_host`: Публичный IP-адрес или hostname для SSH-подключения. Обязательна для каждого хоста. Пример представлен ниже:

```yaml
vault_cluster:
  hosts:
    vault_cluster1:
      ansible_host: 1.2.3.4
    vault_cluster2:
      ansible_host: 1.2.3.5
    vault_cluster3:
      ansible_host: 1.2.3.6
```

- `global_nginx_host_domain`: Доменное имя для конфигурации Nginx. Указывается только на тех узлах, где планируется запуск роли `system-proxy-nginx`. Пример представлен ниже:

- `global_haproxy_host_domain`: Доменное имя для конфигурации HAProxy. Указывается только на узлах, где планируется запуск роли `system-proxy-haproxy`. Пример представлен ниже:

```yaml
ubuntu24.04:
  hosts:
    ubuntu24.04-instance1:
      ansible_host: 1.2.3.4
      global_nginx_host_domain: vault.example.com
      global_haproxy_host_domain: vault.example.com
```

- `ansible_user`: SSH-пользователь, который задаётся на уровне группы через `vars`, если он отличается от имени пользователя, передаваемого через `-u`. Особенно актуально для роли `manual-single-consul-agent` в HTTPS-режиме – когда роль обращается к узлам кластера Consul через `delegate_to`, и если SSH-пользователь у них отличается, то без явного `ansible_user` Ansible получит `Permission denied`. Пример представлен ниже:

```yaml
consul_cluster:
  vars:
    ansible_user: admin
  hosts:
    consul_cluster1:
      ansible_host: 1.2.3.4
```

Inventory по умолчанию задан в `ansible.cfg`, поэтому флаг `-i` при запуске плейбуков указывать не обязательно.

---

### Групповые переменные (group_vars):

Файлы в `group_vars/` применяются Ansible автоматически только если узел входит в соответствующую группу. Например, `group_vars/vault_cluster/all.yaml` загружается автоматически лишь тогда, когда плейбук запускается против группы `vault_cluster`. При запуске против другой группы переменные необходимо передавать явно через `-e @inventory/group_vars/vault_cluster/all.yaml`.

```
group_vars/
├── all.yaml               # Общие переменные: Vault, Consul, Nginx, HAProxy, Molecule/AWS
├── vault_cluster/
│   └── all.yaml           # Переменные кластера Vault: Storage Backend, TLS, Transit, сертификаты
├── consul_cluster/
│   └── all.yaml           # Переменные кластера Consul: datacenter, TLS, сертификаты
└── consul_agent/
    └── all.yaml           # Переменные Consul-агента: retry_join, TLS
```

---

## Список переменных:

В таблицах ниже перечислены все переменные из `group_vars/`. Значения взяты из файлов как есть – они представляют собой рабочие значения по умолчанию или примеры-заглушки. Колонка **По умолчанию** отвечает на вопрос: **задействована ли переменная при запуске роли без дополнительной настройки?**

- **Да**: Переменная активна при стандартном запуске (например, **Raft** включён по умолчанию – `global_vault_cluster_enable_raft: true`).

- **Нет**: Переменная задействуется только при явном включении соответствующей функции (например, Transit Auto-Unseal, TLS, кластерный режим Proxy).

Примечание: Ниже представлен список всех переменных, которые разбиты на смысловые подкатегории.

---

### Подготовка системы:

Все переменные данного блока отвечают за предварительную подготовку системы перед запуском основных ролей.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_system_prepare_update_packages` | `false` | Нет | Опция дополнительно обновляет пакеты на узлах при запуске роли `system-prepare` |

### Базовые параметры Vault:

Все переменные данного блока отвечают за базовую установку и настройку Vault. Такие вещи как версия, адрес и порт, на котором Vault будет слушать, а также настройки времени жизни токенов и lease.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_vault_current_version` | `1.21.1` | Да | Опция определяет текущую версию Vault для установки |
| `global_vault_file_archive_checksum` | `sha256:...` | Да | Опция определяет контрольную сумму архива Vault. Должна соответствовать указанной версии |
| `global_vault_host_listening_address` | `0.0.0.0` | Да | Опция определяет адрес, на котором Vault слушает входящие соединения |
| `global_vault_host_listening_port` | `8200` | Да | Опция определяет порт Vault API |
| `global_vault_lease_default_value` | `24h` | Да | Опция определяет время жизни токена по умолчанию |
| `global_vault_lease_max_value` | `768h` | Да | Опция определяет максимальное время жизни токена |

### Vault Transit Auto-Unseal:

Все переменные данного блока отвечают за автоматическое распечатывание Vault посредством такого механизма, как Transit Auto-Unseal. Все переменные из таблицы задействуются только при наличии параметра `true` в переменной `global_vault_transit_backend_enable`. В противном случае (как это установлено по умолчанию) весь список переменных игнорируется.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_vault_transit_backend_enable` | `false` | Нет | Опция включает режим работы Transit Auto-Unseal |
| `global_vault_transit_backend_unseal_host` | `""` | Нет | Опция определяет адрес Transit-сервера Vault |
| `global_vault_transit_backend_host_port` | `8200` | Нет | Опция определяет порт Transit-сервера (установите 443 если сервер за прокси с SSL) |
| `global_vault_transit_backend_token` | `""` | Нет | Опция определяет токен для аутентификации на Transit-сервере |
| `global_vault_transit_backend_key_name` | `autounseal` | Нет | Опция определяет имя ключа Transit, используемого для распечатывания |
| `global_vault_transit_backend_mount_path` | `transit-backend-01/` | Нет | Опция определяет путь монтирования Transit Secrets Engine |
| `global_vault_transit_backend_disable_renewal` | `false` | Нет | Опция отключает автоматическое обновление токена Transit |
| `global_vault_transit_backend_tls_skip_verify` | `true` | Нет | Опция пропускает проверку TLS-сертификата Transit-сервера (если был настроен SSL на сервере) |

### Инициализация и распечатывание Vault:

Все переменные данного блока отвечают за автоматическую инициализацию и распечатывание Vault, которые используются ролями `system-unseal-*`. Поддерживают распечатывание как Standalone, так и Cluster режима. Можно определить количество ключей Shamir и настройку TLS для обращения к API.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_vault_unseal_secret_shares` | `5` | Да | Опция определяет общее количество ключей Shamir при инициализации |
| `global_vault_unseal_secret_threshold` | `3` | Да | Опция определяет минимальное количество ключей для распечатывания |
| `global_vault_unseal_tls_skip_verify` | `true` | Да | Опция пропускает проверку TLS при обращении к Vault API |
| `global_vault_unseal_tls_disable` | `true` | Да | Опция отключает TLS при обращении к Vault API. Параметр `true` когда кластер работает между собой по HTTP, `false` – когда по HTTPS |

### Базовые параметры Consul:

Все переменные данного блока отвечают за базовые параметры установки Consul. Такие вещи как версия, адрес и порты, на которых Consul слушает (DNS, HTTP, HTTPS).

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_consul_cluster_inventory_group` | `consul_cluster` | Да | Опция определяет имя группы инвентори с узлами кластера Consul. Используется при Vault → Consul backend и в роли агента в HTTPS-режиме |
| `global_consul_current_version` | `1.22.1` | Да | Опция определяет версию Consul для установки |
| `global_consul_file_archive_checksum` | `sha256:...` | Да | Опция определяет контрольную сумму архива Consul. Должна соответствовать указанной версии |
| `global_consul_host_listening_address` | `0.0.0.0` | Да | Опция определяет адрес, на котором Consul слушает входящие соединения |
| `global_consul_host_listening_dns_port` | `8600` | Да | Опция определяет порт DNS-интерфейса Consul |
| `global_consul_host_listening_http_port` | `8500` | Да | Опция определяет порт HTTP API Consul |
| `global_consul_host_listening_https_port` | `8443` | Нет | Опция определяет порт HTTPS API Consul. Задействуется только при наличии параметра `true` в переменной `global_consul_cluster_enable_https` |

### Nginx в качестве Reverse Proxy:

Все переменные данного блока отвечают за конфигурирование Nginx в качестве Reverse Proxy. Работает как для одиночного сервера, так и для кластера. Параметры поддерживают схему соединения на каждом из уровней (клиент → Nginx → Vault), домен, SSL-сертификат через Certbot и опциональный режим балансировки для кластера Vault.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_nginx_enable_certbot_certificates` | `false` | Нет | Опция активирует получение SSL-сертификата через Certbot |
| `global_nginx_enable_certbot_certificates_email_address` | `rurik@kitezh.slavic` | Нет | Опция определяет email для регистрации сертификата в Let's Encrypt. Задействуется только при включённом Certbot |
| `global_nginx_enable_certbot_certificates_command` | `certbot certonly ...` | Нет | Опция активирует команду запуска Certbot. Формируется автоматически из других переменных |
| `global_nginx_host_domain` | `molecule.local.vault` | Да | Опция представляет собой заглушку домена для тестов Molecule. В реальном развертывании задаётся на уровне хоста в `servers.yaml` |
| `global_nginx_set_http_scheme` | `http` | Да | Опция определяет схему соединения уровня Client → Nginx. Устанавливать `http` для обращения к Proxy по 80 порту, в противном случае использовать `https` |
| `global_nginx_set_proxy_pass_scheme` | `http` | Да | Опция определяет схему соединения уровня Nginx → Vault. Устанавливать `http` если Vault работает между собой без TLS, в противном случае – `https` |
| `global_nginx_set_cluster_vault_config` | `false` | Нет | Опция включает конфигурацию Nginx для кластера Vault вместо одиночного сервера |
| `global_nginx_set_cluster_vault_addresses` | `[10.0.0.1, ...]` | Нет | Опция определяет список IP-адресов нод кластера Vault. Задействуется только в случае значения `true` для переменной `global_nginx_set_cluster_vault_config` |
| `global_nginx_set_cluster_vault_weight` | `[10, 5, 3]` | Нет | Опция определяет веса нод кластера при балансировке. Количество должно совпадать с количеством адресов |

### HAProxy в качестве Reverse Proxy:

Все переменные данного блока отвечают за конфигурирование HAProxy в качестве Reverse Proxy. Работает как для одиночного сервера, так и для кластера. Параметры поддерживают схему соединения на каждом из уровней (клиент → HAProxy → Vault), домен, SSL-сертификат через Certbot и опциональный режим балансировки для кластера Vault.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_haproxy_enable_certbot_certificates` | `false` | Нет | Опция активирует получение SSL-сертификата через Certbot |
| `global_haproxy_enable_certbot_certificates_email_address` | `rurik@kitezh.slavic` | Нет | Опция определяет email для регистрации сертификата в Let's Encrypt. Задействуется только при включённом Certbot |
| `global_haproxy_enable_certbot_certificates_command` | `certbot certonly ...` | Нет | Опция активирует команду запуска Certbot. Формируется автоматически из других переменных |
| `global_haproxy_host_domain` | `molecule.local.vault` | Нет | Опция представляет собой заглушку домена для тестов Molecule. В реальном развертывании задаётся на уровне хоста в `servers.yaml` |
| `global_haproxy_set_http_scheme` | `http` | Да | Опция определяет схему соединения уровня Client → HAProxy. Устанавливать `http` для обращения к Proxy по 80 порту, в противном случае использовать `https` |
| `global_haproxy_set_proxy_pass_scheme` | `http` | Да | Опция определяет схему соединения уровня HAProxy → Vault. Устанавливать `http` если Vault работает между собой без TLS, в противном случае – `https` |
| `global_haproxy_set_cluster_vault_config` | `false` | Нет | Опция включает конфигурацию HAProxy для кластера Vault вместо одиночного сервера |
| `global_haproxy_set_cluster_vault_addresses` | `[10.0.0.1, ...]` | Нет | Опция определяет список IP-адресов узлов кластера Vault. Задействуется только в случае значения `true` для переменной `global_haproxy_set_cluster_vault_config` |

---

### Продвинутые параметры для настройки кластера Vault:

Все переменные данного блока отвечают за продвинутую установку и настройку Vault. Такие вещи как конфигурация кластера, выбор Storage Backend (Raft или Consul), режим TLS и Transit Auto-Unseal, помимо ранее упомянутых базовых переменных. Расположение всех переменных из данной секции можно найти в файле `group_vars/vault_cluster/all.yaml`.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_vault_cluster_inventory_group` | `vault_cluster` | Да | Опция определяет имя группы инвентори с узлами кластера. Используется в шаблонах для формирования блока `retry_join` |
| `global_vault_cluster_name` | `vault` | Да | Опция определяет имя кластера Vault в конфигурации |
| `global_vault_cluster_port` | `8201` | Да | Опция определяет порт для межнодовой коммуникации в рамках работы кластера Vault |
| `global_vault_cluster_http_config` | `vault_cluster_http_config.hcl.j2` | Да | Опция определяет шаблон конфигурации для межнодовой коммуникации по HTTP |
| `global_vault_cluster_https_config` | `vault_cluster_https_config.hcl.j2` | Нет | Опция определяет шаблон для межнодовой коммуникации по HTTPS. Задействуется только при значении `true` в переменной `global_vault_cluster_enable_https` |
| `global_vault_cluster_enable_https` | `false` | Нет | Опция включает поддержку TLS для Vault API и межнодовой коммуникации в рамках работы кластера Vault |
| `global_vault_cluster_enable_transit` | `false` | Нет | Опция включает поддержку Transit Auto-Unseal в рамках работы кластера Vault |
| `global_vault_cluster_enable_raft` | `true` | Да | Опция включает поддержку Raft в качестве Storage Backend для работы кластера Vault |
| `global_vault_cluster_enable_consul` | `false` | Нет | Опция включает поддержку Consul в качестве Storage Backend для работы кластера Vault |
| `global_vault_cluster_enable_consul_https` | `false` | Нет | Опция включает поддержку TLS для взаимодействия между кластером Vault и Consul. Задействуется только в случае значения `true` для переменной `global_vault_cluster_enable_consul` |
| `global_vault_cluster_enable_consul_path` | `vault/` | Нет | Опция определяет путь в KV Consul для хранения данных Vault |
| `global_vault_cluster_enable_consul_client` | `127.0.0.1` | Нет | Опция определяет адрес агента Consul для подключения Vault |


Примечание: Переменные блока `global_system_internal_*` управляют созданием внутреннего CA и выпуском самоподписных сертификатов для узлов кластера. Задействуются только при наличии `true` в переменной `global_vault_cluster_enable_https`. Определяют пути хранения CA и сертификатов на сервере, параметры ключа (тип RSA, размер 4096 бит), поля CSR (страна, CN, организация, email) и SAN DNS-имена. Значения по умолчанию рабочие и не требуют изменений для базового развертывания.

### Продвинутые параметры для настройки кластера Consul:

Все переменные данного блока отвечают за продвинутую установку и настройку Consul. Такие вещи как конфигурация кластера, имя датацентра, шаблон конфигурации сервера и настройки TLS для межнодовой коммуникации, помимо ранее упомянутых базовых переменных. Расположение всех переменных из данной секции можно найти в файле `group_vars/consul_cluster/all.yaml`.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_consul_cluster_inventory_group` | `consul_cluster` | Да | Опция определяет имя группы инвентори с нодами кластера. Используется для формирования `retry_join` и `bootstrap_expect` |
| `global_consul_cluster_dc_name` | `dc1` | Да | Опция определяет имя датацентра Consul |
| `global_consul_cluster_server_config` | `consul_server_config.hcl.j2` | Да | Опция определяет шаблон конфигурации сервера Consul |
| `global_consul_cluster_enable_https` | `false` | Нет | Опция включает поддержку TLS для Consul API и межнодовой коммуникации |
| `global_consul_cluster_enable_tls_incoming` | `true` | Нет | Опция включает проверку входящего TLS-соединения. Задействуется только при наличии `true` в переменной `global_consul_cluster_enable_https` |
| `global_consul_cluster_enable_tls_outgoing` | `true` | Нет | Опция включает проверку исходящего TLS-соединения. Задействуется только при наличии `true` в переменной `global_consul_cluster_enable_https` |
| `global_consul_cluster_enable_tls_server_hostname` | `true` | Нет | Опция включает проверку hostname сервера в TLS. Задействуется только при наличии `true` в переменной `global_consul_cluster_enable_https` |

Примечание: Аналогично блоку сертификатов Vault переменные `global_system_internal_*` управляют созданием CA и выпуском сертификатов для узлов кластера Consul. Задействуются только при наличии `true` в переменной `global_consul_cluster_enable_https`. Отличаются от варианта с Vault путями хранения (`/opt/consul/tls/`), именем группы-владельца (`consul`) и SAN DNS-именами, включающими записи вида `*.dc1.consul` и `server.dc1.consul`.

### Базовые параметры для настройки Agent Consul:

Все переменные данного блока отвечают за установку и настройку Consul в режиме агента. Такие вещи как адреса для подключения к кластеру Consul, имя датацентра и настройка TLS для соединения агента с кластером, помимо ранее упомянутых базовых переменных для Consul. Расположение всех переменных из данной секции можно найти в файле `group_vars/consul_agent/all.yaml`.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `global_consul_cluster_inventory_group` | `consul_cluster` | Нет | Опция определяет имя группы инвентори кластера Consul. Используется исключительно в HTTPS-режиме для получения CA-сертификата с узлов кластера. В HTTP-режиме (по умолчанию) не задействуется |
| `global_consul_manual_agent_config` | `consul_agent_config.hcl.j2` | Да | Опция определяет шаблон конфигурации агента Consul |
| `global_consul_manual_agent_data_center` | `dc1` | Да | Опция определяет имя датацентра. Должно совпадать со значением кластера Consul |
| `global_consul_manual_agent_retry_join` | `[172.31.x.x, ...]` | Да | Опция определяет список IP-адресов узлов кластера Consul для подключения агента. Необходимо заменить на реальные адреса узлов |
| `global_consul_manual_agent_enable_https` | `false` | Нет | Опция включает поддержку TLS для соединения агента с кластером Consul |
| `global_consul_manual_agent_enable_tls_incoming` | `true` | Нет | Опция включает проверку входящего TLS-соединения. Задействуется только при наличии `true` в переменной `global_consul_manual_agent_enable_https` |
| `global_consul_manual_agent_enable_tls_outgoing` | `true` | Нет | Опция включает проверку исходящего TLS-соединения. Задействуется только при наличии `true` в переменной `global_consul_manual_agent_enable_https` |
| `global_consul_manual_agent_enable_tls_server_hostname` | `true` | Нет | Опция включает проверку hostname сервера в TLS. Задействуется только при наличии `true` в переменной `global_consul_manual_agent_enable_https` |

### Переменные для тестов в AWS с помощью Molecule:

Переменные данного блока используются исключительно для запуска тестов Molecule с драйвером EC2. На реальное развертывание не влияют.

| Переменная | Значение | По умолчанию | Описание |
|---|---|:---:|---|
| `aws_profile` | `default` | Нет | Опция определяет имя профиля для взаимодействия с AWS через CLI |
| `aws_region` | `eu-central-1` | Нет | Опция определяет регион AWS для запуска тестовых инстансов |
| `aws_instance_type` | `t3a.small` | Нет | Опция определяет тип EC2-инстанса для тестов |
| `aws_vpc_subnet_id` | `""` | Нет | Опция определяет ID подсети VPC. При пустом значении создаётся эфемерная сеть |
| `aws_vpc_id` | `vpc-cef0f9a7` | Нет | Опция определяет ID VPC. При пустом значении создаётся эфемерная сеть |
| `aws_key_method` | `ec2` | Нет | Опция определяет метод создания SSH-ключей: `ec2` или `cloud-init` |
| `aws_default_ssh_user` | `ubuntu` | Нет | Опция определяет SSH-пользователя для подключения к тестовым EC2-инстансам |
| `aws_local_private_key` | `~/cosmos.pem` | Нет | Опция определяет путь к приватному SSH-ключу для подключения к EC2 |
| `aws_local_public_key` | `""` | Нет | Опция определяет путь к публичному SSH-ключу. При пустом значении ключ генерируется автоматически |
| `aws_custom_key_name` | `""` | Нет | Опция определяет имя ключа в EC2 Key Pairs. При пустом значении генерируется с префиксом `molecule-` |
| `aws_security_group_name` | `""` | Нет | Опция определяет имя существующей Security Group. При пустом значении создаётся новая с префиксом `molecule-` |
