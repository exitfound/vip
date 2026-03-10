# **Модуль: auth_approle**

**Модуль auth_approle** – включает метод аутентификации AppRole в Vault и создаёт роль с настраиваемыми параметрами токена и `secret_id`. Предназначен для аутентификации сервисов, приложений и демонов, которым необходим программный доступ к Vault без участия человека. В отличие от Userpass, AppRole не требует интерактивного ввода учётных данных.

---

## **Как работает**

Метод аутентификации AppRole основан на двух учётных данных: `role_id` (идентификатор роли, аналог логина) и `secret_id` (секрет, аналог пароля). Приложение предъявляет оба значения Vault и получает токен с заданными политиками, который далее используется для доступа к секретам.

`role_id` является статичным и не меняется на протяжении всей жизни роли. `secret_id` может быть ограничен по числу использований (`secret_id_num_uses`) или времени жизни (`secret_id_ttl`). При значении `secret_id_num_uses = 0` `secret_id` является многоразовым, что позволяет приложению повторно аутентифицироваться после истечения `token_max_ttl` без генерации нового `secret_id`.

`secret_id` намеренно генерируется **вне Terraform** через команду `vault write -f auth/<path>/role/<role_name>/secret-id`, чтобы не попадать в state. Если переменная `generate_secret_id = true` – Terraform сгенерирует `secret_id` самостоятельно и вернёт его в outputs, однако в этом случае значение окажется в state.

---

## **Параметры модуля**

### Backend

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `path` | `string` | `"approle"` | Путь монтирования AppRole auth backend |
| `description` | `string` | `""` | Описание backend |

### Роль

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `role_name` | `string` | – | Имя роли (обязательный) |
| `token_policies` | `list(string)` | – | Политики Vault для выдаваемых токенов (обязательный) |
| `token_ttl` | `number` | `3600` | TTL токена в секундах (3600 = 1h) |
| `token_max_ttl` | `number` | `86400` | Максимальный TTL токена в секундах (86400 = 24h) |
| `token_num_uses` | `number` | `0` | Число использований токена (0 = без ограничений) |
| `token_period` | `number` | `0` | Period для periodic токена в секундах. При ненулевом значении TTL игнорируется. 0 = выключено |
| `token_type` | `string` | `"default"` | Тип токена: `default`, `service`, `batch` |
| `token_bound_cidrs` | `list(string)` | `[]` | CIDR ограничения для использования токена |

### Secret ID

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `bind_secret_id` | `bool` | `true` | Требовать `secret_id` при логине |
| `secret_id_ttl` | `number` | `0` | TTL `secret_id` в секундах. 0 = без истечения |
| `secret_id_num_uses` | `number` | `0` | Число использований `secret_id` (0 = без ограничений) |
| `secret_id_bound_cidrs` | `list(string)` | `[]` | CIDR ограничения для использования `secret_id` |
| `generate_secret_id` | `bool` | `false` | Сгенерировать `secret_id` через Terraform и вернуть в outputs |

---

## **Примеры вызова модуля**

### Простой вариант

Минимальный пример – роль с прямым указанием политики:

```hcl
module "auth_approle" {
  source = "../../../modules/auth_approle"

  role_name      = "my-app"
  token_policies = ["my-app-policy"]
  token_ttl      = 3600
  token_max_ttl  = 86400
}
```

---

### Полный вариант: связка с модулем vault_custom_policy

Рекомендуемый подход – политика создаётся отдельным модулем и передаётся через output:

```hcl
module "policy_my_app" {
  source = "../../../modules/vault_custom_policy"

  name = "my-app-policy"
  rules = [
    { path = "secret/data/my-app/*",     capabilities = ["read"] },
    { path = "secret/metadata/my-app/*", capabilities = ["list"] },
    { path = "auth/token/lookup-self",   capabilities = ["read"] },
    { path = "auth/token/renew-self",    capabilities = ["update"] },
  ]
}

module "auth_approle" {
  source = "../../../modules/auth_approle"

  path           = "approle"
  role_name      = "my-app"
  token_policies = [module.policy_my_app.policy_name]
  token_ttl      = 3600
  token_max_ttl  = 86400
  token_type     = "default"

  bind_secret_id     = true
  secret_id_num_uses = 0
  secret_id_ttl      = 0
  generate_secret_id = false
}
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `role_id` | `string` | Идентификатор роли – используется вместе с `secret_id` для аутентификации |
| `secret_id` | `string` (sensitive) | Сгенерированный `secret_id` – доступен только при `generate_secret_id = true` |
| `secret_id_accessor` | `string` | Accessor для `secret_id` – доступен только при `generate_secret_id = true` |
| `mount_path` | `string` | Путь монтирования AppRole auth backend |
| `role_name` | `string` | Имя созданной роли |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output -raw role_id
terragrunt output -raw secret_id          # только при generate_secret_id = true
terragrunt output -raw secret_id_accessor
terragrunt output mount_path
```

---

## **После apply**

После успешного применения конфигурации рекомендуется сгенерировать `secret_id` вне Terraform и проверить процесс аутентификации:

```bash
# Получить role_id
terragrunt output -raw role_id

# Сгенерировать secret_id вручную (не попадает в state)
vault write -f auth/approle/role/my-app/secret-id

# Выполнить логин с полученными учётными данными
vault write auth/approle/login \
  role_id="<role_id>" \
  secret_id="<secret_id>"

# Список всех AppRole ролей
vault list auth/approle/role

# Проверить конфигурацию роли
vault read auth/approle/role/my-app
```

В командах выше `approle` – это значение переменной `path`. Если задано `path = "my-approle"`, то необходимо заменить `auth/approle/...` на `auth/my-approle/...` во всех командах.

---

## **Жизненный цикл токена**

```
Приложение                              Vault
    │                                     │
    │── role_id + secret_id ─────────────>│  логин
    │<── token (TTL=1h) ─────────────────-│
    │                                     │
    │  ... использует токен ...           │
    │                                     │
    │── POST /auth/token/renew-self ──────>│  продление (до token_max_ttl)
    │<── TTL сброшен до 1h ───────────────│
    │                                     │
    │  ... token_max_ttl=24h исчёрпан ... │
    │                                     │
    │── role_id + secret_id ─────────────>│  повторный логин
    │<── новый token (TTL=1h) ────────────│
```

После истечения `token_max_ttl` продление токена невозможно. Приложение должно выполнить повторный логин с теми же `role_id` и `secret_id`. Именно поэтому рекомендуется устанавливать `secret_id_num_uses = 0` – чтобы `secret_id` оставался действительным для повторного использования на протяжении всего времени работы приложения.

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
