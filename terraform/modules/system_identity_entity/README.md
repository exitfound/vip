# **Модуль: system_identity_entity**

**Модуль system_identity_entity** – создаёт Identity Entity в Vault и привязывает к ней aliases из разных auth-методов. Entity – это единая идентичность пользователя или сервиса в Vault, независимая от способа аутентификации. Позволяет одному субъекту логиниться через несколько auth-методов, накапливать metadata и входить в группы.

---

## **Как работает**

Когда пользователь логинится через любой auth-метод, Vault ищет alias с соответствующим именем в рамках этого auth backend. Если alias найден – логин ассоциируется с entity, к которой он привязан. Токен получает идентификатор entity и наследует все её свойства: metadata, политики, членство в группах.

Alias – это «маска» entity в конкретном auth-методе. Для Userpass это `username`, для AppRole – `role_id`, для LDAP – DN пользователя. Один субъект может иметь несколько aliases в разных auth-методах – все они ведут к одной entity. Это позволяет:
- Одному пользователю логиниться через разные методы и оставаться одной entity
- Добавлять metadata на уровне entity (`team`, `env`) и использовать их в OIDC token templates
- Включать entity в группы, которые наследуют политики

При `disabled = true` все токены с этой entity немедленно отклоняются вне зависимости от метода аутентификации – пользователь не может войти ни через один auth-метод до снятия блокировки.

---

## **Параметры модуля**

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `name` | `string` | – | Имя entity (обязательный) |
| `policies` | `list(string)` | `[]` | Политики напрямую на entity. Предпочтительнее назначать через группы |
| `metadata` | `map(string)` | `{}` | Метаданные entity. Например: `{ team = "ops", env = "prod" }` |
| `disabled` | `bool` | `false` | Отключить entity – все токены с этой entity будут отклонены |
| `aliases` | `list(object)` | `[]` | Список aliases: `name` = имя в auth backend, `mount_accessor` = accessor backend |

### Структура объекта в переменной `aliases`

| Поле | Тип | Описание |
|---|---|---|
| `name` | `string` | Имя субъекта в конкретном auth backend (username, role_id и т.д.) |
| `mount_accessor` | `string` | Accessor auth backend – получается из output модуля auth-метода или через `data "vault_auth_backend"` |

---

## **Получить accessor auth backend**

Accessor необходим для создания alias и передаётся в поле `mount_accessor`. Получить его можно через output модуля auth-метода или через data source:

```hcl
# Через output модуля auth_userpass
module.auth_userpass.accessor

# Через data source (если backend создаётся не через Terraform)
data "vault_auth_backend" "userpass" {
  path = "userpass"
}
# data.vault_auth_backend.userpass.accessor
```

---

## **Примеры вызова модуля**

### Простой вариант: entity без aliases

Минимальный пример – entity без привязки к auth-методу (заглушка для будущего использования):

```hcl
module "entity_demo" {
  source   = "../../../modules/system_identity_entity"

  name     = "demo-entity"
  metadata = { env = "demo" }
  disabled = false
  aliases  = []
}
```

---

### Полный вариант: пользователь с alias на Userpass

Рекомендуемый подход – entity создаётся вместе с alias, указывающим на конкретный auth backend:

```hcl
module "auth_userpass" {
  source = "../../../modules/auth_userpass"

  path  = "userpass"
  users = [
    {
      username          = "alice"
      token_policies    = ["ops-policy"]
      token_ttl         = 3600
      token_max_ttl     = 28800
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
  ]
}

module "entity_alice" {
  source = "../../../modules/system_identity_entity"

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

---

### Вариант: пользователь с двумя auth-методами

Entity с aliases на два разных backend – пользователь может логиниться через любой из них:

```hcl
module "entity_alice" {
  source = "../../../modules/system_identity_entity"

  name     = "alice"
  metadata = { team = "ops" }

  aliases = [
    {
      name           = "alice"
      mount_accessor = module.auth_userpass.accessor
    },
    {
      name           = "alice-approle"
      mount_accessor = module.auth_approle.accessor
    },
  ]
}
```

---

### Вариант: отключить пользователя

```hcl
module "entity_alice" {
  source = "../../../modules/system_identity_entity"

  name     = "alice"
  metadata = { team = "ops" }
  disabled = true
  aliases  = []
}
```

При `disabled = true` все токены с этой entity отклоняются – пользователь не может логиниться ни через один auth-метод до явного снятия блокировки.

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `entity_id` | `string` | ID созданной entity – используется при добавлении в группу через `member_entity_ids` |
| `entity_name` | `string` | Имя entity |
| `alias_ids` | `map(string)` | Карта `alias_name → alias_id` для всех созданных aliases |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output entity_id
terragrunt output entity_name
terragrunt output -json alias_ids
```

---

## **После apply**

После успешного применения конфигурации проверить состояние entity можно с помощью следующих команд:

```bash
# Посмотреть entity по имени
vault read identity/entity/name/alice

# Посмотреть entity по ID
vault read identity/entity/id/<entity_id>

# Список всех entities
vault list identity/entity/name

# Посмотреть все aliases
vault list identity/entity-alias/id

# Добавить metadata вручную (без Terraform)
vault write identity/entity/name/alice metadata="team=ops" metadata="env=prod"

# Временно заблокировать пользователя без пересоздания
vault write identity/entity/name/alice disabled=true

# Проверить к какой entity привязан текущий токен
vault token lookup  # поле entity_id → vault read identity/entity/id/<id>
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
