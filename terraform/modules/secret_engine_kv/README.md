# **Модуль: secret_engine_kv**

**Модуль secret_engine_kv** – создаёт KV v2 secrets engine в Vault и настраивает его параметры. Предназначен для хранения произвольных пар ключ-значение с версионированием. Модуль управляет только точкой монтирования (mount) и её конфигурацией – сам контент секретов заносится пользователями или приложениями через Vault CLI, API или UI.

---

## **Как работает**

KV v2 – это встроенный secrets engine Vault для хранения произвольных секретов с версионированием. Каждая запись сохраняет историю изменений: по умолчанию до 10 версий включительно. Старые версии можно восстановить, а удаление является мягким (soft delete) – данные физически не уничтожаются до момента явного вызова `destroy`.

Рекомендуется создавать отдельный mount для каждого сервиса или команды: `my-app`, `cicd`, `ops`. Это обеспечивает чёткое разграничение доступа на уровне ACL политик – политика для `my-app` ссылается на пути `my-app/data/*` и никогда не пересекается с путями других mount-ов. При обращении к секретам через API путь всегда включает префикс `data/` или `metadata/`, который добавляется автоматически при работе через KV v2 API.

---

## **Параметры модуля**

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `path` | `string` | `"secret"` | Путь монтирования KV engine |
| `description` | `string` | `""` | Описание mount |
| `max_versions` | `number` | `10` | Максимальное количество версий на секрет. 0 = без ограничений |
| `cas_required` | `bool` | `false` | Требовать check-and-set при записи – защита от слепой перезаписи |
| `delete_version_after` | `string` | `""` | Автоматическое удаление версий через заданное время. Например `"720h"`. Пусто = выключено |

---

## **Примеры вызова модуля**

### Простой вариант: один mount с базовыми параметрами

Минимальный пример – mount для одного сервиса:

```hcl
module "kv_my_app" {
  source      = "../../../modules/secret_engine_kv"
  path        = "my-app"
  description = "Secrets for my-app service"
}
```

---

### Полный вариант: несколько изолированных mount-ов

Рекомендуемый подход для Production – отдельный mount на каждый сервис или команду:

```hcl
module "kv_my_app" {
  source       = "../../../modules/secret_engine_kv"
  path         = "my-app"
  description  = "Secrets for my-app service"
  max_versions = 10
}

module "kv_cicd" {
  source               = "../../../modules/secret_engine_kv"
  path                 = "cicd"
  description          = "CI/CD secrets – versions older than 30 days are deleted"
  max_versions         = 5
  delete_version_after = "720h"  # 30 дней
}

module "kv_ops" {
  source       = "../../../modules/secret_engine_kv"
  path         = "ops"
  description  = "Operations secrets – CAS required to prevent concurrent overwrites"
  max_versions = 20
  cas_required = true
}
```

---

## **Структура путей KV v2**

```
<mount>/
├── data/             # реальное хранилище (read/write) – путь в политике: <mount>/data/...
│   └── <key>
├── metadata/         # мета-информация о версиях (list/delete) – путь в политике: <mount>/metadata/...
│   └── <key>
└── delete/           # soft delete конкретных версий – путь в политике: <mount>/delete/...
    └── <key>
```

В ACL политике пути записываются с учётом prefixов `data/` и `metadata/`:

```hcl
{ path = "my-app/data/*",     capabilities = ["read"] }   # чтение секретов
{ path = "my-app/metadata/*", capabilities = ["list"] }   # листинг ключей
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `mount_path` | `string` | Путь монтирования KV v2 secrets engine |
| `accessor` | `string` | Accessor mount – используется в Sentinel политиках и group alias (Enterprise) |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output mount_path
terragrunt output accessor
```

---

## **После apply**

После успешного применения конфигурации можно начать работу с секретами:

```bash
# Записать секрет
vault kv put my-app/config db_password=s3cr3t api_key=abc123

# Прочитать секрет (последняя версия)
vault kv get my-app/config

# Прочитать конкретную версию
vault kv get -version=2 my-app/config

# Список секретов
vault kv list my-app/

# Удалить версию (soft delete – восстановимо)
vault kv delete -versions=1 my-app/config

# Полностью уничтожить версию (не восстановить)
vault kv destroy -versions=1 my-app/config

# Мета-информация о секрете (все версии)
vault kv metadata get my-app/config
```

При включённом `cas_required = true` запись требует явного указания текущей версии:

```bash
# Первая запись: cas=0
vault kv put -cas=0 ops/credentials db_password=initial

# Обновление: cas=1 (текущая версия)
vault kv put -cas=1 ops/credentials db_password=updated
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
