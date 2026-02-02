# Ansible Inventory

Директория содержит два формата inventory файлов с идентичной структурой.

## Файлы

| Файл | Формат | Описание |
|------|--------|----------|
| `servers` | INI | Классический формат Ansible inventory |
| `servers.yaml` | YAML | Современный формат с лучшей читаемостью |

## Использование

### INI формат

```bash
ansible-playbook -i hosts/servers playbook.yml
ansible -i hosts/servers all -m ping
```

### YAML формат

```bash
ansible-playbook -i hosts/servers.yaml playbook.yml
ansible -i hosts/servers.yaml all -m ping
```

## Структура групп

```
all
├── vault_cluster        # Vault кластер (3 ноды)
├── consul_agent         # Consul агенты (3 ноды)
├── consul_cluster       # Consul кластер (3 ноды)
├── suse                 # SUSE семейство
│   ├── opensuse15.5
│   ├── opensuse15.6
│   ├── sles15
│   └── sles16
├── redhat               # RedHat семейство
│   ├── centos8
│   ├── centos9
│   ├── redhat8
│   ├── redhat9
│   └── redhat10
├── debian               # Debian семейство
│   ├── debian10
│   ├── debian11
│   └── debian12
└── ubuntu               # Ubuntu семейство
    ├── ubuntu20.04
    ├── ubuntu22.04
    └── ubuntu24.04
```

## Примеры команд

### Запуск на конкретной группе

```bash
# Все SUSE хосты
ansible-playbook -i hosts/servers.yaml -l suse playbook.yml

# Только Ubuntu 24.04
ansible-playbook -i hosts/servers.yaml -l ubuntu24.04 playbook.yml

# Vault кластер
ansible-playbook -i hosts/servers.yaml -l vault_cluster playbook.yml
```

### Проверка inventory

```bash
# Список всех хостов (JSON)
ansible-inventory -i hosts/servers.yaml --list

# Граф групп
ansible-inventory -i hosts/servers.yaml --graph

# Информация о конкретном хосте
ansible-inventory -i hosts/servers.yaml --host vault_cluster1
```

### Ping всех хостов

```bash
ansible -i hosts/servers.yaml all -m ping
```

## Переменные хостов

Некоторые хосты имеют дополнительные переменные:

| Переменная | Описание | Пример |
|------------|----------|--------|
| `ansible_host` | IP адрес или hostname | `35.159.175.77` |
| `ansible_user` | SSH пользователь | `ubuntu` |
| `global_nginx_host_domain` | Домен для Nginx | `u24.kitezh.world` |
| `global_haproxy_host_domain` | Домен для HAProxy | `u24.kitezh.world` |

## Групповые переменные

Групповые переменные хранятся в `group_vars/`:

```
group_vars/
├── all.yaml              # Переменные для всех хостов
├── consul_agent/
│   └── all.yaml          # Переменные для consul_agent группы
└── ...
```
