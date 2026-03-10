# **Модуль: system_identity_oidc**

**Модуль system_identity_oidc** – настраивает Vault как OIDC token provider. Создаёт signing key и роли для генерации подписанных JWT токенов: залогиненный пользователь или сервис может запросить OIDC токен у Vault, а другой сервис – проверить его подпись через JWKS endpoint Vault и аутентифицировать пользователя без прямого обращения к Vault.

---

## **Как работает**

Vault Identity OIDC позволяет Vault самому выступать в роли провайдера идентичности. Залогиненный субъект запрашивает токен через `vault read identity/oidc/token/<role>`. Vault подписывает JWT своим приватным ключом и возвращает его. Стороны-получатели (приложения, другие сервисы) проверяют подпись через публичный JWKS endpoint Vault и принимают решение об аутентификации на своей стороне.

**Ключ (`vault_identity_oidc_key`)** – это signing key (RSA или EC) с автоматическим периодом ротации. После ротации старый публичный ключ остаётся в JWKS в течение `verification_ttl` – достаточно, чтобы токены, выданные до ротации, успели пройти валидацию. `verification_ttl` должен быть не менее 2× `rotation_period`: иначе после ротации токены выданные в «мёртвой зоне» между двумя ротациями не смогут быть проверены.

**Роль (`vault_identity_oidc_role`)** – конфигурация генерируемого токена: TTL, дополнительные claims из entity metadata через template, client_id для идентификации аудитории.

---

## **Параметры модуля**

| Параметр | Тип | Значение по умолчанию | Описание |
|---|---|---|---|
| `issuer` | `string` | `""` | Issuer URL в токене (`iss` claim). Пусто = использовать адрес Vault |
| `key_name` | `string` | `"default"` | Имя signing key |
| `algorithm` | `string` | `"RS256"` | Алгоритм подписи: `RS256`, `RS384`, `RS512`, `ES256`, `ES384`, `ES512`, `EdDSA` |
| `rotation_period` | `number` | `86400` | Период ротации ключа в секундах (по умолчанию 24h) |
| `verification_ttl` | `number` | `86400` | Как долго старый публичный ключ остаётся валидным после ротации. Должно быть `>= 2 × rotation_period` |
| `allowed_client_ids` | `list(string)` | `[]` | Список `client_id` ролей, которым разрешено использовать ключ. Пусто = все |
| `roles` | `list(object)` | `[]` | Список ролей для генерации токенов |

### Структура объекта в переменной `roles`

| Поле | Тип | Описание |
|---|---|---|
| `name` | `string` | Имя роли – используется в пути `identity/oidc/token/<name>` |
| `ttl` | `number` | TTL токена в секундах |
| `template` | `string` | JSON template с дополнительными claims из entity metadata. Пусто = только стандартные claims |
| `client_id` | `string` | Идентификатор аудитории. Пусто = Vault генерирует автоматически |

---

## **Template для дополнительных claims**

Через `template` можно добавить в токен произвольные claims из entity metadata и групп:

```json
{
  "groups": {{identity.entity.groups.names}},
  "team":   {{identity.entity.metadata.team}}
}
```

Доступные переменные в template:

| Переменная | Значение |
|---|---|
| `{{identity.entity.id}}` | Entity ID |
| `{{identity.entity.name}}` | Имя entity |
| `{{identity.entity.metadata}}` | Все metadata как объект |
| `{{identity.entity.metadata.<key>}}` | Конкретное значение metadata |
| `{{identity.entity.groups.names}}` | Список имён групп |
| `{{identity.entity.groups.ids}}` | Список ID групп |

---

## **Примеры вызова модуля**

### Простой вариант: ключ без ролей

Минимальный пример – только signing key, без ролей (заглушка или будущее использование):

```hcl
module "oidc" {
  source = "../../../modules/system_identity_oidc"

  key_name         = "demo-key"
  algorithm        = "RS256"
  rotation_period  = 86400
  verification_ttl = 172800   # 2× rotation_period
  roles            = []
}
```

---

### Полный вариант: ключ с ролями и кастомными claims

Рекомендуемый подход для Production – роли с явными `client_id` и template для передачи metadata:

```hcl
module "oidc" {
  source = "../../../modules/system_identity_oidc"

  key_name         = "apps"
  algorithm        = "RS256"
  rotation_period  = 86400    # ротация раз в 24h
  verification_ttl = 172800   # старый ключ валиден 48h после ротации

  roles = [
    {
      name      = "my-app"
      ttl       = 3600
      template  = "{\"groups\": {{identity.entity.groups.names}}, \"team\": {{identity.entity.metadata.team}}}"
      client_id = "my-app"
    },
    {
      name      = "ci-pipeline"
      ttl       = 300
      template  = ""
      client_id = "ci-pipeline"
    },
  ]
}
```

---

### Вариант: проверка OIDC токена на стороне получателя

Пример проверки JWT токена Vault в Python:

```python
import jwt
import requests

# Получить JWKS из Vault
jwks_uri = "http://vault:8200/v1/identity/oidc/.well-known/keys"
jwks = requests.get(jwks_uri).json()

# Декодировать и проверить JWT
token = "<jwt-from-vault>"
public_key = jwt.algorithms.RSAAlgorithm.from_jwk(jwks["keys"][0])
payload = jwt.decode(token,
                     public_key,
                     algorithms=["RS256"],
                     audience="my-app")
print(payload)
# {"sub": "alice", "groups": ["ops-team"], "team": "ops", ...}
```

---

## **Outputs**

После выполнения `terragrunt apply` модуль предоставляет следующие выходные значения:

| Output | Тип | Описание |
|---|---|---|
| `key_name` | `string` | Имя signing key |
| `role_client_ids` | `map(string)` | Карта `role_name → client_id` – используется как `audience` при валидации токенов |
| `issuer` | `string` | Issuer URL – значение `iss` claim в выданных токенах |

Запросить значения outputs можно с помощью следующих команд:

```bash
terragrunt output key_name
terragrunt output -json role_client_ids
terragrunt output issuer
```

---

## **После apply**

После успешного применения конфигурации проверить работу OIDC можно с помощью следующих команд:

```bash
# Залогиниться в Vault (нужна entity с alias)
vault login -method=userpass username=alice

# Получить OIDC токен для роли
vault read identity/oidc/token/my-app

# Декодировать полученный JWT (без проверки подписи)
echo "<jwt>" | cut -d. -f2 | base64 -d 2>/dev/null | jq .

# Посмотреть конфигурацию ключа
vault read identity/oidc/key/apps

# Посмотреть JWKS endpoint – публичные ключи для валидации токенов
curl http://localhost:8200/v1/identity/oidc/.well-known/keys

# Посмотреть OIDC configuration (discovery document)
curl http://localhost:8200/v1/identity/oidc/.well-known/openid-configuration

# Список ролей
vault list identity/oidc/role

# Прочитать конфигурацию роли
vault read identity/oidc/role/my-app
```

Примечание: Подробнее о том, как вызываются модули в рамках конкретного окружения, можно посмотреть в директории [`environments/`](../../environments/).
