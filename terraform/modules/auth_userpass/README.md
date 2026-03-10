# **Модуль: auth_userpass**

**Модуль auth_userpass** – включает метод аутентификации Userpass в Vault и создаёт пользователей с настраиваемыми параметрами токена. Предназначен для операторов, администраторов и разработчиков, которые логинятся в Vault интерактивно через CLI, UI или скрипты. В отличие от AppRole и JWT, Userpass ориентирован на аутентификацию людей, а не сервисов.

---

## **Как работает**

Terraform управляет только конфигурацией пользователей: политиками, TTL токена и прочими параметрами. Пароли управляются отдельно: при первом `apply` Terraform генерирует начальный пароль через ресурс `random_password` и возвращает его в sensitive output. Пользователь читает этот пароль один раз и сразу меняет на свой через `vault write auth/<path>/users/<username>/password`. После этого Terraform больше не трогает пароль – `ignore_changes` на соответствующем ресурсе гарантирует это.

Каждый пользователь описывается как объект в списке переменной `users`, что позволяет управлять произвольным числом пользователей через один вызов модуля.

---

## **Параметры модуля**

### Backend

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `path` | `string` | `"userpass"` | Путь монтирования Userpass auth backend |
| `description` | `string` | `""` | Описание backend |

### Пользователи

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `users` | `list(object)` | – | Список конфигураций пользователей (обязательный) |

### Структура объекта в переменной `users`

| Поле | Тип | Описание |
|---|---|---|
| `username` | `string` | Имя пользователя |
| `token_policies` | `list(string)` | Политики Vault для выдаваемых токенов |
| `token_ttl` | `number` | TTL токена в секундах (0 = Vault default) |
| `token_max_ttl` | `number` | Максимальный TTL токена в секундах (0 = Vault default) |
| `token_type` | `string` | Тип токена: `default`, `service`, `batch` |
| `token_num_uses` | `number` | Число использований токена (0 = без ограничений) |
| `token_bound_cidrs` | `list(string)` | CIDR ограничения для токена ([] = без ограничений) |

---

## **Примеры вызова модуля**

### Простой вариант

Минимальный пример с одним пользователем и прямым указанием политики:

```hcl
module "auth_userpass" {
  source = "../../../modules/auth_userpass"

  path = "userpass"

  users = [
    {
      username          = "demo-user"
      token_policies    = ["default"]
      token_ttl         = 3600
      token_max_ttl     = 28800
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
  ]
}
```

---

### Полный вариант: несколько пользователей со связкой через vault_custom_policy

Рекомендуемый подход – политика создаётся отдельным модулем и передаётся через output:

```hcl
module "policy_ops" {
  source = "../../../modules/vault_custom_policy"

  name = "ops-policy"
  rules = [
    { path = "secret/data/ops/*",      capabilities = ["read", "list"] },
    { path = "secret/metadata/ops/*",  capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
    { path = "auth/token/renew-self",  capabilities = ["update"] },
  ]
}

module "auth_userpass" {
  source = "../../../modules/auth_userpass"

  path = "userpass"

  users = [
    {
      username          = "alice"
      token_policies    = [module.policy_ops.policy_name]
      token_ttl         = 3600
      token_max_ttl     = 28800  # 8h – рабочий день
      token_type        = "default"
      token_num_uses    = 0
      token_bound_cidrs = []
    },
    {
      username          = "bob"
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

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `mount_path` | `string` | Путь монтирования Userpass auth backend |
| `accessor` | `string` | Accessor backend – используется при создании alias в `system_identity_entity` |
| `usernames` | `list(string)` | Список имён созданных пользователей |
| `initial_passwords` | `map(string)` (sensitive) | Начальные пароли по имени пользователя – прочитать один раз и сменить |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output mount_path
terragrunt output accessor
terragrunt output -json initial_passwords | jq -r '.alice'
```

---

## **После apply**

После успешного применения конфигурации необходимо прочитать начальный пароль и сменить его:

```bash
# Получить начальный пароль пользователя
terragrunt output -json initial_passwords | jq -r '.alice'

# Сменить пароль на свой (пользователь выполняет сам)
vault write auth/userpass/users/alice/password password="my-new-password"

# Проверить логин
vault login -method=userpass \
  -path=userpass \
  username=alice \
  password="my-new-password"

# Список всех пользователей
vault list auth/userpass/users

# Проверить конфигурацию пользователя
vault read auth/userpass/users/alice
```

---

## **Жизненный цикл токена**

```
Оператор                              Vault
    │                                   │
    │── username + password ────────────>│  логин
    │<── token (TTL=1h) ────────────────│
    │                                   │
    │  ... работает ...                 │
    │                                   │
    │── POST /auth/token/renew-self ───>│  продление (до token_max_ttl)
    │<── TTL сброшен до 1h ────────────│
    │                                   │
    │  ... token_max_ttl=8h исчёрпан ..│
    │                                   │
    │── username + password ────────────>│  повторный логин
    │<── новый token ───────────────────│
```

Для операторов рекомендуется всегда использовать `token_type = "default"` или `"service"` – они поддерживают продление токена. Тип `batch` не подходит для интерактивных пользователей, так как не поддерживает renewal.

---

## **Смена пароля**

Смена пароля происходит исключительно через Vault CLI и никак не затрагивает Terraform:

```bash
vault write auth/userpass/users/alice/password password="new-password"
```

Повторный запуск `terragrunt apply` не перезапишет пароль, так как `ignore_changes` на ресурс пароля гарантирует его неизменность со стороны Terraform.

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
