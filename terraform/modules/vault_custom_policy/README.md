# **Модуль: vault_custom_policy**

**Модуль vault_custom_policy** – создаёт произвольную ACL политику Vault из структурированного списка правил, без необходимости писать raw HCL вручную. Политика затем передаётся в auth-методы (AppRole, JWT, Userpass) через параметр `token_policies`, и все токены, выданные этими методами, получают описанные права.

---

## **Как работает**

ACL политика Vault – это набор правил вида «путь → разрешённые операции». Модуль принимает список таких правил в виде Terraform-объектов и генерирует из них HCL строку через `join()`, которая затем применяется к ресурсу `vault_policy`. Политика создаётся один раз и может передаваться в любое количество auth-методов через `token_policies`. Все токены, выданные этими методами, наследуют права из политики.

Vault проверяет права токена при каждом запросе: если у токена нет capability, соответствующего пути и операции – запрос отклоняется с кодом `403`. При наличии нескольких политик на токене права объединяются (union), а не пересекаются.

---

## **Параметры модуля**

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `name` | `string` | – | Имя политики (обязательный) |
| `rules` | `list(object)` | – | Список правил path + capabilities (обязательный) |

### Структура объекта в переменной `rules`

| Поле | Тип | Описание |
|---|---|---|
| `path` | `string` | Vault path, поддерживает glob (`*`, `+`) |
| `capabilities` | `list(string)` | Список разрешений |

### Доступные capabilities

| Capability | Операция | Описание |
|---|---|---|
| `create` | POST/PUT | Создание нового ресурса |
| `read` | GET | Чтение ресурса |
| `update` | POST/PUT | Обновление существующего ресурса |
| `delete` | DELETE | Удаление ресурса |
| `list` | LIST | Перечисление ключей |
| `patch` | PATCH | Частичное обновление |
| `deny` | – | Явный запрет доступа – перекрывает все остальные capability |
| `sudo` | – | Доступ к root-защищённым путям |

---

## **Примеры вызова модуля**

### Простой вариант: политика для приложения

Минимальный пример – политика для приложения с доступом к собственному namespace в KV:

```hcl
module "policy_app" {
  source = "../../../modules/vault_custom_policy"

  name = "my-app-policy"
  rules = [
    { path = "secret/data/my-app/*",     capabilities = ["read"] },
    { path = "secret/metadata/my-app/*", capabilities = ["list"] },
    { path = "auth/token/lookup-self",   capabilities = ["read"] },
    { path = "auth/token/renew-self",    capabilities = ["update"] },
  ]
}
```

Сгенерирует следующий HCL в Vault:

```hcl
path "secret/data/my-app/*" {
  capabilities = ["read"]
}

path "secret/metadata/my-app/*" {
  capabilities = ["list"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
```

---

### Полный вариант: связка с auth-методом

Политика создаётся отдельным модулем и передаётся в AppRole или другой auth-метод через output:

```hcl
module "policy_cicd" {
  source = "../../../modules/vault_custom_policy"

  name = "cicd-policy"
  rules = [
    { path = "cicd/data/*",            capabilities = ["read"] },
    { path = "cicd/metadata/*",        capabilities = ["list"] },
    { path = "auth/token/lookup-self", capabilities = ["read"] },
  ]
}

module "auth_approle" {
  source = "../../../modules/auth_approle"

  role_name      = "ci-runner"
  token_policies = [module.policy_cicd.policy_name]
  token_ttl      = 3600
  token_max_ttl  = 86400
}
```

---

### Вариант: политика для Transit Auto-Unseal

Политика с минимальными правами на операции шифрования и дешифрования через Transit Engine:

```hcl
module "policy_transit" {
  source = "../../../modules/vault_custom_policy"

  name = "autounseal-policy"
  rules = [
    { path = "auth/token/lookup-self",               capabilities = ["read"] },
    { path = "transit-autounseal/encrypt/autounseal", capabilities = ["update"] },
    { path = "transit-autounseal/decrypt/autounseal", capabilities = ["update"] },
  ]
}

module "transit" {
  source      = "../../../modules/secret_engine_transit"
  name        = "autounseal"
  path        = "transit-autounseal"
  policy_name = module.policy_transit.policy_name
}
```

---

## **Паттерны glob в путях**

Vault поддерживает два вида glob в путях политик:

```hcl
# Wildcard (*) – любая строка на любой глубине
{ path = "secret/data/*",  capabilities = ["read"] }

# Segment placeholder (+) – заменяет ровно один сегмент пути
{ path = "secret/data/+/config", capabilities = ["read"] }

# Конкретный путь без glob
{ path = "auth/token/lookup-self", capabilities = ["read"] }
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующее выходное значение:

| Output | Тип | Описание |
|---|---|---|
| `policy_name` | `string` | Имя созданной политики – передаётся в `token_policies` auth-методов |

Запросить значение output можно с помощью следующей команды:

```bash
terragrunt output policy_name
```

---

## **После apply**

После успешного применения конфигурации проверить созданную политику можно с помощью следующих команд:

```bash
# Проверить содержимое политики
vault policy read my-app-policy

# Список всех политик
vault policy list

# Проверить права конкретного токена на путь
vault token capabilities <token> secret/data/my-app/config

# Проверить свои права от текущего VAULT_TOKEN
vault token capabilities secret/data/my-app/config
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
