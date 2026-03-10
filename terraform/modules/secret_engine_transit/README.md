# **Модуль: secret_engine_transit**

**Модуль secret_engine_transit** – создаёт Transit secrets engine в Vault, ключ шифрования и токен с правами на операции encrypt/decrypt. Основное назначение – Transit Auto-Unseal: Vault-кластер или одиночный Vault-сервер использует этот токен для автоматического распечатывания через Transit-сервер при каждом перезапуске, без ручного ввода ключей. Политику для токена модуль принимает как входной параметр – она создаётся отдельно через `vault_custom_policy`.

---

## **Как работает**

Transit Engine позволяет шифровать и дешифровать данные, не раскрывая сам ключ. При Transit Auto-Unseal основной Vault хранит свои ключи распечатывания в зашифрованном виде. При каждом перезапуске он отправляет зашифрованные данные Transit-серверу, получает расшифрованный ключ и самостоятельно распечатывается. Для этого основному Vault нужен токен с правами на `encrypt` и `decrypt` для конкретного ключа Transit Engine.

Модуль создаёт три ресурса: mount Transit Engine, ключ шифрования и токен с заданной политикой. Токен является **sensitive output** – его необходимо прочитать после `apply` и передать в конфигурацию целевого Vault через переменную `global_vault_transit_backend_token` в рамках Ansible-роли `manual-single-vault` или `manual-cluster-vault`.

---

## **Параметры модуля**

### Transit mount

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `path` | `string` | `"transit"` | Путь монтирования Transit secrets engine |
| `default_lease_ttl_seconds` | `number` | `3600` | TTL lease по умолчанию (секунды) |
| `max_lease_ttl_seconds` | `number` | `31536000` | Максимальный TTL lease (секунды) – должен быть >= `period` токена |

### Transit key

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `name` | `string` | `"autounseal"` | Имя ключа – используется как часть пути в политике |
| `auto_rotate_period` | `number` | `0` | Автоматическая ротация ключа в секундах. 0 = выключено |
| `allow_plaintext_backup` | `bool` | `false` | Разрешить plaintext экспорт ключа (необходимо при миграции) |
| `deletion_allowed` | `bool` | `false` | Разрешить удаление ключа через API |
| `exportable` | `bool` | `false` | Разрешить экспорт ключевого материала |

### Токен

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `policy_name` | `string` | – | Имя Vault политики для токена – создаётся через `vault_custom_policy` (обязательный) |
| `period` | `string` | `"8760h"` | Период обновления periodic токена (1 год) |
| `renewable` | `bool` | `true` | Разрешить ручное обновление через `vault token renew` |
| `no_default_policy` | `bool` | `true` | Исключить политику `default` из токена |
| `no_parent` | `bool` | `true` | Orphan токен – не привязан к сессии Terraform |
| `explicit_max_ttl` | `string` | `""` | Абсолютный потолок жизни токена. Пусто = без потолка |

---

## **Режимы работы токена**

Модуль поддерживает **3 режима** в зависимости от комбинации переменных `period`, `renewable` и `explicit_max_ttl`:

```hcl
# Режим 1: Periodic токен (рекомендуется для Production auto-unseal)
# Таймер сбрасывается при каждом использовании. Vault использует токен
# только при unseal, поэтому period должен быть с заметным запасом.
period           = "8760h"  # 1 год
renewable        = true
explicit_max_ttl = ""       # без абсолютного потолка

# Режим 2: Periodic токен с принудительной ротацией
# Токен обновляется автоматически, но не переживёт explicit_max_ttl.
# После истечения необходимо пересоздать токен через terraform apply.
period           = "168h"
renewable        = true
explicit_max_ttl = "8760h"  # принудительная ротация раз в год

# Режим 3: Разовый нецикличный токен (для тестов и dev)
period           = ""
renewable        = false
explicit_max_ttl = "24h"
```

---

## **Примеры вызова модуля**

### Простой вариант: Production auto-unseal

Сначала создаётся политика, затем передаётся в модуль:

```hcl
module "policy_transit" {
  source = "../../../modules/vault_custom_policy"

  name = "autounseal-policy"
  rules = [
    { path = "auth/token/lookup-self",                    capabilities = ["read"] },
    { path = "transit-autounseal/encrypt/autounseal",     capabilities = ["update"] },
    { path = "transit-autounseal/decrypt/autounseal",     capabilities = ["update"] },
  ]
}

module "transit" {
  source = "../../../modules/secret_engine_transit"

  name                  = "autounseal"
  path                  = "transit-autounseal"
  policy_name           = module.policy_transit.policy_name
  period                = "8760h"
  renewable             = true
  no_default_policy     = true
  no_parent             = true
  explicit_max_ttl      = ""
  max_lease_ttl_seconds = 31536000
}
```

---

### Полный вариант: Production с ротацией ключа

```hcl
module "policy_transit" {
  source = "../../../modules/vault_custom_policy"

  name = "autounseal-policy"
  rules = [
    { path = "auth/token/lookup-self",                    capabilities = ["read"] },
    { path = "transit-autounseal/encrypt/autounseal",     capabilities = ["update"] },
    { path = "transit-autounseal/decrypt/autounseal",     capabilities = ["update"] },
  ]
}

module "transit" {
  source = "../../../modules/secret_engine_transit"

  name                   = "autounseal"
  path                   = "transit-autounseal"
  policy_name            = module.policy_transit.policy_name
  period                 = "8760h"
  renewable              = true
  no_default_policy      = true
  no_parent              = true
  explicit_max_ttl       = ""
  max_lease_ttl_seconds  = 31536000
  auto_rotate_period     = 7776000   # ротация ключа раз в 90 дней
  allow_plaintext_backup = false
  deletion_allowed       = false
  exportable             = false
}
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `transit_token_value` | `string` (sensitive) | Токен с правами encrypt/decrypt – передаётся в конфигурацию целевого Vault |
| `transit_policy_name` | `string` | Имя Vault политики, прикреплённой к токену |
| `transit_mount_path` | `string` | Путь монтирования Transit secrets engine |
| `transit_key_name` | `string` | Имя Transit ключа шифрования |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output -raw transit_token_value
terragrunt output transit_mount_path
terragrunt output transit_key_name
```

---

## **После apply**

После успешного применения конфигурации необходимо получить токен и проверить его:

```bash
# Получить токен (sensitive)
terragrunt output -raw transit_token_value

# Проверить информацию о токене
vault token lookup <token>

# Проверить права токена на Transit путь
vault token capabilities <token> transit-autounseal/encrypt/autounseal

# Проверить список ключей Transit Engine
vault list transit-autounseal/keys

# Проверить конфигурацию ключа
vault read transit-autounseal/keys/autounseal
```

---

## **Важно**

`no_parent = true` является **обязательным** для токенов Auto-Unseal. Без него токен является дочерним по отношению к сессии Terraform. При смене root-токена или перезапуске Transit-сервера дочерний токен автоматически отзывается – целевой Vault потеряет возможность распечатываться.

`max_lease_ttl_seconds` на mount должен быть строго **не меньше** значения `period` токена в секундах. В противном случае Vault молча урежет `period` до значения `max_lease_ttl_seconds`, что может привести к более частому истечению токена, чем ожидалось.

```
period = "8760h" = 31 536 000 секунд
max_lease_ttl_seconds >= 31 536 000
```

После ротации ключа (`auto_rotate_period`) старые версии ключа **сохраняются** – Vault по-прежнему может расшифровывать данные, зашифрованные предыдущими версиями. Новые шифрования используют текущую версию ключа.

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
